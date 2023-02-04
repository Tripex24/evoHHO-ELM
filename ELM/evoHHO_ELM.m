clc
clear all
close all

%% data processing_period_1
x=xlsread('ENB2012_data');
[ndata, D] = size(x);      
R = randperm(ndata);
input_test = x(R(1:150),1:8)';
output_test= x(R(1:150),9)';
R(1:150) = [];
input_train = x(R,1:8)';
output_train=x(R,9)';

%% data processing_period_2
[inputn,inputps]=mapminmax(input_train,0,1);
[outputn,outputps]=mapminmax(output_train,0,1);

inputn_test=mapminmax('apply',input_test,inputps,0,1);
outputn_test=mapminmax('apply',output_test,outputps,0,1);

hiddennum=30;

threshold= minmax(inputn) ;

inputnum=size(inputn,1);
outputnum=size(outputn,1);

w1num=inputnum*hiddennum;
w2num=outputnum*hiddennum;
dim=w1num+hiddennum;

%% evoHHO-ELM
maxgen=120;
sizepop=20;

ub=5;
lb=-5;

if(max(size(ub)) == 1)
    ub = ub.*ones(1,dim);
    lb = lb.*ones(1,dim);
end

Positions=initialization_g(sizepop,dim,ub,lb);

fitness=zeros(1,sizepop);

Max_iter=maxgen;
SearchAgents_no=sizepop;

Rabbit_Location=zeros(1,dim);
Rabbit_Energy=inf;

Convergence_curve=zeros(1,Max_iter);

%% search optimal
for t=1:Max_iter
    
    for i=1:size(Positions,1)
        FU=Positions(i,:)>ub;
        FL=Positions(i,:)<lb;
        Positions(i,:)=(Positions(i,:).*(~(FU+FL)))+ub.*FU+lb.*FL;
    end
    fitness=Objfun(Positions,inputn,outputn,hiddennum,inputn_test,outputn_test);
    
    for i=1:size(Positions,1)
        if fitness(i)<Rabbit_Energy
            Rabbit_Energy=fitness(i);
            Rabbit_Location=Positions(i,:);
        end
    end
    if mod(t,40)==0
        range=ub-lb;
        
        Flag4lb_1=((Rabbit_Location-lb)>=1/4.*range);
        lb=(Rabbit_Location-1/4.*range).*Flag4lb_1+lb.*~Flag4lb_1;
        
        Flag4ub_2=((ub-Rabbit_Location)>=1/4.*range);
        ub=(Rabbit_Location+1/4.*range).*Flag4ub_2+ub.*~Flag4ub_2;
        
    end
    
    E1=2*(1-(t/Max_iter));
    
    for i=1:size(Positions,1)
        E0=2*rand()-1;
        Escaping_Energy=E1*(E0);
        if abs(Escaping_Energy)>=1
            q=rand();
            rand_Hawk_index = floor(SearchAgents_no*rand()+1);
            X_rand = Positions(rand_Hawk_index, :);
            if q<0.5
                Positions(i,:)=X_rand-rand()*abs(X_rand-2*rand()*Positions(i,:));
            elseif q>=0.5
                Positions(i,:)=(Rabbit_Location(1,:)-mean(Positions))-rand()*((ub-lb)*rand+lb);
            end
        elseif abs(Escaping_Energy)<1
            % phase 1
            r=rand();
            if r>=0.5 && abs(Escaping_Energy)<0.5
                gama=(5^0.5-1)/2;
                x1=-pi+(1-gama)*2*pi;
                x2=-pi+gama*2*pi;
                R1=2*pi*rand();
                R2=pi*rand();
                Positions(i,:)=(Rabbit_Location)-Escaping_Energy*abs(Rabbit_Location-Positions(i,:));
                Positions(i,:)=Positions(i,:)*abs(sin(R1))+R2*sin(R1).*abs(x1.*Rabbit_Location-x2.*Positions(i,:));
            end
            if r>=0.5 && abs(Escaping_Energy)>=0.5
                gama=(5^0.5-1)/2;
                x1=-pi+(1-gama)*2*pi;
                x2=-pi+gama*2*pi;
                R1=2*pi*rand();
                R2=pi*rand();
                Jump_strength=2*(1-rand());
                Positions(i,:)=(Rabbit_Location-Positions(i,:))-Escaping_Energy*abs(Jump_strength*Rabbit_Location-Positions(i,:));
                Positions(i,:)=Positions(i,:)*abs(sin(R1))+R2*sin(R1).*abs(x1.*Rabbit_Location-x2.*Positions(i,:));
            end
            % phase 2
            if r<0.5 && abs(Escaping_Energy)>=0.5
                Jump_strength=2*(1-rand());
                X1=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-Positions(i,:));
                if sum(X1.^2)<sum(Positions(i,:).^2)
                    Positions(i,:)=X1;
                else
                    beta=1.5;
                    sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
                    u=randn(1,dim)*sigma;
                    v=randn(1,dim);
                    step=u./abs(v).^(1/beta);
                    o1=0.01*step;
                    X2=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-Positions(i,:))+rand(1,dim).*o1;
                    if (sum(X2.^2)<sum(Positions(i,:).^2))
                        Positions(i,:)=X2;
                    end
                end
            end
            if r<0.5 && abs(Escaping_Energy)<0.5
                Jump_strength=2*(1-rand());
                X1=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(Positions));
                if sum(X1.^2)<sum(Positions(i,:).^2)
                    Positions(i,:)=X1;
                else
                    beta=1.5;
                    sigma=(gamma(1+beta)*sin(pi*beta/2)/(gamma((1+beta)/2)*beta*2^((beta-1)/2)))^(1/beta);
                    u=randn(1,dim)*sigma;
                    v=randn(1,dim);
                    step=u./abs(v).^(1/beta);
                    o2=0.01*step;
                    X2=Rabbit_Location-Escaping_Energy*abs(Jump_strength*Rabbit_Location-mean(Positions))+rand(1,dim).*o2;
                    if (sum(X2.^2)<sum(Positions(i,:).^2))
                        Positions(i,:)=X2;
                    end
                end
            end
        end
    end
    Convergence_curve(t)=Rabbit_Energy;
end

%% optmal location
x=Rabbit_Location;

%% analysis
% Convergence curve
figure(1)
semilogy(Convergence_curve,'Color','r')
title('Objective space')
xlabel('Iteration');
ylabel('Best score obtained so far');

%%
w1num=inputnum*hiddennum;
w1=x(1:w1num);  
B1=x(w1num+1:w1num+hiddennum);
IW1=reshape(w1,hiddennum,inputnum);
IB1=reshape(B1,hiddennum,1);

%% build ELM
[LW,TF,TYPE] = elmtrain(inputn,outputn,hiddennum,'sig',0,IW1,IB1);
%% test ELM
T_train_sim1 = elmpredict(inputn,IW1,IB1,LW,TF,TYPE);
T_test_sim1 = elmpredict(inputn_test,IW1,IB1,LW,TF,TYPE);

Y11= mapminmax('reverse',T_train_sim1,outputps);
Y12 = mapminmax('reverse',T_test_sim1,outputps);

err11=norm(Y11-output_train);
err12=norm(Y12-outputn_test);

disp(['train error is:',num2str(err11)])
disp(['test error is:',num2str(err12)])

%% plot
figure(2)
plot(output_train,'g')
hold on
plot(Y11,'r')
xlabel('Time');ylabel('Power');
legend('Actual','evoHHO-ELM');
set(gca,'FontSize',12,'FontName','Times New Roman');
hold off

figure(3)
plot(output_test,'g')
hold on
plot(Y12,'r')
xlabel('Time');ylabel('Power');
legend('Actual','evoHHO-ELM');
set(gca,'FontSize',12,'FontName','Times New Roman');
hold off

%% assessment criteria
Result1=CalcPerf(output_train,Y11);
Rvalue1=Result1.Rvalue;
MSE1=Result1.MSE;
RMSE1=Result1.RMSE;
MAPE1=Result1.Mape;
disp(['Train-ELM-Rvalue = ', num2str(Rvalue1)])
disp(['ELM-RMSE = ', num2str(RMSE1)])
disp(['ELM-MSE  = ', num2str(MSE1)])
disp(['ELM-MAPE = ', num2str(MAPE1)])

Result2=CalcPerf(output_test,Y12);
Rvalue2=Result2.Rvalue;
MSE2=Result2.MSE;
RMSE2=Result2.RMSE;
MAPE2=Result2.Mape;
disp(['Test-ELM-Rvalue = ', num2str(Rvalue2)])
disp(['ELM-RMSE = ', num2str(RMSE2)])
disp(['ELM-MSE  = ', num2str(MSE2)])
disp(['ELM-MAPE = ', num2str(MAPE2)])
