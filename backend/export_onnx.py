import os
import sys
import torch
sys.stdout.reconfigure(encoding='utf-8')
sys.stderr.reconfigure(encoding='utf-8')
from custom_decoder import RRDBNet

def export_to_onnx():
    print("Loading PyTorch Custom Decoder...", flush=True)
    model = RRDBNet()
    ckpt_path = r"c:\Users\TONY\Development\fractal\models\my_custom_sr_decoder_epoch5.pth"
    
    if not os.path.exists(ckpt_path):
        print(f"Error: Could not find {ckpt_path}", flush=True)
        return
        
    ckpt = torch.load(ckpt_path, map_location='cpu', weights_only=False)
    model.load_state_dict(ckpt, strict=True)
    model.eval()

    # We must construct a dummy input for tracing the ONNX graph.
    dummy_input = torch.randn(1, 3, 256, 256)

    out_path = r"c:\Users\TONY\Development\fractal\models\custom_decoder.onnx"
    print(f"Exporting to Universal ONNX at {out_path}...", flush=True)

    # Exporting with completely dynamic dimensions so any image works!
    torch.onnx.export(
        model, 
        dummy_input, 
        out_path, 
        opset_version=14,
        input_names=['input'], 
        output_names=['output'],
        dynamic_axes={
            'input': {0: 'batch_size', 2: 'height', 3: 'width'},
            'output': {0: 'batch_size', 2: 'height', 3: 'width'}
        }
    )
    print("ONNX Mathematical Graph Export Successful!", flush=True)

if __name__ == "__main__":
    export_to_onnx()
