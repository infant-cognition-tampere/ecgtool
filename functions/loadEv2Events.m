function [event_times, event_ids] = loadEv2Events(filename_and_path)

fid=fopen(filename_and_path);
markers  = textscan(fid, '%d %s %s %s %d %f', 'delimiter', ' ', 'MultipleDelimsAsOne', 1);
fclose(fid);

%the stimulus-types are on column 2 and event-times are on column 6 
event_ids=markers{2};
event_times=markers{6};