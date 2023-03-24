%% Message reading
[y,Fs] = audioread("Short_QuranPalestine.wav"); %Short_BBCArabic2.wav
[p,Fs2] = audioread("Short_BBCArabic2.wav");
m = (y(:,1)+y(:,2));    %converting the message to mono audio
m2 = (p(:,1)+p(:,2));
x=interp(m,10);         %message after increasing Fs
x2 = interp(m2,10);
Fs = 10*Fs;             
Fs2 = Fs;
N = 1048576;
k=-N/2:N/2-1;
X = fft(x,N);
X2 = fft(x2,N);
subplot(4,3,1)
plot(x);
xlabel('t');
ylabel('x(t)');
title('1st Message in Time Domain');
subplot(4,3,2)
plot(x2);
xlabel('t');
ylabel('x2(t)');
title('2nd Message in Time Domain');
subplot(4,3,3)
plot(k*Fs/N,fftshift(abs(X)));
xlabel('F');
ylabel('X(F)');
title('1st Message in Frequency Domain');
subplot(4,3,4)
plot(k*Fs2/N,fftshift(abs(X2)));
xlabel('F');
ylabel('X2(F)');
title('2nd Message in Frequency Domain');
%% Creating the AM carrier for first signal
Ts=0:1/(Fs):17;
Fn=100000;
A = cos(2*pi*Fn*Ts);    %carrier signal
A = A.';                %converting to row vector to multiply properly

%% Creating the AM carrier for the second signal
Ts2=0:1/(Fs2):17;
Fn2=150000;
A2 = cos(2*pi*Fn2*Ts2);   %carrier signal
A2 = A2.';                %converting to row vector to multiply properly

%% Padding for both Signals
maxlen = max(length(A), length(x));
x(end+1:maxlen) = 0;
A(end+1:maxlen) = 0;     %padding for the carrier and the signal
maxlen = max(length(A2), length(x2));
x2(end+1:maxlen) = 0;
A2(end+1:maxlen) = 0;    %padding for the carrier and the signal

%% FDM
s=(x.*A)+(x2.*A2);   %DSB-SC AM
subplot(4,3,5)
plot(s);
xlabel('t');
ylabel('s(t)');
title('Modulated Signals in Time Domain');
S = fft(s,N);
subplot(4,3,6)
plot(k*Fs/N,fftshift(abs(S)));
xlabel('F');
ylabel('S(F)');
title('Modulated Signals in Frequency Domain');
 
%% RF Stage BPF
A_stop1 = 60;                    % Attenuation in the first stopband = 60 dB
F_stop1 = 88000;                 % Edge of the stopband = 88000 Hz
F_pass1 = 90000;                 % Edge of the passband = 90000 Hz
F_pass2 = 110000;                % Closing edge of the passband = 110000 Hz
F_stop2 = 112000;                % Edge of the second stopband = 112000 Hz
A_stop2 = 80;                    % Attenuation in the second stopband = 80 dB
A_pass = 1;                      % Amount of ripple allowed in the passband = 1 dB
Sbpf = fdesign.bandpass(F_stop1, F_pass1, F_pass2, F_stop2, A_stop1, A_pass, A_stop2, 441000);
BandPassFilt = design(Sbpf, 'equiripple');
op = filter(BandPassFilt,s);
OP= fft(op, N);
subplot(4,3,7)
plot(k*Fs/N,fftshift(abs(OP)));
xlabel('F');
ylabel('OP(F)');
title('Modulated Signals after RF-BPF ');
%% RF Oscillator Stage
Fif = 125000;       %carrier frequency
c = 2*cos(2*pi*Fif*Ts);
c = c.';
maxlen = max(length(c), length(op));
c(end+1:maxlen) = 0;
op(end+1:maxlen) = 0;
%% Mixer Stage
sif = c.*op;      % output of Mixer in time domain
Sif = fft(sif,N);
subplot(4,3,8)
plot(k*Fs/N,fftshift(abs(Sif)));
xlabel('F');
ylabel('Sif(F)');
title('Modulated Signal after The Mixer');
 
%% IF BPF  
A_stop1if = 60;                    % Attenuation in the first stopband = 60 dB
F_stop1if = 14000;                 % Edge of the stopband = 14000 Hz
F_pass1if = 15000;                 % Edge of the passband = 15000 Hz
F_pass2if = 35000;                 % Closing edge of the passband = 35000 Hz
F_stop2if = 36000;                 % Edge of the second stopband = 360000 Hz
A_stop2if = 60;                    % Attenuation in the second stopband = 60 dB
A_passif = 1;                      % Amount of ripple allowed in the passband = 1 dB
Sbpfif = fdesign.bandpass(F_stop1if, F_pass1if, F_pass2if, F_stop2if, A_stop1if, A_passif, A_stop2if, 441000);
BandPassFiltif = design(Sbpfif, 'equiripple');
opif = filter(BandPassFiltif,sif);
OPIF= fft(opif,N);
subplot(4,3,9)
plot(k*Fs/N,fftshift(abs(OPIF)));
xlabel('F');
ylabel('OPIF(F)');
title('Modulated Signals after IF-BPF ');
%% BaseBand Oscillator
fbb = 25000;
bboc = 10*cos(2*pi*fbb*Ts);
bboc = bboc.';
maxlen = max(length(bboc), length(opif));
bboc(end+1:maxlen) = 0;
opif(end+1:maxlen) = 0;
%% Mixer
h = bboc.*opif;
H = fft(h,N);
subplot(4,3,10)
plot(k*Fs/N,fftshift(abs(H)));
xlabel('F');
ylabel('H(F)');
title('BaseBand before LPF');
%% Base Band Detection
w = lowpass(h,10000,Fs);
W = fft(w,N);
subplot(4,3,11)
plot(k*Fs/N,fftshift(abs(W)));
xlabel('F');
ylabel('W(F)');
title('Demodulated Signal');
g= downsample(w,10);
sound(g,Fs/10);
subplot(4,3,12)
plot(g);
xlabel('t');
ylabel('g(t)');
title('final o/p original signal')

