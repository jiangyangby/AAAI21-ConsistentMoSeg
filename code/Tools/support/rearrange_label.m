gt_path = 'C:\Users\75781\Desktop\Group_Work\BangYan\bangyan_aaai21\KT3DMoSeg\KT3DMoSeg\';
gt_name1 = 'Seq028_Clip02_Tracks';
gt_name2 = 'Seq038_Clip01_Tracks'
gt_name3 = 'Seq059_Clip01_Tracks'

tmp1 = load([gt_path gt_name1 '.mat']);
tmp2 = load([gt_path gt_name2 '.mat']);
tmp3 = load([gt_path gt_name3 '.mat']);

gt_data1 = tmp1.Data;
gt_data2 = tmp2.Data;
gt_data3 = tmp3.Data;

seq_id1 = 11;
seq_id2 = 14;
seq_id3 = 17;

ours_path = 'C:\Users\75781\Desktop\Group_Work\BangYan\bangyan_aaai21\KT3DMoSeg\Ours\';
ours_name = 'Error_RandSamp_nhpf-500_alpha-5_lamda1-0.0010_lamda2-0.0100_SM2C_S';
tmp = load([ours_path ours_name '.mat']);
ours_data = tmp;

subset_path = 'C:\Users\75781\Desktop\Group_Work\BangYan\bangyan_aaai21\KT3DMoSeg\Subset\';
subset_name = 'Error_RandSamp_nhpf-500_alpha-10_gamma-0.01';
tmp = load([subset_path subset_name  '.mat']);
subset_data = tmp;

[~,index] = missclassGroups(ours_data.ClusterIdx{seq_id1}, gt_data1.GtLabel, max(gt_data1.GtLabel));
ours_data.ClusterIdx{seq_id1} = index(ours_data.ClusterIdx{seq_id1})';

[~,index] = missclassGroups(subset_data.ClusterIdx{seq_id1}, gt_data1.GtLabel, max(gt_data1.GtLabel));
subset_data.ClusterIdx{seq_id1} = index(subset_data.ClusterIdx{seq_id1})';

[~,index] = missclassGroups(ours_data.ClusterIdx{seq_id2}, gt_data2.GtLabel, max(gt_data2.GtLabel));
ours_data.ClusterIdx{seq_id2} = index(ours_data.ClusterIdx{seq_id2})';

[~,index] = missclassGroups(subset_data.ClusterIdx{seq_id2}, gt_data2.GtLabel, max(gt_data2.GtLabel));
subset_data.ClusterIdx{seq_id2} = index(subset_data.ClusterIdx{seq_id2})';

[~,index] = missclassGroups(ours_data.ClusterIdx{seq_id3}, gt_data3.GtLabel, max(gt_data3.GtLabel));
ours_data.ClusterIdx{seq_id3} = index(ours_data.ClusterIdx{seq_id3})';
ClusterIdx = ours_data.ClusterIdx;
error = ours_data.error;
save([ours_path ours_name '-perm.mat'], 'ClusterIdx', 'error');

[~,index] = missclassGroups(subset_data.ClusterIdx{seq_id3}, gt_data3.GtLabel, max(gt_data3.GtLabel));
subset_data.ClusterIdx{seq_id3} = index(subset_data.ClusterIdx{seq_id3})';
ClusterIdx = subset_data.ClusterIdx;
error = subset_data.error;
save([subset_path subset_name '-perm.mat'], 'ClusterIdx', 'error');
