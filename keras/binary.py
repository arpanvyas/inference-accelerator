def int2bin(n,frac_bits,tot_bits):
    n = float(n)
    if(n<0):
        n1 = n + 2**tot_bits
    else:
        n1 = n

    int_part = int(n1)
    frac_part = float(n1) - float(int(n1))

    #print(int_part)
    #print(frac_part)

    s_int = ""
    s_frac = ""

    for i in range(0,frac_bits):
        frac_part = frac_part*2
        if(int(frac_part) == 1):
            s_frac = s_frac+"1"
            frac_part = frac_part - 1
        else:
            s_frac = s_frac+"0"

    dec_bits = tot_bits-frac_bits
    
    for i in range(0,dec_bits):
        if(int_part%2 == 1):
            s_int = "1"+s_int
        else:
            s_int = "0"+s_int
        int_part = int(int_part/2)

    s = s_int + s_frac

    return s




def bin2int(s,not_two_comp):
    l = len(s)
    
    n1 = 0
    for i in range(0,l):
        if(s[l-i-1] == "1"):
            n1 = n1 + (2**i)


    if(not_two_comp == 1): #original string not two_complement
        return n1
    elif(not_two_comp == 0): #original string in two_complement form 
        n2 = 2**l
        n3 = 2**(l-1)
        if(n1 >= n3):
            return n1-n2
        else:
            return n1
    else:
        exit("error here in bin2int")

   
#print(int2bin(-0.5,8,16))
#print(bin2int("1111",0))
