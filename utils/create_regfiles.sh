#!/bin/bash

rm inst -f

./xls_to_regfile.pl register_set.ods 2 3 4 5 6

for x in `ls regfile*.sv`; do
    ~/data/lib/scripts/perl_rtl/mod_to_inst.pl $x >> inst
done

vim -c "source clean_mod_regfiles.vim | wq" inst

mv regfile_*.sv inst ../design/modules/reg_intf/hdl/

