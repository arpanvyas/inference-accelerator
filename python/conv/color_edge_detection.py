from bit import *
import numpy as np
import random
import cv2

generate_files = 1
compute_out_hll = 1


if(compute_out_hll):
	img = cv2.imread("leena.jpg")
	img = img.astype('float')
	print img.shape

	gx = np.array([[1,0,-1],[2,0,-2],[ 1,0,-1]])
	gy = np.array([[1,2,1],[0,0,0],[ -1,-2,-1]])
	in_img = np.zeros([400,400,6])
	in_flt = np.zeros([3,3,6])
	b,g,r = cv2.split(img)
	out_img = np.zeros([398,398,6])


	in_img[:,:,0] = np.copy(b)
	in_img[:,:,0] = np.copy(b)
	in_img[:,:,1] = np.copy(g)
	in_img[:,:,1] = np.copy(g)
	in_img[:,:,2] = np.copy(r)
	in_img[:,:,2] = np.copy(r)

	in_flt[:,:,0] = np.copy(gx)
	in_flt[:,:,1] = np.copy(gy)
	in_flt[:,:,2] = np.copy(gx)
	in_flt[:,:,3] = np.copy(gy)
	in_flt[:,:,4] = np.copy(gx)
	in_flt[:,:,5] = np.copy(gy)

	im_h = 400
	im_w = 400

	for k in range(0,6):

		for i in range(0,im_h-2):
			for j in range(0,im_w-2):
				out_img[i,j,k] += in_img[i,j,k]		*in_flt[0,0,k]
				out_img[i,j,k] += in_img[i,j+1,k]	*in_flt[0,1,k]
				out_img[i,j,k] += in_img[i,j+2,k]	*in_flt[0,2,k]
				out_img[i,j,k] += in_img[i+1,j,k]	*in_flt[1,0,k]
				out_img[i,j,k] += in_img[i+1,j+1,k]	*in_flt[1,1,k]
				out_img[i,j,k] += in_img[i+1,j+2,k]	*in_flt[1,2,k]
				out_img[i,j,k] += in_img[i+2,j,k]	*in_flt[2,0,k]
				out_img[i,j,k] += in_img[i+2,j+1,k]	*in_flt[2,1,k]
				out_img[i,j,k] += in_img[i+2,j+2,k]	*in_flt[2,2,k]


	out_edge = np.zeros([398,398])

	out_edge = out_img[:,:,0]+out_img[:,:,1]+out_img[:,:,2]+out_img[:,:,3]+out_img[:,:,4]+out_img[:,:,5]
	out_edge /= 6

out_edge = out_edge.astype('uint8')
cv2.imshow("win",out_edge)
cv2.waitKey(0)


if(generate_files):
	for k in range(0,6):
		file = open("pe_input_image"+str(k)+".bin","w")
		for i in range(0,im_h):
			for j in range(0,im_w):
				file.write(int2bin(in_img[i,j,k],16,8)+'\n')
		file.close()


		file = open("pe_input_filter"+str(k)+".bin","w")
		for i in range(0,3):
			for j in range(0,3):
				file.write(int2bin(in_flt[i,j,k],16,8)+'\n')
		file.close()


	file = open("pe_output_image.bin","w")
	for i in range(0,im_h-2):
		for j in range(0,im_w-2):
			file.write(int2bin(out_edge[i,j],16,8)+'\n')
	file.close()	
