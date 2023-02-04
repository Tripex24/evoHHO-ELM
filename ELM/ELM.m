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

%% data_processing_period_2
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

IW1=rand(hiddennum,inputnum)* 2 - 1;
IB1=rand(hiddennum,1);

%% build ELM
[LW,TF,TYPE] = elmtrain(inputn,outputn,hiddennum,'sig',0,IW1,IB1);

%% Test ELM
T_train_sim1 = elmpredict(inputn,IW1,IB1,LW,TF,TYPE);
T_test_sim1 = elmpredict(inputn_test,IW1,IB1,LW,TF,TYPE);

Y11= mapminmax('reverse',T_train_sim1,outputps);
Y12 = mapminmax('reverse',T_test_sim1,outputps);

err11=norm(Y11-output_train);
err12=norm(Y12-outputn_test);

disp(['Train error is:',num2str(err11)])
disp(['Test error is:',num2str(err12)])

%% plot
figure(1)
plot(output_train,'g')
hold on
plot(Y11,'r')
xlabel('Time');ylabel('Power');
legend('Actual','ELM');
set(gca,'FontSize',12,'FontName','Times New Roman');
hold off

figure(2)
plot(output_test,'g')
hold on
plot(Y12,'r')
xlabel('Time');ylabel('Power');
legend('Actual','ELM');
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


