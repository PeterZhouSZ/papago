function logP = logpSubjPatch(subjPatch, subjWeightPatch, subjPatchValidRegion, subjMu, subjSigma, invBb)
% LOGSUBJPATCH compute the logp of the *known* and *valid* regions of the subject patch given
% cluster parameters
%
%
% subjPatch is the whole patch in subject space
% subjWeight is 0-1 weight patch in subject space
% subjPatchValidRegion is the 0-1 mask from the transform specifying the atlas patch shape inside
%   the subject patch. Think of this as the "shape" of the atlas patch rotated in subject space.
% subjMu is the nKnown-by-1 subject mean
% subjSigma is the nKnown-by-nKnown subject covariance
% invBb is a potentially-useful matrix of inv(B) * b, where b is the vector of mean-centered known
%   and valid voxels, and B is the covariance of those voxels.
%
% logP is scalar

     % get the part of the subject patch corresponding to the atlas patch
    subjPatchWithNans = subjPatch;
    subjPatchWithNans(~subjWeightPatch) = nan;
    subjPatchAtlVoxels = subjPatchWithNans(subjPatchValidRegion);

    % compute inv(B) * b, where b is the vector of mean-centered known and valid voxels, and B is
    % the covariance of those voxels.
    valid = ~isnan(subjPatchAtlVoxels);
    selSubjMu = subjMu(subjPatchValidRegion);
    b = (subjPatchAtlVoxels(valid) - selSubjMu(valid));
    selSubjSigma = subjSigma(subjPatchValidRegion, subjPatchValidRegion);
    B = selSubjSigma(valid, valid);
    
    % compute inv(B) * b
    if nargin <= 5
        invBb = B \ b;
    end
        
    % compute the log probability
    logP = -numel(b)/2 * log(2*pi) - 0.5 * logdet(B) - 0.5 * b' * invBb;
    