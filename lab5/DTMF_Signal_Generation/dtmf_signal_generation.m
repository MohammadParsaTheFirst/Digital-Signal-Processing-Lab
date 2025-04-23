% DTMF Signal Generator with File Output and Analysis
clear; close all; clc;

% Parameters
fs = 8000;                  % Sampling frequency (8 kHz)
tone_duration = 1;          % seconds
pause_duration = 1.5;       % seconds
num_cycles = 3;             % Number of 1-pause-2-pause cycles to generate

% DTMF frequencies (Hz)
dtmf_freqs_hor = [697 770 852 941];   
dtmf_freqs_ver = [1209 1336 1477];

% Define keys (row, column pairs)
key1 = [1, 1];  % Key '1' (697 Hz + 1209 Hz)
key2 = [1, 2];  % Key '2' (697 Hz + 1336 Hz)

% Create time vectors
t_tone = 0:1/fs:tone_duration-1/fs;
t_pause = zeros(1, round(pause_duration*fs));

% Generate DTMF signals
dtmf1 = sin(2*pi*dtmf_freqs_hor(1)*t_tone) + sin(2*pi*dtmf_freqs_ver(2)*t_tone);
dtmf2 = sin(2*pi*dtmf_freqs_hor(1)*t_tone) + sin(2*pi*dtmf_freqs_ver(2)*t_tone);

% Normalize signals
dtmf1 = dtmf1/max(abs(dtmf1));
dtmf2 = dtmf2/max(abs(dtmf2));

% Create complete signal with multiple cycles
full_signal = [];
for i = 1:num_cycles
    full_signal = [full_signal, dtmf1, t_pause, dtmf2, t_pause];
end

% Save as .dat file (binary format)
fid = fopen('dtmf_signal.dat', 'w');
fwrite(fid, full_signal, 'double');
fclose(fid);

% Save as .wav file
audiowrite('dtmf_signal.wav', full_signal, fs);

% Time-Frequency Analysis
figure;

% Spectrogram settings
window = hamming(512);
noverlap = 256;
nfft = 1024;

% Plot spectrogram
subplot(2,1,1);
spectrogram(full_signal, window, noverlap, nfft, fs, 'yaxis');
title('Spectrogram of DTMF Signal');
colorbar;

% Plot time domain signal
subplot(2,1,2);
t = (0:length(full_signal)-1)/fs;
plot(t, full_signal);
xlabel('Time (s)');
ylabel('Amplitude');
title('Time Domain Signal');
xlim([0 t(end)]);

% Play the sound
soundsc(full_signal, fs);

% Display information
disp('Files saved successfully:');
disp(['- Binary data: dtmf_signal.dat']);
disp(['- Audio file: dtmf_signal.wav']);
disp(['Signal contains ', num2str(num_cycles), ' cycles of 1-pause-2-pause pattern']);
