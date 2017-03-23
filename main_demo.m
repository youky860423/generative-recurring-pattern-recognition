clear;
close all
%%%%%%%loading data%%%%%%%
load('signalexp.mat')
m=700;
display=1;
if display
    figure(1)
    plot(y)
    title('original collection of signals')
end
[smean,sigmed,tau_opt_vec,f_aml,f_lower,f_upper]=greedymin_revised(y,m,display);
pause()
%%%%%%%testing template of a detection performance%%%%%%%%
load('header');
addpath('tvdip/');
%%%%%%%initializing%%%%%%%%%%%
home='ps-025';
pathname=['testdata/',home,'/testing/'];
folders=dir([pathname,'2012*']);
threshold_vec=[0:2e-5:1e-3,0.0015,2e-3:1e-3:1e-2,0.015,2e-2:1e-2:0.1,0.15,0.2:0.1:1]; 
device_needtv=[12,13,14,18];
testapp=8;
if ismember(testapp,device_needtv)
    high_bool=1;
else
    high_bool=0;
end
%%%%%%%detecting activation pattern%%%%%%
testapp_template=smean(1:end-1);
score = det_result(testapp_template,pathname,folders,home,header,threshold_vec,testapp,high_bool,display);
%%%%%%%%%%calculating ROC%%%%%%
for m=1:size(score,1)
    Score=zeros(2,2);
    for n=1:size(score,2)
        Score=Score+score{m,n};
    end
    %%%%%%%calculating ROC%%%%
    if Score(1,1)==0 && Score(2,1)==0
        TPR(m,1)=0;
    else
        TPR(m,1)=Score(1,1)/(Score(1,1)+Score(2,1));
    end
    if Score(1,2)==0 && Score(2,2)==0
        FPR(m,1)=0;
    else
        FPR(m,1)=Score(1,2)/(Score(1,2)+Score(2,2));
    end
end
AUC = myAUC( TPR, FPR );
figure(4)
plot(FPR,TPR,'-')
title(['roc curve for air-conditioning','on','AUC= ',num2str(AUC)])
xlabel('false positive rate')
ylabel('true positive rate')
