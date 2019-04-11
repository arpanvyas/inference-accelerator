module spi_master(

    //interface with host
    input   clk,    
    input   rst,
    input   tx_en,
    input [31:0] tx_data,
    input             rw_mode,
    output logic [15:0] rx_data,
    output logic       rx_en,

    //interface with slave
    output  logic      SCLK,
    output  logic      MOSI,
    input            MISO,
    output  logic      SS
);


logic [5:0] counter;
logic [31:0] tx_data_buffer;
logic [15:0] rx_data_buffer;
logic        mode_buffer;

always@(negedge clk, posedge rst)
begin
    if(rst) begin
        counter <= 0;
        tx_data_buffer <= 0;
        rx_data_buffer <= 0;
        rx_data <= 0;
        rx_en <= 0;
        SS <= 1;
        MOSI <= 0;
    
    end else begin
        if(tx_en && counter == 0) begin
            tx_data_buffer <= tx_data;
            mode_buffer <= rw_mode;
            counter <= 1;
            SS <= 0;
        end else if (counter >= 1 && counter <= 14) begin
            MOSI <= tx_data_buffer[31];
            tx_data_buffer[31:19] <= tx_data_buffer[30:18];
            tx_data_buffer[18] <= 0;
            counter <= counter + 1;
        end else if (counter == 15) begin
            MOSI <= mode_buffer;
            counter <= counter + 1;
        end else if (counter == 16) begin
            MOSI <= 0;
            counter <= counter + 1;
        end else if (counter >= 17 && counter <= 32) begin
            if(mode_buffer == 1'b0) begin //read
                rx_data_buffer[0] <= MISO;
                rx_data_buffer[15:1] <= rx_data_buffer[14:0]; 
            end else begin //mode_buffer == 1'b1
                MOSI <= tx_data_buffer[15];
                tx_data_buffer[15:1] <= tx_data_buffer[14:0];
                tx_data_buffer[0] <= 0;
            end
            counter <= counter + 1;

        end else if (counter == 33) begin
            SS <= 1;
            if(mode_buffer == 1'b0) begin 
                rx_en <= 1;
                rx_data <= rx_data_buffer;
            end
            counter <= 0;

        end else begin //counter == 0 and tx_en == 0
            counter <= 0;
            SS <= 1;
            mode_buffer <= 0;
        end

    end


end

logic gate_sclk;
assign gate_clk = (counter>1 && counter<=33) ? 1 : 0;

assign SCLK = gate_clk && clk;


endmodule

