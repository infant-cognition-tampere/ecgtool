function HR = calcHR(stim_time, Rpeaks, startloc, winlen)
% Algorithm originating from Pasi Kauppinen. Modified slightly. Calculates 
% heart rates in given time windows.

% tsekkaa ensin input
% 3 kpl
if nargin < 3 
    fprintf('Not enought input arguments\n');
    fprintf('Check the data\n');
    return;
end

% Rpeaks riitt‰v‰n pitk‰
 if length(nonzeros(Rpeaks)) < 8
     fprintf('Number of R-peaks in the data only %d \n',length(nonzeros(Rpeaks)));
     fprintf('Check the data\n');
     return;
 end


%SR=1000; edit: SR poistettu 2.7, koska k‰ytet‰‰n ms
% tsekataan meneekˆ stim_tim menee sopivasti R-piikkien v‰lille, jos ei
% niin palautetaan -666;
if ( ((stim_time * 1000 + 1) > max(Rpeaks)) || ((stim_time * 1000 - 1) < min(nonzeros(Rpeaks))) )
     fprintf('Stimulus time and R-peak data do not match\n');
     fprintf('Stim_time=%g\n',stim_time);
     fprintf('Min R-peak at %g ms\n', min(nonzeros(Rpeaks)));
     fprintf('Max R-peak at %g ms\n', max(Rpeaks));
     fprintf('Check the data\n');
     HR=-666;
     return;
 end   

% asetetaan ulostulomatriisi
HR = -666;

% lasketaan jokaiselle (paitsi 1:lle) R-piikille vastaava RR-intervalli
% sekunneissa
RR = zeros(length(nonzeros(Rpeaks)),1);
RR(1) = 0;
for i = 2:length((Rpeaks))
    RR(i) = Rpeaks(i) - Rpeaks(i-1);
end
% edit 2.7: poistettu RR=RR./SR;
%RR;

% A: etsit‰‰n Stim_timea [s] edelt‰v‰‰ PUOLTA(edit 020708)sekuntia ensimm‰inen edelt‰v‰n
% R-piikin j‰rjestysnro
% edit 2.7: start_time -> start_time_ms
start_time_ms = stim_time * 1000 + startloc;
% etsi Rpeaks, kunnes pienempi kuin Stim_time-0.5s
start_loc = start_time_ms;

i = 1;
while (Rpeaks(i) <= start_loc)
    i = i + 1;
end
aRpeak = i-1;  
Rpeaks(i);

%B: etsit‰‰n viimeinen piikki ennen ikkunan loppumista.
i = 1;
start_loc_ms = stim_time *1000 + startloc + winlen;
while (Rpeaks(i) <= start_loc_ms)
    i = i + 1;
end
pRpeak = i - 1;   %t‰h‰nkin lis‰tty -1 koska while menee yhden kerran liikaa...


R_events = pRpeak - aRpeak;
if R_events < 0, R_events = 0; end
%  fprintf('start_time_ms=%g\taRpeak=%d\tpRpeak=%d\tR_events=%d\n', start_time_ms, aRpeak, pRpeak, R_events)

% eventtien lkm:st‰ riippuen v‰lille aRpeakin ja pRpeakin v‰lille osuu
% joko: 0 , 1 tai useampi R-piikki. Jaotellaan m‰‰rittely t‰m‰n mukaan
% 0: bradycardia
if R_events == 0
    % Stim_timen ja sit‰ edelt‰v‰n sekunnin aikana ei yht‰‰n R-piikki‰
    % t‰llˆin RR tulee pelk‰st‰‰n pRpeakin RR:st‰
    %R_events
    %RR(pRpeak)
    %pRpeak

    HR = RR(pRpeak + 1);
end

% 1: sinus
if R_events == 1
    % Stim_timen ja sit‰ edelt‰v‰n 0.5 sekunnin aikana yksi R-piikki
    %RR(aRpeak+1)
    %(((Rpeaks(aRpeak+1))-(stim_time*1000-500))/500)
    %RR(pRpeak)
    %(stim_time*1000-(Rpeaks(pRpeak-1)))/500
    %stim_time
    %KOSKA VƒLIT RR OVAT KAKSI EDELLƒ R-PIIKKEJƒ, LISƒTƒƒN 2.

%        rr_apeak=RR(44:50)

    ibi_a = RR(aRpeak + 1);  %IBI ikkunan keskell‰ olevaa piikki‰ ennen
    osuus_a = (Rpeaks(aRpeak + 1) - (stim_time * 1000 + startloc)) / winlen; %IBI-a:n kerroin

    ibi_b = RR(pRpeak + 1); %IBI keskell‰ ikkunaa olevan piikin j‰lkeen
    osuus_b = (stim_time * 1000 + startloc + winlen - (Rpeaks(pRpeak))) / winlen;

    HR = osuus_a * ibi_a + osuus_b * ibi_b;

end

% 3: tachycardia
if (R_events >= 2) 
    % Ikkunan sis‰ll‰ kaksi tai useampia R-piikkej‰
    % edellisen kohdan lauseke pit‰‰ luupata v‰liss‰ olevien R-piikkien
    % mukaan

    HR = 0;

    ibi_a = RR(aRpeak + 1);  %IBI ikkunan alussa kesken oleva ibi
    osuus_a = (Rpeaks(aRpeak + 1) - (stim_time * 1000 + startloc)) / winlen; %IBI-alun kerroin

    ibi_b = RR(pRpeak + 1); %Ikkunan jalkeen kesken j‰‰v‰ ibi
    osuus_b = (stim_time * 1000 + startloc + winlen - (Rpeaks(pRpeak))) / winlen;


    for i = (aRpeak + 1):(pRpeak - 1)
        ibi = RR(i + 1);
        osuus = ibi / winlen;
        HR = HR + osuus * ibi;
    end

    HR = HR + osuus_a * ibi_a + osuus_b * ibi_b;

end