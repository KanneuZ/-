# NGD-SLAM: структура репозитория

## configs/
- Replica_office0.yaml — Replica room1 (1200x680, fx=fy=600, cx=599.5, cy=339.5)
- Replica_office0_small.yaml — Replica office0_small (640x360)
- apartment_midas.yaml — своя съёмка apartment (1920x1080, fx=fy=1000, cx=960, cy=540)

## scripts/
- run_apartment_pipeline.sh — видео -> кадры -> MiDaS-глубина -> TUM-датасет -> NGD-SLAM
- make_assoc.py — генерация assoc.txt для TUM-датасетов (по rgb.txt/depth.txt)
- make_assoc_replica.py — генерация assoc4.txt для Replica
- replica_to_tum.py — конвертер сырого рендера Replica (results/) в TUM-формат (rgb/, depth/, assoc4.txt)

## gt/
- apartment_gt.txt — GT для своей съёмки (timestamp tx ty tz qx qy qz qw)
- fr1_xyz_gt.txt — GT TUM fr1_xyz
- fr3_walking_xyz_gt.txt — GT TUM fr3_walking_xyz
- replica_room1_gt.txt — GT Replica room1 (матрица 4x4)
- replica_room1_gt_tum.txt — GT Replica room1, конвертирован в TUM-формат
- replica_room1_gt_tum_shifted.txt — то же, сдвинуто под таймстампы SLAM

## results/
- ngd_*.log — логи запусков NGD-SLAM
- traj_*.txt — траектории (CameraTrajectory.txt)
- kf_*.txt — keyframe-траектории (KeyFrameTrajectory.txt)
- evo_ape_*.txt — метрики ATE (вывод evo_ape tum --align)

## datasets/
- README.md — ссылки на скачивание (TUM, Replica, apartment). Сами данные не в репозитории.

## Запуск

TUM fr1_xyz:
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt ./Examples/RGB-D/TUM1.yaml <dataset>/fr1_xyz <dataset>/fr1_xyz/assoc.txt

TUM fr3_walking_xyz:
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt ./Examples/RGB-D/TUM3.yaml <dataset>/fr3_walking_xyz <dataset>/fr3_walking_xyz/assoc.txt

TUM fr2_xyz:
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt ./Examples/RGB-D/TUM2.yaml <dataset>/fr2_xyz <dataset>/fr2_xyz/assoc.txt

Replica room1:
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt configs/Replica_office0.yaml <dataset>/replica_room1 <dataset>/replica_room1/assoc4.txt

Replica office0_small:
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt configs/Replica_office0_small.yaml <dataset>/replica_office0_small <dataset>/replica_office0_small/assoc4.txt

apartment:
python3 scripts/run_apartment_pipeline.sh
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt configs/apartment_midas.yaml <dataset>/apartment <dataset>/apartment/assoc.txt

## Метрики (evo_ape tum --align)

Датасет | Кадров | Синхр. | ATE RMSE (м) | Файл
TUM fr1_xyz | 798 | 798/798 | 0.0108 | results/evo_ape_fr1_xyz.txt
TUM fr3_walking_xyz | 827 | 827/827 | 0.0156 | results/evo_ape_fr3_walking_xyz.txt
TUM fr2_xyz | 3665 | 124/2000 | 0.365 | results/evo_ape_fr2_xyz.txt
Replica room1 | 2000 | — | — | (перезапуск)
Replica office0_small | 2000 | — | — | (перезапуск)
apartment | 341 | — | — | упал на кадре 9 (MiDaS)
