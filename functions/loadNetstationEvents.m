function [event_times, event_ids] = loadNetstationEvents(filename_and_path)
% loads ECG-events from Netstation exported .mat-file

A = load(filename_and_path);
fnames = fieldnames(A);

[selection, ok] = listdlg('ListString', fnames, 'SelectionMode', 'single', 'promptstring', 'Select the Event-channel');


%event_times_string=A.ECI_TCPIP_55513(4,:);

event_times_string = A.(fnames{selection})(4,:);

for i=1:length(event_times_string)
	event_times_rowvec(i) = event_times_string{i};
end
event_times = event_times_rowvec';

%event_ids = A.ECI_TCPIP_55513(1,:)';
event_ids = A.(fnames{selection})(1,:)';