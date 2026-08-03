%% =========================================================
%  SIMULATION BENCHMARK - Comparaison CPU vs FPGA
%  Auteur  : (ton nom)
%  Date    : 2025
%  Objectif: Mesurer temps, CPU, RAM et signaux pour
%            comparer avec une implementation FPGA temps reel
%% =========================================================

clear; clc; close all;

%% -------------------------------------------------------
%  PARAMETRES DE TA SIMULATION (modifie ici)
%% -------------------------------------------------------
Fs      = 10000;    % Frequence d'echantillonnage [Hz]
T_sim   = 0.0005;      % Duree de simulation [s]
N       = Fs * T_sim;  % Nombre de points
t       = (0:N-1) / Fs;  % Vecteur temps

%% -------------------------------------------------------
%  0. MESURES AVANT SIMULATION
%% -------------------------------------------------------
[~, sys_before] = memory();
ram_before_MB   = sys_before.PhysicalMemory.Available / 1e6;

% CPU : on lance un timer de fond pour echantillonner le %CPU
cpu_samples = [];

fprintf('\n========================================\n');
fprintf('  SIMULATION BENCHMARK DEMARRE\n');
fprintf('  Fs = %d Hz | Duree = %.2f s | N = %d pts\n', Fs, T_sim, N);
fprintf('========================================\n\n');

%% -------------------------------------------------------
%  1. DEBUT CHRONOMETRAGE
%% -------------------------------------------------------
t_start_abs = datetime('now');
tic;  % Horloge haute precision

%% -------------------------------------------------------
%  2. TA SIMULATION ICI
%  Remplace ce bloc par ton systeme reel
%  Exemples inclus : signal composite + filtre IIR
%% -------------------------------------------------------

%% -------------------------------------------------------
%  2. TA SIMULATION SIMULINK ICI
%% -------------------------------------------------------

% -- Charge ton modele Simulink --
model_name = 'gmStateSpaceHDL_buck_convert_test1_fixpt';   % <-- mets le nom de ton fichier .slx (sans extension)
load_system(model_name);

% -- Configure les parametres de simulation --
set_param(model_name, 'StopTime',    num2str(T_sim));
set_param(model_name, 'FixedStep',   num2str(1/Fs));   % si solveur a pas fixe
set_param(model_name, 'Solver',      'FixedStepAuto'); % ou 'ode4', 'ode1', etc.

% -- Lance la simulation --
simOut = sim(model_name);

% -- Recupere tes signaux de sortie --
% Option A : si tu as un bloc "To Workspace" dans Simulink
signal_in  = simOut.mon_signal_entree.Data';   % <-- nom du bloc To Workspace
signal_out = simOut.mon_signal_sortie.Data';   % <-- nom du bloc To Workspace

% Option B : si tu utilises un scope / logsout
% signal_out = simOut.logsout.getElement('nom_signal').Values.Data';

% -- Vecteur temps depuis Simulink --
t = simOut.tout';   % ecrase le vecteur t defini plus haut
N = length(t);      % met a jour N aussi

%% -------------------------------------------------------
%  3. FIN CHRONOMETRAGE
%% -------------------------------------------------------
t_elapsed = toc;  % Temps total de simulation [s]
t_end_abs = datetime('now');

%% -------------------------------------------------------
%  4. MEMOIRE APRES
%% -------------------------------------------------------
[~, sys_after] = memory();
ram_after_MB   = sys_after.PhysicalMemory.Available / 1e6;
ram_used_MB    = ram_before_MB - ram_after_MB;

%% -------------------------------------------------------
%  5. CPU (estimation via Java - fonctionne sans toolbox)
%% -------------------------------------------------------
try
    rt = java.lang.Runtime.getRuntime();
    cpu_cores   = rt.availableProcessors();
    % Note : Java ne donne pas directement le % CPU, 
    % on utilise le temps ecoule vs temps reel comme proxy
    cpu_pct_estimate = min(100, (t_elapsed / T_sim) * 100);
catch
    cpu_cores        = feature('numcores');
    cpu_pct_estimate = NaN;
end

%% -------------------------------------------------------
%  6. CALCUL DES METRIQUES DE COMPARAISON
%% -------------------------------------------------------
% Ces metriques serviront a comparer avec les donnees FPGA

% -- Spectral (FFT) --
NFFT  = 2^nextpow2(N);
S_fft = fft(signal_out, NFFT) / N;
f_fft = (0:NFFT/2) * (Fs / NFFT);
mag_spectrum = 2 * abs(S_fft(1:NFFT/2+1));

% -- Stats du signal de sortie --
sig_mean   = mean(signal_out);
sig_std    = std(signal_out);
sig_rms    = rms(signal_out);
sig_peak   = max(abs(signal_out));

% -- Si tu as des donnees FPGA, charge-les ici --
% fpga_data = load('mes_donnees_fpga.mat');  % Decommenter
% signal_fpga = fpga_data.sortie;
% Pour demo, on simule une version FPGA avec quantification 16-bit
signal_fpga_sim = round(signal_out * 32767) / 32767;  % Virgule fixe 16-bit

% -- Erreur CPU vs FPGA --
err_signal  = signal_out - signal_fpga_sim;
MSE         = mean(err_signal.^2);
RMSE        = sqrt(MSE);
MAE         = mean(abs(err_signal));
SNR_dB      = 10 * log10(sig_rms^2 / MSE);

%% -------------------------------------------------------
%  7. RAPPORT CONSOLE
%% -------------------------------------------------------
fprintf('--- RESULTATS DE SIMULATION ---\n\n');

fprintf('[TEMPS]\n');
fprintf('  Debut           : %s\n', datestr(t_start_abs));
fprintf('  Fin             : %s\n', datestr(t_end_abs));
fprintf('  Duree totale    : %.4f s\n', t_elapsed);
fprintf('  Temps reel sim  : %.4f s\n', T_sim);
fprintf('  Ratio RT        : %.2fx  (%s)\n', T_sim/t_elapsed, ...
    ternaire(T_sim/t_elapsed >= 1, 'plus rapide que temps reel', 'TROP LENT pour RT'));
fprintf('  Temps/iteration : %.4f ms  (moy sur %d)\n', mean(t_iters)*1000, n_iter);
fprintf('  Jitter iter     : %.4f ms  (std)\n\n', std(t_iters)*1000);

fprintf('[RESSOURCES CPU]\n');
fprintf('  Coeurs dispo    : %d\n', cpu_cores);
fprintf('  CPU estime      : %.1f %%\n\n', cpu_pct_estimate);

fprintf('[MEMOIRE]\n');
fprintf('  RAM disponible avant : %.1f MB\n', ram_before_MB);
fprintf('  RAM disponible apres : %.1f MB\n', ram_after_MB);
fprintf('  RAM consommee        : %.1f MB\n\n', ram_used_MB);

fprintf('[SIGNAL]\n');
fprintf('  Fs              : %d Hz\n', Fs);
fprintf('  N points        : %d\n', N);
fprintf('  Moyenne         : %.6f\n', sig_mean);
fprintf('  Ecart-type      : %.6f\n', sig_std);
fprintf('  RMS             : %.6f\n', sig_rms);
fprintf('  Crete           : %.6f\n\n', sig_peak);

fprintf('[ERREUR CPU vs FPGA (virgule fixe 16-bit)]\n');
fprintf('  MSE             : %.2e\n', MSE);
fprintf('  RMSE            : %.2e\n', RMSE);
fprintf('  MAE             : %.2e\n', MAE);
fprintf('  SNR             : %.2f dB\n\n', SNR_dB);

fprintf('========================================\n');
fprintf('  SIMULATION TERMINEE\n');
fprintf('========================================\n\n');

%% -------------------------------------------------------
%  8. GRAPHIQUES
%% -------------------------------------------------------
fig = figure('Name', 'Benchmark Simulation CPU vs FPGA', ...
             'NumberTitle', 'off', 'Position', [50 50 1400 800]);

% --- Subplot 1 : Signal temporel complet ---
subplot(2, 3, 1);
plot(t, signal_in,  'Color', [0.5 0.5 0.5], 'LineWidth', 0.7); hold on;
plot(t, signal_out, 'b',  'LineWidth', 1.2);
plot(t, signal_fpga_sim, 'r--', 'LineWidth', 0.9);
xlabel('Temps (s)'); ylabel('Amplitude');
title('Signal temporel');
legend('Entree', 'CPU (float)', 'FPGA sim (16-bit)', 'Location', 'best');
grid on;

% --- Subplot 2 : Zoom sur les premiers cycles ---
n_zoom = min(500, N);
subplot(2, 3, 2);
plot(t(1:n_zoom), signal_out(1:n_zoom),      'b',   'LineWidth', 1.5); hold on;
plot(t(1:n_zoom), signal_fpga_sim(1:n_zoom), 'r--', 'LineWidth', 1.2);
xlabel('Temps (s)'); ylabel('Amplitude');
title('Zoom - Comparaison CPU vs FPGA');
legend('CPU (float64)', 'FPGA (16-bit)', 'Location', 'best');
grid on;

% --- Subplot 3 : Erreur CPU vs FPGA ---
subplot(2, 3, 3);
plot(t, err_signal, 'r', 'LineWidth', 0.8);
xlabel('Temps (s)'); ylabel('Erreur');
title(sprintf('Erreur (RMSE=%.2e, SNR=%.1fdB)', RMSE, SNR_dB));
grid on;
yline(0, '--k', 'Alpha', 0.4);

% --- Subplot 4 : Spectre FFT ---
subplot(2, 3, 4);
plot(f_fft, 20*log10(mag_spectrum + 1e-12), 'b', 'LineWidth', 1.2);
xlabel('Frequence (Hz)'); ylabel('Magnitude (dB)');
title('Spectre FFT - Signal de sortie');
xlim([0, Fs/2]); grid on;

% --- Subplot 5 : Temps par iteration ---
subplot(2, 3, 5);
bar(t_iters * 1000, 'FaceColor', [0.2 0.5 0.8]);
hold on;
yline(mean(t_iters)*1000, 'r--', 'LineWidth', 1.5, 'Label', 'Moyenne');
xlabel('Iteration'); ylabel('Temps (ms)');
title('Temps de traitement par iteration');
grid on;

% --- Subplot 6 : Tableau recap ---
subplot(2, 3, 6);
axis off;
metriques = {
    'Duree totale',       sprintf('%.4f s',   t_elapsed);
    'Ratio temps reel',   sprintf('%.2fx',     T_sim/t_elapsed);
    'Temps/iter (moy)',   sprintf('%.3f ms',   mean(t_iters)*1000);
    'Jitter (std)',       sprintf('%.3f ms',   std(t_iters)*1000);
    'CPU estime',         sprintf('%.1f %%',   cpu_pct_estimate);
    'RAM utilise',        sprintf('%.1f MB',   ram_used_MB);
    'MSE',                sprintf('%.2e',      MSE);
    'SNR CPU vs FPGA',    sprintf('%.2f dB',   SNR_dB);
    'Fs',                 sprintf('%d Hz',      Fs);
    'N points',           sprintf('%d',         N);
};
t_tbl = uitable(fig, 'Data', metriques, ...
    'ColumnName',  {'Metrique', 'Valeur'}, ...
    'ColumnWidth', {160, 120}, ...
    'Units',       'normalized', ...
    'Position',    [0.67 0.05 0.31 0.42]);
title(gca, 'Recapitulatif des metriques');

sgtitle('Benchmark Simulation MATLAB - Comparaison CPU vs FPGA', ...
        'FontSize', 13, 'FontWeight', 'bold');

%% -------------------------------------------------------
%  9. SAUVEGARDE
%% -------------------------------------------------------
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
save_name = sprintf('benchmark_%s.mat', timestamp);

save(save_name, ...
    't', 'signal_in', 'signal_out', 'signal_fpga_sim', ...
    'f_fft', 'mag_spectrum', 'err_signal', ...
    't_elapsed', 't_iters', 'cpu_pct_estimate', 'ram_used_MB', ...
    'MSE', 'RMSE', 'MAE', 'SNR_dB', 'Fs', 'N', 'T_sim');

fig_name = sprintf('benchmark_%s.png', timestamp);
exportgraphics(fig, fig_name, 'Resolution', 150);

fprintf('Donnees sauvegardees : %s\n', save_name);
fprintf('Figure exportee      : %s\n\n', fig_name);

%% -------------------------------------------------------
%  FONCTIONS UTILITAIRES
%% -------------------------------------------------------
function out = ternaire(cond, vrai, faux)
    if cond; out = vrai; else; out = faux; end
end