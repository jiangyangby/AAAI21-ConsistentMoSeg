%% Sample affine hypotheses

clear all;
close all;

%% Set path.
addpath(genpath('../../Tools/'));

%% Para
FrameGap = 1;   % gap between a pair of frames
max_NumHypoPerFrame = 500;  % Max number of hypotheses sampled from each frame pair

% Dataset = 'Hopkins155';  % KT3DMoSeg
% select_visible = 0;  % 1 for KT3DMoSeg
% Dataset = 'KT3DMoSeg';
% select_visible = 1;
Dataset = 'MTPV62';
select_visible = 1;
model_type = lower('affine');
gen_Hypo_Dataset(Dataset, model_type, FrameGap, max_NumHypoPerFrame, select_visible);

model_type = lower('fundamental');
gen_Hypo_Dataset(Dataset, model_type, FrameGap, max_NumHypoPerFrame, select_visible);

model_type = lower('homography');
gen_Hypo_Dataset(Dataset, model_type, FrameGap, max_NumHypoPerFrame, select_visible);
