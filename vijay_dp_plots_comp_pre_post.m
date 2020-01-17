clear;
clf;
clc;

allchinID=75:80;
% allchinID=78;

mrkrSize= 10;
fSize=14;
lw= 1.5;
ax=nan(length(allchinID),1);
xTicks= [300 500 1e3 2e3 4e3 10e3];
rootDataDir= '/media/parida/DATAPART1/Matlab/ExpData/VijayaData/UB ABR data/';
useNELvalues= 0;

fName=[];

nh_data_cell= cell(length(allchinID), 1);
hi_data_cell= cell(length(allchinID), 1);

for chinVar=1:length(allchinID)
    chinID=allchinID(chinVar);
    addpath('/media/parida/DATAPART1/Matlab/Screening/');
    
    allChinDirs= dir([rootDataDir '*' num2str(chinID) '*_L']);
    
    NH.dirNum= find(~contains(lower({allChinDirs.name}'), 'Post'));
    NH.DataDir= allChinDirs(NH.dirNum).name;
    NH.dpFile= dir([rootDataDir NH.DataDir filesep '*dpoae*']);
    NH.dpFile= [rootDataDir NH.DataDir filesep NH.dpFile(end).name];
    NH.calibFile= get_lower_calibFile(NH.dpFile);
    
    HI.dirNum= find(contains(lower({allChinDirs.name}'), 'post'));
    HI.DataDir= allChinDirs(HI.dirNum).name;
    HI.dpFile= dir([rootDataDir HI.DataDir filesep '*dpoae*']);
    HI.dpFile= [rootDataDir HI.DataDir filesep HI.dpFile(end).name];
    HI.calibFile= get_lower_calibFile(HI.dpFile);
    
    
    % Pre-exposure
    run(NH.calibFile);
    NH.calibData=ans;
    NH.calibData=NH.calibData.CalibData;
    run(NH.dpFile);
    NH.dpData= ans;
    
    if useNELvalues
        NH.dpData=NH.dpData.DpoaeData;
    else
        temp_dpData=NH.dpData.DpoaeData;
        temp_dpData(:,4)= 0*temp_dpData(:,4);
        PSDfreq= NH.dpData.Dpoaefreqs;
        PSDdpoae= NH.dpData.DpoaeSpectra;
        for freqVar= 1:size(temp_dpData,1)
            curDPOAE= PSDdpoae(freqVar, :);
            cur_dpFreq= temp_dpData(freqVar,3);
            spread= min(100, 0.05*temp_dpData(freqVar,1));
            valid_inds= find(PSDfreq>cur_dpFreq-spread & PSDfreq<cur_dpFreq+spread);
            [maxVal, maxInd]= max(curDPOAE(valid_inds));
            temp_dpData(freqVar, 4)= maxVal;
            
            %             clf
            %             semilogx(PSDfreq, curDPOAE);
            %             hold on;
            %             plot(PSDfreq(valid_inds(maxInd)), maxVal, 'r*');
            %             plot(PSDfreq(valid_inds), 0*PSDfreq(valid_inds), 'k.');
            
        end
        NH.dpData= temp_dpData;
    end
    
    NH.freqs= NH.dpData(:, 3);
    calib_at_freqs=0*NH.freqs;
    for freqVar=1:length(NH.freqs)
        calib_at_freqs(freqVar)= CalibInterp(NH.freqs(freqVar)/1e3, NH.calibData);
    end
    
    % post-exposure
    run(HI.calibFile);
    HI.calibData=ans;
    HI.calibData=HI.calibData.CalibData;
    run(HI.dpFile);
    HI.dpData= ans;
    
    if useNELvalues
        HI.dpData=HI.dpData.DpoaeData;
    else
        temp_dpData=HI.dpData.DpoaeData;
        temp_dpData(:,4)= 0*temp_dpData(:,4);
        PSDfreq= HI.dpData.Dpoaefreqs;
        PSDdpoae= HI.dpData.DpoaeSpectra;
        for freqVar= 1:size(temp_dpData,1)
            curDPOAE= PSDdpoae(freqVar, :);
            cur_dpFreq= temp_dpData(freqVar,3);
            spread= min(100, 0.05*temp_dpData(freqVar,1));
            valid_inds= find(PSDfreq>cur_dpFreq-spread & PSDfreq<cur_dpFreq+spread);
            [maxVal, maxInd]= max(curDPOAE(valid_inds));
            temp_dpData(freqVar, 4)= maxVal;
            
            %             clf
            %             semilogx(PSDfreq, curDPOAE);
            %             hold on;
            %             plot(PSDfreq(valid_inds(maxInd)), maxVal, 'r*');
            %             plot(PSDfreq(valid_inds), 0*PSDfreq(valid_inds), 'k.');
        end
        HI.dpData= temp_dpData;
    end
    
    HI.freqs= HI.dpData(:, 3);
    calib_at_freqs=0*HI.freqs;
    for freqVar=1:length(HI.freqs)
        calib_at_freqs(freqVar)= CalibInterp(HI.freqs(freqVar)/1e3, HI.calibData);
    end
    
    %     ax(chinVar)=subplot(length(allchinID), 1, chinVar);
    hold on;
    %     plot(NH.freqs, NH.dpData(:,4), '-o', 'Color', get_color('b'), 'markersize', mrkrSize, 'LineWidth', lw);
    %     plot(HI.freqs, HI.dpData(:,4), '-d', 'Color', get_color('r'), 'markersize', mrkrSize, 'LineWidth', lw);
    plot(NH.freqs, NH.dpData(:,4), '-o', 'Color', get_color('b'), 'markersize', mrkrSize, 'LineWidth', lw);
    plot(HI.freqs, HI.dpData(:,4), '-d', 'Color', get_color('r'), 'markersize', mrkrSize, 'LineWidth', lw);
    
    set(gca, 'xscale', 'log', 'fontsize', fSize, 'xtick', xTicks);
    ylim([-10 50]);
    %     grid on;
    %     title(['Q' num2str(chinID)]);
    ylabel('DP amplitude (dB)');
    xlabel('Frequency (Hz)');
    xlim([250 10e3]);
    fName= [fName 'Q' num2str(chinID) '_'];
    title('DPOAE @ 75/65 dB SPL')
    
    nh_data_cell{chinVar}= NH.dpData(:,4)';
    hi_data_cell{chinVar}= HI.dpData(:,4)';
end

nh_data_mat= cell2mat(nh_data_cell);
nh_data_mat(isnan(nh_data_mat))= 0;
hi_data_mat= cell2mat(hi_data_cell);
hi_data_mat(isnan(hi_data_mat))= 0;

figure(11);
clf;
hold on;
errorbar(NH.freqs(1:end-1), nanmean(nh_data_mat(:, 1:end-1), 1), nanstd(nh_data_mat(:, 1:end-1), [], 1), 'Color', get_color('b'), 'LineWidth', lw);
errorbar(NH.freqs(1:end-1), nanmean(hi_data_mat(:, 1:end-1), 1), nanstd(hi_data_mat(:, 1:end-1), [], 1), 'Color', get_color('r'), 'LineWidth', lw);
set(gca, 'xscale', 'log', 'fontsize', fSize, 'xtick', xTicks);
ylim([-10 50]);
ylabel('DP amplitude (dB)');
xlabel('Frequency (Hz)');
xlim([250 10e3]);
fName= [fName 'Q' num2str(chinID) '_'];
title('DPOAE @ 75/65 dB SPL')


fName= [fName 'Vijay_pre_post_DPgrams'];
legend('Pre-blast', 'Post-blast', 'location', 'southwest');
set(gcf, 'units', 'inches', 'position', [1 1 7 4]);
set(findall(gcf,'-property','FontSize'),'FontSize', fSize);
saveas(gcf, fName, 'tiff');