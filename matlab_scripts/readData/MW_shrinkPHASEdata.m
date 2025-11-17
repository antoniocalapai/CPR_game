function optimizedPHASEdata = MW_shrinkPHASEdata(trialParam)
% function optimizedPHASEdata = MW_shrinkPHASEdata(trialParam)
%
% This function delete duplicate frames in the stimDisplayUpdate structure
% of one trial (trialParam) and return the optimized phase data
% (optimizedPHASEdata).
%
% The function checks also for lots of possible errors in the phase data.If
% there is an error, the function return nothing -> []
%
% rbrockhausen@dpz.eu, Oct 2013

% Known bugs:
% - getStimData und kein Background ist doof
%   Test also noch mal explizit fuer den Background/Verschiedene Test
%   durchfuehren.

optimizedPHASEdata = [];

% stimDisplayUpdate exists?
if isfield(trialParam, 'stimDisplayUpdate')
    phase = trialParam.stimDisplayUpdate;
    % phase.data and phase.time exists?
    if (isfield(phase, 'data') && isfield(phase, 'time'))
        % phase.data and phase.time have the same length
        if length(phase.data) == length(phase.time)
            % phase.data is not empty?
            if ~isempty(phase.data)
                % Check now every frame...
                for frameCX = 1 : length(phase.data)
                    % Frame is not empty?
                    if ~isempty(phase.data{frameCX})
                        % Check now every stimulus in this frame
                        for stimCX = 1 : length(phase.data{frameCX})
                            % Check if stimulus is not empty
                            if ~isempty(phase.data{frameCX}{stimCX})
                                % Alles ok...
                            else
                                fprintf('!   trial %d: empty stimulus -> delete trial!\n', trialParam.ML_trialStart.data(1));
                                return
                            end
                        end
                    else
                        fprintf('!   trial %d: empty frame -> delete trial!\n', trialParam.ML_trialStart.data(1));
                        return
                    end
                end
            else
                fprintf('!   trial %d: no data -> delete trial!\n', trialParam.ML_trialStart.data(1));
                return
            end
        else
            fprintf('!   trial %d: data and time have diffrent length -> no import!!!\n', trialParam.ML_trialStart.data(1));
            return
        end
    else
        fprintf('!   trial %d: data or time are not exist -> delete the trial!\n', trialParam.ML_trialStart.data(1));
        return
    end
else
    fprintf('!   trial %d: stimDisplayUpdate does not exist -> delete the trial!\n', trialParam.ML_trialStart.data(1));
    return
end


%% Clear redundant phase data

delIdx = [];
frameCX = 1;
%rab fprintf('    trial %d: frames %d -> ', trialParam.ML_trialStart.data(1), length(phase.data));
% Go through every frame
while frameCX < length(phase.data) 
    allEq = true;
    if length(phase.data{frameCX}) == length(phase.data{frameCX+1})       % Next frame got same number of stimuli
        for stimCX = 1 : length(phase.data{frameCX})                   % Check every stimulus of the frame
            
            for nextStimCX = 1 : length(phase.data{1,frameCX+1})         % Search if the stimulus exist the next frame
                if strcmp(phase.data{frameCX}{stimCX}.name, phase.data{1,frameCX+1}{nextStimCX}.name)
                    break;
                end
            end
            
            % If the simulus doesn't exist, take this frame and check the next one
            if ~(strcmp(phase.data{frameCX}{stimCX}.name, phase.data{frameCX+1}{nextStimCX}.name))
                allEq = false;
                break;
            else
                % Check if the parameter are the same
                checkFields = fieldnames(phase.data{frameCX}{stimCX});
                for fieldCX=1:length(checkFields)
                    switch (checkFields{fieldCX})
                        case {'lastDotPosition', 'update_delta', 'reset', 'bit_code'}
                        otherwise
                            if isstr(phase.data{frameCX}{stimCX}.(checkFields{fieldCX}))
                                if ~strcmp(phase.data{frameCX}{stimCX}.(checkFields{fieldCX}), phase.data{frameCX+1}{nextStimCX}.(checkFields{fieldCX}))
                                    %fprintf('Different: %s\n', checkFields{fieldCX})
                                    allEq = false;
                                    break;
                                end
                            else
                                if (phase.data{frameCX}{stimCX}.(checkFields{fieldCX}) ~= phase.data{frameCX+1}{nextStimCX}.(checkFields{fieldCX}))
                                    %fprintf('Different: %s\n', checkFields{fieldCX})
                                    allEq = false;
                                    break;
                                end
                            end
                    end
                end
            end
        end
    else
        allEq = false;
    end
    if allEq
        % Delete redundant frame...
        delIdx = [delIdx frameCX+1];
    end
    frameCX = frameCX + 1;
end
phase.data(delIdx) = [];
phase.time(delIdx) = [];
%rab fprintf('%d\n', length(phase.data));

optimizedPHASEdata = phase;
end