module program_driver (
    input logic clk,
    input logic rst,

    //To controller -> regintf
    output logic  wr_en_drv,
    output logic rd_en_drv,
    output logic [13:0] addr_drv,
    output logic [15:0] write_data_drv,
    input logic [15:0] read_data_drv,

    //From to Controller
    input logic done_executing,
    input logic [31:0] pc_max,
    input logic run_program,
    output logic execute_2

);


parameter IDLE = 3'b000, FETCH = 3'b010, EXECUTE_1 = 3'b011,EXECUTE_2 = 3'b100, DONE = 3'b101;

logic [2:0] state;
logic [31:0] pc; 
logic [31:0] instr;

logic we;
logic re;

logic send_regfile;

logic wr_en_drv1;
logic [13:0] addr_drv1;

assign we = 0;
program_memory Iprogram_memory (

    .clk(clk),
    .we(we),
    .re(re),
    .rd_addr(pc),
    .data_out(instr)
);

assign wr_en_drv = (send_regfile) ? ( (instr[31:30] == 2'b01) ? 1 : 0 ) : 0;
assign wr_en_drv1 = (send_regfile) ? ( (instr[31:30] == 2'b01) ? 1 : 0 ) : 0;
assign rd_en_drv = (send_regfile) ? ( (instr[31:30] == 2'b10) ? 1 : 0 ) : 0;
assign addr_drv  = instr[29:16];
assign addr_drv1  = instr[29:16];
assign write_data_drv  = instr[15:0];




always@(posedge clk, posedge rst)
begin
    if(rst) begin
        state <= IDLE;
        pc    <= 0;
        re    <= 0;
        send_regfile <= 0;
    end else begin
        
        case(state) 

            IDLE : begin
                send_regfile <= 0;
                if(run_program) begin
                    if(pc < pc_max) begin
                        re <= 1;
                        state <= FETCH;
                    end else begin
                        state <= IDLE;
                        re <= 0;
                    end
                end else begin
                    state <= IDLE;
                    re    <= 0;
                    
                end
            
            end

            FETCH : begin //should be here for exactly 1 cycle
                re <= 0;
                pc <= pc + 1;
                send_regfile <= 1;
                state <= EXECUTE_1;
        
            end

            EXECUTE_1 : begin

                send_regfile <= 0;

                if(instr[31:30] == 2'b10 && instr[13:7] == 7'h01) begin //wait for done when Wr and WOC
                    state <= EXECUTE_2; 
                    
                end else begin //send to regfile
                    state <= IDLE;
                    
                end



            end

            EXECUTE_2 : begin
                if(done_executing == 1) begin
                    state <= IDLE;
                end else begin
                    state <= EXECUTE_2; 
                end

            end

            default : begin
                state <= IDLE;

            end
        
        endcase

    end




end






endmodule
