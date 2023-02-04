function [LW,TF,TYPE] = elmtrain(P,T,N,TF,TYPE,IW,B)

if nargin < 2 
    error('ELM:Arguments','Not enough input arguments.');
end

[R,Q] = size(P);

if nargin < 3  
    N = size(P,2);
end

if nargin < 4 
    TF = 'sig';
end

if nargin < 5 
    TYPE = 0;
end   
if nargin < 6 
    IW = rand(N,R) * 2 - 1;
end   
if nargin < 7 
    B = rand(N,1);
end   

if size(P,2) ~= size(T,2)  
    error('ELM:Arguments','The columns of P and T must be same.');
end

if TYPE  == 1
    T=ind2vec(T);
end

[S,Q] = size(T);

BiasMatrix = repmat(B,1,Q);

tempH = IW * P + BiasMatrix;
switch TF
    case 'sig'
        H = 1 ./ (1 + exp(-tempH));
    case 'sin'
        H = sin(tempH);
    case 'hardlim'
        H = hardlim(tempH);
end

LW = pinv(H') * T';