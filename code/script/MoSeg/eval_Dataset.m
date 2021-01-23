function [ error, ClusterIdx, Affinitys, StructCs, Losses, ExtRes ] = ...
    eval_Dataset( Dataset, model_type, ClusterFn, Alpha, ...
    Params, ext_flag, max_NumHypoPerFrame, visible, visualize )
%% Load Seq Information
temp = load(['../../Data/' Dataset '/SeqList.mat']);
SeqList = temp.SeqList;
seq_range = 1:length(SeqList);

%% motion segmentation on all sequences
error = zeros(length(seq_range), 1);
ClusterIdx = {};
Affinitys = {};
StructCs = {};
Losses = {};
ExtRes = {};

old_Params = Params;
for s_i = seq_range
    SeqName = SeqList{s_i};

    %% Load Data
    Data = load_seq(Dataset, SeqName);

    %% Normalize affinity matrix by the Cooccurrence of points
    if visible == 1
        PtsOcc = double(Data.visibleSparse);    % point occurrence across all frames
    else
        PtsOcc = double(ones(Data.nSparsePoints, Data.nFrames));
    end
    CoocNormalizer = PtsOcc * PtsOcc' + 0.1;    % points cooccurrence

    %% Load Affine Kernel Matrix
    K_A = load_kernel('affine', Dataset, SeqName, max_NumHypoPerFrame);
    K_A = K_A./(CoocNormalizer+0.1);

    %% Load H Kernel Matrix
    K_H = load_kernel('homography', Dataset, SeqName, max_NumHypoPerFrame);
    K_H = K_H./(CoocNormalizer+0.1);

    %% Load F Kernel Matrix
    K_F = load_kernel('fundamental', Dataset, SeqName, max_NumHypoPerFrame);
    K_F = K_F./(CoocNormalizer+0.1);

    [K_A,Mask] = func_Adapt_eNN(K_A,Alpha);
    [K_H,Mask] = func_Adapt_eNN(K_H,Alpha);
    [K_F,Mask] = func_Adapt_eNN(K_F,Alpha);

    %% Merge all kernels
    nMotion = max(Data.GtLabel);
    K_A = K_A - diag(diag(K_A));
    K_H = K_H - diag(diag(K_H));
    K_F = K_F - diag(diag(K_F));
    Z = {K_A, K_H, K_F};
%     ea = eig(diag( K_A * ones(size(K_A,2), 1) ) - K_A);
%     eh = eig(diag( K_H * ones(size(K_H,2), 1) ) - K_H);
%     ef = eig(diag( K_F * ones(size(K_F,2), 1) ) - K_F);
%     disp([nMotion])
%     disp([ea(1:4) eh(1:4) ef(1:4)])
    tic;
    [CD, AffinityMat, C, D, loss, PredLabel, error_rate, E] = eval_ClusterFunc(ClusterFn, Z, nMotion, Data.GtLabel, Params, ext_flag);
    solve_time = toc;
    Losses{s_i} = loss;
    StructCs{s_i} = C;
    Affinitys{s_i} = AffinityMat;
    ClusterIdx{s_i} = PredLabel;
    error(s_i) = error_rate;
    ExtRes{s_i} = E;
    fprintf('seq-%d error=%.2f%% time=%.2fs\n', s_i, 100*error(s_i), solve_time);

    %% Visualize
    if visualize == 1
        GT = build_indicator_mat(size(K_A, 1), Data.GtLabel);
        Pred = build_indicator_mat(size(K_A, 1), PredLabel);
        % rearrange
        [gt_sorted, index] = sort(Data.GtLabel, 'ascend');
        GT = GT(index, index);
        C = C(index, index);
        Pred = Pred(index, index);
        AffinityMat = AffinityMat(index, index);
        D = cellfun(@(d) d(index, index), D, 'UniformOutput', false);
        Z = cellfun(@(z) z(index, index), Z, 'UniformOutput', false);
        visualize_mats( GT, Pred, C, AffinityMat, Z, D );
%         E = cellfun(@(e) e(index, index), E, 'UniformOutput', false);
%         visualize_mats( GT, C, AffinityMat, Z, D, E );
    end
end

fprintf('Alpha=%d, Lamda1=%.3f, Lamda2=%.3f, Lamda3=%.2f, Overall Error Rate = %.2f%%\n', ...
    Alpha, Params(1), Params(2), Params(3), 100*mean(error));
end

