%Modularized Code for Earl' behavioral analysis
% zeros(1,8);
function trialInfo = extract_dirInfo(dataCurrentTrial,trialNumber)
% trialInfo = [];
trialInfo(1,1) = trialNumber;
oc = 0;
 %RDP properties
for frame = 1:length(dataCurrentTrial.stimDisplayUpdate.data) %for every stim disp update events

            for stim = 1:length(dataCurrentTrial.stimDisplayUpdate.data{frame})

                    if strcmp(dataCurrentTrial.stimDisplayUpdate.data{frame}{stim}.type,'dynamic_random_dots')%if it's a RDP
                          if ~isempty(dataCurrentTrial.stimDisplayUpdate.data{frame}{stim}.direction)
                            if strcmp(dataCurrentTrial.stimDisplayUpdate.data{frame}{stim}.name,'target_RDP')
                               oc = oc+1;
                              % disp(['RDP # ' num2str(oc) 'frame # ' num2str(frame) ' stim # ' num2str(stim)])
                               
                               if oc == 1 %first direction
                                    firstRDPdir = dataCurrentTrial.stimDisplayUpdate.data{frame}{stim}.direction;% direction of current RDP
                                    trialInfo(1,2) = firstRDPdir;%first RDP direction
                                     trialInfo(1,6) = dataCurrentTrial.stimDisplayUpdate.time(frame);%time of first RDP
                               end
                               
                               if oc == 2%second direction
                                    secondRDPdir = dataCurrentTrial.stimDisplayUpdate.data{frame}{stim}.direction;%direction of second RDP
                                    if secondRDPdir == firstRDPdir%something wrong in the stim disp update, look for more RDPs
                                        oc = oc-1;
                                    else 
                                        trialInfo(1,3) = secondRDPdir;%
                                        trialInfo(1,7) = dataCurrentTrial.stimDisplayUpdate.time(frame);%time of direction change (2nd RDP)
                                    end
                               end
                            end
                        end      
                    end 
              end
end
          %% Responses and response times
                            %both buttons are pressed
                             if ~isempty(dataCurrentTrial.IO_button1) && ~isempty(dataCurrentTrial.IO_button2)
                                  tb1 = min(dataCurrentTrial.IO_button1.time(dataCurrentTrial.IO_button1.data == 0));%first release of button1
                                  tb2 = min(dataCurrentTrial.IO_button2.time(dataCurrentTrial.IO_button2.data == 0));%first release of button2
                                   if length(dataCurrentTrial.IO_button1.data) > 1 %button 1 has multiple responses
                                      
                                       %if button 2 was released
                                       if (dataCurrentTrial.IO_button2.data == 0) > 0
                                           if tb1< dataCurrentTrial.IO_button2.time(dataCurrentTrial.IO_button2.data == 0)%b1 before b2
                                               trialInfo(1,4) = 1;%button 1 is the response
                                               trialInfo(1,8) = tb1;%button 1 release time
                                           else
                                               trialInfo(1,4) = 2;%button 2 is the response
                                               trialInfo(1,8) = min(dataCurrentTrial.IO_button2.time(dataCurrentTrial.IO_button2.data == 0));%button 2 release time
                                           end
                                       else
                                           trialInfo(1,4) = 1;%button 1 is the response
                                           trialInfo(1,8) = tb1;%button 1 release time
                                       end
                                      
                                   elseif length(dataCurrentTrial.IO_button2.data) > 1%button 2 has multiple responses
                                      
                                        %if button 2 was released
                                       if (dataCurrentTrial.IO_button1.data == 0) > 0
                                           if tb2< dataCurrentTrial.IO_button1.time(dataCurrentTrial.IO_button1.data == 0)%b1 before b2
                                               trialInfo(1,4) = 2;%button 1 is the response
                                               trialInfo(1,8) = tb2;%button 2 release time
                                           else
                                               trialInfo(1,4) = 1;%button 1 is the response
                                               trialInfo(1,8) = min(dataCurrentTrial.IO_button1.time(dataCurrentTrial.IO_button1.data == 0));%button 1 release time
                                           end
                                        else
                                           trialInfo(1,4) = 2;%button 2 is the response
                                           trialInfo(1,8) = tb2;%button 2 release time
                                       end
                                   else
                                       tb = [tb1 tb2];
                                       trialInfo(1,4) = find(min(tb));%earliest button is the response
                                       trialInfo(1,8) = min(tb);%button whichever is released first time
                                   end
                             end
                             %button1 is pressed
                             if ~isempty(dataCurrentTrial.IO_button1) && isempty(dataCurrentTrial.IO_button2)
                                 if any(dataCurrentTrial.IO_button1.data == 0)
                                  trialInfo(1,4) = 1;%button 1 is the response
                                 end
                                  if (dataCurrentTrial.IO_button1.data == 0) > 0
                                        trialInfo(1,8) = min(dataCurrentTrial.IO_button1.time(dataCurrentTrial.IO_button1.data == 0));%button 1 release time
                                  end
                             end
                             %button2 is pressed
                             if isempty(dataCurrentTrial.IO_button1) && ~isempty(dataCurrentTrial.IO_button2)
                                  if any(dataCurrentTrial.IO_button2.data == 0)
                                   trialInfo(1,4) = 2;%button 2 is the response
                                  end
                                   if (dataCurrentTrial.IO_button2.data == 0) > 0
                                        trialInfo(1,8) = min(dataCurrentTrial.IO_button2.time(dataCurrentTrial.IO_button2.data == 0));%button 2 release time
                                   end
                             end
                             %no button is pressed
                             if isempty(dataCurrentTrial.IO_button1) && isempty(dataCurrentTrial.IO_button2)
                                    trialInfo(1,4) = 3;%button 3 is "neither"
                                    trialInfo(1,8) = NaN;
                             end
                             %% Now Categorize in the fifth column
                             %success = 1
                             %incorrect = 2
                             %miss = 3
                             %early = 4
                             %no dir change, successful catch trial = 5
                             %other, failed catch trial = 6 
                             if ~isempty(dataCurrentTrial.TRIAL_outcome)
                                %success trials
                                if contains(dataCurrentTrial.TRIAL_outcome.data,'success_choice')
                                    trialInfo(1,5) = 1;%success choice
                                end
                                %incorrect trials
                                if contains(dataCurrentTrial.TRIAL_outcome.data,'incorrect')
                                    trialInfo(1,5) = 2;%incorrect
                                end
                                %missed trials
                                if contains(dataCurrentTrial.TRIAL_outcome.data,'miss')
                                    trialInfo(1,5) = 3;%miss
                                end
                                %early trials
                                if contains(dataCurrentTrial.TRIAL_outcome.data,'early')
                                    trialInfo(1,5) = 4;%early
                                end
                                 %success catch trail
                                if contains(dataCurrentTrial.TRIAL_outcome.data,'success_catch')
                                     trialInfo(1,5) = 5;%no dir change, SUCCESSFUL catch trial
                                end
                                 %failed catch trail
                                if contains(dataCurrentTrial.TRIAL_outcome.data,'failed_catch')
                                    trialInfo(1,5) = 6;%no dir change, FAILED catch trial
                                end
                             end
                             

