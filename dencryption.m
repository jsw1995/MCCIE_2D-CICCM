function [ rim ] = dencryption( cip,cover,dnkey,ext_val,sort_hist, im_shape )
% 三通道分别压缩，合并一起，置乱，有意义密文嵌入
% 使用第一种嵌入方式


m = im_shape(1);n=im_shape(2);k=im_shape(3);
[M,N,K]=size(cip);
% 密钥生成
a1 = dnkey(1);b1=dnkey(2);x01=dnkey(3);y01=dnkey(4);
a2 = dnkey(5);b2=dnkey(6);x02=dnkey(7);y02=dnkey(8);
a3 = dnkey(9);b3=dnkey(10);x03=dnkey(11);y03=dnkey(12);

% 提取
[ x3,y3 ] = CICCM_2D( [x03,y03],[a3,b3], M+N*K );
[ rT2 ] = extract( cip,cover,x3,y3,[m/2,n/2,k] );


% 反向bit置乱
[ x2,y2 ] = CICCM_2D( [x02,y02],[a2,b2], 2*m+n*k );
rT1 = bit_dscram( uint8(rT2),x2,y2 );

% 直方图重组
[ rT1 ] = rhre( rT1, sort_hist );

% 重构
[ x1,y1 ] = CICCM_2D( [x01,y01],[a1,b1], m*n*1.5 );
[ rim ] = recon( rT1,ext_val,x1,y1,[m,n,k] );

end


function [ x,y ] = CICCM_2D( init,para,L )
%   IICM 
%   此处显示详细说明

x = []; y= [];
x(1)=init(1);y(1)=init(2);
a=para(1);b=para(2);
a=a^pi;b=b^exp(1);

for i=1:L+1000
    x(i+1)=mod(a/x(i) * sin(b/y(i)),1);
    y(i+1)=mod(a/y(i) * sin(b/x(i)),1);
end

x=x(1001:L+1000);
y=y(1001:L+1000);

end


function [ rim ] = extract( cip,cover,r1,r2,im_shape )
%   EXTRACT 自己的嵌入操作(空域)
%   此处显示详细说明


% 前期准备
[m, n, k] = size(cover);
m1=im_shape(1); n1=im_shape(2);k1=im_shape(3);

% 封面和密文置乱
cover = reshape(cover,[m,n*k]);
cover = scram( cover,r1,r2 );
cip = reshape(cip,[m,n*k]);
cip = scram( cip,r1,r2 );

% 提取
rim = mod(mod(cip(1:2*m1,1:2*n1*k1),4) - mod(cover(1:2*m1,1:2*n1*k1),4), 4);

% 嵌入值调整
rim = evd(rim);

CA = rim(1:m1,1:n1*k1);
CH = rim(1:m1,n1*k1+1:2*n1*k1);
CV = rim(m1+1:2*m1,1:n1*k1);
CD = rim(m1+1:2*m1,n1*k1+1:2*n1*k1);

rim = CA*64 + CH*16 + CV*4 + CD;
rim = reshape(rim,[int16(m1),int16(n1),k1]);

end
function [ cip ] = evd( im )
%   SCRAM 乱序循环移位
%   此处显示详细说明

cip = im;
cip(im==3)=2;
cip(im==2)=3;

end

function [ rim ] = bit_dscram( cip,r1,r2 )
%   SCRAM 乱序循环移位
%   此处显示详细说明

[m,n,k]=size(cip);
bin_T2 = dec2bin(cip,8) - '0';
bin_T2 = reshape(bin_T2,[4*m,2*k*n]);
bin_T2 = dscram( bin_T2,r1,r2 );
bin_T2 = reshape(bin_T2,[3*m*n,8]);
T2 = bin2dec(char(bin_T2 + '0'));
rim = reshape(T2,[m,n,k]);

end

function [ rim ] = rhre( cip, sort_hist )
%   直方图重组
%   此处显示详细说明

list = 0:255;
bin_list = dec2bin(list,8) - '0';
sum_bin = sum(bin_list,2);
[~, sort_sum] = sort(sum_bin, 'ascend'); % 升序
sort_sum = sort_sum-1; %%%%%%%%%%%%%%%
rim = cip;
for i=1:256
    rim(cip==sort_sum(i))=sort_hist(i);
end

end

function [ cip ] = scram( im,r1,r2 )
%   SCRAM 乱序循环移位
%   此处显示详细说明

[m,n]=size(im);
cip = im;
v1 = floor(mod(r1(1:m)*10^10,n));
v2 = floor(mod(r2(1:n)*10^10,m));

for i=1:m
    cip(i,:)=circshift(cip(i,:),[0,v1(i)]); 
end

for i=1:n
    cip(:,i)=circshift(cip(:,i),[v2(i),0]);
end

end
function [ rim ] = dscram( cip,r1,r2 )
%   DSCRAM 解密
%   此处显示详细说明

[m,n]=size(cip);
rim = cip;

v1 = -floor(mod(r1(1:m)*10^10,n));
v2 = -floor(mod(r2(1:n)*10^10,m));

for i=1:n
    rim(:,i)=circshift(rim(:,i),[v2(i),0]);
end

for i=1:m
    rim(i,:)=circshift(rim(i,:),[0,v1(i)]); 
end

end


function [ rim ] = recon( T1,AA,R1,R2,im_shape )

% 压缩率为 0.25
m=im_shape(1);n=im_shape(2);k=im_shape(3);
% a1=ceil(0.7*m);b1=ceil(0.7*n);
% a2=ceil(0.4*m);b2=ceil(0.4*n);
% a3=ceil(0.3*m);b3=ceil(0.3*n);

a1=floor(sqrt(0.48)*m);b1=floor(sqrt(0.48)*n);  % 358
a2=floor(sqrt(0.18)*m);b2=floor(sqrt(0.18)*m);  % 256
a3=floor(sqrt(0.09)*m);b3=floor(sqrt(0.09)*m);  % 153

R1= 1-2*mod(R1*10^4,1);R2=1-2*mod(R2*10^4,1);
x1 = reshape(R1(1:a1*m),[a1,m]);
y1 = reshape(R2(1:b1*n),[b1,n]);
x2 = reshape(R1(a1*m+1:a1*m+a2*m),[a2,m]);
y2 = reshape(R2(b1*n+1:b1*n+b2*n),[b2,n]);
x3 = reshape(R1(a1*m+a2*m+1:a1*m+a2*m+a3*m),[a3,m]);
y3 = reshape(R2(b1*n+b2*n+1:b1*n+b2*n+b3*n),[b3,n]);

T=1000;
% fai11 = sqrt(2/a1)*x1;
% fai21 = sqrt(2/b1)*y1;
fai11 = x1;
fai21 = y1;
fai11(:, 1:a1) =fai11(:, 1:a1) * T;
fai11 = orth(fai11')';
fai21(:, 1:b1) = fai21(:, 1:b1) * T;
fai21 = orth(fai21')';

% fai12 = sqrt(2/a2)*x2;
% fai22 = sqrt(2/b2)*y2;
fai12 = x2;
fai22 = y2;
fai12(:, 1:a2) =fai12(:, 1:a2) * T;
fai12 = orth(fai12')';
fai22(:, 1:b2) = fai22(:, 1:b2) * T;
fai22 = orth(fai22')';

% fai13 = sqrt(2/a3)*x3;
% fai23 = sqrt(2/b3)*y3;
fai13 = x3;
fai23 = y3;
fai13(:, 1:a3) =fai13(:, 1:a3) * T;
fai13 = orth(fai13')';
fai23(:, 1:b3) = fai23(:, 1:b3) * T;
fai23 = orth(fai23')';

max_cip_r = AA(1);min_cip_r = AA(2);
cip_r = reshape(T1(1:a1*b1),[a1,b1]);
cip_r = cip_r / 255 * (max_cip_r-min_cip_r) + min_cip_r;
max_cip_g = AA(3);min_cip_g = AA(4);
cip_g = reshape(T1(a1*b1+1:a1*b1+a2*b2),[a2,b2]);
cip_g = cip_g / 255 * (max_cip_g-min_cip_g) + min_cip_g;
max_cip_b = AA(5);min_cip_b = AA(6);
cip_b = reshape(T1(a1*b1+a2*b2+1:a1*b1+a2*b2+a3*b3),[a3,b3]);
cip_b = cip_b / 255 * (max_cip_b-min_cip_b) + min_cip_b;

[ rdct_imr ] = nsl0_2d( cip_r,fai11,fai21' );
[ rdct_img ] = nsl0_2d( cip_g,fai12,fai22' );
[ rdct_imb ] = nsl0_2d( cip_b,fai13,fai23' );

rdct = cat(3,rdct_imr,rdct_img,rdct_imb);
rim = idct_3d( rdct );
rim(rim>255) = 255;
rim(rim<0) = 0;

end
function [ rim ] = nsl0_2d( y,A,B )
%   NSL0_2D 此处显示有关此函数的摘要
%   此处显示详细说明

sigma_min = 0.01;
sigma_decrease_factor = 0.05;  %
ksai = 0.01;

A_pinv = pinv(A);
B_pinv = pinv(B);

s = A_pinv * y * B_pinv;

sigma = 4 * max(max(abs(s)));
r = 0;
r0 = y - A * s * B;

while (sigma>sigma_min)

    if sum(sum((r-r0).^2)) < ksai
        
        d = -(sigma^2 * s) ./ (s.*s + sigma^2);
        s = s + d;
        s = s - A_pinv * (A * s * B - y) * B_pinv;
        r0 = y - A * s * B;
        
    end

    sigma = sigma * sigma_decrease_factor;
 
end

rim = s;

end
function [ tem2 ] = idct_3d( im )
% IDCT3 此处显示有关此函数的摘要
%   此处显示详细说明

[m,~,k] = size(im);
tem2 = im;

for i=1:k
    tem2(:,:,i)=idct(idct(im(:,:,i)).').';
end

for i=1:m
    tem2(i,:,:)=idct(squeeze(tem2(i,:,:)).').';
end

end

function [ rim ] = extract2( cip,cover,im_shape )
%   EXTRACT 自己的嵌入操作(空域)
%   此处显示详细说明


% 前期准备
[m, n, k] = size(cover);
m1=im_shape(1); n1=im_shape(2);k1=im_shape(3);

% 封面和密文置乱
cover = reshape(cover,[m,n*k]);
cip = reshape(cip,[m,n*k]);

% 提取
rim = mod(mod(cip(1:2*m1,1:2*n1*k1),4) - mod(cover(1:2*m1,1:2*n1*k1),4), 4);

% 嵌入值调整
rim = evd(rim);

CA = rim(1:m1,1:n1*k1);
CH = rim(1:m1,n1*k1+1:2*n1*k1);
CV = rim(m1+1:2*m1,1:n1*k1);
CD = rim(m1+1:2*m1,n1*k1+1:2*n1*k1);

rim = CA*64 + CH*16 + CV*4 + CD;
rim = reshape(rim,[int16(m1),int16(n1),k1]);

end

