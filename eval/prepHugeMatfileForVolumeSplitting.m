function prepHugeMatfileForVolumeSplitting(mdpath, mod, outmatfile)
% mdpath = [SYNTHESIS_DATA_PATH, '/ADNI_T1_baselines/md/adalca_wholevol_restor_md_2016_03_06.mat']
% mod = 'Ds5Us5RegMask'
% outmatfile = '/data/vision/polina/projects/stroke/work/patchSynthesis/data/ADNI_T1_baselines/subvols/wholevol/mar12_2016/ADNI_T1_baselines_wholevol_Ds5Us5RegMask_volumes.mat'
%
% mdpath = [SYNTHESIS_DATA_PATH, '/stroke/md/adalca_brain_pad10_restor_md_2016_03_12.mat']
% mod = 'Ds5Us5RegMask'
% outmatfile = '/data/vision/polina/projects/stroke/work/patchSynthesis/data/stroke/subvols/brain_pad10/mar12_2016/stroke_brain_pad10_Ds5Us5RegMask_volumes.mat'

    load(mdpath);
    
    % get subjects
    tic;
    nSubjects = md.getNumSubjects();
    vi = verboseIter(1:nSubjects, 2);
    while vi.hasNext()
        i = vi.next();
        if i == 1
            volume = md.loadVolume(mod, i);
            volumes = zeros([size(volume), nSubjects]);
            volumes(:,:,:,i) = volume;
        else
            volumes(:,:,:,i) = md.loadVolume(mod, i);
        end
    end
    vi.close();
    toc;
        
    % save matfile
    tic;
    mkdir(fileparts(outmatfile));
    save(outmatfile, 'volumes', '-v7.3');
    toc;
    
    disp('done');
    