function [ detindex ] = thresholding( Error_sig,threshold_orig )
%THRESHOLDING using different thresholding values to get the activation
%indexes
%   input: Error_sig is a vector of the detection output, threshold_orig is
%          the original threshold value between 0 and 1 and we transfer into
%          data-based thresholding values;
%   output: detected indexes ;

sortedE=sort(Error_sig,'ascend');
threshold=sortedE(min([max([1,round(length(Error_sig)*threshold_orig)]),length(Error_sig)]));
%%%%thresholding the signal and extract activation index%%%
detindex=find(Error_sig<threshold);
% if ~isempty(index)
% % %     figure(4)
% % %     plot(1:length(E3),E3,index,E3(index),'r.');
% % %     figure(5)
% % %     plot(1:length(y),y,index,y(index),'r.');
%     I=zeros(length(E3),1);
%     Ind=zeros(length(E3)+1,1);
%     I(index)=1;
%     Ind(2:end)=I;
%     grping=cumsum(diff(Ind)>0).*I;%%%finding groups of index
%     [grpidx,~,val]=find(grping);
%     for i=1:max(val)
%         grpidx2=grpidx(val==i);
%         [~,idx]=min(E3(grpidx2));
%         detindex(i,1)=grpidx2(idx);
%     end
% else
%     detindex=[];
% end



end

