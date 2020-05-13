import math

def int2bin(z,num,frac_bits):
    i = int(z*math.pow(2,frac_bits))
    s1 = ''
    for m in range(0,num):
       s1 = "0" + s1
    if i == 0: return s1
    si = ''
    j = 1
    while (i > 0 or j < num+1):
        if i & 1 == 1:
            si = "1" + si
        else:
            si = "0" + si
        i /= 2
        j += 1
    return si

def bin2int(s):
   def toTwosComplement(binarySequence):
       convertedSequence = [0] * len(binarySequence)
       carryBit = 1
       # INVERT THE BITS
       for i in range(0, len(binarySequence)):
           if binarySequence[i] == '0':
               convertedSequence[i] = 1
           else:
               convertedSequence[i] = 0

       # ADD BINARY DIGIT 1

       if convertedSequence[-1] == 0: #if last digit is 0, just add the 1 then there's no carry bit so return
               convertedSequence[-1] = 1
               return ''.join(str(x) for x in convertedSequence)

       for bit in range(0, len(binarySequence)):
           if carryBit == 0:
               break
           index = len(binarySequence) - bit - 1
           if convertedSequence[index] == 1:
               convertedSequence[index] = 0
               carryBit = 1
           else:
               convertedSequence[index] = 1
               carryBit = 0

       return ''.join(str(x) for x in convertedSequence)
   num = len(s)
   sign = 0
   if(s[0]=="1"):
      s=toTwosComplement(s)
      sign = 1
   n=0
   l=1
   for i in range(0,num):
      k=num-1-i
      n=n+int(s[k])*l
      l=l*2
   if(sign):
      return -1*n
   else:
      return n


if __name__ == '__main__':
  print int2bin(-15.2,16,8)