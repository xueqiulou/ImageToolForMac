# -*- coding: UTF-8 -*-

#上一句代码保证可以使用中文文本,不然会报错...


import os
import sys

#导入tinify提供的库
import tinify

#在tinify官网申请的key,免费的key每个月有500张图片可以压缩,再多了需要付费购买
appKey = sys.argv[2];
tinify.key = appKey;

#图片所在目录
sourcePath = sys.argv[1]

#需要放图片的目标目录
resultPath = sys.argv[1]

print("参数1: "+sys.argv[1]);
print("源路径: "+sys.argv[1]);
print("目标路径: "+sys.argv[1]);

if not os.path.exists(resultPath):
    os.makedirs(resultPath)
    pass

def compressImage(sourcePath):
	filenames = os.listdir(sourcePath);
	count = 0;

	print("共有"+str(len(filenames))+"张需要压缩图片🔥🔥🔥"+"\n\n\n");
	for filename in filenames:
		if filename.endswith(('jpg','png','jpeg','bmp')):
			unoptimizeFile = os.path.join(sourcePath,filename);
			toFile = unoptimizeFile
			count = count+1;
			print("正在压缩第"+str(count)+"张图片...");
			source = tinify.from_file(unoptimizeFile)
			source.to_file(toFile)
		else:
			print(filename+"不是图片")
	print("所有图片压缩完成✅✅✅");
	pass	

def iterate(targetPath):
	filenames = os.listdir(targetPath);
	count = 0
	for filename in filenames:
		filePath = os.path.join(targetPath,filename)
		if os.path.isdir(filePath):
			count = count +1
			iterate(filePath) #递归调用遍历
		elif os.path.isfile(filePath):
			print(filePath + "是文件2")
	if count == 0:
		print("内部没有文件夹了!!!")
		compressImage(targetPath)



iterate(sourcePath)


