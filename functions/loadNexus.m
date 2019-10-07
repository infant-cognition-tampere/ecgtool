function [ekg, srate, event_times, event_ids] = loadNexus(filename)
    % loads ekg-signal from nexus system (state: as-fast-as possibly done,
    % not perhaps handing errors or unexpected file export options)

    raw_str = fileread(filename);
    
    % remove empty lines
    %str_emptylines_gone = regexprep(raw_str, '\n\n+', '\n');
    
    % this function only reads correctly headers in this case (according to
    % testing) so get headers with this
    [headers,  data] = hdrLoad(filename);

    % calculate amount of header rows
    headerlinecount = size(headers, 1);
    
    % read last header row containing text (expected to be column headers)
    % not cleanest solution, but will do
    last_header_line = '';
    for i=1:headerlinecount
        hstr = headers(i,:);
        hstr2 = strrep(hstr, ' ', '');
        if ~strcmp(hstr2, '')
            last_header_line = hstr;
        end
    end
    
    delimiter = '\t';
    
    % find how many columns (how many delimiters actually)
    colcount = length(strfind(last_header_line, sprintf(delimiter)));
    
    % construct fileformat string for headers
    fileformat = '';
    for i=1:colcount
        fileformat = strcat(fileformat, '%s');
    end
    
    % read headers to cell to figure out which column has what
    HEADERS = textscan(last_header_line, fileformat, 'Delimiter', delimiter);
    
    ekgcol = colNum(HEADERS, 'Sensor-B:EEG');
    eventcol = colNum(HEADERS, 'Events');
    
    % construct fileformat string for data (ekg is numerical, so different)
    fileformat = '';
    for i=1:colcount
        if i == ekgcol
            format_id = '%f';
        else
            format_id = '%s';
        end
        fileformat = strcat(fileformat, format_id);
    end
    
    % read data columns (expected after headers)
    DATA = textscan(raw_str, fileformat, 'HeaderLines', ...
                    headerlinecount, 'Delimiter', delimiter);

    ekg_raw = DATA{ekgcol};
    srate = 256;

    % event loading
    % event_ids = unique(DATA{eventcol});
    event_vector = DATA{eventcol};
    
    % remove empty values (causes a crash, because can not be converted to
    % numerical)
    event_times = find(~strcmp(event_vector, ''));
    ekg = ekg_raw(~isnan(ekg_raw));
    event_ids = event_vector(event_times);
  
  
  function [column_number] = colNum(HEADERS, column_id)
    %Function [column_number] = colNum(HEADERS, column_id)
    %
    % Finds the order number of the column_id and returns it as an integer. If
    % column of that name not found, returns -1.

    column_number = -1;
    found = 0;

    for n=1:length(HEADERS)
        if strcmp(HEADERS{n}{1}, column_id) && ~found
            column_number = n;
        end
    end
