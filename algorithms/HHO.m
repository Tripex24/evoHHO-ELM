function [Rabbit_Energy,Rabbit_Location,Convergence_curve]=HHO(SearchAgents_no,Max_iter,lb,ub,dim,fobj)

Rabbit_Location=zeros(1,dim);
Rabbit_Energy=inf;

Positions= initialization(SearchAgents_no,dim,ub,lb);
Convergence_curve = zeros(Max_iter,1);

for t=1:Max_iter
    
    for i=1:size(Positions,1)
        FU=Positions(i,:)>ub;
        FL=Positions(i,:)<lb;
        Positions(i,:)=(Positions(i,:).*(~(FU+FL)))+ub.*FU+lb.*FL;
        fitness(i)=fobj(Positions(i,:));
        
        if fitness(i)<Rabbit_Energy
        Rabbit_Energy=fitness(i);
        Rabbit_Location=Positions(i,:);
        end
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
                Positions(i,:)=(Rabbit_Location)-Escaping_Energy*abs(Rabbit_Location-Positions(i,:));
            end
            if r>=0.5 && abs(Escaping_Energy)>=0.5
                Jump_strength=2*(1-rand());
                Positions(i,:)=(Rabbit_Location-Positions(i,:))-Escaping_Energy*abs(Jump_strength*Rabbit_Location-Positions(i,:));
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
