function [ CD, CDmean, C, D, loss ] = ConsistenMoSeg( Z, n_cluster, Params )
% min_{C,D,W} 0.5*||Z-C\odot D||_F^2 + 0.5lambda1*||D||_F^2 +
% lambda2*<Diag(C1)-C,W> + 0.5lambda3*||W||_F^2
% s.t. diag(C)=0, C>=0, C=C^T,
%      0<=W<=I, Tr(W)=k.
    lambda1 = Params(1);
    lambda2 = Params(2);
    lambda3 = Params(3);
    C_max = Params(4);
    D_min = Params(5);
    N = size(Z{1}, 1);
    V = size(Z, 2);
    k = n_cluster;
    tol = 1e-3;
    maxIter = 500;
    eps = 1e-4;

    %% Initialization
    W = eye(N);
    D = cellfun(@(n) zeros(n), {N, N, N}, 'UniformOutput', false);
    C = ones(N);
    C = C - diag(diag(C));

    loss = zeros(maxIter, 1);
    diffC = zeros(maxIter, 1);
    diffD = zeros(maxIter, 1);
    diffW = zeros(maxIter, 1);

    iter = 0;
    while iter < maxIter
        iter = iter + 1;

        % update D
        Dk = D;
        D = cellfun(@(z) (C .* z) ./ (C.^2 + lambda1), Z, 'UniformOutput', false);
        D = cellfun(@(x) max(x, D_min), D, 'UniformOutput', false);

        % update C
        Ck = C;
        S1 = zeros(size(C));
        S2 = zeros(size(C));
        for v = 1:V
            S1 = S1 + D{v}.* Z{v} + (D{v}') .* (Z{v}');
            S2 = S2 + D{v}.^2 + (D{v}').^2;
        end
        tW = diag(W) * ones(1, N) - W;
        tW = tW + tW';
        C  = (S1 - lambda2 * tW) ./ (S2 + eps) ;
        C = max(0, (C+C')/2);
        C = min(C, C_max);
        C = C - diag(diag(C));
        L = CalLaplacian(C);

        % update W
        Wk = W;
        [VV, DD] = eig(L);
        DD = diag(DD);
        [Sigma, ind] = sort(DD,'ascend');
        VV = VV(:, ind);
        if abs(Sigma(k) - Sigma(k+1)) < 1e-6
            Sigma_diff = [Sigma; 1000000] - [0; Sigma];
            p = find(Sigma_diff(1:k) > 0, 1, 'last') - 1;
            if isempty(p)
                p = 0;
            end
            q = find(Sigma_diff(k+1:end) > 0, 1, 'first') + k - 1;
%             delta_p = Sigma_diff(p + 1);
%             delta_q = Sigma_diff(q + 1);
%             if p > 0 && q < N
%                 d_sigma = min(delta_p, delta_q);
%             else
%                 d_sigma = max(delta_p, delta_q);
%             end
            Sigma_alter = [ones(p, 1); ones(q - p, 1) .* (k - p) ./ (q - p)];
            W = VV(:, 1:q) * diag(Sigma_alter) * VV(:, 1:q)';
        else
            W = VV(:,1:k) * VV(:,1:k)';
        end

        % calculate loss
        l1 = 0.5 * sum(cellfun(@(x,y) sumsqr(x-C.*y), Z, D));
        l2 = 0.5 * lambda1 * sumsqr(D);
        l3 = lambda2 * sum(sum(W.*CalLaplacian(C)));
%         l4 = 0.5 * lambda3 * sumsqr(W);
        disp([l1 l2 l3]);
        loss(iter) = l1 + l2 + l3;

        % stopping condition
        diffC(iter) = sumsqr(C - Ck);
        diffW(iter) = sumsqr(W - Wk);
        diffD(iter) = sum(cellfun(@(X,Y) sumsqr(X - Y), D, Dk));
        stopC = max([diffC(iter), diffD(iter)]);
        if stopC < tol
            break;
        end
    end

%     diff.C = diffC;
%     diff.D = diffD;
%     diff.W = diffW;
    CD = cellfun(@(x) C.* x, D, 'UniformOutput', false);
%     CD = cellfun(@(x) (x + x')/2, CD, 'UniformOutput', false);
    CDmean = MergeAdjacentMatrix(CD);
end

function L =  CalLaplacian(C)
    L = diag( C * ones(size(C,2), 1) ) - C;
end

function Zmean =  MergeAdjacentMatrix(Z)
    Zmean = zeros(size(Z{1}));
    for i = 1:numel(Z)
        Zmean  =  Zmean + (abs(Z{i}) + abs(Z{i}'))/2;
    end
%     Zmean = Zmean / numel(Z);
end
