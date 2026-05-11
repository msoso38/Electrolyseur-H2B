function G2P_Horizon_Gauges()
    % --- UI SETUP ---
    fig = uifigure('Name', 'Horizon PEM G2P Monitor', 'Position', [50 50 1100 680]);
    fig.Color = [0.1 0.1 0.1]; 

    % --- STATE VARIABLES ---
    sim = struct('H2_in', 100, 'O2_in', 50, 'V_load', 0.6, 'W_purge', 5, 'Current', 0, 'Eta', 0);

    % --- INPUT CONTROLS ---
    pnl = uipanel(fig, 'Title', 'System Controls', 'Position', [20 20 280 640], 'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'w');
    
    uilabel(pnl, 'Text', 'H2 Input (ml/min):', 'Position', [20 560 150 20], 'FontColor', 'w');
    uislider(pnl, 'Limits', [0, 500], 'Position', [40 540 200 3], 'Value', sim.H2_in, ...
        'ValueChangingFcn', @(src,event) updateParam('H2_in', event.Value));
    
    uilabel(pnl, 'Text', 'O2 Input (ml/min):', 'Position', [20 460 150 20], 'FontColor', 'w');
    uislider(pnl, 'Limits', [0, 250], 'Position', [40 440 200 3], 'Value', sim.O2_in, ...
        'ValueChangingFcn', @(src,event) updateParam('O2_in', event.Value));

    uilabel(pnl, 'Text', 'Electronic Load (V):', 'Position', [20 360 150 20], 'FontColor', 'w');
    uislider(pnl, 'Limits', [0.1, 1.2], 'Position', [40 320 200 3], 'Value', sim.V_load, ...
        'ValueChangingFcn', @(src,event) updateParam('V_load', event.Value));

    uilabel(pnl, 'Text', 'Water Exit Capacity:', 'Position', [20 260 180 20], 'FontColor', 'w');
    uislider(pnl, 'Limits', [0.1, 10], 'Position', [40 220 200 3], 'Value', sim.W_purge, ...
        'ValueChangingFcn', @(src,event) updateParam('W_purge', event.Value));

    % --- READOUTS & GAUGE ---
    gaugeEta = uigauge(fig, 'linear', 'Position', [330 540 250 60], 'Limits', [0 1], 'Value', 0, 'FontColor', 'w');
    uilabel(fig, 'Text', 'Efficiency (\eta)', 'Position', [410 605 100 20], 'FontColor', 'w', 'HorizontalAlignment', 'center');

    lblAmp = uilabel(fig, 'Text', 'Current: 0.00 A', 'Position', [330 480 250 40], 'FontSize', 20, 'FontColor', [1 0.8 0.3]);
    lblPow = uilabel(fig, 'Text', 'Power: 0.00 W', 'Position', [330 440 250 40], 'FontSize', 20, 'FontColor', [1 0.5 0.5]);
    lblH2O = uilabel(fig, 'Text', 'Water Exit: 0.00 ml/min', 'Position', [330 400 250 30], 'FontSize', 16, 'FontColor', [0.7 0.7 1]);
    
    lblH2Cons = uilabel(fig, 'Text', 'H2 Cons: 0.00 ml/min', 'Position', [330 360 250 30], 'FontSize', 14, 'FontColor', [0.3 0.6 1]);
    lblO2Cons = uilabel(fig, 'Text', 'O2 Cons: 0.00 ml/min', 'Position', [330 330 250 30], 'FontSize', 14, 'FontColor', [0.3 1 0.3]);

    % --- PLOT (Clean - No Eta on Graph) ---
    ax = uiaxes(fig, 'Position', [600 80 460 550], 'BackgroundColor', [0 0 0], 'XColor', 'w', 'YColor', 'w');
    grid(ax, 'on'); xlabel(ax, 'Time (s)'); ylabel(ax, 'Electrical Output');
    ax.YLim = [0 5]; ax.XLim = [0 60];
    
    hAmp = animatedline(ax, 'Color', [1 0.8 0.3], 'LineWidth', 2);
    hPow = animatedline(ax, 'Color', [1 0.5 0.5], 'LineWidth', 2);
    legend(ax, {'Current (A)', 'Power (W)'}, 'TextColor', 'w');

    function updateParam(field, val), sim.(field) = val; end

    % --- PHYSICS ---
    F = 96485;
    V_th = 1.23; 
    startTime = tic;
    
    while isvalid(fig)
        t = toc(startTime);
        
        % Stoichiometry
        I_avail = min((sim.H2_in/22414/60)*2*F, (sim.O2_in/22414/60)*4*F);
        
        % Resistance & Load
        R_int = 0.5 + (2.0 / (sim.W_purge + 0.1)); 
        V_ocv = 1.05; 
        
        if sim.V_load < V_ocv
            I_req = (V_ocv - sim.V_load) / R_int;
            sim.Current = min(I_req, I_avail);
        else
            sim.Current = 0;
        end
        
        % Efficiency & Consumption
        sim.Eta = (sim.Current > 0) * (sim.V_load / V_th);
        p_watts = sim.Current * sim.V_load;
        act_h2 = (sim.Current * 60 * 22414) / (2 * F);
        act_o2 = act_h2 / 2;
        act_h2o = (sim.Current * 60 * 18.015) / (2 * F);

        % UI UPDATES
        gaugeEta.Value = sim.Eta;
        lblAmp.Text = sprintf('Current: %.2f A', sim.Current);
        lblPow.Text = sprintf('Power: %.2f W', p_watts);
        lblH2O.Text = sprintf('Water Exit: %.4f ml/min', act_h2o);
        lblH2Cons.Text = sprintf('H2 Cons: %.2f ml/min', act_h2);
        lblO2Cons.Text = sprintf('O2 Cons: %.2f ml/min', act_o2);
        
        addpoints(hAmp, t, sim.Current);
        addpoints(hPow, t, p_watts);
        
        if t > 60, ax.XLim = [t-60, t]; end
        drawnow limitrate; pause(0.04); 
    end
end