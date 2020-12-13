
clear all;
close all;


addpath(genpath('../../Tools/'));

%% Para
max_NumHypoPerFrame = 500;
FrameGap = 1;
model_type = 'Subset';

Alpha_Range = 5:15; % range of power scaling parameter to evaluate

gamma_range = 1e-2;   % range of gamma to evaluate

%% Load Seq Information
% Dataset = 'KT3DMoSeg';
% visible = 1;
Dataset = 'Hopkins155';
visible = 0;
temp = load(['../../Data/' Dataset '/SeqList.mat']);
SeqList = temp.SeqList;
seq_range = 1:length(SeqList);

for Alpha = Alpha_Range
    for gamma = gamma_range
        %% motion segmentation result save path
        result_path = fullfile(['../../Results/' Dataset '/MoSeg/'],model_type);

        if ~exist(result_path,'dir')
            mkdir(result_path);

        end

        result_filepath = fullfile(result_path,sprintf('Error_RandSamp_nhpf-%d_alpha-%g_gamma-%g.mat',...
            max_NumHypoPerFrame,Alpha,gamma));

        %% motion segmentation on all sequences
        error = [];
        ClusterIdx = [];

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

            %% Subset Constraint motion segmentation
            nMotion = max(Data.GtLabel);
            epsilon = 1e-8;
            MaxItr = 20;

            K = [];
            K(:,:,1) = K_A+eps;
            K(:,:,2) = K_H+eps;
            K(:,:,3) = K_F+eps;

            tic;
            [U_Subset, ~ , ~] = func_Subset_eig(K,nMotion,gamma,epsilon,MaxItr);

            %% Normalize
            U_All = [];
            for k_i = 1:size(U_Subset,3)
                U_All = [U_All func_L2Normalize(U_Subset(:,:,k_i),2)];
            end

            %%% Normalize
            U = func_L2Normalize(U_All,2);

            ClusterIdx{s_i} = kmeans(U, nMotion, 'replicates',500, 'start', 'cluster', ...
                'EmptyAction', 'singleton');
            
            solve_time = toc;

            %%% Evaluate Classification Error
            error(s_i) = Misclassification(ClusterIdx{s_i},Data.GtLabel);

            fprintf('Sequence %s Error = %.2f%%, time=%.2fs \n',SeqName,100*error(s_i), solve_time);

        end

        fprintf('Overall Miss Classification Rate = %.2f%%\n',100*mean(error));

        %% Save Results

        save(result_filepath,'ClusterIdx','error');

    end

end

