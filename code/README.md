# AAAI21-ConsistentMoSeg
Matlab implementation for AAAI 2021 paper `What to Select: Pursuing Consistent Motion Segmentation from Multiple Geometric Models`.

## Acknowledge
The implementation is based on [Subset model](https://github.com/alex-xun-xu/MultiViewMoSeg). We sincerely thank the authors for their work.

## Data
Original data can be found in [Hopkins155/Hopkins12](http://www.vision.jhu.edu/data/), [MTPV62](http://pami.xmu.edu.cn/∼wlzhao), [KT3DMoSeg](https://github.com/alex-xun-xu/MultiViewMoSeg).

We provide a reformatted version in `Data/` according to `KT3DMoSeg` dataset. Please unzip the compressed files before run the codes.

## Run
Uncomment corresponding `Dataset`, `select_visible`, `Params` for different datasets in the following codes and then run them.
- Run hypotheses generation code for each geometric model: `./script/Hypo/script_AHF_Hypo_RandSamp.m`
- Run ORK kernel computing code: `./script/Kernel/script_AHF_ORK_RandSamp.m`
- Run single-view (`script_X_MoSeg_RandSamp.m`, where X is Affine/Homography/Fundamental) or multi-view (`script_AHF_X_RandSamp.m`, where X is `KerAdd/CoReg/Subset/ConsistenMoSeg`) motion segmentation under `./script/MoSeg/`


## Citation
Please cite our paper if you use our code in your own work:

```
@inproceedings{jiang2021consistentmoseg,
  title={What to Select: Pursuing Consistent Motion Segmentation from Multiple Geometric Models},
  author={Jiang, Yangbangyan and Xu, Qianqian and Ke, Ma and Yang, Zhiyong and Cao, Xiaochun and Huang, Qingming},
  booktitle={AAAI Conference on Artificial Intelligence},
  year={2021}
}
```
