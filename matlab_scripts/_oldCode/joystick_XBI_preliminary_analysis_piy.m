%% joystick XBI-data analysis
%creates an array from the extracted data file

 S = [];

for i = 1:length(trial)
    
        
        if isempty(trial(i).SC_in) %staircase in
            S{i,1} = nan;
        else 
            S{i,1} = [trial(i).SC_in.data];  
        end
        
%         S{1,2} = 90; %since the staircase always starts from 90(range)
        if isempty(trial(i).SC_out) %staircase out
            S{i,2} = nan;
        else 
            S{i,2} = [trial(i).SC_out.data];  
        end
        
        [S{i,3},S{i,4}] =  MW_getStimData('RDP', 'direction', trial(i)); %RDP direction
        S{i,5} = [trial(i).TRIAL_outcome.data]; % Trial outcome.hitCorrect or wrong
        
         if isempty(trial(i).IO_rewardA) %the amount given if correct. to doublecheck the results
             S{i,6} = nan;
         else
             S{i,6} = [trial(i).IO_rewardA.data];
         end
       
%         S{i,7} = [trial(i).announceSound.data.name]; %sound. failure or reward. 
%         S{i,8} = [trial(i).announceMessage.data]; %3rd row is important. message about the EXP_limits
        S{i,9} = [trial(i).IO_joystick_strength.data];  %joystick strength data and time for each data point
        S{i,10} = [trial(i).IO_joystick_strength.time];
        S{i,11} = [trial(i).IO_joystick_direction.data]; %joystick direction data and time for each data point
        S{i,12} = [trial(i).IO_joystick_direction.time];
        S{i,13} = [trial(i).IO_joystick_x_calib.data]; %joystick x coordinate
        S{i,14} = [trial(i).IO_joystick_y_calib.data]; %joystick y coordinate
        
        if isempty(trial(i).SC_index_starting) %staircase starting index.shows the behaviour of the staircase
            S{i,15} = nan;
        else 
            S{i,15} = [trial(i).SC_index_starting.data];  
        end
        
end
%save S;

%polar plot is on the way
