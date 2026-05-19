% 对两种加密方式进行实验仿真
clc;clear all;close all;clear;

%% 加密演示
% im = double(imread('E:\date\ccia_CVG_image\color_image_512/lena.ppm'));
% cover = double(imread('E:\date\ccia_CVG_image\color_image_512/baboon.ppm'));

% im = double(imread('E:\date\ccia_CVG_image\color_image_512/toucan.ppm'));
% cover = double(imread('E:\date\ccia_CVG_image\color_image_512/portofino.ppm'));

% im = double(imread('E:\date\ccia_CVG_image\color_image_512/butfish1.ppm'));
% cover = double(imread('E:\date\ccia_CVG_image\color_image_512/barnfall.ppm'));

% im = double(imread('E:\date\ccia_CVG_image\color_image_512/elephant.ppm'));
% cover = double(imread('E:\date\ccia_CVG_image\color_image_512/sailboat.ppm'));
% 
% [m,n,k]=size(im);
% [M,N,K]=size(cover);
% key='8d5ab8ba5340fce4420829ad5d12a0e45dacb0858544163d04c1d02b73e3697d';
% [ cip,dnkey,ext_val,sort_hist,nc ] = encryption( im,cover,key );
% [ rim ] = dencryption( cip,cover,dnkey,ext_val,sort_hist, [m,n,k] );
%  
% figure(1)
% imshow(uint8(im))
% figure(2)
% imshow(uint8(cover))
% % figure(21)
% % imshow(uint8(cover(:,:,1)))
% % figure(22)
% % imshow(uint8(cover(:,:,2)))
% % figure(23)
% % imshow(uint8(cover(:,:,3)))
% figure(3)
% imshow(uint8(cip))
% % figure(31)
% % imshow(uint8(cip(:,:,1)))
% % figure(32)
% % imshow(uint8(cip(:,:,2)))
% % figure(33)
% % imshow(uint8(cip(:,:,3)))
% figure(4)
% imshow(uint8(rim))
% figure(5)
% imshow(uint8(nc))
% 
% % imwrite(uint8(im),'cip/im.bmp')
% % imwrite(uint8(cover),'cip/cover.bmp')
% % imwrite(uint8(nc),'cip/tc.bmp')
% % imwrite(uint8(cip),'cip/cip.bmp')
% % imwrite(uint8(rim),'cip/rim.bmp')
% % imwrite(uint8(50*(cip-cover)),'cip/d1.bmp')
% % imwrite(uint8(50*(rim-im)),'cip/d2.bmp')
% 
% 
% [psnr_cip, ~] = psnr(double(cover),double(uint8(cip)),255)
% [ssim_cip, ~] = ssim(uint8(cover),uint8(cip))
% [ NP_cip ] = NPCR( cover,cip )
% [ UA_cip ] = UACI( cover,cip,255 )
% 
% [psnr_rim, ~] = psnr(double(im),double(uint8(rim)),255)
% [ssim_rim, ~] = ssim(uint8(im),uint8(rim))
% 
% niqe_co = niqe(uint8(cover))
% niqe_cip = niqe(uint8(cip))
% brisque_co = brisque(uint8(cover))
% brisque_cip = brisque(uint8(cip))


%% 三个数据集量化

% % plain_file = 'D:\date\ccia_CVG_image\color_image_512/';
% % fileExt = '*.ppm';  %待读取图像的后缀名
% 
% % plain_file = 'D:/date/BSDS100/';
% % fileExt = '*.png';  %待读取图像的后缀名
% 
% plain_file = 'D:\date\DIV2K\DIV2K_valid_HR/';
% fileExt = '*.png';  %待读取图像的后缀名
% 
% plain_files = dir(fullfile(plain_file,fileExt)); 
% plain_len = size(plain_files,1);
% 
% psnr11=ones(plain_len,2);
% ssim11=ones(plain_len,2);
% ncc11=ones(plain_len,2);
% 
% key='8d5ab8ba5340fce4420829ad5d12a0e45dacb0858544163d04c1d02b73e3697d';
% def1=[1,3,3,5,3,5,5,9,3,5,5,8];
% def2=[1,3,3,4,3,5,5,10,4,5,5,9];
% MC = 20;
% img_size = 1024;
% img_size_half = img_size/2;
% 
% for i=1:plain_len
%     i
%     tim = double(imread(strcat(plain_file,plain_files(i).name)));
%     [m,n,k]=size(tim);
%     if m>img_size && n>img_size
%         im = tim(floor(m/2)-img_size_half:floor(m/2)+img_size_half-1,floor(n/2)-img_size_half:floor(n/2)+img_size_half-1,:);
%     elseif m<img_size && n>img_size
%         im = tim(:,floor(n/2)-img_size_half:floor(n/2)+img_size_half-1,:);
%         im = double(imresize_rgb(uint8(im),[img_size,img_size,3]));
%     elseif m>img_size && n<img_size
%         im = tim(floor(m/2)-img_size_half:floor(m/2)+img_size_half-1,:,:);
%         im = double(imresize_rgb(uint8(im),[img_size,img_size,3]));
%     else
%         im = double(imresize_rgb(uint8(tim),[img_size,img_size,3]));
%     end
%     
%     if i==plain_len
%         tcover = double(imread(strcat(plain_file,plain_files(1).name)));
%     else
%         tcover = double(imread(strcat(plain_file,plain_files(i+1).name)));
%     end
%     [m,n,k]=size(tcover);
%     if m>img_size && n>img_size
%         cover = tcover(floor(m/2)-img_size_half:floor(m/2)+img_size_half-1,floor(n/2)-img_size_half:floor(n/2)+img_size_half-1,:);
%     elseif m<img_size && n>img_size
%         cover = tcover(:,floor(n/2)-img_size_half:floor(n/2)+img_size_half-1,:);
%         cover = double(imresize_rgb(uint8(cover),[img_size,img_size,3]));
%     elseif m>img_size && n<img_size
%         cover = tcover(floor(m/2)-img_size_half:floor(m/2)+img_size_half-1,:,:);
%         cover = double(imresize_rgb(uint8(cover),[img_size,img_size,3]));
%     else
%         cover = double(imresize_rgb(uint8(tcover),[img_size,img_size,3]));
%     end
%     
%     
% %     [ cip1,dnkey1,ext_val1,tc1 ] = encryption( im,cover,key,def1 );
% %     [ cip2,dnkey2,ext_val2,TT2,tc2 ] = encryption2( im,cover,key,def2,MC );
% %     [ cip2,dnkey2,ext_val2,TT2,tc2 ] = encryption22( im,cover,key,def2,[18,18,25] );
%     [ cip2,dnkey2,ext_val2,TT2,sort2,tc2 ] = encryption22( im,cover,key,def2,[20,20,20] );
%     
% %     imwrite(uint8(cover),strcat(strcat('date256/',num2str(i)),'.bmp'))
% %     imwrite(uint8(cip1),strcat(strcat('cip1_256/',num2str(i)),'.bmp'))
% %     imwrite(uint8(cip2),strcat(strcat('cip2_256/',num2str(i)),'.bmp'))
% 
% %     psnr1 = psnr(double(uint8(cip1)),cover,255);
% %     ssim1 = ssim(uint8(cip1),uint8(cover));
% %     ncc1 = NCC(uint8(cip1),uint8(cover));
% %     psnr11(i,1) = psnr1;
% %     ssim11(i,1) = ssim1;
% %     ncc11(i,1) = ncc1;
%     
%     psnr1 = psnr(double(uint8(cip2)),cover,255);
%     ssim1 = ssim(uint8(cip2),uint8(cover));
%     ncc1 = NCC(uint8(cip2),uint8(cover));
%     psnr11(i,2) = psnr1;
%     ssim11(i,2) = ssim1;
%     ncc11(i,2) = ncc1;
%     
% end
% 
% psnr2 = mean(psnr11,1);
% ssim2 = mean(ssim11,1);
% ncc2 = mean(ncc11,1);
 

%% 统计分析
% 
im = double(imread('E:\date\ccia_CVG_image\color_image_512/toucan.ppm'));
cover = double(imread('E:\date\ccia_CVG_image\color_image_512/portofino.ppm'));
key = '8d5ab8ba5340fce4420829ad5d12a0e45dacb0858544163d04c1d02b73e3697d';

[m,n,k]=size(im);
[M,N,K]=size(cover);

[ cip,dnkey,ext_val,sort_hist,tcip] = encryption( im,cover,key );
[ rim ] = dencryption( cip,cover,dnkey,ext_val,sort_hist, [m,n,k] );

im = uint8(im);cover=uint8(cover);tcip=uint8(tcip);cip=uint8(cip);rim=uint8(rim);


figure(1)
imshow(uint8(im))
figure(2)
imshow(uint8(cover))
figure(3)
imshow(uint8(tcip))
figure(4)
imshow(uint8(cip))
figure(5)
imshow(uint8(rim))
% 直方图
H_IM = plothist( im,11 );
H_CO = plothist( cover,12 );
H_NC = plothist( tcip,13 );
H_C = plothist( cip,14 );
% 相邻像素相关性
[ch_im,cv_im,cd_im]=plotcoor( im,21 );
[ch_co,cv_co,cd_co]=plotcoor( cover,22 );
[ch_nc,cv_nc,cd_nc]=plotcoor( tcip,23 );
[ch_c,cv_c,cd_c]=plotcoor( cip,24 );
% 三通道相关性
[crg_im, crb_im, cgb_im]=plotchcoor( im,31 );
[crg_co, crb_co, cgb_co]=plotchcoor( cover,32 );
[crg_nc, crb_nc, cgb_nc]=plotchcoor( tcip,33 );
[crg_c, crb_c, cgb_c]=plotchcoor( cip,34 );


%% 密钥敏感性
% im = double(imread('E:\date\ccia_CVG_image\color_image_512/toucan.ppm'));
% cover = double(imread('E:\date\ccia_CVG_image\color_image_512/portofino.ppm'));
% key = '8d5ab8ba5340fce4420829ad5d12a0e45dacb0858544163d04c1d02b73e3697d';
% 
% [m,n,k]=size(im);
% [M,N,K]=size(cover);
% 
% [ cip,dnkey,ext_val,sort_hist,tcip] = encryption( im,cover,key );
% dnkey(11)=dnkey(11)+10^-14;
% [ rim ] = dencryption( cip,cover,dnkey,ext_val,sort_hist, [m,n,k] );
% 
% imwrite(uint8(im),'cip/im.bmp')
% imwrite(uint8(rim),'cip/rim11.bmp')
% 
% figure(1)
% imshow(uint8(im))
% figure(2)
% imshow(uint8(cover))
% figure(3)
% imshow(uint8(tcip))
% figure(4)
% imshow(uint8(cip))
% figure(5)
% imshow(uint8(rim))

%% 鲁棒性分析
% im = double(imread('E:\date\ccia_CVG_image\color_image_512/toucan.ppm'));
% cover = double(imread('E:\date\ccia_CVG_image\color_image_512/portofino.ppm'));
% key = '8d5ab8ba5340fce4420829ad5d12a0e45dacb0858544163d04c1d02b73e3697d';
% 
% [m,n,k]=size(im);
% [M,N,K]=size(cover);
% 
% [ cip,dnkey,ext_val,sort_hist,tcip] = encryption( im,cover,key );
% d0 = zeros(size(cip));
% [ rim ] = dencryption( cip,cover,dnkey,ext_val,sort_hist, [m,n,k] );

% % 椒盐噪声
% psnr_all = zeros(1, 11);
% ssim_all = zeros(1, 11);
% for i=0:10
%     noise_density = 0.0005 * 4*i;
%     cip1 = double(imnoise(uint8(cip),'salt & pepper',noise_density));
%     [rim1] = dencryption( cip1,cover,dnkey,ext_val,sort_hist, [m,n,k] );
%     psnr_all(i+1) = psnr(double(uint8(im)),double(uint8(rim1)),255);
%     ssim_all(i+1) = ssim(double(uint8(im)),double(uint8(rim1)));
%     
%     save_rim1_path = sprintf('lu/sp/rim1_noise_%d.png', i);
%     imwrite(uint8(rim1), save_rim1_path);
%     save_cip1_path = sprintf('lu/sp/cip1_noise_%d.png', i);
%     imwrite(uint8(cip1), save_cip1_path);
% end
% 
% xlable = (0:10)*0.0005*4;
% figure('Position', [100, 100, 600, 400]);
% 
% yyaxis left
% h1 = plot(xlable, psnr_all, '-o', 'LineWidth', 2, 'MarkerSize', 6, ...
%      'MarkerFaceColor', 'b', 'Color', [0, 0.4470, 0.7410]);
% ylabel('PSNR (dB)', 'FontSize', 14, 'FontName', 'Times New Roman');
% xlabel('S&P noise density', 'FontSize', 14, 'FontName', 'Times New Roman');
% ylim([min(psnr_all)-5, max(psnr_all)+5]);
% set(gca, 'YColor', [0, 0.4470, 0.7410]);
% 
% % 右Y轴 - SSIM
% yyaxis right
% h2 = plot(xlable, ssim_all, '-s', 'LineWidth', 2, 'MarkerSize', 6, ...
%      'MarkerFaceColor', 'r', 'Color', [0.8500, 0.3250, 0.0980]);
% ylabel('SSIM', 'FontSize', 14, 'FontName', 'Times New Roman');
% ylim([min(ssim_all)-0.05, max(ssim_all)+0.05]);
% set(gca, 'YColor', [0.8500, 0.3250, 0.0980]);
% 
% % 设置坐标轴字体
% set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
% 
% % 添加网格和图例
% legend([h1, h2], {'PSNR', 'SSIM'}, 'Location', 'best', 'FontSize', 12, 'FontName', 'Times New Roman');

% % 高斯噪声
% psnr_all = zeros(1, 11);
% ssim_all = zeros(1, 11);
% xlable = zeros(1, 11);
% for i=0:10
%     if i > 0
%         noise_var = 0.00000003 * 4*i+0.0000001;
%     else
%         noise_var = 0;
%     end
% 
%     xlable(i+1) = noise_var;
%     cip1 = double(imnoise(uint8(cip),'gaussian', 0, noise_var));
%     [rim1] = dencryption( cip1,cover,dnkey,ext_val,sort_hist, [m,n,k] );
%     psnr_all(i+1) = psnr(double(uint8(im)),double(uint8(rim1)),255);
%     ssim_all(i+1) = ssim(double(uint8(im)),double(uint8(rim1)));
%     
%     save_rim1_path = sprintf('lu/gs/rim1_noise_%d.png', i);
%     imwrite(uint8(rim1), save_rim1_path);
%     save_cip1_path = sprintf('lu/gs/cip1_noise_%d.png', i);
%     imwrite(uint8(cip1), save_cip1_path);
% end
% 
% 
% figure('Position', [100, 100, 600, 400]);
% yyaxis left
% h1 = plot(xlable, psnr_all, '-o', 'LineWidth', 2, 'MarkerSize', 6, ...
%      'MarkerFaceColor', 'b', 'Color', [0, 0.4470, 0.7410]);
% ylabel('PSNR (dB)', 'FontSize', 14, 'FontName', 'Times New Roman');
% xlabel('Gaussian noise variance', 'FontSize', 14, 'FontName', 'Times New Roman');
% xlim([0, xlable(11)]);
% ylim([min(psnr_all)-5, max(psnr_all)+5]);
% set(gca, 'YColor', [0, 0.4470, 0.7410]);
% 
% % 右Y轴 - SSIM
% yyaxis right
% h2 = plot(xlable, ssim_all, '-s', 'LineWidth', 2, 'MarkerSize', 6, ...
%      'MarkerFaceColor', 'r', 'Color', [0.8500, 0.3250, 0.0980]);
% ylabel('SSIM', 'FontSize', 14, 'FontName', 'Times New Roman');
% xlim([0, xlable(11)]);
% ylim([min(ssim_all)-0.05, max(ssim_all)+0.05]);
% set(gca, 'YColor', [0.8500, 0.3250, 0.0980]);
% 
% % 设置坐标轴字体
% set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
% 
% % 添加网格和图例
% legend([h1, h2], {'PSNR', 'SSIM'}, 'Location', 'best', 'FontSize', 12, 'FontName', 'Times New Roman');


% 剪切
% psnr_all = zeros(1, 11);
% ssim_all = zeros(1, 11);
% for i=0:10
%     cut_size = uint16(8 * i);
%     cip1 = cip;
%     if cut_size~=0
%         cip1(1:cut_size,1:cut_size,:)=0;
%     end
%     [rim1] = dencryption( cip1,cover,dnkey,ext_val,sort_hist, [m,n,k] );
%     psnr_all(i+1) = psnr(double(uint8(im)),double(uint8(rim1)),255);
%     ssim_all(i+1) = ssim(double(uint8(im)),double(uint8(rim1)));
%     
%     save_rim1_path = sprintf('lu/cut/rim1_noise_%d.png', i);
%     imwrite(uint8(rim1), save_rim1_path);
%     save_cip1_path = sprintf('lu/cut/cip1_noise_%d.png', i);
%     imwrite(uint8(cip1), save_cip1_path);
% end
% 
% xlable = (0:10)*8;
% figure('Position', [100, 100, 550, 400]);
% 
% yyaxis left
% h1 = plot(xlable, psnr_all, '-o', 'LineWidth', 2, 'MarkerSize', 6, ...
%      'MarkerFaceColor', 'b', 'Color', [0, 0.4470, 0.7410]);
% ylabel('PSNR (dB)', 'FontSize', 14, 'FontName', 'Times New Roman');
% xlabel('Cut size', 'FontSize', 14, 'FontName', 'Times New Roman');
% ylim([min(psnr_all)-5, max(psnr_all)+5]);
% set(gca, 'YColor', [0, 0.4470, 0.7410]);
% 
% % 右Y轴 - SSIM
% yyaxis right
% h2 = plot(xlable, ssim_all, '-s', 'LineWidth', 2, 'MarkerSize', 6, ...
%      'MarkerFaceColor', 'r', 'Color', [0.8500, 0.3250, 0.0980]);
% ylabel('SSIM', 'FontSize', 14, 'FontName', 'Times New Roman');
% ylim([min(ssim_all)-0.05, max(ssim_all)+0.05]);
% set(gca, 'YColor', [0.8500, 0.3250, 0.0980]);
% 
% % 设置坐标轴字体
% set(gca, 'FontSize', 14, 'FontName', 'Times New Roman');
% 
% % 添加网格和图例
% legend([h1, h2], {'PSNR', 'SSIM'}, 'Location', 'best', 'FontSize', 12, 'FontName', 'Times New Roman');
% 
% 

% figure(11)
% imshow(uint8(im))
% figure(12)
% imshow(uint8(cover))
% figure(13)
% imshow(uint8(tcip))
% figure(14)
% imshow(uint8(cip))
% figure(15)
% imshow(uint8(rim))
% figure(16)
% imshow(uint8(cip1))
% figure(61)
% imshow(uint8(d1))
% figure(71)
% imshow(uint8(cip2))
% figure(71)
% imshow(uint8(d2))
% figure(18)
% imshow(uint8(rim1))
% figure(19)
% imshow(uint8(rim2))

%% 差分攻击
% im = double(imread('E:\date\ccia_CVG_image\color_image_512/toucan.ppm'));
% cover = double(imread('E:\date\ccia_CVG_image\color_image_512/portofino.ppm'));
% key = '8d5ab8ba5340fce4420829ad5d12a0e45dacb0858544163d04c1d02b73e3697d';
% 
% [m,n,k]=size(im);
% [M,N,K]=size(cover);
% 
% im1 = im;
% im1(1,1,1)=mod(im1(1,1,1)+1,256);
% im2 = im;
% im2(512,512,1)=im(1,1,1);im2(1,1,1)=im(512,512,1);
% im3 = im;
% 
% [ cip,dnkey,ext_val,sort_hist,tcip] = encryption( im,cover,key );
% [ cip1,dnkey1,ext_val1,sort_hist1,tcip1] = encryption( im1,cover,key );
% [ cip2,dnkey2,ext_val2,sort_hist2,tcip2] = encryption( im2,cover,key );
% [ cip3,dnkey3,ext_val3,sort_hist3,tcip3] = encryption( im3,cover,key );
% [ rim ] = dencryption( cip,cover,dnkey,ext_val,sort_hist, [m,n,k] );
% 
% [ssim_tcip1,~] = ssim(uint8(tcip1),uint8(tcip));
% [ssim_tcip2,~] = ssim(uint8(tcip2),uint8(tcip));
% [ssim_tcip3,~] = ssim(uint8(tcip3),uint8(tcip));
% 
% [ NP_tcip1 ] = NPCR( tcip1,tcip );
% [ NP_tcip2 ] = NPCR( tcip2,tcip );
% [ NP_tcip3 ] = NPCR( tcip3,tcip );
% 
% [ UA_tcip1 ] = UACI( tcip1,tcip,255 );
% [ UA_tcip2 ] = UACI( tcip2,tcip,255 );
% [ UA_tcip3 ] = UACI( tcip3,tcip,255 );
%  
% [mssim_cip1,~] = ssim(uint8(cip1),uint8(cip));
% [mssim_cip2,~] = ssim(uint8(cip2),uint8(cip));
% [mssim_cip3,~] = ssim(uint8(cip3),uint8(cip));
% 
% [ NP_cip1 ] = NPCR( cip1,cip );
% [ NP_cip2 ] = NPCR( cip2,cip );
% [ NP_cip3 ] = NPCR( cip3,cip );
% 
% [ UA_cip1 ] = UACI( cip1,cip,255 );
% [ UA_cip2 ] = UACI( cip2,cip,255 );
% [ UA_cip3 ] = UACI( cip3,cip,255 );
% 
% [ rim1 ] = dencryption( cip,cover,dnkey1,ext_val,sort_hist, [m,n,k] );
% [ rim2 ] = dencryption( cip,cover,dnkey2,ext_val,sort_hist, [m,n,k] );
% [ rim3 ] = dencryption( cip,cover,dnkey3,ext_val,sort_hist, [m,n,k] );
% 
% imwrite(uint8(im1),'cip/im1.bmp')
% imwrite(uint8(im2),'cip/im2.bmp')
% imwrite(uint8(im3),'cip/im3.bmp')
% imwrite(uint8(rim1),'cip/rim1.bmp')
% imwrite(uint8(rim2),'cip/rim2.bmp')
% imwrite(uint8(rim3),'cip/rim3.bmp')
% 
% figure(1)
% imshow(uint8(im))
% figure(2)
% imshow(uint8(cover))
% figure(3)
% imshow(uint8(tcip))
% figure(4)
% imshow(uint8(cip))
% figure(5)
% imshow(uint8(rim))
% figure(6)
% imshow(uint8(rim1))
