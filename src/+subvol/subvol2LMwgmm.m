function subvol2LMwgmm(dsSubvolMat, wtSubvolMat, clusterIdxMat, wgmmMat, iniFilename)
% this file structure is a relic from MICCAI 2016 / Thesis 2016 attempt. We'll keep it for now...
% we're hard-coding dsidx2S init.
% 
% dsSubvolMat - matfile name of subvolume
% wtSubvolMat - matfile name of weights
% iniFilename - ini filename with parameters (input)
% clusterIdxMat - matfile name of cluster assignments (if don't have, where to save)
% wgmmMat - matfile name of output wgmm (output)

    params = ini2struct(iniFilename); 

    % rename the parameters
    gmmK = params.gmmK; 
    patchSize = params.patchSize; 
    nPatches = params.nPatches; 
    
    gmmTolerance = params.gmmTolerance; 
    regstring = params.regstring;
    
    diffPad = params.volPad;
    dLow = params.dLow;
    maxIters = params.maxIters;
    TolFun = params.TolFun;
    wthr = params.threshold;
    
    nDims = numel(patchSize);

    %% load subvolumes
    tic
    q = load(dsSubvolMat, 'subvolume'); 
    dsSubvols = q.subvolume;
    q = load(wtSubvolMat, 'subvolume'); 
    wtSubvols = q.subvolume;
    clear q;
    fprintf('took %5.3f to load the subvolumes\n', toc);
    
    % compute some parameters
    volSize = size(dsSubvols);
    nSubj = volSize(nDims + 1);
    volSize = volSize(1:nDims);
    
    if isscalar(diffPad)
        diffPad = diffPad * ones(1, nDims);
    end
    
    % crop volumes -- we don't want to learn from the edges of the volumes;
    dsSubvolsCrop = cropVolume(dsSubvols, [diffPad+1 1], [volSize-diffPad nSubj]);
    wtSubvolsCrop = cropVolume(wtSubvols, [diffPad+1 1], [volSize-diffPad nSubj]);
    
    %% get patches and init.
    dsPatches = patchlib.vol2lib(dsSubvolsCrop, [patchSize 1]);
    wtPatches = patchlib.vol2lib(wtSubvolsCrop, [patchSize 1]);
    
    % Need to select which patches to work with.
    % here we'll use clusterIdxMat as the file to dump the trainsetIdx matrix
    if ~sys.isfile(clusterIdxMat)
        trainsetIdx = randsample(size(dsPatches, 1), nPatches);
        Y = dsPatches(trainsetIdx, :);
        
        gmmopt = statset('Display', 'iter', 'MaxIter', 3, 'TolFun', gmmTolerance);
        % gmmClust = fitgmdist(smallBlurPatches, gmmK, regstring, 1e-4, 'replicates', 3, 'Options', gmmopt);
        gmdist = gmdistribution.fit(Y, gmmK, regstring, 1e-4, 'replicates', 3, 'Options', gmmopt);

        % compute expectations
        dspost = gmdist.posterior(Y);
        pi = sum(dspost) ./ sum(dspost(:));
        % wgmm.gmdist2wgmm is problematic in 2014b.gmdist.ComponentProportion
        wgDs = wgmm([], struct('mu', gmdist.mu, 'sigma', gmdist.Sigma, 'pi', pi));
        wgDs.expect.gammank = dspost;
        
        save(clusterIdxMat, 'trainsetIdx', 'wgDs');
    else
        q = load(clusterIdxMat, 'trainsetIdx', 'wgDs');
        trainsetIdx = q.trainsetIdx;
        assert(numel(trainsetIdx) == nPatches, 'The saved number of patches is incorrect');
        
        Y = dsPatches(trainsetIdx, :);
    end
        
    %% run
    data = struct('Y', Y, 'W', wtPatches(trainsetIdx, :) > wthr, 'K', gmmK);
    
    % ecm
    wg = wgmmfit(data, 'modelName', 'latentMissing', 'modelArgs', struct('dopca', dLow), ...
        'maxIter', maxIters, 'TolFun', TolFun, 'verbose', 2, 'replicates', 1, ...
        'init', 'latentMissing-clusterIdx-twostage', 'initArgs', struct('wgmm', wgDs));

    save(wgmmMat, 'wg', 'trainsetIdx', '-v7.3'); 

    % warning('(might be meaningless now? remember to add small diagonal component to sigmas in next code'); 
end
