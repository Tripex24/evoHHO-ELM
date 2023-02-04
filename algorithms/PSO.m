function [Best_fitness,Best_Pos,IterCurve]=PSO(pop,dim,ub,lb,fobj,vmax,vmin,maxIter)

c1=1.5;
c2=1.5;
w=0.5;

V=initialization(pop,dim,vmax,vmin);
X=initialization(pop,dim,ub,lb);
fitness=zeros(1,pop);

for i=1:pop
    fitness(i)=fobj(X(i,:));
end

pBest=X;
pBestFitness=fitness;
[~,index]=min(fitness);
gBestFitness=fitness(index);
gBest=X(index,:);

Xnew=X;
fitnessNew=fitness;

for t=1:maxIter
    for i=1:pop
        r1=rand(1,dim);
        r2=rand(1,dim);
        V(i,:)=w.*V(i,:)+c1.*r1.*(pBest(i,:)-X(i,:))+c2.*r2.*(gBest-X(i,:));
        for j=1:dim
            if V(i,j)>ub
                V(i,j)=ub;
            end
            if V(i,j)<lb
                V(i,j)=lb;
            end
        end
        Xnew(i,:)=X(i,:)+V(i,:);
        fitnessNew(i)=fobj(Xnew(i,:));
        
        if fitnessNew(i)<pBestFitness(i)
            pBest(i,:)=Xnew(i,:);
            pBestFitness(i)=fitnessNew(i);
        end
        if fitnessNew(i)<gBestFitness
            gBestFitness=fitnessNew(i);
            gBest=Xnew(i,:);
        end
    end
    
    X=Xnew;
    fitness=fitnessNew;
    
    Best_Pos=gBest;
    Best_fitness=gBestFitness;
    IterCurve(t)=Best_fitness;
end