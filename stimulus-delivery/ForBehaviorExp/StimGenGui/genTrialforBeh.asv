function trials = genTrialforBeh(behStimType, trialKey)
%GENTRIALFORBEH creates trial structure for playing the visual stimuli in
%behavior experiment.

switch behStimType
    case 'Left Right Full-field Drifting Grating'
        trials = trialStruct_LeftRightFullFieldGrating(trialKey);
    case 'Delayed Matching/NonMatch to Sample visual stimulus'
        trials = trialStruct_DMTSvs(trialKey);
    otherwise
        error('Stimulus type is not defined')
end

