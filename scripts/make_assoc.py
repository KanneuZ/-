import os
from bisect import bisect_left

root = os.path.expanduser("~/datasets/TUM/rgbd_dataset_freiburg3_walking_xyz")

def read_list(fn):
    items = []
    for line in open(os.path.join(root, fn)):
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        t, f = line.split()
        # ВАЖНО: путь ОТНОСИТЕЛЬНЫЙ, без root
        items.append((float(t), f))
    items.sort()
    return items

rgb = read_list("rgb.txt")
depth = read_list("depth.txt")

depth_ts = [d[0] for d in depth]
used = set()
out = []
MAX_DIFF = 0.02

for t, rf in rgb:
    i = bisect_left(depth_ts, t)
    candidates = []
    if i < len(depth):
        candidates.append(depth[i])
    if i > 0:
        candidates.append(depth[i-1])
    if not candidates:
        continue
    dt, df = min(candidates, key=lambda c: abs(c[0] - t))
    if abs(dt - t) > MAX_DIFF:
        continue
    if dt in used:
        continue
    used.add(dt)
    out.append((t, rf, dt, df))

outfile = os.path.join(root, "associations_rel.txt")
with open(outfile, "w") as f:
    for t, rf, dt, df in out:
        f.write(f"{t} {rf} {dt} {df}\n")

print(f"Written {len(out)} associations to {outfile}")
print("First line:", out[0] if out else "none")
