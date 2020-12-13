function [ ret ] = gen_Hypo_Dataset( Dataset, model_type, FrameGap, max_NumHypoPerFrame, select_visible )
%% Sample Hypothesis for a Dataset (many sequences)
%% Load Seq Information
temp = load(['../../Data/' Dataset '/SeqList.mat']);
SeqList = temp.SeqList;

for s_i = 1:length(SeqList)
    SeqName = SeqList{s_i}; % sequence name

    %%% Load Ground-Truth Data
    Data = load_seq(Dataset, SeqName);
    num_frames = Data.nFrames;

    %%% Save Path for hypotheses
    save_path = fullfile(['../../Results/' Dataset '/Hypotheses/'], model_type);
    if ~exist(save_path, 'dir')
        mkdir(save_path);
    end

    hypo_filepath = fullfile(save_path, ...
        sprintf('Hypo_RandSamp_Sparse_seq-%s_nHypo-%d.mat',SeqName,max_NumHypoPerFrame));

    Hypos = gen_Hypo_Seq(Data, model_type, num_frames, FrameGap, max_NumHypoPerFrame, select_visible);

    %% Save Hypotheses
    save(hypo_filepath, 'Hypos');

    fprintf('Finish %s %d-th seq\n', Dataset, s_i);
end
ret = 1;
end

