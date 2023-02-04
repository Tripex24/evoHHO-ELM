function Positions=initialization_g(SearchAgents_no,dim,ub,lb)

%tent map
alpha=0.499;
beta=zeros(1,SearchAgents_no.*dim);
beta(1)=rand();

for i=2:SearchAgents_no*dim
    if beta(i-1)<alpha
        beta(i)=beta(i-1)./alpha;
    else
        beta(i)=(1-beta(i-1))./(1-alpha);
    end
end
beta=reshape(beta,SearchAgents_no,dim);
Boundary_no= size(ub,2);

if Boundary_no==1
    Positions=beta.*(rand(SearchAgents_no,dim).*(ub-lb)+lb);
end