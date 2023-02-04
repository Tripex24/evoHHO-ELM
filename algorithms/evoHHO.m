function [Rabbit_Energy,Rabbit_Location,Convergence_curve]=evoHHO(SearchAgents_no,Max_iter,lb,ub,dim,fobj)

Rabbit_Location=zeros(1,dim);
Rabbit_Energy=inf;

Positions= initialization_g(SearchAgents_no,dim,ub,lb);
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
    
    if mod(t,200)==0
        range=ub-lb;
        
        Flag4lb_1=((Rabbit_Location-lb)>=1/4.*range);
        lb=(Rabbit_Location-1/4.*range).*Flag4lb_1+lb.*~Flag4lb_1;
        
        Flag4ub_2=((ub-Rabbit_Location)>=1/4.*range);
        ub=(Rabbit_Location+1/4.*range).*Flag4ub_2+ub.*~Flag4ub_2;
        
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
                gama=(5^0.5-1)/2;
                x1=-pi+(1-gama)*2*pi;
                x2=-pi+gama*2*pi;
                R1=2*pi*rand();
                R2=pi*rand();
                Positions(i,:)=(Rabbit_Location)-Escaping_Energy*abs(Rabbit_Location-Positions(i,:));
                Positions(i,:)=Positions(i,:)*abs(sin(R1))+R2*sin(R1).*abs(x1.*Rabbit_Location-x2.*Positions(i,:));
            end

            if r>=0.5 && abs(Escaping_Energy)>=0.5
                gama=(5^0.5-1)/2;
                x1=-pi+(1-gama)*2*pi;
                x2=-pi+gama*2*pi;
                R1=2*pi*rand();
                R2=pi*rand();
                Positions(i,:)=(Rabbit_Location)-Escaping_Energy*abs(Rabbit_Location-Positions(i,:));
                Positions(i,:)=Positions(i,:)*abs(sin(R1))+R2*sin(R1).*abs(x1.*Rabbit_Location-x2.*Positions(i,:));
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
