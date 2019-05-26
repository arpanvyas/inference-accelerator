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
    output logic execute_2,
    output logic next_layer

);


typedef enum { IDLE, FETCH, EXECUTE_1,EXECUTE_2, DONE} ProgdrvStates;

ProgdrvStates state;
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




always_ff@(posedge clk, posedge rst)
begin
    if(rst) begin
        state <= #1 IDLE;
        pc    <= #1 0;
        re    <= #1 0;
        send_regfile <= #1 0;
    end else begin
        
        execute_2 <= #1 0;
        next_layer  <= #1 0;

        case(state) 

            IDLE : begin
                send_regfile <= #1 0;
                if(run_program) begin
                    if(pc < pc_max) begin
                        re <= #1 1;
                        state <= #1 FETCH;
                    end else begin
                        state <= #1 IDLE;
                        re <= #1 0;
                    end
                end else begin
                    state <= #1 IDLE;
                    re    <= #1 0;
                    
                end
            
            end

            FETCH : begin //should be here for exactly 1 cycle
                re <= #1 0;
                pc <= #1 pc + 1;
                send_regfile <= #1 1;
                state <= #1 EXECUTE_1;
        
            end

            EXECUTE_1 : begin

                send_regfile <= #1 0;
                next_layer   <= #1 0;

                if(instr[31:30] == 2'b01 && instr[29:23] == 7'h01) begin //wait for done when Wr and WOC
                    state <= #1 EXECUTE_2; 
                    execute_2 <= #1 1;
                    
                end else begin //send to regfile
                    state <= #1 IDLE;
                    
                end

                if(instr[31:30] == 2'b01 && instr[29:16] == 14'h01) begin
                    next_layer  <= #1 1;
                end



            end

            EXECUTE_2 : begin
                if(done_executing == 1) begin
                    state <= #1 IDLE;
                end else begin
                    state <= #1 EXECUTE_2; 
                end

            end

            default : begin
                state <= #1 IDLE;

            end
        
        endcase

    end




end






endmodule
