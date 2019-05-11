import re
import reg_map as reg
import binary as b1
from mem_param import mem_param as mem

def assembler(assembly,regfile,machine_dump):
    machine = []
    for instr in assembly:
        valid_write = re.search('^write (\w+), (0x[0-9a-fA-F]+)$',instr)
        valid_read = re.search('^read (\w+), (0x[0-9a-fA-F]+)$',instr)
        if valid_write:
            regname = valid_write.group(1)
            data    = valid_write.group(2)
            regpack = reg.regaddr(regfile,regname)
            #print(regname, data)
            instr_this = "01"+b1.int2bin(regpack['regaddrint'],0,16)+b1.int2bin(int(data,16),0,16)
            #print(instr_this)
            machine.append(instr_this)
        elif valid_read:
            regname = valid_write.group(1)
            data    = valid_write.group(2)
            regpack = reg.regaddr(regfile,regname)
            #print(regname, data)
            instr_this = "10"+b1.int2bin(regpack['regaddrint'],0,16)+b1.int2bin(int(data,16),0,16)
            #print(instr_this)
            machine.append(instr_this)
        else:
            print("Unrecognised assmebly instruction")
            print(instr)
            return 0

    dumpfile = open(machine_dump,"w")

    for item in machine:
        dumpfile.write(item+'\n')

    dumpfile.close()

    return machine


if __name__ == "__main__":
    regfile = reg.regmap("../utils/register_set.ods")
    assembly = ["write REG_0003, 0x9e12", "write REG_0005, 0x2"]
    machine = assembler(assembly,regfile,machine_dump)
