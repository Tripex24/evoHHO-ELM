function Obj=Objfun(X,P,T,hiddennum,P_test,T_test)
%% 

[M,N]=size(X);
Obj=zeros(M,1);
P_train = P ;
T_train = T ;
for i=1:M
    Obj(i)=ELMfun(X(i,:),P_train,T_train,hiddennum,P_test,T_test);
end