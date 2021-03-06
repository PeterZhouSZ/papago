function [reconPatch, subjPatchMins, logp] = recon(atlMu, atlSigma, atlLoc, atlPatchSize, ...
    subjVol, subjWeightVol, atlLoc2SubjSpace, method, varargin)
% reconstruct a subject patch given the atlas
%
% varargin is:
%   <regVal> if method is forward 
%   subjLoc2AtlSpace if method is inverse
%   if |varargin| > 1, second varargin is R
%
% srcLoc2TgtSpace is computed via
%   srcLoc2TgtSpace = tform2cor3d(subj2Atl, size(subjVol), srcVoxDims, tgtVolSize, tgtVoxDims, dirn);
%
% TODO: use cropVolume to extract patch.
% TODO: allow just tform as opposed to cell map?

    % get subject gaussian coordinates and information
    if numel(varargin) > 1
        bigR = varargin{2};
        assert(strncmp(method, 'inverse', 7));
        
        [~, subjPatchMins, subjPatchSize] = paffine.atl2SubjPatch(atlLoc, atlPatchSize, atlLoc2SubjSpace);
        [R, ~, subjInterpMask] = vol2subvolInterpmat(bigR, atlLoc2SubjSpace, size(varargin{1}{1}), atlLoc, atlPatchSize); 
        [subjMu, subjSigma] = paffine.atl2SubjGauss(atlMu, atlSigma, method, R);
        
    else
        [subjMu, subjSigma, subjInterpMask, subjPatchMins, subjPatchSize] = ...
            paffine.atl2SubjGauss(atlMu, atlSigma, method, atlLoc, atlPatchSize, atlLoc2SubjSpace, varargin{:});
    end

           
    % reconstruct the patch
    subjPatch = cropVolume(subjVol, subjPatchMins, subjPatchMins + subjPatchSize - 1);
    %m = mean(subjPatch(:));
    %subjPatch = subjPatch - m;
    subjWeightPatch = cropVolume(subjWeightVol, subjPatchMins, subjPatchMins + subjPatchSize - 1);
    [reconPatch, invBb] = paffine.reconSubjPatch(subjPatch, subjWeightPatch, subjInterpMask, subjMu, subjSigma);
    %reconPatch = reconPatch + m;
    
    % compute the logp
    if nargout > 2
        logp = paffine.logpSubjPatch(subjPatch, subjWeightPatch, subjInterpMask, subjMu, subjSigma, invBb);
    end
end
