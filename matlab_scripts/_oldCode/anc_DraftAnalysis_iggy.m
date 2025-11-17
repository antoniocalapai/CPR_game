function [trials, hits] = anc_DraftAnalysis_iggy(file,plotit)

% clear all
% file = 'igg_20191106_1103_XBI13_JMotion_FollowRDP_4R.mwk'; plotit = 1;
% file = 'joyTest.mwk';

DATA_dir = '/Volumes/weco/Joystick_XBI/data/iggy/';
session = [DATA_dir file];

[~, trialParam] = MW_readExperiment(session);

% [~, trialParam] = MW_readExperiment(file);

for tr = 1:length(trialParam)
    [target_dir, target_time] = MW_getStimData('RDP_target', 'direction', trialParam(tr));
    
    target_time = double(target_time)./1000;
    
    joy_dir = double([trialParam(tr).IO_joystick_direction.data{1:end}]);
    joy_str = double([trialParam(tr).IO_joystick_strength.data{1:end}]);
    joy_time = double([trialParam(tr).IO_joystick_direction.time]./1000);
    hit = double([trialParam(tr).IO_rewardA.data]);
    hit_time = double([trialParam(tr).IO_rewardA.time]./1000);
    hit = hit > 0;
    hit_time = hit_time(hit>0);
    
    for i = 1:length(joy_time)
        %disp(length(joy_time)-i)
        
        rew = [];
        if ~isempty(trialParam(tr).IO_rewardA)
            for rr = 1:length(trialParam(tr).IO_rewardA.data)
                if trialParam(tr).IO_rewardA.data(rr) > 0
                    rew(end+1) = trialParam(tr).IO_rewardA.time(rr)/1000;
                end
            end
        end
        
        pos = target_dir(target_time < joy_time(i));
        
        if ~isempty(pos)
            if ~isempty(pos{1,end})
                TAR(i) = mod(round(pos{end}),360);
            else
                TAR(i) = nan;
            end
        end
    end
    
    rew_time = [];
    for ll = 1:length(rew)
        rew_time(ll) = sum(joy_time < rew(ll));
    end
    
    if plotit
        fig = figure('rend','painters','pos',[2049 355 1279 250]);
        %subplot(length(trialParam), 1, tr)
        difference = 180 - abs(abs(joy_dir - TAR) - 180);
        plot(joy_dir,'LineWidth',2)
        hold on
        plot(TAR(1:length(joy_dir)),'LineWidth',2)
        plot(difference,'LineWidth',2)
        
        y = ylim; % current y-axis limits
        for pl = 1:length(rew_time)
            plot([rew_time(pl) rew_time(pl)],[y(1) y(2)], 'LineStyle',':','Color','k','LineWidth',2)
        end
        
        legend('Joystick', 'Target', 'reward')
        hold off
        set(gca,'FontSize',22)
        
        xlabel('Time[ms]')
        ylabel('motion[deg]')
        hold off
    end
    
    temp = target_dir(2:end);
    alltargets = unique(mod(cell2mat(temp),360));
    figure
    for k = 1:length(alltargets)
        for j = 1:length(target_dir)-1
            if target_dir{j} == alltargets(k)
                onset = target_time(j);
                offset = target_time(j+1);
                sampleLenght = round(offset - onset);
                
                if sampleLenght > 1500
                    J = joy_dir(joy_time < offset & joy_time > onset);
                    T = mod(target_dir{j},360);
                    
                    difference = 180 - abs(abs(J - T) - 180);
                    
                    if sum(hit_time > onset & hit_time < offset)
                        subplot(length(alltargets)/2,length(alltargets)/2,k)
                        plot(smoothdata(difference(1:1500)),'black')
                    else
                        subplot(length(alltargets)/2,length(alltargets)/2,k)
                        plot(smoothdata(difference(1:1500)),'red')
                    end
                    hold on
                end
            end
        end        
        title(alltargets(k))        
    end
    hold off
    
end

trials = length(trialParam);
hits = length(rew);
end