function [out, data_s, dataf,a] = ecg_1000(data);
% This peak detection algorithm is not made by HIP-lab, but the programmers
% credits are lost. We are sorry. If you made this algorithm, please let
% us know and we will credit you.

% out = index of R-spike

% Desing of a FIR filter to remove frequences over 30 Hz  

[n,f,m,w]=firpmord([30 50],[1 0],[0.01 0.001],1000);
n=128;
B_ecg=firpm(n,f,m,w);

% filtering the data 

data_s = conv(B_ecg,data);
data_s = data_s(65:end-64);

% filtering the data with meanfilter length of 55
f1 = ones(55,1)/55;
df = conv(f1,data_s);
df = df(28:end-27);

% dataf is the signal from which the spikes are detectetd

dataf = data_s - df;

% Calculation of the maximun value of dataf in moving window length of 501 
tmp1 = maxfilt(dataf,501);

% sections where dataf>tmp1*0.8
tmp2 = dataf>tmp1*0.8;
tmp3 = diff(tmp2);
k1 = find(tmp3==1);
k2 = find(tmp3==-1);
k1=k1(:);
k2=k2(:);
if k2(1)<k1(1);
    k2 = k2(2:end);
    k1 = k1(1:end-1);
end
if length(k2)<length(k1)
    k1=k1(1:length(k2));
elseif length(k2)>length(k1)
    k2=k2(1:length(k1));
end
K = [k1(2:end-1) k2(2:end-1)];

% the seeking of the max value (= R spike)

for j=1:length(K);
    [a(j),ind]=max(dataf(K(j,1)-30:K(j,2)+30));
    out(j)=ind + K(j,1) - 31;
end