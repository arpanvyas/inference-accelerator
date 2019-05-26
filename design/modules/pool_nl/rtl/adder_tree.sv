`include "header.vh"
module adder_tree(
    input								rst,
    input								clk,
    input								adder_enable,
    input	[`WID_PE_BITS*`N_PE-1:0]	output_mac_packed,
    output	[`WID_PE_BITS-1:0]		adder_tree_out
    );


wire[`WID_PE_BITS-1:0]	output_mac		[`N_PE-1:0];
reg [`WID_PE_BITS-1:0]	adder_stage1	[`N_PE/2-1:0]; //16 output
reg [`WID_PE_BITS-1:0]	adder_stage2	[`N_PE/4-1:0]; //8 output
reg [`WID_PE_BITS-1:0]	adder_stage3	[`N_PE/8-1:0]; //4 output
//reg [`WID_PE_BITS-1:0]	adder_stage4	[`N_PE/16-1:0]; //2 output
//reg [`WID_PE_BITS-1:0]	adder_stage5; //1 output
integer					i1,i2,i3,i4,i5;

`UNPACK_ARRAY(`WID_PE_BITS,`N_PE,output_mac,output_mac_packed)

initial begin


end

always @(posedge clk, posedge rst)
begin
	if(rst) begin
			for(i1=0;i1<`N_PE/2;i1=i1+1) begin
				adder_stage1[i1]	<= 0;
			end
			for(i2=0;i2<`N_PE/4;i2=i2+1) begin
				adder_stage2[i2]	<= 0;
			end
			for(i3=0;i3<`N_PE/8;i3=i3+1) begin
				adder_stage3[i3]	<= 0;				
			end
//			for(i4=0;i4<`N_PE/16;i4=i4+1) begin
//				adder_stage4[i4]	<=0;								
//			end
//			adder_stage5			<= 0;
	
	end else begin
		if(adder_enable) begin
			

			for(i1=0;i1<`N_PE/2;i1=i1+1) begin
				adder_stage1[i1]	<= output_mac[2*i1]+output_mac[2*i1+1];
			end

			for(i2=0;i2<`N_PE/4;i2=i2+1) begin
				adder_stage2[i2]	<= adder_stage1[2*i2]+adder_stage1[2*i2+1];
			end

			for(i3=0;i3<`N_PE/8;i3=i3+1) begin
				adder_stage3[i3]	<= adder_stage2[2*i3]+adder_stage2[2*i3+1];				
			end

//			for(i4=0;i4<`N_PE/16;i4=i4+1) begin
//				adder_stage4[i4]	<= adder_stage3[2*i4]+adder_stage3[2*i4+1];								
//			end

//			adder_stage5			<= adder_stage4[0] + adder_stage4[1];

		end		
	end
end


//assign adder_tree_out = adder_stage5;

assign adder_tree_out = adder_stage3[0];













endmodule