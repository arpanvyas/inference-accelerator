
module spi_master_tb();

    reg   clk;    //100MHz
    reg   rst;
    reg   tx_en;
    reg [31:0] tx_data;
    reg [1:0]  rw_mode;
    wire [15:0] rx_data;
    wire        rx_en;

    //interface with slave
    wire  SCLK;
    wire  MOSI;
    reg   MISO;
    wire  SS;

    spi_master MASTER (

        .clk(clk),    //100MHz
        .rst(rst),
        .tx_en(tx_en),
        .tx_data(tx_data),
        .rw_mode(rw_mode),
        .rx_data(rx_data),
        .rx_en(rx_en),

    //interface with slave
        .SCLK(SCLK),
        .MOSI(MOSI),
        .MISO(MISO),
        .SS(SS)


    );


    always
        #5   clk <= ~clk;

    initial begin
        clk = 0;
        rst = 1;
        MISO = 0;
        tx_en   = 0;
        tx_data = 0;
        rw_mode = 0;

        @(posedge clk);
        @(posedge clk);
        rst = 0;

        @(posedge clk);
        @(posedge clk);

        tx_data = 32'ha28bc10e;
        tx_en   = 1;
        rw_mode = 0;
        repeat(40) begin
            @(posedge clk);
            tx_en = 0;
            MISO = $random;
        end

        tx_data = 32'h01234567;
        tx_en   = 1;
        rw_mode = 1;

        repeat(50) begin
            @(posedge clk);
            tx_en = 0;
        end
           

        $finish;
    end


endmodule
