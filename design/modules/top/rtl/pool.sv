module pool(
    input   logic   clk,
    input   logic   rst,
    input   logic   start,
    interface_regfile   regfile,
    interface_pe_array_ctrl     intf_pea_ctrl,
    interface_buffer_m1_ctrl    intf_buf1_m1_ctrl,
    interface_buffer_m1_ctrl    intf_buf2_m1_ctrl,
    output  logic   aybz_azby,
    output  logic   done

);


assign aybz_azby = 0;

always_ff@(posedge clk, posedge rst) begin

    if(rst) begin
        done <= #1 0;
    end else begin
    
        done <= #1 0;

        if(start) begin
            done <= #1 1;
        end

    end
end




endmodule
