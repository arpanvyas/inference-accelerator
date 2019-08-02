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
integer j;
integer f;
initial
begin

    f = $fopen("poolout.dat","w");
    for (i = 0; i < 2**`ADDR_EXT_RAM; i ++ )
    begin
        mem[i] = 0;
    end

    $readmemb("model.dat",mem,0);
    $readmemb("input.dat",mem,4194304);


    #1990726; //pooling ends here

    j = 0;
    for(i = 7398528; i < 7407744; i ++)
    begin
        
        $fwrite(f,"%b\n", mem[i]);
        j = j + 1;
        if(j%144 == 0) begin
            $fwrite(f,"----------\n");
        end
    end

    $fclose(f);

end

endmodule
