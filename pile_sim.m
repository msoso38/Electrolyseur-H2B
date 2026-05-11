%% Dynamic PEM Electrolyzer Control
clear; clc;

% --- Pile Constants (Horizon Auto Cell) ---
n = 1;              % 1 cell
A = 5.3;            % cm^2
F = 96485;          % Faraday Constant
R_int = 0.15;       % Internal Resistance (Adjustable)

% --- Setup Live Plot ---
figure('Name', 'Horizon PEM Live Monitor', 'Color', 'w');
h1 = subplot(2,1,1); grid on; hold on;
title('Voltage Response (V)'); xlabel('Time (s)'); ylabel('Volts');
h2 = subplot(2,1,2); grid on; hold on;
title('H2 Production Rate (mol/s)'); xlabel('Time (s)'); ylabel('Flow');

% --- Dynamic Simulation Loop ---
total_time = 100; % seconds
dt = 0.5;         % time step

for t = 0:dt:total_time
    % 1. SIMULATE DYNAMIC INPUTS (You can change these values manually here)
    if t < 30
        Intensity = 0.5;   % Low Power phase
        Water_Qty = 1.0;
    elseif t < 70
        Intensity = 1.2;   % High Power phase (Stress test)
        Water_Qty = 2.0;   % Increase water to cool/hydrate
    else
        Intensity = 0.8;   % Recovery phase
        Water_Qty = 1.0;
    end

    % 2. ELECTROCHEMICAL CALCULATIONS
    % V = E_rev + I*R + Activation_Loss
    V_rev = 1.229; 
    V_stack = n * (V_rev + (Intensity * R_int) + 0.05 * log(Intensity/0.001));

    % H2 Production (Faraday's Law)
    H2_flow = (n * Intensity) / (2 * F);

    % 3. UPDATE LIVE PLOTS
    plot(h1, t, V_stack, 'r.');
    plot(h2, t, H2_flow, 'b.');
    drawnow limitrate; % Forces MATLAB to update the UI

    pause(0.05); % Slows down simulation so you can watch it
end