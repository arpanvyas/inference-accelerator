numfrom bit import *
import numpy as np
import random
import cv2
from matplotlib import pyplot as plt

generate_files = 1
eval_output_ver = 1
compute_out_hll = 1

#MAKE A NEW ARRAY AND COMPUTE OUTPUT FROM PYTHON(HLL)
if(compute_out_hll==1):

	im_h = 30; im_w = im_h
	in_img = np.zeros((im_h,im_w))
	in_flt = (np.zeros((3,3))).astype(float)
	out_img = np.zeros((im_h-2,im_w-2))

	random.seed(238)

	# for i in range(1,im_h-1):   
	# 	for j in range(1,im_w-1):
	# 		in_img[i,j] = .7*i+.3*j

	for i in range(1,im_h-1):
		for j in range(1,im_w-1):
			in_img[i,j] = (float(random.randint(0,1000))/1000)*50 - 10



	# for i in range(0,3):
	# 	for j in range(0,3):
	# 		in_flt[i,j] = .8*i -.5*j

	for i in range(0,3):
	 	for j in range(0,3):
	 		in_flt[i,j] = (float(random.randint(0,1000))/1000)*3 - 1.5


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
	print in_img



#GENERATE THE FILES FOR INPUT TO THE CONVOLVER
if(generate_files==1):
	file = open("input_image.bin","w")
	for i in range(0,im_h):
		for j in range(0,im_w):
			file.write(int2bin(in_img[i,j],16,8)+'\n')
	file.close()

	file = open("input_filter.bin","w")
	for i in range(0,3):
		for j in range(0,3):
			file.write(int2bin(in_flt[i,j],16,8)+'\n')
	file.close()

	file = open("output_image.bin","w")
	for i in range(0,im_h-2):
		for j in range(0,im_w-2):
			file.write(int2bin(out_img[i,j],16,8)+'\n')
	file.close()	



#EVALUATE THE OUTPUT FROM THE VERILOG MODULE
if(eval_output_ver==1):

	accu = 0

	out_ver = [line.rstrip('\n') for line in open("output_image_ver.bin")]
	out_ver = [x.strip() for x in out_ver] 
	
	file = open("output_image_ver_test.bin","w")
	for i in range(0,784):
		#print bin2int(out_ver[i])

		s1 = str(out_ver[i])

		#print i/28, i%28
		n1 = float(bin2int(out_ver[i]))/(65536)
		s2 = str(n1)

		s3 = int2bin(out_img[i/28,i%28],16,8)
		s4 = str(out_img[i/28,i%28])
		file.write( s1+' <-- '+s2 + ' ||| ' + s3 + ' ' + s4 +"------------  " +  str(out_img[i/28,i%28]-n1)+ '\n' )
		accu = accu + out_img[i/28,i%28]-n1

accu = accu/784
print accu		

