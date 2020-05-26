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
integer f_pool;
integer f_conv1;
integer f_conv2;
initial
begin

    f_conv1 = $fopen("conv1out.dat","w");
    f_conv2 = $fopen("conv2out.dat","w");
    f_pool = $fopen("poolout.dat","w");
    
    for (i = 0; i < 2**`ADDR_EXT_RAM; i ++ )
    begin
        mem[i] = 0;
    end

    $readmemb("model.dat",mem,0);
    //use this from end of model allocated memory
    $readmemb("input.dat",mem,1572864);


    #24000000; //all finished by this time
    j = 0;
    //use these ranges from interm.map
    //for( i = 7340032; i < 7361664; i++) 
    for( i = 1966080; i < 2009344; i++) 
    begin
        $fwrite(f_conv1, "%b\n", mem[i]);
        j = j + 1;
        if(j%676 == 0) begin
            $fwrite(f_conv1,"----------\n");
        end
    end

    j = 0;
    //use these ranges from interm.map
    //for( i = 7361664; i < 7398528; i++)
    for( i = 2009344; i < 2046208; i++)
    begin
        $fwrite(f_conv2, "%b\n", mem[i]);
        j = j + 1;
        if(j%576 == 0) begin
            $fwrite(f_conv2,"----------\n");
        end
    end


    j = 0;
    //use these ranges from interm.map
    //for(i = 7398528; i < 7407744; i ++)
    for(i = 2046208; i < 2055424; i ++)
    begin
        
        $fwrite(f_pool,"%b\n", mem[i]);
        j = j + 1;
        if(j%144 == 0) begin
            $fwrite(f_pool,"----------\n");
        end
    end

    $fclose(f_conv1);
    $fclose(f_conv2);
    $fclose(f_pool);

end

endmodule
