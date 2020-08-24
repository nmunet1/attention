function imdata = target(TrialRecord, MLConfig)
% Generates a vertically oriented circular Gabor matrix

PixPerDeg = MLConfig.Screen.PixelsPerDegree;

% Gabor parameters, in deg
Sigma = TrialRecord.Editable.choice_radius/2.5; % std of Gaussian modulation, in deg
Theta = 0; % orientation angle, in deg
Freq = TrialRecord.Editable.frequency; % grating frequency, in cycles/deg
Contrast = TrialRecord.Editable.contrast; % light/dark contrast

if TrialRecord.CurrentConditionInfo.cue_on
    color = [0 1 0];
else
    color = [1 1 1];
end

imdata = circgabor(Sigma, Theta, Freq, Contrast, PixPerDeg, color);

end