function [average_heartrates, sorted_unique_events] = calc_avg_hr(event_ids, columnCount, heartRates)
% Function made quick so it is not the "clearest", remake if time ->

% find different stimulae (shortened)
uniq_events = unique(event_ids);

sorted_unique_events = sort(uniq_events);

% find rows where each stimulus appears
for i = 1:length(sorted_unique_events) 
	k = 1; % k‰ytet‰‰n apuna, jotta saadaan rivinumerot matriisiin per‰kk‰in
	for j = 1:length(event_ids) %k‰yd‰‰n l‰pi koko event_‰rsykkeet, josta saadaan rivit joilla kukin ‰rsyke esiintyy
		if isequal(sorted_unique_events(i), event_ids(j)) %jos rivill‰ ‰rsykett‰
			rows_of_this_stimulus(i, k) = j; % lis‰t‰‰n tieto lˆytyneest‰ rivist‰ matriisiin
			k = k + 1;
		end
	end
end

timevalues = zeros(length(sorted_unique_events), columnCount);
%etsit‰‰n ‰rsykkeiden arvot ja lasketaan ne yhteen
for i = 1:length(sorted_unique_events)
	stimulus_times = zeros(1, columnCount);

	for j = 1:length(rows_of_this_stimulus(i, :)) %kaikki rivin alkiot !!huomioi ett‰ length(matriisi) antaa matriisin suuremman dimension!!
		if ~(rows_of_this_stimulus(i, j) == 0)
			stimulus_times = heartRates(rows_of_this_stimulus(i, j), :);
			timevalues(i, :) = timevalues(i, :) + stimulus_times;      %n‰ytt‰isi toimivan nyt, t‰ss‰ oli ongelmia
		end
	end
end

for i = 1:length(sorted_unique_events)
	%Lasketaan ‰rsykesarakkeen pituus. Ensin kaikki alkiot, sitten
	%v‰hennet‰‰n kaikki nolla-alkiot
    % length of valuecolumn, first all values, then take away zeros.
	eventcolumn_length(i,1) = length(rows_of_this_stimulus(i, :)) - length(find(rows_of_this_stimulus(i, :) == 0));
	average_heartrates(i,:) = [timevalues(i,:)/eventcolumn_length(i,1)]; % divide by stimulus count
end
