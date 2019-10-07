function saveEvents(ECGDATA, fhandles)
% function saves (modified) events to file (path+filename)

event_times = ECGDATA.event_times;
event_ids = ECGDATA.event_ids;

% get filename with a GUI
[filename, dpath] = uiputfile('*.txt', 'Export events', [a filesep b '_events.txt']);

if filename == 0
   return;
end

% save events
fid = fopen([dpath filesep filename], 'wt');

for i=1:length(event_times)
	fprintf(fid, '%s\t\t%g\n', char(event_ids(i,:)), event_times(i));
end

fclose(fid);
