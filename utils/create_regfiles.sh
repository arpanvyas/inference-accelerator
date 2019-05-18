#!/bin/bash

rm inst -f

./xls_to_regfile.pl register_set.ods 2 3 4 5 6


mv regfile_*.sv interface_regfile.sv ../design/modules/reg_intf/hdl/

