function [x,exitCode]=eqConstLSSpher(A,b,alpha,varargin)
%%EQCONSTLSSPHER Find x to minimize norm(A*x-b,2) under the constraint
%                that norm(x,2)=alpha. This is essentialy contraining x to
%                the surface of a sphere of radius alpha. This only solves
%                real systems.
%
%INPUTS: A A real mXn matrix with m>=n.
%        b A real mX1 vector.
%    alpha The equality constraint value. If this parameter is omitted or
%          an empty matrix is passed, the default of 1 is used.
% varargin Any parameters that one might wish to pass to the fzero
%          function. These are generally comma-separated things, such as
%          'TolX',1e-12.
%
%OUTPUTS: x The optimal value of x subject to the spherical constraint.
%    lambda The Lagrangian multiplier used in the optimization. lambda>=0.
%           If lambda=0, then the constraint on x did not have to be
%           enforced.
%  exitFlag The exit flag from the fzero function, which is used as a
%           subroutine in this function.
%
%This implements a modified version of the algorithm of Chapter 6.2.1 of
%[1]. The zero of the cost function is found usign the fzero function.
%
%The algorithm of Chapter 6.2.1 of [1] solves the optimization
%constrained such that norm(x,2)<=alpha. We wish to solve the equality
%constrained problem. When the x returned by the unconstrained optimization
%is such that norm(x,2)>alpha, we proceed in the same manner as is done in
%the inequality-constrained implementation in constrainedLSSpher. When
%norm(x,2)<alpha, we proceed in the same manner: solving a particular
%equation for the Lagrangian multiplier alpha by using the fzero function.
%However, the bounds for the search are different. The upper bound is now 0
%(the unconstrained case). In this instance, we know that the Lagrangian
%multiplier must be negative. The cost function is a sum of r squared
%terms. We consider the most negative value of lambda such that a single
%term in the sum is equal to alpha^2. That forms the lower bound. After
%that, the fzero function is used.
%
%EXAMPLE:
%This is a simple example where the x returned by the
%inequality-constrained algorithm is too small. Thus, we 
% A=magic(8)+20*eye(8);
% b=(1:8).';
% x=inv(A)*b;
% norm(x)%Norm <1.
% [xConst,exitCode]=eqConstLSSpher(A,b);
% norm(xConst)%Norm=1
% %It is not just normalizing the vector; elements are not scaled by a
% %constant.
% x./xConst
%
%REFERENCES:
%[1] G. H. Golub and C. F. Van Loan, Matrix Computations, 4th ed.
%    Baltimore: Johns Hopkins University Press, 2013.
%
%December 2020 David F. Crouse, Naval Research Laboratory, Washington D.C.
%(UNCLASSIFIED) DISTRIBUTION STATEMENT A. Approved for public release.

if(nargin<3||isempty(alpha))
    alpha=1;
end

r=rank(A);

[U,Sigma,V]=svd(A,0);
sigma=diag(Sigma);

%Sums are only up to r, so get rid of the extra elements.
U=U(:,1:r);
V=V(:,1:r);
sigma=sigma(1:r);

bTilde=U'*b;
x=V*(bTilde./sigma);

%We have to zero the objective function as a function of lambda. To use
%fzero and assure that lambda is positive, we have to bound the value of
%lambda. It is clear that objFun(0)>0. We just need to find a value of
%lambda so that objFun(lambda)<0. To do this, we take the largest term
%in the sum and multiply it by r. Then, we find when the lambda for
%that to be zero, multiply the result by 2 and we have an upper bound.
%Of course, we do not know which is the largest term, so we will
%evaluate all of them and choose the largest. The abs is because there
%are two solutions and the correct one will be the positive one.
if(norm(x)>alpha)
    upperBound=2*max((abs(bTilde.*sigma)*sqrt(r)-alpha*sigma.^2)./alpha);
    lowerBound=0;
else
    upperBound=0;
    lowerBound=min(-sigma.^2-abs(bTilde.*sigma/alpha));
end
f=@(lambda)objFun(lambda,alpha,bTilde,sigma);
[lambda,~,exitCode]=fzero(f,[lowerBound,upperBound],varargin{:});
x=V*((sigma.*bTilde)./(sigma.^2+lambda));
end

function val=objFun(lambda,alpha,bTilde,sigma)
%This is the function in Algorithm 6.2.1 that must be zeroed to find the
%Lagrange multiplier.

    val=sum(((sigma.*bTilde)./(sigma.^2+lambda)).^2)-alpha^2;
end

%LICENSE:
%
%The source code is in the public domain and not licensed or under
%copyright. The information and software may be used freely by the public.
%As required by 17 U.S.C. 403, third parties producing copyrighted works
%consisting predominantly of the material produced by U.S. government
%agencies must provide notice with such work(s) identifying the U.S.
%Government material incorporated and stating that such material is not
%subject to copyright protection.
%
%Derived works shall not identify themselves in a manner that implies an
%endorsement by or an affiliation with the Naval Research Laboratory.
%
%RECIPIENT BEARS ALL RISK RELATING TO QUALITY AND PERFORMANCE OF THE
%SOFTWARE AND ANY RELATED MATERIALS, AND AGREES TO INDEMNIFY THE NAVAL
%RESEARCH LABORATORY FOR ALL THIRD-PARTY CLAIMS RESULTING FROM THE ACTIONS
%OF RECIPIENT IN THE USE OF THE SOFTWARE.
