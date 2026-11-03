cat > ~/ngd-slam-repo/README.md << 'EOF'
# NGD-SLAM & DPVO: Исследование алгоритмов SLAM

Репозиторий содержит пайплайн запуска, конфигурации и **полные результаты тестирования** двух алгоритмов SLAM:
1. **NGD-SLAM** (RGB-D, использует YOLO и метрическую глубину).
2. **DPVO** (Монокулярный, использует только RGB).

Тестирование проводилось на эталонных датасетах **TUM RGB-D** и **Replica**, а также на собственной съёмке (`apartment`).

---

## 📂 Структура репозитория

- `configs/` — YAML-конфиги камер для NGD-SLAM.
- `scripts/` — вспомогательные скрипты (нарезка видео, генерация глубины MiDaS, создание ассоциаций).
- `gt/` — исходные файлы Ground Truth для некоторых сцен.
- `datasets/` — содержит `README.md` со ссылками на скачивание данных (сами данные не хранятся в Git из-за размера).
- **`results/` — ГЛАВНАЯ ПАПКА С РЕЗУЛЬТАТАМИ.**
  - Внутри разложены папки по сценам (`TUM_fr1_xyz`, `TUM_fr2_xyz`, `TUM_fr3_walking_xyz`, `Replica_office0_small`, `Replica_room1`, `apartment`).
  - В каждой папке лежат: исходные траектории, графики (`plot_all.png` и др.) и `README.md` с метриками.
  - В корне папки `results` есть сводный `README.md` с общей таблицей и анализом.

---

## 📊 Краткие итоги (ATE RMSE, метры)

| Сцена | Источник | NGD-SLAM (RGB-D) | DPVO (Монокуляр) | Вывод |
|---|---|---|---|---|
| **TUM fr1_xyz** | [TUM](https://vision.in.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_xyz.tgz) | **0.0108** | 0.1292 | NGD точнее в 12 раз |
| **TUM fr2_xyz** | [TUM](https://vision.in.tum.de/rgbd/dataset/freiburg2/rgbd_dataset_freiburg2_xyz.tgz) | 0.3650 | **0.0418** | DPVO точнее (YOLO ошибся) |
| **TUM fr3_walking_xyz** | [TUM](https://vision.in.tum.de/rgbd/dataset/freiburg3/rgbd_dataset_freiburg3_walking_xyz.tgz) | **0.0156** | 0.0909 | NGD отфильтровал людей |
| **Replica office0_small** | [Replica](https://github.com/facebookresearch/Replica-Dataset) | 0.7943 | **0.7198** | DPVO чуть точнее |
| **Replica room1** | [Replica](https://github.com/facebookresearch/Replica-Dataset) | 0.8233 | **0.5617** | DPVO точнее |
| **apartment** (своя) | Собственная съёмка | — (упал) | 2.9065 | NGD упал (MiDaS), DPVO построил |

---

## 🚀 Запуск NGD-SLAM

*(Команды запускаются из папки NGD-SLAM)*

### TUM fr1_xyz
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt ./Examples/RGB-D/TUM1.yaml <dataset>/fr1_xyz <dataset>/fr1_xyz/assoc.txt

### TUM fr3_walking_xyz
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt ./Examples/RGB-D/TUM3.yaml <dataset>/fr3_walking_xyz <dataset>/fr3_walking_xyz/assoc.txt

### TUM fr2_xyz
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt ./Examples/RGB-D/TUM2.yaml <dataset>/fr2_xyz <dataset>/fr2_xyz/assoc.txt

### Replica room1
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt configs/Replica_office0.yaml <dataset>/replica_room1 <dataset>/replica_room1/assoc4.txt

### Replica office0_small
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt configs/Replica_office0_small.yaml <dataset>/replica_office0_small <dataset>/replica_office0_small/assoc4.txt

### apartment (своя съёмка)
python3 scripts/run_apartment_pipeline.sh
./Examples/RGB-D/rgbd_tum ./Vocabulary/ORBvoc.txt configs/apartment_midas.yaml <dataset>/apartment <dataset>/apartment/assoc.txt

---

## 📝 Основные выводы
1. **NGD-SLAM** показывает наилучшую точность (до 1 см) на сценах с **метрической глубиной** и **динамическими объектами** (людьми), так как использует YOLO.
2. **DPVO** (без глубины) ошибается сильнее на реальных данных, но показывает стабильные результаты на синтетике (Replica).
3. На сцене `TUM fr2` NGD-SLAM ошибся из-за **ложного срабатывания YOLO** на статичных объектах (принял мебель за человека).
4. На собственной съёмке (`apartment`) **NGD-SLAM упал** из-за отсутствия метрической глубины (MiDaS не подходит). **DPVO** построил траекторию, но ошибка высока (2.9 м) из-за разворота камеры и зеркал.
EOF
