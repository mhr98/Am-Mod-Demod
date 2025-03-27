% AM_Mod_Demod: This program illustrates AM modulation and demodulation
% using acoustic signals in the human-audible frequency band
% Copyright (C) 2025  Mohammad Safa
% GitHub Repository: https://github.com/mhr98/Am-Mod-Demod
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

%% Parameters
clear;
Fs = 48000;       % Sampling frequency
Fc1 = 13000;      % Carrier frequency for User 1
Fc2 = 9000;      % Carrier frequency for User 2
Fc3 = 5000;      % Carrier frequency for User 3
Message_time = 3; % Audio signal duration in seconds
Flpf =1500;      % Cutoff frequency for low-pass filter (baseband bandwidth)
M = 1;            % Modulation index (100% modulation)

%% Audio recorder setup
audioRecorder = audiorecorder(Fs, 16, 1);

% Record baseband signals from three users
disp('Recording User 1 message...');
record(audioRecorder); 
pause(Message_time);
stop(audioRecorder); 
audio_sig1 = getaudiodata(audioRecorder)';

disp('Recording User 2 message...');
record(audioRecorder); 
pause(Message_time);
stop(audioRecorder); 
audio_sig2 = getaudiodata(audioRecorder)';

disp('Recording User 3 message...');
record(audioRecorder); 
pause(Message_time);
stop(audioRecorder); 
audio_sig3 = getaudiodata(audioRecorder)';

% Apply low-pass filter to limit baseband bandwidth
input_sig1 = lowpass(audio_sig1, Flpf, Fs, Steepness=0.95);
input_sig2 = lowpass(audio_sig2, Flpf, Fs, Steepness=0.95);
input_sig3 = lowpass(audio_sig3, Flpf, Fs, Steepness=0.95);

% Plot frequency spectrum of baseband signals
plot_spectrum(input_sig1, Fs, 'User 1 Baseband Spectrum');
plot_spectrum(input_sig2, Fs, 'User 2 Baseband Spectrum');
plot_spectrum(input_sig3, Fs, 'User 3 Baseband Spectrum');

% Normalize signals to prevent overmodulation
input_sig1 = input_sig1 / max(abs(input_sig1));
input_sig2 = input_sig2 / max(abs(input_sig2));
input_sig3 = input_sig3 / max(abs(input_sig3));

%% AM Transmitter
% Generate carrier signals with normalized amplitude
t = (1/Fs)*(0:length(audio_sig1)-1);
carrier1 = (1/sqrt(2))*cos(2*pi*Fc1*t);
carrier2 = (1/sqrt(2))*cos(2*pi*Fc2*t);
carrier3 = (1/sqrt(2))*cos(2*pi*Fc3*t);

% Perform amplitude modulation
mod_sig1 = carrier1 .* (1 + M*input_sig1);
mod_sig2 = carrier2 .* (1 + M*input_sig2);
mod_sig3 = carrier3 .* (1 + M*input_sig3);

% Combine all modulated signals for transmission
Tx_signal = mod_sig1 + mod_sig2 + mod_sig3;

plot_spectrum(Tx_signal, Fs, 'AM Spectrum');

% Save transmission as WAV file (commented for simulation)
Tx_normalized = Tx_signal / max(abs(Tx_signal));
% audiowrite('txAudio.wav', Tx_normalized, Fs);

%% AM Receiver Simulation
% Record received signal through acoustic channel
soundsc(Tx_normalized, Fs);

disp('Receiving transmission...');
record(audioRecorder); 
pause(Message_time + 1); % Allow extra time for transmission delay
stop(audioRecorder); 
Rx_signal = getaudiodata(audioRecorder)';
plot_spectrum(Rx_signal, Fs, 'Received Signal Spectrum');

% For simulation
% Rx_signal=Tx_signal;

%% AM Demodulation
% Generate complex local oscillators for coherent detection
t = (1/Fs)*(0:length(Rx_signal)-1);
local_osc1 = (1/sqrt(2))*exp(1i*2*pi*Fc1*t);
local_osc2 = (1/sqrt(2))*exp(1i*2*pi*Fc2*t);
local_osc3 = (1/sqrt(2))*exp(1i*2*pi*Fc3*t);

% Demodulate User 1 signal
downconverted1 = Rx_signal .* local_osc1;
filtered1 = lowpass(downconverted1, Flpf, Fs, Steepness=0.95);
plot_spectrum(filtered1, Fs, 'User 1 Baseband Recovery');

% Extract envelope and remove DC offset
demod_sig1 = abs(filtered1);          % Envelope detection
demod_sig1 = demod_sig1 - mean(demod_sig1); 

% Demodulate User 2 signal
downconverted2 = Rx_signal .* local_osc2;
filtered2 = lowpass(downconverted2, Flpf, Fs, Steepness=0.95);
demod_sig2 = abs(filtered2);
demod_sig2 = demod_sig2 - mean(demod_sig2);

% Demodulate User 3 signal
downconverted3 = Rx_signal .* local_osc3;
filtered3 = lowpass(downconverted3, Flpf, Fs, Steepness=0.95);
demod_sig3 = abs(filtered3);
demod_sig3 = demod_sig3 - mean(demod_sig3);

% Play demodulated audio (example for User 1)
% soundsc(demod_sig1, Fs);
