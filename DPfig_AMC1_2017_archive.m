%% this code must be run from the same directory that the summary DP data
%% mat files are in. Otherwise you'll need to add a cd statement.
clear
myLW = 1.5;
myalpha = 0.01/27;  % alpha corrected for 27 t-tests 1 per freq
% myalpha = 0.05;  % alpha not corrected for multiple tests
my_xlim = [200 10000];
my_ylim = [0 55];
% lightcolors = [ .2 .2 .2;1 .2 .2];
lightcolors = [ .7 .7 .7;1 .7 .7;.7 .7 1];
plot_individuals = true;
dolegend = true;
legendfont = 12;
printpdf = 0;
mycolors = {'k','k:';'r','r:';'b','b:'};
% hearingstatus = {'NH';'TTS'};
hearingstatus = {'NH';'TTS';'TTS2'};
% ftypelist = {'*65.mat'; '*75.mat'};
% ftypelist = {['*' hearingstatus '*65.mat'];['*' hearingstatus '*75.mat']};
% ftypelist = { ['*NH*65.mat'];['*TTS*65.mat']};
% ftypes = ftypelist([1 2]);
fnamecharidx = 5:8; %use for MW filenaming(includes Q in chin ID)
L2 = {'65';'75'};
hold off
for j = 1:length(L2)
    dpt_str = ['L1 = 75; L2 = ' L2{j}];
    for k = 1:length(hearingstatus)
        h(j) = figure(j);
        h(j+2) = figure(j+2);
        hs = hearingstatus{k};
        dpt = [hs L2{j}];
        fnames = cellstr(ls(['*' hs '_*' L2{j} '.mat']));
        for i = 1:length(fnames)
            load(fnames{i})
            if i == 1
                DPall.(dpt)(1:3,:) = dpoae.data(:,1:3)';
                DPnf.(dpt) = dpoae.noisefloor';
            end
            DPall.(dpt)(i+3,:) = dpoae.data(:,4)';
            DPnf.(dpt)(:,i) = dpoae.noisefloor';
            if plot_individuals
                figure(h(j))
                semilogx(DPall.(dpt)(3,:),[DPall.(dpt)(i+3,:)],'x','Color',lightcolors(k,:),...
                    'DisplayName',fnames{i}(fnamecharidx),'LineWidth',1);hold on;
                figure(h(j+2))
                semilogx(DPall.(dpt)(3,:),[DPall.(dpt)(i+3,:)],'x','Color',lightcolors(k,:),...
                    'DisplayName',fnames{i}(fnamecharidx),'LineWidth',1);hold on;
            end
        end
        
        mymean = mean(DPall.(dpt)(4:end,:));
        mysd = std(DPall.(dpt)(4:end,:));
        mysem = mysd/sqrt(length(fnames));
        DPall.(dpt) = [DPall.(dpt); mymean; mysd]; %DPall = [vF1;vF2;vFdp;nRows x DPmag; mean; s.d.]
        
        NFmean = mean(DPnf.(dpt),2);
        NFsd = std(DPnf.(dpt),0,2);
        NFsem = NFsd/sqrt(length(fnames));
        DPnf.(dpt) = [DPnf.(dpt) NFmean NFsd];  %DPnf = (27Rows)[DPnf, mean, s.d.]
        
        figure(h(j))
        hax(j,k) = semilogx(DPall.(dpt)(3,:),mymean, mycolors{k,1},'DisplayName',[hs 'Mean'],'LineWidth',myLW);hold on;
        semilogx(DPall.(dpt)(3,:),mymean+mysem, mycolors{k,2},'LineWidth',myLW)
        semilogx(DPall.(dpt)(3,:),mymean-mysem, mycolors{k,2},'LineWidth',myLW)
%         semilogx(DPall.(dpt)(3,:),NFmean-3*NFsem, mycolors{k,2},'LineWidth',myLW)
        semilogx(DPall.(dpt)(3,:),NFmean+2*NFsem, mycolors{k,2},'LineWidth',myLW)
        title(sprintf('Mean DPs (%s dBSPL) for NH and TTS animals +/- 1 S.E.M.',dpt_str),'FontSize',18)
        ylim(my_ylim);
        %     xlim(my_xlim);
        
        figure(h(j+2))
        hax(j+2,k) = semilogx(DPall.(dpt)(3,:),mymean,mycolors{k,1},'DisplayName',[hs 'Mean'],'LineWidth',myLW);hold on;
        semilogx(DPall.(dpt)(3,:),mymean+2*mysem, mycolors{k,2},'LineWidth',myLW)
        semilogx(DPall.(dpt)(3,:),mymean-2*mysem, mycolors{k,2},'LineWidth',myLW)
        %     semilogx(DPall.(dpt)(3,:),NFmean-3*NFsem, mycolors{j,2},'LineWidth',myLW)
        semilogx(DPall.(dpt)(3,:),NFmean+2*NFsem, 'Color', lightcolors(k,:),'LineWidth',myLW)
        fl = fill([DPall.(dpt)(3,1) DPall.(dpt)(3,:) DPall.(dpt)(3,end)],[my_ylim(1); NFmean; my_ylim(1)], lightcolors(k,:),'LineWidth',myLW,'EdgeColor','none');
        set(fl,'facealpha',.5)
        title(sprintf('Mean DPs (%s dBSPL) for NH and TTS animals with 95%% C.I.''s',dpt_str),'FontSize',18)
        ylim(my_ylim);
        %             xlim(my_xlim);
        
        %     tests/plots if the DPmean is not significantly above the noisefloor for the group
        %         foo2 = ~logical(ttest(DPall.(dpt)(4:end-2,:),DPnf.(dpt)(:,1:end-2)',myalpha));
        %% %uses the bonferroni-holm sequential ttest
        alphavec = myalpha*(1:size(DPall.(dpt),2));
        [~,foo3]=ttest(DPall.(dpt)(4:end-2,:),DPnf.(dpt)(:,1:end-2)',myalpha);
        [foo4,foo5] = sort(foo3);
        foo2 = alphavec<foo4;
        semilogx(DPall.(dpt)(3,foo5(foo2)),mymean(foo5(foo2))+5*mysem(foo5(foo2)), 'b*')
        drawnow
        
    end
    if dolegend
        hl(j) = legend(hax(j,:),hearingstatus,'Location','northwest');
        hl(j).FontSize = legendfont;
        hl(j+2) = legend(hax(j+2,:),hearingstatus,'Location','northwest');
        hl(j+2).FontSize = legendfont;
    end
    if printpdf
                set(gcf,'PaperOrientation','Portrait','PaperPosition',[0 0 8.5 11]);
%                 picfile = strjoin(['..\Summary\PDFs\' datestr(now,'YYYY_mm_dd') '_ABR_TH_pre-post_' chins{k} '_FU_' FUdates{k}],'');
                picfile = ['..\PDFs\' datestr(now,'YYYY_mm_dd') 'AMcohort1_DPgrams_BL2-FU1-FU2'];
                print(h(k),picfile,'-dpdf')
    end
end
if 0
    alphavec = myalpha*(1:size(DPall.(dpt),2));
    [~,foo3]=ttest(DPall.('NH65')(4:end-2,:),DPnf.('TTS65')(:,1:end-2)',myalpha);
    [foo4,foo5] = sort(foo3);
    foo2 = alphavec<foo4;
    semilogx(DPall.('NH65')(3,foo5(foo2)),mymean(foo5(foo2))+5*mysem(foo5(foo2)), 'b*')
end