import cv2
import numpy as np
import binary as b1

fo = open("conv2out.dat","r")
lines = fo.readlines()
lines_filter = []
for itr in lines:
    lines_filter.append(itr.rstrip())


imgs = []

idx = 0

for i1 in range(0,64):
    im_this = []
    for i2 in range(0,24):
        row = []
        for i3 in range(0,24):
            #print(idx)
            row.append(lines_filter[idx])
            idx += 1
        im_this.append(row)
    imgs.append(im_this)
    idx += 1

img_dec = imgs

for i1 in range(0,64):
    for i2 in range(0,24):
        for i3 in range(0,24):
            k = b1.bin2int(imgs[i1][i2][i3])
            k = float(k)

            if(k>255):
                k = 255

            k = k/255
            
            k = pow(k,.2)
            k = k*255
    
            img_dec[i1][i2][i3] = k
            

roll=0 
for i1 in range(0,64):
    img_this = np.array(img_dec[i1])
    if(roll == 1):
        img_this = np.roll(img_this,-6,axis=1)

    if(i1 == -1):
        print(img_this.astype(int))
    img_new = cv2.resize(img_this,(144,144))
    cv2.imwrite(str(i1)+".png",img_new)


