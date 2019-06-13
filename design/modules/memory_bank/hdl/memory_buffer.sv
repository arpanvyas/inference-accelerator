`include "header.vh"
module memory_buffer(
    input		rst,
    input       clk,
    interface_buffer    intf_buf

);

`include "user_tasks.vh"



logic [`WID_PE_BITS-1:0] m1_input_bus_unpack [`N_BUF-1:0];
logic [`WID_PE_BITS-1:0] m1_output_bus_unpack [`N_BUF-1:0];

`UNPACK_ARRAY(`WID_PE_BITS,`N_BUF,m1_input_bus_unpack,intf_buf.m1_input_bus)
`PACK_ARRAY(`WID_PE_BITS,`N_BUF,m1_output_bus_unpack,intf_buf.m1_output_bus)

logic		[`N_BUF-1:0]		    m_w_en;
logic		[`N_BUF-1:0]		    m_r_en;
logic		[`ADDR_RAM-1:0]	        m_r_addr    [`N_BUF-1:0];
logic		[`ADDR_RAM-1:0]	        m_w_addr    [`N_BUF-1:0];
logic	    [`WID_PE_BITS-1:0]      m_w_data    [`N_BUF-1:0];
logic       [`WID_PE_BITS-1:0]      m_r_data    [`N_BUF-1:0];
logic	    [5:0]				    m0_r_en_dec;


integer i1;
always@(*)
begin
    case(intf_buf.mode)

        0: begin    //Only one address here as serial: i.e only one buffer reading/writing at a time

            //1. ENABLES
            m_w_en	<= #1 intf_buf.m0_w_en;
            m_r_en  <= #1 intf_buf.m0_r_en;

            //2. ADDRESSES
            
                //Send the read/write address to all buffers, the rd_en/wr_en will decide
                //where the reads/writes come from
            for (int i1 = 0; i1 <`N_BUF; i1 = i1+1) begin
              m_r_addr[i1] <= #1 intf_buf.m0_r_addr;
              m_w_addr[i1] <= #1 intf_buf.m0_w_addr;
            end


            //3. DATA M0

                //Put the appropriate read data to the output read word m0_r_data
            intf_buf.m0_r_data	<= #1 m_r_data[hot_to_dec(intf_buf.m0_r_en)];

                //Put the write date to all buffers, the wr_en will decide where
                //to write to
            for(i1=0;i1<`N_BUF;i1=i1+1) begin//put the serial write data to each buffer	
                m_w_data[i1]	<= #1 intf_buf.m0_w_data;	
            end
            

            //4. READ DATA M1
            for(i1=0;i1<`N_BUF;i1=i1+1) begin	
                m1_output_bus_unpack[i1] <= #1 m_r_data[i1];
            end

        end

        1: begin    //Multiple addresses here as parallel: i.e. Many buffers simultaneously working
            
            //1. ENABLES
            m_w_en   <= #1 intf_buf.m1_w_en;
            m_r_en   <= #1 intf_buf.m1_r_en;

            //2. ADDRESSES
            m_w_addr <= #1 intf_buf.m1_w_addr;
            m_r_addr <= #1 intf_buf.m1_r_addr;	

            //3. DATA M1
            for(i1=0;i1<`N_BUF;i1=i1+1) begin	
                m_w_data[i1]	<= #1 m1_input_bus_unpack[i1];
                m1_output_bus_unpack[i1]	<= #1 m_r_data[i1];
            end	

            //4. READ DATA M0
            intf_buf.m0_r_data	<= #1 m_r_data[m0_r_en_dec];

        end

    endcase
end


genvar i;
generate for(i=0 ; i<`N_BUF ; i=i+1)
begin
    memory_bank memory_bank 
    (
        .clk		(clk),
        .we			(m_w_en[i]),
        .re			(m_r_en[i]),
        .rd_addr	(m_r_addr[i]),
        .wr_addr	(m_w_addr[i]),
        .data_in	(m_w_data[i]),
        .data_out	(m_r_data[i])
    );

end
endgenerate


endmodule
