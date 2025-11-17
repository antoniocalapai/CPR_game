function experimentData = MW_readFile(filename, includeList, excludeList)
% function allesWirdGut = MW_readFile(filename, includeList, excludeList)
%
% Please be aware: This is only a proof of concept for the new reading function.



if (isempty(includeList))
    eType = {'ML_', '#announceMessage', '#stimDisplayUpdate', 'EYE_', 'IO_', 'SPIKE_', 'SC_', 'EXP_', 'TOUCH_'};
else
    eType = includeList;
end

if (isempty(excludeList))
    dType = {'IO_joystick_x_raw', 'IO_joystick_y_raw', 'IO_joystick_x_calib', 'IO_joystick_y_calib', 'IO_mIOLooptime_mks',...
    'EYE_on', 'EYE_raw_right_x', 'EYE_raw_right_y', 'EYE_raw_left_x', 'EYE_raw_left_y',...
    'EYE_raw_x', 'EYE_raw_y', 'EYE_raw_z', 'EYE_href_right_x', 'EYE_href_right_y', ...
    'EYE_href_left_x', 'EYE_href_left_y', 'EYE_pupil_right_x', 'EYE_pupil_right_y', ...
    'EYE_pupil_left_x', 'EYE_pupil_left_y', 'EYE_pupil_size_right', 'EYE_pupil_size_left', ...
    'EYE_sample_time', 'EYE_saccade'};
else
    dType = excludeList;
end


addpath('/Library/Application Support/MWorks/Scripting/Matlab')

%filename = 'tito-match2sample_v19_WIP-20191105-112420.mwk2';
%filename = 'tito-joystick_v1-20191007-110518.mwk2';
%filename = 'repaired_jah-spAtt2-hay-079-01+01.mwk';
%filename = 'igg_20191106_1103_XBI13_JMotion_FollowRDP_4R.mwk';
%filename = 'bew-MSTRC-igg-113-01+01.mwk'; %BROKEN FRAME!!
%filename = 'P4A_XBI07_20191010_1310_P4ACA_Hum.mwk'; % BROCKEN FRAME!
%filename = 'tito-test_rdp2_0-20191120-100007.mwk2';
codecs=getCodecs(filename);


% REMOVE ALL DATAID THINGS!
% WHAT ABOUT PRELOCATING ARRAYS IN A HUGE SIZE BEFORE? CHECK THE SPEED...

% Stelle Liste alle Events die gelesen werden sollen zusammen:
%eType = {'ML_', 'IO_', 'EYE_', 'TOUCH_', 'SC_', 'SPIKE_', 'EXP_', '#stimDisplayUpdate', '#announceMessage', '#announceSound', 'TRIAL_fixate'};
%eType = {'ML_', '#announceMessage', '#stimDisplayUpdate', 'EYE_', 'IO_', 'SPIKE_', 'SC_', 'EXP_', 'TOUCH_'};%{'IO_joystick_direction'}; %'ML_', '#stimDisplayUpdate', , 'IO_joystick_strength'
%debug = 0;
% dType = {'IO_joystick_x_raw', 'IO_joystick_y_raw', 'IO_joystick_x_calib', 'IO_joystick_y_calib', 'IO_mIOLooptime_mks',...
%     'EYE_on', 'EYE_raw_right_x', 'EYE_raw_right_y', 'EYE_raw_left_x', 'EYE_raw_left_y',...
%     'EYE_raw_x', 'EYE_raw_y', 'EYE_raw_z', 'EYE_href_right_x', 'EYE_href_right_y', ...
%     'EYE_href_left_x', 'EYE_href_left_y', 'EYE_pupil_right_x', 'EYE_pupil_right_y', ...
%     'EYE_pupil_left_x', 'EYE_pupil_left_y', 'EYE_pupil_size_right', 'EYE_pupil_size_left', ...
%     'EYE_sample_time', 'EYE_saccade'};
eCodecNo = [];
stepSizeMs = 60000000;


fprintf('---== Selected events ==---\n');
for i=1:length(codecs.codec)
    left = '   '; right = '   ';
    for j=1:length(eType)
        if (strfind(codecs.codec(i).tagname, eType{j}) == 1)
            if (sum(strcmp(codecs.codec(i).tagname, dType)) == 0)
                left = '=> '; right = ' <=';
                eCodecNo = [eCodecNo codecs.codec(i).code];
            end
        end
    end
    
    fprintf('%s%s%s\n', left, codecs.codec(i).tagname, right);
end
clear left right i j; 

% fprintf('---=== Read the raw data into memory ==---\n');
% eventList = getEvents(filename, eCodecNo);
% [~, order] = sort([eventList(:).time_us],'ascend');
% eventList = eventList(order);

lastFrameStimuli = {};
thisFrameStimuli = {};
lastFrame = {};
lastFrameNo = 0;
msgType = {'LOG_message', 'LOG_warning', 'LOG_error'};



errorList = struct('timestamp', 0, 'message', 'open datafile...');


% dataID = struct('timestamp', 0, 'action', 0, 'value', ' ');
% dataID(1000000) = struct('timestamp', 0, 'action', 0, 'value', '');
dataCX = 1;

data.timestamp = [];
data.action = [];
%data.tagname = {};
data.valueNUM = [];
data.valueCHAR = {};

codecID = struct('code', 0, 'name', ' ');
for (codecCX = 1:length(eCodecNo))
    fprintf('%s\n', codecs.codec([codecs.codec.code] == eCodecNo(codecCX)).tagname);
    codecID(codecCX).code = eCodecNo(codecCX);
    codecID(codecCX).name = codecs.codec([codecs.codec.code] == eCodecNo(codecCX)).tagname;
end



codecID(length(codecID)+1) = struct('code', max([codecID.code])+1, 'name', 'STIM_displayUpdate');




%% This loop reads the data minute by minute.
% I didn't figure out, how to get the last timestamp in the datafile,
% that's why I check if no data came in the last 60 minutes. If anybody
% find a better solution, please add it here (y)
leaveLoopCX = 0; % leeaveLoop and firstData are both used as an exit from the loop 
firstData = false;
minuteCX = 0;
tic
fprintf('\n');

fprintf('---== read and convert data  ==---\n');
while (leaveLoopCX < 60)

    eventList = getEvents(filename, eCodecNo, minuteCX*stepSizeMs, ((minuteCX+1)*stepSizeMs)-1);
    [~, order] = sort([eventList(:).time_us],'ascend');
    eventList = eventList(order);
    
    if not(isempty(eventList))
        fprintf('Minute No %4d %3d (%6ld events): %6.2f done', minuteCX+1, leaveLoopCX, length(eventList), 0.0);
    end
    
    if (not(firstData) && (length(eventList) > 0)) 
        firstData = true;
    end
    
    if (firstData && (length(eventList) == 0))
        leaveLoopCX = leaveLoopCX + 1;
    end
    
    for (i=1:length(eventList))
        leaveLoopCX = 0;
%         if (dataCX > size(dataID,2))
%             dataID(dataCX + 1000000) = struct('timestamp', 0, 'action', 0, 'value', ' ');
%         end
        
        if (isempty(eventList(i).data))
        elseif not(isstruct(eventList(i).data)) && not(iscell(eventList(i).data))
            data.timestamp(dataCX) = eventList(i).time_us;
            data.action(dataCX) = eventList(i).event_code;
            %data.tagname{dataCX} = codecs.codec([codecs.codec.code] == eventList(i).event_code).tagname;
            %data.value{dataCX} = eventList(i).data;
            if (ischar(eventList(i).data))
                data.valueCHAR{dataCX} = eventList(i).data;
            else
                data.valueNUM(dataCX) = eventList(i).data;
            end
            
%             dataID(dataCX) = struct('timestamp', eventList(i).time_us, 'action', eventList(i).event_code, 'value',  eventList(i).data);
            dataCX = dataCX+1;
            
            
%         elseif (isstring(eventList(i).data))
%             dataID(dataCX) = struct('timestamp', eventList(i).time_us, 'action', codecs.codec([codecs.codec.code] == eventList(i).event_code).tagname, 'value',  eventList(i).data);
%             dataCX = dataCX+1;
        elseif (strcmp(codecs.codec([codecs.codec.code] == eventList(i).event_code).tagname, '#announceMessage'))
            data.timestamp(dataCX) = eventList(i).time_us;
            data.action(dataCX) = eventList(i).event_code;
            data.valueCHAR{dataCX} = eventList(i).data.message;
            
            %dataID(dataCX) = struct('timestamp', eventList(i).time_us, 'action', msgType{eventList(i).data.type+1}, 'value',  eventList(i).data.message);
            %RAB MessageType!!!
            dataCX = dataCX+1;
            % ANZEIGE SPƒTER ANSCHALTEN, AM BESTEN MIT PARAMETER fprintf('%8ld %s\n', eventList(i).time_us/1000, eventList(i).data.message);
%         elseif (strcmp(codecs.codec([codecs.codec.code] == eventList(i).event_code).tagname, '#announceSound'))
%             dataID(dataCX) = struct('timestamp', eventList(i).time_us, 'action', 'SOUND', 'value',  eventList(i).data.name);
%             dataCX = dataCX+1;
        elseif (strcmp(codecs.codec([codecs.codec.code] == eventList(i).event_code).tagname, '#stimDisplayUpdate'))
            % #stimDisplayUpdate: Eingelesen werden nur frame(n) != frame(n-1)
            %fprintf(fileID, '%6d\t(frame)\t%ld\tDISPLAYUPDATE\t1\n',i , eventList(i).time_us/1000);
            
            data.timestamp(dataCX) = eventList(i).time_us;
            data.action(dataCX) = MW_getCodecCode(codecID, 'STIM_displayUpdate');
            %data.tagname{dataCX} = 'STIM_displayUpdate';
            data.valueNUM(dataCX) = 1;
            
%             dataID(dataCX) = struct('timestamp', eventList(i).time_us, 'action', MW_getCodecCode(codecID, 'STIM_displayUpdate'), 'value',  1);
            dataCX = dataCX+1;
            
            
            % ACHTUNG: Ich habe jetzt zweimal schon einen Frame gefunden in
            % der ein Stimulus zweimal in der Liste auftaucht :-o
            % Das ist ganz ganz schlecht :-( ich bin mir noch nicht ganz
            % sicher, was ich daraus machen soll...
%             theFrame = eventList(i);
%             numStimuli = length(theFrame.data);
%             testStimList = {};
%             testFlag = false;
%             for (stimCX = 1:numStimuli)
%                 if (sum(strcmp(theFrame.data{stimCX}.name, testStimList)) > 0)
%                     testFlag = true;
%                 else
%                     testStimList{length(testStimList)+1} = theFrame.data{stimCX}.name;
%                 end
%             end
            % Bis hier in eine einzelne Funktion auslagern
            
            
            if ((lastFrameNo ~= 0) && not(MW_frameCompare(eventList(i), lastFrame)))
                %fprintf('%4d frame - start working: %.2f\n', i, length(eventList(i).data))
                if (isempty(eventList(i).data))
                    for (lfsCX = 1:length(thisFrameStimuli))
                        %fprintf(fileID, '%6d\t(frame)\t%ld\tSTIM_%s_onScreen\t0\n',i , eventList(i).time_us/1000, thisFrameStimuli{lfsCX});
                        %max([codecID.code])
                        %codecID(strcmp({codecID.name}, 'STIM_displayUpdate')).code
                         fprintf('......................SCHNURZ\n.....................');
                        if (not(strcmp({codecID.name}, ['STIM_' thisFrameStimuli{lfsCX} '_onScreen'])))
                            fprintf('......................HURZ\n.....................');
                        end

                        data.timestamp(dataCX) = eventList(i).time_us;
                        data.action(dataCX) = MW_getCodecCode(codecID, ['STIM_' thisFrameStimuli{lfsCX} '_onScreen']);
                        %data.tagname{dataCX} = ['STIM_' thisFrameStimuli{lfsCX} '_onScreen'];
                        data.valueNUM(dataCX) = 0;

%                         dataID(dataCX) = struct('timestamp', eventList(i).time_us, 'action', ['STIM_' thisFrameStimuli{lfsCX} '_onScreen'], 'value',  0);
                        dataCX = dataCX+1;
                    end
                    lastFrameStimuli = {};
                    thisFrameStimuli = {};
                    
                else
                    lastlastFrame = lastFrame; %debug
                    lastFrame = eventList(i).data;
                    
                    lastFrameStimuli = thisFrameStimuli;
                    %thisFrameStimuli = cell(1, length(eventList(i).data));
                    thisFrameStimuli = {};
                    
                    for (stimCX = 1:length(eventList(i).data))
                        
                        if (sum(strcmp(eventList(i).data{stimCX}.name, thisFrameStimuli)) == 0)
                            
                            
                            % StimulusOnset
                            if not(sum(strcmp(lastFrameStimuli, eventList(i).data{stimCX}.name)))
                                %fprintf(fileID, '%6d\t(frame)\t%ld\tSTIM_%s_onScreen\t1\n',i , eventList(i).time_us/1000, eventList(i).data{stimCX}.name);
                                if (not(strcmp({codecID.name}, ['STIM_' eventList(i).data{stimCX}.name '_onScreen'])))
                                    codecID(length(codecID)+1) = struct('code', max([codecID.code])+1, 'name', ['STIM_' eventList(i).data{stimCX}.name '_onScreen']);
                                end
%                                 dataID(dataCX) = struct('timestamp', eventList(i).time_us, 'action', MW_getCodecCode(codecID, ['STIM_' eventList(i).data{stimCX}.name '_onScreen']), 'value',  1);
                                dataCX = dataCX+1;
                            else
                                lastFrameStimuli{strcmp(lastFrameStimuli, eventList(i).data{stimCX}.name)} = 'nix';
                            end
                            thisFrameStimuli{stimCX} = eventList(i).data{stimCX}.name;
                            
                            featureList = fieldnames(eventList(i).data{stimCX});
                            for (featureCX = 1:length(featureList))
                                if (not(strcmp(featureList{featureCX}, 'name')))
                                    
                                    if (not(strcmp({codecID.name}, ['STIM_' eventList(i).data{stimCX}.name '_' featureList{featureCX}])))
                                        codecID(length(codecID)+1) = struct('code', max([codecID.code])+1, 'name', ['STIM_' eventList(i).data{stimCX}.name '_' featureList{featureCX}]);
                                    end
                                    
                                    data.timestamp(dataCX) = eventList(i).time_us;
                                    data.action(dataCX) = MW_getCodecCode(codecID, ['STIM_' eventList(i).data{stimCX}.name '_' featureList{featureCX}]);
                                    %data.tagname{dataCX} = ['STIM_' eventList(i).data{stimCX}.name '_' featureList{featureCX}];
                                    %data.value{dataCX} = eventList(i).data{stimCX}.(featureList{featureCX});
                                    if (ischar(eventList(i).data{stimCX}.(featureList{featureCX})))
                                        data.valueCHAR{dataCX} = eventList(i).data{stimCX}.(featureList{featureCX});
                                    else
                                        data.valueNUM(dataCX) = eventList(i).data{stimCX}.(featureList{featureCX});
                                    end
                                    
%                                     dataID(dataCX) = struct('timestamp', eventList(i).time_us, 'action', MW_getCodecCode(codecID, ['STIM_' eventList(i).data{stimCX}.name '_' featureList{featureCX}]), 'value',  eventList(i).data{stimCX}.(featureList{featureCX}));
                                    
                                    
                                    %dataID(dataCX) = struct('timestamp', eventList(i).time_us, 'action', ['STIM_' eventList(i).data{stimCX}.name '_' featureList{featureCX}], 'value',  eventList(i).data{stimCX}.(featureList{featureCX}));
                                    dataCX = dataCX+1;
                                    %                             if (isinteger(eventList(i).data{stimCX}.(featureList{featureCX})))
                                    %                                 fprintf(fileID, '%6d\t(frame)\t%ld\tSTIM_%s_%s\t%d\n',i , eventList(i).time_us/1000, eventList(i).data{stimCX}.name, featureList{featureCX}, eventList(i).data{stimCX}.(featureList{featureCX}));
                                    %                             elseif (isfloat(eventList(i).data{stimCX}.(featureList{featureCX})))
                                    %                                 fprintf(fileID, '%6d\t(frame)\t%ld\tSTIM_%s_%s\t%f\n',i , eventList(i).time_us/1000, eventList(i).data{stimCX}.name, featureList{featureCX}, eventList(i).data{stimCX}.(featureList{featureCX}));
                                    %                             elseif (ischar(eventList(i).data{stimCX}.(featureList{featureCX})))
                                    %                                 fprintf(fileID, '%6d\t(frame)\t%ld\tSTIM_%s_%s\t%s\n',i , eventList(i).time_us/1000, eventList(i).data{stimCX}.name, featureList{featureCX}, eventList(i).data{stimCX}.(featureList{featureCX}));
                                    %                             else
                                    %                                 fprintf('ERROROROROROROROROROR!!!\n');
                                    %                                 %fprintf('%6d frame   STIM_%s_%s %ld 0\n', i, eventList(i).data{stimCX}.name, featureList{featureCX}, eventList(i).time_us);
                                    %                             end
                                    
                                end
                            end

                        else
                           fprintf('\nDouble Stimulus Error :-o...\n............%6.2f done');
                           errorList(length(errorList)+1) = struct('timestamp', eventList(i).time_us, 'message', 'Duplicate stimulus in a frame - maybe an internal mWorks error.');
                        end
                    end
                    
                    if (sum(not(strcmp(lastFrameStimuli, 'nix'))))
                        for (lfsCX = 1:length(lastFrameStimuli))
                            if (not(strcmp(lastFrameStimuli{lfsCX}, 'nix')))
                                %fprintf(fileID, '%6d\t(frame)\t%ld\tSTIM_%s_onScreen\t0\n',i , eventList(i).time_us/1000, lastFrameStimuli{lfsCX});
                                data.timestamp(dataCX) = eventList(i).time_us;
                                data.action(dataCX) = MW_getCodecCode(codecID, ['STIM_' eventList(i).data{stimCX}.name '_onScreen']);
                                %data.tagname{dataCX} = ['STIM_' eventList(i).data{stimCX}.name '_onScreen'];
                                data.valueNUM(dataCX) = 0;
                                
%                                 dataID(dataCX) = struct('timestamp', eventList(i).time_us, 'action', MW_getCodecCode(codecID, ['STIM_' eventList(i).data{stimCX}.name '_onScreen']), 'value',  0);
                                
                                %dataID(dataCX) = struct('timestamp', eventList(i).time_us, 'action', ['STIM_' lastFrameStimuli{lfsCX} '_onScreen'], 'value',  0);
                                dataCX = dataCX+1;
                            end
                        end
                    end
                    
                end
            end
            lastFrameNo = i;
            lastFrame = [];
            lastFrame = eventList(lastFrameNo);
        else
            fprintf('%6d unknown format %s\n', i,  codecs.codec([codecs.codec.code] == eventList(i).event_code).tagname);
        end
        
        if (mod(i,100) == 0) && not(isempty(eventList))
            fprintf('\b\b\b\b\b\b\b\b\b\b\b%6.2f done', i*100/length(eventList));
        end
    end
    
    if (not(isempty(eventList)))
        fprintf('\b\b\b\b\b\b\b\b\b\b\b100.00 done\n');
    end
    
    minuteCX = minuteCX+1;
    
end % trialCX

%%
% das hier auﬂerhalb der trialschleife
% dataID(dataCX:size(dataID,2)) = [];
%fprintf('\b\b\b\b\b\b\b\b\b\b\b100.00 done\n');

%events = getEvents(filename, [trialCodec(:).code]);clear all

%hurz = events([events.event_code] == 9);
% save(['data_temp/' filename '.mat'], 'events')

data.codecCode = [codecID.code];
data.codecName = {codecID.name};

toc
fprintf('\n');

errorList(1) = [];
for (i = 1:length(errorList))
    fprintf('%10ld\t%s\n', errorList(i).timestamp, errorList(i).message);
end

clear codecCX codecID codecs eventList featureCX featureList firstData i ...
    lastFrame lastFrameNo lastFrameStimuli lastlastFrame leaveLoopCX ...
    lfsCX msgType stimCX thisFrameStimuli minuteCX order stepSizeMs eCodecNo ...
    eType dType dataCX;

tic
fprintf('---== save data into mat-file  ==---\n');
save([filename '.mat'], 'data')
toc

experimentData = data;

end

