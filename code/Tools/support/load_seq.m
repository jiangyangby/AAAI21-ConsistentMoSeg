function [ Data ] = load_seq( Dataset, SeqName )
    filepath = fullfile(['../../Data/' Dataset '/'],[SeqName,'_Tracks.mat']);
    temp = load(filepath);
    Data = temp.Data;
end
