fs = 24e4;
lp_cutoff = 1e5;
lpFilt = designfilt ( 'lowpassfir' , ...
    'PassbandFrequency' , lp_cutoff , ...
    'StopbandFrequency' , lp_cutoff * 1.2 , ...
    'SampleRate' , fs , ...
    'DesignMethod' , 'equiripple');

%% step 2 -- getting the (sterio) L+R signal --
fs = 24e4;
lp_cutoff2 = 1.5e4;
lpFilt2 = designfilt ( 'lowpassfir' , ...
'PassbandFrequency' , lp_cutoff2 , ...
'StopbandFrequency' , 1.7e4 , ...
'SampleRate' , fs , ...
'DesignMethod' , 'equiripple') ;
%%

fs = 24e4;
lp_cutoff3 = 2e4;
lpFilt3 = designfilt ( 'lowpassfir' , ...
'PassbandFrequency' , lp_cutoff3 , ...
'StopbandFrequency' , 2.5e4 , ...
'SampleRate' , fs , ...
'DesignMethod' , 'equiripple') ;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       THIS IS THE CODE THAT RTL-SDR HANDLES EVERYTHING          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Defining the main params
fs = 24e4;
centerFreq_MHz = 93.5;
sampleRate = 240e3 ;
audioFs = 48e3 ;

% Checking if any object of these types are still in the memeory to delete them
if exist ('radio','var') , release ( radio ) ; clear radio ; end
if exist ('specAnalyzer','var') , release ( specAnalyzer ) ; clear specAnalyzer ; end
if exist ('fmDemod','var') , release ( fmDemod ) ; clear fmDemod ; end
if exist ('player','var') , release ( player ) ; clear player ; end

% the player object
player = audioDeviceWriter ('SampleRate', audioFs ) ;

% Recieving the sgnal
radio = comm . SDRRTLReceiver ( ...
    'CenterFrequency', centerFreq_MHz *1e6 , ...
    'SampleRate', sampleRate , ...
    'OutputDataType', 'double', ...
    'EnableTunerAGC', false , ...
    'TunerGain', 50,...
    'SamplesPerFrame', 1024*10) ;
    
% Defining the spectrum analyzer
specAnalyzer = dsp.SpectrumAnalyzer ( ...
    'SampleRate', sampleRate , ...
    'SpectrumType', 'Power', ...
    'Title', 'RTL_SDL_Real_Time_Spectrum', ...
    'ShowLegend', true ) ;
    
% Demodulation Module
fmDemod = comm.FMBroadcastDemodulator ( ...
'SampleRate', sampleRate , ...
'FrequencyDeviation', 75e3 , ...
'AudioSampleRate', audioFs ) ;

% Online Streaming of the radio signal
while true
    iq = double ( radio () ) ;
    iq = iq / max ( abs ( iq ) ) ; % Normalize
    specAnalyzer ( iq ) ;  
    audio = fmDemod ( double ( iq ) ) ;
    player ( audio ) ;
end

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        THIS IS THE CODE USING THE FILTER FUNCTION               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
centerFreq_MHz = 93.5;
sampleRate = 240e3 ;
audioFs = 48e3 ;

if exist ('radio','var') , release ( radio ) ; clear radio ; end
if exist ('specAnalyzer','var') , release ( specAnalyzer ) ; clear specAnalyzer ; end
if exist ('fmDemod','var') , release ( fmDemod ) ; clear fmDemod ; end
if exist ('player','var') , release ( player ) ; clear player ; end

player = audioDeviceWriter ('SampleRate', audioFs ) ;

%recieve sgnal
radio = comm . SDRRTLReceiver ( ...
    'CenterFrequency', centerFreq_MHz *1e6 , ...
    'SampleRate', sampleRate , ...
    'OutputDataType', 'double', ...
    'EnableTunerAGC', false , ...
    'TunerGain', 50,...
    'SamplesPerFrame', 1200) ;

%analyze the spectrum
specAnalyzer = dsp.SpectrumAnalyzer ( ...
    'SampleRate', sampleRate , ...
    'SpectrumType', 'Power', ...
    'Title', 'RTL_SDL_Real_Time_Spectrum', ...
    'ShowLegend', true ) ;

%demodulation
%fmDemod = comm.FMBroadcastDemodulator ( ...
%'SampleRate', sampleRate , ...
%'FrequencyDeviation', 75e3 , ...
%'AudioSampleRate', audioFs ) ;

% playing
%player = audioDeviceWriter ('SampleRate', audioFs ) ;


while true
    iq = double ( radio () ) ;
    iq = iq / max ( abs ( iq ) ) ; % Normalize

    filteredSignal = filter ( lpFilt , iq ) ;
    % -- getting the phase, diffferentiating it & removing its DC --
    instPhase = unwrap ( angle ( filteredSignal ) ) ;
    demodulated = diff ( instPhase ) ;
    demodulated = demodulated - mean ( demodulated ) ;
    filteredSignal2 = filter ( lpFilt2 , demodulated ) ;
    %step 3 -- decimation of L+R signal --
    decimation_factor = 5;%floor ( fs / aud% io_fs ) ;
    audio = decimate(filteredSignal2 , decimation_factor ) ;
    audio = audio / max ( abs ( audio ) ) ;

    % -- playing the L+R signal
    %sound ( audio , fs/decimation_factor ) ;

    specAnalyzer ( iq ) ;
    %audio = fmDemod ( double ( iq ) ) ;
    player ( audio ) ;
end


%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              THIS IS BASED ON OVERLAP-SAVE METHOD               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L = 14366;
M1 = 24;
M2 = 243;
M3 = 102;

centerFreq_MHz = 93.5;
sampleRate = 240e3 ;
audioFs = 48e3 ;

if exist ('radio','var') , release ( radio ) ; clear radio ; end
if exist ('specAnalyzer','var') , release ( specAnalyzer ) ; clear specAnalyzer ; end
if exist ('fmDemod','var') , release ( fmDemod ) ; clear fmDemod ; end
if exist ('player','var') , release ( player ) ; clear player ; end

player = audioDeviceWriter ('SampleRate', audioFs, 'SupportVariableSizeInput',true) ;

%recieve signal
radio = comm . SDRRTLReceiver ( ...
    'CenterFrequency', centerFreq_MHz *1e6 , ...
    'SampleRate', sampleRate , ...
    'OutputDataType', 'double', ...
    'EnableTunerAGC', false , ...
    'TunerGain', 50,...
    'SamplesPerFrame', 1200) ;

%analyze the spectrum
specAnalyzer = dsp.SpectrumAnalyzer ( ...
    'SampleRate', sampleRate , ...
    'SpectrumType', 'Power', ...
    'Title', 'RTL_SDL_Real_Time_Spectrum', ...
    'ShowLegend', true ) ;


saveOLPin1 = zeros(M1-1,1);
saveOLPin2 = zeros(M2-1,1);
saveOLPin3 = zeros(M3-1,1);
idx_init =1;

while true
    iq = double ( radio () ) ;
    iq = iq / max ( abs ( iq ) ) ; 

    %----------------------------------------------------------
    %filteredSignal = filter ( lpFilt , iq );
    % 14336 = 2^11 * 7 = (112)*(128)
    h1 = lpFilt.Coefficients(:);
    L1 = 112;
    for j=1:(L/L1)%=128
        temp = iq((j-1)*L1+1:j*L1)
        [filteredSignal, saveOLPout1] = OLS( h1, temp, saveOLPin1);
        saveOLPin1 = saveOLPout1;
    end
    %[filteredSignal, saveOLPout1] = OLS( h1, iq, saveOLPin1);
    %saveOLPin1 = saveOLPout1;

    % ----------------------------------------------------------

    instPhase = unwrap ( angle ( filteredSignal ) ) ;
    demodulated = diff ( instPhase ) ;
    demodulated = demodulated - mean ( demodulated ) ;

    % -----------------------------------------------------------
    % filteredSignal2 = filter ( lpFilt2 , demodulated ) ; 
    h2 = lpFilt2.Coefficients(:);
    L1 = 112;
    for k=1:(L/L1)%=128
        temp = demodulated((k-1)*L1+1:k*L1)
        [filteredSignal, saveOLPout1] = OLS( h2, temp, saveOLPin1);
        saveOLPin1 = saveOLPout1;
    end
    %[filteredSignal2, saveOLPout2] = OLS( h2, demodulated, saveOLPin2);
    %saveOLPin2 = saveOLPout2;
    % ------------------------------------------------------------
    
    decimation_factor = 5;
    % audio = decimate(filteredSignal2 , decimation_factor ) ;
    h3 = lpFilt3.Coefficients(:);
    for t=1:(L/L1)%=128
        temp = filteredSignal2((t-1)*L1+1:t*L1);
        [audio] = OLA( h3, temp);
    end
    %[audio, saveOLPout3] = OLS( h3, filteredSignal2, saveOLPin3);
    %saveOLPin3 = saveOLPout3;
    step = idx_init:decimation_factor:length(audio);
    idx_init = step(length(step)) - length(audio) + decimation_factor;
    audio = audio(step);
    % ------------------------------------------------------------
    audio = audio / max ( abs ( audio ) ) ;
    specAnalyzer ( iq ) ;
    player ( audio ) ;
end


%%
if exist ('radio','var') , release ( radio ) ; clear radio ; end
if exist ('specAnalyzer','var') , release ( specAnalyzer ) ; clear specAnalyzer ; end
if exist ('fmDemod','var') , release ( fmDemod ) ; clear fmDemod ; end
if exist ('player','var') , release ( player ) ; clear player ; end
%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               THIS IS BASED ON OVERLAP-ADD METHOD               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
L = 14366;
M1 = 24;
M2 = 243;
M3 = 102;

centerFreq_MHz = 93.5;
sampleRate = 240e3 ;
audioFs = 48e3 ;

if exist ('radio','var') , release ( radio ) ; clear radio ; end
if exist ('specAnalyzer','var') , release ( specAnalyzer ) ; clear specAnalyzer ; end
if exist ('fmDemod','var') , release ( fmDemod ) ; clear fmDemod ; end
if exist ('player','var') , release ( player ) ; clear player ; end

player = audioDeviceWriter ('SampleRate', audioFs, 'SupportVariableSizeInput',true) ;

%recieve signal
radio = comm . SDRRTLReceiver ( ...
    'CenterFrequency', centerFreq_MHz *1e6 , ...
    'SampleRate', sampleRate , ...
    'OutputDataType', 'double', ...
    'EnableTunerAGC', false , ...
    'TunerGain', 50,...
    'SamplesPerFrame', 1200) ;

%analyze the spectrum
specAnalyzer = dsp.SpectrumAnalyzer ( ...
    'SampleRate', sampleRate , ...
    'SpectrumType', 'Power', ...
    'Title', 'RTL_SDL_Real_Time_Spectrum', ...
    'ShowLegend', true ) ;

idx_init =1;

while true
    iq = double ( radio () ) ;
    iq = iq / max ( abs ( iq ) ) ; 

    %----------------------------------------------------------
    %filteredSignal = filter ( lpFilt , iq );
    % 14336 = 2^11 * 7 = (112)*(128)
    h1 = lpFilt.Coefficients(:);
    L1 = 112;
    for j=1:(L/L1)%=128
        temp = iq((j-1)*L1+1:j*L1);
        [filteredSignal] = OLA( h1, temp, saveOLPin1);
    end
    %[filteredSignal, saveOLPout1] = OLS( h1, iq, saveOLPin1);
    %saveOLPin1 = saveOLPout1;

    % ----------------------------------------------------------

    instPhase = unwrap ( angle ( filteredSignal ) ) ;
    demodulated = diff ( instPhase ) ;
    demodulated = demodulated - mean ( demodulated ) ;

    % -----------------------------------------------------------
    % filteredSignal2 = filter ( lpFilt2 , demodulated ) ; 
    h2 = lpFilt2.Coefficients(:);
    L1 = 112;
    for k=1:(L/L1)%=128
        temp = demodulated((k-1)*L1+1:k*L1);
        [filteredSignal2] = OLA( h2, temp);
    end
    %[filteredSignal2, saveOLPout2] = OLS( h2, demodulated, saveOLPin2);
    %saveOLPin2 = saveOLPout2;
    % ------------------------------------------------------------
    
    decimation_factor = 5;
    % audio = decimate(filteredSignal2 , decimation_factor ) ;
    h3 = lpFilt3.Coefficients(:);
    for t=1:(L/L1)%=128
        temp = filteredSignal2((t-1)*L1+1:t*L1);
        [audio] = OLA( h3, temp);
    end
    %[audio, saveOLPout3] = OLS( h3, filteredSignal2, saveOLPin3);
    %saveOLPin3 = saveOLPout3;
    step = idx_init:decimation_factor:length(audio);
    idx_init = step(length(step)) - length(audio) + decimation_factor;
    audio = audio(step);
    % ------------------------------------------------------------
    audio = audio / max ( abs ( audio ) ) ;
    specAnalyzer ( iq ) ;
    player ( audio ) ;
end


%%
function [output, saveOLPout] = OLS(h, signal, saveOLPin)
    L= length(signal);    
    M = length(h);
    z = zeros(L,1);
    y = conv(signal, h);
    % disp(size(z));
    % disp(size(saveOLPin));
    % disp(size(z(1:M-1)));
    z(1:M-1) = saveOLPin;
    output = y(1:L) + z;
    saveOLPout = y(L+1:L+M-1);
end



function [output] = OLA(h, signal, output, i)
    L= length(signal);    
    M = length(h);
    z = zeros(L,1);
    y = conv(signal, h); % size L+M-1
    output((i-1)*L+1:i*L) = output((i-1)*L+1:i*L) + y(1:L);
    output(i*L+1:i*L+M-1) = y(L+1:L+M-1);
end


% function [] = fmDemodBlock()



%%
% %check that OLA function works properly
% block = zeros(100,1);
% x = rand(1000,1);
% h = rand(10,1);
% 
% output  = zeros(1000,1);
% real_output = conv(x,h);
% 
% for i=1:10
%     block = x((i-1)*100+1:i*100);
%     [output] = OLA(h,block,output, i);
% end
% 
% 
% figure
% subplot(1, 3, 1)
% plot(output, 'b');
% subplot(1, 3, 2)
% plot(real_output, 'r');
% subplot(1,3,3);
% plot(real_output, 'r');
% hold on 
% plot(output, 'b');
% 
% 

%% ----> check that OLS function works properly
% block = zeros(100,1);
% x = rand(1000,1);
% z = zeros(9,1);
% h = rand(10,1);
% my_ouput  = zeros(1000,1)
% output = zeros(100,1);
% for i=1:10
%     block = x((i-1)*100+1:i*100);
%     [output,save] = OLS(h,block, z);
%     z = save;
%     my_ouput((i-1)*100+1: i*100) = output;
% end
% 
% 
% real_output = conv(x, h);
% figure
% subplot(1, 3, 1)
% plot(my_ouput, 'b');
% subplot(1, 3, 2)
% plot(real_output, 'r');
% subplot(1,3,3);
% plot(real_output, 'r');
% hold on 
% plot(my_ouput, 'b');
