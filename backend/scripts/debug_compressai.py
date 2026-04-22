import traceback
try:
    from compressai.models import Cheng2020Attention
    print("Cheng2020Attention: OK")
except Exception as e:
    print(f"FAIL: {e}")
    traceback.print_exc()

try:
    from compressai.ops import compute_padding
    print("compute_padding: OK")
except Exception as e:
    print(f"FAIL compute_padding: {e}")
    traceback.print_exc()
