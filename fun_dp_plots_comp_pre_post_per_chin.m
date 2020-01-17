function fun_dp_plots_comp_pre_post_per_chin(allChins)


DPoae_rootDataDir= '/media/parida/DATAPART1/Matlab/ExpData/Baselines/';

xTicks= [500 1e3 5e3 10e3];
mrkrSize1=12;
lw1= 2;
fSize= 20;

for chinVar=1:length(allChins)
    chinID=allChins(chinVar);
    addpath('/media/parida/DATAPART1/Matlab/Screening/');
    
    allChinDirs= dir([DPoae_rootDataDir '*' num2str(chinID) '*']);
    
    NH.dirNum= find(contains(lower({allChinDirs.name}'), {'pre', 'nh'}));
    NH.DataDir= allChinDirs(NH.dirNum).name;
    NH.dpFile= dir([DPoae_rootDataDir NH.DataDir filesep '*dpoae*']);
    NH.dpFile= [DPoae_rootDataDir NH.DataDir filesep NH.dpFile(1).name];
    NH.calibFile= get_lower_calibFile(NH.dpFile);
    
    HI.dirNum= find(contains(lower({allChinDirs.name}'), {'post', 'hi', 'pts', 'tts', 'follow'}));
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
    NH.freqs_Hz= [out_DPOAE_data.freq2];
    calib_at_freqs=0*NH.freqs_Hz;
    for freqVar=1:length(NH.freqs_Hz)
        calib_at_freqs(freqVar)= CalibInterp(NH.freqs_Hz(freqVar)/1e3, NH.calibData);
    end
    
    % post-exposure
    run(HI.calibFile);
    HI.calibData=ans;
    HI.calibData=HI.calibData.CalibData;
    %     run(HI.dpFile);
    %     HI.dpData= ans;
    
    out_DPOAE_data= my_dpoae_analysis(HI.dpFile);
    HI.dpData=[out_DPOAE_data.dp_amp];
    HI.freqs_Hz= [out_DPOAE_data.freq2];
    
    calib_at_freqs=0*HI.freqs_Hz;
    for freqVar=1:length(HI.freqs_Hz)
        calib_at_freqs(freqVar)= CalibInterp(HI.freqs_Hz(freqVar)/1e3, HI.calibData);
    end
    
   
    %%
    hold on;
    
    if chinID~=369
        plot(NH.freqs_Hz/1e3, NH.dpData, '-ob', 'markersize', mrkrSize1, 'linew', lw1);
        plot(HI.freqs_Hz/1e3, HI.dpData, '-dr', 'markersize', mrkrSize1, 'linew', lw1);
    else
        plot(NH.freqs_Hz/1e3, NH.dpData, '-oc', 'markersize', mrkrSize1, 'linew', lw1);
        plot(HI.freqs_Hz/1e3, HI.dpData, '-dm', 'markersize', mrkrSize1, 'linew', lw1);
    end
    
end

set(gca, 'xscale', 'log', 'fontsize', fSize, 'xtick', xTicks);
ylim([0 50]);
grid on;
ylabel('DP Amplitude (dB)');
xlabel('Frequency (kHz)');
xlim([250 10e3]/1e3);

legend('NH', 'HI', 'location', 'southwest');