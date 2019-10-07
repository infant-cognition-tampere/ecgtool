function [freq, X] = calcFFT(x, Fs)

N=length(x);
k=0:N-1;
T=N/Fs;
freq=k/T; %create the frequency range
X=fft(x)/N;

cutOff=ceil(N/2);
X=X(1:cutOff);
freq=freq(1:cutOff);