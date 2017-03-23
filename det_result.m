function score = det_result(x,pathname,folders,home,header,threshold_vec,test,high_bool,display)
%DET_RESULT This gives detection result score ceils
%   input---folders:choosing detection test from that folder, threshold_vec:giving all the
%            posible threshold value.
%   output---score for each threshold and each file

   %%%%%choosing files containing activations%%%%
%%%%initializing%%%%
pw_threshold=60;%%%%determing activations
winsize=120*10;%%%%detecting window
eps=0.1;%%%%for adjusting template value to error function in detection part
 cnt=0; 
 cnt_act=0;
    for i=1:length(folders)
         fdname=folders(i).name;
         folder=dir([pathname,'/',fdname,'/',upper(home),'-2012*.mat']); 
         for j=1:length(folder)%%length(folder)
            fname=folder(j).name;
            load([pathname,'/',fdname,'/',fname]);
            if test==14
                if ismember(str2double(fname(16:17)),(17:20))
                    submeter=[];
                else
                    submeter=data(:,test);
                end
            end
            
            if  test>14 && ismember(str2double(fname(16:17)),(17:20))%%20121117-20 has only 17 columns
                submeter=data(:,test-1);
            else
               submeter=data(:,test);           
            end
            idx=find(submeter>pw_threshold,1);
            if ~isempty(idx)
                if display
                    figure(3)
                    subplot(3,1,1)
                    plot(submeter)
                    title([header{test}{1},' power readings for ',fname])
                end
                activation=zeros(length(submeter),1);
                [ actindex, deactindex ] = gdtruth( submeter, pw_threshold,high_bool);
                if ~isempty(actindex)
                    cnt=cnt+1;%%%%%counting files containing activations
                    cnt_act=cnt_act+length(actindex);%%%count total activations%%%%  
                    activation(actindex)=1;
                    if display
                        figure(3)
                        subplot(3,1,2)
                        plot(activation)
                        title([header{test}{1},' groundtruth signal for ',fname])
                    end
                    %%%%%%%%%%despiking the signatures first%%%%%%%%%%
                    y=data(:,4);
                    y_new=medfilt1(y,5);
                    filtidx=find(y_new>1.1*median(y_new) | y_new<0.9*median(y_new));
                    y_new(filtidx)=median(y_new);
                    Error_sig= detection( x,y_new,eps);
                    for a=1:length(threshold_vec)
                         threshold=threshold_vec(a);
                         detidx = thresholding( Error_sig,threshold);
                         switch home
                             case 'ps-025'
                             %%%%for ps-025 delays between voltage meter and power meter
                             bound_idx=(detidx+1000<length(data));
                             detidx(bound_idx)=detidx(bound_idx)+1000;
                             case 'ps-051'
                             %%%%for ps-051 delays between voltage meter and power meter
                                 if test==8
                                     bound_idx=(detidx+500<length(data));
                                     detidx(bound_idx)=detidx(bound_idx)+500;
                                  else
                                     bound_idx=(detidx+800<length(data));
                                     detidx(bound_idx)=detidx(bound_idx)+800;
                                 end
                             case 'ps-029'
                             %%%for ps-029 delays:
                                 switch test   
                                     case 8 || 11 || 13 
                                          bound_idx=(detidx+1000<length(data));
                                          detidx(bound_idx)=detidx(bound_idx)+1000;
                                     case 12
                                          bound_idx=(detidx+700<length(data));
                                          detidx(bound_idx)=detidx(bound_idx)+700;
                                     otherwise
                                          bound_idx=(detidx+500<length(data));
                                          detidx(bound_idx)=detidx(bound_idx)+500;
                                 end
                             case 'ps-046'
                             %%%%for ps-046 delays between voltage meter and power meter
                                 switch  test
                                     case  8 || 12
                                         bound_idx=(detidx+1100<length(data));
                                         detidx(bound_idx)=detidx(bound_idx)+1100;
                                     case 14 || 16
                                         bound_idx=(detidx+1000<length(data));
                                         detidx(bound_idx)=detidx(bound_idx)+1000;
                                     otherwise
                                         bound_idx=(detidx+800<length(data));
                                         detidx(bound_idx)=detidx(bound_idx)+800;
                                 end
                             otherwise
                                 disp('wrong home')
                         end
%                          length(detidx)
% %                          detidx=detidx-length(x); %%%correction for Error_sig;
                         if display
                             figure(3)
                             subplot(3,1,3)
                             plot(1:length(y),y,1:length(y_new),y_new,'g')
                             hold on
                             plot(detidx,y_new(detidx),'r.')
                             title([header{test}{1},' activation detection signal for ',fname])
                             hold off
                             pause(0.1)
                         end
                         score{a,cnt}=myROC(actindex,detidx,submeter,winsize);
                     end
                else
                     continue    
                end   
            end
            if cnt_act>30
                return;
            end
% %             pause()
         end
    end
    
    
    
end

