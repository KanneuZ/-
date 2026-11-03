# Структура репозитория:

## configs/
- `Replica_office0.yaml` — Replica room1 (1200x680, fx=fy=600, cx=599.5, cy=339.5)
- `Replica_office0_small.yaml` — Replica office0_small (640x360)
- `apartment_midas.yaml` — своя съёмка apartment (1920x1080, fx=fy=1000, cx=960, cy=540)

## scripts/
- `run_apartment_pipeline.sh` — видео → кадры → MiDaS-глубина → TUM-датасет → NGD-SLAM
- `make_assoc.py` — генерация assoc.txt для TUM-датасетов (по rgb.txt/depth.txt)
- `make_assoc_replica.py` — генерация assoc4.txt для Replica
- `replica_to_tum.py` — конвертер сырого рендера Replica в TUM-формат

## gt/
- `apartment_gt.txt` — GT для своей съёмки (timestamp tx ty tz qx qy qz qw)
- `fr1_xyz_gt.txt` — GT TUM fr1_xyz
- `fr3_walking_xyz_gt.txt` — GT TUM fr3_walking_xyz
- `replica_room1_gt.txt` — GT Replica room1 (матрица 4x4)
- `replica_room1_gt_tum.txt` — GT Replica room1, TUM-формат
- `replica_room1_gt_tum_shifted.txt` — то же, сдвинуто под таймстампы SLAM

## results/
Директории с результатами: 
- `apartment/`
- `Replica_office0_small/`
- `Replica_room1/`
- `TUM_fr1_xyz/`
- `TUM_fr2_xyz/`
- `TUM_fr3_walking_xyz/`
- `README.md` — краткий вывод того, что получилось

## datasets/
- `README.md` — ссылки на скачивание (TUM, Replica, apartment). Сами данные не в репозитории.
