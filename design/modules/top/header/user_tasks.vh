`include "header.vh"


function automatic hot_to_dec;
input [`N_BUF-1:0] hot;
output [5:0] dec;
integer i;
begin
	dec = 0;
	for(i=0;i<`N_BUF;i=i+1) begin
		if(hot[i])	dec	= i;
		else 			dec	= dec;
	end
end
endfunction


function automatic [`N_BUF-1:0] dec_to_hot;

    input   [5:0]   dec;
    integer i;

    begin
        dec_to_hot = 'd0;
        dec_to_hot[dec]    = 1'b1;

    end

endfunction
