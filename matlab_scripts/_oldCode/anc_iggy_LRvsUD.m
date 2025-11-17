%%%%%%%%%%%
clear all %
close all %
%%%%%%%%%%%

addpath(genpath(('/Volumes/weco/Joystick_XBI/Analysis')))
addpath(genpath(('/Volumes/cnl/mWorks/MatLab')))

DATA_dir = '/Volumes/weco/Joystick_XBI/data/iggy/';
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

FirstSess = 82;

for i = FirstSess:length(SESSION_list)
    disp(i)
    
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
                
                [mt, ~] = MW_getStimData('RDP', 'direction', trialParam(j));
                RT(i).mot(j) = cell2mat(mt);
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
        
    elseif not(isempty(strfind(SESSION_list(i).name, '8R')))
        [~, trialParam] = MW_readExperiment([DATA_dir SESSION_list(i).name]);
        TYPE{i} = '8R';
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
    end
    
end

% %% Staircase Left Right vs Up Down
% fig = figure('rend','painters','pos',[465 111 1053 854]);
% CHANCE = (STEP_LR / 360) * 100;
% yaxis = [2 5 10 20 30 40 50 60 70 80 85 90 100 110 120 130 140 150 160 170];
% h = stairs(TRIAL_LR, STEP_LR, '-..');
% h(1).MarkerSize = 20;
% hold on
% f = stairs(TRIAL_UD, STEP_UD, '-..r');
% f(1).MarkerSize = 20;
% set(gca, 'YDir','reverse')
% xlabel('Trials','FontSize',30)
% ylabel('Range','FontSize',30)
% yticks([unique(STEP_LR)])
% ylim([0 180])
% grid on
% legend('Left/Right (first)','Up/Down (second)','Location','southeast','FontSize',30)
% title("Iggy - joystick staircase",'FontSize',30)
% 
% name = ([plot_path 'anc_iggy_stcs']);
% saveas(fig,name,'png')


% %% HIT RATE vs SESSION
% fig = figure('rend','painters','pos',[465 111 1053 854]);
% bar(TOT)
% xticks([1:length(TOT)])
% set(gca,'xticklabel',TYPE)
% xlabel('Session','FontSize',30)
% ylabel('Trials','FontSize',30)
% grid on
% title("Iggy - joystick staircase - total trials across sessions",'FontSize',30)
% 
% name = ([plot_path 'anc_iggy_tot']);
% saveas(fig,name,'png')

%% Reaction time
% fig = figure('rend','painters','pos',[465 111 2000 1000]);
% for i = 1:length(SESSION_list)
%     
%     subplot(2,ceil(length(SESSION_list)/2),i)
%     hold on
%     histogram(RT(i).ses(strcmp(RT(i).idx,'hit'))/1000,30)
%     histogram(RT(i).ses(strcmp(RT(i).idx,'wro'))/1000,30)
%     line([TUNING.direction.spiral.bestdelay(2) TUNING.direction.spiral.bestdelay(2)],ylim,'LineStyle',':','Color','m','LineWidth',4)
%     
%     if i == length(SESSION_list)
%         legend({'hit','wro'},'FontSize',20)
%         xlabel('seconds from stimulus onset','FontSize',20)
%         ylabel('#','FontSize',20)
%     end
%     Common Y axis
%     X axis in seconds
%     title(['Session ' num2str(i) ' ' TYPE{i}],'FontSize',20)
%     grid on
%     hold off
%     
% end
% 
% name = ([plot_path 'anc_iggy_RT']);
% saveas(fig,name,'png')

%% Hit rate by direction
for i = FirstSess:length(SESSION_list)
    if not(isempty(strfind(SESSION_list(i).name, '8R'))) || ...
            not(isempty(strfind(SESSION_list(i).name, '4R'))) || ...
            not(isempty(strfind(SESSION_list(i).name, 'fullRange')))
        
        %directions = unique(RT(i).mot);
        %outcome = [];
        
        [~, trialParam] = MW_readExperiment([DATA_dir SESSION_list(i).name]);
        
        for j = 1:length(trialParam)
            [temp, ~] = MW_getStimData('RDP', 'direction', trialParam(j));
            mot(j) = cell2mat(temp);
            test{j} = trialParam(j).TRIAL_outcome.data(1:3);
        end
        
        directions = unique(mot);
        outcome = []; tot = []; absolute = []; each = []; hits = [];
        
        for k = 1:length(directions)
            outcome(k) = sum(mot == directions(k) & strcmp(test,'hit'))/sum(mot == directions(k) & not(strcmp(test,'ign')));
            hits(k) = sum(mot == directions(k) & strcmp(test,'hit'));
            tot(k) = sum(mot == directions(k) & not(strcmp(test,'ign')));
            absolute(k) = sum(mot == directions(k) & strcmp(test,'ign'));
            each(k) = sum(mot == directions(k));
            ign(k) = sum(mot == directions(k) & strcmp(test,'ign'));
        end
        
        fig = figure('rend','painters','pos',[465 111 1053 854]);
        bar(outcome)
        
        xticks([1:length(directions)-1])
        set(gca,'xticklabel',directions(2:end))
        
        xlabel('motion direction','FontSize',20)
        ylabel('%','FontSize',20)
        ylim([0 1])
        title(['Outcome of Session ', SESSION_list(i).name(5:12) ' ' SESSION_list(i).name(25:end-4)],'FontSize',20)
        grid on
        
        disp(['Date ' SESSION_list(i).name(5:12)])
        disp(['Type ' SESSION_list(i).name(25:end-4)])
        disp(['Total Trials ' num2str(sum(tot))])
        disp(['HitRate ', num2str(sum(hits)/sum(tot))])
        disp(['Duration (minutes) ' num2str((trialParam(end).ML_trialEnd.time - trialParam(1).ML_trialEnd.time)/100000000)])
        disp('===================')
        
       
    end
end

% mot = [];
% test = [];
% [exp, trialParam] = MW_readExperiment('igg_20190807_1057_XBI13_joystickstaircase1_8R_pseudo.mwk');
% for j = 1:length(trialParam)
%     [temp, ~] = MW_getStimData('RDP', 'direction', trialParam(j));
%     mot(j) = cell2mat(temp);
%     test{j} = trialParam(j).TRIAL_outcome.data;
% end
% 
% directions = unique(mot);
% outcome = []; tot = []; absolute = []; each = []; hits = [];
% 
% % for k = 1:length(directions)
% %     outcome(k) = sum(mot == directions(k) & strcmp(test,'hitCorrect'))/ sum(mot == directions(k) & not(strcmp(test,'ignore')));
% %     tot(k) = sum(mot == directions(k) & not(strcmp(test,'ignore')));
% %     absolute(k) = sum(mot == directions(k) & strcmp(test,'ignore'));
% % end
% % bar(outcome)
% 
% for k = 1:length(directions)
%     outcome(k) = sum(mot == directions(k) & strcmp(test,'hit'))/ sum(mot == directions(k) & not(strcmp(test,'ignore')));
%     hits(k) = sum(mot == directions(k) & strcmp(test,'hit'));
%     tot(k) = sum(mot == directions(k) & not(strcmp(test,'ignore')));
%     absolute(k) = sum(mot == directions(k) & strcmp(test,'ignore'));
%     each(k) = sum(mot == directions(k));
% end
% bar(each)
% bar(hits)
% bar(absolute)
% bar(outcome)
% 
% y = [
%     
% direction = []; joystick = [];
% for i = 1:length(trialParam)
% direction(i) = cell2mat(MW_getStimData('RDP', 'direction', trialParam(i)));
% try
%     joystick(i) = cell2mat(trialParam(i).IO_joystick_direction.data(end));
% catch
%     joystick(i) = nan;
% end
% end
% 
% hist(180- (joystick(direction == 180)))