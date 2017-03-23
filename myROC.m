function score=myROC(gd_truth_label,detect_index,submeter,winsize)
%myROC generate ture positive rate, false positive rate for a single file
%   input: ground truth label, detection label, and y is object signal; 
%          windowsize:base for calculating TPR and FPR;
%   output: score with TP, FP, FN and TN that are used for plotting ROC ;

%%%%%%%%initialization%%%%%%

num_pos=0;num_neg=0;
TP=0;TN=0;FP=0;FN=0;
instance_num=floor(length(submeter)/winsize);
activation=zeros(length(submeter),1);
activation(gd_truth_label)=1;
detection=zeros(length(submeter),1);
detection(detect_index)=1;

% % %%%%%%%%%getting scores%%%%%%%
% % score=zeros(2,2);
% % if isempty(gd_truth_label) && isempty(detect_index)
% %     score(2,2)=instance_num; return
% % end
% % if isempty(gd_truth_label) && ~isempty(detect_index)
% %     score(1,2)=length(detect_index); 
% %     score(2,2)=instance_num-length(detect_index); return
% % end
% % if ~isempty(gd_truth_label) && isempty(detect_index)
% %     score(2,1)=length(gd_truth_label); 
% %     score(2,2)=instance_num-length(gd_truth_label); return
% % end
% % for k=1:instance_num
% %     idx=(k-1)*winsize+1:k*winsize;
%     figure(1)
%     subplot(3,1,1);  plot(submeter);
%     subplot(3,1,2);  plot(idx,activation(idx),'r*');
%     subplot(3,1,3);  plot(idx,detection(idx),'g*');
%     pause()
% %     ind_gd=ismember(gd_truth_label,idx);
% %     if sum(ind_gd)>=1
% %         num_pos=num_pos+1;
% %         gd_idx=find(ind_gd,1,'first');
% %         diff_idx=find(gd_truth_label(gd_idx)-detect_index<=1000,1);
% %         if ~isempty(diff_idx)
% %             TP=TP+1;
% %         else
% %             FN=FN+1;
% %         end
% %     else
% %         num_neg=num_neg+1;
% %         ind_det=ismember(detect_index,idx);
% %         if sum(ind_det)>=1
% %             FP=FP+1;
% %         else
% %             TN=TN+1;
% %         end
% %     end
% % end
for k=1:instance_num
    idx=(k-1)*winsize+1:k*winsize;
    %%%%%%%%new approach%%%%%%%
    if sum(activation(idx))>=1
        gt_vec(k)=1;
    else
        gt_vec(k)=0;
    end
    if sum(detection(idx))>=1
        det_vec(k)=1;
    else
        det_vec(k)=0;
    end
end
new_vec=gt_vec+2*det_vec;
TP=sum(new_vec==3);
TN=sum(new_vec==0);
FN=sum(new_vec==1);
FP=sum(new_vec==2);
% % %%%%%checking the output%%%%%
% % if (TP+FN)~=num_pos
% %     sprintf('wrong TP and FN, please check~!')
% % end
% % if (FP+TN)~=num_neg
% %     sprintf('wrong FP and TN, please check~!')
% % end

%%%%%%output scores%%%%%%%%%

if TP~=0, score(1,1)=TP; else score(1,1)=0; end
if FP~=0, score(1,2)=FP; else score(1,2)=0; end
if FN~=0, score(2,1)=FN; else score(2,1)=0; end
if TN~=0, score(2,2)=TN; else score(2,2)=0; end

end