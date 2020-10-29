program test(intf i_intf);



task transaction(
    input   [1:0]   rw_type,
    input   [13:0]  addr,
    input   [15:0]  data,
    input   [4:0]   pre_pad = 0,
    input   [4:0]   post_pad = 0

    );

    logic clk_gate;
    logic test_SCLK;
    logic [31:0] mosi_buffer;
    logic [31:0] miso_buffer;

    string rw;
    logic [15:0] received_data;

    begin
        
        if(rw_type == 2'b00) begin
            rw = "Read";
        end else if (rw_type == 2'b01) begin
            rw = "Write";
        end else begin
            $display("Bad rw_type provided, %b",rw_type);
            return;
        end
        //$display("Starting SPI transaction, Type: %s, Addr: %x, Data: %x",rw, addr, data); 




        mosi_buffer = {rw_type,addr,data};
        
        fork
            begin //clocking
                test_SCLK = 0;
                forever begin
                    #20 test_SCLK = ~test_SCLK;
                end
            end //clocking


            begin
                forever @(test_SCLK or clk_gate)  begin
                    i_intf.SCLK = (clk_gate && test_SCLK);
                end
            end //driving test_SCLK to SCLK

            begin //transaction
                clk_gate <= 0;
                repeat(pre_pad) begin
                    @(negedge test_SCLK);
                end //pre padding
                
                clk_gate <= 1;
                i_intf.SS <= 0;
                
                i_intf.MOSI <= mosi_buffer[31];
                mosi_buffer[31:1] <= mosi_buffer[30:0];
                
                repeat(31) begin
                    @(posedge test_SCLK);
                    miso_buffer[0] <= i_intf.MISO;
                    miso_buffer[31:1] <= miso_buffer[30:0];
                    @(negedge test_SCLK);
                    i_intf.MOSI <= mosi_buffer[31];
                    mosi_buffer[31:1] <= mosi_buffer[30:0];
                end
                    @(posedge test_SCLK);
                    miso_buffer[0] <= i_intf.MISO;
                    miso_buffer[31:1] <= miso_buffer[30:0];
                    @(negedge test_SCLK);
                    received_data <= miso_buffer[15:0];

                    @(posedge test_SCLK);



                i_intf.SS <= 1;
                clk_gate <= 0;
                
                repeat(post_pad) begin
                    @(posedge test_SCLK);
                end //post padding


            end //transaction
        join_any

        if(rw_type == 2'b00) begin
            $display("Ended SPI Read Transaction, Addr: %x, Data Received: %x",addr, received_data);
        end else if (rw_type == 2'b01) begin
            $display("Ended SPI Write Transaction, Addr: %x, Data Written: %x",addr, data);
        end
        
        disable fork;
        return;
    end



endtask




initial begin

    fork 

        begin
            i_intf.SS = 1;
            i_intf.SCLK = 0;
            i_intf.MOSI = 0;
            
            #40;
            #3;

            //transaction(2'b00,14'h0001, 16'habcd,1,1);
            //transaction(2'b01,14'h0001, 16'h8fff,1,1);
            //transaction(2'b00,14'h0001, 16'h0121,1,1);
            //transaction(2'b01,14'h0001, 16'h0897,1,1);
            //transaction(2'b00,14'h0001, 16'h0999,1,1);
            //transaction(2'b01,14'h0001, 16'h0999,1,1);
            //transaction(2'b00,14'h0001, 16'h0999,1,1);

            #20;
            #100;
            //#(1872856-(20+100+43)); //after conv
            #25000000;
            //#10000000;
            


            $finish;
        end

        begin
        end
    join
end




endprogram

