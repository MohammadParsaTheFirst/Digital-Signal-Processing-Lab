%% step 1 -- making the complex signal --
path = "C:\\Users\\USER\\Desktop\\sdrsharp\\IQ\\2025_05_03\\audio4.Wav";
[ raw_signal , fs ] = audioread ( path ) ;
I = raw_signal (: ,1) ;
Q = raw_signal (: ,2) ;
complexSignal = I + 1i * Q ;
% step 2 -- filtering the freqs > 100kHz --
lp_cutoff = 1e5;
lpFilt = designfilt ( 'lowpassfir' , ...
'PassbandFrequency' , lp_cutoff , ...
'StopbandFrequency' , lp_cutoff * 1.2 , ...
'SampleRate' , fs , ...
'DesignMethod' , 'equiripple') ;
filteredSignal = filter ( lpFilt , complexSignal ) ;
% step 3 -- getting the phase, diffferentiating it & removing its DC --
instPhase = unwrap ( angle ( filteredSignal ) ) ;
demodulated = diff ( instPhase ) ;
demodulated = demodulated - mean ( demodulated ) ;

%% step 4 -- getting the (sterio) L+R signal --
lp_cutoff2 = 1.5e4;
lpFilt2 = designfilt ( 'lowpassfir' , ...
'PassbandFrequency' , lp_cutoff2 , ...
'StopbandFrequency' , 1.8e4 , ...
'SampleRate' , fs , ...
'DesignMethod' , 'equiripple') ;

filteredSignal2 = filter ( lpFilt2 , demodulated ) ;

%% step 5 -- decimation of L+R signal --
audio_fs = 44100;
decimation_factor = 40;%floor ( fs / aud% io_fs ) ;
audio = decimate(filteredSignal2 , decimation_factor ) ;
audio = audio / max ( abs ( audio ) ) ;

% step 6 -- playing the L+R signal
sound ( audio , fs/decimation_factor ) ; % Play the audio at the target sampling rate

% step 7 --
pwelch(audio,[] , [], [], fs/decimation_factor)

%% step 8 -- getting & decimating the sterio DSB signal --

bp_cutoff1 = 2.3e4; % Lower passband frequency in Hz
bp_cutoff2 = 5.3e4; % Upper passband frequency in Hz

bpFilt = designfilt('bandpassfir', ...
    'PassbandFrequency1', bp_cutoff1, ...
    'StopbandFrequency1', (bp_cutoff1- 1e3), ...
    'PassbandFrequency2', bp_cutoff2, ...
    'StopbandFrequency2', (bp_cutoff2 + 1e3), ...
    'SampleRate', fs, ...
    'DesignMethod', 'equiripple');

filteredSignal3 = filter(bpFilt, demodulated);

audio_fs = 44100;
decimation_factor = 40;
audio2 = decimate(filteredSignal3 , decimation_factor ) ;
audio2 = audio / max ( abs ( audio2 ) ) ;

%% step 9 -- extracting the delta and its phase --

pilot_bpFilt = designfilt('bandpassfir', ...
    'PassbandFrequency1', 1.85e4, ...
    'StopbandFrequency1', 1.8e4, ...
    'PassbandFrequency2', 1.95e4, ...
    'StopbandFrequency2', 2e4, ...
    'SampleRate', fs, ...
    'DesignMethod', 'equiripple');

pilotTone = filter(pilot_bpFilt, demodulated);

% 9.2 Get analytic signal & phase of 19kHz
analyticPilot = hilbert(pilotTone);
carrier38kHz = cos(2 * angle(analyticPilot));    % generate a 38kHz signal

%% Demodulating the signal

% demodulation (DSB-SC demodulation)
modulated_filteredSignal3 = filteredSignal3 .* carrier38kHz;  %% the L-R signal

% using the low-pass filter used earlier in section 4
filteredSignal4 = filter(lpFilt2, modulated_filteredSignal3);

% decimation
decimated_filteredSignal4 = decimate(filteredSignal4, decimation_factor);
decimated_filteredSignal4 = decimated_filteredSignal4 / max(abs(decimated_filteredSignal4));

%% Left & Right signals
Left = (decimated_filteredSignal4 + audio)/2;
Right = (- decimated_filteredSignal4 + audio)/2;


%% playing the left song 
sound(Left,  fs/decimation_factor)

%% playning the right song
sound(Right, fs/decimation_factor)

%% playing in sterio
stereoAudio = [Left, Right];
sound(stereoAudio, fs / decimation_factor);


