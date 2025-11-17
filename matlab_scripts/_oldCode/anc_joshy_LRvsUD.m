%%%%%%%%%%%
clear all %
close all %
%%%%%%%%%%%

addpath(genpath(('/Volumes/weco/Joystick_XBI/Analysis')))

DATA_dir = '/Volumes/weco/Joystick_XBI/data/joshi/';
plot_path = '/Volumes/weco/Joystick_XBI/Analysis/plots/';
SESSION_list = dir([DATA_dir '*.mwk']);

STEP_LR = [];
TRIAL_LR = [];
SESS_LR = [];
prev_trials_LR = 0;
curr_trials_LR = 0;

STEP_UD = [];
TRIAL_UD = [];
SESS_UD = [];
prev_trials_UD = 0;
curr_trials_UD = 0;

TOT = [];
TYPE = [];
sessions = [];
RT = [];

for i = 1:length(SESSION_list)
    
    total_trials = 0;
    
    if not(isempty(strfind(SESSION_list(i).name, 'left_right')))
        [~, trialParam] = MW_readExperiment([DATA_dir SESSION_list(i).name]);
        TYPE{i} = 'LR';
        
        for j = 1:length(trialParam)
            if not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'wrong'))) || ...
                    not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'hitCorrect'))) || ...
                    not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'Correct')))
                
                total_trials = total_trials + 1;
                RT(i).ses(j) = double((trialParam(j).TRIAL_outcome.time(1)-trialParam(j).ML_trialStart.time) /1000);
                RT(i).idx{j} = trialParam(j).TRIAL_outcome.data(1:3);
                
                [~, tg] = MW_getStimData('RDP', 'action', trialParam(j));
                RT(i).sti(j) = double((tg - trialParam(j).ML_trialStart.time)/1000);
                
            end
            
            if not(isempty(trialParam(j).SC_out))
                STEP_LR = [STEP_LR trialParam(j).SC_out.data];
                TRIAL_LR = [TRIAL_LR (j + prev_trials_LR)];
                curr_trials_LR = curr_trials_LR + 1;
            end
        end
        TOT(i) = total_trials;
        SESS_LR = [SESS_LR ones(1,curr_trials_LR)*i];
        prev_trials_LR = prev_trials_LR + length(trialParam);
        curr_trials_LR = 0;
        
    elseif not(isempty(strfind(SESSION_list(i).name, 'up_down')))
        [~, trialParam] = MW_readExperiment([DATA_dir SESSION_list(i).name]);
        TYPE{i} = 'UD';
        
        for j = 1:length(trialParam)
            if not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'wrong'))) || ...
                    not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'hitCorrect'))) || ...
                    not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'Correct')))
                
                total_trials = total_trials + 1;
                RT(i).ses(j) = double((trialParam(j).TRIAL_outcome.time(1)-trialParam(j).ML_trialStart.time) /1000);
                RT(i).idx{j} = trialParam(j).TRIAL_outcome.data(1:3);
                
                [~, tg] = MW_getStimData('RDP', 'action', trialParam(j));
                RT(i).sti(j) = double((tg - trialParam(j).ML_trialStart.time)/1000);
            end
            if not(isempty(trialParam(j).SC_out))
                STEP_UD = [STEP_UD trialParam(j).SC_out.data];
                TRIAL_UD = [TRIAL_UD (j + prev_trials_UD)];
                curr_trials_UD = curr_trials_UD + 1;
            end
        end
        
        TOT(i) = total_trials;
        SESS_UD = [SESS_UD ones(1,curr_trials_UD)*i];
        prev_trials_UD = prev_trials_UD + length(trialParam);
        curr_trials_UD = 0;
        
    elseif not(isempty(strfind(SESSION_list(i).name, 'fullRange')))
        [~, trialParam] = MW_readExperiment([DATA_dir SESSION_list(i).name]);
        TYPE{i} = 'FR';
        
        for j = 1:length(trialParam)
            if not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'wrong'))) || ...
                    not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'hitCorrect'))) || ...
                    not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'Correct')))
                
                total_trials = total_trials + 1;
                RT(i).ses(j) = double((trialParam(j).TRIAL_outcome.time(1)-trialParam(j).ML_trialStart.time) /1000);
                RT(i).idx{j} = trialParam(j).TRIAL_outcome.data(1:3);
                
                [~, tg] = MW_getStimData('RDP', 'action', trialParam(j));
                RT(i).sti(j) = double((tg - trialParam(j).ML_trialStart.time)/1000);
            end
        end
        TOT(i) = total_trials;
        
    elseif not(isempty(strfind(SESSION_list(i).name, '4R')))
        [~, trialParam] = MW_readExperiment([DATA_dir SESSION_list(i).name]);
        TYPE{i} = '4R';
        for j = 1:length(trialParam)
            if not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'wrong'))) || ...
                    not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'hitCorrect'))) || ...
                    not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'Correct')))
                
                total_trials = total_trials + 1;
                RT(i).ses(j) = double((trialParam(j).TRIAL_outcome.time(1)-trialParam(j).ML_trialStart.time) /1000);
                RT(i).idx{j} = trialParam(j).TRIAL_outcome.data(1:3);
                
                [~, tg] = MW_getStimData('RDP', 'action', trialParam(j));
                RT(i).sti(j) = double((tg - trialParam(j).ML_trialStart.time)/1000);
                
                [mt, ~] = MW_getStimData('RDP', 'direction', trialParam(j));
                RT(i).mot(j) = cell2mat(mt);
            end
        end
        TOT(i) = total_trials;
    
    else
        [~, trialParam] = MW_readExperiment([DATA_dir SESSION_list(i).name]);
        TYPE{i} = 'NN';
        for j = 1:length(trialParam)
            if not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'wrong'))) || ...
                    not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'hitCorrect'))) || ...
                    not(isempty(strfind(trialParam(j).TRIAL_outcome.data,'Correct')))
                
                total_trials = total_trials + 1;
                RT(i).ses(j) = double((trialParam(j).TRIAL_outcome.time(1)-trialParam(j).ML_trialStart.time) /1000);
                RT(i).idx{j} = trialParam(j).TRIAL_outcome.data(1:3);
                
                [~, tg] = MW_getStimData('RDP', 'action', trialParam(j));
                RT(i).sti(j) = double((tg - trialParam(j).ML_trialStart.time)/1000);
            end
        end
        TOT(i) = total_trials;
    end
end

%% Staircase Left Right vs Up Down
fig = figure('rend','painters','pos',[465 111 1053 854]);
CHANCE = (STEP_LR / 360) * 100;
yaxis = [2 5 10 20 30 40 50 60 70 80 85 90 100 110 120 130 140 150 160 170];
h = stairs(TRIAL_LR, STEP_LR, '-..');
h(1).MarkerSize = 20;
hold on
f = stairs(TRIAL_UD, STEP_UD, '-..r');
f(1).MarkerSize = 20;
set(gca, 'YDir','reverse')
xlabel('Trials','FontSize',30)
ylabel('Range','FontSize',30)
yticks([unique(STEP_LR)])
%ylim([0 180])
grid on
legend('Left/Right (first)','Up/Down (second)','Location','southeast','FontSize',30)
title("Joshi - joystick staircase",'FontSize',30)

name = ([plot_path 'anc_joshi_stcs']);
saveas(fig,name,'png')


%% HIT RATE vs SESSION
fig = figure('rend','painters','pos',[465 111 1053 854]);
bar(TOT)
xticks([1:length(TOT)])
set(gca,'xticklabel',TYPE)
xlabel('Session','FontSize',30)
ylabel('Trials','FontSize',30)
grid on
title("Joshi - joystick staircase - total trials across sessions",'FontSize',30)

name = ([plot_path 'anc_joshi_tot']);
saveas(fig,name,'png')

%% Reaction time
fig = figure('rend','painters','pos',[465 111 2000 1000]);
for i = 1:length(SESSION_list)
    
    subplot(2,ceil(length(SESSION_list)/2),i)
    hold on
    histogram(RT(i).ses(strcmp(RT(i).idx,'hit'))/1000,30)
    histogram(RT(i).ses(strcmp(RT(i).idx,'wro'))/1000,30)
    %line([TUNING.direction.spiral.bestdelay(2) TUNING.direction.spiral.bestdelay(2)],ylim,'LineStyle',':','Color','m','LineWidth',4)
    
    if i == length(SESSION_list)
        legend({'hit','wro'},'FontSize',20)
        xlabel('seconds from stimulus onset','FontSize',20)
        ylabel('#','FontSize',20)
    end
    % Common Y axis
    % X axis in seconds
    title(['Session ' num2str(i) ' ' TYPE{i}],'FontSize',20)
    grid on
    hold off
    
end

name = ([plot_path 'anc_joshi_RT']);
saveas(fig,name,'png')

% mot = [];
% test = [];
% [exp, trialParam] = MW_readExperiment('jos_20190606_1218_XBI13_joystickstaircase1_4R.mwk');
% for j = 1:length(trialParam)
%     [temp, ~] = MW_getStimData('RDP', 'direction', trialParam(j));
%     mot(j) = cell2mat(temp);
%     test{j} = trialParam(j).TRIAL_outcome.data;
% end
% 
% directions = unique(mot);
% outcome = []; tot = []; absolute = []; igno = [];
% 
% for k = 1:length(directions)
%     outcome(k) = sum(mot == directions(k) & strcmp(test,'hitCorrect'))/ sum(mot == directions(k));
%     tot(k) = sum(mot == directions(k));
%     absolute(k) = sum(mot == directions(k) & strcmp(test,'wrong'));
%     
%     igno(k) = sum(mot == directions(k) & strcmp(test,'ignore'));
% end

