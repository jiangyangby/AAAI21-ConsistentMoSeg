function [ CD, AffinityMat, C, D, loss, ClusterIdx, error_rate, ext ] = eval_ClusterFunc( ClusterFunc, Z, nMotion, GtLabel, Params, ext_flag )
    ext = 0;
    if ext_flag == 1
        [CD, AffinityMat, C, D, loss, ext] = ClusterFunc(Z, nMotion, Params);
    else
        [CD, AffinityMat, C, D, loss] = ClusterFunc(Z, nMotion, Params);
    end
    %% Spectral clustering
    AffinityMat(AffinityMat < 1e-5) = 0;
    AffinityMat = thrC(AffinityMat, 0.9);
    ClusterIdx = SpectralClustering_svd(AffinityMat, nMotion, 'normalized');
%     ClusterIdx = SpectralClustering_svd(C, nMotion, 'normalized');
    if isrow(ClusterIdx)
        ClusterIdx = ClusterIdx';
    end
    %% Eval Classification Error Rate
    error_rate = Misclassification(ClusterIdx, GtLabel);
end

