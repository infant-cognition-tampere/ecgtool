function [event_times, event_ids] = loadHandmadeEvents(filename_and_path)

%[event_arsykkeet, event_ajat]=textread(tiedostonimi_ja_polku, '%s %f');  %TEXTREAD on hyvä ja hyödyllinen, muista!

A = importdata(filename_and_path, ',');
event_times = A.data(:,1);
event_ids = A.rowheaders;