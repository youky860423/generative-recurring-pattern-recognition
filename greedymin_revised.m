function   [smean,sigmed,aligned_y,tau_opt_vec,f_aml,f_lower,f_upper]=greedymin_revised(y,m,display)
%This function is generating template from a collection of signals and the
%corresponding delay indexes.
% Input: collection of signals by dxN and the window size m, where d is the dimension of the
%        signal, and the N is the total number of signals.
% Output: aligned_y is the aligned subwindowed signal; 
%         smean is the recognized template by the mean of the aligned_y; 
%         sigmed is the median of the aligned signal;
%         tau_opt_vec is the optimal delay index by the template;
%         f_aml is optimal objective value by our method;
%         f_lower is the lower bound and f_upper is the upper bound;

%%% data generation (construct Yi's)%%%%%%%%%
[d, N]=size(y);
if N>100
    N=100;
end
%%%%%setting limit of the data example%%%%%%
Y=[];
no_delays=d-m+1;
phi=zeros(N,no_delays);
for i=1:N
    ytmp=y(:,i)-mean(y(:,i));
    a=(1:d);
    Ytmp=zeros(m+1,d-m+1);
    for j=1:no_delays
        Ytmp(1:m,j)=ytmp(j:m+j-1)-mean(ytmp(j:m+j-1));
        idx=~ismember(a,(j:m+j-1));
        Ytmp(m+1,j)=sqrt(d-m)*mean(ytmp(idx));
        phi(i,j)=(ytmp(idx)-mean(ytmp(idx)))'*(ytmp(idx)-mean(ytmp(idx)));
    end
    Y{i}=Ytmp;
end
 
%%%%%%%%%main function%%%%%%%%%%%%%
if N==1
    [~,tau_opt_vec]=max(phi);
    smean=Y{N}(:,tau_opt_vec);
    sigmed=Y{N}(:,tau_opt_vec);
    aligned_y=Y{N}(:,tau_opt_vec)';
    f_aml=0;
    f_lower=0;
    f_upper=0;
else
    %%% init
    idx_vec1=zeros(N,1);
    val_vec1=zeros(N,1);

    for i=1:N
        %Dij_tot=zeros(no_delays,no_delays);
        v=zeros(no_delays,1);
        tmpidx=1:N;
        tmpidx(i)=[];
        for j=tmpidx
            Dij=sum(Y{i}.^2)'*ones(1,no_delays) - 2*Y{i}'*Y{j} + ones(no_delays,1)*sum(Y{j}.^2) + ...
                ones(no_delays,1)*phi(j,:);
            v=v+min(Dij,[],2);%%% minimizing \sum_{j \neq i} D(Yi xi, Yj xj)^2
            [ftaui(i,j,:),idxtaui(i,j,:)]=min(Dij,[],2);
        end
        [val_vec1(i),idx_vec1(i)]=min(v+phi(i,:)'); %%% min_k min x_i \sum_{j in{1:N}\{k}} min x_j x_i' Dij x_j

    end
    [val,idx]=min(val_vec1);
    %%%%%obtaining the optimal bag%%%%%
    k_opt=idx;
    xi_opt=idx_vec1(idx);
    tau_opt_vec=idxtaui(k_opt,:,xi_opt);
    tau_opt_vec(k_opt)=xi_opt;
    tmp1=0;tmp2=0;
    for i=1:N
        taui_opt=idxtaui(i,:,idx_vec1(i));
        taui_opt(i)=idx_vec1(i);
        tmp3=0;
        for j=1:N
            tmp1=tmp1+norm(Y{i}(:,tau_opt_vec(i))-Y{j}(:,tau_opt_vec(j)))^2;
            tmp3=tmp3+norm(Y{i}(:,taui_opt(i))-Y{j}(:,taui_opt(j)))^2+phi(j,taui_opt(j));
    %         for k=1:no_delays
    %             tmp4(i)=norm(Y{i}(:,tau_opt_vec(i))-Y{j}(:,k))^2;
    %         end
        end
        fi(i)=tmp3;
        tmp2=tmp2+phi(i,tau_opt_vec(i));
    end

    %%%%%for generating activation signature
    aligned_vec=[];smean=zeros(m+1,1);
    aligned_y=zeros(m+1,N);
    for i=1:N
        smean=smean+1/N*Y{i}(:,tau_opt_vec(i));
        aligned_y(:,i)=Y{i}(:,tau_opt_vec(i));
        if display
            figure(2)
            plot(aligned_y(1:m,i))
            hold on
        end
        aligned_vec=[aligned_vec,aligned_y(:,i)];
    %     gg2=[gg2,Y{k_vec(i)}(:,xi_vec(i))*std_vec(k_vec(i),xi_vec(i))]; %%% back to original signatures
    end
    sigmed=median(aligned_vec,2);
    if display
        plot(smean(1:m),'ro-')
        plot(sigmed(1:m),'gd')
        hold off
        title('template and the aligned signals')
    end

    %%%checking for the bounds%%%%
    f_aml(1)=tmp1/(2*N)+tmp2;
    % val_vec1
    f_lower(1)=1/2*mean(val_vec1);
    % fi
    f_lower2(1)=1/2*mean(fi);
    f_upper(1)=val;

end

end
