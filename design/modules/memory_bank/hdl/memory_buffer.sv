`include "header.vh"
module memory_buffer(
    input		rst,
    input       clk,
    interface_buffer    intf_buf

);

`include "user_tasks.vh"



logic [`WID_PE_BITS-1:0] m1_input_bus_unpack [`N_PE-1:0];
logic [`WID_PE_BITS-1:0] m1_output_bus_unpack [`N_PE-1:0];

`UNPACK_ARRAY(`WID_PE_BITS,`N_PE,m1_input_bus_unpack,intf_buf.m1_input_bus)
`PACK_ARRAY(`WID_PE_BITS,`N_PE,m1_output_bus_unpack,intf_buf.m1_output_bus)

logic		[`N_PE-1:0]		m_w_en;
logic		[`N_PE-1:0]		m_r_en;
logic		[`ADDR_RAM-1:0]	m_r_addr;
logic		[`ADDR_RAM-1:0]	m_w_addr;
logic	 [`WID_PE_BITS-1:0] m_w_data [`N_PE-1:0];
logic [`WID_PE_BITS-1:0] m_r_data [`N_PE-1:0];
logic	 [5:0]				m0_r_en_dec;


integer i1;
always@(*)
begin
    case(intf_buf.mode)

        0: begin
            m_w_en	<= #1 intf_buf.m0_w_en;
            m_w_addr <= #1 intf_buf.m0_w_addr;

            for(i1=0;i1<`N_PE;i1=i1+1) begin	
                m_w_data[i1]	<= #1 intf_buf.m0_w_data;	
                m1_output_bus_unpack[i1] <= #1 m_r_data[i1];
            end



            m_r_en  <= #1 intf_buf.m0_r_en;
            m_r_addr <= #1 intf_buf.m0_r_addr;

            intf_buf.m0_r_data	<= #1 m_r_data[hot_to_dec(intf_buf.m0_r_en)];

        end

        1: begin


            m_w_addr <= #1 intf_buf.m1_w_addr;
            m_r_addr <= #1 intf_buf.m1_r_addr;	

            for(i1=0;i1<`N_PE;i1=i1+1) begin	
                m_w_en[i1]		<= #1 intf_buf.m1_w_en;
                m_r_en[i1]		<= #1 intf_buf.m1_r_en;
                m_w_data[i1]	<= #1 m1_input_bus_unpack[i1];
                m1_output_bus_unpack[i1]	<= #1 m_r_data[i1];
            end	
            intf_buf.m0_r_data	<= #1 m_r_data[m0_r_en_dec];

        end

    endcase
end


genvar i;
generate for(i=0 ; i<`N_PE ; i=i+1)
begin
    memory_bank memory_bank 
    (
        .clk		(clk),
        .we			(m_w_en[i]),
        .re			(m_r_en[i]),
        .rd_addr	(m_r_addr),
        .wr_addr	(m_w_addr),
        .data_in	(m_w_data[i]),
        .data_out	(m_r_data[i])
    );

end
endgenerate


endmodule
