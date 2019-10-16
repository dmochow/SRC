function [Rxy,Rxx,Ryy,Ryx] = nanRXY(X,Y)
% [Rxy,Rxx,Ryy,Ryx] = nanRXY(X,Y) computes covariance matrixes taking NaN into account. 
X = X.'; Y = Y.'; % this just because the rest of the doce assumes it this way. 
Rxx=nancov(X,'pairwise');
Ryy=nancov(Y,'pairwise');
for i=1:size(X,2), for j=1:size(Y,2), c=nancov(X(:,i),Y(:,i)); Rxy(i,j)=c(1,2); end; end;
if nargout==4, Ryx=Rxy'; end
