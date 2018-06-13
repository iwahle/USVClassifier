

function red_dim = pca_red(X, n)
    disp('pca');
    inds = randperm(size(X,1),min(size(X,1),50000));
    [coeff, ~, latent] = pca(X(inds,:));
    d = find(size(coeff) == length(latent));
    if(d==2)
        coeff = coeff';
    end
    red_dim = bsxfun(@times,coeff(:,1:n),1./latent(1:n)');
    disp('done');
%     Xpca = X*red_dim;
end

% reduction method from:
% https://stackoverflow.com/questions/30656047/reducing-dimensionality-of-features-with-pca-in-matlab