function err=ELMfun(x,P_train,T_train,hiddennum,P_test,T_test)
%%
inputnum=size(P_train,1);
outputnum=size(T_train,1);

[P_train,inFP] = mapminmax(P_train,0,1);
T_train = mapminmax(T_train,0,1);

[P_test,outFP] = mapminmax(P_test,0,1);
T_test = mapminmax(T_test,0,1);

%%
w1num=inputnum*hiddennum;
w1=x(1:w1num);
w1 = reshape(w1,hiddennum,inputnum);
B1=x(w1num+1:w1num+hiddennum);
B1=reshape(B1,hiddennum,1);

%% train ELM
[LW,TF,TYPE] = elmtrain(P_train,T_train,hiddennum,'sig',0,w1,B1);

Tsim = elmpredict(P_test,w1,B1,LW,TF,TYPE);  

T_sim = mapminmax('reverse',Tsim,outFP);

err=norm(T_sim-T_test);
