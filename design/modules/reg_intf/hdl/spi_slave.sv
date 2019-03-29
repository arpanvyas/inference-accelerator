module spi_slave(
    input clk,
    input rst,

    //SPI
    input   MOSI,
    input   SCLK,
    input   SS,
    output logic  MISO,

    //REG INTF
    input           [15:0]  tx_data,
//    input                   tx_data_en,
    output  logic   [13:0]  rx_addr,
    output  logic           rx_addr_en,
    output  logic   [1:0]   rx_rw_mode,
    output  logic           rx_rw_mode_en,
    output  logic   [15:0]  rx_data,
    output  logic           rx_data_en,
    
    output  logic           rd_en_stretch,
    output  logic           wr_en_stretch

);


/////////////////////////////////////////////////////////////
//CORE SPI FUNCTIONALITY (almost, see Tx)
/////////////////////////////////////////////////////////////

logic [15:0] buffer_rx;
logic [15:0] buffer_tx;


logic [5:0]  counter_p;
logic [5:0]  counter_n;

//Rx - sample on posedge
always@(posedge SCLK, posedge SS) begin
    if (SS) begin 
      //  buffer_rx <= 0;
    end else if (!SS) begin
        buffer_rx[0] <= #1 MOSI;
        buffer_rx[15:1] <= #1 buffer_rx[14:0];
    end
end

//Tx - drive on negedge
always@(negedge SCLK, posedge SS) begin
    if (SS) begin
        MISO <= #1 0;
    end else begin
        if(counter_p == 16) begin
            MISO <= #1 tx_data[15];
        end else begin
            MISO <= #1 buffer_tx[15];
        end
    end
end






/////////////////////////////////////////////////////////////
//CONTROL LOGIC SPECIFICALLY FOR THE TRANSFER FORMAT CHOSEN
/////////////////////////////////////////////////////////////


//Counter
always@(posedge SCLK, posedge SS) begin
    if (SS) begin
        counter_p <= #1 0;
    end else begin
        if(counter_p == 31) 
            counter_p <= #1 0;
        else 
            counter_p <= #1 counter_p + 1;
    end
end

always@(negedge SCLK, posedge SS) begin
    if (SS) begin
        counter_n <= #1 0;
    end else begin
        if(counter_n == 31)
            counter_n <= #1 0;
        else
            counter_n <= #1 counter_n + 1;
    end
end

//Control
always@(posedge SCLK, posedge SS) begin
    if(SS) begin
        // rx_rw_mode <= #1 0;
    end else begin
        if(counter_p == 1) begin
            rx_rw_mode <= #1 {buffer_rx[0],MOSI};
        end else begin
            rx_rw_mode <= #1 rx_rw_mode;
        end
    end
end

//Sending Rx Addr, Rx Rw Mode and Rx data to Regbank
always@(posedge SCLK, posedge SS) begin
    if(SS) begin
      //  rx_addr <= #1 0;
        rx_addr_en <= #1 0;
      //  rx_data <= #1 0;
        rx_data_en <= #1 0;
        rx_rw_mode_en <= #1 0;
    end else begin 

        rx_addr_en <= #1 0;
        rx_data_en <= #1 0;
        rx_addr    <= #1 rx_addr;
        rx_data    <= #1 rx_data;
        rx_rw_mode_en <= #1 0;

        if(counter_p == 15) begin
            rx_addr <= #1 {buffer_rx[12:0],MOSI};
            if(rx_rw_mode == 0) begin //read
                rx_rw_mode_en <= #1 1;
                rx_addr_en <= #1 1;
            end
        end else if (counter_p == 31) begin
            if(rx_rw_mode == 1) begin //write
                rx_data <= #1 {buffer_rx[14:0],MOSI};
                rx_data_en <= #1 1;
                rx_addr_en <= #1 1;
                rx_rw_mode_en <= #1 1;
            end
        end

    end

end


//Taking Tx Data from Regbank

logic tx_data_en;


always@(negedge SCLK,posedge SS) begin
    if (SS) begin
        buffer_tx <= #1 0;
    end else begin
        if(tx_data_en) begin
            buffer_tx[15:1] <= #1 tx_data[14:0];
        end else begin
            buffer_tx[15:2] <= #1 buffer_tx[14:1];
        end 
    end //~SS
end

assign tx_data_en = (counter_p == 16 && rx_rw_mode == 0) ? 1 : 0;


//RD_EN and WR_EN to pass to regintf
logic [1:0] rd_en_count;

always@(posedge SCLK, posedge rst)
begin
    if(rst) begin
        rd_en_count <= #1 0;
        rd_en_stretch <= #1 0;
    end else begin 
        if(counter_p == 15 && rx_rw_mode == 2'b00) begin
            rd_en_count <= #1 1;
            rd_en_stretch <= #1 1;
        end else if (rd_en_count == 1) begin
            rd_en_count <= #1 2;
            rd_en_stretch <= #1 1;
        end else if (rd_en_count == 2) begin
            rd_en_count <= #1 0;
            rd_en_stretch <= #1 0;
        end
    end
end

logic [1:0] wr_en_count;

always@(posedge SCLK, posedge rst)
begin
    if(rst) begin
        wr_en_count <= #1 0;
        wr_en_stretch <= #1 0;
    end else begin
        if(counter_p == 31 && rx_rw_mode == 2'b01) begin
            wr_en_count <= #1 1;
            wr_en_stretch <= #1 1;
        end else if (wr_en_count == 1) begin
            wr_en_count <= #1 2;
            wr_en_stretch <= #1 1;
        end else if (wr_en_count == 2) begin
            wr_en_count <= #1 0;
            wr_en_stretch <= #1 0;
        end
    end
end


/////////////////////////////////////////////
//WORKING
/////////////////////////////////////////////
//At the 16th bit from Master (posedge)
//
//  i. Write operation
//      Wait till 32th bit from Master (posedge)
//      Send Write Addr, Write Mode, Write Data and All Enables together
//
//  ii. Read operation
//      Send Read Addr and Read Mode to regfile
//      In regfile : Read Addr -> Read Data to tx_data combinatorially
//      Some delay after posedge of sample, tx_data is ready
//      tx_data -> buffer_tx -> MISO
//      Since, regintf freq 10x to 5x of SPI, by the next negedge data arrives
//      on tx_data and is stable
//      tx_data_en : to be high for 1 SCLK posedge
//      

endmodule

