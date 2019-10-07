function [ekg, srate] = loadBrainvisionEcg(filename_and_path)

fid = fopen(filename_and_path);

if fid == -1
	return;
end

tiedosto_cellina = textscan(fid, '%s', 'delimiter', sprintf('\n'));
%cell -> array
headers = char(tiedosto_cellina{1,1});

[srate, desimSep, ekg_row, datatype, dataformat, data_or, ekg_filename, channels] = readBrainHeaders(headers);

if (strcmp(data_or, 'VECTORIZED') && strcmp(dataformat, 'ASCII') && strcmp(datatype, 'TIMEDOMAIN'))

	dpath = fileparts(filename_and_path);
	ekg_filename_and_path = strcat(dpath, ekg_filename);
	
	%set channels to listbox
	[selection, ok] = listdlg('ListString', channels, 'SelectionMode', 'single', 'promptstring', ...
		'Select the EKG-channel', 'InitialValue', ekg_row);
	
	ekg = openBrainvision(ekg_filename_and_path, selection, desimSep);
else
	msgbox('Error occurred. Use the following attributes in Analyzer: DataFormat=ASCII, DataOrientation=VECTORIZED, DataType=TIMEDOMAIN, ','Error','error');
end


function [srate, desim_sep, ekg_row, data_type, data_format, data_or, data_filename, channels] = readBrainHeaders(headers)

filename_row = findme('Datafile=', headers);
data_filename = filename_row(1,10:length(filename_row));

%get rate
sinterval_row = findme('SamplingInterval=', headers);
sampling_freq = str2num((sinterval_row(:,18:length(sinterval_row))));
srate = 1000000/sampling_freq;

%gather header info
row = findme('DataOrientation=', headers);
data_or = textscan(row, 'DataOrientation=%s');
data_or = data_or{1};

%datatype-info
row = findme('DataType=', headers);
data_type = textscan(row, 'DataType=%s');
data_type = data_type{1};

%dataformat-info
row = findme('DataFormat=', headers);
data_format = textscan(row, 'DataFormat=%s');
data_format = data_format{1};

%decimalsymbol-info
row = findme('DecimalSymbol=', headers);
desim_sep = textscan(row, 'DecimalSymbol=%s');
desim_sep = desim_sep{1};

[row,col] = size(headers);

%get channels
channels_start = find(findRow('[Channel Infos', headers));
channels_m_s = find(headers(channels_start+1:row,1)~=';', 1, 'first'); %comments away
first_channel_row = channels_start+channels_m_s;
last_channel_row = find(headers(first_channel_row:row,1)~='C', 1, 'first');

channels_not_sorted = headers(first_channel_row:first_channel_row + last_channel_row - 2, :);
%reduce displayed char to 30
channels = channels_not_sorted(:,1:30);

%ekg_rivinumero=find(etsiRivi('=EKG', channels_not_sorted));
ekg_rownumber = find(findRow('=EKG', headers));
if isempty(ekg_rownumber)
   ekg_rownumber = 1;
end

%haetaan numero textscanilla riviltä
ekg_row = textscan(headers(ekg_rownumber,:), 'Ch%d%*s');
ekg_row = ekg_row{1};


function [ekg_data] = openBrainvision(filename_and_path, ekg_row, desim_sep)
   
if~(filename_and_path == 0)
	fid = fopen(filename_and_path);
	%jos luettavissa
	if ~(fid == -1)
		%lukee rivin tekstiä muistiin välilyönti eroittimena

		%graphical waiting-bar
		h = waitbar(0,'Processing...');

		%row text to cell
		textrow = textscan(fid, '%s[\n]', 'delimiter', '\n' ,'HeaderLines', ekg_row-1, 'MultipleDelimsAsOne', 1, 'bufsize', 100000000);
		waitbar(0.5);

		%extract values from row
		teksti = textscan(char(textrow{1}), '%s', 'delimiter', ' ', 'MultipleDelimsAsOne', 1);
		waitbar(0.75);

		ekg_as_string = teksti{1};
		string_len = length(ekg_as_string);
		ekg_as_numbers = zeros(string_len,1);

		k = 1;
		while(k <= string_len)
		   if (strcmp(desim_sep, ','))
				ekg_as_string(k) = strrep(ekg_as_string(k), ',' , '.');
		   end
		   ekg_as_numbers(k,1) = str2double(ekg_as_string{k});
		   k = k + 1;
		end

		%take the first NaN away (tune if rpeaks do not correspond)
		ekg_as_numbers = ekg_as_numbers(3:length(ekg_as_numbers));

		waitbar(1);
		pause(0.3);
		% close waiting bar
		close(h);

		fclose(fid);
	end
end

ekg_data = ekg_as_numbers;


function rownumbers = findRow(findme, array_of_rows)

[rowdim, coldim] = size(array_of_rows);

rownumbers = zeros(rowdim,1);

for i = 1:size(array_of_rows)
    
   if (regexpi(array_of_rows(i,:), findme))
       rownumbers(i,1) = 1;
   end
end
%rivinumerot=find(rivit);
