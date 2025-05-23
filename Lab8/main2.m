% step 0 -- Defining the main params --
fs = 24e4;
centerFreq_MHz = 93.5;
sampleRate = fs;
audioFs = 48e3 ;

% step 1 -- the filter for the signal within [0,100kHz] freq range --
lp_cutoff = 1e5;
lpFilt = designfilt ( 'lowpassfir' , ...
    'PassbandFrequency' , lp_cutoff , ...
    'StopbandFrequency' , lp_cutoff * 1.2 , ...
    'SampleRate' , fs , ...
    'DesignMethod' , 'equiripple');
    
% step 2 -- the filter for getting the (aggregated sterio) L+R signal --
fs = 24e4;
lp_cutoff2 = 1.5e4;
lpFilt2 = designfilt ( 'lowpassfir' , ...
'PassbandFrequency' , lp_cutoff2 , ...
'StopbandFrequency' , 1.7e4 , ...
'SampleRate' , fs , ...
'DesignMethod' , 'equiripple') ;

% step 3 -- chekcing whether certain objects are in the workspace
if exist ('radio','var') , release ( radio ) ; clear radio ; end
if exist ('specAnalyzer','var') , release ( specAnalyzer ) ; clear specAnalyzer ; end
if exist ('fmDemod','var') , release ( fmDemod ) ; clear fmDemod ; end
if exist ('player','var') , release ( player ) ; clear player ; end

% step 4 -- receiving the signal & defining the player obj --
player = audioDeviceWriter ('SampleRate', audioFs ) ;
radio = comm . SDRRTLReceiver ( ...
    'CenterFrequency', centerFreq_MHz *1e6 , ...
    'SampleRate', sampleRate , ...
    'OutputDataType', 'double', ...
    'EnableTunerAGC', false , ...
    'TunerGain', 50,...
'SamplesPerFrame', 1024*14) ;

% step 5 -- getting the data in real-time, processing it & playing the signal at last --
while true
    % -- getting the envelope sigal --
    iq = double ( radio () ) ;
    iq = iq / max ( abs ( iq ) ) ; % Normalize
    filteredSignal = filter ( lpFilt , iq ) ;
    % -- getting the phase, diffferentiating it & removing its DC --
    instPhase = unwrap ( angle ( filteredSignal ) ) ;
    demodulated = diff ( instPhase ) ;
    demodulated = demodulated - mean ( demodulated ) ;
    filteredSignal2 = filter ( lpFilt2 , demodulated ) ;
    % -- decimation of L+R signal --
    decimation_factor = fs / audioFs; % =5 here
    audio = decimate(filteredSignal2 , decimation_factor ) ;
    audio = audio / max ( abs ( audio ) ) ;
    % -- playing the L+R signal --
    player ( audio ) ;
end
