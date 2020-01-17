clear;
clc;
close all;


saveFigs= 1;
allChins= [358 360 366 367 370 371 373 374 379 369];
% allChins= [358 360 366 367 370];

DataDir= '/media/parida/DATAPART1/Matlab/ABR/Output/';
figOutDir= '/media/parida/DATAPART1/Matlab/SNRenv/SFR_sEPSM/Figure_Out/';

LatexDir= '/home/parida/Dropbox/Articles/Loss_of_tonotopy_in_HI_FFR/figures/';
LatexDir_prelims= '/home/parida/Dropbox/Academics/Prelims/slides/figures/';

types= {'NH', 'HI'};
freqs2use_Hz= [.5 1 2 4 8]*1e3;
freqs2use_kHz= freqs2use_Hz/1e3;

thresh_data.nh.z= {};
thresh_data.hi.z= {};
thresh_data.nh.amp= {};
thresh_data.hi.amp= {};
nhChins= [];
hiChins= [];

for chinVar= 1:length(allChins)
    cur_ChinID= allChins(chinVar);
    for typeVar= 1:length(types)
        cur_type= types{typeVar};
        curDir= dir(sprintf('%sQ%d_%s*', DataDir, cur_ChinID, cur_type));
        if numel(curDir)==2 && cur_ChinID==369
            % Q369 has 2 post-exposure baselines. 
            curDir= curDir(strcmp({curDir.name}', 'Q369_HI_2019_01_16'));
        end
        if ~isempty(curDir)
            fprintf('Using %s\n', curDir.name);
            curData_fName= dir(sprintf('%s%s%s*.mat', DataDir, curDir.name, filesep));
            curData= load(sprintf('%s%s%s%s', DataDir, curDir.name, filesep, curData_fName.name));
            curData= curData.abrs;
            [~, inds]= ismember(freqs2use_Hz, curData.thresholds(:,1));
            if strcmp(cur_type, 'NH')
                thresh_data.nh.z= [thresh_data.nh.z, curData.thresholds(inds,2)];
                nhChins= [nhChins; cur_ChinID]; %#ok<*AGROW>
                %                 thresh_data.nh.amp= [thresh_data.nh.amp, curData.thresholds(:,3)];
            elseif strcmp(cur_type, 'HI')
                thresh_data.hi.z= [thresh_data.hi.z, curData.thresholds(inds,2)];
                hiChins= [hiChins; cur_ChinID];
                %                 thresh_data.hi.amp= [thresh_data.hi.amp, curData.thresholds(:,3)];
            end
            
        else
            warning('No %s data for Q%d\n', cur_type, cur_ChinID);
        end
        
    end
end

% % % % % % DPoae_rootDataDir= '/media/parida/DATAPART1/Matlab/ExpData/Baselines/';
% % % % % % 
% % % % % % for chinVar=1:length(allChins)
% % % % % %     chinID=allChins(chinVar);
% % % % % %     addpath('/media/parida/DATAPART1/Matlab/Screening/');
% % % % % %     
% % % % % %     allChinDirs= dir([DPoae_rootDataDir '*' num2str(chinID) '*']);
% % % % % %     
% % % % % %     NH.dirNum= find(contains(lower({allChinDirs.name}'), {'pre', 'nh'}));
% % % % % %     NH.DataDir= allChinDirs(NH.dirNum).name;
% % % % % %     NH.dpFile= dir([DPoae_rootDataDir NH.DataDir filesep '*dpoae*']);
% % % % % %     NH.dpFile= [DPoae_rootDataDir NH.DataDir filesep NH.dpFile(1).name];
% % % % % %     NH.calibFile= get_lower_calibFile(NH.dpFile);
% % % % % %     
% % % % % %     HI.dirNum= find(contains(lower({allChinDirs.name}'), {'post', 'hi', 'pts', 'tts', 'follow'}));
% % % % % %     HI.DataDir= allChinDirs(HI.dirNum).name;
% % % % % %     HI.dpFile= dir([DPoae_rootDataDir HI.DataDir filesep '*dpoae*']);
% % % % % %     HI.dpFile= [DPoae_rootDataDir HI.DataDir filesep HI.dpFile(1).name];
% % % % % %     HI.calibFile= get_lower_calibFile(HI.dpFile);
% % % % % %     
% % % % % %     
% % % % % %     % Pre-exposure
% % % % % %     run(NH.calibFile);
% % % % % %     NH.calibData=ans;
% % % % % %     NH.calibData=NH.calibData.CalibData;
% % % % % %     %     run(NH.dpFile);
% % % % % %     %     NH.dpData= ans;
% % % % % %     out_DPOAE_data= my_dpoae_analysis(NH.dpFile);
% % % % % %     NH.dpData=[out_DPOAE_data.dp_amp];
% % % % % %     NH.freqs_Hz= [out_DPOAE_data.freq2];
% % % % % %     calib_at_freqs=0*NH.freqs_Hz;
% % % % % %     for freqVar=1:length(NH.freqs_Hz)
% % % % % %         calib_at_freqs(freqVar)= CalibInterp(NH.freqs_Hz(freqVar)/1e3, NH.calibData);
% % % % % %     end
% % % % % %     
% % % % % %     % post-exposure
% % % % % %     run(HI.calibFile);
% % % % % %     HI.calibData=ans;
% % % % % %     HI.calibData=HI.calibData.CalibData;
% % % % % %     %     run(HI.dpFile);
% % % % % %     %     HI.dpData= ans;
% % % % % %     
% % % % % %     out_DPOAE_data= my_dpoae_analysis(HI.dpFile);
% % % % % %     HI.dpData=[out_DPOAE_data.dp_amp];
% % % % % %     HI.freqs_Hz= [out_DPOAE_data.freq2];
% % % % % %     
% % % % % %     calib_at_freqs=0*HI.freqs_Hz;
% % % % % %     for freqVar=1:length(HI.freqs_Hz)
% % % % % %         calib_at_freqs(freqVar)= CalibInterp(HI.freqs_Hz(freqVar)/1e3, HI.calibData);
% % % % % %     end    
% % % % % % end

%% plot
mrkSize= 6;
lw1= 2;
lw3= 5;
fSize= 20;

nh_data= cell2mat(thresh_data.nh.z)';
hi_data= cell2mat(thresh_data.hi.z)';
outlier_chin= 369;

reg_ind_nh= find(ismember(nhChins, setxor(nhChins, outlier_chin)));
reg_ind_hi= find(ismember(hiChins, setxor(nhChins, outlier_chin)));
outlier_ind_nh= find(ismember(nhChins, outlier_chin));
outlier_ind_hi= find(ismember(hiChins, outlier_chin));


figure(1);
clf;


sp_ax(1)= subplot(121);
[~, co_struct]= set_colblind_order();
hold on;
plot(freqs2use_kHz, nh_data(reg_ind_nh, :)', '-o', 'color', co_struct.b, 'markersize', mrkSize, 'linew', lw1);
plot(freqs2use_kHz, nh_data(outlier_ind_nh, :)', '-d', 'color', co_struct.lb, 'markersize', mrkSize, 'linew', lw1);
plot(freqs2use_kHz, nanmean(nh_data(reg_ind_nh, :), 1), '-', 'color', 'b', 'markersize', mrkSize, 'linew', lw3);

plot(freqs2use_kHz, hi_data(reg_ind_hi, :)', '-o', 'color', co_struct.r,'markersize', mrkSize, 'linew', lw1);
plot(freqs2use_kHz, hi_data(outlier_ind_hi, :)', '-d', 'color', co_struct.lr,'markersize', mrkSize, 'linew', lw1);
plot(freqs2use_kHz, nanmean(hi_data(reg_ind_hi, :), 1), '-', 'color', 'r','markersize', mrkSize, 'linew', lw3);

set(gca, 'xscale', 'log', 'xtick', freqs2use_kHz);
xlim([.4 10]);
xlabel('Frequency (kHz)');
ylabel('ABR Threshold (dB SPL)');
set(gca, 'fontsize', fSize, 'box', 'off');

% lg= plot(nan, nan, '-bd', nan, nan, '-ro','markersize', mrkSize, 'linew', lw1);
% legend(lg, 'NH', 'HI');

%%
sp_ax(2)= subplot(122);
[~, co_struct]= set_colblind_order();
DPoae_rootDataDir= '/media/parida/DATAPART1/Matlab/ExpData/Baselines/';

xTicks= freqs2use_Hz;

% each column is for one animal
freq27= load('default_27freq_DPOAE.mat');
freq27= freq27.default_27freq_DPOAE;
dp_data_nh= nan(27, length(allChins));
dp_data_hi= nan(27, length(allChins));

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
    existHI= ~isempty(find(contains(lower({allChinDirs.name}'), {'post', 'hi', 'pts', 'tts', 'follow'}), 1));
    
    if existHI
        HI.DataDir= allChinDirs(HI.dirNum).name;
        HI.dpFile= dir([DPoae_rootDataDir HI.DataDir filesep '*dpoae*']);
        HI.dpFile= [DPoae_rootDataDir HI.DataDir filesep HI.dpFile(1).name];
        HI.calibFile= get_lower_calibFile(HI.dpFile);
    end
    
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
    
    if existHI
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
    end
   
    %%
    hold on;
    
    if chinID~=369
        plot(NH.freqs_Hz/1e3, NH.dpData, '-o', 'color', co_struct.b, 'markersize', mrkSize, 'linew', lw1);
        plot(HI.freqs_Hz/1e3, HI.dpData, '-d', 'color', co_struct.r, 'markersize', mrkSize, 'linew', lw1);
    else
        plot(NH.freqs_Hz/1e3, NH.dpData, '-o', 'color', co_struct.lb, 'markersize', mrkSize, 'linew', lw1);
        if existHI
            plot(HI.freqs_Hz/1e3, HI.dpData, '-d', 'color', co_struct.lr, 'markersize', mrkSize, 'linew', lw1);
        end
    end
    if numel(NH.dpData)~=27
        fprintf('chin %d\n', chinID);
    end
    dp_data_nh(:, chinVar)= interp1(NH.freqs_Hz, NH.dpData, freq27);
    dp_data_hi(:, chinVar)= interp1(HI.freqs_Hz, HI.dpData, freq27);
end

plot(NH.freqs_Hz/1e3, nanmean(dp_data_nh, 2), '-', 'color', 'b', 'markersize', mrkSize, 'linew', lw3);
plot(HI.freqs_Hz/1e3, nanmean(dp_data_hi, 2), '-', 'color', 'r', 'markersize', mrkSize, 'linew', lw3);


set(gca, 'xscale', 'log', 'fontsize', fSize, 'xtick', xTicks/1e3);
ylim([0 50]);
grid on;
ylabel('DP Amplitude (dB SPL)');
xlabel('Frequency (kHz)');
xlim([450 10.1e3]/1e3);
box off;

lg(1)= plot(nan, nan, '-o', 'color', co_struct.b,'markersize', mrkSize, 'linew', lw1);
lg(2)= plot(nan, nan, '-d', 'color', co_struct.r,'markersize', mrkSize, 'linew', lw1);
legend(lg, 'NH', 'HI', 'Location', 'southeast', 'box', 'off');
grid off;

linkaxes(sp_ax, 'y');

set(gcf, 'Units', 'inches', 'Position', [1 1 11 4.5])

add_subplot_letter(1, 2, 30);

fName= 'pooled_abr_dpoae';
if saveFigs
   saveas(gcf, [LatexDir fName], 'epsc');
end