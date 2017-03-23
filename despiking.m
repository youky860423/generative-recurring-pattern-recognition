close all
figure(1)
y=data(:,4);
y_mf=medfilt1(y,5);
plot(y)
hold on
plot(y_mf,'r')
hold off
median(y_mf)
idx=find(y_mf>2*median(y_mf) | y_mf<0.9*median(y_mf));
y_mf(idx)=median(y_mf);
figure(2)
y=data(:,4);
plot(y)
hold on
plot(y_mf,'r')
hold off