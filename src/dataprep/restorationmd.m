function md = restorationmd(dsAmounts, buildpath, savepath, name)
% prepare a medicalDataset object for the restoration project. 
%   md = restorationmd(dsAmounts, buildpath) prepare and build a medicalDataset
%   object for the restoration project. 
%
%   md = restorationmd(dsAmounts, buildpath, savepath, name) also save the md
%   object.
%
%   dsAmounts - a vector of the downsampling amounts. e.g. 2:5
%   buildpath e.g.: ADNI_PATH_PROC
%   savepath e.g.: SYNTHESIS_DATA_PATH
%   name - the name of the md, mostly for saving purposes
%
% Image Restoration project

    %% create adni medicalDatasets for data.

    % initialize basic modalities
    md = medicalDataset();
    % md.addRequiredModality('orig', '%s.nii.gz');
    md.addModality('proc', '%s_proc.nii.gz');
    md.addModality('matfile', '%s.mat');
    md.addRequiredModality('brain', '%s_brain.nii.gz');
    md.addModality('seg', '%s_seg.nii.gz');
    md.addModality('procBrain', '%s_proc_brain.nii.gz');
    md.addModality('procBrainSeg', '%s_proc_brain_seg.nii.gz');
    

    % rigid registrations directly
    md.addModality('rigidReg', '%s_reg_buckner61.nii.gz');
    md.addModality('rigidRegBrain', '%s_brain_reg_buckner61_brain.nii.gz');
    md.addModality('rigidRegMat', '%s_reg_buckner61.mat');
    md.addModality('rigidRegMatBrain', '%s_brain_reg_buckner61_brain.mat');

    % bounding boxes
    md.addModality('bb', 'boundingBox/%s.nii.gz');
    md.addModality('bbBrain', 'boundingBox/%s_brain.nii.gz');
    md.addModality('bbmat', 'boundingBox/%s.mat');
    md.addModality('bbmatBrain', 'boundingBox/%s_brain.mat');

    for s = dsAmounts % downsample amount

        % downsampled data in z direction
        mod = sprintf('%s_roc_downsampled%d.nii.gz', '%s', s);
        md.addModality(sprintf('ds%d', s), mod);

        mod = sprintf('%s_brain_roc_downsampled%d.nii.gz', '%s', s);
        md.addModality(sprintf('brainDs%d', s), mod);

        mod = sprintf('%s_brain_cropped%d.nii.gz', '%s', s);
        md.addModality(sprintf('brainCropped%d', s), mod);

        mod = sprintf('%s_brain_cropped%d_seg.nii.gz', '%s', s);
        md.addModality(sprintf('brainCropped%dSeg', s), mod);
        
        mod = sprintf('%s_brain_cropped%d_mask.nii.gz', '%s', s);
        md.addModality(sprintf('brainCropped%dMask', s), mod);

        for u = 1:s % upsample amount
            % in most cases, all volumes will be downsampled by a factor of 1x1xs, then "upsampled" by a
            % factor of 1x1xu
            %
            % thus, if s = u, you get volumes that are the same size as you started.
            %
            % exception are the *iso* volumes, which are downsampled by a factor of 1x1xs, then
            % downsampled by uxuxs then upsampled to uxuxu. 

            mod = sprintf('%s_brain_iso_2_ds%d_us%d_size.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainIso2Ds%dUs%dsize', s, u), mod); 

            mod = sprintf('%s_brain_downsampled%d_isoprepped%d.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainDs%dIso%d', s, u), mod); 

            mod = sprintf('%s_brain_downsampled%d_reinterpolated%d.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainDs%dUs%d', s, u), mod);

            mod = sprintf('%s_brain_downsampled%d_reinterpolated%d_nn.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainDs%dUs%dNN', s, u), mod);

            mod = sprintf('%s_brain_downsampled%d_reinterpolated%d_dsmask.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainDs%dUs%dMask', s, u), mod);

            mod = sprintf('%s_brain_downsampled%d_reinterpolated%d_dsmask_nn.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainDs%dUs%dNNMask', s, u), mod);


            % registration modalities: ds/us and then register
            mod = sprintf('%s_brain_downsampled%d_reinterpolated%d_reg.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainDs%dUs%dReg', s, u), mod);
            
            mod = sprintf('%s_brain_downsampled%d_reinterpolated%d_regwcor.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainDs%dUs%dInterpReg', s, u), mod);
            
            mod = sprintf('%s_brain_downsampled%d_reinterpolated%d_reg_seg.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainDs%dUs%dRegSeg', s, u), mod);

            mod = sprintf('%s_brain_downsampled%d_reinterpolated%d_reg.mat', '%s', s, u);
            md.addModality(sprintf('brainDs%dUs%dRegMat', s, u), mod);

            mod = sprintf('%s_brain_downsampled%d_reinterpolated%d_dsmask_reg.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainDs%dUs%dRegMask', s, u), mod);

            mod = sprintf('%s_brain_iso_2_ds%d_us%d_size_reg.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainIso2Ds%dUs%dsizeReg', s, u), mod); 

            mod = sprintf('%s_brain_iso_2_ds%d_us%d_size_reg_seg.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainIso2Ds%dUs%dsizeRegSeg', s, u), mod); 
            
            
            % regitraion modalities: first registering then propagate the ds/us
            mod = sprintf('%s_brain_reg_downsampled%d_reinterpolated%d.nii.gz', '%s', s, u);
            md.addModality(sprintf('regBrainDs%dUs%d', s, u), mod);

            mod = sprintf('%s_brain_reg_downsampled%d_reinterpolated%d_dsmask.nii.gz', '%s', s, u);
            md.addModality(sprintf('regBrainDs%dUs%dMask', s, u), mod);

            mod = sprintf('%s_brain_reg_downsampled%d_reinterpolated%d_nn.nii.gz', '%s', s, u);
            md.addModality(sprintf('regBrainDs%dUs%dNN', s, u), mod);

            mod = sprintf('%s_brain_reg_downsampled%d_reinterpolated%d_dsmask_nn.nii.gz', '%s', s, u);
            md.addModality(sprintf('regBrainDs%dUs%dNNMask', s, u), mod);    
        end
    end

    %% add rebuilt modalities
    for s = dsAmounts % downsample amount
        for u = 2:s % upsample amount
            mod = sprintf('%s_brain_downsampled%d_reinterpolated%d_rebuilt.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainDs%dUs%d_rebuilt', s, u), mod);

            % registration modalities: ds/us and then register
            mod = sprintf('%s_brain_downsampled%d_reinterpolated%d_rebuilt_reg.nii.gz', '%s', s, u);
            md.addModality(sprintf('brainDs%dUs%dReg_rebuilt', s, u), mod);
        end
    end
    
    %% build md
    md.build(buildpath, []);
    md.overwrite = true;
    
    %% save md
    if exist('savepath', 'var')
        if ~exist('name', 'var')
            name = '';
        end
        date = datestr(now, 'yyyy_mm_dd');
        fld = [savepath, filesep, name, filesep, 'md', filesep];
        mkdir(fld);
        save([fld, sys.usrname, '_restor_md_', date], 'md');
    end
    