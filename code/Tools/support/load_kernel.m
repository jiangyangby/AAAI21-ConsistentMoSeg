function [ K ] = load_kernel( kernel_type, Dataset, SeqName, max_NumHypoPerFrame )
    save_path = fullfile(['../../Results/' Dataset '/Kernels/'], kernel_type);
    kernel_filepath = fullfile(save_path,sprintf('ORK_RandomSamp_Sparse_seq-%s_nhypoframe-%d.mat',...
        SeqName,max_NumHypoPerFrame));
    temp = load(kernel_filepath);
    K = temp.K;
end
