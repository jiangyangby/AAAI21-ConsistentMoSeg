
clear all;
close all;

addpath(genpath('../../Tools/'));

warning('off', 'stats:kmeans:FailedToConvergeRep');

%% Para
max_NumHypoPerFrame = 500;
FrameGap = 1;
% Dataset = 'Hopkins155';
% select_visible = 0;
% Dataset = 'Hopkins12';
% select_visible = 0;
Dataset = 'KT3DMoSeg';
select_visible = 1;
% Dataset = 'MTPV62';
% select_visible = 1;
model_type = 'ConsistenMoSeg';
ClusterFn = @ConsistenMoSeg;
ext_flag = 0;

Alpha_Range = 3:3; % range of power scaling parameter to evaluate

visualize = 0;

rng(10101011);

for Alpha = Alpha_Range
%     Params = [0.001 0.015 0 5 1e-4];  % Hopkins155, MTPV62
    % Params = [0.005 0.05 0 5 1e-4];  % Hopkins12
    Params = [0.001 0.01 0 5 1e-4];  % KT3DMoSeg
    [error, ClusterIdx, Affinitys, StructCs, Losses, ExtRes] = ...
        eval_Dataset(Dataset, model_type, ClusterFn, Alpha, Params, ...
        ext_flag, max_NumHypoPerFrame, select_visible, visualize);
    %% Save Results
    result_path = fullfile(['../../Results/' Dataset '/MoSeg/'], model_type);
    if ~exist(result_path,'dir')
        mkdir(result_path);
    end
    result_filepath = fullfile(result_path,sprintf('Error_RandSamp_nhpf-%d_alpha-%g.mat',...
        max_NumHypoPerFrame, Alpha));
    save(result_filepath, 'error', 'ClusterIdx', 'Affinitys');
end

