`include "header.vh"
module external_memory(
	input logic clk,
    interface_extmem intf_extmem
);

logic [`DATA_EXT_RAM-1:0] mem[ 2**`ADDR_EXT_RAM - 1:0];

always@(posedge clk)
begin
    if (intf_extmem.re) begin
	intf_extmem.rd_data <= #1 mem[intf_extmem.rd_addr];
	end
	
	if (intf_extmem.we) begin
	mem[intf_extmem.wr_addr] <= #1 intf_extmem.wr_data;
	end

end


//Storing Model in RAM
integer i;
initial
begin

    for (i = 0; i < 2**`ADDR_EXT_RAM; i ++ )
    begin
        mem[i] = 0;
    end

    $readmemb("model.dat",mem,0);
    $readmemb("input.dat",mem,4194304);

end

endmodule
