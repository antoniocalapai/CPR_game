function [HITRATE, TOTALTRIALS, summary] = anc_ContData_HitRate(filename, plotit)
% filename = 'igg_20191106_1103_XBI13_JMotion_FollowRDP_4R.mwk';
% filename = 'JoyTest_23.mwk'

addpath(genpath(('/Users/acalapai/Documents/MWorks/MatLab/readData')))
addpath(genpath(('/Volumes/weco/Joystick_XBI/Analysis')))
data = MwW_readFile(filename, ...
    {'RDP_selection','RDP_direction',...
    'IO_joystick_direction','IO_rewardA'},[]);

% =========================================================================
% Until Ralf changes the code of MW_readFile 
movefile(([filename,'.mat']),([pwd,'/',filename]))
% =========================================================================

% Extract the Joystick Direction
code = data.codecCode(strcmp(data.codecName, 'IO_joystick_direction'));
joy_dir = data.valueNUM([data.action == code]);
joy_dir_time = data.timestamp([data.action == code]);

% Extract the RDP Direction
code = data.codecCode(strcmp(data.codecName, 'RDP_direction'));
target_dir = data.valueNUM([data.action == code]);
target_time = data.timestamp([data.action == code]);

% code = data.codecCode(strcmp(data.codecName, 'RDP_selection'));
% target_dir = data.valueNUM([data.action == code]);
% target_time = data.timestamp([data.action == code]);

% Extract the Reward information
code = data.codecCode(strcmp(data.codecName, 'IO_rewardA'));
hit_time = data.timestamp([data.valueNUM > 0 & data.action == code]);

%% Calculate summary statistics for the session
if plotit
    figure('rend','painters','pos',[0 0 800 800]);
end

alltargets = unique(mod(target_dir(5:end),360));
allhits = [zeros(1,length(alltargets)); zeros(1,length(alltargets))];

for k = 1:length(alltargets)
    for j = 1:length(target_dir)-1
        if target_dir(j) == alltargets(k)
            onset = target_time(j);
            offset = target_time(j+1);
            sampleLenght(j) = round(offset - onset);
            
            if sampleLenght(j) > 1500000 && sampleLenght(j) < 5000000
                J = joy_dir(joy_dir_time < offset & joy_dir_time > onset);
                T = mod(target_dir(j),360);
                
                difference = 180 - abs(abs(J - T) - 180);
                
                if sum(hit_time > onset & hit_time < offset)
                    subplot(ceil(length(alltargets)/2),ceil(length(alltargets)/2),k)
                    if plotit
                        plot(smoothdata(difference),'black')
                    end
                    allhits(1,k) = allhits(1,k) + 1;
                else
                    subplot(ceil(length(alltargets)/2),ceil(length(alltargets)/2),k)
                    if plotit
                        plot(smoothdata(difference),'red')
                    end
                    allhits(2,k) = allhits(2,k) + 1;
                end
                
            end
            hold on            
        end
    end
    if plotit
        title([num2str(alltargets(k)),', ',num2str(round(100 - (allhits(2,k)/(allhits(2,k) + allhits(1,k))*100))),'% Correct'])
    end
end
hold off

HITRATE = round(100 * (allhits(1,:) / (allhits(2,:) +allhits(1,:))));
TOTALTRIALS = sum(sum(allhits));
summary = [alltargets;allhits];
