function [Leader_score,Leader_pos,Convergence_curve]=WOA(SearchAgents_no,Max_iter,lb,ub,dim,fobj)

Leader_pos=zeros(1,dim);
Leader_score=inf;

Positions=initialization(SearchAgents_no,dim,ub,lb);

Convergence_curve=zeros(1,Max_iter);

t=1;

while t<=Max_iter
    for i=1:size(Positions,1)

        Flag4ub=Positions(i,:)>ub;
        Flag4lb=Positions(i,:)<lb;
        Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;

        fitness=fobj(Positions(i,:));

        if fitness<Leader_score
            Leader_score=fitness;
            Leader_pos=Positions(i,:);
        end
        
    end
    
    a=2-t*((2)/Max_iter);
    
    a2=-1+t*((-1)/Max_iter);

    for i=1:size(Positions,1)
        r1=rand();
        r2=rand();
        
        A=2*a*r1-a;
        C=2*r2;
        
        
        b=1;
        l=(a2-1)*rand+1;
        
        p = rand();
        
        for j=1:size(Positions,2)
            
            if p<0.5   
                if abs(A)>=1
                    rand_leader_index = floor(SearchAgents_no*rand()+1);
                    X_rand = Positions(rand_leader_index, :);
                    D_X_rand=abs(C*X_rand(j)-Positions(i,j));
                    Positions(i,j)=X_rand(j)-A*D_X_rand;
                    
                elseif abs(A)<1
                    D_Leader=abs(C*Leader_pos(j)-Positions(i,j));
                    Positions(i,j)=Leader_pos(j)-A*D_Leader;
                end
                
            elseif p>=0.5
                distance2Leader=abs(Leader_pos(j)-Positions(i,j));
                Positions(i,j)=distance2Leader*exp(b.*l).*cos(l.*2*pi)+Leader_pos(j); 
            end
        end
    end
    Convergence_curve(t)=Leader_score;
    t=t+1;
end



