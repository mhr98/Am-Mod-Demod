
% plot_spectrum: Plot the signal's spectrom
%
% Inputs: 
%   - signal: the input signal
%   - Fs: Sampling frequency
%   - title_str: the figure title
% Outputs:
%   - Signal spectrum

function plot_spectrum(signal, Fs, title_str)
    figure;
    pwelch(signal, [], [], [], Fs);
    xlabel('kHz', 'FontSize', 18, 'FontName', 'Times');
    ylabel('Spectrum', 'FontSize', 18, 'FontName', 'Times');
    title(title_str, 'FontSize', 18, 'FontName', 'Times');
    xlim([0 Fs/2000])
    set(gca, 'fontsize', 18);
end