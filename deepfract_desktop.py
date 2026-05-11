"""
DeepFract Desktop — Neural Fractal Image Compression
Premium desktop client with Flet UI connected to cloud backend.
Modern Async Implementation for Flet 0.85+
"""

import os, sys, io, time, asyncio, base64
import flet as ft
from PIL import Image
Image.MAX_IMAGE_PIXELS = None
import httpx # Using httpx for async API calls

API_URL = "https://tony-saleeb-deepfract-api.hf.space"
VERSION = "2.0.1"

def resource_path(rel):
    return os.path.join(getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__))), rel)

def human_size(n):
    return (f"{n} B" if n < 1024 else
            f"{n/1024:.1f} KB" if n < 1024**2 else
            f"{n/1024**2:.1f} MB")

# ── API (Async) ──────────────────────────────────────────────────
async def api_health():
    async with httpx.AsyncClient() as client:
        try:
            r = await client.get(f"{API_URL}/health", timeout=10)
            return r.json().get('status') == 'ok'
        except: return False

async def api_compress(path):
    async with httpx.AsyncClient(timeout=3600) as client:
        with open(path, 'rb') as f:
            data = f.read()
        files = {'image': (os.path.basename(path), data, 'application/octet-stream')}
        t0 = time.perf_counter()
        r = await client.post(f"{API_URL}/compress", files=files)
        r.raise_for_status()
        wall = time.perf_counter() - t0
        h = r.headers
        return r.content, {
            'original_size': len(data), 'compressed_size': len(r.content),
            'ratio': float(h.get('X-Ratio', '0')),
            'psnr': float(h.get('X-PSNR', '0')),
            'rmse': float(h.get('X-RMSE', '0')),
            'time': float(h.get('X-Time', str(wall))),
        }

async def api_decompress(path):
    async with httpx.AsyncClient(timeout=3600) as client:
        with open(path, 'rb') as f:
            data = f.read()
        files = {'fic': (os.path.basename(path), data, 'application/octet-stream')}
        t0 = time.perf_counter()
        r = await client.post(f"{API_URL}/decompress", files=files)
        r.raise_for_status()
        wall = time.perf_counter() - t0
        img = Image.open(io.BytesIO(r.content)).convert('RGB')
        h = r.headers
        return img, r.content, {
            'fic_size': len(data), 'output_size': len(r.content),
            'width': img.size[0], 'height': img.size[1],
            'psnr': float(h.get('X-PSNR', '0')),
            'rmse': float(h.get('X-RMSE', '0')),
            'time': float(h.get('X-Time', str(wall))),
        }

# ── Colors ───────────────────────────────────────────────────────
C = {
    "bg": "#0a0a0f", "sidebar": "#0e1117", "surface": "#161b22",
    "border": "#21262d", "primary": "#3b82f6", "primary_light": "#60a5fa",
    "success": "#22c55e", "error": "#ef4444", "warning": "#f59e0b", "cyan": "#06b6d4",
    "text": "#e6edf3", "text_sec": "#b1bac4", "text_muted": "#7d8590", "text_dim": "#484f58",
}

def img_to_b64(img_or_bytes, max_sz=900):
    if isinstance(img_or_bytes, bytes):
        img = Image.open(io.BytesIO(img_or_bytes))
    else:
        img = img_or_bytes
    img.thumbnail((max_sz, max_sz), Image.LANCZOS)
    buf = io.BytesIO()
    img.save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()


async def main(page: ft.Page):
    page.title = "DeepFract"
    page.theme_mode = ft.ThemeMode.DARK
    page.bgcolor = C["bg"]
    page.padding = 0
    page.spacing = 0
    page.window.width = 1300
    page.window.height = 850
    page.window.min_width = 1000
    page.window.min_height = 700

    state = {"mode": "compress", "busy": False,
            "fic_bytes": None, "png_bytes": None, "result_img": None}

    # FilePicker is a service in 0.85+, no need to add to overlay
    file_picker = ft.FilePicker()

    # ── Sidebar & Logo ───────────────────────────────────────────
    logo_src = None
    logo_widget = ft.Container(width=0)
    for p in [resource_path(os.path.join('assets', 'logo.png')),
            os.path.join('frontend', 'assets', 'images', 'logo.png')]:
        if os.path.exists(p):
            try:
                logo_src = f"data:image/png;base64,{img_to_b64(Image.open(p), 120)}"
                logo_widget = ft.Image(src=logo_src, width=36, height=36)
            except: pass
            break

    nav_compress = ft.Container(
        content=ft.Row([
            ft.Icon(ft.Icons.COMPRESS_ROUNDED, color=C["primary_light"], size=20),
            ft.Text("Compress Image", size=14, weight=ft.FontWeight.W_600, color=C["primary_light"]),
        ], spacing=12),
        padding=ft.Padding(20, 14, 20, 14), border_radius=10, bgcolor=C["surface"],
        on_click=lambda _: set_mode("compress"),
    )
    nav_decompress = ft.Container(
        content=ft.Row([
            ft.Icon(ft.Icons.ZOOM_OUT_MAP_ROUNDED, color=C["text_muted"], size=20),
            ft.Text("Decompress FIC", size=14, weight=ft.FontWeight.W_600, color=C["text_muted"]),
        ], spacing=12),
        padding=ft.Padding(20, 14, 20, 14), border_radius=10, bgcolor="transparent",
        on_click=lambda _: set_mode("decompress"),
    )

    api_dot = ft.Container(width=8, height=8, border_radius=4, bgcolor=C["warning"])
    api_label = ft.Text("Connecting…", size=12, weight=ft.FontWeight.W_600, color=C["text_muted"])

    sidebar = ft.Container(
        content=ft.Column([
            ft.Container(
                content=ft.Row([
                    logo_widget,
                    ft.Column([
                        ft.Text("DeepFract", size=20, weight=ft.FontWeight.W_700, color=C["primary_light"]),
                        ft.Text("W O R K S P A C E", size=9, weight=ft.FontWeight.W_800,
                                color=C["text_dim"], style=ft.TextStyle(letter_spacing=2)),
                    ], spacing=2),
                ], spacing=14),
                padding=ft.Padding(24, 32, 24, 28),
            ),
            ft.Container(height=1, bgcolor=C["border"], margin=ft.Margin(20, 0, 20, 0)),
            ft.Container(
                content=ft.Column([nav_compress, nav_decompress], spacing=6),
                padding=ft.Padding(16, 20, 16, 0),
            ),
            ft.Container(expand=True),
            ft.Container(height=1, bgcolor=C["border"], margin=ft.Margin(20, 0, 20, 0)),
            ft.Container(
                content=ft.Row([api_dot, api_label], spacing=10),
                padding=ft.Padding(24, 16, 24, 8),
            ),
            ft.Container(
                content=ft.Text(f"v{VERSION}", size=11, color=C["text_dim"]),
                padding=ft.Padding(24, 0, 0, 20),
            ),
        ], spacing=0),
        width=260, bgcolor=C["sidebar"],
        border=ft.Border(right=ft.BorderSide(1, C["border"])),
    )

    # ── Workspace ────────────────────────────────────────────────
    ws_title = ft.Text("Compress Image", size=26, weight=ft.FontWeight.W_800, color=C["text"])
    ws_subtitle = ft.Text("Neural Encoding · Select an image to begin",
                        size=13, color=C["text_muted"], weight=ft.FontWeight.W_500)

    def _make_dropzone():
        icon = ft.Icons.CLOUD_UPLOAD_OUTLINED if state["mode"] == "compress" else ft.Icons.FILE_OPEN_OUTLINED
        hint = "JPG · PNG · WebP — No size limit" if state["mode"] == "compress" else "DeepFract Format (.fic)"
        return ft.Column(
            controls=[
                ft.Icon(icon, color=C["primary"], size=56),
                ft.Container(height=8),
                ft.Text("Click to select a file", size=17, weight=ft.FontWeight.W_600, color=C["text_sec"]),
                ft.Text("or use Ctrl+O", size=13, color=C["text_dim"]),
                ft.Container(height=12),
                ft.Text(hint, size=11, color=C["text_dim"], weight=ft.FontWeight.W_600),
            ],
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            alignment=ft.MainAxisAlignment.CENTER, spacing=4,
        )

    preview_card = ft.Container(
        content=_make_dropzone(),
        bgcolor=C["surface"], border=ft.Border(ft.BorderSide(1, C["border"]), ft.BorderSide(1, C["border"]), ft.BorderSide(1, C["border"]), ft.BorderSide(1, C["border"])),
        border_radius=16, expand=True, alignment=ft.Alignment(0, 0),
        on_click=lambda _: page.run_task(select_file),
    )

    def _make_stat(label, icon):
        return ft.Container(
            content=ft.Column([
                ft.Row([ft.Icon(icon, color=C["text_dim"], size=13),
                        ft.Text(label, size=9, color=C["text_dim"], weight=ft.FontWeight.W_800, style=ft.TextStyle(letter_spacing=1.5))],
                    spacing=5),
                ft.Text("—", size=20, weight=ft.FontWeight.W_700, color=C["text_sec"]),
            ], spacing=6, horizontal_alignment=ft.CrossAxisAlignment.CENTER),
            bgcolor=C["surface"], border=ft.Border(ft.BorderSide(1, C["border"]), ft.BorderSide(1, C["border"]), ft.BorderSide(1, C["border"]), ft.BorderSide(1, C["border"])),
            border_radius=12, padding=ft.Padding(16, 14, 16, 14), expand=True,
        )

    stat_ratio = _make_stat("RATIO", ft.Icons.COMPARE_ARROWS_ROUNDED)
    stat_psnr  = _make_stat("PSNR", ft.Icons.INSIGHTS_ROUNDED); stat_psnr.visible = False
    stat_rmse  = _make_stat("RMSE", ft.Icons.TRENDING_DOWN_ROUNDED); stat_rmse.visible = False
    stat_size  = _make_stat("SIZE", ft.Icons.STORAGE_ROUNDED)
    stat_time  = _make_stat("TIME", ft.Icons.TIMER_ROUNDED)

    btn_select = ft.Button(
        content=ft.Text("Select File"), icon=ft.Icons.FOLDER_OPEN_ROUNDED,
        bgcolor=C["primary"], color="#ffffff",
        style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=10), padding=ft.Padding(28, 18, 28, 18)),
        on_click=lambda _: page.run_task(select_file),
    )
    btn_save = ft.Button(
        content=ft.Text("Save Result"), icon=ft.Icons.SAVE_ALT_ROUNDED,
        bgcolor=C["success"], color="#ffffff",
        style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=10), padding=ft.Padding(28, 18, 28, 18)),
        on_click=lambda _: page.run_task(save_result), visible=False,
    )
    btn_reset = ft.OutlinedButton(
        content=ft.Text("Reset"), icon=ft.Icons.REFRESH_ROUNDED,
        style=ft.ButtonStyle(shape=ft.RoundedRectangleBorder(radius=10), padding=ft.Padding(20, 18, 20, 18),
                            side=ft.BorderSide(1, C["border"])),
        on_click=lambda _: reset_workspace(), visible=False,
    )

    status_text = ft.Text("Ready", size=12, color=C["text_muted"])
    status_bar = ft.Container(
        content=ft.Row([status_text, ft.Container(expand=True),
                        ft.Text(f"DeepFract v{VERSION}", size=11, color=C["text_dim"])]),
        bgcolor=C["sidebar"], border=ft.Border(top=ft.BorderSide(1, C["border"])),
        padding=ft.Padding(24, 8, 24, 8), height=36,
    )

    workspace = ft.Container(
        content=ft.Column([
            ft.Container(content=ft.Column([ws_title, ws_subtitle], spacing=6), padding=ft.Padding(0, 0, 0, 24)),
            preview_card,
            ft.Container(height=20),
            ft.Row([stat_ratio, stat_psnr, stat_rmse, stat_size, stat_time], spacing=12),
            ft.Container(height=20),
            ft.Row([btn_select, btn_save, btn_reset], spacing=12),
        ], spacing=0),
        expand=True, padding=40,
    )

    page.add(ft.Column([
        ft.Row([sidebar, workspace], expand=True, spacing=0),
        status_bar,
    ], expand=True, spacing=0))

    # ── Helpers ──────────────────────────────────────────────────
    def _set_stat(stat, val, color=C["text_sec"]):
        stat.content.controls[1].value = val
        stat.content.controls[1].color = color

    def set_mode(m):
        if state["busy"]: return
        state["mode"] = m
        for nav, active in [(nav_compress, m == "compress"), (nav_decompress, m == "decompress")]:
            nav.bgcolor = C["surface"] if active else "transparent"
            nav.content.controls[0].color = C["primary_light"] if active else C["text_muted"]
            nav.content.controls[1].color = C["primary_light"] if active else C["text_muted"]
        ws_title.value = "Compress Image" if m == "compress" else "Decompress FIC"
        ws_subtitle.value = ("Neural Encoding · Select an image to begin" if m == "compress"
                            else "Neural Reconstruction · Select a .fic archive")
        stat_psnr.visible = (m == "decompress")
        stat_rmse.visible = (m == "decompress")
        reset_workspace()

    def reset_workspace():
        state["fic_bytes"] = None; state["png_bytes"] = None; state["result_img"] = None
        btn_save.visible = False; btn_reset.visible = False; btn_select.disabled = False
        preview_card.content = _make_dropzone()
        for s in [stat_ratio, stat_psnr, stat_rmse, stat_size, stat_time]:
            _set_stat(s, "—")
        status_text.value = "Ready"
        page.update()

    async def select_file(e=None):
        if state["busy"]:
            return
        else:
            if state["mode"] == "compress":
                files = await file_picker.pick_files(
                    dialog_title="Select Image",
                    allowed_extensions=["jpg", "jpeg", "png", "bmp", "webp"],
                    allow_multiple=False)
                if files: await _start_compress(files[0].path)
            else:
                files = await file_picker.pick_files(
                    dialog_title="Select .fic File",
                    allowed_extensions=["fic"],
                    allow_multiple=False)
                if files: await _start_decompress(files[0].path)

    async def save_result(e=None):
        if state["mode"] == "compress" and state["fic_bytes"]:
            path = await file_picker.save_file(dialog_title="Save Compressed File",
                                                    file_name="result.fic", allowed_extensions=["fic"])
            if path:
                with open(path, 'wb') as f: f.write(state["fic_bytes"])
                status_text.value = f"Saved to {os.path.basename(path)}"; page.update()
        elif state["mode"] == "decompress" and state["png_bytes"]:
            path = await file_picker.save_file(dialog_title="Save Image",
                                                    file_name="result.png", allowed_extensions=["png", "jpg"])
            if path:
                with open(path, 'wb') as f: f.write(state["png_bytes"])
                status_text.value = f"Saved to {os.path.basename(path)}"; page.update()

    async def _show_loading(msg):
        loader = ft.Image(src=logo_src, width=80, height=80, rotate=0, animate_rotation=1000) if logo_src else ft.ProgressRing(color=C["primary"], width=48, height=48)
        
        # Clear stats immediately
        for s in [stat_ratio, stat_psnr, stat_rmse, stat_size, stat_time]:
            _set_stat(s, "—")
        btn_save.visible = False; btn_reset.visible = False
            
        preview_card.content = ft.Column(
            controls=[
                ft.Container(content=loader, padding=20),
                ft.Text(msg, size=18, weight=ft.FontWeight.W_700, color=C["text"]),
                ft.Text("Accelerating via Neural Backend", size=12, color=C["text_dim"]),
            ],
            horizontal_alignment=ft.CrossAxisAlignment.CENTER,
            alignment=ft.MainAxisAlignment.CENTER, spacing=10)
        status_text.value = msg; btn_select.disabled = True; page.update()
        
        if logo_src:
            async def rotate_loop():
                while state["busy"]:
                    loader.rotate = (loader.rotate or 0) + 3.14159 * 2
                    page.update()
                    await asyncio.sleep(1)
            page.run_task(rotate_loop)

    async def _start_compress(path):
        state["busy"] = True
        await _show_loading("Compressing…")
        try:
            fic, s = await api_compress(path)
            state["fic_bytes"] = fic; state["busy"] = False
            _set_stat(stat_ratio, f"{s['ratio']:.1f}:1", C["success"])
            _set_stat(stat_psnr, f"{s['psnr']:.1f} dB", C["cyan"])
            _set_stat(stat_rmse, f"{s['rmse']:.2f}", C["warning"])
            _set_stat(stat_size, human_size(s['compressed_size']), C["primary_light"])
            _set_stat(stat_time, f"{s['time']:.1f}s", C["text_sec"])
            preview_card.content = ft.Column(
                controls=[
                    ft.Container(
                        content=ft.Icon(ft.Icons.CHECK_CIRCLE_ROUNDED, color=C["success"], size=64),
                        width=100, height=100, border_radius=50,
                        bgcolor="#22c55e15", alignment=ft.Alignment(0, 0)),
                    ft.Container(height=12),
                    ft.Text("Compression Complete!", size=20, weight=ft.FontWeight.W_700, color=C["text"]),
                    ft.Text(f"{human_size(s['original_size'])} → {human_size(s['compressed_size'])} ({s['ratio']:.1f}:1)",
                            size=13, color=C["text_muted"]),
                ],
                horizontal_alignment=ft.CrossAxisAlignment.CENTER,
                alignment=ft.MainAxisAlignment.CENTER, spacing=4)
            btn_save.visible = True; btn_reset.visible = True; btn_select.disabled = False
            status_text.value = "Compression complete — Ready to save"; page.update()
        except Exception as ex:
            state["busy"] = False; btn_select.disabled = False
            status_text.value = f"Error: {str(ex)[:80]}"; reset_workspace()

    async def _start_decompress(path):
        state["busy"] = True
        await _show_loading("Decompressing…")
        try:
            img, png_bytes, s = await api_decompress(path)
            state["result_img"] = img; state["png_bytes"] = png_bytes; state["busy"] = False
            b64 = img_to_b64(img)
            preview_card.content = ft.Column(
                controls=[
                    ft.Container(
                        content=ft.Image(src=f"data:image/png;base64,{b64}", fit="contain"),
                        expand=True, alignment=ft.Alignment(0, 0), border_radius=12),
                    ft.Text(f"Reconstructed — {s['width']}×{s['height']} px",
                            size=11, color=C["text_dim"], weight=ft.FontWeight.W_600),
                ], expand=True, spacing=8, horizontal_alignment=ft.CrossAxisAlignment.CENTER)
            _set_stat(stat_size, human_size(s['output_size']), C["primary_light"])
            _set_stat(stat_time, f"{s['time']:.1f}s", C["text_sec"])
            _set_stat(stat_psnr, f"{s['psnr']:.1f} dB" if s['psnr'] > 0 else "N/A", C["cyan"])
            _set_stat(stat_rmse, f"{s['rmse']:.2f}" if s['rmse'] > 0 else "N/A", C["warning"])
            btn_save.visible = True; btn_reset.visible = True; btn_select.disabled = False
            status_text.value = "Decompression complete — Ready to save"; page.update()
        except Exception as ex:
            state["busy"] = False; btn_select.disabled = False
            status_text.value = f"Error: {str(ex)[:80]}"; reset_workspace()

    async def on_keyboard(e: ft.KeyboardEvent):
        if e.ctrl and e.key == "O": await select_file()
        elif e.ctrl and e.key == "S": await save_result()
    page.on_keyboard_event = on_keyboard

    async def check_api():
        ok = await api_health()
        api_dot.bgcolor = C["success"] if ok else C["error"]
        api_label.value = "API Connected" if ok else "API Offline"
        page.update()
    page.run_task(check_api)


if __name__ == "__main__":
    ft.run(main)
