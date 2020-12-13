
clear all;
close all;

datadir = '../../Data/MTPV62/';
DataNames = dir(datadir);
DataNames = DataNames(3:end);  % remove '.' & '..': d(i).isdir ~= 1
seq_cnt = 0;
SeqList = {};
for i = 1:length(DataNames)
    if DataNames(i).isdir ~= 1
        continue
    end
    if strcmp(DataNames(i).name, 'Hopkins50') == 1
        seqnames = dir([datadir DataNames(i).name]);
        seqnames = seqnames(3:end);
        for j = 1:length(seqnames)
            if seqnames(j).isdir ~= 1
                continue
            end
            fname = seqnames(j).name;
            seq_cnt = seq_cnt + 1;
            SeqList{seq_cnt} = [DataNames(i).name '_' fname];
            datai = load(fullfile(datadir, DataNames(i).name, fname, [fname '_truth.mat']));
            Data.GtLabel = datai.s;
            Data.Name = fname;
            Data.ySparse = datai.y;  % unnormalized
            Data.nFrames = datai.frames;
            Data.nSparsePoints = datai.points;
            Data.visibleSparse = ones(datai.points, datai.frames);
            save(fullfile(datadir, [DataNames(i).name '_' fname '_Tracks.mat']), 'Data');
        end
    else
        seqnames = dir([datadir DataNames(i).name]);
        disp([datadir DataNames(i).name]);
        seqnames = seqnames(3:end);
        for j = 1:length(seqnames)
            if strcmp(DataNames(i).name, 'MTPV_data') == 1 && seqnames(j).isdir ~= 1
                continue
            end
            if strcmp(DataNames(i).name, 'PerspectiveNViewsData') == 1 && seqnames(j).name(length(seqnames(j).name) - 1) ~= 'a'
                continue
            end
            seq_cnt = seq_cnt + 1;
            if strcmp(DataNames(i).name, 'MTPV_data') == 1
                fname = seqnames(j).name;
                datai = load(fullfile(datadir, DataNames(i).name, fname, [lower(fname) '_gt.mat']));
            else
                fname = seqnames(j).name(1:length(seqnames(j).name)-4);
                datai = load(fullfile(datadir, DataNames(i).name, seqnames(j).name));
            end
            disp([fname]);
            SeqList{seq_cnt} = [DataNames(i).name '_' fname];
            Data.GtLabel = datai.labels;
            Data.Name = fname;
            Data.nFrames = size(datai.X, 3);
            Data.nSparsePoints = size(datai.X, 1);
            % matrix completion for datai.X (missing data with (sqrt(-1),
            % sqrt(-1))) [for competitors]
%             ms_idx = (sum(imag(pt_frame_f) ~= 0)) > 0;
            X = datai.X;
            X(:, 3, :) = 1;
            X(imag(X(:, :, :)) ~= 0) = 0;
            Data.visibleSparse = ones(Data.nSparsePoints, Data.nFrames);
            for p = 1:Data.nSparsePoints
                for f = 1:Data.nFrames
                    if imag(datai.X(p, 1, f)) ~= 0 && imag(datai.X(p, 2, f)) ~= 0
                        X(p, 3, f) = 0;
                        Data.visibleSparse(p, f) = 0;
                    end
                end
            end
            Data.ySparse = permute(X(:, :, :), [2 1 3]);  % unnormalized
            Data.visibleSparse = logical(Data.visibleSparse);
            save(fullfile(datadir, [DataNames(i).name '_' fname '_Tracks.mat']), 'Data');
        end
    end
end
save(fullfile(datadir, 'SeqList.mat'), 'SeqList');