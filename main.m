% 对两种加密方式进行实验仿真
clc;clear all;close all;clear;

%% 加密演示
im = double(imread('E:\date\ccia_CVG_image\color_image_512/lena.ppm'));
cover = double(imread('E:\date\ccia_CVG_image\color_image_512/baboon.ppm'));

[m,n,k]=size(im);
[M,N,K]=size(cover);
key='8d5ab8ba5340fce4420829ad5d12a0e45dacb0858544163d04c1d02b73e3697d';
[ cip,dnkey,ext_val,sort_hist,nc ] = encryption( im,cover,key );
[ rim ] = dencryption( cip,cover,dnkey,ext_val,sort_hist, [m,n,k] );
 
figure(1)
imshow(uint8(im))
figure(2)
imshow(uint8(cover))
figure(3)
imshow(uint8(cip))
figure(4)
imshow(uint8(rim))
figure(5)
imshow(uint8(nc))








