clear all; close all; clc

% stim2eeg demo
addpath('..');
load('./sampleData.mat','sampleEEG','sampleFeature','fsEEG','fsStim');

% first downsample the EEG to the sampling rate of the stimulus
sampleEEGdown=resample(sampleEEG,fsStim,fsEEG); 

% it's common for the downsampled EEG and the stimulus to have slightly
% different lengths, so we fix this here

% check if feature missing samples
if size(sampleEEGdown,1)>numel(sampleFeature) 
    nMissing=size(sampleEEGdown,1)-numel(sampleFeature);
    sampleFeature=cat(1,sampleFeature,zeros(nMissing,1));
end

% check if feature has too many samples
if size(sampleEEGdown,1)<numel(sampleFeature)  
    sampleFeature=sampleFeature(1:size(sampleEEGdown,1));
end

% now we need to create a convolution matrix from the one-dimensional
% feature time series.  this allows us to temporally filter the stimulus
% time series using a matrix-vector product.  tplitz.m is a function that
% creates the convolution matrix, so we call it here on the stimulus

% before calling the function, we need to specify how long we want the
% filter to be.  here we set this to one second worth of stimulus.  so
% we're looking back 1 second in time.  you can think of this as the
% maximum delay between the stimulus and the EEG response.
filterLength=fsStim; 

% now create the convolution matrix
sampleFeatureConvolution=tplitz(sampleFeature,filterLength);

% we are ready to call the core (CCA) function, but first we need to set
% some regularization parameters, which tell the CCA how many dimensions we
% should keep in both the stimulus and the EEG data

% how strongly to regularize the stimulus (small number means strong
% regularization)
Kx=7; 

% how strongly to regularize the EEG
Ky=7;

% call the core function which correlates the stimulus with the EEG
[H,W,rhos,pvals,U,V,Rxx,Ryy] = myCanonCorr(sampleFeatureConvolution,sampleEEGdown,Kx,Ky); 

% now let's examine the results

% how many components do we want to examine
nComp=7;

% how strong are the correlations:
rhos(1:nComp)

% now let's look at the scalp maps of the first three EEG components that
% the stim2eeg found

% first compute the so-called "forward models"
A=Ryy*W(:,1:nComp)*inv(W(:,1:nComp)'*Ryy*W(:,1:nComp));

figure(1);
locfile='BioSemi32.loc'; % EEGLAB-style location file for rendering scalp maps
for c=1:3
    subplot(2,3,c);
    topoplot(A(:,c),locfile,'electrodes','off','numcontour',0,'plotrad',0.7);
    colormap('jet')
    subplot(2,3,c+3);
    plot(H(:,c),'k');
end

% go over the other outputs from myCanonCorr...

