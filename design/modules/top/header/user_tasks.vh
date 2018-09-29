`include "header.vh"


task hot_to_dec;
input [`N_PE-1:0] hot;
output [4:0] dec;
integer i;
begin
	dec = 0;
	for(i=0;i<`N_PE;i=i+1) begin
		if(hot[i])	dec	= i;
		else 			dec	= dec;
	end
end
endtask	