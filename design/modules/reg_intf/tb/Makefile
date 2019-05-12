
RTL_FILES = ../hdl/reg_intf.sv \
			../hdl/spi_slave.sv \
			../hdl/reg_intf_mux.sv \
			../hdl/regfile_conv.sv \
			../hdl/regfile_fc.sv \
			../hdl/regfile_general_config.sv \
			../hdl/regfile_nl.sv \
			../hdl/regfile_pool.sv \
		    ../hdl/sync_2s.sv	

TB_FILES = spi_tb.sv \
		   -incdir .

compile_hdl:
	irun -access +rwc $(RTL_FILES)  -c -snapshot spisnap

compile_tb:
	irun -access +rwc $(TB_FILES)  -c -snapshot spisnap

compile: compile_hdl compile_tb	

run:
	irun -access +rwc -r spisnap -gui 

run1:
	irun -gui -access +rwc $(RTL_FILES) $(TB_FILES) 

all: compile run
