function exportPeaksEventsEkgCsv(EKGDATA, fhandles)

EKG = EKGDATA.ekg;
eventt = EKGDATA.event_times;
eventi = EKGDATA.event_ids;
rpeaks = EKGDATA.rpeaks;
srate = EKGDATA.srate;


if ~(isempty(eventi))

    file = getappdata(gcf, 'file');
    [a, b, ~] = fileparts(file);

    % get filename with a GUI
    [filename, dpath] = uiputfile('*.csv', 'Export RR', [a filesep b '_data']);

    if ~(isnumeric(filename) && isnumeric(dpath))

        targetfile = [dpath filesep filename];

        % save rr-intervals
        fid = fopen(targetfile, 'wt');

        fprintf(fid,'srate, %d\nEKG(uV)', srate);
        
        for i = 1:length(EKG)
            fprintf(fid,'%f,', EKG(i));
        end
        
        fprintf(fid, '\nrpeaks(corresponds to point),');
        
        for i = 1:length(rpeaks)
            fprintf(fid,'%i,', rpeaks(i));
        end
        
        fprintf(fid, '\nevent time,');
        
        for i = 1:length(eventt)           
            fprintf(fid,'%i,', eventt(i));
        end
        
        fprintf(fid, '\nevent_id,');
        
        for i = 1:length(eventi)           
            fprintf(fid,'%s,', eventi{i});
        end

        fclose(fid);
    end
end