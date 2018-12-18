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
IRUN_RTLOPTS += $(IRUN_OPTS) -elaborate
IRUN_TBOPTS += $(IRUN_OPTS) -elaborate
IRUN_GUIOPTS += $(IRUN_OPTS) -gui 

#LIBRARY NAMES
IRUN_OPTS += -nclibdirpath $$PROJECT_VER_DIR/SNAPSHOTS -nclibdirname INCA_accel 

#SOURCE FILES
IRUN_RTLOPTS += $(RTL_FILES) $(HEADER_FILES) -incdir $(INCLUDE_DIRS)
IRUN_TBOPTS += $(TB_FILES) -incdir $(INCLUDE_DIRS)
#HEADER FILES
HEADER_FILES += $$PROJECT_RTL_DIR/modules/top/header/header.vh
INCLUDE_DIRS += $$PROJECT_RTL_DIR/modules/top/header

#LOG FILES
IRUN_OPTS += -logfile $$PROJECT_VER_DIR/LOGS/irun.log
IRUN_RTLOPTS += -log_ncelab $$PROJECT_VER_DIR/LOGS/$(MODULE)_rtl_ncelab.log -log_ncvlog $$PROJECT_VER_DIR/LOGS/$(MODULE)_rtl_ncvlog.log
IRUN_TBOPTS += -log_ncelab $$PROJECT_VER_DIR/LOGS/$(MODULE)_tb_ncelab.log -log_ncvlog $$PROJECT_VER_DIR/LOGS/$(MODULE)_tb_ncvlog.log
IRUN_GUIOPTS += -log_ncsim $$PROJECT_VER_DIR/LOGS/$(TC)_$(SEED)_$(MODULE).log -k $$PROJECT_VER_DIR/LOGS/$(TC)_$(SEED)_$(MODULE).key

#SEEDS
IRUN_GUIOPTS += -seed $(SEED)
#TCL FILES
IRUN_GUIOPTS += -input $$PROJECT_VER_DIR/TCL/force.do

###########################################################
#FOR COMPILING DIFFERENT MODULES
###########################################################
ifeq ($(MODULE), conv)

#SOURCE
RTL_FILES += $$PROJECT_RTL_DIR/modules/convolver/rtl/*
TB_FILES += $$PROJECT_VER_DIR/HDL/tb_convolver.v

#WORKDIR and SNAPSHOTS
IRUN_TBOPTS += -snapshot convsnap
IRUN_GUIOPTS += -r convsnap

#ADDITIONAL FORCS
IRUN_GUIOPTS += -input $$PROJECT_VER_DIR/TCL/force_conv.do

else ifeq ($(MODULE),top)

RTL_FILES += $$PROJECT_RTL_DIR/modules/*/rtl/*
IRUN_TBOPTS += -snapshot topsnap
IRUN_GUIOPTS += -r topsnap

else ifeq ($(MODULE), pe)

RTL_FILES += $$PROJECT_RTL_DIR/modules/pe_array/rtl/*
IRUN_TBOPTS += -snapshot pesnap
IRUN_GUIOPTS += -r pesnap

else ifeq ($(MODULE), mem)

RTL_FILES += $$PROJECT_RTL_DIR/modules/memory_bank/rtl/*
IRUN_TBOPTS += -snapshot memsnap
IRUN_GUIOPTS += -r memsnap

endif

###########################################################
#TARGETS
###########################################################

clean:
	rm -rf $$PROJECT_VER_DIR/SNAPSHOTS/*
rtl:
	irun $(IRUN_RTLOPTS)
tb:
	irun $(IRUN_TBOPTS) 
run:
	irun $(IRUN_GUIOPTS)	

