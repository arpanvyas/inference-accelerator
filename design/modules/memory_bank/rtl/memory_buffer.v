`include "header.vh"
module memory_buffer(
	input 									rst,
	input										clk,
	input										mode,
	input		[`N_PE-1:0]					m0_r_en,
	input		[`ADDR_RAM-1:0]			m0_r_addr,
	output reg		[`WID_RAM-1:0]		m0_r_data,
	input		[`N_PE-1:0]					m0_w_en,
	input		[`ADDR_RAM-1:0]			m0_w_addr,
	input		[`WID_RAM-1:0]				m0_w_data,
	
	input										m1_r_en,
	input		[`ADDR_RAM-1:0]			m1_r_addr,
	output	[`WID_PE_BITS*`N_PE-1:0]m1_output_bus,
	input										m1_w_en,
	input		[`ADDR_RAM-1:0]			m1_w_addr,
	input		[`WID_PE_BITS*`N_PE-1:0]m1_input_bus
    );

`include "user_tasks.vh"



wire [`WID_PE_BITS-1:0] m1_input_bus_unpack [`N_PE-1:0];
reg [`WID_PE_BITS-1:0] m1_output_bus_unpack [`N_PE-1:0];

`UNPACK_ARRAY(`WID_PE_BITS,`N_PE,m1_input_bus_unpack,m1_input_bus)
`PACK_ARRAY(`WID_PE_BITS,`N_PE,m1_output_bus_unpack,m1_output_bus)

reg		[`N_PE-1:0]		m_w_en;
reg		[`N_PE-1:0]		m_r_en;
reg		[`ADDR_RAM-1:0]	m_r_addr;
reg		[`ADDR_RAM-1:0]	m_w_addr;
reg	 [`WID_PE_BITS-1:0] m_w_data [`N_PE-1:0];
wire [`WID_PE_BITS-1:0] m_r_data [`N_PE-1:0];
reg	 [4:0]				m0_r_en_dec;


integer i1;
always@(*)
begin
	hot_to_dec(m0_r_en,m0_r_en_dec);
	case(mode)
	
		0: begin
			m_w_en	<=	m0_w_en;
			m_r_en	<=	m0_r_en;
			m_w_addr <=	m0_w_addr;
			m_r_addr <=	m0_r_addr;
			m0_r_data	<= m_r_data[m0_r_en_dec];
			for(i1=0;i1<`N_PE;i1=i1+1) begin	
				m_w_data[i1]	<=	m0_w_data;	
				m1_output_bus_unpack[i1] <= m_r_data[i1];
			end

		end
			
		1: begin


			m_w_addr<=	m1_w_addr;
			m_r_addr<=	m1_r_addr;	

			for(i1=0;i1<`N_PE;i1=i1+1) begin	
				m_w_en[i1]		<=	m1_w_en;
				m_r_en[i1]		<=	m1_r_en;
				m_w_data[i1]	<= m1_input_bus_unpack[i1];
				m1_output_bus_unpack[i1]	<=	m_r_data[i1];
			end	
			m0_r_data	<= m_r_data[m0_r_en_dec];
		
		end

		default: begin
			
			m_w_en	<=	m0_w_en;
			m_r_en	<=	m0_r_en;
			m_w_addr <=	m0_w_addr;
			m_r_addr <=	m0_r_addr;
			
			for(i1=0;i1<`N_PE;i1=i1+1) begin	
				m_w_data[i1]	<=	m0_w_data;
				m1_output_bus_unpack[i1]	<=	m_r_data[i1];

			end
			m0_r_data	<= m_r_data[m0_r_en_dec];
	
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
