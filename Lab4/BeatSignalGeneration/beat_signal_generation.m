% Parameters
fs = 8000;          % Sampling frequency (8 kHz)
duration = 20;      % Total duration in seconds
t_total = 0:1/fs:duration-1/fs;  % Time vector for entire signal

% Create the base signal x1(t) = 2*sin(650Hz * t * π)
x1 = 2 * sin(650 * t_total * pi);

% Initialize x2 as a copy of x1
x2 = x1;

% Create the heartbeat burst signal (2000 Hz)
burst_duration = 2; % seconds
burst_samples = burst_duration * fs;
burst_signal = 20 * sin(2000 * (0:1/fs:burst_duration-1/fs) * pi);

% Insert bursts every 4 seconds (simulating heartbeat)
beat_interval = 4; % seconds
beat_samples = beat_interval * fs;

num_beats = floor(duration / beat_interval);

for i = 1:num_beats
    start_sample = (i-1)*beat_samples + 1;
    end_sample = start_sample + burst_samples - 1;
    
    % Make sure we don't exceed the array bounds
    if end_sample <= length(x2)
        x2(start_sample:end_sample) = burst_signal;
    else
        % Handle the last partial beat if needed
        available_samples = length(x2) - start_sample + 1;
        x2(start_sample:end) = burst_signal(1:available_samples);
    end
end

% Normalize the signal for WAV file (range [-1, 1])
x2_normalized = x2 / max(abs(x2));

% Save as .dat file (binary format)
fid = fopen('heartbeat_signal.dat', 'w');
fwrite(fid, x2, 'double');  % Save as double precision
fclose(fid);

% Save as .wav file (audio format)
audiowrite('heartbeat_sound.wav', x2_normalized, fs);

% Display information
disp('Files saved successfully:');
disp(['- Binary data: heartbeat_signal.dat (', num2str(length(x2)), ' samples)']);
disp(['- Audio file: heartbeat_sound.wav (', num2str(fs), ' Hz, ', num2str(duration), ' seconds)']);

% Play the sound
sound(x2_normalized, fs);

% Plot the first few seconds to visualize
figure;
plot(t_total(1:5*fs), x2(1:5*fs));
xlabel('Time (s)');
ylabel('Amplitude');
title('Heartbeat Audio Signal (First 5 Seconds)');
grid on;
