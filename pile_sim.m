%% PEM Electrolyzer Simulation: Horizon Auto Cell
clear; clc;

% --- 1. Define Pile Physical Data ---
n_cells = 1;                % Single cell for Horizon kit
A = 5.3;                    % Active area in cm^2 (standard Horizon size)
membrane_thickness = 175;   % Nafion 117 is approx 175 micrometers

% --- 2. Define Variables to Vary ---
current_intensity = [0.1, 0.5, 1.0, 1.5]; % Amps (Intensity)
water_flow_rate = [0.5, 1.0, 2.0];        % ml/min (Quantity of water)

% --- 3. Run Simulation Loop ---
results = struct();

for i = 1:length(current_intensity)
    I = current_intensity(i);

    % Example Calculation: Hydrogen Production Rate (molar)
    % n_dot = (n * I) / (z * F)
    z = 2; 
    F = 96485;
    h2_prod = (n_cells * I) / (z * F);

    % Store results
    results(i).intensity = I;
    results(i).h2_flow = h2_prod;

    fprintf('Simulating Intensity: %.2f A... Done.\n', I);
end

% --- 4. Plotting the Polarization Curve ---
% (Assuming you have a function to calculate Voltage V)
% plot(current_intensity, [results.voltage]); 
% title('Horizon PEM Pile: V-I Curve');
% xlabel('Intensity (A)'); ylabel('Voltage (V)');