function trialParam = MW_readTrial(data, varargin) %expParam

%check for optional parameters
includeEYE = 1; includePHASE = 1; includeIO = 1; includeSPIKE = 1; includeSC = 1; includeALL = 0; noparallel = 1; dontclose = 0;
removeDoublePhaseData = 1; trialCodec = [];


for i = 1 : int16(size(varargin,2)/2)
    switch varargin{2*(i-1)+1}
        case 'trialCodec'
            trialCodex = varargin{i*2};
        otherwise
            %disp('blsblsbls psf_addSample: WARNING: Unknown input argument!');
    end
end

% for i= 1 : size(varargin,2)
%     if (ischar(varargin{i}))
%         %fprintf('     %s\n', varargin{i});
%         switch varargin{i}
%             case '~EYE'
%                 includeEYE = 0;
%                 fprintf('no eye positions; ');
%             case '~PHASE'
%                 includePHASE = 0;
%                 fprintf('no phase data; ');
%             case '~IO'
%                 includeIO = 0;
%                 fprintf('no IOs; ');
%             case '~SPIKE'
%                 includeSPIKE = 0;
%                 fprintf('no spikes; ');
%             case '~SC'
%                 includeSC = 0;
%                 fprintf('no staircases; ');
%             case 'ALL'
%                 includeALL = 1;
%             case 'parallel'
%                 noparallel = 0;
%             case 'dontclose'
%                 dontclose = 1;
%             case '~DOUBLEPHASE'
%                 removeDoublePhaseData = 0;
%             otherwise
%                 disp('WARNING: Unknown input argument!');
%         end
%     elseif(isnumeric(varargin{i}))
%         fprintf('     %d\n', varargin{i});
%     end
% end
% if ~noparallel && ~verLessThan('matlab', '7.11')
%     fprintf('\nTry to open Matlab Pool ... ')
%     try
%         if matlabpool('size') == 0
%             matlabpool%('open', feature('numcores'))
%             if ~dontclose
%             	cleanerPool = onCleanup(@() matlabpool('close')); % close matlabpool (if possible) when leaving the function
%             end
%         end
%         printf('success\n')
%     catch
%         fprintf('failed\n')
%     end
% end

%% init and destruct progress bar
% file = filename(find(filename == '/',1,'last')+1:size(filename,2));
% h= waitbar( 0,'initializing','Name',file,'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
% setappdata(h,'canceling',0)
% cleanWaitbar = onCleanup(@() delete(h));
% clear file;

%% read the codecs

% addpath('/Library/Application Support/MWorks/Scripting/Matlab')

%fprintf('\n\n##### %s\n', filename);
%fprintf('# Indexing the datafile... this could take a while :-(\n');
% Get Codecs and clear private stuff...
%codecs=getCodecs(filename);
%codecs=codecs(1);
%fprintf('# Check codecs\n');

% RAB HERE INSERT CLEANING AND WARNINGS

%idi = false(1,length(codecs.codec));
%idi = or(idi,cellfun(@(x)strcmp(x,'ML_trialStart'),{codecs.codec.tagname}));
%idi = or(idi,cellfun(@(x)strcmp(x,'ML_trialEnd'),{codecs.codec.tagname}));
%idi = or(idi,cellfun(@(x)strcmp(x,'TRIAL_fixate'),{codecs.codec.tagname}));
%idi = or(idi,cellfun(@(x)strcmp(x,'TRIAL_outcome'),{codecs.codec.tagname}));
%idi = or(idi,cellfun(@(x)strcmp(x,'TRIAL_responseEvent'),{codecs.codec.tagname}));
%idi = or(idi,cellfun(@(x)strcmp(x,'TRIAL_response'),{codecs.codec.tagname}));

%ido = false(1,length(codecs.codec));
%%if includeEYE 
 %   idi = or(idi,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'EYE_','start','once')));
%else
%    ido = or(ido,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'EYE_','start','once')));
%end    
%if includeIO
%    idi = or(idi,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'IO_','start','once')));
%else
%    ido = or(ido,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'IO_','start','once')));
%end
%if includeSC
%    idi = or(idi,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'SC_','start','once')));
%else
%    ido = or(ido,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'SC_','start','once')));
%end
%if includeSPIKE
%    idi = or(idi,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'SPIKE_','start','once')));
%else
%    ido = or(ido,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'SPIKE_','start','once')));
%end
%if includePHASE
%    idi = or(idi,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'#stimDisplayUpdate','start','once')));
%else
%    ido = or(ido,cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'#stimDisplayUpdate','start','once')));
%end

%ide = cellfun(@(x)~isempty(x),regexpi({codecs.codec.tagname},'EXP_','start','once'));

%if includeALL
%    idi = or(idi,xor(~ido,ide));
%end
if isempty(trialCodec)
    trialCodec = data.event_codec; % codecs.codec(idi);
    % expCodec = codecs.codec(ide);
    
    clear includeEYE includeIO includeSPIKE includeSC idi ido ide;
    
    %%
    
    % Start with reading the 'EXP_' variables of the data file
    % expParam = [];
    % if ~isempty(expCodec)
    %     events = getEvents(filename, [expCodec(:).code]);
    %     [~, order] = sort([events(:).time_us],'ascend');
    %     events = events(order);
    %     fprintf('# Read & sort %d EXP_events of the datafile...\n', length(events));
    %     for i = 1:length(expCodec)
    %         indices = find([events(:).event_code] == expCodec(i).code);
    %         if indices
    %             expParam.(expCodec(i).tagname) = [{events(indices).data};{events(indices).time_us}];
    %         else
    %             expParam.(expCodec(i).tagname) = [];
    %         end
    %     end
    %     clear order events indices;
    % end
    % % set EXP_fileName and dateTime
    % dirInfo = dir(filename);
    % if (size(dirInfo,1) > 1)
    %     dirInfo = dir(strcat(filename, '/*.mwk'));
    % end
    %
    % expParam = setfield(expParam, 'EXP_fileName', dirInfo.name);
    % expParam = setfield(expParam, 'EXP_dateTime', dirInfo.date);
    
    % write version of readMWdata into the expParam struct
    % try
    %     expParam.EXP_version{1,size(expParam.EXP_version,2)+1} = versionStr;
    %     expParam.EXP_version{2,size(expParam.EXP_version,2)} = 0;
    % catch
    %     expParam = setfield(expParam, 'EXP_version', [{versionStr};{0}]);
    % end
    
    % remove redundant data from the EXP_version parameter
    % Delete Initvalues
    % i = length(expParam.EXP_version(2,:));
    % while i > 0
    %     if expParam.EXP_version{1,i} == 0
    %         expParam.EXP_version(:, i) = [];
    %     end
    %     i = i-1;
    % end
    % % Delete Doubles
    % if length(expParam.EXP_version(2,:)) > 1
    %     i = 0;
    %     while i < length(expParam.EXP_version(2,:))
    %         i = i+1;
    %         j = length(expParam.EXP_version(2,:));
    %         while j > i
    %             if strcmp(expParam.EXP_version{1,i}, expParam.EXP_version{1,j})
    %                 expParam.EXP_version(:, j) = [];
    %             end
    %             j = j-1;
    %         end
    %     end
    % end
    
    
    
    % clear dirInfo expCodec versionStr;
    
    % Create trial structure
    trialParam = [];
    for i = 1:length(trialCodec)
        tagname = trialCodec(i).tagname;
        if tagname(1) == '#'
            tagname = tagname(2:length(tagname));
        end
        trialParam = setfield(trialParam, tagname, []);
    end
    clear tagname;
end

% fprintf('# Read & sort all the events of the datafile...  this could take a while, too :-(\n');
% Get ML_trialStart & ML_trialEnd Events
%events = data.events;
[~, order] = sort([data.events(:).time_us],'ascend');
events = data.events(order);
clear order;

% fprintf('# Check for broken trials\n');
% % Check start & stops and minimal trial length (> 20)
% trialStartFlag = 0;
% trialCounter = 0;
% for i = 1:length(events)
%     if events(i).event_code == codec_tag2code(trialCodec, 'ML_trialStart')
%         if (events(i).data <= 0)
%         %    fprintf('WARNING: ML_trialStart with value "0"\n');
%         elseif not(trialStartFlag)
%             startTime = events(i).time_us;
%             trialStartFlag = 1;
%         %else
%         %     fprintf('WARNING: ML_trialStart, without ML_trialEnd\n');
%         end
%     else
%         if trialStartFlag
%             trialCounter = trialCounter + 1;
%             borders(trialCounter, 1) = startTime;
%             borders(trialCounter, 2) = events(i).time_us;
%             trialStartFlag = 0;
%         %else
%         %    fprintf('WARNING: ML_trialEnd, without ML_trialStart\n');
%         end
%     end
% end
% 
% clear trialCounter trialStartFlag startTime;

% i = 1;
% while i <= length(borders(:,2))
%     if (borders(i,2) - borders(i,1) <= 10)
%         % fprintf('Found invalid trial...\n', i);
%         borders(i,:) = [];
%     else 
%         i = i + 1;
%     end
% end


% cx = 0;
% fprintf('# Find and copy data to trialStruct (one dot is 10 trials)\n');
% if noparallel == 0
%     fprintf('(Displaying of dots does not work when working on multiple processors, just hang on..\n)');
% end
% Now we can read all the nice date per trial
% for trialCounter = 1:length(borders(:,2))
%     if mod(trialCounter,10)==0
%         fprintf('.');
%     end
%     events = getEvents(filename, [trialCodec(:).code], borders(trialCounter,1), borders(trialCounter,2));
%     [~, order] = sort([events(:).time_us],'ascend');
%     events = events(order);
for i = 1:length(trialCodec)
    indices = find([events(:).event_code] == trialCodec(i).code);
    if indices
        tagname = trialCodec(i).tagname;
        if tagname(1) == '#'
            tagname = tagname(2:length(tagname));
        end
        
        %trialParam(trialCounter).(tagname) = [{events(indices).data}; {events(indices).time_us}];
        try
            trialParam.(tagname).data = cell2mat({events(indices).data});
        catch
            trialParam.(tagname).data = {events(indices).data};
        end
        trialParam.(tagname).time = [events(indices).time_us];
    end
end
% end
clear trialcounter i indices tagname events codecs trialCodec borders cx order;


% %% Clear redundant phase data
if includePHASE
    trialParam.stimDisplayUpdate = MW_shrinkPHASEdata(trialParam);
    if ~isfield(trialParam.stimDisplayUpdate, 'data')
        trialParam = [];
    end
end
clear includePHASE includeALL;

% if ~isfield(trialParam, 'ML_trialOutcome')
%     fprintf('Debugmessage (will disapear soon) (Ralf)\n');
% end

%fprintf('\n# Done!\n');
% toc

end
