%Author: Joel Kemp
%File: GMMEMLogLikelihood.m
%Purpose: Computes the sum of the log likelihoods that each point was
%   generated by the model parameters.
%Returns: The scalar sum of log likelihoods across all cluster parameters.
function llh = GMMEMLogLikelihood(X, m, means, covariances, mixtureCoeffs)
N = numel(X(:,1));

llh = 0;
%For every point
for j = 1:N
    %Cache the point
    p = X(j,:); 
    
    likelihood = 0;
    %For each cluster
    for k = 1:m
        %Note: We use a try/catch here because large values of m (namely
        %   about 19 and upward) throw an error about ill-conditioned
        %   covariance matrices. We fix this in the catch by adding a very
        %   small positive number to the elements of the matrix. The small
        %   value somehow fixes the problem without negatively affecting the
        %   values of the covariance matrix.
        try
        %Compute the norm distribution of p with the cluster stats
        y = mvnpdf(p, means(k,:), covariances{k,:});
        likelihood = likelihood + mixtureCoeffs(k,1) * y;
        catch err
            covariances{k,:} = covariances{k,:} + 0.0000001;
            %Compute the norm distribution of p with the cluster stats
            y = mvnpdf(p, means(k,:), covariances{k,:});
            likelihood = likelihood + mixtureCoeffs(k,1) * y;
        end
    end
    
    %Compute the log of the likelihood
    llh = llh + log(likelihood);
end