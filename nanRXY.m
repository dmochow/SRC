function [Rxy,Rxx,Ryy,Ryx] = nanRXY(X,Y)
% [Rxy,Rxx,Ryy,Ryx] = nanRXY(X,Y) computes covariance matrixes taking NaN into account. 
% Assumes X and Y are organized as samples by channels. 
Rxx=nancov(X,'pairwise');
Ryy=nancov(Y,'pairwise');
for i=1:size(X,2), for j=1:size(Y,2), c=nancov(X(:,i),Y(:,i)); Rxy(i,j)=c(1,2); end; end;
if nargout==4, Ryx=Rxy'; end
