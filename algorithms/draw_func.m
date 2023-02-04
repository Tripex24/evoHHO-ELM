clear all
clc
format long
F_name=["F1","F2","F3","F4","F8","F10"];
figure('Position',[150 150 700 700])
for i=1:6
    subplot(3,2,i);
    Function_name=F_name(i);
    func_plot(Function_name);
    title('Function Topology')
    xlabel('x_1');
    ylabel('x_2');
    zlabel([Function_name,'( x_1 , x_2 )'])
end