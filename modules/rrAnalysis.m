function rrAnalysis(ECGDATA, fhandles)

% form the RR-intervals
RR_series = formRRSeries(ECGDATA.rpeaks*(1000/ECGDATA.srate));

% get range
answer = inputdlg({'Start #RR', 'End #RR'}, ...
                  'Specify the range of the R-peaks in the analysis', 1, {'1', num2str(length(RR_series))});

if isempty(answer)
    return;
end
				  
beginning = str2num(answer{1});
ending = str2num(answer{2});

RR = RR_series(beginning:ending);

%(RR, fileid)

% define ui-elements
hfig = figure('units', 'normalized', 'position', [0.1 0.1 0.8 0.8]);

set(hfig, 'menubar', 'none', 'numbertitle', 'off', 'name', 'Ekgtool 3.0', 'color', 'w');

setappdata(hfig, 'RR', RR);
setappdata(hfig, 'file', ECGDATA.file);

% set backgroung image
hBg =  axes('units','normalized', 'position',[0 0 1 1]);

% Move the background axes to the bottom
uistack(hBg,'bottom'); 

set(hBg,'handlevisibility','off', 'visible','off');


h.axes1 = axes('units', 'normalized', 'position', [0.06 0.8 0.88 0.16]);
h.axes2 = axes('units', 'normalized', 'position', [0.06 0.6 0.88 0.16]);
h.axes3 = axes('units', 'normalized', 'position', [0.06 0.4 0.40 0.16]);

panelcol = [0.894 0.941 0.942];

h.panel1 = uipanel('units', 'normalized', 'position', [0.06 0.02 0.35 0.27], 'backgroundcolor', panelcol);

h.freqb_text = uicontrol('parent', h.panel1, 'Style', 'text', 'string', 'Rsa frequenct band (Hz)', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', ...
							[0.02 0.87 0.6 0.07], 'backgroundcolor', panelcol);

h.rsa_min_freq_edit = uicontrol('parent', h.panel1, 'Style', 'edit', 'string', '0.12', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', ...
							[0.6 0.87 0.15 0.07], 'backgroundcolor', panelcol);

h.rsa_max_freq_edit = uicontrol('parent', h.panel1, 'Style', 'edit', 'string', '0.4', ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', ...
							[0.8 0.87 0.15 0.07], 'backgroundcolor', panelcol);
						
h.firsize_text = uicontrol('parent', h.panel1, 'Style', 'text', 'string', 'Fir bandpass filter size', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', ...
							[0.02 0.72 0.6 0.07], 'backgroundcolor', panelcol);
						
h.filter_size_edit = uicontrol('parent', h.panel1, 'Style', 'edit', 'string', '241', 'enable', 'inactive',...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', ...
							[0.6 0.72 0.15 0.07], 'backgroundcolor', panelcol);
						
h.rr_interval_text = uicontrol('parent', h.panel1, 'Style', 'text', 'string', 'RR-interval on interpolation', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', ...
							[0.02 0.57 0.6 0.07], 'backgroundcolor', panelcol);
						
h.rr_interval_edit = uicontrol('parent', h.panel1, 'Style', 'edit', 'string', '100', 'enable', 'inactive',...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', ...
							[0.6 0.57 0.15 0.07], 'backgroundcolor', panelcol);

h.display_text = uicontrol('parent', h.panel1, 'Style', 'text', 'string', 'Display mode', ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', ...
							[0.02 0.42 0.6 0.07], 'backgroundcolor', panelcol);
						
h.display_popup = uicontrol('parent', h.panel1, 'Style', 'popupmenu', 'string', {'Linear interpolation', 'Equidistant sampling'}, ...
                            'horizontalalignment', 'left', 'units', 'normalized', 'position', ...
							[0.6 0.42 0.38 0.07], 'backgroundcolor', panelcol);

h.dot_togglebutton = uicontrol('style', 'togglebutton', 'units', 'normalized', 'position', [0.952 0.8 0.03 0.04], ...
                               'string', '-.-');                        

hinttext = {'RR-series for analysis derived by linear interpolation.';
            'Unfiltered RR-metrics are derived from the RR-series ';
            'that covers (timewise) the same area as filtered data.'};

						
h.hint_text = uicontrol('parent', h.panel1, 'Style', 'text', 'string', hinttext, ...
                            'horizontalalignment', 'center', 'units', 'normalized', 'position', ...
							[0.02 0.06 0.96 0.2], 'backgroundcolor', panelcol);
						

h.quit_button = uicontrol('Style', 'pushbutton', 'string', 'Quit', 'horizontalalignment', 'left', ...
	                      'units', 'normalized', 'position', [0.89 0.015 0.09 0.03], 'backgroundcolor', panelcol);


h.information_uitable = uitable('units', 'normalized', 'position', [0.7 0.06 0.28 0.3]);



set(h.quit_button, 'Callback', {@quit_Callback, h});
set(h.rsa_min_freq_edit, 'Callback', {@rsa_min_freq_Callback, h});
set(h.rsa_max_freq_edit, 'Callback', {@rsa_max_freq_Callback, h});
set(h.dot_togglebutton, 'callback', {@edit_callback, h});
set(h.display_popup, 'callback', {@edit_callback, h});


%set(handles.rsa_min_freq_edit, 'String', getappdata(hEkgtool, 'rsa_low_freq'));
%set(handles.rsa_max_freq_edit, 'String', getappdata(hEkgtool, 'rsa_high_freq'));

%if nargin == 2
%	setappdata(gcf, 'fileid', fileid);
%end

updateView(h);

function updateView(h)

RR = getappdata(gcf, 'RR');
rr_sum = calcAdditiveRRVector(RR); %increasing sum vector of rr's: 1.0, 2.RR1, 3.RR2... in ms

%retrieve analysis-window and freq-controls
rsa_min_freq = str2double(get(h.rsa_min_freq_edit, 'String'));
rsa_max_freq = str2double(get(h.rsa_max_freq_edit, 'String'));

%get user specified rr-interval and calc rate
rr_interval = str2double(get(h.rr_interval_edit, 'String'));
rr_rate = 1000/rr_interval;

%Form RR-timeseries by basic interp1 linear interpolation
rr_timevector = 0:rr_interval:rr_sum(length(rr_sum));
rr_power = interp1(rr_sum, RR, rr_timevector);

%proceed to 1000hz rate->

if ~exist('fir1')
    error('You probably do not have a signal processing toolbox. Please install that in order to use this function.');
end

%form the filter
filter_size = str2double(get(h.filter_size_edit, 'String'));
filter_half = round((filter_size-1)/2);
filt = fir1(filter_size, [rsa_min_freq/(0.5*rr_rate) rsa_max_freq/(0.5*rr_rate)]);

%apply the filter
correction_parameter = 4; %to correct the series to be ~from the same area then cmetx
rr_power_filtered = conv(filt, rr_power);
rr_power_filtered = rr_power_filtered(filter_half:length(rr_power_filtered)-filter_half);
rr_power_filtered(1:filter_half) = 0;
rr_power_filtered(length(rr_power_filtered)-filter_half-correction_parameter:length(rr_power_filtered)) = 0;

rr_time_filtered=(1:length(rr_power_filtered))/rr_rate;

%calc RR's that go inside the filter window from RR original and RR
%timeseries
times_inside_filter = rr_timevector(filter_half:length(rr_timevector) - filter_half-correction_parameter);
RR_start = find(rr_sum<times_inside_filter(1), 1, 'last');
RR_end = find(rr_sum>times_inside_filter(length(times_inside_filter)), 1, 'first');

rr_start = find(rr_timevector<times_inside_filter(1), 1, 'last');
rr_end = find(rr_timevector>times_inside_filter(length(times_inside_filter)), 1, 'first');

%define the analysis area to be the filtered area
%analysis_RR_power=RR(RR_start+1:RR_end);

analysis_RR_power=RR(RR_start+1:RR_end);
analysis_rr_power=rr_power(rr_start+1:rr_end);

%calc metrics
[ num_rr, mean_rr, mean_hr, sdnn, rmssd, msd, var_unfilt, logHRV, variance_filt_rr, nn50, pnn50, logVAR ] = calculateMetrics(analysis_RR_power, analysis_rr_power, rr_power_filtered(filter_half:length(rr_power_filtered)-filter_half - correction_parameter));

%set the information panel (and save results)
setInfo(h, rsa_min_freq, rsa_max_freq, num_rr, mean_rr, mean_hr, sdnn, rmssd, msd, var_unfilt, logHRV, variance_filt_rr, nn50, pnn50, logVAR);

%calc fft of the whole curve
[freq, power]=calcFFT(analysis_rr_power-mean(analysis_rr_power), rr_rate);

%choose plot type for rr-series
rr_sampling_type = get(h.display_popup, 'Value');
if rr_sampling_type == 1 %basic interp1 linear interpolation
    rr_y=rr_power;
    rr_x=rr_timevector;
    
else if rr_sampling_type == 2 %equidistant sampling
    rr_interval=sum(RR)/length(RR);
    rr_rate=1000/rr_interval;
    rr_x=0:rr_interval:sum(RR(1:length(RR)));
    rr_x=(rr_x(1:length(rr_x)-1));
    rr_y=RR';
    end
end

%fill the axes
drawData(h, rr_x, rr_y, rr_time_filtered, rr_power_filtered, freq, abs(power), rr_rate);


function [ num_rr, mean_rr, mean_hr, sdnn, rmssd, msd, var_unfilt, logHRV, variance_filt_rr, nn50, pnn50, logVAR] = calculateMetrics(RR, rr_power, RR_filtered)
    
%num rr's
num_rr = length(RR);

%mean rr
mean_rr = mean(RR);

%mean HR
mean_hr = mean(60*1000./RR);

%SDNN
sdnn = std(RR);

%variance over RR-interpolated timeseries
var_unfilt=var(rr_power);

%logarithm over variance (logHRV)
logHRV=log(var_unfilt);

%differences of adjacent RR-intervals
differences=zeros(length(RR)-1,1);
for i=1:length(RR)-1
	differences(i)=RR(i+1)-RR(i);
end

%MSD
msd=mean(abs(differences));

%RMSSD
rmssd = sqrt(mean(differences.^2));

%pnn50-values
nn50 = length(differences(abs(differences)>50));
pnn50 = 100 * nn50/length(differences);

%variance over filtered rr
variance_filt_rr = var(RR_filtered(~isnan(RR_filtered)),1);

%log RSA
logVAR = log(variance_filt_rr);
    

function  rr_sumvector = calcAdditiveRRVector(RR)

rr_sumvector=zeros(length(RR),1);
rrsum=0;
rr_sumvector(1)=0;

for j=1:length(RR)-1
    rrsum=rrsum+RR(j);
    rr_sumvector(j+1)=rrsum;
end


function quit_Callback(~, ~, h)

close gcf;

function setInfo(handles, min_freq, max_freq, num_rr,  mean_rr, mean_hr, sdnn, rmssd, msd, var_unfilt, logHRV, variance_filt_rr, nn50, pnn50, logVAR)
%set information to information table on UI

information(1,1)={'Frequency band'};
information(1,2)={strcat(num2str(min_freq), '-', num2str(max_freq))};
information(2,1)={'Number of RR´s'};
information(2,2)={num2str(num_rr)};
information(3,1)={'Mean RR (ms)'};
information(3,2)={num2str(mean_rr)};
information(4,1)={'Mean HR'};
information(4,2)={num2str(mean_hr)};
information(5,1)={'SDNN'};
information(5,2)={num2str(sdnn)};
information(6,1)={'RMSSD'};
information(6,2)={num2str(rmssd)};
information(7,1)={'MSD'};
information(7,2)={num2str(msd)};    
information(8,1)={'NN50'};
information(8,2)={num2str(nn50)};
information(9,1)={'PNN50'};
information(9,2)={num2str(pnn50)};
information(10,1)={'Variance(RR-unfiltered)'};
information(10,2)={num2str(var_unfilt)};
information(11,1)={'LogHRV'};
information(11,2)={num2str(logHRV)};
information(12,1)={'Variance (RR_filtered)'};
information(12,2)={num2str(variance_filt_rr)};
information(13,1)={'logRSA'};
information(13,2)={num2str(logVAR)};

set(handles.information_uitable, 'Data', information);

str = '<html><b>Calculations performed in this table (Matlab calls) are specified in the manual.';
set(handles.information_uitable,'tooltipString',str);

saveMetrics(information);


function drawData(h, rr_time, rr_power, rr_time_filtered, rr_power_filtered, fft_freq, fft_power, rr_rate, analysis_start, analysis_end)

max_x=length(rr_time)/rr_rate;
cla(h.axes1);

%plot RR-series
 if get(h.dot_togglebutton, 'Value') == 1
    plot(h.axes1, rr_time/1000, rr_power, 'k-', rr_time/1000, rr_power, 'r.');
 else
    plot(h.axes1, rr_time/1000, rr_power, 'k-');
 end
 
axes(h.axes1);
xlabel '';
ylabel 'RR-interval(ms)';
title('RR-series');
axis(h.axes1, [0 max_x min(rr_power) max(rr_power) ]);

%plot filtered RR-series
plot(h.axes2, rr_time_filtered, rr_power_filtered, 'b-');
axes(h.axes2);
xlabel '';
ylabel '';
title('Filtered RR-series');
%axis(handles.axes2, [0 max_x min(rr_power_filtered) max(rr_power_filtered)]);
axis tight;

%plot fft over the whole RR
plot(h.axes3, fft_freq, fft_power, 'Color', 'black');
axes(h.axes3);
xlabel 'f (Hz)';
ylabel '';
title('FFT(RR-mean(RR))');
axis(h.axes3, [0 0.5 0 max(fft_power)]);

plot_bg_color=[0.961, 0.967, 0.992];
set(h.axes1, 'Color', plot_bg_color);
set(h.axes2, 'Color', plot_bg_color);
set(h.axes3, 'Color', plot_bg_color);


function rsa_min_freq_Callback(hObject, ~, h)

rsa_max_freq = str2double(get(h.rsa_max_freq_edit, 'String'));
rsa_min_freq = str2double(get(hObject,'String'));

if rsa_min_freq >= rsa_max_freq
    set(hObject, 'String', num2str(rsa_max_freq-0.1));
else if rsa_min_freq<=0
    set(hObject, 'String', num2str(0.001));
    end
end

updateView(h);


function rsa_max_freq_Callback(hObject, ~, h)
rsa_min_freq = str2double(get(h.rsa_min_freq_edit, 'String'));
rsa_max_freq = str2double(get(hObject,'String'));

if rsa_max_freq <= rsa_min_freq
    set(hObject,'String', num2str(rsa_min_freq+0.1));
end

updateView(h);


function edit_callback(~, ~, h)
% every change in values comes to this function
updateView(h);


function rr_interval_edit_Callback(hObject, ~, h)

if str2double(get(hObject,'String'))<10
    set(hObject, 'String', 10)
end

updateView(h);


function saveMetrics(information)
% saves information table to a file

filename = getappdata(gcf, 'file');
[a, b, ~] = fileparts(filename);

% define saving target
dest = [a filesep b '_metrics.csv'];

% save
fid = fopen(dest, 'wt');

fprintf(fid, 'sep=,\n');
for i = 1:length(information(:,1))
	fprintf(fid,'%s,%s\n', information{i,1}, information{i,2});
end

fclose(fid);
