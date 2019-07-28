`include "header.vh"
module PE(
    input rst,
    input clk,
    input logic [`N_BUF-1:0] shifting_line,
    input logic [`N_PE-1:0]  shifting_filter,
    input logic              shifting_bias,
    input logic [`N_PE-1:0]  mac_enable,
    input logic              bias_enable,
    input logic              nl_enable,
    input logic              feedback_enable,

    input line_buffer_reset,
    input [`ADDR_FIFO-1:0]	row_length,
    input adder_enable,
    input								pool_enable,
    input logic [15:0]                  pool_type,
    input logic [15:0]                  pool_horiz,
    input logic [15:0]                  pool_vert,

    input logic                         dense_enable,
    input logic [7:0]                   dense_valid,
    input logic                         dense_adder_reset,
    input logic                         dense_adder_on,

    input [15:0]					    nl_type,
    input [`WID_PE_BITS-1:0]		    input_bus1_PE [`N_BUF-1:0],	//line inputs to all the convolvers = 32*16b
    input [`WID_PE_BITS-1:0]			input_2_PE,		//feedback input for the Single PE
    output[`WID_PE_BITS-1:0]			output_1_PE,    //Single PE output

    interface_regfile                   regfile
);

logic signed    [`WID_PE_BITS-1:0]		output_mac			[`N_PE-1:0];
wire		        					adder_enable;
reg		        [`WID_PE_BITS-1:0]		interm_add;

parameter PE_index = 0;

genvar i;
generate for(i=0 ; i<`N_CONV ; i=i+1)
begin
    convolver convolver_module
    (
        .rst						(rst),
        .clk						(clk),
        .shifting_line				(shifting_line[i]),
        .input_line					(input_bus1_PE[i]),
        .shifting_filter			(shifting_filter[i]),
        .line_buffer_reset			(line_buffer_reset),
        .row_length					(row_length),
        .input_filter				(input_bus1_PE[i]),
        .mac_enable					(mac_enable[i]),
        .output_mac					(output_mac[i]),
        .regfile                    (regfile)
    );
end
endgenerate

logic signed [`WID_PE_BITS-1:0] adder_tree_out;

adder_tree	adder_tree_module
(
    .rst						(rst),
    .clk						(clk),
    .output_mac     			(output_mac),
    .mac_enable                 (mac_enable),
    .adder_enable				(|mac_enable),
    .adder_tree_out				(adder_tree_out)
);


//Feedback Adder

logic signed [`WID_PE_BITS-1:0]		fb_adder_out, dense_adder_out;

always_ff@(posedge clk, posedge rst) begin

    if(rst) begin
        fb_adder_out <= #1 0;
    end else begin
        if(feedback_enable) begin
            fb_adder_out <= #1 adder_tree_out + input_2_PE;
        end else begin
            fb_adder_out <= #1 adder_tree_out;
        end

    end
end




logic signed [`WID_PE_BITS-1:0] in_nl_data,out_nl_data, out_pool_data, out_dense_data;
logic signed [`WID_PE_BITS-1:0] bias_add_out, bias_add_in, bias_val;

assign bias_add_in = (dense_enable == 1) ? dense_adder_out : fb_adder_out;


always_ff@(posedge clk, posedge rst) begin
    if(rst) begin
        bias_add_out <= #1 0;
        bias_val     <= #1 0;
    end else begin
        if(bias_enable) begin
            bias_add_out <= #1 bias_add_in + bias_val;
        end else begin
            bias_add_out <= #1 bias_add_in;
        end

        if(dense_enable == 0) begin //in case of conv take bias from last buffer i.e. #32 and in form of line (as all bias are clubbed together in last buffer)
            if(shifting_bias) begin
                bias_val <= #1 input_bus1_PE[`N_PE]; //bias comes from buffer#32
            end else begin
                bias_val <= #1 bias_val;
            end
        end else begin //in case of dense take bias from PE_index buffer and in form of filter (as each filter has 1 bias with it in its own buffer)
            if(shifting_bias) begin
                bias_val <= #1 input_bus1_PE[PE_index];
            end else begin
                bias_val <= #1 bias_val;
            end
        end
    end
end


assign in_nl_data = bias_add_out;


non_linearity	non_linearity_module
(
    .rst						(rst),
    .clk						(clk),
    .nl_enable					(nl_enable),
    .nl_type					(nl_type),
    .in_nl_data					(in_nl_data),
    .out_nl_data				(out_nl_data),
    .regfile                    (regfile)
);



assign output_1_PE = (pool_enable == 1 ) ? out_pool_data : out_nl_data;


pooling	pooling_module
(
    .rst							(rst),
    .clk							(clk),
    .shifting_line					(shifting_line[PE_index]),
    .line_buffer_reset				(line_buffer_reset),
    .row_length						(row_length),
    .input_line 				 	(input_bus1_PE[PE_index]),
    .pool_enable					(pool_enable),
    .pool_type                      (pool_type),
    .pool_horiz                     (pool_horiz),
    .pool_vert                      (pool_vert),
    .out_pool_data					(out_pool_data),
    .regfile                        (regfile)
);

densing densing_module
(
    .rst							(rst),
    .clk							(clk),
    .shifting_line					(shifting_line[`N_PE]), //dense input
    .line_buffer_reset				(line_buffer_reset),
    .row_length						(row_length),
    .input_line 				 	(input_2_PE), //dense input
    .shifting_filter                (shifting_filter[PE_index]), //dense weight
    .input_filter                   (input_bus1_PE[PE_index]), //dense weight
    .dense_valid                    (dense_valid),
    .out_dense_data					(out_dense_data),
    .regfile                        (regfile)
);

//Dense Adder
always_ff@(posedge clk, posedge rst) begin
    if(rst) begin
        dense_adder_out <= #1 0;
    end else begin

        if(dense_adder_reset) begin
            dense_adder_out <= #1 0;
        end else if(dense_adder_on) begin
            dense_adder_out <= #1 dense_adder_out + out_dense_data;
        end

    end


end



endmodule























