function [features] = extractFeatures(accsCells)
%EXTRACTFEATURES Summary of this function goes here
% AR The range of amplitude of each channel
% RMS The root mean square value (RMS) of each channel
% NPCR The peaks of the normalized cross-correlation function
% NTL The time lag corresponding to peaks of the normalized cross-correlation function
% DF The dominant frequency component
% ER The ratio of the energy associated with the dominant frequency component
% of the total energy
% SE Signal entropy
% weight Normalization parameters


for i = 1:size(accsCells,2)
    if size(accsCells{i},1)>5
        temp = accsCells{i};
        timestamp = temp(1);
        FT = fft(accsCells{i},13);
        AR = get_amplitude_range(FT(:,5));
        RMS = get_channel_RMS(FT(:,5));
        %[NPCR,NTL] = get_norm_peaksNtime_lags(accsCells{i});
        DF = get_domin_frq(FT(:,5));
        ER = get_energy_ratio(FT(:,5));
        SE = get_entropy(accsCells{i});
        %weight = size(accsCells{i},1)/5926725;
        features = [features;timestamp,AR,RMS,DF,ER,SE];
    end
end
end

function [AR] = get_amplitude_range(FT)
amplitude = abs(FT)/size(FT,1)*2;
AR = [max(amplitude)-min(amplitude)];
end

function [RMS] = get_channel_RMS(FT)
RMS = rms(abs(FT));
end

function [NPCR,NTL] = get_norm_peaksNtime_lags(accs)
[correlation,timelags] = xcorr(accs(:,5));
[NPCR,index] = max(correlation);
NTL = timelags(index);
end

function [DF] = get_domin_frq(FT)
[~,DF] = max(abs(FT(2:end)));
DF = DF+1;
end

function [ER] = get_energy_ratio(FT)
ER = max(abs(FT))/(sum(abs(FT).^2));
end

function [SE] = get_entropy(accs)
% p = hist(accs(:,5),size(accs,1));
% temp = p(p>0).*log2(p(p>0));
% SE = -sum(temp);
SE = wentropy(accs,'log energy');
end

