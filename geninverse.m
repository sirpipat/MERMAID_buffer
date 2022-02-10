function Gi = geninverse(G, Cd)
% Gi = GENINVERSE(G, Cd)
% Computes generalized inverse of a matrix for the overdetermined case.
%
% G^{-g} = (G^T * C_d^{-1}* G)^{-1} * G^T * C_d^{-1}
%
% INPUT
% G         matrix to invert
% Cd        data covariance matrix [default: eye(size(G,1))]
% 
% OUTPUT
% Gi        general inverse of a matrix
%
% Last modified by Sirawich Pipatprathanporn, 10/30/2020

if ~exist('Cd', 'var') || isempty(Cd)
    Cd = eye(size(G,1));
end

% check dimension of Cd and G
if size(Cd,1) ~= size(Cd,2)
    error('ERROR: data covariance matrix has to be a square matrix\n');
end
if size(G,1) ~= size(Cd,1)
    error(['ERROR: the number of row of G matrix has to equal size of' ...
        ' data covariance matrix\n']);
end

% overdetermined case
if size(G,1) >= size(G,2)
    if all(Cd == eye(size(G,1)), 'all')
        Gi = (G' * G) \ G';
    else
        Gi = (G' / Cd * G) \ G' / Cd;
    end
% underdetermined case
else
    Gi = G' / (G * G');
end
end