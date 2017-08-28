function postProcessSubject(md, subjid, dsRate, regType, usRates)
% processing after ANTs Registrations are done.

    if ischar(md), load(md); end
    if ischar(subjid) && ~isempty(str2double(subjid)), subjid = str2double(subjid); end
	if ischar(dsRate), dsRate = str2double(dsRate); end
    if ischar(usRates), usRates = str2double(usRates); end
    
    % decide whether to do segmentations
    doseg = sys.isfile(md.getModality('seg', subjid));
    
    %% Perform registration via DsXUsX rigid registration
    antsfile = sprintf('Ds%dUs%dANTsReg', dsRate, dsRate);
    preregmod = sprintf('Ds%dUs%dRegMat', dsRate, dsRate);
    DsUsReg = sprintf('Ds%dUs%dReg', dsRate, dsRate);
    DsUs = sprintf('Ds%dUs%d', dsRate, dsRate);
    md.register(DsUs, antsfile, 'affine', 'monomodal', ...
        'saveModality', DsUsReg, 'savetformModality', preregmod, 'include', subjid);
    
    usRatesSorted = sort(usRates, 'descend');
    for usRate = usRatesSorted
        % prepare atlas file (for applying warp)
        atlfile = eval(sprintf('atlMods.%s_DS%d_US%d', upper(regType), dsRate, usRate));

        % modality names for this dsRate and usRate
        IsoDsUssize = sprintf('Iso2Ds%dUs%dsize', dsRate, usRate);
        DsUs = sprintf('Ds%dUs%d', dsRate, usRate);
        DsUsMark = sprintf('Ds%dUs%dMask', dsRate, usRate);

        DsUsReg = sprintf('Ds%dUs%dReg', dsRate, usRate);
        DsUsRegMask = sprintf('Ds%dUs%dRegMask', dsRate, usRate);
        Iso2DsUssizeReg = sprintf('Iso2Ds%dUs%dsizeReg', dsRate, usRate);

        % apply "dsXusX" registration to modality and to mask
        md.register(DsUs, atlfile, 'rigid', 'monomodal', ...
            'saveModality', DsUsReg, 'loadtformModality', preregmod, 'include', subjid);
        md.register(DsUsMark, atlfile, 'rigid', 'monomodal', ...
            'saveModality', DsUsRegMask, 'loadtformModality', preregmod, 'include', subjid);
        md.register(IsoDsUssize, atlfile, 'rigid', 'monomodal', ...
            'saveModality', Iso2DsUssizeReg, 'loadtformModality', preregmod, 'include', subjid);
        
        % segmentations
        if doseg
            DsUsSeg = sprintf('Ds%dUs%dSeg', dsRate, usRate);
            DsUsRegSeg = sprintf('Ds%dUs%dRegSeg', dsRate, usRate); % use the original Ds5Us5!
            md.register(DsUsSeg, atlfile, 'rigid', 'multimodal', ...
                'saveModality', DsUsRegSeg, 'loadtformModality', preregmod, 'registeredVolumeInterp', 'nearest', 'include', subjid);        
        end
    end
