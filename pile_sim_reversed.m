function G2P_Horizon_Final()
    % --- CONFIGURATION DE L'INTERFACE ---
    fig = uifigure('Name', 'Horizon G2P : Monitor Pro', 'Position', [50 50 1100 680]);
    fig.Color = [0.1 0.1 0.1]; 

    % --- VARIABLES D'ÉTAT ---
    sim = struct('H2_in', 50, 'O2_in', 25, 'V_load', 0.6, 'W_purge', 5, 'Current', 0, 'Eta', 0);

    % --- PANNEAU DE CONTRÔLE ---
    pnl = uipanel(fig, 'Title', 'Entrées Gaz & Charge', 'Position', [20 20 280 640], 'BackgroundColor', [0.2 0.2 0.2], 'ForegroundColor', 'w');
    
    uilabel(pnl, 'Text', 'Entrée H2 (ml/min):', 'Position', [20 560 150 20], 'FontColor', 'w');
    uislider(pnl, 'Limits', [0, 100], 'Position', [40 540 200 3], 'Value', sim.H2_in, ...
        'ValueChangingFcn', @(src,event) updateParam('H2_in', event.Value));
    
    uilabel(pnl, 'Text', 'Entrée O2 (ml/min):', 'Position', [20 460 150 20], 'FontColor', 'w');
    uislider(pnl, 'Limits', [0, 100], 'Position', [40 440 200 3], 'Value', sim.O2_in, ...
        'ValueChangingFcn', @(src,event) updateParam('O2_in', event.Value));

    uilabel(pnl, 'Text', 'Charge Électronique (V):', 'Position', [20 360 150 20], 'FontColor', 'w');
    uislider(pnl, 'Limits', [0.1, 1.2], 'Position', [40 320 200 3], 'Value', sim.V_load, ...
        'ValueChangingFcn', @(src,event) updateParam('V_load', event.Value));

    uilabel(pnl, 'Text', 'Purge Eau (Sortie):', 'Position', [20 260 180 20], 'FontColor', 'w');
    uislider(pnl, 'Limits', [0.1, 10], 'Position', [40 220 200 3], 'Value', sim.W_purge, ...
        'ValueChangingFcn', @(src,event) updateParam('W_purge', event.Value));

    % --- AFFICHAGE DES DONNÉES & JAUGE ---
    gaugeEta = uigauge(fig, 'linear', 'Position', [330 540 250 60], 'Limits', [0 1], 'Value', 0, 'FontColor', 'w');
    uilabel(fig, 'Text', 'Rendement (\eta)', 'Position', [410 605 100 20], 'FontColor', 'w', 'HorizontalAlignment', 'center');

    lblAmp = uilabel(fig, 'Text', 'Courant: 0.00 A', 'Position', [330 480 250 40], 'FontSize', 20, 'FontColor', [1 0.8 0.3]);
    lblPow = uilabel(fig, 'Text', 'Puissance: 0.00 W', 'Position', [330 440 250 40], 'FontSize', 20, 'FontColor', [1 0.5 0.5]);
    lblH2O = uilabel(fig, 'Text', 'Eau Sortie: 0.00 ml/min', 'Position', [330 400 250 30], 'FontSize', 16, 'FontColor', [0.7 0.7 1]);
    
    lblH2Cons = uilabel(fig, 'Text', 'Consommation H2: 0.00 ml/min', 'Position', [330 360 250 30], 'FontSize', 14, 'FontColor', [0.3 0.6 1]);
    lblO2Cons = uilabel(fig, 'Text', 'Consommation O2: 0.00 ml/min', 'Position', [330 330 250 30], 'FontSize', 14, 'FontColor', [0.3 1 0.3]);

    % --- GRAPHIQUE (Historique Permanent) ---
    ax = uiaxes(fig, 'Position', [600 80 460 550], 'BackgroundColor', [0 0 0], 'XColor', 'w', 'YColor', 'w');
    grid(ax, 'on'); xlabel(ax, 'Temps (s)'); ylabel(ax, 'Sortie Électrique');
    ax.YLim = [0 2]; % Adapté à la puissance d'un petit kit Horizon
    ax.XLim = [0 60]; 
    
    hAmp = animatedline(ax, 'Color', [1 0.8 0.3], 'LineWidth', 2);
    hPow = animatedline(ax, 'Color', [1 0.5 0.5], 'LineWidth', 2);
    legend(ax, {'Courant (A)', 'Puissance (W)'}, 'TextColor', 'w');

    function updateParam(field, val), sim.(field) = val; end

    % --- BOUCLE PHYSIQUE ---
    F = 96485;
    V_th = 1.23; 
    startTime = tic;
    
    while isvalid(fig)
        t = toc(startTime);
        
        % Calcul de la disponibilité des gaz (Stœchiométrie)
        I_avail = min((sim.H2_in/22414/60)*2*F, (sim.O2_in/22414/60)*4*F);
        
        % Résistance interne typique d'une cellule Horizon
        R_int = 0.8 + (1.5 / (sim.W_purge + 0.1)); 
        V_ocv = 1.02; 
        
        % Calcul du courant selon la charge
        if sim.V_load < V_ocv
            I_req = (V_ocv - sim.V_load) / R_int;
            sim.Current = min(I_req, I_avail);
        else
            sim.Current = 0;
        end
        
        % Rendement, Puissance et Consommation
        sim.Eta = (sim.Current > 0) * (sim.V_load / V_th);
        p_watts = sim.Current * sim.V_load;
        act_h2 = (sim.Current * 60 * 22414) / (2 * F);
        act_o2 = act_h2 / 2;
        act_h2o = (sim.Current * 60 * 18.015) / (2 * F);

        % MISE À JOUR UI
        gaugeEta.Value = sim.Eta;
        lblAmp.Text = sprintf('Courant: %.2f A', sim.Current);
        lblPow.Text = sprintf('Puissance: %.2f W', p_watts);
        lblH2O.Text = sprintf('Eau Sortie: %.4f ml/min', act_h2o);
        lblH2Cons.Text = sprintf('Consommation H2: %.2f ml/min', act_h2);
        lblO2Cons.Text = sprintf('Consommation O2: %.2f ml/min', act_o2);
        
        % Tracé permanent (Infinite Trace)
        addpoints(hAmp, t, sim.Current);
        addpoints(hPow, t, p_watts);
        
        if t > 60, ax.XLim = [t-60, t]; end
        drawnow limitrate; pause(0.04); 
    end
end