clear;
% close all;
clc;
hold on;

% allchinID=[358 360 366 367 369 369 370];
allchinID= [375 378]; 


fighan.single= 1;
fighan.pool= 2;
saveFigs= 0;

DPoae_rootDataDir= '/media/parida/DATAPART1/Matlab/ExpData/Baselines/';
DPoae_OutFigDir= '/media/parida/DATAPART1/Matlab/Baseline_Folder_temporary/Out_Figure/';
DPoae_OutDataDir= '/media/parida/DATAPART1/Matlab/Baseline_Folder_temporary/Out_Data/';
% LatexDir= '/home/parida/Dropbox/Seminars/SHRP_Feb19/figures/';
LatexDir= '/home/parida/Dropbox/Academics/Prelims/slides/figures/';


if ~isfolder(DPoae_OutFigDir)
    mkdir(DPoae_OutFigDir);
end

if ~isfolder(DPoae_OutDataDir)
    mkdir(DPoae_OutDataDir);
end

ax=nan(length(allchinID),1);
xTicks= [300 500 1e3 2e3 4e3 10e3];
mrkrSize2=16;
mrkrSize1=12;
lw2= 3;
lw1= 2;
fSize= 18;

for chinVar=1:length(allchinID)
    chinID=allchinID(chinVar);
    addpath('/media/parida/DATAPART1/Matlab/Screening/');
    
    allChinDirs= dir([DPoae_rootDataDir '*' num2str(chinID) '*']);
    
    NH.dirNum= find(contains(lower({allChinDirs.name}'), {'pre', 'nh'}));
    NH.DataDir= allChinDirs(NH.dirNum).name;
    NH.dpFile= dir([DPoae_rootDataDir NH.DataDir filesep '*dpoae*']);
    NH.dpFile= [DPoae_rootDataDir NH.DataDir filesep NH.dpFile(1).name];
    NH.calibFile= get_lower_calibFile(NH.dpFile);
    
    HI.dirNum= find(contains(lower({allChinDirs.name}'), {'post', 'hi', 'pts', 'tts', 'follow', 'carbo'}));
    if numel(HI.dirNum)~=1
        warning('multiple directories');
        HI.dirNum= HI.dirNum(end);
    end
    HI.DataDir= allChinDirs(HI.dirNum).name;
    HI.dpFile= dir([DPoae_rootDataDir HI.DataDir filesep '*dpoae*']);
    HI.dpFile= [DPoae_rootDataDir HI.DataDir filesep HI.dpFile(1).name];
    HI.calibFile= get_lower_calibFile(HI.dpFile);
    
    
    % Pre-exposure
    run(NH.calibFile);
    NH.calibData=ans;
    NH.calibData=NH.calibData.CalibData;
    %     run(NH.dpFile);
    %     NH.dpData= ans;
    out_DPOAE_data= my_dpoae_analysis(NH.dpFile);
    NH.dpData=[out_DPOAE_data.dp_amp];
    NH.freqs= [out_DPOAE_data.freq2];
    calib_at_freqs=0*NH.freqs;
    for freqVar=1:length(NH.freqs)
        calib_at_freqs(freqVar)= CalibInterp(NH.freqs(freqVar)/1e3, NH.calibData);
    end
    
    % post-exposure
    run(HI.calibFile);
    HI.calibData=ans;
    HI.calibData=HI.calibData.CalibData;
    %     run(HI.dpFile);
    %     HI.dpData= ans;
    
    out_DPOAE_data= my_dpoae_analysis(HI.dpFile);
    HI.dpData=[out_DPOAE_data.dp_amp];
    HI.freqs= [out_DPOAE_data.freq2];
    
    calib_at_freqs=0*HI.freqs;
    for freqVar=1:length(HI.freqs)
        calib_at_freqs(freqVar)= CalibInterp(HI.freqs(freqVar)/1e3, HI.calibData);
    end
    
    %%
    figure(fighan.single);
    clf;
    hold on;
    %     ax(chinVar)=subplot(length(allchinID), 1, chinVar);
    l1= plot(NH.freqs, NH.dpData, '-ob', 'markersize', mrkrSize2, 'linew', lw2);
    l2= plot(HI.freqs, HI.dpData, '-dr', 'markersize', mrkrSize2, 'linew', lw2);
    
    set(gca, 'xscale', 'log', 'fontsize', fSize, 'xtick', xTicks);
    ylim([0 50]);
    grid on;
    title(['Q' num2str(chinID)]);
    ylabel('DP amplitude (dB)');
    xlabel('freq Hz');
    xlim([250 10e3]);
    fName= ['Q' num2str(chinID) '_dpoae'];
    
    legend('NH', 'HI', 'location', 'southwest');
    set(gcf, 'units', 'inches', 'position', [1 1 8 6]);
    
    if saveFigs
        saveas(fighan.single, [DPoae_OutFigDir fName], 'png');
    end
    
    %%
    figure(fighan.pool);
    hold on;
    
    if chinID~=369[DPoae_OutFigDir fName]
        plot(NH.freqs, NH.dpData, '-ob', 'color', l1.Color, 'markersize', mrkrSize1, 'linew', lw1);
        plot(HI.freqs, HI.dpData, '-dr', 'color', l2.Color, 'markersize', mrkrSize1, 'linew', lw1);
    else
        plot(NH.freqs, NH.dpData, '-o', 'color', 'c', 'markersize', mrkrSize1, 'linew', lw1);
        plot(HI.freqs, HI.dpData, '-d', 'color', 'm', 'markersize', mrkrSize1, 'linew', lw1);
    end
    
end

set(gca, 'xscale', 'log', 'fontsize', fSize, 'xtick', xTicks);
ylim([0 50]);
grid on;
% title(['Q' num2str(chinID)]);
ylabel('DP amplitude (dB)');
xlabel('freq Hz');
xlim([250 10e3]);
fName= 'pooled_dpoae';

legend('NH', 'HI', 'location', 'southwest');
set(gcf, 'Units', 'inches', 'Position', [1 1 6 4]);

if saveFigs
    saveas(fighan.pool, [DPoae_OutFigDir fName], 'png');
    saveas(fighan.pool, [LatexDir fName], 'epsc');
end
