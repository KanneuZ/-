# Датасеты

## Своя съёмка (apartment)
- Исходное видео `apartment.MTS`: <ссылка на Google Drive>
- TUM-датасет (rgb + MiDaS-depth + assoc.txt, ~1.5 ГБ): <вставь ссылку>
- Ground truth: `../gt/apartment_gt.txt`

## TUM RGB-D (скачать самостоятельно)
- fr1_xyz: https://vision.in.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_xyz.tgz
- fr3_walking_xyz: https://vision.in.tum.de/rgbd/dataset/freiburg3/rgbd_dataset_freiburg3_walking_xyz.tgz

Ассоциации генерируются скриптом `../scripts/make_assoc.py` (или вручную по `rgb.txt` / `depth.txt`).

## Replica
- https://github.com/facebookresearch/Replica-Dataset
- Использованные сцены: `office0` (полная и `small`)
