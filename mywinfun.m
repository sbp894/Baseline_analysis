function rmswin = mywinfun(D, levoffset, cur_rows)
%% This function is used by ABR_meta for determining the time window for RMS amplitude normalization

use_p5win = 0;  %toggle using flat 4.5ms win after p1 return to baseline, or use picked p5 indices
xDoffset = 2;    %indexing offset for D.x and D.waves due to first 2 cols being freq and lev
thisrow = find(cur_rows,1)+levoffset;
dd=D.waves(thisrow,(xDoffset+1):end);
tdt_SR = length(dd)/31.0478; %approximates TDT samp. rate for odd datasets with wrong numel for waves

% tdt_SR = length(;
if ~isnan(D.x(thisrow,4))
    p1idcs =ceil(D.x(thisrow,[3 4])*tdt_SR)+xDoffset-1;
else
    'asdf'
    p1idcs =ceil([D.x(thisrow,3)]*tdt_SR);
    [pks,p_x]=findpeaks(dd);
    [troughs,t_x]=findpeaks(-dd,10);
    troughs = -troughs; t_x = t_x*10;
    p1idcs(2) = t_x(find(t_x>p_x(find(p_x>p1idcs(1),1)),1));
end
rmswin(1) = find(D.waves(thisrow,p1idcs(2):end)>0,1)+p1idcs(2)-xDoffset-1;%-3;

if use_p5win %doesn't work fully, currently just use the 4.5ms win only
    if ~isnan(D.x(thisrow,11))& ~isnan(D.x(thisrow,12))
        p5idcs =ceil(D.x(thisrow,[11 12])*tdt_SR)+1;
    else
        if ~isnan(D.x(thisrow,11))    %P5 picked in analysis N5 not
            p5idcs(1) = floor([D.x(thisrow,11)]*tdt_SR);
        else                %if neither P5 or N5 were picked during analysis
            disp('neither P5 nor N5 were picked during analysis')
            %          [pks,p_x]=findpeaks(D.waves(3,3:end));
            [pks5, p5_x] = findpeaks(D.waves(3,p1idcs(1)+[0:140]),[p1idcs(1)+[0:140]]/tdt_SR,'MinPeakProminence',.05,'MinPeakDistance',.5);
            [ts5, t5_x] = findpeaks(-D.waves(3,p1idcs(1)+[0:140]),[p1idcs(1)+[0:140]]/tdt_SR,'MinPeakProminence',.05,'MinPeakDistance',.5);
            ts5 = -ts5;
            p5idcs(4)
            p5idcs(2) = t_x(find(t_x>p_x(find(p_x>p1idcs(1),1)),1));
            
        end
        [troughs,t_x]=findpeaks(-dd,10);
        troughs = -troughs; t_x = t_x*10;
        p5idcs(2) = t_x(find(t_x>p_x(find(p_x>p5idcs(1),5)),1));
    end
else
    rmswin(2) = find(diff(0<dd((ceil(rmswin(1)+tdt_SR*4.5)):end)),1)+(ceil(rmswin(1)+tdt_SR*4.5));
end
end