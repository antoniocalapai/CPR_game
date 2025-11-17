function flagIsEqual = MW_frameCompare(frame1, frame2)
% function flagIsEqual = MW_frameCompare(frame1, frame2)
%
% This function checks if two frames are identical (except teh timestamp)
%
% rbrockhausen@dpz.eu, Dec 2019

allEq = true;
if length(frame1.data) == length(frame2.data)       % Next frame got same number of stimuli
    for stimCX = 1 : length(frame1.data)                              % Check every stimulus of the frame
        
        for nextStimCX = 1 : length(frame2.data)         % Search if the stimulus exist the last frame
            if strcmp(frame1.data{stimCX}.name, frame2.data{nextStimCX}.name)
                break;
            end
        end
        
        % If the simulus doesn't exist, take this frame and check the next one
        if ~(strcmp(frame1.data{stimCX}.name, frame2.data{nextStimCX}.name))
            allEq = false;
            break;
        else
            % Check if the parameter are the same
            checkFields = fieldnames(frame1.data{stimCX});
            for fieldCX=1:length(checkFields)
                switch (checkFields{fieldCX})
                    case {'lastDotPosition', 'update_delta', 'reset', 'bit_code'}
                    otherwise
                        if ischar(frame1.data{stimCX}.(checkFields{fieldCX}))
                            if ~strcmp(frame1.data{stimCX}.(checkFields{fieldCX}), frame2.data{nextStimCX}.(checkFields{fieldCX}))
                                %fprintf('Different: %s\n', checkFields{fieldCX})
                                allEq = false;
                                break;
                            end
                        else
                            if (frame1.data{stimCX}.(checkFields{fieldCX}) ~= frame2.data{nextStimCX}.(checkFields{fieldCX}))
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
    %delIdx = [delIdx frameCX+1];
end
flagIsEqual = allEq;