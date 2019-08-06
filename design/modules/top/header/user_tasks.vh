`include "header.vh"


function automatic hot_to_dec;
    input [`N_BUF-1:0] hot;
    output [`LOG_N_BUF-1:0] dec;
    integer i;
    begin
        dec = 0;
        for(i=0;i<`N_BUF;i=i+1) begin
            if(hot[i] == 1) begin
                dec	= i;
            end else begin
                dec	= dec;
            end
        end
    end
endfunction


function automatic [`N_BUF-1:0] dec_to_hot;

    input   [`LOG_N_BUF-1:0]   dec;
    integer i;

    begin
        if(dec > `N_BUF-1) begin //because indexed from 0
            dec_to_hot = 'd0;
        end else begin
            dec_to_hot = 'd0;
            dec_to_hot[dec]    = 1'b1;
        end

    end

endfunction
