%% Generate a Table with all cells and all parameters associated
% The table contains every cell offline sorted (with at least 1000 spikes)
% and most of the parameters extracted throughout the analysis
addpath(genpath(('/Users/acalapai/ownCloud/Shared/MST_manuscript/Matlab_scripts/')))
database_path = '/Users/acalapai/ownCloud/Shared/MST_manuscript/Databases/';
cells_path = '/Users/acalapai/ownCloud/Shared/MST_manuscript/Cells_matfiles/';
cells_list = dir([cells_path '*.mat']);

% create a list of all cells in all protocols
unique_list = [];
for i = 1:length(cells_list)
    spl = split(cells_list(i).name, '-');
    cell_ID = [spl{1} '-' spl{2} '-' spl{3} '-' spl{4}];
    unique_list{end+1} = cell_ID;
end

unique_list = unique(unique_list,'stable');

%% if this is the first time the table is created
if not(isfile([database_path 'Cells.mat']))
    % this is the list of fields for each unit
    Variables = {'ID', 'string'; ...            % Cell ID
        'mapping_matfile', 'string'; ...        %
        'tuning_matfile', 'string'; ...         %
        'VisualResponse', 'logical';...         % Visual Response
        'session', 'string'; ...                %
        'tuning', 'logical'; ...                %
        'mapping', 'logical'; ...               %
        'include', 'logical'; ...               %
        'date', 'double'; ...                   % Session metadata
        'penetration', 'string'; ...            %
        'AP', 'double'; ...                     %
        'ML', 'double'; ...                     %
        'emisphere', 'string';                  %
        'monkey', 'string';                     %
        'map_hitrate', 'double'; ...            % Behavioral performance
        'tun_hitrate', 'double'; ...            %
        'tun_reactiontime', 'cell'; ...         %
        'tuning_bestdelay', 'double'; ...       %
        'x_list', 'cell'; ...                   % RF task parameters
        'y_list', 'cell'; ...                   %
        'z_list', 'cell'; ...                   %
        'probe_duration', 'double'; ...         %
        'probe_radius', 'double'; ...           %
        'probe_speed', 'double'; ...            %
        'probe_density', 'double'; ...          %
        'probe_dot_size', 'double'; ...         %
        'probe_ndots', 'double'; ...            %
        'stimulus_types', 'cell';               % TUNING task parameters
        'stimulus_directions', 'cell'; ...      %
        'stimulus_disparities', 'cell'; ...     %
        'stimulus_speed_type_1', 'cell'; ...    %
        'stimulus_speed_type_2', 'cell'; ...    %
        'stimulus_radius', 'double'; ...        %
        'stimulus_duration', 'double'; ...      %
        'stimulus_position_x', 'double'; ...    %
        'stimulus_position_y', 'double'; ...    %
        'latencies', 'cell'; ...                % Analysis parameters
        'nspikes_RFmap', 'double'; ...          %
        'nspikes_tuning', 'int16'; ...          %
        'mapping_valid', 'double'; ...          %
        'RF_x', 'double'; ...                   %
        'RF_y', 'double'; ...                   %
        'RF_bestdelay', 'double'; ...           %
        'RF_area', 'double'; ...                %
        'RF_eccentricity', 'double'; ...        %
        'RF_goodnessOfFit', 'double'; ...       %
        'RF_angle', 'double'; ...               %
        'GAM_aic_0', 'double'; ...              % Modelling results
        'GAM_aic_1', 'double'; ...              %
        'GAM_aic_2', 'double'; ...              %
        'GAM_aic_3', 'double'; ...              %
        'GAM_aic_4', 'double'; ...              %
        'GAM_aic_5', 'double'; ...              %
        'GAM_dev_0', 'double'; ...              %
        'GAM_dev_1', 'double'; ...              %
        'GAM_dev_2', 'double'; ...              %
        'GAM_dev_3', 'double'; ...              %
        'GAM_dev_4', 'double'; ...              %
        'GAM_dev_5', 'double'};                 %
    
    CELLS = table('Size',[length(unique_list), size(Variables,1)],...
        'VariableTypes',Variables(:,2),...
        'VariableNames',Variables(:,1));
else
    CELLS = load([database_path 'Cells.mat'], 'CELLS');
    CELLS = CELLS.CELLS;
end

%% Import metadata information from csv file
P = readtable([database_path 'Penetrations.csv']);
for i = 1:length(unique_list)
    spl = split(unique_list{i},'-');
    
    % Date
    CELLS.date(i) = double(P{ismember(P{:,1}, spl{1}) & ...
        ismember(P{:,3}, [spl{2} '-' spl{3}(1:2)]),2});
    
    % Session name
    if strcmp(spl{1},'igg')
        exp = 'anc';
    else
        exp = 'chx';
    end
    
    CELLS.session{i} = [exp '-MERGED-' spl{1} '-' spl{2} '-' spl{3}(1:2)];
    
    % ID , monkey, penetration ID
    CELLS.ID(i) = unique_list(i);
    CELLS.monkey(i) = {unique_list{i}(1:3)};
    CELLS.penetration{i} = [spl{2} '-' spl{3}(1:2)];
    
    % Relative AP
    ap = P{ismember(P{:,1}, spl{1}) & ...
        ismember(P{:,3}, [spl{2} '-' spl{3}(1:2)]),4};
    
    l_ap = P{ismember(P{:,1}, spl{1}) & ...
        ismember(P{:,3}, [spl{2} '-' spl{3}(1:2)]),6};
    
    CELLS.AP(i) = str2double(ap)/100 + str2double(l_ap)/100;
    
    % Relative ML
    ml = P{ismember(P{:,1}, spl{1}) & ...
        ismember(P{:,3}, [spl{2} '-' spl{3}(1:2)]),5};
    
    l_ml = P{ismember(P{:,1}, spl{1}) & ...
        ismember(P{:,3}, [spl{2} '-' spl{3}(1:2)]),7};
    
    CELLS.ML(i) = str2double(ml)/100 + str2double(l_ml)/100;
    
    % Emisphere
    ml = str2double(P{ismember(P{:,1}, spl{1}) & ...
        ismember(P{:,3}, [spl{2} '-' spl{3}(1:2)]),5})/100;
    
    switch ml > 0
        case{1}
            CELLS.emisphere{i} = 'right';
        case{0}
            CELLS.emisphere{i} = 'left';
    end
end

%% Import analysis results from individual mat files
for i = 1:length(unique_list)
    
    % RF mapping
    try
        load([cells_path unique_list{i} '-RFmapp.mat'])
        CELLS.mapping_matfile{i} = [unique_list{i} '-RFmapp.mat'];
        CELLS.mapping_valid(i) = MAPPING.valid;
        CELLS.mapping(i) = 1;
    catch
        CELLS.mapping_valid(i) = 0;
        CELLS.mapping(i) = 0;
    end
    
    if CELLS.mapping_valid(i) > 0
        CELLS.x_list{i} = MAPPING.info.x_list;
        CELLS.y_list{i} = MAPPING.info.y_list;
        CELLS.z_list{i} = MAPPING.info.z_list;
        CELLS.probe_duration(i) = MAPPING.info.stim_duration;
        CELLS.probe_speed(i) = MAPPING.info.speed;
        CELLS.probe_radius(i) = MAPPING.info.radius(end);
        CELLS.probe_density(i) = MAPPING.info.ndots;
        CELLS.probe_dot_size(i) = MAPPING.info.dsize{end};
        CELLS.probe_ndots(i) = MAPPING.info.ndots;
        CELLS.latencies{i} = MAPPING.info.delay;
        CELLS.nspikes_RFmap(i) = MAPPING.info.nspikes;
        CELLS.RF_bestdelay(i) = MAPPING.info.bestdelay;
        CELLS.map_hitrate(i) = MAPPING.info.hitrate;
        CELLS.RF_x(i) = MAPPING.info.RF_x;
        CELLS.RF_y(i) = MAPPING.info.RF_y;
        
        if MAPPING.valid > 0 && MAPPING.valid < 5
            CELLS.RF_area(i) = MAPPING.info.FitRes.area;
            CELLS.RF_eccentricity(i) = MAPPING.info.FitRes.ecce;
            CELLS.RF_goodnessOfFit(i) = MAPPING.info.FitRes.gf;
            CELLS.RF_angle(i) = MAPPING.info.FitRes.angl;
            
        elseif MAPPING.valid == 5
            CELLS.RF_area(i) = MAPPING.info.FitRes.area;
            CELLS.RF_eccentricity(i) = MAPPING.info.FitRes.ecce;
        end
    end
    
    % Tuning
    try
        load([cells_path unique_list{i} '-tuning.mat'])
        tun = 1;
    catch
        tun = 0;
    end
    
    if tun
        CELLS.tuning(i) = 1;
        CELLS.tuning_matfile{i} = [unique_list{i} '-tuning.mat'];
        CELLS.nspikes_tuning(i) = double(TUNING.info.nspikes);
        CELLS.tuning_bestdelay(i) = TUNING.info.bestdelay;
        CELLS.latencies{i} = TUNING.lists.delay;
        CELLS.stimulus_types{i} = TUNING.lists.motion;
        CELLS.stimulus_directions{i} = TUNING.lists.direction;
        CELLS.stimulus_disparities{i} = TUNING.lists.disparity;
        CELLS.stimulus_speed_type_1{i} = TUNING.lists.speed.linear;
        CELLS.stimulus_speed_type_2{i} = TUNING.lists.speed.spiral;
        CELLS.stimulus_duration(i) = TUNING.info.stim_duration;
        CELLS.stimulus_radius(i) = TUNING.info.stim_radius;
        CELLS.stimulus_position_x(i) = TUNING.info.stim_x;
        CELLS.stimulus_position_y(i) = TUNING.info.stim_y;
        CELLS.tun_hitrate(i) = TUNING.info.hitrate;
        CELLS.tun_reactiontime{i} = TUNING.info.RT;
        CELLS.VisualResponse(i) = TUNING.VisualResponse.p < 0.05;
    else
        CELLS.tuning(i) = 0;
    end
end

% save the database as Cells.mat
save([database_path 'Cells'],'CELLS');