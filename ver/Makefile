export PROJECT_DIR
export PROJECT_RTL_DIR
export PROJECT_VER_DIR

RTL_DIR=
RTL_FILES=
TB_FILES=
HEADER_FILES=

ifndef TC
	TC=test
endif
ifndef SEED
	SEED=12345
endif
ifndef MODULE
	MODULE=conv
endif
export TC
export SEED
export MODULE



IRUN_OPTS += -access +rw -vlog_ext .v,.vh 
IRUN_GUIOPTS += $(IRUN_OPTS) -gui 
IRUN_SNAPOPTS += $(IRUN_OPTS) -elaborate

#LOG FILES
IRUN_OPTS += -logfile $$PROJECT_VER_DIR/LOGS/irun.log
IRUN_GUIOPTS += -log_ncsim $$PROJECT_VER_DIR/LOGS/$(TC)_$(SEED).log -k $$PROJECT_VER_DIR/LOGS/$(TC)_$(SEED).key
IRUN_SNAPOPTS += -log_ncelab $$PROJECT_VER_DIR/LOGS/$(MODULE)_ncelab.log -log_ncvlog $$PROJECT_VER_DIR/LOGS/$(MODULE)_ncvlog.log

#SEEDS
IRUN_GUIOPTS += -snseed $(SEED) -svseed $(SEED)

#WORKDIR
##IRUN_OPTS += -work $$PROJECT_VER_DIR/SNAPSHOTS
IRUN_OPTS += -nclibdirpath $$PROJECT_VER_DIR/SNAPSHOTS -incdir $(RTL_DIR)

#SOURCE FILES
IRUN_SNAPOPTS += $(RTL_FILES) $(TB_FILES) $(HEADER_FILES)

#TCL FILES
IRUN_GUIOPTS += -input $$PROJECT_VER_DIR/TCL/force.do

#FOR COMPILING DIFFERENT MODULES
ifeq ($(MODULE), conv)
RTL_DIR=$$PROJECT_RTL_DIR/modules/convolver/rtl
RTL_FILES += $(RTL_DIR)/*
TB_FILES += $$PROJECT_VER_DIR/HDL/tb_convolver.v
HEADER_FILES += $$PROJECT_RTL_DIR/modules/top/header/header.vh
IRUN_SNAPOPTS += -snapshot convsnap
IRUN_GUIOPTS += -r convsnap -input $$PROJECT_VER_DIR/TCL/force_conv.do
else ifeq ($(MODULE),top)
include $$PROJECT_VER_DIR/MAKEFILES/Makefile.top
else ifeq ($(MODULE), pe)
include $$PROJECT_VER_DIR/MAKEFILES/Makefile.pe_array
else ifeq ($(MODULE), mem)
include $$PROJECT_VER_DIR/MAKEFILES/Makefile.memory_bank
endif

clean:
	rm -rf $$PROJECT_VER_DIR/SNAPSHOTS/*

rtl:
	irun $(IRUN_SNAPOPTS)
	
runtest:
	irun $(IRUN_GUIOPTS)	

