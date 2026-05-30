function [ cip,dnkey,ext_val,sort_hist,T2 ] = encryption( im,cover,key )
% 三通道分别压缩，合并一起，置乱，有意义密文嵌入
% key='8d5ab8ba5340fce4420829ad5d12a0e45dacb0858544163d04c1d02b73e3697d';

[m,n,k]=size(im);
[M,N,K]=size(cover);
% 密钥生成
[ dnkey ] = dkey( im,key );
a1 = dnkey(1);b1=dnkey(2);x01=dnkey(3);y01=dnkey(4);
a2 = dnkey(5);b2=dnkey(6);x02=dnkey(7);y02=dnkey(8);
a3 = dnkey(9);b3=dnkey(10);x03=dnkey(11);y03=dnkey(12);

% 阶梯式压缩
[ x1,y1 ] = CICCM_2D( [x01,y01],[a1,b1], m*n*1.5 );
[ T1,ext_val ] = comp_3d( im,x1,y1 );

% 直方图重组
[ T1,sort_hist ] = hre( T1 );

% bit置乱
[ x2,y2 ] = CICCM_2D( [x02,y02],[a2,b2], 2*m+n*k );
[T2] = bit_scram( uint8(T1),x2,y2 );

% 嵌入
[ x3,y3 ] = CICCM_2D( [x03,y03],[a3,b3], M+N*K );
[ cip ] = embed( T2,cover,x3,y3 );


end


function [ dnkey ] = dkey( p,key )
%   DKEY 动态密钥生成
%   p明文，key动态密钥 

x = ones(1,256);
sha_sum = 0;
time = clock;
sha_time = SHA(time,'SHA-256');
sha_p = SHA(p,'SHA-256');
for i=1:32  % hex2dec只能到2^52，所以运用循环每8位来一次，也可以其他位数
    tem = ones(1,8);
    tem2 = ones(1,8);
    sn = dec2bin(hex2dec(sha_p((i-1)*2+1:(i-1)*2+2)),8);
    tn = dec2bin(hex2dec(sha_time((i-1)*2+1:(i-1)*2+2)),8);
    kn = dec2bin(hex2dec(key((i-1)*2+1:(i-1)*2+2)),8);
    tem(sn==kn) = 0;
    tem2(char(tem+'0')==tn) = 0;
    x((i-1)*8+1:(i-1)*8+8) = tem2;
    sha_sum = sha_sum + bin2dec(num2str(tem2));
end

a1=0;b1=0;x01=0;y01=0;
a2=0;b2=0;x02=0;y02=0;
a3=0;b3=0;x03=0;y03=0;
for i = 1:16
    a1=a1+x(i)*2^(-i);
    b1=b1+x(i+16)*2^(-i);
    x01=x01+x(i+32)*2^(-i);
    y01=y01+x(i+48)*2^(-i);
    
    a2=a2+x(i+64)*2^(-i);
    b2=b2+x(i+80)*2^(-i);
    x02=x02+x(i+96)*2^(-i);
    y02=y02+x(i+112)*2^(-i);
    
    a3=a3+x(i+128)*2^(-i);
    b3=b3+x(i+160)*2^(-i);
    x03=x03+x(i+176)*2^(-i);
    y03=y03+x(i+192)*2^(-i);
end

a1=mod(a1*sha_sum,11);b1=mod(b1*sha_sum,11);x01=x01*sha_sum/8192;y01=y01*sha_sum/8192;
a2=mod(a2*sha_sum,11);b2=mod(b2*sha_sum,11);x02=x02*sha_sum/8192;y02=y02*sha_sum/8192;
a3=mod(a3*sha_sum,11);b3=mod(b3*sha_sum,11);x03=x03*sha_sum/8192;y03=y03*sha_sum/8192;
dnkey = [a1,b1,x01,y01,a2,b2,x02,y02,a3,b3,x03,y03];

end
function h = SHA(inp,meth)
% HASH - Convert an input variable into a message digest using any of
%        several common hash algorithms
%
% USAGE: h = hash(inp,'meth')
%
% inp  = input variable, of any of the following classes:
%        char, uint8, logical, double, single, int8, uint8,
%        int16, uint16, int32, uint32, int64, uint64
% h    = hash digest output, in hexadecimal notation
% meth = hash algorithm, which is one of the following:
%        MD2, MD5, SHA-1, SHA-256, SHA-384, or SHA-512
%
% NOTES: (1) If the input is a string or uint8 variable, it is hashed
%            as usual for a byte stream. Other classes are converted into
%            their byte-stream values. In other words, the hash of the
%            following will be identical:
%                     'abc'
%                     uint8('abc')
%                     char([97 98 99])
%            The hash of the follwing will be different from the above,
%            because class "double" uses eight byte elements:
%                     double('abc')
%                     [97 98 99]
%            You can avoid this issue by making sure that your inputs
%            are strings or uint8 arrays.
%        (2) The name of the hash algorithm may be specified in lowercase
%            and/or without the hyphen, if desired. For example,
%            h=hash('my text to hash','sha256');
%        (3) Carefully tested, but no warranty. Use at your own risk.
%        (4) Michael Kleder, Nov 2005
%
% EXAMPLE:
%
% algs={'MD2','MD5','SHA-1','SHA-256','SHA-384','SHA-512'};
% for n=1:6
%     h=hash('my sample text',algs{n});
%     disp([algs{n} ' (' num2str(length(h)*4) ' bits):'])
%     disp(h)
% end

inp=inp(:);
% convert strings and logicals into uint8 format
if ischar(inp) || islogical(inp)
    inp=uint8(inp);
else % convert everything else into uint8 format without loss of data
    inp=typecast(inp,'uint8');
end

% verify hash method, with some syntactical forgiveness:
meth=upper(meth);
switch meth
    case 'SHA1'
        meth='SHA-1';
    case 'SHA256'
        meth='SHA-256';
    case 'SHA384'
        meth='SHA-384';
    case 'SHA512'
        meth='SHA-512';
    otherwise
end
algs={'MD2','MD5','SHA-1','SHA-256','SHA-384','SHA-512'};
if isempty(strcmp(algs,meth))
    error(['Hash algorithm must be ' ...
        'MD2, MD5, SHA-1, SHA-256, SHA-384, or SHA-512']);
end

% create hash
x=java.security.MessageDigest.getInstance(meth);
x.update(inp);
h=typecast(x.digest,'uint8');
h=dec2hex(h)';
if(size(h,1))==1 % remote possibility: all hash bytes  128, so pad:
    h=[repmat('0',[1 size(h,2)]);h];
end
h=lower(h(:)');

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


function [ T1,AA ] = comp_3d( im,R1,R2 )

% 压缩率为 0.25

[m,n,k]=size(im);
% a1=ceil(0.7*m);b1=ceil(0.7*n);  % 359
% a2=ceil(0.4*m);b2=ceil(0.4*n);  % 205
% a3=ceil(0.3*m);b3=ceil(0.3*n);  % 154

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

% 压缩
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

dct_im = dct_3d( im );
T1_r = fai11*dct_im(:,:,1)*fai21';
T1_g = fai12*dct_im(:,:,2)*fai22';
T1_b = fai13*dct_im(:,:,3)*fai23';

max_cip_r = max(max(T1_r));
min_cip_r = min(min(T1_r));
cip_r = round( (T1_r-min_cip_r)/(max_cip_r-min_cip_r) * 255);
max_cip_g = max(max(T1_g));
min_cip_g = min(min(T1_g));
cip_g = round((T1_g-min_cip_g)/(max_cip_g-min_cip_g) * 255);
max_cip_b = max(max(T1_b));
min_cip_b = min(min(T1_b));
cip_b = round((T1_b-min_cip_b)/(max_cip_b-min_cip_b) * 255);

% 这时候直方图移位呢，三个移位参数模式

T1 = 127*ones([0.5*m,0.5*n,k]);
T1(1:a1*b1)=cip_r; T1(a1*b1+1:a1*b1+a2*b2)=cip_g; T1(a1*b1+a2*b2+1:a1*b1+a2*b2+a3*b3)=cip_b;
T1(isnan(T1))=0;
AA = [max_cip_r,min_cip_r,max_cip_g,min_cip_g,max_cip_b,min_cip_b];

end
function [ tem ] = dct_3d( im )

[m,~,k]=size(im);
tem=im;

for i=1:m
    tem(i,:,:)=dct(squeeze(im(i,:,:)).').';
end

for i=1:k
    tem(:,:,i)=dct(dct(tem(:,:,i)).').';
end

end

function [ cip ] = bit_scram( im,r1,r2 )
%   SCRAM 乱序循环移位
%   此处显示详细说明

[m,n,k]=size(im);
bin_T2 = dec2bin(im,8) - '0';
bin_T2 = reshape(bin_T2,[4*m,2*k*n]);
bin_T2 = scram( bin_T2,r1,r2 );
bin_T2 = reshape(bin_T2,[3*m*n,8]);
T2 = bin2dec(char(bin_T2 + '0'));
cip = reshape(T2,[m,n,k]);

% 是分布均匀的，置乱以后值比较集中，相关性比较高
% bin_T21 = bin_T2;
% r = rand(m*n*k*8,1);
% bin_T21 = scrambling( bin_T21,r );
% T21 = bin2dec(char(bin_T21 + '0'));
% cip1 = reshape(T21,[m,n,k]);

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

% cip=circshift(cip,[0,v1]); 
% cip=circshift(cip,[v2,0]); 

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

function [ cip,sort_hist ] = hre( im )
%   直方图重组
%   此处显示详细说明

[hist,~] = imhist(uint8(im));
[~,sort_hist] = sort(hist, 'descend'); % 降序
sort_hist = sort_hist-1;
list = 0:255;
bin_list = dec2bin(list,8) - '0';
sum_bin = sum(bin_list,2);
[~, sort_sum] = sort(sum_bin, 'ascend'); % 升序
sort_sum = sort_sum-1; %%%%%%%%%%
cip = im;
for i=1:256
    cip(im==sort_hist(i))=sort_sum(i);
end

end

function [ cip ] = embed( im,cover,r1,r2 )
%   embed 自己的嵌入操作(空间域)
%   此处显示详细说明

% 前期准备
[m, n, k] = size(cover);
[m1,n1,k1] = size(im);
im = reshape(im,[m1,n1*k1]);

% figure(114)
% imshow(uint8(im))

% 封面置乱
cover = reshape(cover,[m,n*k]);
cover = scram( cover,r1,r2 );

% figure(111)
% imshow(uint8(cover))

% 类噪声密文分解
CA11 = floor(im/64);
CH11 = floor(mod(im,64)/16);
CV11 = floor(mod(im,16)/4);
CD11 = mod(im,4);
sp_im = [CA11,CH11;CV11,CD11];
% 
% figure(115)
% imshow(uint8(CA11))
% figure(116)
% imshow(uint8(CH11))
% figure(117)
% imshow(uint8(CV11))
% figure(118)
% imshow(uint8(CD11))

% 嵌入值调整
sp_im = evd(sp_im);

% figure(112)
% imshow(uint8(sp_im))

% 嵌入
cip = cover;
cip(1:2*m1,1:2*n1*k1) = mod(sp_im + mod(cover(1:2*m1,1:2*n1*k1),4), 4) + floor(cover(1:2*m1,1:2*n1*k1)/4)*4;

% 修正
cip = correction(cover,cip,4,1);

% figure(113)
% imshow(uint8(cip))

% 反向置乱
cip = dscram( cip,r1,r2 );
cip = reshape(cip,[m,n,k]);

end
function [ cip ] = evd( im )
%   SCRAM 乱序循环移位
%   此处显示详细说明

cip = im;
cip(im==3)=2;
cip(im==2)=3;

end
function [ cip2 ] = correction( cover,cip,e,t )
%   CORRECTION 修正
%   此处显示详细说明

tem = cip-cover;
cip2 = cip;
cip2(tem < -e/2) = cip(tem < -e/2) + e;
cip2(tem > e/2) = cip(tem > e/2) - e;

if t==1
    % 整数嵌入需要注意不要超范围(空域才需要)
    cip2(cip2 < 0) = cip(cip2 < 0);
    cip2(cip2 > 255) = cip(cip2 > 255);
end

end





