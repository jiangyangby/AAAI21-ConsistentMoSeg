function [ Hypos ] = gen_Hypo_Seq( Data, model_type, num_frames, FrameGap, ...
    max_NumHypoPerFrame, select_visible )
%% Generate Hypothesis Model For A Sequence
%%% Initialize All Hypotheses
Hypos.H = [];
Hypos.r = [];  % Start Frame
Hypos.v = [];  % End Frame (r + FrameGap)
Hypos.supp = [];

for f_i = 1:num_frames-FrameGap
    
    %% Prepare candidate data
    r = f_i;
    v = r+FrameGap;
    
    if select_visible == 1
        %%% Select points visible on both frames
        visible_pts_ind = Data.visibleSparse(:,f_i) & Data.visibleSparse(:,f_i+1);
    else
        visible_pts_ind = 1:size(Data.ySparse, 2);
    end
    
    y1 = Data.ySparse(:,visible_pts_ind,r);
    y2 = Data.ySparse(:,visible_pts_ind,v);
    
    %% Normalise raw correspondences.
    dat_img_1 = normalise2dpts(y1);
    dat_img_2 = normalise2dpts(y2);
    normalized_data = [ dat_img_1 ; dat_img_2 ];
    
    % Maximum CPU seconds allowed
    lim = 20;
    
    % Storage.
    par = cell(2,1);
    res = cell(2,1);
    inx = cell(2,1);
    tim = cell(2,1);
    hit = cell(2,4);
    met = char('Random','Multi-GS');
    
    % Random sampling.
    [ par{1} res{1} inx{1} tim{1} ] = randomSampling(lim, normalized_data, ...
        max_NumHypoPerFrame, model_type);
    
    % Guided-sampling using the Multi-GS method. (alternative sampling strategy)
%     [ par{2} res{2} inx{2} tim{2} ] = multigsSampling(lim,normalized_data, ...
%         max_NumHypoPerFrame,10,model_type);
    
    %% Accumulate Hypotheses
    Hypos.H = [Hypos.H  par{1}];
    Hypos.r = [Hypos.r ; r*ones(size(par{1},2),1)];
    Hypos.v = [Hypos.v ; v*ones(size(par{1},2),1)];
    Hypos.supp = [Hypos.supp  inx{1}];
end
end