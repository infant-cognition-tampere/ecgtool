function hrAnalysis(ECGDATA, fhandles)

% define ui-elements
hfig = figure('units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);

set(hfig, 'menubar', 'none', 'numbertitle', 'off', 'name', 'Ekgtool 3.0', 'color', 'w');

% set backgroung image
hBg =  axes('units','normalized', 'position',[0 0 1 1]);

% Move the background axes to the bottom
uistack(hBg, 'bottom'); 

set(hBg,'handlevisibility','off', 'visible','off');

panelcol = [0.894 0.941 0.942];

h.rootdir = ECGDATA.rootdir;

h.hranalysis = gcf;

h.panel1 = uipanel('units', 'normalized', 'position', [0.01 0.01 0.21 0.98], 'backgroundcolor', panelcol);


h.winlen_text = uicontrol('parent', h.panel1, 'Style', 'text', 'string', 'Analysis interval (ms)', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', ...
							[0.02 0.93 0.69 0.03], 'backgroundcolor', panelcol);

h.winlen_edit = uicontrol('parent', h.panel1, 'Style', 'edit', 'string', '500', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', ...
							[0.75 0.93 0.23 0.03], 'backgroundcolor', panelcol);

h.prestim_text = uicontrol('parent', h.panel1, 'Style', 'text', 'string', 'Pre-stimulus time (ms)', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', ...
							[0.02 0.88 0.69 0.03], 'backgroundcolor', panelcol);

h.prestim_edit = uicontrol('parent', h.panel1, 'Style', 'edit', 'string', '-500', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', ...
							[0.75 0.88 0.23 0.03], 'backgroundcolor', panelcol);

h.poststim_text = uicontrol('parent', h.panel1, 'Style', 'text', 'string', 'Post-stimulus time (ms)', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', ...
							[0.02 0.83 0.69 0.03], 'backgroundcolor', panelcol);

h.poststim_edit = uicontrol('parent', h.panel1, 'Style', 'edit', 'string', '2500', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', ...
							[0.75 0.83 0.23 0.03], 'backgroundcolor', panelcol);

h.isokay_text = uicontrol('parent', h.panel1, 'Style', 'text', 'string', 'Values Ok', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', ...
							[0.02 0.75 0.96 0.04], 'backgroundcolor', 'green', 'fontsize', 17);
						
h.calc_hr_button = uicontrol('parent', h.panel1, 'Style', 'pushbutton', 'string', 'Calculate heartrates', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', ...
							[0.02 0.68 0.96 0.045]);
						
h.append_file_button = uicontrol('parent', h.panel1, 'Style', 'pushbutton', 'string', 'Save avgHR to an existing file', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', ...
							[0.02 0.58 0.96 0.07]);
						
h.savehr_autom_checkbutton = uicontrol('parent', h.panel1, 'Style', 'checkbox', 'string', 'Save avgHR to an existing file', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', ...
							[0.02 0.53 0.96 0.04], 'backgroundcolor', panelcol, 'value', 1);

h.axes1 = axes('parent', h.panel1, 'units', 'normalized', 'position', [0.12 0.35 0.85 0.15], 'buttondownfcn', {@clickax});

h.axes2 = axes('parent', h.panel1, 'units', 'normalized', 'position', [0.12 0.15 0.85 0.15], 'buttondownfcn', {@clickax});

h.new_file_button = uicontrol('parent', h.panel1, 'Style', 'pushbutton', 'string', 'Create new avgHR-file', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', ...
							[0.02 0.07 0.96 0.04]);

h.quit_button = uicontrol('parent', h.panel1, 'Style', 'pushbutton', 'string', 'Quit', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', ...
							[0.02 0.01 0.96 0.05]);
						
h.hr_text = uicontrol('Style', 'text', 'string', 'Heart rates', 'horizontalalignment', 'left', ...
	                  'units', 'normalized', 'position', [0.23 0.955 0.2 0.03], 'backgroundcolor', 'white');

h.table1 = uitable('units', 'normalized', 'position', [0.23 0.35 0.76 0.6], 'rowname', [], 'columnname', [] );

h.avghr_text = uicontrol('Style', 'text', 'string', 'Average heart rates', 'horizontalalignment', 'left', ...
	                  'units', 'normalized', 'position', [0.23 0.3 0.2 0.03], 'backgroundcolor', 'white');

h.table2 = uitable('units', 'normalized', 'position', [0.23 0.01 0.76 0.27], 'rowname', [], 'columnname', [] );

set(h.winlen_edit, 'callback', {@winopt_edit_Callback, h});
set(h.prestim_edit, 'callback', {@winopt_edit_Callback, h});
set(h.poststim_edit, 'callback', {@winopt_edit_Callback, h});
set(h.table1, 'cellselectioncallback', {@table1_Callback, h});
set(h.table2, 'cellselectioncallback', {@table2_Callback, h});
set(h.quit_button, 'callback', {@close_Callback, h});
set(h.new_file_button, 'callback', {@new_file_Callback, h});
set(h.append_file_button, 'callback', {@append_file_Callback, h});
set(h.calc_hr_button, 'callback', {@calc_hr_Callback, h});

set(gcf, 'closerequestfcn', {@hr_CloseRequestFcn, h});

setappdata(gcf, 'file', ECGDATA.file);
setappdata(gcf, 'detected_peaks', ECGDATA.rpeaks);
setappdata(gcf, 'srate', ECGDATA.srate);
setappdata(gcf, 'event_times', ECGDATA.event_times);
setappdata(gcf, 'event_ids', ECGDATA.event_ids);
setappdata(gcf, 'event_order_nums', ECGDATA.event_order_nums);

hropts = loadHrWinopts([ECGDATA.rootdir filesep 'hrwinopts.txt']);

set(h.prestim_edit, 'string', num2str(hropts.prestimtime));
set(h.poststim_edit, 'string', num2str(hropts.poststimtime));
set(h.winlen_edit, 'string', num2str(hropts.winlen));

checkValues(h);


function close_Callback(~, ~, h)

close gcf;   % close window -> after this to closerequest


function new_file_Callback(~, ~, h)

if ~checkValues(h) || ~isappdata(gcf, 'avg_HR') %values okay and heartrates calculated
    return;
end


[fname, dpath] = uiputfile('*.csv');

avgHR = getappdata(gcf, 'avg_HR');
event_ids_table = getappdata(gcf, 'avg_event_ids');

prestimtime = str2num(get(h.prestim_edit, 'string'));    %ms
poststimtime = str2num(get(h.poststim_edit, 'string'));
winlen = str2num(get(h.winlen_edit, 'string'));
columncount = (poststimtime-prestimtime)/winlen;

% create value-row to save from array -> transpose -> vector
avgHR_transpose = avgHR';
row_to_save = avgHR_transpose(:)';

% column headers
headertime = prestimtime;
for j=1:columncount
    column_headers(1,j) = headertime;
    headertime = headertime + winlen;
end

k = 1;
for i = 1:(length(row_to_save)/columncount)
    header_row_to_save(1,k:columncount+k-1) = column_headers; % construct header row
    k = k + columncount;
end

if fname == 0
    return;
end

fid = fopen([dpath, fname], 'wt');

if fid == -1
    return;
end

% save headers
fprintf(fid, 'Filename');
for i = 1:length(header_row_to_save)
    save_this = [char(event_ids_table(ceil(i/columncount))), '/', num2str(header_row_to_save(1,i))];
    fprintf(fid, ',%s', save_this);
end

saveRow(fid, row_to_save);

fclose(fid);


function append_file_Callback(~, ~, handles)

% premises okay
if ~checkValues(handles) || isempty(getappdata(gcf, 'avg_HR'))
   return; 
end

[fname, dpath] = uiputfile('*.csv');

if fname == 0
    return;
end

fid = fopen([dpath, fname], 'a');

avg_heartrates = getappdata(gcf, 'avg_HR');
% create avghr-row
avg_heartrates_transpose = avg_heartrates'; % easier to change to row-vectors
row_to_save = avg_heartrates_transpose(:)';

saveRow(fid, row_to_save)

fclose(fid);


function calc_hr_Callback(~, ~, h)

% if all the needed values are there
if ~checkValues(h)
    return;
end

srate = getappdata(gcf, 'srate');
detected_peaks = (getappdata(gcf, 'detected_peaks')/srate)*1000; % srate -> ms
event_times = getappdata(gcf, 'event_times')/srate; % to seconds
event_ids = getappdata(gcf,'event_ids');
event_order_nums = getappdata(gcf,  'event_order_nums');

HR = []; % format HR-matrix

% get time values from gui-fields
preStimTime = str2num(get(h.prestim_edit, 'string'));    %ms
postStimTime = str2num(get(h.poststim_edit, 'string'));
winlen = str2num(get(h.winlen_edit, 'string'));
columnCount = (postStimTime - preStimTime) / winlen;

% calculate heartrates in each location
currentTime = preStimTime;
for j = 1:columnCount % each column
    for i = 1:length(event_times) % each event
       HR(i, j) = calcHR(event_times(i), detected_peaks, currentTime, winlen);
    end
    column_headers(1, j) = currentTime; % row-headers: time in ms
    currentTime = currentTime + winlen; % increase by window size
end

BPM = 1./(HR)*60*1000; % because using milliseconds

% calculate average heartrates
[avg_hr, avg_event_ids] = calc_avg_hr(event_ids, columnCount, BPM);

for i = 1:length(event_ids)
   event_ids{i} = [num2str(event_order_nums(i)) ', ' event_ids{i}]; 
end

for i = 1:length(avg_event_ids)
   avg_event_ids{i} = ['NaN, ' avg_event_ids{i}]; 
end

set(h.table1, 'data', BPM, 'columnname', column_headers, 'rowname', event_ids);
set(h.table2, 'data', avg_hr, 'columnname', column_headers, 'rowname', avg_event_ids);

% set heartrates to appdata-variables
setappdata(gcf, 'HR', BPM);
setappdata(gcf, 'avg_HR', avg_hr);
setappdata(gcf, 'avg_event_ids', avg_event_ids);

% If checkbutton checked, -> save hr and avg hr 
if get(h.savehr_autom_checkbutton, 'Value') == 1
    saveHR(column_headers, event_ids, avg_event_ids, BPM, avg_hr);
end

function clickax(~,~, row_ids)
%catch mouseclick from continuous data and if normal -> zoom


% what kind of click was performed?
clicktype = get(gcf, 'SelectionType');

if strcmp(clicktype, 'normal')
    identifier_text = 'Visualization of the heartrates';
    hfig = zoomAxes(gca, identifier_text);
    axh = get(hfig, 'currentaxes');
    legend(axh, row_ids, 'Location', 'NorthEastOutside');
end

function winopt_edit_Callback(~, ~, h)
 
checkValues(h);
emptyTables(h);


function table1_Callback(hObject, b, h)

plotrows = unique(b.Indices(:,1));
rnames = get(hObject, 'rowname');

drawCurves(h, get(h.table1, 'data'), plotrows, rnames(plotrows), h.axes1);


function table2_Callback(hObject, b, h)

plotrows = unique(b.Indices(:,1));
rnames = get(hObject, 'rowname');

drawCurves(h, get(h.table2, 'data'), plotrows, rnames(plotrows), h.axes2);


function hr_CloseRequestFcn(hObject, ~, h)

% save window-options till next time
prestimtime = get(h.prestim_edit, 'string');
poststimtime = get(h.poststim_edit, 'string');
winlen = get(h.winlen_edit, 'string');

fid = fopen([h.rootdir filesep 'hrwinopts.txt'], 'w');

if fid ~= -1
    saveAsetting(fid, prestimtime);
    saveAsetting(fid, poststimtime);
    saveAsetting(fid, winlen);
    fclose(fid);
end

delete(hObject);
	
	
function truthval = checkValues(h)
% returns one if all okay, zero if something wrong

prestimtime = str2num(get(h.prestim_edit, 'string'));    %ms
poststimtime = str2num(get(h.poststim_edit, 'string'));
winlen = str2num(get(h.winlen_edit, 'string'));
wincount = (prestimtime-poststimtime)/winlen;

if isempty(getappdata(gcf, 'detected_peaks')) || isempty(getappdata(gcf, 'event_times')) || ...
		isempty(getappdata(gcf, 'event_ids')) || ~(wincount == ceil(wincount))           || ...
		prestimtime > poststimtime
	%if-lauseen vika-kohta:jos ikkunoiden_lkm ja _lkm:n katto eivät ole samat => murtoluku

	set(h.isokay_text, 'String', 'Check values');
	set(h.isokay_text, 'BackgroundColor', 'Red');

	truthval = 0;

else % all okay
	set(h.isokay_text, 'String', 'Values OK');
	set(h.isokay_text, 'BackgroundColor', 'Green');

	truthval = 1;
end

    
function drawCurves(h, datamatrix, plotrows, row_ids, axh)
% function draws illustration of the selected curves on the selected
% axes

% if no rows selected or deselected rows
if isempty(plotrows)
    cla(axh);
    return;
end

pre_stim_time = str2num(get(h.prestim_edit, 'string'));    %ms
post_stim_time = str2num(get(h.poststim_edit, 'string'));
winlen = str2num(get(h.winlen_edit, 'string'));

% form time-vector
time_vector = pre_stim_time:winlen:post_stim_time - winlen;

% Max and minimum limits of y-axis change if you want to change scaling
ymin = min(min(datamatrix(plotrows, :))) - 1;
ymax = max(max(datamatrix(plotrows, :))) + 1;

if size(datamatrix(plotrows, :), 1) == length(time_vector)
	plot(axh, time_vector, datamatrix(plotrows, :)');
    set([axh; get(axh, 'children')], 'buttondownfcn', {@clickax, row_ids});
else
	plot(axh, time_vector, datamatrix(plotrows, :));
    set([axh; get(axh, 'children')], 'buttondownfcn', {@clickax, row_ids});
end

% skaling
axis(axh, [pre_stim_time, post_stim_time - winlen, ymin, ymax]);

% stimulus line
axes(axh);
line([0, 0], [ymin, ymax], 'color', 'black');


function saveHR(column_headers, event_ids, avg_event_ids, HR, avgHR)

ecg_filename = getappdata(gcf, 'file');

[a, b, c] = fileparts(ecg_filename);

% sizes of heartrate matrices
[rowdimHR] = size(HR, 1);
[rowdim_avgHR] = size(avgHR, 1);

coldim = length(column_headers);

% save HR
fid = fopen([a filesep b '_HR.csv'], 'wt');

if fid == -1
   return; 
end

% headers for HR
fprintf(fid, 'order_number,  event_id,');

for j = 1:coldim
	fprintf(fid,'%d', column_headers(j));
    
    if j ~= coldim
        fprintf(fid,',');
    end    
end

fprintf(fid, '\n');

% values for HR
for i = 1:rowdimHR 
    fprintf(fid, '%c', event_ids{i});
    
	for j = 1:coldim
		fprintf(fid,',%f', HR(i,j));
	end
	fprintf(fid, '\n');
end

fprintf(fid, '\n\n');

% and avgHR
for i = 1:rowdim_avgHR
    fprintf(fid, '%c', avg_event_ids{i});
    
	for j = 1:coldim
		fprintf(fid,',%f', avgHR(i,j));
	end
	fprintf(fid, '\n');
end

fclose(fid);


function emptyTables(h)

set(h.table1, 'data', [], 'rowname', [], 'columnname', []);
set(h.table2, 'data', [], 'rowname', [], 'columnname', []);
cla(h.axes1);
cla(h.axes2);


function saveRow(fid, row_to_save)

file = getappdata(gcf, 'file');

[a, b, c] = fileparts(file);

fprintf(fid, '\n%s', [b]);

for i=1:length(row_to_save(1,:))
	fprintf(fid, ',%8.3f', row_to_save(1,i));
end


function saveAsetting(fid, parameter)
% saves the desired parameter to file identirier fid. File needs to
% be open for writing.
fprintf(fid,'%s\n', num2str(parameter));


function HRwinopts = loadHrWinopts(file)
% load previous heart-rate window-options from file or if no file
% available, load default options.

HRwinopts.prestimtime = -2500;
HRwinopts.poststimtime = 5000;
HRwinopts.winlen = 500;

if ~exist(file)
    return;
end

opt = textread(file);

HRwinopts.prestimtime = opt(1);
HRwinopts.poststimtime = opt(2);
HRwinopts.winlen = opt(3);

