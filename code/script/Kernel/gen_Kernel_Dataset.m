function [ ret ] = gen_Kernel_Dataset( Dataset, model_type, ...
    resfn, FrameGap, max_NumHypoPerFrame, select_visible )
%% Load Seq Information
temp = load(['../../Data/' Dataset '/SeqList.mat']);
SeqList = temp.SeqList;

for s_i = 1:length(SeqList)
    SeqName = SeqList{s_i}; % sequence name

    %% Kernel result save path
    kernel_path = fullfile(['../../Results/' Dataset '/Kernels/'],model_type);
    if ~exist(kernel_path,'dir')
        mkdir(kernel_path);
    end
    kernel_filepath = fullfile(kernel_path, ...
        sprintf('ORK_RandomSamp_Sparse_seq-%s_nhypoframe-%d.mat',SeqName,max_NumHypoPerFrame));

    %%% Load Hypotheses
    hypo_path = fullfile(['../../Results/' Dataset '/Hypotheses/'],model_type);
    hypo_filepath = fullfile(hypo_path, ...
        sprintf('Hypo_RandSamp_Sparse_seq-%s_nHypo-%d.mat',SeqName,max_NumHypoPerFrame));
    temp = load(hypo_filepath, 'Hypos');
    Model = temp.Hypos;

    Data = load_seq(Dataset, SeqName);

    %% Compute kernel by accumulating all frame pairs
    K = zeros(Data.nSparsePoints);

    for f_i = 1:Data.nFrames-FrameGap
        mdl_idx = find(Model.r == f_i)';    % all hypotheses in current frame pair
        Res = [];   % residual w.r.t. hypotheses
        
        if select_visible == 1
            %%% Select points visible on both frames
            visible_pts_ind = Data.visibleSparse(:,f_i) & Data.visibleSparse(:,f_i+1);
        else
            visible_pts_ind = 1:size(Data.ySparse, 2);
        end

        for h_i = mdl_idx
            r = Model.r(h_i);   % first frame
            v = Model.v(h_i);   % second frame

            y1 = Data.ySparse(:,visible_pts_ind,r);
            y2 = Data.ySparse(:,visible_pts_ind,v);

            %% Normalise raw correspondences.
            dat_img_1 = normalise2dpts(y1);
            dat_img_2 = normalise2dpts(y2);
            normalized_data = [dat_img_1 ; dat_img_2];

            %% Calculate Residual
            Res = [Res feval(resfn, Model.H(:,h_i), normalized_data)];
        end

        %% Compute ORK kernel
        [foo, resinx] = sort(Res,2);
        h = round(0.1*size(Res,2));

        K_temp = zeros(Data.nSparsePoints);
        K_ORK = computeIntersection(resinx', resinx', h);
        K_temp(visible_pts_ind, visible_pts_ind) = K_ORK;

        K = K + K_temp;
    end

    %% Save Results
    save(kernel_filepath,'K');

    fprintf('Finish %d-th seq\n',s_i);
end
ret = 1;
end

