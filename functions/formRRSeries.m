function [RR] = formRRSeries(detected_peaks)
% calc RR-intervals (milliseconds)

for i = 1:length(detected_peaks) - 1
	RR(i,1) = detected_peaks(i + 1) - detected_peaks(i);
end