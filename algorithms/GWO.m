function [Best_Score,Best_Pos,Convergence_curve]=GWO(SearchAgents_no,Max_iter,lb,ub,dim,fobj)

Alpha_Pos=zeros(1,dim);
Alpha_Score=inf;
Beta_Pos=zeros(1,dim);
Beta_Score=inf;
Delta_Pos=zeros(1,dim);
Delta_Score=inf;

Positions=initialization(SearchAgents_no,dim,ub,lb);

fitness=zeros(1,SearchAgents_no);

for i=1:SearchAgents_no
    fitness(i)=fobj(Positions(i,:));
end

[SortFitness,IndexSort]=sort(fitness);
Alpha_Pos=Positions(IndexSort(1),:);
Alpha_Score=SortFitness(1);
Beta_Pos=Positions(IndexSort(2),:);
Beta_Score=SortFitness(2);
Delta_Pos=Positions(IndexSort(3),:);
Delta_Score=SortFitness(3);

Group_Best_Pos=Alpha_Pos;
Group_Best_Score=Alpha_Score;

for t=1:Max_iter
    a=2-t*((2)/Max_iter);
    for i=1:SearchAgents_no
        for j=1:dim
            r1=rand;
            r2=rand;
            A1=2*a*r1-a;
            C1=2*r2;
            D_Alpha=abs(C1*Alpha_Pos(j)-Positions(i,j));
            X1=Alpha_Pos(j)-A1*D_Alpha;
            
            r1=rand;
            r2=rand;
            A2=2*a*r1-a;
            C2=2*r2;
            D_Beta=abs(C2*Beta_Pos(j)-Positions(i,j));
            X2=Beta_Pos(j)-A2*D_Beta;
            
            r1=rand;
            r2=rand;
            A3=2*a*r1-a;
            C3=2*r2;
            D_Delta=abs(C3*Delta_Pos(j)-Positions(i,j));
            X3=Delta_Pos(j)-A3*D_Delta;
            
            Positions(i,j)=(X1+X2+X3)/3;
        end
    end
    
    for k=1:size(Positions,1)
        
        Flag4ub=Positions(k,:)>ub;
        Flag4lb=Positions(k,:)<lb;
        Positions(k,:)=(Positions(k,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
        
    end
    
    for r=1:SearchAgents_no
        fitness(r)=fobj(Positions(r,:));
        if fitness(r)<Alpha_Score
            Alpha_Score=fitness(r);
            Alpha_Pos=Positions(r,:);
        end
        if fitness(r)>Alpha_Score&&fitness(r)<Beta_Score
            Beta_Score=fitness(r);
            Beta_Pos=Positions(r,:);
        end
        if fitness(r)>Alpha_Score&&fitness(r)>Beta_Score&&fitness(r)<Delta_Score
            Delta_Score=fitness(r);
            Delta_Pos=Positions(r,:);
        end
    end
    
    Group_Best_Pos=Alpha_Pos;
    Group_Best_Score=Alpha_Score;
    Convergence_curve(t)=Group_Best_Score;
    
end

Best_Pos=Group_Best_Pos;
Best_Score=Group_Best_Score;

end