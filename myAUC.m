function [ AUC ] = myAUC( TPR, FPR )
%MYAUC  This function calculate area under curve
%   input---TPR:true positive rate vector as y axis point,FPR:false positive
%          rate vector as x axis point.
%   output---:AUC: measures the performance of the detector.

for i=1:length(TPR)-1
    area(i,:)=(FPR(i+1)-FPR(i))*(TPR(i+1,:)+TPR(i,:))/2;
end
AUC=sum(area);
    

end

