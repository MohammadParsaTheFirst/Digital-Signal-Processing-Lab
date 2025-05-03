%% step 1
path = "C:\\Users\\USER\\Desktop\\sdrsharp\\IQ\\2025_05_03\\audio4.Wav";
[ raw_signal , fs ] = audioread ( path ) ;
I = raw_signal (: ,1) ;
Q = raw_signal (: ,2) ;
complexSignal = I + 1i * Q ;
%% step 2
lp_cutoff = 1e5;
lpFilt = designfilt ( 'lowpassfir' , ...
'PassbandFrequency' , lp_cutoff , ...
'StopbandFrequency' , lp_cutoff * 1.2 , ...
'SampleRate' , fs , ...
'DesignMethod' , 'equiripple') ;
filteredSignal = filter ( lpFilt , complexSignal ) ;
%% step 3
instPhase = unwrap ( angle ( filteredSignal ) ) ;
demodulated = diff ( instPhase ) ;
demodulated = demodulated - mean ( demodulated ) ;

%% step 5
lp_cutoff2 = 1.5e4;
lpFilt2 = designfilt ( 'lowpassfir' , ...
'PassbandFrequency' , lp_cutoff2 , ...
'StopbandFrequency' , 1.8e4 , ...
'SampleRate' , fs , ...
'DesignMethod' , 'equiripple') ;
filteredSignal2 = filter ( lpFilt2 , demodulated ) ;


%% step 4
audio_fs = 44100;
decimation_factor = 40;%floor ( fs / aud% io_fs ) ;
audio = decimate(filteredSignal2 , decimation_factor ) ;
audio = audio / max ( abs ( audio ) ) ;


%% step 6
sound ( audio , fs/decimation_factor ) ; % Play the audio at the target sampling rate
%%
pwelch(audio,[] , [], [], fs/decimation_factor)
