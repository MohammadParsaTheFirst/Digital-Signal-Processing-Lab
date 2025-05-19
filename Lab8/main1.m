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
    
% Analyzing the spectrum
specAnalyzer = dsp.SpectrumAnalyzer ( ...
    'SampleRate', sampleRate , ...
    'SpectrumType', 'Power', ...
    'Title', 'RTL_SDL_Real_Time_Spectrum', ...
    'ShowLegend', true ) ;
    
% demodulation
fmDemod = comm.FMBroadcastDemodulator ( ...
'SampleRate', sampleRate , ...
'FrequencyDeviation', 75e3 , ...
'AudioSampleRate', audioFs ) ;

% playing
player = audioDeviceWriter ('SampleRate', audioFs ) ;

while true
    iq = double ( radio () ) ;
    iq = iq / max ( abs ( iq ) ) ; % Normalize
    specAnalyzer ( iq ) ;  
    audio = fmDemod ( double ( iq ) ) ;
    player ( audio ) ;
end
