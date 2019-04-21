import pyexcel as p


def regmap(filename):
    book = p.get_book(file_name=filename)
    
    tot_sheets = book[0][0,1]
    i_regname = 1
    i_address = 2
    i_fldname = 3
    i_access  = 4
    i_fldsize = 5
    i_startbit= 6
    i_defval  = 7
    addr_bit_size = 16
    
    regfile = []
    
    sheets  =  book.to_dict()
    
    #for itr in 
    
    #print(sheets.keys()[0])
    #print(book['Conv'][0])
    
    sheetnum = 0
    
    #print(len(book[1]))
    
    #Assuming sheets.keys() return sorted keys as per sheet num
    for sheetname in sheets.keys():
        if(sheetname == "Parameters"):
            #regfile.append(sheetname)
            #sheetnum+= 1
            #print("VOILA")
            continue
        else:
            #print("LIOLA")
            a = 0

        
    
        regfile.append(sheetname)
        sheet = book[sheetnum+1]
        rowmax = len(sheet)
        regfile[sheetnum] = {}
        r = 1
        while r < rowmax:
            if(sheet[r,0] == "//"):
                r +=1
            else:
                regname = sheet[r,i_regname]
                regaddr = sheet[r,i_address]
                regaddrint = int(regaddr, addr_bit_size)
                regfile[sheetnum][regaddrint] = {}
                regfile[sheetnum][regaddrint]['name'] = regname
                regfile[sheetnum][regaddrint]['addr'] = regaddr
                regfile[sheetnum][regaddrint]['fields'] = {}
                #print(r,regname)
                while(r < rowmax and sheet[r,i_regname] == regname):
                    startbit = sheet[r,i_startbit]
                    fieldname = sheet[r,i_fldname]
                    access = sheet[r,i_access]
                    fieldsize = sheet[r,i_fldsize]
                    defaultvalue = sheet[r,i_defval]
                    regfile[sheetnum][regaddrint]['fields'][startbit] = {}
                    regfile[sheetnum][regaddrint]['fields'][startbit]['name'] = fieldname
                    regfile[sheetnum][regaddrint]['fields'][startbit]['access'] = access
                    regfile[sheetnum][regaddrint]['fields'][startbit]['startbit'] = startbit
                    regfile[sheetnum][regaddrint]['fields'][startbit]['defval'] = defaultvalue
                    regfile[sheetnum][regaddrint]['fields'][startbit]['fieldsize'] = fieldsize
                     
                    r+=1
    
        #regname = book[sheetnum][]
        
        sheetnum += 1

    return regfile


def fieldaddr(regfile,fieldname_requested):

    sheetnum = 0
    for k1 in regfile: #k1 = sheetnum
        #print(k1)
        for k2 in k1.keys(): #k2 = regaddrint
            regname = k1[k2]['name']
            regaddrint = k2
            regaddr = k1[k2]['addr']
            for k3 in k1[k2]['fields'].keys(): #k3 = startbit
                startbit = k3
                for k4 in k1[k2]['fields'][k3]:
                    fld = k1[k2]['fields'][k3]
                    fieldname = fld['name']
                    defval = fld['defval']
                    access = fld['access']
                    fldsize = fld['fieldsize']
                    if(fieldname == fieldname_requested):
                        fieldpack = {'regname': regname, 'regaddr':regaddr, 'regaddrint': regaddrint}
                        fieldpack['fieldname'] = fieldname
                        fieldpack['startbit'] = startbit
                        fieldpack['defval'] = defval
                        fieldpack['access'] = access
                        fieldpack['length'] = fldsize
                        fieldpack['sheetnum'] = sheetnum
                        return fieldpack
        sheetnum += 1
    #print("Fieldname:",fieldname_requested," not found.")
    return 0

def regaddr(regfile,regname_requested):

    sheetnum = 0
    for k1 in regfile: #k1 = sheetnum
        #print(k1)
        for k2 in k1.keys(): #k2 = regaddrint
            regname = k1[k2]['name']
            regaddrint = k2
            regaddr = k1[k2]['addr']
            if(regname == regname_requested):
                regpack = {'regname':regname, 'regaddr':regaddr, 'regaddrint': regaddrint}
                regpack['sheetnum'] = sheetnum
                return regpack

        sheetnum += 1
    #print("Fieldname:",fieldname_requested," not found.")
    return 0






#Structure
#   regfile: list with sheet as index
#   regfile[n]: dict with regaddr(int) as only key
#   regfile[n][regint] : dict with 'name', 'addr', 'fields'
#   regfile[n][regint]['fields']: dict with startbit(int) as only key
#   regfile[n][regint]['fields'][startbit]: dict with
#       'name', 'access', 'startbit', 'defval', 'fieldsize'
#


if __name__ == "__main__":

    regfile = regmap("../utils/register_set.ods")

    b = regfile[1]
    for k in b.keys():
        for k1 in b[k]['fields'].keys():
            #print(b[k]['fields'][k1]['name'])
            a = 0

    fldreq = "mem_save_buffer_addr"
    fld = fieldaddr(regfile,fldreq)
    if(fld == 0):
        print("Fieldname: ",fldreq," not found.")
    else:
        print(fld['regaddr'],fld['startbit'],fld['length'])

        
