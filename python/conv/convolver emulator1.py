from bit import *
import numpy as np
import random
import cv2
from matplotlib import pyplot as plt

compute_out_hll = 1
generate_files = 1
eval_output_ver = 1
verilog_output_recons = 1

img_file = 'leena.jpg'
img_ver_file = "1input_image.bin"
filter_ver_file = "1input_filter.bin"
output_py_file = "1output_image.bin"
output_ver_file = "1output_image_ver.bin"
output_compare_file = "1output_image_ver_test.bin"

##FILTERS
gx = np.array([[1,0,-1],[2,0,-2],[ 1,0,-1]],dtype='float')
gy = np.array([[1,2,1],[0,0,0],[ 1,2,1]],dtype='float')


v1 = float(1)/16; v2 = float(1)/2;
lpf = np.array([[v1,v1,v1],[v1,v2,v1],[v1,v1,v1]],dtype='float')

v3 = float(1)/8;
hpf = np.array([[v3,v3,v3],[v3,-v3,v3],[v3,v3,v3]],dtype='float')


#in_flt = np.copy(gx)
in_flt = np.copy(lpf)	
#in_flt = np.copy(hpf)
#in_flt = np.copy(gy)

img_save_str = "lpf"


#MAKE A NEW ARRAY AND COMPUTE OUTPUT FROM PYTHON(HLL)
if(compute_out_hll==1):

	im_h = 400; im_w = im_h



	


	out_img = np.zeros((im_h-2,im_w-2))




	# for i in range(1,im_h-1):   
	# 	for j in range(1,im_w-1):
	# 		in_img[i,j] = .7*i+.3*j

	# for i in range(1,im_h-1):
	# 	for j in range(1,im_w-1):
	# 		in_img[i,j] = (float(random.randint(0,1000))/1000)*50 - 10
	in_img = cv2.imread(img_file)
	in_img,c,b = cv2.split(in_img)
	in_img = in_img.astype('float')
	in_img = in_img/2

	# for i in range(0,3):
	# 	for j in range(0,3):
	# 		in_flt[i,j] = .8*i -.5*j

	# for i in range(0,3):
	#  	for j in range(0,3):
	#  		in_flt[i,j] = (float(random.randint(0,1000))/1000)*3 - 1.5


	print in_flt

	for i in range(0,im_h-2):
		for j in range(0,im_w-2):
			out_img[i,j] += in_img[i,j]		*in_flt[0,0]
			out_img[i,j] += in_img[i,j+1]	*in_flt[0,1]
			out_img[i,j] += in_img[i,j+2]	*in_flt[0,2]
			out_img[i,j] += in_img[i+1,j]	*in_flt[1,0]
			out_img[i,j] += in_img[i+1,j+1]	*in_flt[1,1]
			out_img[i,j] += in_img[i+1,j+2]	*in_flt[1,2]
			out_img[i,j] += in_img[i+2,j]	*in_flt[2,0]
			out_img[i,j] += in_img[i+2,j+1]	*in_flt[2,1]
			out_img[i,j] += in_img[i+2,j+2]	*in_flt[2,2]
	#print in_img



#GENERATE THE FILES FOR INPUT TO THE CONVOLVER
if(generate_files==1):
	file = open(img_ver_file,"w")
	for i in range(0,im_h):
		for j in range(0,im_w):
			file.write(int2bin(in_img[i,j],16,8)+'\n')
	file.close()

	file = open(filter_ver_file,"w")
	for i in range(0,3):
		for j in range(0,3):
			file.write(int2bin(in_flt[i,j],16,8)+'\n')
	file.close()

	file = open(output_py_file,"w")
	for i in range(0,im_h-2):
		for j in range(0,im_w-2):
			file.write(int2bin(out_img[i,j],16,8)+'\n')
	file.close()	


imo_h = im_h -2

#EVALUATE THE OUTPUT FROM THE VERILOG MODULE
if(eval_output_ver):

	accu = 0

	out_ver = [line.rstrip('\n') for line in open(output_ver_file)]
	out_ver = [x.strip() for x in out_ver] 
	
	file = open(output_compare_file,"w")
	for i in range(0,imo_h*imo_h):
		#print bin2int(out_ver[i])

		s1 = str(out_ver[i])

		#print i/28, i%28
		n1 = float(bin2int(out_ver[i]))/(65536)
		s2 = str(n1)

		s3 = int2bin(out_img[i/imo_h,i%imo_h],16,8)
		s4 = str(out_img[i/imo_h,i%imo_h])
		file.write( s1+' <-- '+s2 + ' ||| ' + s3 + ' ' + s4 +"------------  " +  str(out_img[i/imo_h,i%imo_h]-n1)+ '\n' )
		accu = accu + abs(out_img[i/imo_h,i%imo_h]-n1)
	accu = accu/(imo_h*imo_h)
	print accu		


if(verilog_output_recons):
	out_ver_recn = [line.rstrip('\n') for line in open(output_ver_file)]
	out_ver_recn = [x.strip() for x in out_ver]
	recns = np.zeros([imo_h,imo_h])
	for i in range(0,imo_h*imo_h):
		#print bin2int(out_ver[i])

		s1 = str(out_ver[i])

		#print i/28, i%28
		n1 = float(bin2int(out_ver[i]))/(65536)
		recns[i/imo_h,i%imo_h]  = n1

#OUTPUT RECNSTRN
out_img = out_img*2
recns = recns*2
out_img = out_img.astype('uint8')
recns = recns.astype('uint8')

cv2.imshow("win",out_img)
cv2.imshow("win1",recns)
cv2.waitKey(0)
cv2.imwrite(img_save_str+"_py.jpg",out_img)
cv2.imwrite(img_save_str+"_ver.jpg",recns)
