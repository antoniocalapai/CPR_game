% Timeline of the entire session for each subject


cd('/Users/dzingler/ownCloud/Shared/Continous_Psychophisics/matlab_scripts')
addpath(genpath('./readData'))
SESSION_list = dir(['./test_data/' '*.mwk']);


for j = 1:length(SESSION_list)
    filename = ['./test_data/' SESSION_list(j).name];
    load([filename '/' SESSION_list(j).name '.mat'])
    
    %% Mouse Information
    mouse_x = data.valueNUM(data.action == data.codecCode(strcmp(data.codecName, 'IO_cursor_x')));
    mouse_y = data.valueNUM(data.action == data.codecCode(strcmp(data.codecName, 'IO_cursor_y')));
    mouse_t = data.timestamp(data.action == data.codecCode(strcmp(data.codecName, 'IO_cursor_x')));
    mouse_angle = mod(atan2(1,0)-atan2(mouse_y, mouse_x),2*pi)*180.0/3.14;
    
    mouse_d = [];
    for m = 1:length(mouse_t)
        mouse_d(m) = sqrt(mouse_x(m)^2 + mouse_y(m)^2);
    end
    
    %% Trial information
    trialStart = data.timestamp(data.action == data.codecCode(strcmp(data.codecName, 'ML_trialStart')));
    trialEnd = data.timestamp(data.action == data.codecCode(strcmp(data.codecName, 'ML_trialEnd')));
    
    %% Target Information
    target = data.valueNUM(data.action == data.codecCode(strcmp(data.codecName, 'IO_target_ON')));
    target_t = data.timestamp(data.action == data.codecCode(strcmp(data.codecName, 'IO_target_ON')));
    target_ON = target_t(target == 1);
    
    %% Trial outcome
    outcome = data.valueCHAR(data.action == data.codecCode(strcmp(data.codecName, 'TRIAL_outcome')));
    outcome_t = data.timestamp(data.action == data.codecCode(strcmp(data.codecName, 'TRIAL_outcome')));
    
    %% RDP information
    rdp_direction = data.valueNUM(data.action == data.codecCode(strcmp(data.codecName, 'RDP_direction')));
    rdp_coherence = data.valueNUM(data.action == data.codecCode(strcmp(data.codecName, 'RDP_coherence')));
    rdp_t = data.timestamp(data.action == data.codecCode(strcmp(data.codecName, 'RDP_direction')));
    
    %% Session information
    session_duration = (mouse_t(end) - mouse_t(1)) / 1e+6;
    trials_duration = diff(trialStart);
    
    frames = data.valueNUM(data.action == data.codecCode(strcmp(data.codecName, 'EXP_shiftFrames')));
    stepsize = data.valueNUM(data.action == data.codecCode(strcmp(data.codecName, 'EXP_stepsize')));
    switchtype = data.valueNUM(data.action == data.codecCode(strcmp(data.codecName, 'EXP_shiftType')));
    
    frames = frames(frames > 0);
    stepsize = stepsize(stepsize > 0)/3;
    switchtype = switchtype(switchtype > 0);
    
    %% Plotting session timeline
    fig = figure;
    set(fig,'position',[1   1   1871   620])
    subplot(3,10,[1 10])
    plot((rdp_t - mouse_t(1))/1e+6, mod(rdp_direction,360), 'b','LineWidth',1.5)
    hold on
    plot((mouse_t - mouse_t(1))/1e+6, mouse_angle, 'r','LineWidth',1.5)
    for i = 1:length(target_ON)
        xline((trialStart(i) - mouse_t(1))/1e+6,':k','LineWidth',2);
        xline((target_ON(i) - mouse_t(1))/1e+6, ':g', 'LineWidth',2);
    end    
    grid on
    legend({'RDP','Mouse', 'TrialStart', 'TargetON'})
    xlim([0 inf])
    xlabel('Time from session start [sec]')
    ylabel('Angle [deg]')
    title(['Session Timeline ' SESSION_list(j).name],'Interpreter', 'none')
    set(gca,'FontSize',12)
    
    % Plot section of session
    subplot(3,10,[11 15])
    plot((rdp_t - mouse_t(1))/1e+6, mod(rdp_direction,360), 'b','LineWidth',1.5)
    hold on
    plot((mouse_t - mouse_t(1))/1e+6, mouse_angle, 'r','LineWidth',1.5)
    for i = 1:length(target_ON)
        xline((trialStart(i) - mouse_t(1))/1e+6,':k','LineWidth',2);
        xline((target_ON(i) - mouse_t(1))/1e+6, ':g', 'LineWidth',2);
    end    
    grid on
    xlim([(mouse_t(100) - mouse_t(1))/1e+6 (mouse_t(3000) - mouse_t(1))/1e+6])
    xlabel('Time [sec]')
    ylabel('Angle [deg]')
    title('Splice of 1 minute at mid session')
    set(gca,'FontSize',12)
    
    % Plot distance from center
    subplot(3,10,[21 25])
    plot((mouse_t - mouse_t(1))/1e+6, mouse_d, 'k','LineWidth',1.5)
    hold on
    for i = 1:length(target_ON)
        xline((trialStart(i) - mouse_t(1))/1e+6,':k','LineWidth',2);
        xline((target_ON(i) - mouse_t(1))/1e+6, ':g', 'LineWidth',2);
    end
    grid on
    legend({'Dist. 0','TrialStart', 'TargetON'})
    xlim([(mouse_t(100) - mouse_t(1))/1e+6 (mouse_t(3000) - mouse_t(1))/1e+6])
    xlabel('Time [sec]')
    ylabel('Angle [deg]')
    title('Euclidean Distance of mouse from center of RDP')
    set(gca,'FontSize',12)
    hold off
    
    %% Plot trials duration
    subplot(3,10,[16 17, 26 27])
    histogram(trials_duration/1e+6,'BinMethod','fd')
    YL = get(gca,'ylim');
    XL =  get(gca,'xlim');
    text(XL(2)/2,YL(2)/2,...
        ['Total (min) ' num2str(session_duration/60)],'FontSize',12)
    xlabel('Time [sec]')
    ylabel('#')
    title('Trial duration')
    set(gca,'FontSize',12)
    grid on
    
    % Plot Noise staircase
    subplot(3,10,[18 19, 28 29])
    stairs(rdp_coherence(rdp_coherence > 0), 'LineWidth',1.5)
    ylim([0 0.5])
    ylabel('SNR')
    xlabel('Trials')
    title('RDP coherence staircase')
    set(gca,'FontSize',12)
    grid on
    
    % Plot hit vs mis
    outcome = outcome(~cellfun('isempty',outcome));
    a = unique(outcome,'stable');
    b = cell2mat(cellfun(@(x) sum(ismember(outcome,x)),a,'un',0));
        
    subplot(3,10,[20 30])
    bar(b(2:3)./sum(b(2:3)),'r')
    text(1,0.95,['Trials = ' num2str(sum(b(2:3)))],'FontSize',12)
    xticklabels({'hit','mis'})
    ylim([0 1])
    ylabel('%')
    title('Outcome')
    set(gca,'FontSize',12)
    grid on
    
    saveas(gcf,SESSION_list(j).name(1:end-4),'epsc')
end


