clear all
clc
format long
SearchAgents_no=25; % Number of search agents

Function_name='F1';

Max_iteration=1000; % Maximum number of iterations

[lb,ub,dim,fobj]=Get_Functions_details(Function_name);

vmax=0.2*ub;
vmin=-0.2*ub;

[Leader_score,Leader_pos,Convergence_curve]=PSO(SearchAgents_no,dim,ub,lb,fobj,vmax,vmin,Max_iteration);

% function topology
figure('Position',[200 200 900 400])
subplot(1,2,1);
func_plot(Function_name);
title('Function Topology')
xlabel('x_1');
ylabel('x_2');
zlabel([Function_name,'( x_1 , x_2 )'])

% Convergence curve
subplot(1,2,2);
semilogy(Convergence_curve,'Color','r')
title('Objective space')
xlabel('Iteration');
ylabel('Best score obtained so far');


display(['Optimal position obtained by PSO is : ', num2str(Leader_pos,10)]);
display(['Optimal value botained by PSO is : ', num2str(Leader_score,10)]);