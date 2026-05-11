function UniversalPEMApp()
    % --- INITIALIZE INTERFACE ---
    fig = uifigure('Name', 'Horizon Universal PEM: Electrolyzer & Fuel Cell', 'Position', [50 50 1000 600]);
    
    % --- SHARED STATE ---
    sim = struct('Running', true, 'Mode', 'Electrolyzer'); 
    
    % --- CONTROL PANEL (Left) ---
    pnl = uipanel(fig, 'Title', 'System Inputs', 'Position', [20 20 280 560]);
    
    % Mode Switch
    uilabel(pnl, 'Text', 'Operating Mode:', 'Position', [20 510 100 20]);
    sw = uiswitch(pnl, 'Items', {'Electrolyzer', 'Fuel Cell'}, 'Position', [150 510 60 20], ...
        'ValueChangedFcn', @(src,event) modeChange(src));

    % Knobs for precise control
    uilabel(pnl, 'Text', 'Input/Target Voltage (V):', 'Position', [20 440 200 20]);
    knobV = uiknob(pnl, 'continuous', 'Limits', [0 3], 'Position', [100 360 80 80], 'Value', 1.8);

    uilabel(pnl, 'Text', 'Max Intensity (A):', 'Position', [20 280 150 20]);
    sldI = uislider(pnl, 'Limits', [0, 3], 'Position', [40 260 200 3], 'Value', 1.5);
    
    uilabel(pnl, 'Text', 'Max Water/Gas Flow:', 'Position', [20 180 150 20]);
    sldF = uislider(pnl, 'Limits', [0.1, 10], 'Position', [40 160 200 3], 'Value', 5);

    btnStop = uibutton(pnl, 'Text', 'Emergency Shutdown', 'Position', [50 40 180 40], ...
        'BackgroundColor', [0.8 0.2 0.2], 'FontColor', 'w', 'ButtonPushedFcn', @(btn,event) stopSim());

    % --- PLOT AREA (Right) ---
    axV = uiaxes(fig, 'Position', [330 320 630 240]);
    title(axV, 'Electrical Performance (V-I)'); grid(axV, 'on'); hold(axV, 'on');
    
    axG = uiaxes(fig, 'Position', [330 40 630 240]);
    title(axG, 'Gas Flow Rates (H2 & O2)'); ylabel(axG, 'sccm'); grid(axG, 'on'); hold(axG, 'on');

    hV = animatedline(axV, 'Color', 'k', 'LineWidth', 1.5);
    hH2 = animatedline(axG, 'Color', 'blue', 'LineWidth', 2, 'DisplayName', 'H2');
    hO2 = animatedline(axG, 'Color', 'green', 'LineWidth', 2, 'DisplayName', 'O2');
    legend(axG, 'Location', 'northwest');

    % --- CONSTANTS ---
    F = 96485;      % Faraday
    n = 1;          % Number of cells
    R_ohm = 0.2;    % Internal resistance

    startTime = tic;

    % --- MAIN DYNAMIC LOOP ---
    while sim.Running
        t = toc(startTime);
        
        % 1. Get Inputs
        V_in = knobV.Value;
        I_max = sldI.Value;
        Flow_max = sldF.Value;
        
        if strcmp(sim.Mode, 'Electrolyzer')
            % V_in pushes the reaction. Calculate resulting Current (I)
            % Simplified: I = (V_in - V_rev) / R
            V_rev = 1.23;
            if V_in > V_rev
                currentI = min(I_max, (V_in - V_rev) / R_ohm);
            else
                currentI = 0;
            end
            
            % Outflow (Gas)
            H2_out = (currentI / (2*F)) * 60 * 22400; % Convert to sccm
            O2_out = H2_out / 2;
            
        else % FUEL CELL MODE
            % V_in is the target load. If V_in < V_rev, Current flows OUT.
            V_rev = 1.1; % Fuel cell reversible voltage is lower due to losses
            if V_in < V_rev
                currentI = min(I_max, (V_rev - V_in) / R_ohm);
            else
                currentI = 0;
            end
            
            % Inflow (Consuming Gas)
            H2_out = -(currentI / (2*F)) * 60 * 22400; % Negative means consumption
            O2_out = H2_out / 2;
        end
        
        % 2. Safety / Flow Limiter
        if abs(H2_out) > Flow_max * 10
             H2_out = sign(H2_out) * Flow_max * 10;
             O2_out = H2_out / 2;
        end

        % 3. Update Plots
        addpoints(hV, t, V_in);
        addpoints(hH2, t, H2_out);
        addpoints(hO2, t, O2_out);
        
        axV.XLim = [max(0, t-20), t+2];
        axG.XLim = [max(0, t-20), t+2];
        
        drawnow;
        pause(0.1);
    end

    function modeChange(src)
        sim.Mode = src.Value;
        clearpoints(hV); clearpoints(hH2); clearpoints(hO2);
    end

    function stopSim()
        sim.Running = false;
        delete(fig);
    end
end