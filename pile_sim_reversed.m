function G2P_Horizon_Final()
% --- UI SETUP ---
fig = uifigure('Name', 'Horizon PEM Stack: G2P Monitor', 'Position', [50 50 1100 680]);
fig.Color = [0.1 0.1 0.1]; 

% --- STATE VARIABLES ---
sim = struct('H2_in', 100, 'O2_in', 50, 'V_load', 0.6, 'W_purge', 5, 'Current', 0, 'Eta', 0);

% --- INPUT CONTROLS ---
pnl = uipanel(fig, 'Title', 'Horizon Stack Controls', 'Position', [20 20 280 640], 'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'w');

uilabel(pnl, 'Text', 'H2 Input (ml/min):', 'Position', [20 560 150 20], 'FontColor', 'w');
uislider(pnl, 'Limits', [0, 500], 'Position', [40 540 200 3], 'Value', sim.H2_in, ...
    'ValueChangingFcn', @(src,event) updateParam('H2_in', event.Value));

uilabel(pnl, 'Text', 'O2 Input (ml/min):', 'Position', [20 460 150 20], 'FontColor', 'w');
uislider(pnl, 'Limits', [0, 250], 'Position', [40 440 200 3], 'Value', sim.O2_in, ...
    'ValueChangingFcn', @(src,event) updateParam('O2_in', event.Value));

uilabel(pnl, 'Text', 'Electronic Load (V):', 'Position', [20 360 150 20], 'FontColor', 'w');
uislider(pnl, 'Limits', [0.1, 1.2], 'Position', [40 340 200 3], 'Value', sim.V_load, ...
    ... % Standard Horizon cell voltage range
    'ValueChangingFcn', @(src,event) updateParam('V_load', event.Value));

uilabel(pnl, 'Text', 'Water Exit Capacity:', 'Position', [20 260 180 20], 'FontColor', 'w');
uislider(pnl, 'Limits', [0.1, 10], 'Position', [40 240 200 3], 'Value', sim.W_purge, ...
    'ValueChangingFcn', @(src,event) updateParam('W_purge', event.Value));

% --- READOUTS ---
lblAmp = uilabel(fig, 'Text', 'Current: 0.00 A', 'Position', [330 570 250 40], 'FontSize', 22, 'FontColor', [1 0.8 0.3]);
lblPow = uilabel(fig, 'Text', 'Power: 0.00 W', 'Position', [330 520 250 40], 'FontSize', 22, 'FontColor', [1 0.5 0.5]);

% ETA Gauge
uilabel(fig, 'Text', 'Efficiency (\eta)', 'Position', [330 460 100 20], 'FontColor', 'w');
gaugeEta = uigauge(fig, 'semicircular', 'Position', [330 350 200 120], 'Limits', [0 1], 'Value', 0);

lblH2O = uilabel(fig, 'Text', 'Water Exit: 0.00 ml/min', 'Position', [330 300 250 30], 'FontSize', 16, 'FontColor', [0.7 0.7 1]);

% --- PLOT (Infinite Trace) ---
ax = uiaxes(fig, 'Position', [600 80 460 550], 'BackgroundColor', [0 0 0], 'XColor', 'w', 'YColor', 'w');
grid(ax, 'on'); xlabel(ax, 'Time (s)'); ylabel(ax, 'Telemetry');
ax.YLim = [0 5]; ax.XLim = [0 60];

hAmp = animatedline(ax, 'Color', [1 0.8 0.3], 'LineWidth', 2, 'DisplayName', 'Current (A)');
hEta = animatedline(ax, 'Color', [0.5 1 0.5], 'LineWidth', 2, 'DisplayName', 'Efficiency (\eta)');
legend(ax, 'TextColor', 'w');

    function updateParam(field, val), sim.(field) = val; end

% --- PHYSICS ---
F = 96485;
V_th = 1.23; % Theoretical potential (HHV)
startTime = tic;

while isvalid(fig)
    t = toc(startTime);

    % 1. Stoichiometry
    I_avail = min((sim.H2_in/22414/60)*2*F, (sim.O2_in/22414/60)*4*F);

    % 2. Horizon Internal Resistance Calibration
    R_int = 0.5 + (2.0 / (sim.W_purge + 0.1)); 
    V_ocv = 1.05; % Typical OCV for a small Horizon stack

    if sim.V_load < V_ocv
        I_req = (V_ocv - sim.V_load) / R_int;
        sim.Current = min(I_req, I_avail);
    else
        sim.Current = 0;
    end

    % 3. Calculate ETA (Efficiency)
    % Voltage Efficiency = Operating Voltage / Theoretical Voltage
    if sim.Current > 0
        sim.Eta = sim.V_load / V_th;
    else
        sim.Eta = 0;
    end

    p_watts = sim.Current * sim.V_load;
    actual_h2o = (sim.Current * 60 * 18.015) / (2 * 96485);

    % 4. UI UPDATE
    lblAmp.Text = sprintf('Current: %.2f A', sim.Current);
    lblPow.Text = sprintf('Power: %.2f W', p_watts);
    lblH2O.Text = sprintf('Water Exit: %.3f ml/min', actual_h2o);
    gaugeEta.Value = sim.Eta;

    addpoints(hAmp, t, sim.Current);
    addpoints(hEta, t, sim.Eta * 5); % Scaled to Y-axis for visibility

    if t > 60, ax.XLim = [t-60, t]; end
    drawnow limitrate; pause(0.04); 
end
end