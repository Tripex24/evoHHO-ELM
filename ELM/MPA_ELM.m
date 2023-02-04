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

%% MPA-ELM
maxgen=120;
sizepop=20;

ub=5;
lb=-5;
Boundary_no=size(ub,2);

if(max(size(ub)) == 1)
    ub = ub.*ones(1,dim);
    lb = lb.*ones(1,dim);
end

Prey=initialization(sizepop,dim,ub,lb);

fitness=zeros(1,sizepop);

Iter=0;
Max_iter=maxgen;
SearchAgents_no=sizepop;

Top_predator_pos=zeros(1,dim);
Top_predator_fit=inf;

Convergence_curve=zeros(1,Max_iter);
stepsize=zeros(SearchAgents_no,dim);

%% search optimal
while Iter<Max_iter
    
    %------------------- Detecting top predator -----------------
    for i=1:size(Prey,1)
        Flag4ub=Prey(i,:)>ub;
        Flag4lb=Prey(i,:)<lb;
        Prey(i,:)=(Prey(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
    end
    fitness=Objfun(Prey,inputn,outputn,hiddennum,inputn_test,outputn_test);
    
    for i=1:size(Prey,1)
        if fitness(i)<Top_predator_fit
            Top_predator_fit=fitness(i);
            Top_predator_pos=Prey(i,:);
        end
    end
    %------------------- Marine Memory saving -------------------
    
    if Iter==0
        fit_old=fitness;    Prey_old=Prey;
    end
    
    Inx=(fit_old<fitness);    
    Indx=repmat(Inx,1,dim);
    Prey=Indx.*Prey_old+~Indx.*Prey;
    fitness=Inx.*fit_old+~Inx.*fitness;
    
    fit_old=fitness;    Prey_old=Prey;
    
    %------------------------------------------------------------
    
    Elite=repmat(Top_predator_pos,SearchAgents_no,1);  
    CF=(1-Iter/Max_iter)^(2*Iter/Max_iter);
    
    RL=0.05*levy(SearchAgents_no,dim,1.5);
    RB=randn(SearchAgents_no,dim);
    P=0.5;
    FADs=0.2;
    
    for i=1:size(Prey,1)
        for j=1:size(Prey,2)
            R=rand();
            %------------------ Phase 1-------------------
            if Iter<Max_iter/3
                stepsize(i,j)=RB(i,j)*(Elite(i,j)-RB(i,j)*Prey(i,j));
                Prey(i,j)=Prey(i,j)+P*R*stepsize(i,j);
                
                %--------------- Phase 2----------------
            elseif Iter>Max_iter/3 && Iter<2*Max_iter/3
                
                if i>size(Prey,1)/2
                    stepsize(i,j)=RB(i,j)*(RB(i,j)*Elite(i,j)-Prey(i,j));
                    Prey(i,j)=Elite(i,j)+P*CF*stepsize(i,j);
                else
                    stepsize(i,j)=RL(i,j)*(Elite(i,j)-RL(i,j)*Prey(i,j));
                    Prey(i,j)=Prey(i,j)+P*R*stepsize(i,j);
                end
                
                %----------------- Phase 3-------------------
            else
                
                stepsize(i,j)=RL(i,j)*(RL(i,j)*Elite(i,j)-Prey(i,j));
                Prey(i,j)=Elite(i,j)+P*CF*stepsize(i,j);
                
            end
        end
    end
    
    %---------- Eddy formation and FADs¡¯ effect-----------
    
    if rand()<FADs
        U=rand(SearchAgents_no,dim)<FADs;
        Prey=Prey+CF*((lb+rand(SearchAgents_no,dim).*(ub-lb)).*U);
        
    else
        r=rand();  Rs=size(Prey,1);
        stepsize=(FADs*(1-r)+r)*(Prey(randperm(Rs),:)-Prey(randperm(Rs),:));
        Prey=Prey+stepsize;
    end
    
    Iter=Iter+1;
    Convergence_curve(Iter)=Top_predator_fit;
    
end
%% optimal location
x=Top_predator_pos;

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
legend('Actual','MPA-ELM');
set(gca,'FontSize',12,'FontName','Times New Roman');
hold off

figure(3)
plot(output_test,'g')
hold on
plot(Y12,'r')
xlabel('Time');ylabel('Power');
legend('Actual','MPA-ELM');
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
