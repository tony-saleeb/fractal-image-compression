import torch
m = torch.load('models/finetuned_cheng2020_q2.pth', map_location='cpu')
print("Type:", type(m))
if isinstance(m, dict):
    print("Top-level keys:", list(m.keys())[:10])
    sd = m.get('state_dict', m.get('model_state_dict', m))
else:
    sd = m
keys = list(sd.keys())
print(f"State dict: {len(keys)} keys")
print("First 25 keys:")
for k in keys[:25]:
    print(f"  {k:60s}  {sd[k].shape}")
