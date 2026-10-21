import os, glob, shutil, sys

src = sys.argv[1]
out = sys.argv[2]

rgb_files = sorted(glob.glob(os.path.join(src, "frame*.jpg")) +
                   glob.glob(os.path.join(src, "frame*.png")))
depth_files = sorted(glob.glob(os.path.join(src, "depth*.png")))
print(f"RGB: {len(rgb_files)}, Depth: {len(depth_files)}")
if not rgb_files or not depth_files:
    sys.exit("Не нашёл кадры. Проверь структуру.")

os.makedirs(os.path.join(out, "rgb"), exist_ok=True)
os.makedirs(os.path.join(out, "depth"), exist_ok=True)

n = min(len(rgb_files), len(depth_files))
with open(os.path.join(out, "assoc4.txt"), "w") as f:
    for i in range(n):
        r, d = rgb_files[i], depth_files[i]
        rn = f"frame{i:06d}" + os.path.splitext(r)[1]
        dn = f"depth{i:06d}.png"
        shutil.copy(r, os.path.join(out, "rgb", rn))
        shutil.copy(d, os.path.join(out, "depth", dn))
        f.write(f"{float(i)} rgb/{rn} {float(i)} depth/{dn}\n")
print(f"Written {n} frames to {out}")
