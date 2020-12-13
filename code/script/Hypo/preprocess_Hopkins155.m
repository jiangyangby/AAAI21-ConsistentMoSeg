
clear all;
close all;

% datadir = '../../Data/Hopkins155/';
datadir = '../../Data/Hopkins12/';
model_type = 'SM2C';
% SeqList = dir(datadir);
% SeqList = SeqList(3:end);  % remove '.' & '..': d(i).isdir ~= 1
load(fullfile(datadir, 'SeqNames.mat'));

%% load the data
% for i = 1:length(MotionAllSeqList)  % Hopkins155
%     fname = strtrim(MotionAllSeqList(i, :));  % Hopkins155
for i = 1:length(SeqNames)  % Hopkins12
    fname = strtrim(SeqNames{i});  % Hopkins12
    datai = load(fullfile(datadir, fname, [fname '_truth.mat']));
%     Data = struct('ySparse',[], 'Name',[], 'GtLabel',[], 'nFrames',{});
    Data.GtLabel = datai.s;
    Data.Name = fname;
    Data.ySparse = datai.y;  % unnormalized
    Data.nFrames = datai.frames;
    Data.nSparsePoints = datai.points;
    save(fullfile(datadir, [fname '_Tracks.mat']), 'Data');
%     data(i).X = reshape(permute(datai.x(1:2,:,:),[1 3 2]),2*datai.frames,datai.points);  % SSC
end
