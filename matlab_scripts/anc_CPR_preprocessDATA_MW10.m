%% First draft to analyse the CPR mouse+rdp+target task
addpath(genpath(('/Users/acalapai/ownCloud/Shared/ContRDP/Analysis')))

DATA_dir = '/Users/acalapai/ownCloud/Shared/ContRDP/Analysis/test_data/';
SESSION_list = dir([DATA_dir '*.mwk2']);

for i = 1:length(SESSION_list)
    filename = [DATA_dir SESSION_list(i).name];
    MW_readFile([DATA_dir SESSION_list(i).name]);
    disp(SESSION_list(i).name)
    
    % filename = 'igg_20191217_1150_XBI13_JMotion_FollowRDP_4R_pseudo.mwk';
    % filename = 'ConJoy_test_17.mwk'
    
    data = MW_readFile(filename, ...
        {'ML_trialStart',...
        'RDP_coherence',...
        'n_alpha',...
        'alpha',...
        'IO_target_size',...
        'target_x',...
        'target_y',...
        'IO_target_ON',...
        'IO_target_shown',...
        'IO_target_phase',...
        'IO_cursor_x',...
        'IO_cursor_y',...
        'TRIAL_outcome',...
        },'exclude', {}, '~dotPositions');
    
    % =========================================================================
    % Until Ralf changes the code of MW_readFile
    movefile(([filename,'.mat']),([pwd,'/',filename]))
    % =========================================================================
    
    % Extract the Mouse Angle
    cursor_x = data.dataNUM(strcmp(data.action, 'IO_cursor_x'));
    
    code = data.action(strcmp(data.action, 'IO_cursor_x'));
    joy_dir = data.dataNUM([data.action == code]);
    joy_dir_time = data.timestamp([data.action == code]);
    
    % Extract the RDP Direction
    code = data.codecCode(strcmp(data.codecName, 'RDP_direction'));
    target_dir = data.valueNUM([data.action == code]);
    target_time = data.timestamp([data.action == code]);
    
    % code = data.codecCode(strcmp(data.codecName, 'RDP_global'));
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
end