clear;
clf;
clc;
allchinID=[356 362];

mrkrSize=16;
fSize=16;
ax=nan(length(allchinID),1);
xTicks= [300 500 1e3 2e3 4e3 10e3];

for chinVar=1:length(allchinID)
    chinID=allchinID(chinVar);
    addpath('/media/parida/DATAPART1/Matlab/Screening/');
    if chinID==353
        calibFile_NH= '/media/parida/DATAPART1/Matlab/ExpData/NelData/SP-2018_07_12-Q353_baseline_pre/p0001_calib.m';
        dpFile_NH='/media/parida/DATAPART1/Matlab/ExpData/NelData/SP-2018_07_12-Q353_baseline_pre/p0002_dpoae.m';
        calibFile_HI= '/media/parida/DATAPART1/Matlab/ExpData/NelData/SP-2018_08_07-Q353_PTS_baselines_post_exposure/p0001_calib.m';
        dpFile_HI='/media/parida/DATAPART1/Matlab/ExpData/NelData/SP-2018_08_07-Q353_PTS_baselines_post_exposure/p0002_dpoae.m';
    elseif chinID==361
        calibFile_NH= '/media/parida/DATAPART1/Matlab/ExpData/NelData/SP-2018_07_12-Q361_baseline_pre/p0001_calib.m';
        dpFile_NH='/media/parida/DATAPART1/Matlab/ExpData/NelData/SP-2018_07_12-Q361_baseline_pre/p0002_dpoae.m';
        calibFile_HI= '/media/parida/DATAPART1/Matlab/ExpData/NelData/SP-2018_08_07-Q361_baseline_PTS_post_exposure/p0001_calib.m';
        dpFile_HI='/media/parida/DATAPART1/Matlab/ExpData/NelData/SP-2018_08_07-Q361_baseline_PTS_post_exposure/p0002_dpoae.m';
    end
    
    
    % Pre-exposure
    run(calibFile_NH);
    calibData_NH=ans;
    calibData_NH=calibData_NH.CalibData;
    run(dpFile_NH);
    dpData_NH= ans;
    dpData_NH=dpData_NH.DpoaeData;
    freqs_NH= dpData_NH(:, 3);
    calib_at_freqs=0*freqs_NH;
    for freqVar=1:length(freqs_NH)
        calib_at_freqs(freqVar)= CalibInterp(freqs_NH(freqVar)/1e3, calibData_NH);
    end
    
    % post-exposure
    run(calibFile_HI);
    calibData_HI=ans;
    calibData_HI=calibData_HI.CalibData;
    run(dpFile_HI);
    dpData_HI= ans;
    dpData_HI=dpData_HI.DpoaeData;
    freqs_HI= dpData_HI(:, 3);
    calib_at_freqs=0*freqs_HI;
    for freqVar=1:length(freqs_HI)
        calib_at_freqs(freqVar)= CalibInterp(freqs_HI(freqVar)/1e3, calibData_HI);
    end
    
    ax(chinVar)=subplot(length(allchinID), 1, chinVar);
    hold on;
    plot(freqs_NH, dpData_NH(:,4), '-o', 'markersize', mrkrSize);
    plot(freqs_HI, dpData_HI(:,4), '-d', 'markersize', mrkrSize);
    
    set(gca, 'xscale', 'log', 'fontsize', fSize, 'xtick', xTicks);
    ylim([0 50]);
    grid on;
    title(['Q' num2str(chinID)]);
    ylabel('DP amplitude (dB)');
    xlabel('freq Hz');
    xlim([250 10e3]);
end
legend('NH', 'HI', 'location', 'southwest');
linkaxes(ax, 'x');
set(gcf, 'units', 'inches', 'position', [1 1 8 6]);
saveas(gcf, 'Q353_361_pre_post_DPgrams', 'tiff');