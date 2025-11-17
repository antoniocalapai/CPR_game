%Online trial by trial analysis for Earl
function [retval] = Online_trialbytrial_Earl(data, values)
disp('Online analysis started')
allpath = genpath([strrep(userpath,'MATLAB:','') 'MWorks/MatLab/']);
addpath(allpath);
addpath('/Library/Application Support/MWorks/Scripting/Matlab');
addpath('/Users/cnl/Desktop/Akshay_Earl');
if nargin == 1
    values.perf_figure = NaN;
    values.RT_figure = NaN;
    
    values.perf_stimInfo = [];
    %trialInfo = [];
    %values.linearStimInfo = [];
    %values.spiralStimInfo = [];
    values.endOfExperiment = false;
end

%% Read in data
try
    TRIAL = MW_readTrial(data);
    values.endOfExperiment = true;
    disp('successfully read in TRIAL');
    disp(['Clock: ' num2str(TRIAL.coin.data(1))]);
%     disp(['Time Early: ' num2str(TRIAL.time_earlyResponse.data)]);
     TRIAL
%     disp(['Time Late: ' num2str(TRIAL.time_responseWindow.data(1))]);
%     timeLate = TRIAL.time_earlyResponse.data(1) + TRIAL.time_responseWindow.data(1);
catch
    disp('error while reading in TRIAL information')
end

if values.endOfExperiment == true
   % disp(TRIAL.ML_trialStart.data)
    fprintf(' trial %d *done*\n', TRIAL.ML_trialStart.data);
      if ~isempty(TRIAL)
           if(~isempty(TRIAL.TRIAL_outcome))
               disp([ TRIAL.TRIAL_outcome.data ' Trial']);
           end
           Properties = extract_dirInfo(TRIAL,TRIAL.ML_trialStart.data);%extract direction and time of two RDPs
           values.perf_stimInfo = cat(1,values.perf_stimInfo, Properties);
           values.perf_stimInfo;
           timeEarly = 150;
           timeLate = 650;
           yStack = generate_performance_hist_rt(values.perf_stimInfo,timeEarly,timeLate);
%            Properties
      end
end
retval = values;
           
          
           