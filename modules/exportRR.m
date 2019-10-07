function exportRR(EKGDATA, fhandles)
% ecport RR-series from to a textfile

RR = EKGDATA.rpeaks;

if isempty(RR)
    return;
end

[a, b, ~] = fileparts(EKGDATA.file);

% get filename with a GUI
[filename, dpath] = uiputfile('*.txt', 'Export RR', [a filesep b '_RR.txt']);

if filename == 0
   return;
end

% save rr-intervals
fid = fopen([dpath filesep filename], 'wt');

for i = 1:length(RR)
    fprintf(fid,'%g\n', RR(i));
end

fclose(fid);
