function [event_times, event_ids] = loadBrainvisionEvents(filename_and_path)

%koko event-tiedosto celliin
fid = fopen(filename_and_path);
event_tiedosto = textscan(fid, '%s', 'delimiter', sprintf('\n'));
fclose(fid);

%muutetaan tiedosto taulukoksi
event_taulukkona = char(event_tiedosto{1,1});

%etsit‰‰n markkeririvit
mk_rivinumerot = findRow('Mk[1234567890]+=',event_taulukkona);
stimulus_rivinumerot = findRow('=Stimulus',event_taulukkona);

%suoritetaan and-operaatio:rivit, joilla Mk*= ja =Stimulus
rivinumerot = and(mk_rivinumerot, stimulus_rivinumerot);
%the row of first stimulus 
rivit = find(rivinumerot, 1, 'first');
headerlines = rivit-1;

%luetaan markkeririvit (oletetaan ett‰ ekasta markkerista voidaan lukea
%eteenp‰in tiedoston loppuun) headerit loppuvat ekan rivin kohdalla
fid = fopen(filename_and_path);
markers = textscan(fid, '%s %s %f %*d %*d', 'delimiter', ',', 'HeaderLines', headerlines);
fclose(fid);

%jos tarvii taulukoksi, char(markkerit{2})
event_ids=markers{2};
event_times=markers{3};


function rownumbers = findRow(findme, array)

[rowdim, coldim]=size(array);

rivit=zeros(rowdim,1);

for i=1:size(array)
    
   if (regexpi(array(i,:), findme))
       rivit(i,1)=1;
   end
end
rownumbers=rivit;
%rivinumerot=find(rivit);