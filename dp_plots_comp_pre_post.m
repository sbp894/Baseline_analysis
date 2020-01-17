% Plots pre versus post per animal in a different subplot row! 
clear;
clf;
clc;

allchinID=[358 360 366 367 369 370];

mrkrSize=16;
fSize=16;
ax=nan(length(allchinID),1);
xTicks= [300 500 1e3 2e3 4e3 10e3];
rootDataDir= '/media/parida/DATAPART1/Matlab/ExpData/Baselines/';

fName=[];

for chinVar=1:length(allchinID)
    chinID=allchinID(chinVar);
    addpath('/media/parida/DATAPART1/Matlab/Screening/');
    
    allChinDirs= dir([rootDataDir '*' num2str(chinID) '*']);
    
    NH.dirNum= find(contains(lower({allChinDirs.name}'), {'pre', 'nh'}));
    NH.DataDir= allChinDirs(NH.dirNum).name;
    NH.dpFile= dir([rootDataDir NH.DataDir filesep '*dpoae*']);
    NH.dpFile= [rootDataDir NH.DataDir filesep NH.dpFile(1).name];
    NH.calibFile= get_lower_calibFile(NH.dpFile);
    
    HI.dirNum= find(contains(lower({allChinDirs.name}'), {'post', 'hi', 'pts', 'tts'}));
    HI.DataDir= allChinDirs(HI.dirNum).name;
    HI.dpFile= dir([rootDataDir HI.DataDir filesep '*dpoae*']);
    HI.dpFile= [rootDataDir HI.DataDir filesep HI.dpFile(1).name];
    HI.calibFile= get_lower_calibFile(HI.dpFile);
    
    
    % Pre-exposure
    run(NH.calibFile);
    NH.calibData=ans;
    NH.calibData=NH.calibData.CalibData;
    run(NH.dpFile);
    NH.dpData= ans;
    NH.dpData=NH.dpData.DpoaeData;
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
    HI.dpData=HI.dpData.DpoaeData;
    HI.freqs= HI.dpData(:, 3);
    calib_at_freqs=0*HI.freqs;
    for freqVar=1:length(HI.freqs)
        calib_at_freqs(freqVar)= CalibInterp(HI.freqs(freqVar)/1e3, HI.calibData);
    end
    
    ax(chinVar)=subplot(length(allchinID), 1, chinVar);
    hold on;
    plot(NH.freqs, NH.dpData(:,4), '-o', 'markersize', mrkrSize);
    plot(HI.freqs, HI.dpData(:,4), '-d', 'markersize', mrkrSize);
    
    set(gca, 'xscale', 'log', 'fontsize', fSize, 'xtick', xTicks);
    ylim([0 50]);
    grid on;
    title(['Q' num2str(chinID)]);
    ylabel('DP amplitude (dB)');
    xlabel('freq Hz');
    xlim([250 10e3]);
    fName= [fName 'Q' num2str(chinID) '_'];
end
fName= [fName 'pre_post_DPgrams'];
legend('NH', 'HI', 'location', 'southwest');
linkaxes(ax, 'x');
set(gcf, 'units', 'inches', 'position', [1 1 8 6]);
% saveas(gcf, fName, 'tiff');