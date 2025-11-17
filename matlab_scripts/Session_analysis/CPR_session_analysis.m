function [d, idx, trl] = CPR_session_analysis(fname, plotFlag, d)

% This function extracts and visualises basic experimental parameter of the
% continuous perceptual report (CPR) task as well as the behavioural 
% response of the tested subject.
%
% Input:        .fname:     String, filename [If multiple files: 
%                           Cell{'String', 'String'}]
%               .plotFlag   Logical, Indicates if data are plotted
%               .d          Structure, No import if provided
%
% Output:       .d          Structure, Contains raw MWorks data
%               .idx        Structure, Index for each extracted variable
%               .trl        Strucutre, Trial data
%
% CNL fxs - 11/2020


% Add import functions 
%addpath /Users/fschneider/ownCloud/Documents/MWorks/Import %MWread
%addpath /Users/fschneider/ownCloud/Documents/Matlab %
addpath ('/Users/dorothee/ownCloud/Shared/Continous_Psychophisics/matlab_scripts/Session_analysis/')
addpath ('/Users/dorothee/ownCloud/Documents/Bachelor Thesis/matlab_scripts/MW_read/')


% Switch to data directory
%cd /Users/fschneider/ownCloud/Shared/Continous_Psychophisics/matlab_scripts/test_data/20201120_CPR/
cd ('/Users/dorothee/ownCloud/Documents/Bachelor Thesis/matlab_scripts/CPR_subjects_thesis')  
close all

% Define variables for import
var_import = {  'ML_', ...
                'CTRL_', ...
            	'RDP_', ...
                'SC', ...
                'INFO_', ...
                'TRIAL_', ...
                'IO_joystickDirection', ...
                'IO_joystickStrength' };
           
% Check input arguments
if nargin < 3                                                               % If no data structure provided...
    if iscell(fname)                                                        % If multiple files ...
        d               = mergeFiles(fname, var_import);                    % ... merge to single structure
    else
        if isfile([fname '.mat'])                                           % If .mat file available...
            tmp         = load([fname '.mat']);                            	% ...load .mat file
            d           = tmp.d;
        else
            d           = MW_readFile(fname, 'include', var_import);       	% Import .mwk2 session file
            
            disp('Save struct...')
            save([fname '.mat'], 'd', '-v7.3')                              % Save as .mat file
            disp('Done!')
        end
    end
end
    
if nargin < 2
    plotFlag            = true;
end

% Get session ID
if iscell(fname)
    id                  = fname{1}(1:12);
else
    id                  = fname(1:12);  
end

% Initialise variables
lst                     = categories(d.event);                           	% List of variables, just fyi
idx                     = [];                                            	% Initialise
trl                     = [];
coh_pool                = [];
magn_pool               = [];
dur_pool                = [];

% Create variable-specific indices
idx.tOn                 = d.event == 'ML_trialStart';
idx.tEnd                = d.event == 'ML_trialEnd';
idx.steady_duration     = d.event == 'CTRL_SteadyStateDuration';
idx.RDP_dir             = d.event == 'RDP_direction';
idx.RDP_coh             = d.event == 'RDP_coherence';
idx.JS_dir              = d.event == 'IO_joystickDirection';
idx.JS_str              = d.event == 'IO_cursor_distance2center';
idx.outcome             = d.event == 'TRIAL_outcome';
idx.reward              = d.event == 'INFO_ExtraCash';

% Trial timestamps
trl.tOn                 = d.time(idx.tOn);
trl.tEnd                = d.time(idx.tEnd);

% If unequal trial number, remove redundant onset timestamps
while size(trl.tOn,2) > size(trl.tEnd,2)
    vec                 = [];
    for iTS = 1:length(trl.tEnd)
        vec(iTS)        = trl.tEnd(iTS) > trl.tOn(iTS+1);
    end
    trl.tOn(find(vec,1,'first'))    = [];
    
    if sum(vec) == 0 && size(trl.tOn,2) ~= size(trl.tEnd,2)
        trl.tOn(end)    = [];
    end
end

% Remove trials with duration <5us
excl                    = trl.tEnd - trl.tOn < 5;
trl.tOn(excl)           = [];
trl.tEnd(excl)          = [];

% Get trial data
for iTrl = 1:length(trl.tEnd)    
    trlIdx              = [];
    trlIdx              = d.time > trl.tOn(iTrl) & d.time < trl.tEnd(iTrl);             % Trial index
    
    trl.steDur{iTrl}    = getTrialData(d.value, trlIdx, idx.steady_duration);           % Steady state duration
    trl.coh(iTrl)       = getTrialData(d.value, trlIdx, idx.RDP_coh);                   % Trial coherence level
    trl.dir{iTrl}       = mod(getTrialData(d.value, trlIdx, idx.RDP_dir),360);          % Direction of individual steady states
    
    coh_pool            = [coh_pool repmat(trl.coh(iTrl), [1,length(trl.steDur{iTrl})])];  % Coherence level for each steady state
    magn_pool           = [magn_pool diff(trl.dir{iTrl})];                              % Difference between direction of adjacent steady states
    dur_pool            = [dur_pool trl.steDur{iTrl}];                              	% Steady state duration across trials   
end

% Correct for circular space
magn_pool(magn_pool > 180)  = magn_pool(magn_pool > 180) - 360;             
magn_pool(magn_pool < -180) = magn_pool(magn_pool < -180) + 360;

% Save data to struct
trl.dur                 = (trl.tEnd - trl.tOn) ./ 1e6;                      % Trial duration [s]
trl.nDirSwitch          = length(coh_pool);                                 % No. direction switches
trl.coh_pool            = coh_pool;                                         % Pooled SNR across steady states
trl.magn_pool           = magn_pool;                                        % Pooled magnitude of direction changes between steady states
trl.dur_pool            = dur_pool;                                         % Pooled duration of steady states
trl.reward              = d.value(idx.reward);                              % Reward per hit

% Calculate performance
trl.HIidx           	= strcmp(d.value(idx.outcome), 'hit');              % Index for trial outcome
trl.MIidx             	= strcmp(d.value(idx.outcome), 'miss');

trl.target_idx          = logical(trl.HIidx + trl.MIidx);                   % Target index
trl.target_ts         	= d.time(idx.outcome) ./ 1e6;                       % Target timestamp
trl.nTargets          	= sum(trl.target_idx);                              % Number of targets

trl.HIr                 = sum(trl.HIidx) / trl.nTargets;                    % Hit rate
trl.MIr                 = 1 - trl.HIr;                                      % Miss rate


%% PLOT %%%

if plotFlag
    
    fig                 = figure('Units','Normalized','Position',[0 0 1 1]);
    bwidth              = .05;
    foSize              = 12;
    ts1                 = d.time(1) / 1e6;
    
    %%% Distribution of trial duration
    s1                  = subplot(4,4,9);
    h1                  = histogram(trl.dur);
    s1.XLim             = [floor(min((trl.dur))) ceil(max((trl.dur)))];
    s1.Title.String     = 'Trial duration';
    s1.XLabel.String    = 'Time [s]';
    s1.YLabel.String    = 'No. Trials';
    s1.FontSize         = foSize;
    s1.Box              = 'off';
    h1.BinWidth         = s1.XLim(2) * bwidth;
    h1.FaceColor        = 'k';
    h1.EdgeColor        = 'k';
    h1.FaceAlpha        = 1;
    
    %%% Direction over time
    stim_dir            = mod(cell2mat(d.value(idx.RDP_dir)),360);
    stim_ts             = d.time(idx.RDP_dir) ./ 1e6;
    stim_ts             = stim_ts - ts1;   
    js_dir              = cell2mat(d.value(idx.JS_dir));
    js_ts               = d.time(idx.JS_dir) ./ 1e6;
    js_ts               = js_ts - ts1;
    tmpp                = d.value(idx.JS_str);
    js_str              = cell2mat(tmpp(4:end)) ./ 8;
    js_str_ts           = d.time(idx.JS_str) ./ 1e6;
    js_str_ts           = js_str_ts(4:end) - ts1;
    col                 = {[0 0 0],[1 0 0],[.5 .5 .5]};

    s2                  = subplot(4,4,1:4); hold on;
    p21                 = stairs(stim_ts, stim_dir);
    p21.LineWidth       = 2;
    p21.Color           = col{1};
    p22                 = plot(js_ts, js_dir);
    p22.LineWidth       = 2;
    p22.LineStyle       = ':';
    p22.Color           = col{2};    
    s2.YTick            = [0 90 180 270 360];
    s2.YLim           	= [0 365];
    s2.XLim           	= [1 ceil(stim_ts(end))];
    s2.Title.String     = ['Raw time course: ' id];
    s2.Title.Interpreter= 'none';
    s2.XLabel.String    = 'Time [s]';
    s2.YLabel.String    = 'Angle [deg]';
    s2.FontSize         = foSize;
    s2.Box           	= 'off';
    
    yyaxis right
    p23                 = plot(js_str_ts, js_str);
    p23.LineWidth       = 2;
    p23.LineStyle       = ':';
    p23.Color           = col{3};
    s2.YLim           	= [0 1.1];
    s2.YLabel.String    = 'Radial Distance [norm]';
    s2.YAxis(2).Color   = col{3};
    l                   = legend([p21,p22,p23],{'RDP_dir', 'JS_dir', 'JS_rad'});
    l.Interpreter       = 'none';
    l.Location          = 'southwest';
    
    %%% Distribution of coherence levels
    s3                  = subplot(4,4,11);
    h3                  = histogram(trl.coh_pool);
    s3.XLim             = [min(trl.coh_pool) max(trl.coh_pool)];
    s3.Title.String     = 'Steady state SNR distribution';
    s3.XLabel.String    = 'SNR [%]';
    s3.YLabel.String    = 'No. Steady States';
    s3.FontSize         = foSize;
    s3.Box              = 'off';
    h3.BinWidth         = diff(s3.XLim) * bwidth;
    h3.FaceColor        = 'k';
    h3.EdgeColor        = 'k';
    h3.FaceAlpha        = 1;
    
    %%% Distribution of direction change magnitude
    s4                  = subplot(4,4,12);
    h4                  = histogram(trl.magn_pool);
    s4.XLim             = [-190 190];
    s4.Title.String     = 'Magnitude Direction change';
    s4.XLabel.String    = 'Angle [deg]';
    s4.YLabel.String    = 'No. Switches';
    s4.XTick            = [-180 -135 -90 -45 0 45 90 135 180];
    s4.FontSize         = foSize;
    s4.Box              = 'off';
    h4.BinWidth         = diff(s4.XLim) * bwidth;
    h4.FaceColor        = 'k';
    h4.EdgeColor        = 'k';
    h4.FaceAlpha        = 1;
    
    %%% Distribution of steady state duration
    s5                  = subplot(4,4,10);
    h5                  = histogram(trl.dur_pool);
    s5.XLim             = [min(trl.dur_pool) max(trl.dur_pool)];
    s5.Title.String     = 'Steady state duration';
    s5.XLabel.String    = 'Time [ms]';
    s5.YLabel.String    = 'No. Switches';
    s5.FontSize         = foSize;
    s5.Box              = 'off';
    h5.BinWidth         = diff(s5.XLim) * bwidth;
    h5.FaceColor        = 'k';
    h5.EdgeColor        = 'k';
    h5.FaceAlpha        = 1;
    
    %%% Performance over time
    tIdx                = logical(trl.HIidx+trl.MIidx);                     % Target index
    ts                  = trl.target_ts(tIdx);                              % Target timestamps
    ts                  = ts - ts1;
    r_ts                = d.time(idx.reward) ./ 1e6;                        % Reward timestamps
    r_ts                = r_ts(4:end)-r_ts(4);
    r_ts                = [r_ts ts(end)];
    rval                = cell2mat(trl.reward(4:end));                      % Cumulative reward
    rval                = [rval rval(end)];
    col                 = {[1 0 0], [0 0 0], [.5 .5 .5]};                   % Color specs
        
    s6                  = subplot(4,4,15); hold on
    p61                 = stairs(r_ts,rval);
    p61.LineWidth       = 2;
    p61.LineStyle       = '-';
    p61.Color           = [1 1 1];
    s6.YLim           	= [0 rval(end)];
    s6.YLabel.String    = 'Cumulative extra reward [EUR]';
    
    x                  	= [p61.XData(1),repelem(p61.XData(2:end),2)];       % Fill area
    y                   = [repelem(p61.YData(1:end-1),2),p61.YData(end)];
    fl                  = fill([x,fliplr(x)],[y,0*ones(size(y))], col{3});                    
    fl.FaceAlpha        = .5;
    fl.EdgeAlpha        = .5;
    fl.FaceColor        = col{3};
    fl.EdgeColor        = col{3};

    yyaxis right
    p62                 = plot(ts,movmean(trl.HIidx(tIdx),5));
    p62.LineWidth       = 2;
    p62.Color           = col{1};
    p63                 = plot(ts,movmean(trl.MIidx(tIdx),5));
    p63.LineWidth       = 2;
    p63.LineStyle       = ':';
    p63.Color           = col{2};
    s6.YLim           	= [0 1];
    s6.XLim           	= [1 ts(end)];
    s6.Title.String     = 'Performance [movmean, 5 targets]';
    s6.XLabel.String    = 'Time [s]';
    s6.YLabel.String    = 'Rate';
    s6.FontSize         = foSize;
    s6.Box           	= 'off';
    s6.YAxis(1).Color   = col{3};
    s6.YAxis(2).Color   = col{1};
    l                   = legend([p62,p63,fl],{'HIr', 'MIr', 'EUR'});
    l.Location          = 'west';
    
    %%% Target frequency
    df                  = diff(trl.target_ts(trl.target_idx));              % Difference between target timestamps
    s7                  = subplot(4,4,13); hold on
    h7                  = histogram(df);
    s7.XLim             = [0 max(df)+1];
    s7.Title.String     = 'Target frequency';
    s7.XLabel.String    = 'Period between targets [ms]';
    s7.YLabel.String    = 'No. Targets';
    s7.FontSize         = foSize;
    s7.Box              = 'off';
    h7.BinWidth         = diff(s7.XLim) * bwidth;
    h7.FaceColor        = 'k';
    h7.EdgeColor        = 'k';
    h7.FaceAlpha        = 1;
    
    %%% Performance pie chart
    s8                  = subplot(4,4,16);
    p8                  = pie([trl.HIr,trl.MIr], [1,1]);
    pPatch              = findobj(p8,'Type','patch');
    pText               = findobj(p8,'Type','text');
    percentValues       = get(pText,'String');
    txt                 = {'HIr: ';'MIr: '};
    combinedtxt         = strcat(txt,percentValues);
    s8.Title.String     = 'Overall Performance';
    s8.Title.FontSize   = foSize;
    s8.Title.Position(1)= -1;
    col                 = {[1 0 0],[0 0 0]};
    
    for i = 1:size(pText,1)
        pText(i).String         = combinedtxt(i);
        pText(i).FontSize       = foSize;
        pPatch(i).FaceColor     = col{i};
    end
    
    %%% Reward magnitude
    rwd                 = diff(cell2mat(trl.reward(4:end)));                % Reward magnitude / Extra cash per target
    s9                  = subplot(4,4,14); hold on
    h9                  = histogram(rwd);
    s9.XLim             = [0 max(rwd)];
    s9.Title.String     = 'Reward magnitude [EUR]';
    s9.XLabel.String    = 'Performance dependent extra reward [EUR]';
    s9.YLabel.String    = 'No. Targets';
    s9.FontSize         = foSize;
    s9.Box              = 'off';
    h9.BinWidth         = diff(s9.XLim) * bwidth;
    h9.FaceColor        = 'k';
    h9.EdgeColor        = 'k';
    h9.FaceAlpha        = 1;

      
    %%% Tracking performance
    col             	= {[0 0 0],[1 0 0],[.5 .5 .5]};                          
    offset              = 195;                                              % Offset of scatter elements
    s10             	= subplot(4,4,5:8); hold on

    % Trial timestamps
    trl_start               = d.time(idx.tOn) ./ 1e6;
    trl_start               = trl_start - ts1;
    sc101                   = scatter(trl_start,zeros(1,length(trl_start))+offset);
    sc101.Marker            = 'v';
    sc101.MarkerFaceColor   = col{3};
    sc101.MarkerEdgeColor   = col{3};
      
    trl_end                 = d.time(idx.tEnd) ./ 1e6;
    trl_end                 = trl_end - ts1;
    sc102                   = scatter(trl_end,zeros(1,length(trl_end))+offset);
    sc102.Marker            = '^';
    sc102.MarkerFaceColor   = col{1};
    sc102.MarkerEdgeColor   = col{1};
    
    % Absolut stimulus change
    stim_df                 = diff(stim_dir);
    stim_df(stim_df > 180)  = 360 - stim_df(stim_df > 180);
    stim_df(stim_df < -180) = 360 + stim_df(stim_df < -180);
    p101                = stairs(stim_ts, abs([0 stim_df]));
    p101.LineWidth      = 2;
    p101.Marker         = 'x';
    p101.Color          = col{1};
    s10.YLabel.String   = 'Direction change [deg]';
    s10.YTick           = [0 90 180];
    s10.YLim           	= [0 200];
    s10.XLim           	= [1 ceil(stim_ts(end))];
    s10.Title.String    = 'RDP direction change & Joystick deviation';
    s10.XLabel.String   = 'Time [s]';
    s10.FontSize        = foSize;
    s10.Box           	= 'off';
    
    % Absolut joystick deviation from stimulus
    for i = 1:length(js_dir)
        indx = find(stim_ts < js_ts(i),1,'last');
        
        if isempty(indx)
            dev(i)      = nan;
        else
            RDPdir(i)   = double(stim_dir(indx));
            dev(i)      = RDPdir(i) - js_dir(i);
            
            if dev(i) > 180
                dev(i)  = (360-RDPdir(i)) + js_dir(i);
            elseif dev(i) < -180
                dev(i)  = (360-RDPdir(i)) - js_dir(i);
            end
        end
    end
    
    yyaxis right
    p102                = plot(js_ts, abs(dev));
    p102.LineWidth      = 2;
    p102.LineStyle      = ':';
    p102.Color          = col{2};
    s10.YLabel.String   = 'Joystick Deviation [deg]';
    s10.YTick           = [0 90 180];
    s10.YLim           	= [0 200];
    s10.YAxis(2).Color  = col{1};
    s10.YAxis(2).Color  = col{2};
    l                   = legend([sc101,sc102,p101,p102],{'trl_onset','trl_end', 'abs(dir_change)','abs(JS_deviation)'});
    l.Interpreter       = 'none';
    l.Location          = 'southwest';

    %%% Print figure
    print(['./CPR_session_analysis_' id], '-dpng', '-r400')

end
end