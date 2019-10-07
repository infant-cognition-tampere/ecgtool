function [ekg, rate] = loadEv2Ecg(filename_and_path)


fid = fopen(filename_and_path); 

%jos luettavissa
if ~(fid == -1)
	fclose(fid);

	%luetaan tiedosto. saadaan ekg-datamatriisi ja headerimatriisi
	h=waitbar(0,'Processing...');
	[headers, ekg_data_matrix] = hdrLoad(filename_and_path);
	waitbar(0.5);
	[rate, channels, ekg_channel] = neuroscanReadHeaders(headers);
	waitbar(0.75);
	
	waitbar(1);
	pause(0.3);
	close(h);
end


[selection, ok] = listdlg('ListString', channels, 'SelectionMode', 'single', 'promptstring', 'Select the EKG-channel');


ekg = ekg_data_matrix(:, selection); %otetaan neuroscan matriisista ekg-sarake yhteen muuttujaan



function [rate, channels, ekg_channel] = neuroscanReadHeaders(headers)
%Funktio hakee headereista näytteenottotaajuuden ja sarakkeen ja palauttaa
%ne. Ensin etsitään for-silmukalla näytteenottotaajuuden sisältävä rivi ja
%palautetaan se jatkokäsittelyyn. Sitten siitä poistetaan turhat
%kirjainmerkit ja muutetaan se numeromuotoon. Samoin myöhemmin etsitään ja
%lasketaan ekg-datan sarakkeen numero jotta se saadaan kaivettua muiden
%elektrodien datan joukosta.

rate='';
ekg_column='';
ekg_row='';

%read rate
row = findme('Rate', headers);
rate = textscan(row, '[Rate] %f', 'delimiter', ' ', 'MultipleDelimsAsOne', 1);
rate = rate{1};

%find where channels start
for i = 1:length(headers(:,1))
	if(strfind(headers(i,:), '[Electrode Labels]'))
		row_number = i+1; %channels are in this row
	end
end

%channels in a row
row = headers(row_number, :);

% Shitty loops, I know, but only way that I found out after a workday to
% do this thing.
% find channel letter indexes
k = 1;
for i = 1:length(row)
	if row(i) == '['
		channel_start(k)=i;
	end

	if row(i) == ']'
		channel_end(k)=i;
		k = k+1;
	end
end

%retrieve channels
channels=zeros(length(channel_start), 30);
z = 1;
for i = 1:length(channel_start)
	for j = channel_start(i):channel_end(i)
		channels(i, z)=row(j);
		z = z+1;
	end
	z = 1;
end

channels = char(channels);

%find string "EKG" from channels and if not found, put 1 as channel
ekg_channel = (findstr('EKG', row)+4)/11;
if isempty(ekg_channel)
	ekg_channel = 1;
end
