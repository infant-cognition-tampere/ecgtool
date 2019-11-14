function ecgtool()
% Ecgtool is a graphical user interface to perform EKG/ECG analysis on
% Matlab. Gui features tools to load and display ECG-signal and event-codes
% on corresponding times. Various peak-detection algorithms can be run and
% detection corrected manually. After peak detection, various modules can
% be utilized to use for computing heart-rates, variations of RSA,
% exporting data, eg. Module API is open for everyone to write an
% experiment to perform ECG-data operations.

% register the rootdirectory where the eegtool_preprocess script is located
h.rootdir = fileparts(mfilename('fullpath'));

% construct pathing if not deployed (might mess things up)
if ~isdeployed
    fundir = [h.rootdir filesep 'functions' filesep];
    moduledir = [h.rootdir filesep 'modules' filesep];
    
	if (isdir(fundir) && isdir(h.rootdir))
        addpath(h.rootdir);
		addpath(fundir);
        addpath(moduledir);
	end
end

% define ui properties
hfig = figure('units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);

set(hfig, 'menubar', 'none', 'numbertitle', 'off', 'name', 'Ecgtool 3.0', 'color', 'w');

% set backgroung image
hBg =  axes('units','normalized', 'position',[0 0 1 1]);

% Move the background axes to the bottom
uistack(hBg,'bottom'); 

set(hBg,'handlevisibility','off', 'visible','off');

%-- A quick overview of the data-structures of this UI                     --%
%-- h is a struct that contains handles of the buttons, options etc        --%
%-- of the GUI because they stay the same. Data that changes (EEG, events, --%
%-- filename, ...) is stored in the appdata-struct because it is not       --%
%-- possible to give it as a parameter to function in creation             --%

% define ui elements
h.ecgtool = hfig;
h.axes1 = axes('units', 'normalized', 'position', [0.05 0.75 0.9 0.20]);
title('ECG signal');
xlabel '';
ylabel 'µV';
h.axes2 = axes('units', 'normalized', 'position', [0.05 0.58 0.9 0.11]);
xlabel 'time(s)';
ylabel 'BPM';

h.panel1 = uipanel('units', 'normalized', 'position', [0.02 0.02 0.15 0.5], 'backgroundcolor', [0.894 0.941 0.942]);
h.panel2 = uipanel('units', 'normalized', 'position', [0.19 0.16 0.3 0.36], 'backgroundcolor', [0.871 0.922 0.98]);
h.panel3 = uipanel('units', 'normalized', 'position', [0.19 0.02 0.3 0.12], 'backgroundcolor', [0.871 0.922 0.98]);
h.panel4 = uipanel('units', 'normalized', 'position', [0.51 0.16 0.3 0.36]);
h.panel5 = uipanel('units', 'normalized', 'position', [0.51 0.02 0.3 0.12], 'backgroundcolor', [0.871 0.922 0.98]);
h.panel6 = uipanel('units', 'normalized', 'position', [0.83 0.02 0.15 0.5], 'backgroundcolor', [0.871 0.922 0.98], 'title', 'Modules');


h.load_ecg_button = uicontrol('parent', h.panel1, 'Style', 'pushbutton', 'string', 'Load ECG', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.02 0.9 0.96 0.07]);

h.load_event_button = uicontrol('parent', h.panel1, 'Style', 'pushbutton', 'string', 'Load events', ...
                              'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.02 0.8 0.96 0.07]);

h.clear_button = uicontrol('parent', h.panel1, 'Style', 'pushbutton', 'string', 'Clear view', ...
                          'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.02 0.7 0.96 0.07]);

h.ht1 = uicontrol('parent', h.panel1, 'Style', 'text', 'string', 'Use arrow-keys or buttons to scroll back and forth ECG-trace and events', ...
                          'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.02 0.5 0.96 0.14], ...
                          'backgroundcolor', get(h.panel1,'backgroundcolor'));
                                       
h.ht2 = uicontrol('parent', h.panel1, 'Style', 'text', 'string', 'Click ECG-trace to manually add r-peaks', ...
                          'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.02 0.35 0.96 0.14], ...
                          'backgroundcolor', get(h.panel1,'backgroundcolor'));
                      
h.ht3 = uicontrol('parent', h.panel1, 'Style', 'text', 'string', 'Ctrl + click ECG to interpolate an r-peak between two existing r-peaks', ...
                          'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.02 0.2 0.96 0.14],...
                          'backgroundcolor', get(h.panel1,'backgroundcolor'));
                      
                      
h.about_button = uicontrol('parent', h.panel1, 'Style', 'pushbutton', 'string', 'About Ecgtool', ...
                          'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.02 0.12 0.96 0.07]);
                      
h.quit_button = uicontrol('parent', h.panel1, 'Style', 'pushbutton', 'string', 'Quit', ...
                          'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.02 0.02 0.96 0.07]);

h.ecg_move_text = uicontrol('parent', h.panel2, 'Style', 'text', 'string', 'Browse ECG', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', [0.05 0.88 0.4 0.09], ...
							'backgroundcolor', get(h.panel2,'backgroundcolor'));
			
h.ecg_back_button = uicontrol('parent', h.panel2, 'Style', 'pushbutton', 'string', '<-', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.45 0.88 0.25 0.09]);

h.ecg_forw_button = uicontrol('parent', h.panel2, 'Style', 'pushbutton', 'string', '->', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.74 0.88 0.25 0.09]);

h.event_move_text = uicontrol('parent', h.panel2, 'Style', 'text', 'string', 'Browse events', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', [0.05 0.75 0.4 0.09], ...
							'backgroundcolor', get(h.panel2,'backgroundcolor'));
					 
h.event_back_button = uicontrol('parent', h.panel2, 'Style', 'pushbutton', 'string', '<-', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.45 0.75 0.25 0.09]);

h.event_forw_button = uicontrol('parent', h.panel2, 'Style', 'pushbutton', 'string', '->', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.74 0.75 0.25 0.09]);

h.y_scale_text = uicontrol('parent', h.panel2, 'Style', 'text', 'string', 'Scale Y-axis (s)', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', [0.05 0.60 0.4 0.09], ...
                            'backgroundcolor', get(h.panel2,'backgroundcolor'));

h.y_scale_slider = uicontrol('parent', h.panel2, 'Style', 'slider', 'min', -1, 'max', 2, 'value', 1, ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.45 0.60 0.53 0.09]);

h.clickrange_text = uicontrol('parent', h.panel2, 'Style', 'text', 'string', 'Click range (px)', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', [0.05 0.45 0.4 0.09], ...
                            'backgroundcolor', get(h.panel2,'backgroundcolor'));

h.click_range_edit = uicontrol('parent', h.panel2, 'Style', 'edit', 'string', '30', ...
                                 'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.78 0.45 0.20 0.09]);

h.prestimtime_text = uicontrol('parent', h.panel2, 'Style', 'text', 'string', 'Pre-stim time (s)', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', [0.05 0.32 0.4 0.09], ...
                            'backgroundcolor', get(h.panel2,'backgroundcolor'));

h.prestim_time_edit = uicontrol('parent', h.panel2, 'Style', 'edit', 'string', '-3.5', ...
                                 'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.78 0.32 0.20 0.09]);

h.x_scale_text = uicontrol('parent', h.panel2, 'Style', 'text', 'string', 'Scale X-axis (s)', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', [0.05 0.19 0.4 0.09], ...
                            'backgroundcolor', get(h.panel2,'backgroundcolor'));

h.x_scale_edit = uicontrol('parent', h.panel2, 'Style', 'edit', 'string', '10', ...
                                 'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.78 0.19 0.20 0.09]);
							 
h.invert_button = uicontrol('parent', h.panel2, 'Style', 'pushbutton', 'string', 'invert ECG', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.27 0.02 0.45 0.09]);

h.peak_algorithm_popup = uicontrol('parent', h.panel3, 'Style', 'popupmenu', 'string', {'ecg_1000-algorithm', 'r-peaks algorithm'}, ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.1 0.8 0.8 0.09]);

h.detect_peaks_button = uicontrol('parent', h.panel3, 'Style', 'pushbutton', 'string', 'Detect/remove r-peaks', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.01 0.1 0.5 0.3]);

h.import_peaks_button = uicontrol('parent', h.panel3, 'Style', 'pushbutton', 'string', 'import r-peaks', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.58 0.1 0.4 0.3]);

h.information_uitable = uitable('Parent', h.panel4, 'units', 'normalized', 'position', [0.05 0.05 0.9 0.9], ...
	                            'rowname', [], 'columnname', [], 'ColumnWidth', {150 230});

h.hr_disborder_text = uicontrol('parent', h.panel5, 'Style', 'text', 'string', 'HR display borders (s)', ...
                                'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.03 0.1 0.3 0.3],...
                                'backgroundcolor', get(h.panel5,'backgroundcolor'));

h.hr_dispmin_edit = uicontrol('parent', h.panel5, 'Style', 'edit', 'string', '0', ...
                                 'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.4 0.1 0.2 0.3]);

h.hr_disborder_text2 = uicontrol('parent', h.panel5, 'Style', 'text', 'string', '-', ...
                                'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.62 0.1 0.05 0.3],...
                                'backgroundcolor', get(h.panel5,'backgroundcolor'));
                             
h.hr_default_button = uicontrol('parent', h.panel5, 'Style', 'pushbutton', 'string', 'Default HR borders', ...
                                'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.03 0.6 0.4 0.3]);

h.hr_updateatclick_button = uicontrol('parent', h.panel5, 'Style', 'togglebutton', 'string', 'Update HR at click', 'value', 1, ...
                                'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.53 0.6 0.4 0.3]);

h.hr_dispmax_edit = uicontrol('parent', h.panel5, 'Style', 'edit', 'string', '1', ...
                                 'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.7 0.1 0.2 0.3]);

h.modules_listbox = uicontrol('parent', h.panel6, 'Style', 'listbox', 'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.05 0.2 0.9 0.75]);

h.modules_button = uicontrol('parent', h.panel6, 'Style', 'pushbutton', 'string', 'Launch module', ...
                                 'horizontalalignment', 'center', 'units', 'normalized', 'position', [0.02 0.02 0.96 0.07]);

% set callbackfunctions to buttons etc.
set(h.load_ecg_button, 'Callback', {@load_ecg_Callback, h});
set(h.load_event_button, 'Callback', {@load_events_Callback, h});
set(h.clear_button, 'Callback', {@clear_Callback, h});
set(h.quit_button, 'Callback', {@quit_Callback, h});
set(h.about_button, 'Callback', {@about_Callback, h});
set(h.ecg_back_button, 'Callback', {@ecg_back_Callback, h});
set(h.ecg_forw_button, 'Callback', {@ecg_forw_Callback, h});
set(h.event_back_button, 'Callback', {@event_back_Callback, h});
set(h.event_forw_button, 'Callback', {@event_forw_Callback, h});
set(h.y_scale_slider, 'Callback', {@display_edit_Callback, h});
set(h.detect_peaks_button, 'Callback', {@detect_peaks_Callback, h});
set(h.import_peaks_button, 'Callback', {@loadPeaks_Callback, h});
set(h.invert_button, 'Callback', {@invert_Callback, h});
set(h.click_range_edit, 'Callback', {@display_edit_Callback, h});
set(h.x_scale_edit, 'Callback', {@display_edit_Callback, h});
set(h.modules_button, 'Callback', {@modules_button_Callback, h});
set(h.hr_dispmin_edit, 'callback', {@changeHrBordersCb, h});
set(h.hr_dispmax_edit, 'callback', {@changeHrBordersCb, h});
set(h.hr_default_button, 'callback', {@defaultHrBordersCb, h});

set(gcf,'CloseRequestFcn', {@ecgtool_CloseRequestFcn, h});

% save some function handles
%setappdata(gcf, 'fhpiirraData', {@drawData, h}); 
%setappdata(gcf, 'fhpiirraTaajuudet', {@drawFrequencies, h}); 

% initialize curves for ecg, frequencies etc.
ploth.hr = [];
ploth.areah = [];
set(h.axes2, 'UserData', ploth);

% format variables and drawing areas
clearData(h);
setappdata(h.ecgtool, 'workdir', pwd);

% Keypressfunctions to buttons
hChildren = get(gcf, 'Children');
hPushbuttons = findobj(hChildren, 'style','pushbutton');
set(hPushbuttons, 'KeyPressFcn', {@keyPress, h});

% ...and to figure itself
set(gcf,'KeyPressFcn', {@keyPress, h});

% last, find which modules are present and display them
if ~exist([h.rootdir filesep 'modules'], 'dir');
    return;
end

modules = dir([h.rootdir filesep 'modules' filesep '*.m']);

% generate list of available modules from the modules-folder
listmodules = {};
for i=1:length(modules)
	[a b c] = fileparts(modules(i).name);
	listmodules{i} = b;
end

set(h.modules_listbox, 'string', listmodules);

%%%%%%%%%% distrib extra
listmodules = {'hrAnalysis',  'RSAAnalysis'};

set(h.modules_listbox, 'string', listmodules);
%%%%%%%%%%%%%

function load_ecg_Callback(~, ~, h)

workdir = getappdata(h.ecgtool, 'workdir');
FilterSpec = {'*.dat;*.vhdr;*.mat;*.txt', 'ECG-files (Neuroscan (.dat), Analyzer (.vhdr), Netstation (.mat), Nexus(.txt.))'};

[filename, dpath] = uigetfile(FilterSpec, 'Select ECG-file', workdir);

if filename == 0
	return;
end

setappdata(h.ecgtool, 'workdir', dpath);

clearEvents();

[a, b, c] = fileparts(filename);

load_events_also = 0;
if (strcmp(c, '.dat'))
	[ecg_data, srate] = loadEv2Ecg([dpath filesep filename]);
elseif (strcmp(c, '.vhdr'))
	[ecg_data, srate] = loadBrainvisionEcg([dpath filesep filename]);
elseif (strcmp(c, '.mat'))
	[ecg_data, srate] = loadNetstationEcg([dpath filesep filename]);
elseif (strcmp(c, '.txt'))
	[ecg_data, srate, event_times, event_ids] = loadNexus([dpath filesep filename]);
    load_events_also = 1;
end

clearData(h);

% was there r-peak file for this file before?
rpeak_filename = [dpath b '_Rpeaks.txt'];

if exist(rpeak_filename, 'file') == 2

	[answer] = questdlg('A previous R-peak detection exists for this file, would you like to load that?', ...
		                'Use existing R-peaks', 'Yes', 'No', 'Yes');
	
	if (strcmp(answer, 'Yes'))
		detected_peaks = load(rpeak_filename);
		setappdata(gcf, 'rpeaks', detected_peaks);
	end
end

% jump at the beginning
setappdata(gcf, 'startloc', 0);

setappdata(gcf, 'ecg_data', ecg_data);
setappdata(gcf, 'srate', srate);
setappdata(gcf, 'file', [dpath filename]);
set(h.hr_dispmax_edit, 'string', num2str(length(ecg_data)/srate));

drawECG(h);
calcDrawHr(h);
drawLocationArea(h, 'new');
updateInformation(h, [b], num2str(srate), num2str(length(ecg_data)/srate), '', a, '');

if load_events_also
    load_events(h, a, b, event_times, event_ids);
end


function modules_button_Callback(~, ~, h)

str = get(h.modules_listbox, 'String');
selection = get(h.modules_listbox, 'value');

fcn = str{selection};

% create the ECGDATA datastruct to pass to the modules
ECGDATA.rootdir = h.rootdir;
ECGDATA.file = getappdata(gcf, 'file');
ECGDATA.ecg = getappdata(gcf, 'ecg_data');
ECGDATA.srate = getappdata(gcf, 'srate');
ECGDATA.event_times = getappdata(gcf, 'event_times');
ECGDATA.event_ids = getappdata(gcf, 'event_ids');
ECGDATA.event_order_nums = getappdata(gcf, 'event_order_nums');
ECGDATA.rpeaks = getappdata(gcf, 'rpeaks');

f_handles = [];

% evaluate modules with parameters: ecgdata and functionhandles
%eval([fcn '(ECGDATA, f_handles)']);

%%%%% distrib extra
switch fcn
    case 'hrAnalysis'
        hrAnalysis(ECGDATA, f_handles);
    case 'RSAAnalysis'
        rrAnalysis(ECGDATA, f_handles);
end
%%%%%

function load_events_Callback(~, ~, h)
%open_event;

if isempty(getappdata(gcf,'ecg_data'))
   return; 
end

workdir = getappdata(h.ecgtool, 'workdir');
FilterSpec = {'*.ev2;*.vmrk;*.mat;*.txt', 'Event-files (Neuroscan (.ev2), Analyzer (.vmrk), Netstation (.mat), Hand-made-events (.txt))'};

[filename, dpath] = uigetfile(FilterSpec, 'Select event-file', workdir);

if filename == 0
	return;
end

setappdata(h.ecgtool, 'workdir', dpath);

[a, b, c] = fileparts(filename);

if (strcmp(c, '.ev2'))
	[event_times, event_ids] = loadEv2Events([dpath filesep filename]);
elseif (strcmp(c, '.vmrk'))
	[event_times, event_ids] = loadBrainvisionEvents([dpath filesep filename]);
elseif (strcmp(c, '.txt'))
	[event_times, event_ids] = loadHandmadeEvents([dpath filesep filename]);
elseif (strcmp(c, '.mat'))
	[event_times, event_ids] = loadNetstationEvents([dpath filesep filename]);
end

load_events(h, a, b, event_times, event_ids)

function load_events(h, fpath, fname, event_times, event_ids)

uniq_ids = unique(event_ids);

% 1 or more events
if isempty(uniq_ids)
    return;
end

% choose which events to display
[selection, ok] = listdlg('ListString', uniq_ids, 'SelectionMode', 'multi', 'promptstring', ...
		                  'Select the events to use in the analysis:');

if ~ok
	return;
end

combined_ids = zeros(length(event_ids),1);

for i = 1:length(selection)
	% add the events to the combined id's (to get a vector length of
	% event_ids with 1 on events that were selected by user)
	combined_ids = combined_ids + strcmp(event_ids, uniq_ids{selection(i)});
end

selected_event_times = event_times(combined_ids == 1);
selected_event_ids = event_ids(combined_ids == 1);

setappdata(gcf, 'event_times', selected_event_times);
setappdata(gcf, 'event_ids', selected_event_ids);
setappdata(gcf, 'event_order_nums', 1:length(selected_event_times));

drawECG(h);

ecg_data = getappdata(gcf, 'ecg_data');
srate = getappdata(gcf, 'srate');
calcDrawHr(h); 
drawLocationArea(h, 'new');

updateInformation(h, [fname], num2str(srate), num2str(length(ecg_data)/srate), ...
                  num2str(length(selected_event_times)), fpath, num2str(selected_event_times(end)/srate));

function clearData(h)
% clear all data and prepare the gui for a new file

clearEcg;
clearEvents;

%reset diagrams and buttondownfcn's
emptyAxes(h.axes1);
emptyAxes(h.axes2);

if isappdata(gcf, 'hEvents')
	hEvents = getappdata(gcf, 'hEvents');
	delete(hEvents(:,3));
	rmappdata(gcf, 'hEvents');
end

% zooming-slider to 0.1
set(h.y_scale_slider, 'Value', 0.1);

if ~isempty(getappdata(gcf,'rpeaks'))
	rmappdata(gcf,'rpeaks');
end

setappdata(gcf, 'startloc', 1);
updateInformation(h, 'No file loaded', '', '', '', '', '');


function ecg_back_Callback(~, ~, h)
moveEEGOneStep(h, 'backward');


function ecg_forw_Callback(~, ~, h)
moveEEGOneStep(h, 'forward');


function detect_peaks_Callback(~, ~, h)
detectRpeaks(h);


function ecgtool_CloseRequestFcn(hObject, ~, h)
% Hint: delete(hObject) closes the figure

delete(hObject);


function event_back_Callback(~, ~, h)
browseEvents(h, 'back');


function event_forw_Callback(~, ~, h)
browseEvents(h, 'forward');


function loadPeaks_Callback(~, ~, h)

if isempty(getappdata(gcf, 'ecg_data'))
    msgbox('ECG-data not loaded.','Error','error');
    return;
end

FilterSpec = {'*.txt', 'File containing r-peak times (.txt)'};

[filename, dpath] = uigetfile(FilterSpec);


if fname == 0
    return;
end

%load detected_peaks from a file
detected_peaks = load([dpath filesep filename]);

if max(detected_peaks) > length(getappdata(gcf, 'ecg_data'))
    msgbox('ECG-data and R-peaks do not match.','Error','error');
    return;
end

setappdata(gcf, 'rpeaks', detected_peaks);

% draw ECG
drawECG(h);


function display_edit_Callback(~, ~, h)
drawECG(h);
drawLocationArea(h, 'update');


function detectRpeaks(h)
	
ecg_data = getappdata(gcf,'ecg_data');
srate = getappdata(gcf, 'srate');

% if some R-peaks detected -> clear detection
% if no R-peaks detected -> do peak detection

if isempty(ecg_data)
    msgbox('ECG-data not loaded.', 'Error');
    return;
end

if isempty(getappdata(gcf, 'rpeaks'))  % no r-peaks present

    if get(h.peak_algorithm_popup, 'Value') == 1
        R = ecg_1000(ecg_data);  % calculate r-peaks with ecg-1000-mfile algorithm
    elseif get(h.peak_algorithm_popup, 'Value') == 2
        R=rpeak_ecgtwave(ecg_data, srate);  % calculate R-peaks with another open-source algorithm
    end

    setappdata(gcf, 'rpeaks',R); % save peaks
    saveRpeaks;

else % peaks present -> empty
    setappdata(gcf, 'rpeaks',[]);
end

calcDrawHr(h); 
drawLocationArea(h, 'new');
drawECG(h);


    
function ecgClick(~, ~, h)
% Clickfunction for the ECG-curve. Find click location and calculate if
% peaks nearby. Close or add regarding if peaks nearby or not.

% may be a "rude" function :)

ecgrange = str2double(get(h.click_range_edit, 'String'));
ecg_data = getappdata(h.ecgtool, 'ecg_data');
srate = getappdata(h.ecgtool, 'srate');
detected_peaks = getappdata(h.ecgtool, 'rpeaks');
mouz = get(gca, 'Currentpoint');
mouzloc = mouz(1,1);

if ismember('control', get(h.ecgtool, 'currentmodifier'))
    % control was pressed -> interpolation between two rpeaks
        
    before = find( detected_peaks < mouzloc*srate, 1, 'last');
    after = find(mouzloc*srate < detected_peaks, 1, 'first');
    
    if isempty(before) || isempty(after)
        return;
    end
    
    detected_peaks(end+1) = round(mean([detected_peaks(before), detected_peaks(after)]));
    
else
    % make sure not below zero or above timelimit
    if (ceil(mouz(1,1) * srate-ecgrange) < 0)
        mouzloc = (ecgrange + 1) / srate;
    end

    ecglen = length(ecg_data);

    % upper limit
    if (ceil(mouz(1,1) * srate + ecgrange) >= ecglen)
        mouzloc = (ecglen - ecgrange) / srate;
    end

    % check if R-peak exists between [-ecgrange, click, +ecgrange]
    % make vector ~(-ecgrange)...mouzloc...~ecgrange by stepsize one

    first_to_check = ceil(mouzloc * srate - ecgrange);
    last_to_check = first_to_check + 2 * ecgrange;
    %check_area = first_to_check:1:last_to_check;

    a = find(first_to_check <= detected_peaks);
    b = find(detected_peaks <= last_to_check);
    peaks_in_range = intersect(a, b);

    if isempty(peaks_in_range)
        % no clicks found inside range -> new peak

        [~, newpeakIndex] = max(ecg_data(first_to_check:last_to_check));

        detected_peaks(end+1) = first_to_check + newpeakIndex-1;
    else
        % peaks found -> remove first found
        detected_peaks(peaks_in_range(1)) = [];
    end
end

% save and redraw
setappdata(gcf, 'rpeaks', sort(detected_peaks));

% redraw
drawECG(h);
saveRpeaks;

if(get(h.hr_updateatclick_button, 'value'))
    calcDrawHr(h);
    drawLocationArea(h, 'new');
end


function moveEEGOneStep(h, direction)

if isempty(getappdata(gcf,'ecg_data'))
   return;
end

startloc = getappdata(gcf,'startloc');
x_scale = str2num(get(h.x_scale_edit, 'String'));
srate = getappdata(gcf,'srate');

switch direction
    case 'forward'
        %calc the new startpoint
        new_startloc = startloc + x_scale * srate;

    case 'backward'
        new_startloc = startloc - x_scale * srate;
end

setappdata(gcf, 'startloc', new_startloc);
drawECG(h);
drawLocationArea(h, 'update');
%calcAndPlotHr(h);



function drawECG(h)
% Draws ECG. Re-draw every time when moving back or forward.

startloc = round(getappdata(gcf, 'startloc'));

ecg_data = getappdata(gcf,'ecg_data');
event_times = getappdata(gcf,'event_times');
event_ids = getappdata(gcf, 'event_ids');
event_order_nums = getappdata(gcf, 'event_order_nums');
detected_peaks = getappdata(gcf,'rpeaks');
srate = getappdata(gcf,'srate');
x_scaling = str2num(get(h.x_scale_edit, 'String'));
y_scaling = get(h.y_scale_slider, 'Value');

% set drawing area
set(h.ecgtool, 'currentaxes', h.axes1);

if isempty(ecg_data)
    return;
end
	
endloc = round(startloc + x_scaling*srate);

% not below or over
if  endloc > length(ecg_data)
    startloc = length(ecg_data) - x_scaling * srate;
    endloc = round(startloc + x_scaling * srate);
elseif startloc < 0.000001
    startloc = 1;
    endloc = round(startloc + x_scaling * srate);
end

% find which peaks are inside windows and draw them
a = find(detected_peaks > startloc, 1 );
b = find(detected_peaks < endloc, 1, 'last');

% draw ecg and peaks
plotsh = plot((startloc:endloc)/srate, ecg_data((startloc:endloc), 1),'k', detected_peaks(a:b)/srate, ecg_data(detected_peaks(a:b)), 'ro');
set(plotsh(1), 'buttondownfcn', {@ecgClick, h});

% if rpeaks in the drawing area
if length(plotsh) > 1
    set(plotsh(2), 'buttondownfcn', {@ecgClick, h});
end

hold on;
counter = 1;
rpeakids = [];
for i = a:b
    rpeakids(counter) = text(detected_peaks(i)/srate, ecg_data(detected_peaks(i)), ['  ' num2str(i)], 'fontsize', 10, 'buttondownfcn', {@ecgClick, h}, ...
                             'color', 'red');
    counter = counter + 1;
end
hold off;

if ~isempty(event_times) && ~isempty(ecg_data)
    % if both ecg and events are there -> draw also events
    hevobs = getappdata(gcf, 'hEvents');

    if size(hevobs, 2) > 0
        delete(hevobs(:,3));
    end

    [hevent_objects] = drawEvents(h, startloc, endloc, event_times, event_ids, event_order_nums, ecg_data(startloc:endloc), srate, y_scaling);

    setappdata(gcf, 'hEvents', hevent_objects);
end

% difference in peak and bottom
howtall = round((max(ecg_data(startloc:endloc)) - min(ecg_data(startloc:endloc)))/2);

%tune drawing area with y-skaling
axis([startloc/srate endloc/srate ...
min(ecg_data(startloc:endloc)) - y_scaling*abs(howtall - 5) max(ecg_data(startloc:endloc)) + y_scaling*abs(howtall - 5)]);

setappdata(gcf, 'startloc', startloc);

set(h.axes1, 'buttondownfcn', {@ecgClick, h})

% set labels
title('ECG signal');
xlabel '';
ylabel 'µV';

    
function hEvents = drawEvents(h, startloc, endloc, event_times, event_ids, event_order_nums, ecg_data, srate, y_scale)
% Draws event identifiers on top of the eeg-curve, return (drawn) objects handles

% drawing area limits
y_diff = round((max(ecg_data) - min(ecg_data)) / 2);

y_bot = min(ecg_data) - y_scale * (y_diff - 5);
y_top = max(ecg_data) + y_scale * (y_diff - 5);

y_axis_height = y_top - y_bot;


% find the events inside the window
a = find(event_times > startloc, 1 );
b = find(event_times < endloc, 1, 'last' );

hEvents = [];

% window contains events
if isempty(a) || isempty(b) 
   return; 
end

% and draw the lines, text and removebutton
if ~(a == b || (a < b)) % one event or first smaller than last
    return
end

i = 1;
for j = a:b

    % draw line
    % set object handles to hEvent-matrix as [line, text, button]
    hEvents(i,1) = line([event_times(j) / srate, event_times(j) / srate], ...
        [y_bot, y_top], 'LineWidth', 1, 'LineStyle', '-', 'Color', 'blue'); % -- :

    set(hEvents(i,1), 'HitTest', 'off'); % no clicktest in lines -> r-peak removal possible

    % draw text
    event_id_txt = strcat(num2str(event_order_nums(j)), './', event_ids(j));

    hEvents(i,2) = text(event_times(j)/srate + 0.05, (y_bot + 0.05*y_axis_height), ...
                        event_id_txt, 'FontSize',12);    %, '/', num2str(event_data(j))

    % draw removebutton
    event_x_location_window =  0.05 + (event_times(j) - startloc) / (srate*str2num(get(h.x_scale_edit, 'string'))) * 0.9;

    hEvents(i,3) = uicontrol('style', 'pushbutton', 'string', 'Rm', 'units', 'normalized', 'position', ...
                             [event_x_location_window 0.96 0.02 0.02], 'callback', {@rmevent_Callback, h, j}, ...
                             'KeyPressFcn', {@keyPress, h});

    i = i + 1;
end

set(hEvents(:,2), 'Clipping', 'on');


function browseEvents(h, front_or_back)
% jumps to the next or previous event.

if isequal(front_or_back, 'forward')
	parameter = 1;
else
	parameter = -1;
end

if isempty(getappdata(gcf, 'ecg_data')) || isempty(getappdata(gcf, 'event_times'))
	return;
end

srate = getappdata(gcf, 'srate');
prestimtime = str2num(get(h.prestim_time_edit, 'string')) * srate; %millisekuntia
startloc = getappdata(gcf, 'startloc');
event_times = getappdata(gcf, 'event_times');

i = 1; %haetaan eventtiä+vaihesiirtoa edeltävän tapahtuman indeksi i
while event_times(i) < startloc-prestimtime && event_times(i) < event_times(length(event_times))
	i = i + 1;
end

if (startloc - prestimtime < event_times(1) || i == 1) && isequal(front_or_back,'back') % check don't go "under"
	startloc = event_times(1) + prestimtime;

elseif ((startloc + prestimtime) > event_times(length(event_times)) || i == length(event_times))... % check dont go "over"
		 && isequal(front_or_back, 'forward')
	startloc = event_times(length(event_times)) + prestimtime;

elseif (startloc - prestimtime) > event_times(length(event_times)) ... % check dont go "over"
		&& isequal(front_or_back, 'back') %ja taakse
	startloc = event_times(length(event_times)) + prestimtime;
	
elseif startloc == (event_times(i) + prestimtime) %tarkistetaan, ollaanko jo eventin kohdalla
	while event_times(i+parameter) == event_times(i) %tähän mennään jos useampi samassa kohdassa, loopataan siitä yli
		i = i + 1;
	end
	startloc = event_times(i+parameter) + prestimtime; 

elseif isequal(front_or_back, 'back') % between events, going back
	startloc = event_times(i-1) + prestimtime;

else  % forward
	startloc = event_times(i) + prestimtime;
end

setappdata(gcf, 'startloc', startloc);

drawECG(h);
drawLocationArea(h, 'update');
    
    
function rmevent_Callback(~, ~, h, eventnumber)
% Clicking the remove event-button goes to this function

button = questdlg('Would you like to remove this event?', 'Query', 'Yes', 'No', 'No');
%button = 'Yes';

if ~isequal(button, 'Yes') % if user wants to remove event
	return;
end

event_times = getappdata(gcf, 'event_times');
event_ids = getappdata(gcf, 'event_ids');
event_order_nums = getappdata(gcf, 'event_order_nums');

if length(event_times(:)) == 1 
    % if only one event left -> remove all
	rmappdata(gcf,'event_ids');
	rmappdata(gcf,'event_times');
    rmappdata(gcf, 'event_order_nums');
    
else % if more than one event left
	event_times(eventnumber) = [];
	event_ids(eventnumber) = [];
    event_order_nums(eventnumber) = [];

	setappdata(gcf,'event_ids', event_ids); 
	setappdata(gcf,'event_times', event_times);
    setappdata(gcf, 'event_order_nums', event_order_nums);
end

file = getappdata(gcf, 'file');
ecg_data = getappdata(gcf, 'ecg_data');
srate = getappdata(gcf, 'srate');
[a, b, c] = fileparts(file);

updateInformation(h, [b], num2str(srate), num2str(length(ecg_data)/srate), ...
                  num2str(length(event_times)), a, num2str(event_times(end)/srate));

drawECG(h);

if(get(h.hr_updateatclick_button, 'value'))
    calcDrawHr(h);
    drawLocationArea(h, 'new');
end

function defaultHrBordersCb(~,~,h)
ecg = getappdata(gcf, 'ecg_data');
srate = getappdata(gcf, 'srate');

if isempty(ecg)
    return;
end

set(h.hr_dispmax_edit, 'string', num2str(length(ecg)/srate));
set(h.hr_dispmin_edit, 'string', '0');
set(h.axes2, 'xlim', [0 length(ecg)/srate])


function changeHrBordersCb(~,~,h)

set(h.axes2, 'xlim', [str2num(get(h.hr_dispmin_edit, 'string')) str2num(get(h.hr_dispmax_edit, 'string'))])


function updateInformation(h, fname, srate, ecgduration, lenevtimes, workdir, lastev)
%update changes to information panel

%information = get(h.information_uitable, 'Data');

information(1,1) = {'Root directory'};
information(1,2) = {h.rootdir};
information(2,1) = {'Filename (ECG)'};
information(2,2) = {fname};
information(3,1) = {'ECG-signal duration (s)'};
information(3,2) = {ecgduration};
information(4,1) = {'Rate (Hz)'};
information(4,2) = {srate};

information(5,1) = {'R-peaks output-file'};
information(5,2) = {'-'};
information(6,1) = {''};
information(6,2) = {''};
information(7,1) = {'Work-directory'};
information(7,2) = {workdir};
information(8,1) = {'Number of events'};
information(8,2) = {lenevtimes};
information(9,1) = {'Last event'};
information(9,2) = {lastev};

set(h.information_uitable, 'Data', information);

    
function saveRpeaks()
% function saves the r-peaks to the same folder as the file.

file = getappdata(gcf, 'file');
[a, b, c] = fileparts(file);

rpeaks = getappdata(gcf, 'rpeaks');

rpeaksfile = [a filesep b '_Rpeaks.txt'];

% save peaks
fid = fopen(rpeaksfile, 'wt');

for i=1:length(rpeaks)
	fprintf(fid, '%g ', rpeaks(i));
end

fclose(fid);


function emptyAxes(axhandle)
% Clear all information on the axes presented on parameter.

cla(axhandle);
axis(axhandle,[0 1 0 1]);
set(axhandle, 'buttondownfcn', '');

%set(axhandle, 'userdata', []);


function clearEcg()
% clear all the appdata-variables that have to do with ecg

if ~isempty(getappdata(gcf, 'ecg_data'))
	rmappdata(gcf, 'ecg_data');
end

if ~isempty(getappdata(gcf, 'srate'))
	rmappdata(gcf,'srate');
end

if ~isempty(getappdata(gcf, 'file'))
	rmappdata(gcf,'file');
end


function clearEvents()
% clear all the event-related appdata-variables

if ~isempty(getappdata(gcf,'event_times'))
	rmappdata(gcf,'event_times');
end

if ~isempty(getappdata(gcf,'event_ids'))
	rmappdata(gcf,'event_ids')
end

if ~isempty(getappdata(gcf,'event_order_nums'))
	rmappdata(gcf,'event_order_nums')
end


function keyPress(src, evnt, h)
% Keypress-function for the main ecgtool-window. By pressing arrow buttons
% you move on the curve / events

k = evnt.Key;

switch(k)
    case 'leftarrow'
        moveEEGOneStep(h, 'backward');
    case 'rightarrow'
        moveEEGOneStep(h, 'forward');
    case 'uparrow'
        browseEvents(h, 'forward');
    case 'downarrow'
        browseEvents(h, 'back');
end


function quit_Callback(~, ~, h)

close(h.ecgtool); % close window -> go to closerequestfunction


function about_Callback(~, ~, h)
aboutECGtool;


function clear_Callback(~, ~, h)
clearData(h);


function invert_Callback(~, ~, h)

if isempty(getappdata(gcf, 'ecg_data'))
    return;
end

ecg_data = getappdata(gcf, 'ecg_data');

% calculate mirroring-level
mirrorlevel = min(ecg_data)+(max(ecg_data)-min(ecg_data))/2;

% double and sum to inverse ECG
setappdata(gcf, 'ecg_data', 2*mirrorlevel-ecg_data);

drawECG(h);


function calcDrawHr(h)
% A function that updates the frequency-graph.

ecg_data = getappdata(gcf, 'ecg_data');
srate = getappdata(gcf, 'srate');
detected_peaks = (getappdata(gcf, 'rpeaks')/srate)*1000;

if (isempty(ecg_data) || isempty(detected_peaks) || length(detected_peaks) < 8)
    % just clear axes2
    cla(h.axes2);
    return;
end

[heart_rates, times] = calcRoughHrWindows(srate, detected_peaks, 500);

drawHeartRates(times, heart_rates, h);
axis(h.axes2, [0 length(getappdata(gcf, 'ecg_data'))/getappdata(gcf, 'srate') 0 250]);


function [heart_rates, times1] = calcRoughHrWindows(rate, detected_peaks, window_length)

% window count so that we stay inside the area
first_window = ceil((min(detected_peaks)/1000));
last_window = floor(max(detected_peaks)/1000);

window_count = floor((last_window-first_window)*(1000/window_length));

% drop the last window because some files seem to have an error with that
window_count = window_count-1;

% calculate heart rates in each location
aika = first_window * 1000;
for j = 1:window_count % loop for each column
	HR(j,1) = calcHR(aika/1000, detected_peaks, 0, window_length);
	times1(j,1) = aika/1000;
	aika = aika + window_length; % increase time by window length
end

heart_rates = 1./(HR)*60*1000;


function drawHeartRates(times, heart_rates, h)
% plot HR and set buttondownfcn's

event_times = getappdata(h.ecgtool, 'event_times');
etags = zeros(length(event_times), 1)+200;

a = plot(h.axes2, times, heart_rates, 'k', event_times/getappdata(h.ecgtool, 'srate'), etags, 'bx');
set(gcf, 'currentaxes', h.axes2);
xlabel 'time(s)';
ylabel 'BPM';

set(a, 'buttondownfcn', {@axes2Click, h});


function drawLocationArea(h, opt)
% plot the area on top of axes2 to a location in ECG

srate = getappdata(gcf, 'srate');
prestim_time = str2num(get(h.prestim_time_edit, 'string'));
startpoint = getappdata(gcf, 'startloc');
x_offset = str2num(get(h.x_scale_edit, 'string'));

xmin = (startpoint - prestim_time)/srate;
xmax = xmin + x_offset;

% check if startpoint is under 0 -> set xmin to 0
if xmin < 0
   xmin = 0;
end

selectioncolor =   [0.6235    0.7137    0.8039];

switch opt
    case ('new')
        axes(h.axes2);
        hold on;
        a2 = area(h.axes2, [xmin xmax], [250 250], 'edgecolor', 'k', 'facecolor', selectioncolor);
        alpha(0.5);
        hold off;
        
        % save the new area handle to userdata of the axes
        set(h.axes2, 'userdata', a2);
        set(a2, 'buttondownfcn', {@axes2Click, h});

%    case ('del')
%        % delete the old area
%        if ishandle(get(h.axes2, 'userdata'))
%            delete(get(h.axes2, 'userdata'))
%        end
%        set(h.axes2, 'userdata', []);
        
    case ('update')
        oldax = get(h.axes2, 'userdata');
        set(oldax, 'xdata', [xmin xmax]);
end

set(h.axes2, 'xlim', [str2num(get(h.hr_dispmin_edit, 'string')) str2num(get(h.hr_dispmax_edit, 'string'))]);

set(h.axes2, 'buttondownfcn', {@axes2Click, h});


function axes2Click(gcbo, ~, h)

srate = getappdata(gcf, 'srate');
mouz = get(gca, 'Currentpoint');
mousepoint = mouz(1,1);

setappdata(gcf, 'startloc', ((mousepoint + str2num(get(h.prestim_time_edit, 'string')))) * srate);

drawLocationArea(h, 'update');
drawECG(h);


