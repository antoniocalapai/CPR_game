file = 'joy2.mwk';
[~, trialParam] = MW_readExperiment(file);

T = table();
for i = 1:length(trialParam)
    if not(isempty(MW_getStimData('target', 'action', trialParam(i))))
        temp = [];
        
        temp.joy_x = {double(trialParam(i).IO_joystick_x_calib.data) * -10};
        temp.joy_y = {double(trialParam(i).IO_joystick_y_calib.data) * 10};
        temp.trial_t = {1:length(temp.joy_x{:})};
                
        [coh, c_time] = MW_getStimData('RDP', 'coherence', trialParam(i));
        coh = double([coh{:}]);
        
        temp.target_x = cell2mat(MW_getStimData('target', 'pos_x', trialParam(i)));
        temp.target_y = cell2mat(MW_getStimData('target', 'pos_y', trialParam(i)));
        
        [~, target_time] = MW_getStimData('target', 'action', trialParam(i));
        temp.target_t = double((target_time(1) - trialParam(i).ML_trialStart.time)/ 1000);
        
        if strcmp(trialParam(i).TRIAL_outcome.data,'hit')
            temp.outcome = 1;
        else
            temp.outcome = 0;
        end
        
        temp.coherence = coh(coh > 0);
        temp.trial = i;
        
        temp.trialStart = trialParam(i).ML_trialStart.time;
        temp.trialEnd = trialParam(i).ML_trialEnd.time;
        temp.trial_lenght = (trialParam(i).ML_trialEnd.time -...
            trialParam(i).ML_trialStart.time) / 1000;
        
        if not(isempty(trialParam(i).IO_rewardA))
            temp.reward = (trialParam(i).IO_rewardA.time - ...
                trialParam(i).ML_trialStart.time) / 1000;
        else
            temp.reward = NaN;
        end
        
        % Calculating euclidian distance between joystick and target
        dis = zeros(1,length(temp.joy_x{1,1}));
        for j = 1:length(temp.joy_x{1,1})
            dis(j) = pdist([temp.joy_x{1,1}(j),temp.joy_y{1,1}(j);...
                temp.target_x,temp.target_y],'euclidean');
        end
        
        temp.EuclDist = {dis};
        
        % Append to Table with all trials
        T = [T;struct2table(temp)];
        
    end
end

%% Plotting and data analysis is done with GRAMM
clear g
figure
g = gramm('x', T.trial_t, 'y', T.EuclDist, 'lightness',T.coherence, 'subset', T.outcome == 1);
g.set_color_options('hue_range',[-60 60],'chroma',80,'lightness',90)
g.set_names('x','Time After Stimulus Onset [ms]','y','Distance [deg]','lightness','SNR ');
g.geom_line()
g.geom_vline('x',mean(T.target_t))
g.draw()

% %% Non GRAMM plotting
% figure
% colors = T.coherence - (min(T.coherence) - 0.01);
% colors = colors ./max(colors);
% 
% for i = 1:length(T.EuclDist)
%     if T.outcome(i)
%         plot(T.EuclDist{i}(T.target_t(i)-4000:end),...
%             'linewidth',1, 'Color',[0 colors(i) 0])
%         hold on
%     end
% end