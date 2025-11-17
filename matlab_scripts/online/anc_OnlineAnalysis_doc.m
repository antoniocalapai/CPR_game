function [retval] = anc_OnlineAnalysis(data, values)
disp('Data Flow OK')
% addpath(genpath('/Users/dzingler/ownCloud/Shared/Continous_Psychophisics/matlab_scripts/readData'))
% addpath(genpath('/Users/acalapai/ownCloud/Shared/Continous_Psychophisics/matlab_scripts/readData'))
addpath(genpath('/Users/cnl/Desktop/CPR/matlab_scripts/'))


% List of variables to activate on "EVENTS" in the matlab window
% ML_trialStart
% ML_sync
% TRIAL_outcome
% TRIAL.SC_out
% TRIAL.IO_target_flag1
% TRIAL.IO_target_flag2
% TRIAL.IO_target_flag3
% TRIAL.IO_target_flag4
% EXP_showTarget
% EXP_resetMatlab

%% Read in data
T = MW_readTrial_anc(data);

if strcmp(T.EXP_task.data,'pre-test-SNR')
    if nargin == 1
        clearvars values
        
        values.staircase = [];
        values.trial = [];
        values.outcome = [];
        values.SNR = [];
        values.hr = [];
        values.RT = [];
        values.cursor = [];
        
        
     values.noiselevels = [1 0.95 0.903 0.858 0.815 0.774 0.735 0.698...
                                    0.663 0.63 0.599 0.569 0.541 0.514 0.488...
                                    0.464 0.441 0.419 0.398 0.378 0.359...
                                    0.341 0.324 0.308 0.293 0.278 0.264...
                                    0.251 0.238 0.226 0.215 0.204 0.194...
                                    0.184 0.175 0.166 0.158 0.15 0.143...
                                    0.136 0.129 0.123 0.117 0.111 0.105...
                                    0.1 0.095 0.09];
        values.countNoiseShow = zeros(1,length(values.noiselevels));
        values.countNoiseHit = zeros(1,length(values.noiselevels));
        
%    previous noise level
% values.noiselevels = [0.315 0.299 0.284 0.270 0.256 0.243 0.231...
%             0.220 0.209 0.198 0.188 0.179 0.170 0.161 0.153 0.146 0.138...
%             0.131 0.125 0.118 0.113 0.107 0.102 0.096 0.092 0.087 0.083...
%             0.078 0.074 0.071 0.067 0.064 0.061 0.058 0.055 0.052 0.049...
%             0.047 0.044 0.042 0.040 0.038 0.036 0.034 0.033 0.031 0.029...
%             0.028 0.026 0.025 0.024 0.023 0.021 0.020 0.019 0.018 0.017...
%             0.016 0.015 0.014 0.013 0.012 0.011 0.01];
%         values.countNoiseShow = zeros(1,length(values.noiselevels));
%         values.countNoiseHit = zeros(1,length(values.noiselevels));
        
        close all
        fig = figure;
        set(fig,'position',[844   540   1000   500])
    end
    
    % Staircase output
    values.staircase = [values.staircase, T.SC_out.data];
    values.trial = [values.trial, T.ML_trialStart.data];
    values.outcome = [values.outcome, ...
        strcmp(T.TRIAL_outcome.data, 'hit')];
    
    % Reaction Time
    idx = [sum(T.IO_target_flag1.data) sum(T.IO_target_flag2.data)...
        sum(T.IO_target_flag3.data) sum(T.IO_target_flag4.data)];
    
    TarIDX = 1:4;
    switch TarIDX(idx == 1)
        case(1)
            t2 = T.IO_target_flag1.time(T.IO_target_flag1.data == 1);
        case(2)
            t2 = T.IO_target_flag2.time(T.IO_target_flag2.data == 1);
        case(3)
            t2 = T.IO_target_flag3.time(T.IO_target_flag3.data == 1);
        case(4)
            t2 = T.IO_target_flag4.time(T.IO_target_flag4.data == 1);
    end
    
    t1 = T.EXP_showTarget.time(2);
    values.RT = double([values.RT (t2 - t1)]);
    
    % SNR levels
    idx = T.SC_out.data == values.noiselevels;
    values.countNoiseShow(idx) = values.countNoiseShow(idx) + 1;
    
    if strcmp(T.TRIAL_outcome.data, 'hit')
        values.countNoiseHit(idx) = values.countNoiseHit(idx) + 1;
    end
    
    values.SNR = [values.SNR, T.SC_out.data];
    
    % Hit Rate
    slidingWindow = 5;
    
    if length(values.hr) >= slidingWindow
        values.hr = [values.hr, ...
            sum(values.outcome(end-slidingWindow:end)) / slidingWindow];
    else
        values.hr = [values.hr, ...
            sum(values.outcome) / length(values.outcome)];
    end
    
    
    % Plot Noise staircase
    subplot(2,2,1)
    yyaxis left
    stairs(values.trial, values.staircase, 'LineWidth',1.5)
    ylim([0 1])
    ylabel('SNR')
    xlabel('Trials')
    title('RDP coherence staircase')
    set(gca,'FontSize',12)
    grid on
    if length(values.hr) >= slidingWindow
        yyaxis right
        plot(values.trial,values.hr, 'LineWidth',2);
        ylim([0 1])
        hold on
        x_lim = get(gca,'xlim');
        plot([x_lim(1) x_lim(2)],[0.25 0.25],'r')
        ylabel(['Hit Rate (last 5 trials)'])
        set(gca,'FontSize',12)
        grid on
        hold off
    end
    
    subplot(2,2,2)
    maxRT = 3000000; % 3 second
    %     maxRT = 5000000; % 5 second
    RT = values.RT(values.outcome > 0)/1000;
    RT = RT(RT < maxRT);
    hist(RT)
    hold off
    ylabel('#')
    xlabel('time [ms]')
    title(['Reaction Times, median: ' ...
        int2str(median(RT))])
    set(gca,'FontSize',12)
    grid on
    
    subplot(2,2,3)
    scatter(values.noiselevels, ...
        values.countNoiseHit./values.countNoiseShow, ...
        (values.countNoiseShow+1)*50, 'o')
    ylim([0 1])
    ylabel('Hit Rate')
    xlabel('SNR')
    title('Psychometric Curve')
    set(gca,'FontSize',12)
    set(gca,'xscale','log');
    grid on
    
    subplot(2,2,4)
    RT = values.RT(values.outcome > 0)/1000;
    SNR = values.SNR(values.outcome > 0);
    plot(SNR, RT, 'k*')
    ylim([0 3000])
    ylabel('Reaction Time')
    xlabel('SNR')
    set(gca,'FontSize',12)
    title('RT vs SNR')
    set(gca,'xscale','log');
    grid on
end
%%

%% Read in data

if strcmp(T.EXP_task.data,'pre-test-RT')
    if nargin == 1
        clearvars values
        
        values.staircase = [];
        values.trial = [];
        values.outcome = [];
        values.SNR = [];
        values.hr = [];
        values.RT = [];
        values.cursor = [];
        values.targetX = [];
        values.targetY = [];
        
        close all
        fig = figure;
        set(fig,'position',[844   540   1000   500])
    end
    
    % Staircase output
    values.staircase = [values.staircase, T.SC_out.data];
    values.trial = [values.trial, T.ML_trialStart.data];
    values.outcome = [values.outcome, ...
        strcmp(T.TRIAL_outcome.data, 'hit')];
    
    values.targetX = [values.targetX, T.target_x.data];
    values.targetY = [values.targetY, T.target_y.data];
    

    t2 = T.IO_target_flag.time(T.IO_target_flag.data == 1);                 % target flag ts
    t1 = T.EXP_showTarget.time(2);                                          % targetON ts
    values.RT = [values.RT, double(t2 - t1)];                               % Reaction time
    
    % Hit Rate
    slidingWindow = 5;
    
    if length(values.hr) >= slidingWindow
        values.hr = [values.hr, ...
            sum(values.outcome(end-slidingWindow:end)) / slidingWindow];
    else
        values.hr = [values.hr, ...
            sum(values.outcome) / length(values.outcome)];
    end
    
    subplot(2,2,1:2)
    maxRT = 3000000;                                                        % 3 second
    RT = values.RT(values.outcome > 0)/1000;
    RT = RT(RT < maxRT);
    hist(RT)
    hold off
    ylabel('#')
    xlabel('time [ms]')
    title(['Reaction Times, median: ' ...
        int2str(median(RT))])
    set(gca,'FontSize',12)
    grid on
    
    % Group according to target distance
    values.targetX = abs(values.targetX);
    values.targetY = abs(values.targetY);
    c = 0;
    for iDist = [5 9 12]
        idxX = values.targetX == iDist;
        idxY = values.targetY == iDist;
        
        c = c + 1;
        dist_idx{c} = logical(idxX+idxY);
    end
            
    subplot(2,2,3:4); hold on
    col = {[1 0 0],[0 1 0],[0 0 1]};
    for i = 1:size(dist_idx,2)
        RTd = [];
        RTd = values.RT(dist_idx{i})/1000;
        h = histogram(RTd,10);
        h.FaceColor = col{i};
        h.EdgeColor = col{i};
        h.FaceAlpha = .3;
        h.EdgeAlpha = 0;
    end
    ylim([0 3000])
    xlabel('Reaction Time')
    ylabel('No. Trials')
    set(gca,'FontSize',12)
    title('RT [distance]')
    grid on
    hold off
end
    
%%
if strcmp(T.EXP_task.data,'Steady+Target')
    if nargin == 1
        clearvars values
        values.cursor_angle = [];
        values.cursor_distance = [];
        values.cursor_time = [];
        values.RDP_direction = [];
        values.RDP_coherence = [];
        values.RDP_time = [];
        values.target = [];
        values.outcome = [];
        values.target_flag = [];
        values.RT = [];
        
        close all
        fig = figure;
        set(fig,'position',[844   540   1000   500])
    end
    
    cursor_x = double(T.IO_cursor_x.data);
    cursor_y = double(T.IO_cursor_y.data);
    cursor_t = double(T.IO_cursor_y.time);
    rdp_a = double(T.RDP_direction.data);
    rdp_t = double(T.RDP_direction.time);
    target = double(T.IO_target_shown.data);
    target_t = double(T.IO_target_shown.time);
    
    cursor_d = zeros(1,length(cursor_t));
    for i = 1:length(cursor_t)
        cursor_d(i) = sqrt(cursor_x(i)^2 + cursor_y(i)^2);
    end
    
    cursor_a = mod(atan2(1,0)-atan2(cursor_y, cursor_x),2*pi)*180.0/3.14;
    
    values.cursor_distance = [values.cursor_distance, cursor_d];
    values.cursor_angle = [values.cursor_angle, cursor_a];
    values.cursor_time = [values.cursor_time, cursor_t];
    values.RDP_direction = [values.RDP_direction, rdp_a];
    values.RDP_time = [values.RDP_time, rdp_t];
    values.target = [values.target, target_t(target == 1)];
    
    if strcmp(T.TRIAL_outcome.data, 'hit') 
        values.outcome = [values.outcome, 1];
        target_flag = double(T.IO_target_flag.data);
        target_flag_t = double(T.IO_target_flag.time);
        
        values.target_flag = [values.target_flag, ...
            target_flag_t(target_flag == 1)];
        
        t1 = values.target(end);
        t2 = values.target_flag(end);
        values.RT = double([values.RT (t2 - t1)]);
        
    elseif strcmp(T.TRIAL_outcome.data, 'mis')
        values.outcome = [values.outcome, 0];
        
    end
    
    %
    subplot(3,2,1)
    bar([sum(values.outcome)/length(values.outcome), ...
        sum(values.outcome == 0)/length(values.outcome)])
    xticklabels({'hit','mis'})
    set(gca,'FontSize',12)
    title('Performance')
    
    %
    subplot(3,2,2)
    hist(values.RT / 1000)
    title('Reaction Time')
    set(gca,'FontSize',12)
    title('Reaction Time')
    
    %
    subplot(3,2,[3 4])
    stairs((values.RDP_time - values.cursor_time(1))/1e+6, ...
        mod(values.RDP_direction,360), 'b','LineWidth',1.5)
    hold on
    plot((values.cursor_time - values.cursor_time(1))/1e+6, ...
        values.cursor_angle, 'r','LineWidth',1.5)
    for i = 1:length(values.target)
        line([(values.target(i) - values.cursor_time(1))/1e+6 ...
              (values.target(i) - values.cursor_time(1))/1e+6], ...
              [0 400])
        %xline((values.target(i) - values.cursor_time(1))/1e+6, ':g', 'LineWidth',2);
    end
    grid on
    legend({'RDP','Mouse', 'TargetON'},'Location','northwest')
    xlabel('')
    xticklabels('')
    xlim([0 inf])
    ylabel('Angle [deg]')
    set(gca,'FontSize',12)
    hold off
    
    %
    subplot(3,2,[5 6])
    plot((values.cursor_time - values.cursor_time(1))/1e+6,...
        values.cursor_distance/8,'LineWidth',2)
    title('Cursor distance')
    hold on
    for i = 1:length(values.target)
        %xline((values.target(i) - values.cursor_time(1))/1e+6, ':g', 'LineWidth',2);
        %yline(8, '--k', 'LineWidth',2);
        line([(values.target(i) - values.cursor_time(1))/1e+6 ...
              (values.target(i) - values.cursor_time(1))/1e+6], ...
              [0 1.3])
    end
    hold off
    grid on
    
end

if strcmp(T.EXP_task.data,'Switch+Target')
    
end

retval = values;
end
