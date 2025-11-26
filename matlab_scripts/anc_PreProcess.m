addpath(genpath(('/Volumes/weco/Joystick_XBI/Analysis')))

%% Iggy
DATA_dir = '/Volumes/weco/Joystick_XBI/data/iggy/';
SESSION_list = dir([DATA_dir '*.mwk']);

for i = 1:length(SESSION_list)
    MW_readExperiment([DATA_dir SESSION_list(i).name]);
    disp(SESSION_list(i).name)
end

%% Joshi
DATA_dir = '/Volumes/weco/Joystick_XBI/data/joshi/';
SESSION_list = dir([DATA_dir '*.mwk']);

for i = 1:length(SESSION_list)
    MW_readExperiment([DATA_dir SESSION_list(i).name]);
    disp(SESSION_list(i).name)
end