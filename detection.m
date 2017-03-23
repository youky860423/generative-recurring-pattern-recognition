function [ E3 ] = detection( x,y,eps)
%DETECTION Using generated activation signatures to detect similar patterns
%in voltage envelope waveform.
%   input: activation templates x vector, object voltage envelope waveform
%          y vector under test; eps: allows deviations of templates;
%          threshold is the parameter setting for detecting scheme;
%   output: detected indexes ;
% 
%   our goal is to minimize a^2 *cxx-2*a*cxy+cyy with respect to a and
%   constrained on a is in the range of (1-eps,1+eps)
dx=x-mean(x);
o=ones(length(x),1)/length(x);
tmp=conv(y,o);
% dy=y-tmp(length(x)/2:end-length(x)/2);
cxx=var(x);% variance of x
% cyy=conv(dy.^2,o);% variance of y
cyy=conv(y.^2,o)-tmp.^2;
cyy=cyy(length(x):end-length(x)+1);
cxy=1/length(x)*conv(y,flipud(dx));%covariance between x and y
cxy=cxy(length(x):end-length(x)+1);
% % E1=length(x)*(cxx-2*cxy+cyy);% error function when a is exact 1;
% % figure(1)
% % plot(E1)
% % rou=cxy./(sqrt(cxx)*sqrt(cyy));
% % E2=length(airon_S)*1/cxx*cyy.*(ones(length(rou),1)-rou).^2; % error
% %                               function without any constraint of a;
% % figure(2)
% % plot(E2)
ratio=cxy/cxx;lftbnd=1-eps;rgtbnd=1+eps;
idx1=find(ratio<lftbnd);
idx2=find(ratio>rgtbnd);
idx3=find(ratio>=lftbnd & ratio<=rgtbnd);
E3=zeros(length(ratio),1);
E3(idx1,1)=lftbnd^2*cxx-2*lftbnd*cxy(idx1,1)+cyy(idx1,1);
E3(idx2,1)=rgtbnd^2*cxx-2*rgtbnd*cxy(idx2,1)+cyy(idx2,1);
E3(idx3,1)=-ratio(idx3,1).^2*cxx+cyy(idx3,1);
% % figure(3)
% % plot(E3)


