% Timeline of the entire session for each subject
addpath(genpath('./readData'))
SESSION_list = dir(['./test_data/' '*CPR*']);

for j = 1:length(SESSION_list)
    filename = ['./test_data/' SESSION_list(j).name];
    load([filename '/' SESSION_list(j).name '.mat'])
    