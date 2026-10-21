import os

root = "/mnt/c/Users/Andrey/Desktop/1231324/office0"
out = os.path.join(root, "assoc_replica.txt")

count = 0
with open(out, "w") as f:
    for i in range(2000):
        num = f"{i:06d}"
        rgb = f"results/frame{num}.jpg"
        dep = f"results/depth{num}.png"
        if os.path.exists(os.path.join(root, rgb)) and os.path.exists(os.path.join(root, dep)):
            f.write(f"{i} {rgb} {dep}\n")
            count += 1

print(f"Written {count} associations to {out}")
