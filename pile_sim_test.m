function P2G_Infinite_Trace()
% --- UI SETUP ---
fig = uifigure('Name', 'P2G Infinite Trace (Fixed)', 'Position', [50 50 1100 600]);
fig.Color = [0.1 0.1 0.1]; 

% --- STATE VARIABLES ---
sim = struct('V', 1.8, 'I_lim', 1.0, 'W', 5, 'H2', 0, 'O2', 0, 'Eff', 1);

% --- INPUT CONTROLS ---
pnl = uipanel(fig, 'Title', 'System Controls', 'Position', [20 20 250 560], 'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'w');

uilabel(pnl, 'Text', 'Voltage (V):', 'Position', [20 500 100 20], 'FontColor', 'w');
uislider(pnl, 'Limits', [0, 3], 'Position', [30 480 190 3], 'Value', sim.V, ...
    'ValueChangingFcn', @(src,event) updateParam('V', event.Value));

uilabel(pnl, 'Text', 'Current Limit (A):', 'Position', [20 400 100 20], 'FontColor', 'w');
uislider(pnl, 'Limits', [0, 3], 'Position', [30 380 190 3], 'Value', 1.5, ...
    'ValueChangingFcn', @(src,event) updateParam('I_lim', event.Value));

uilabel(pnl, 'Text', 'Water Flow (ml/min):', 'Position', [20 300 100 20], 'FontColor', 'w');
uislider(pnl, 'Limits', [0.1, 10], 'Position', [30 280 190 3], 'Value', sim.W, ...
    'ValueChangingFcn', @(src,event) updateParam('W', event.Value));

% --- READOUTS ---
gaugeEff = uigauge(fig, 'linear', 'Position', [300 500 250 60], 'Limits', [0 1], 'Value', 1, 'FontColor', 'w');
lblH2 = uilabel(fig, 'Text', 'H2: 0.00 ml/min', 'Position', [300 440 250 40], 'FontSize', 18, 'FontColor', [0.3 0.6 1]);
lblO2 = uilabel(fig, 'Text', 'O2: 0.00 ml/min', 'Position', [300 400 250 40], 'FontSize', 18, 'FontColor', [0.3 1 0.3]);

% --- PLOT ---
ax = uiaxes(fig, 'Position', [580 80 480 480], 'BackgroundColor', [0 0 0], 'XColor', 'w', 'YColor', 'w');
grid(ax, 'on'); xlabel(ax, 'Time (s)'); ylabel(ax, 'ml/min');
ax.YLim = [0 20]; 
ax.XLim = [0 60]; % Initial window

% INCREASED MaximumNumPoints to 10,000 to prevent premature erasing
hH2 = animatedline(ax, 'Color', [0.3 0.6 1], 'LineWidth', 2, 'MaximumNumPoints', 10000);
hO2 = animatedline(ax, 'Color', [0.3 1 0.3], 'LineWidth', 2, 'MaximumNumPoints', 10000);
legend(ax, {'H2', 'O2'}, 'TextColor', 'w', 'Location', 'northwest');

% --- NESTED FUNCTIONS ---
    function updateParam(field, val)
        sim.(field) = val;
    end

% --- PHYSICS & LOOP ---
F = 96485;
startTime = tic;

while isvalid(fig)
    t = toc(startTime);

    % 1. Calculation
    R = 0.2 + (0.1 / (sim.W + 0.1));
    currentI = (sim.V > 1.23) * min(sim.I_lim, (sim.V - 1.23) / R);

    sim.H2 = (currentI * 60 * 22414) / (2 * F) * 0.98;
    sim.O2 = sim.H2 / 2;
    sim.Eff = (sim.V > 1.48) * (1.48 / max(sim.V, 1.48)) + (sim.V <= 1.48) * 1.0;

    % 2. UI Update
    lblH2.Text = sprintf('H2: %.2f ml/min', sim.H2);
    lblO2.Text = sprintf('O2: %.2f ml/min', sim.O2);
    gaugeEff.Value = sim.Eff;

    % 3. Plot Update
    addpoints(hH2, t, sim.H2);
    addpoints(hO2, t, sim.O2);

    % SCROLLING LOGIC: Keep 60s visible
    if t > 60
        ax.XLim = [t-60, t];
    end

    drawnow limitrate;
    pause(0.05); % 20 FPS is plenty for smooth web viewing
end
end