function [ekg, rate] = loadNetstationEcg(filename_and_path)

matfile = load(filename_and_path);
rate = matfile.samplingRate;

fnames = fieldnames(matfile);

[selection, ok] = listdlg('ListString', fnames, 'SelectionMode', 'single', 'promptstring', 'Select the EKG-channel');

if ok==0
	ekg = [];
	return;
end

ekg = matfile.(fnames{selection})';