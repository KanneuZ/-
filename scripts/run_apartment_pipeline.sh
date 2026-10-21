#!/usr/bin/env bash
set -e

# ====== НАСТРОЙКИ (поправь под себя) ======
VIDEO="/mnt/c/Users/Andrey/Desktop/apart/apartment.MTS"
OUT_DIR="$HOME/datasets/apartment_midas"
YAML_SRC="$HOME/dpvo_wsl/NGD-SLAM/Examples/RGB-D/Replica_office0_small.yaml"
YAML_DST="$HOME/datasets/apartment_midas.yaml"
NGD_DIR="$HOME/dpvo_wsl/NGD-SLAM"
FPS=5
# =========================================

mkdir -p "$OUT_DIR"
mkdir -p "$(dirname "$YAML_DST")"

# --- 1. Пишем Python-скрипт ---
cat > /tmp/mts_to_tum_midas.py << 'PYEOF'
import argparse, os, cv2, torch, numpy as np

ap = argparse.ArgumentParser()
ap.add_argument("--video", required=True)
ap.add_argument("--out", required=True)
ap.add_argument("--fps", type=float, default=5.0)
args = ap.parse_args()

rgb_dir = os.path.join(args.out, "rgb")
depth_dir = os.path.join(args.out, "depth")
os.makedirs(rgb_dir, exist_ok=True)
os.makedirs(depth_dir, exist_ok=True)

print("Loading MiDaS...")
midas = torch.hub.load("intel-isl/MiDaS", "MiDaS_small", trust_repo=True)
midas.eval()
if torch.cuda.is_available():
    midas = midas.cuda()
    print("Using CUDA")
transform = torch.hub.load("intel-isl/MiDaS", "transforms", trust_repo=True).small_transform

cap = cv2.VideoCapture(args.video)
if not cap.isOpened():
    raise SystemExit(f"Cannot open: {args.video}")
src_fps = cap.get(cv2.CAP_PROP_FPS) or 30.0
step = max(1, round(src_fps / args.fps))
print(f"Source FPS: {src_fps:.1f}, step: {step}")

assoc = []
idx = 0
frame_i = 0
while True:
    ok, frame = cap.read()
    if not ok:
        break
    if frame_i % step != 0:
        frame_i += 1
        continue
    frame_i += 1

    img_rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    inp = transform(img_rgb)
    if torch.cuda.is_available():
        inp = inp.cuda()
    with torch.no_grad():
        pred = midas(inp)
        pred = torch.nn.functional.interpolate(
            pred.unsqueeze(1), size=img_rgb.shape[:2],
            mode="bicubic", align_corners=False
        ).squeeze()
    depth = pred.cpu().numpy()
    depth = depth.max() - depth
    depth_norm = (depth / (depth.max() + 1e-9) * 65535.0).astype(np.uint16)

    ts = idx / args.fps
    rn = f"frame{idx:06d}.png"
    dn = f"depth{idx:06d}.png"
    cv2.imwrite(os.path.join(rgb_dir, rn), frame)
    cv2.imwrite(os.path.join(depth_dir, dn), depth_norm)
    assoc.append(f"{ts:.6f} rgb/{rn} {ts:.6f} depth/{dn}\n")
    idx += 1
    if idx % 10 == 0:
        print(f"  processed {idx} frames...")

cap.release()
with open(os.path.join(args.out, "assoc.txt"), "w") as f:
    f.writelines(assoc)
print(f"Done. {idx} frames -> {args.out}")
PYEOF

# --- 2. Запускаем конвертацию ---
echo "=== Converting video to TUM dataset (MiDaS) ==="
python3 /tmp/mts_to_tum_midas.py --video "$VIDEO" --out "$OUT_DIR" --fps "$FPS"

# --- 3. Готовим yaml ---
echo "=== Preparing yaml ==="
cp "$YAML_SRC" "$YAML_DST"
sed -i "s/fx: 320/fx: 1000/; s/fy: 320/fy: 1000/; s/cx: 319.7/cx: 960/; s/cy: 181.1/cy: 540/; s/ThDepth: 2/ThDepth: 35.0/" "$YAML_DST"
# DepthMapFactor -> 6553.5
sed -i 's/^DepthMapFactor:.*/DepthMapFactor: 6553.5/' "$YAML_DST"

# --- 4. Запускаем NGD-SLAM ---
echo "=== Running NGD-SLAM ==="
cd "$NGD_DIR"
export LIBGL_ALWAYS_SOFTWARE=1
./Examples/RGB-D/rgbd_tum \
  ./Vocabulary/ORBvoc.txt \
  "$YAML_DST" \
  "$OUT_DIR" \
  "$OUT_DIR/assoc.txt" \
  2>&1 | tee "$HOME/ngd_apartment_midas.log"

echo "=== Done ==="
echo "Trajectory should be in: $NGD_DIR/CameraTrajectory.txt or KeyFrameTrajectory.txt"
echo "Compare with GT:"
echo "  evo_ape tum $HOME/apartment_gt.txt <trajectory> --align --correct_scale -va --plot"
