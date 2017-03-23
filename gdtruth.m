function [ actindex, deactindex ] = gdtruth( y, pw_threshold,high_bool)
%GDTRUTH function generate activation index and deactivation index using 
%        total variance methods 
%   input: data y vector with N*1 dimension;pw_threshold: thresholding
%   power meters with activation or not
%   output: generating activatin timestamp and deactivation timestamp

idx=find(y>pw_threshold, 1);
if isempty(idx)
    actindex=[]; deactindex=[];
else
   lmax = tvdiplmax(y);
    % Perform TV denoising for lambda across a range of values up to a small
    % fraction of the maximum found above  lratio = [1e-4 1e-3 1e-2 1e-1];
    if high_bool
       lratio=1e-1;
       [tv_p, ~, ~] = tvdip(y,lmax*lratio,0,1e-3,50);
%        figure(5)
%        plot(1:length(y),y,1:length(tv_p),tv_p,'g-');
%        title('total variation output power signal');
    else
%         lratio=1e-4;
        tv_p=y; %%%%not using total variance
    end     
       detect_p=conv(tv_p,[ones(60,1);-ones(60,1)]/120);%detecting edges
       detect_p=detect_p(120:end-120);
       actidx=find(detect_p>=0.4*max(detect_p));
%        actidx=actidx+60;
       %%%finding activation index%%%%%%
       if ~isempty(actidx) && max(detect_p)>20
           I=zeros(length(detect_p),1);
           Ind=zeros(length(detect_p)+1,1);
           I(actidx)=1;
           Ind(2:end)=I;
           grping=cumsum(diff(Ind)>0).*I;%%%finding groups of index
           [grpidx,~,val]=find(grping);
           actindex=[];
           for m=1:max(val)
                grpidx2=grpidx(val==m);
                [~,idx]=max(detect_p(grpidx2));
                actindex(m,1)=grpidx2(idx)+60;
   %%%%%%%delete the activation indexes not starting at zero or a small value%%%%
                if y(max(actindex(m,1)-240,1))>0.105*max(y) 
                    actindex(m)=[];
                end
           end
       else
           actindex=[];
       end
       actindex=actindex(actindex~=0);
       %%%%%%deleting other activation indexes that are less than 1s apart%%%
       if length(actindex)~=1
           redu_idx=find(diff(actindex)<=120);
           redu_idx=redu_idx+1;
           actindex(redu_idx)=[];
       end
%        figure(4)
%        plot(1:length(detect_p),detect_p,actidx,detect_p(actidx),'r*')
%        hold on
%        plot(actindex,detect_p(actindex),'g.')
%        hold off
%        title('detection for ground truth');
        %%%%%%finding deactivation index%%%%%%
       deactidx=find(detect_p<=0.2*min(detect_p) & detect_p>=min(detect_p));
%        deactidx=deactidx+60;
       if ~isempty(deactidx) && min(detect_p)<-20
           I=zeros(length(detect_p),1);
           Ind=zeros(length(detect_p)+1,1);
           I(deactidx)=1;
           Ind(2:end)=I;
           grping=cumsum(diff(Ind)>0).*I;%%%finding groups of index
           [grpidx,~,val]=find(grping);
           deactindex=[];
           for m=1:max(val)
               grpidx2=grpidx(val==m);
               [~,idx]=min(detect_p(grpidx2));
               deactindex(m,1)=grpidx2(idx)+60;
                 if y(min(length(y),deactindex(m,1)+120))> 0.11*max(y)
                    deactindex(m)=[];
                end
           end
       else
           deactindex=[];
       end
        deactindex=deactindex(deactindex~=0);
       %%%%%%deleting other activation indexes that are less than 1s apart%%%
       if length(deactindex)~=1
           redu_idx2=find(diff(deactindex)<=120);
           redu_idx2=redu_idx2;
           deactindex(redu_idx2)=[];
       end
end

end


