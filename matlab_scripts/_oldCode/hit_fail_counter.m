


counter = 0;
for i = 1:length(trialParam)
    
    if ~isempty(trialParam(i).TRIAL_outcome)
        if strfind(trialParam(i).TRIAL_outcome.data,'hit')
           
        counter = counter + 1;
        end
    end
end


counter_fail = 0;
for i = 1:length(trialParam)
    
    if ~isempty(trialParam(i).TRIAL_outcome)
        if strfind(trialParam(i).TRIAL_outcome.data,'fail')
           
        counter_fail = counter_fail + 1;
        end
    end
end