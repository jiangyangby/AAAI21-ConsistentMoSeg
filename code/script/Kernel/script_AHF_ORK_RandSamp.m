
clear all;
close all;

addpath(genpath('../../Tools/'));

%% Para
FrameGap = 1; % gap between a pair of frames
max_NumHypoPerFrame = 500;  % Max number of hypotheses sampled from each frame pair

% Dataset = 'Hopkins155';  % KT3DMoSeg
% select_visible = 0;  % 1 for KT3DMoSeg
% Dataset = 'KT3DMoSeg';
% select_visible = 1;
Dataset = 'MTPV62';
select_visible = 1;
model_type = lower('affine');   % Model name
[fitfn resfn degenfn psize numpar] = getModelParam(model_type);
gen_Kernel_Dataset(Dataset, model_type, resfn, FrameGap, max_NumHypoPerFrame, select_visible);

model_type = lower('fundamental');
[fitfn resfn degenfn psize numpar] = getModelParam(model_type);
gen_Kernel_Dataset(Dataset, model_type, resfn, FrameGap, max_NumHypoPerFrame, select_visible);

model_type = lower('homography');
[fitfn resfn degenfn psize numpar] = getModelParam(model_type);
gen_Kernel_Dataset(Dataset, model_type, resfn, FrameGap, max_NumHypoPerFrame, select_visible);
