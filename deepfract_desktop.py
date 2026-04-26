"""
DeepFract Desktop — Neural Fractal Image Compression
Premium desktop client with modern UI connected to cloud backend.
"""

import os, sys, io, time, threading
import tkinter as tk
from tkinter import filedialog
import customtkinter as ctk
from PIL import Image, ImageTk
import urllib.request, urllib.error, json

API_URL = "https://tony-saleeb-deepfract-api.hf.space"

def resource_path(rel):
    return os.path.join(getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__))), rel)

def human_size(n):
    if n < 1024: return f"{n} B"
    if n < 1024**2: return f"{n/1024:.1f} KB"
    return f"{n/1024**2:.1f} MB"

# ── API ───────────────────────────────────────────────────────────
def api_health():
    try:
        with urllib.request.urlopen(f"{API_URL}/health", timeout=10) as r:
            return json.loads(r.read()).get('status') == 'ok'
    except: return False

def _multipart(url, field, filepath):
    data = open(filepath, 'rb').read()
    name = os.path.basename(filepath)
    bd = '----DFBound7777'
    body = (f'--{bd}\r\nContent-Disposition: form-data; name="{field}"; filename="{name}"\r\n'
            f'Content-Type: application/octet-stream\r\n\r\n').encode() + data + f'\r\n--{bd}--\r\n'.encode()
    req = urllib.request.Request(url, data=body,
        headers={'Content-Type': f'multipart/form-data; boundary={bd}'}, method='POST')
    t0 = time.time()
    with urllib.request.urlopen(req, timeout=3600) as r:
        return r.read(), dict(r.headers), time.time() - t0, len(data)

def api_compress(path):
    content, h, wall, orig_sz = _multipart(f"{API_URL}/compress", "image", path)
    return content, {
        'original_size': orig_sz, 'compressed_size': len(content),
        'ratio': float(h.get('X-Ratio', h.get('x-ratio', '0'))),
        'bpp': float(h.get('X-BPP', h.get('x-bpp', '0'))),
        'time': float(h.get('X-Time', h.get('x-time', str(wall)))),
    }

def api_decompress(path):
    content, h, wall, fic_sz = _multipart(f"{API_URL}/decompress", "fic", path)
    img = Image.open(io.BytesIO(content)).convert('RGB')
    return img, content, {
        'fic_size': fic_sz, 'output_size': len(content),
        'width': img.size[0], 'height': img.size[1],
        'time': float(h.get('X-Time', h.get('x-time', str(wall)))),
    }

# ── Design Tokens ─────────────────────────────────────────────────
C = {
    'bg':       '#06080f',   'bg2':      '#0c111c',
    'card':     '#111827',   'card_h':   '#1a2234',
    'border':   '#1e293b',   'border_h': '#2d3f5a',
    'blue':     '#3b82f6',   'blue_d':   '#2563eb',   'blue_l': '#60a5fa',
    'text':     '#f1f5f9',   'muted':    '#64748b',   'dim':    '#475569',
    'green':    '#22c55e',   'red':      '#ef4444',   'amber':  '#f59e0b',
    'cyan':     '#06b6d4',
}

class DeepFractApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")

        self.title("DeepFract Workspace")
        self.geometry("1280x820")
        self.minsize(1100, 750)
        self.configure(fg_color=C['bg'])

        # State
        self._mode = "compress"
        self._busy = False
        self._pending_img = None
        self._pending_fic = None
        self._pending_name = ""
        self._tk_img = None

        # Main Layout Grid (Sidebar | Workspace)
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)

        self._build_sidebar()
        self._build_workspace()

        self._ping()
        self._mode_set("compress")

    # ═══════════════════════════════════════════════════════════════
    # BUILD UI - SIDEBAR
    # ═══════════════════════════════════════════════════════════════
    def _build_sidebar(self):
        self.sidebar = ctk.CTkFrame(self, width=280, corner_radius=0, fg_color=C['bg2'])
        self.sidebar.grid(row=0, column=0, sticky="nsew")
        self.sidebar.grid_rowconfigure(3, weight=1) # Spacer

        # Brand
        brand_f = ctk.CTkFrame(self.sidebar, fg_color="transparent")
        brand_f.grid(row=0, column=0, padx=24, pady=(32, 40), sticky="w")
        
        # Logo
        for p in [resource_path(os.path.join('assets','logo.png')),
                   os.path.join('frontend','assets','images','logo.png')]:
            if os.path.exists(p):
                li = Image.open(p).resize((40,40), Image.LANCZOS)
                self._logo = ctk.CTkImage(li, size=(40,40))
                ctk.CTkLabel(brand_f, image=self._logo, text="").pack(side="left", padx=(0,14))
                break

        tf = ctk.CTkFrame(brand_f, fg_color="transparent")
        tf.pack(side="left")
        ctk.CTkLabel(tf, text="DeepFract", font=ctk.CTkFont("Segoe UI", 21, "bold"),
                     text_color=C['blue_l']).pack(anchor="w")
        ctk.CTkLabel(tf, text="W O R K S P A C E", font=ctk.CTkFont("Segoe UI", 9, "bold"),
                     text_color=C['dim']).pack(anchor="w", pady=(0,0))

        # Navigation
        self._nav_c = self._create_nav_btn(1, "◨  Compress Image", lambda: self._mode_set("compress"))
        self._nav_d = self._create_nav_btn(2, "◧  Decompress FIC", lambda: self._mode_set("decompress"))

        # Status Footer
        footer = ctk.CTkFrame(self.sidebar, fg_color=C['bg'], corner_radius=12,
                              border_width=1, border_color=C['border'])
        footer.grid(row=4, column=0, padx=24, pady=24, sticky="ew")
        
        self._dot = ctk.CTkLabel(footer, text="●", font=ctk.CTkFont(size=10), text_color=C['amber'])
        self._dot.pack(side="left", padx=(14,8), pady=12)
        self._status = ctk.CTkLabel(footer, text="Connecting to API…",
                                     font=ctk.CTkFont("Segoe UI", 12, "bold"), text_color=C['muted'])
        self._status.pack(side="left", padx=(0,14), pady=12)

    def _create_nav_btn(self, row, text, cmd):
        btn = ctk.CTkButton(self.sidebar, text=text, anchor="w",
            font=ctk.CTkFont("Segoe UI", 14, "bold"), height=48,
            corner_radius=8, fg_color="transparent", hover_color=C['card_h'], text_color=C['muted'],
            command=cmd)
        btn.grid(row=row, column=0, padx=16, pady=4, sticky="ew")
        return btn

    # ═══════════════════════════════════════════════════════════════
    # BUILD UI - WORKSPACE
    # ═══════════════════════════════════════════════════════════════
    def _build_workspace(self):
        self.workspace = ctk.CTkFrame(self, corner_radius=0, fg_color=C['bg'])
        self.workspace.grid(row=0, column=1, sticky="nsew", padx=48, pady=40)
        self.workspace.grid_columnconfigure(0, weight=1)
        self.workspace.grid_rowconfigure(1, weight=1)

        # Header
        self._ws_title = ctk.CTkLabel(self.workspace, text="Compress Image",
            font=ctk.CTkFont("Segoe UI", 28, "bold"), text_color=C['text'])
        self._ws_title.grid(row=0, column=0, sticky="w", pady=(0, 24))

        # Main Preview Card (Clickable)
        self._card = ctk.CTkFrame(self.workspace, fg_color=C['card'], corner_radius=16,
                            border_width=1, border_color=C['border'])
        self._card.grid(row=1, column=0, sticky="nsew")
        
        self._card_lbl = ctk.CTkLabel(self._card, text="P R E V I E W",
            font=ctk.CTkFont("Segoe UI",11,"bold"), text_color=C['dim'])
        self._card_lbl.pack(pady=(16,0))
        
        self._cv = tk.Canvas(self._card, bg=C['card'], highlightthickness=0, bd=0, cursor="hand2")
        self._cv.pack(fill="both", expand=True, padx=20, pady=(10,20))
        
        # Bind click events for drag-and-drop illusion
        self._cv.bind("<Button-1>", lambda e: self._action_select())
        self._cv.bind("<Enter>", lambda e: self._on_cv_hover(True))
        self._cv.bind("<Leave>", lambda e: self._on_cv_hover(False))

        # Action & Stats Area
        bot_area = ctk.CTkFrame(self.workspace, fg_color="transparent")
        bot_area.grid(row=2, column=0, sticky="ew", pady=(24,0))
        bot_area.grid_columnconfigure(1, weight=1)

        # Buttons
        self._btn_primary = ctk.CTkButton(bot_area, text="Select File",
            font=ctk.CTkFont("Segoe UI", 15, "bold"), width=200, height=48,
            corner_radius=8, fg_color=C['blue_d'], hover_color=C['blue'],
            state="disabled", command=self._action_select)
        self._btn_primary.grid(row=0, column=0, sticky="w")

        self._btn_save = ctk.CTkButton(bot_area, text="💾 Save Result",
            font=ctk.CTkFont("Segoe UI", 14, "bold"), width=160, height=48,
            corner_radius=8, fg_color=C['green'], hover_color="#16a34a",
            command=self._save_result)
        self._btn_save.grid(row=0, column=1, sticky="w", padx=16)
        self._btn_save.grid_remove() # Hidden initially

        # Context Label
        self._ws_hint = ctk.CTkLabel(bot_area, text="JPG · PNG · WebP — No Size Limit",
            font=ctk.CTkFont("Segoe UI", 12), text_color=C['muted'])
        self._ws_hint.grid(row=1, column=0, sticky="w", pady=(8,0))

        # Stats Strip
        self._stat_strip = ctk.CTkFrame(bot_area, fg_color=C['card'], corner_radius=12,
                              border_width=1, border_color=C['border'], height=72)
        self._stat_strip.grid(row=0, column=2, rowspan=2, sticky="e")
        self._stat_strip.grid_propagate(False)
        
        si = ctk.CTkFrame(self._stat_strip, fg_color="transparent")
        si.pack(fill="both", expand=True, padx=20, pady=8)

        self._stats = {}
        self._stat_frames = {}
        all_stats = [("PSNR",C['cyan']),("RMSE",C['red']),("RATIO",C['green']),
                      ("SIZE",C['amber']),("TIME",C['text'])]
        
        for name, color in all_stats:
            c = ctk.CTkFrame(si, fg_color="transparent")
            ctk.CTkLabel(c, text=name, font=ctk.CTkFont("Segoe UI",10,"bold"),
                         text_color=C['dim']).pack(pady=(2,0))
            l = ctk.CTkLabel(c, text="—", font=ctk.CTkFont("Segoe UI",18,"bold"),
                             text_color=color)
            l.pack(pady=(0,2))
            self._stats[name] = l
            self._stat_frames[name] = c

        # Progress overlay (hidden by default)
        self._prog = ctk.CTkProgressBar(self.workspace, fg_color=C['border'],
            progress_color=C['blue'], height=4, corner_radius=2)
        self._prog.grid(row=3, column=0, sticky="ew", pady=(24,0))
        self._prog.set(0)
        self._prog.grid_remove()

    # ── Helpers ───────────────────────────────────────────────────
    def _mode_set(self, m):
        if self._busy: return
        self._mode = m
        
        # Update Sidebar Nav
        active_color = C['card_h']
        active_text = C['blue_l']
        self._nav_c.configure(fg_color=active_color if m=="compress" else "transparent", 
                              text_color=active_text if m=="compress" else C['muted'])
        self._nav_d.configure(fg_color=active_color if m=="decompress" else "transparent", 
                              text_color=active_text if m=="decompress" else C['muted'])

        # Update Workspace Context
        if m == "compress":
            self._ws_title.configure(text="Compress Image")
            self._ws_hint.configure(text="Supported: JPG, PNG, WebP (No Size Limit)")
            self._btn_primary.configure(text="Select Image")
        else:
            self._ws_title.configure(text="Decompress Archive")
            self._ws_hint.configure(text="Supported: DeepFract Format (.fic)")
            self._btn_primary.configure(text="Select .fic File")

        self._draw_placeholder()
        self._card_lbl.configure(text="WORKSPACE PREVIEW")
        self._show_stats_for_mode()
        for k in self._stats: self._stat(k, "—")
        self._btn_save.grid_remove()
        self._pending_img = None
        self._pending_fic = None

    def _show_stats_for_mode(self):
        if self._mode == "compress":
            show = {"RATIO", "SIZE", "TIME"}
            self._stat_strip.configure(width=280)
        else:
            show = {"PSNR", "RMSE", "SIZE", "TIME"}
            self._stat_strip.configure(width=360)
            
        for name, frame in self._stat_frames.items():
            if name in show:
                frame.pack(side="left", expand=True, fill="y", padx=8)
            else:
                frame.pack_forget()

    def _on_cv_hover(self, is_hover):
        if self._busy: return
        color = C['border_h'] if is_hover else C['border']
        self._card.configure(border_color=color)

    def _draw_placeholder(self):
        self._cv.delete("all")
        self._tk_img = None
        self._cv.update_idletasks()
        cw = max(self._cv.winfo_width(), 300)
        ch = max(self._cv.winfo_height(), 200)
        cx, cy = cw // 2, ch // 2

        pad = 60
        r = 18
        x1, y1, x2, y2 = pad, pad, cw - pad, ch - pad
        dash_color = C['border']
        
        # Border
        self._cv.create_line(x1+r, y1, x2-r, y1, fill=dash_color, dash=(8,6), width=2)
        self._cv.create_line(x2, y1+r, x2, y2-r, fill=dash_color, dash=(8,6), width=2)
        self._cv.create_line(x2-r, y2, x1+r, y2, fill=dash_color, dash=(8,6), width=2)
        self._cv.create_line(x1, y2-r, x1, y1+r, fill=dash_color, dash=(8,6), width=2)
        # Corners
        self._cv.create_arc(x1, y1, x1+2*r, y1+2*r, start=90, extent=90, style='arc', outline=dash_color, width=2)
        self._cv.create_arc(x2-2*r, y1, x2, y1+2*r, start=0, extent=90, style='arc', outline=dash_color, width=2)
        self._cv.create_arc(x2-2*r, y2-2*r, x2, y2, start=270, extent=90, style='arc', outline=dash_color, width=2)
        self._cv.create_arc(x1, y2-2*r, x1+2*r, y2, start=180, extent=90, style='arc', outline=dash_color, width=2)

        icon = "↑" if self._mode == "compress" else "↓"
        title = "Click here to select a file"
        
        self._cv.create_text(cx, cy - 20, text=icon, font=("Segoe UI", 42), fill=C['blue'])
        self._cv.create_text(cx, cy + 30, text=title, font=("Segoe UI", 14, "bold"), fill=C['muted'])

    def _ping(self):
        def w():
            ok = api_health()
            self.after(0, lambda: self._set_status(ok))
        threading.Thread(target=w, daemon=True).start()

    def _set_status(self, ok):
        if ok:
            self._dot.configure(text_color=C['green'])
            self._status.configure(text="API Connected")
        else:
            self._dot.configure(text_color=C['red'])
            self._status.configure(text="API Offline")
        self._btn_primary.configure(state="normal")

    def _show(self, img):
        self._cv.update_idletasks()
        cw, ch = max(self._cv.winfo_width(),100), max(self._cv.winfo_height(),100)
        r = min(cw/img.width, ch/img.height)
        rs = img.resize((int(img.width*r), int(img.height*r)), Image.LANCZOS)
        self._tk_img = ImageTk.PhotoImage(rs)
        self._cv.delete("all")
        self._cv.create_image(cw//2, ch//2, image=self._tk_img)

    def _stat(self, k, v):
        if k in self._stats: self._stats[k].configure(text=v)

    def _lock(self, txt="Processing…"):
        self._busy = True
        self._anim_angle = 0
        self._anim_label = txt
        self._btn_primary.configure(state="disabled", text=txt)
        self._btn_save.grid_remove()
        self._prog.grid()
        self._prog.configure(mode="indeterminate"); self._prog.start()
        for k in self._stats: self._stat(k, "…")
        self._draw_loading()

    def _unlock(self, btn_txt="Select File", status_txt="Ready"):
        self._busy = False
        self._anim_label = None
        self._btn_primary.configure(state="normal", text=btn_txt)
        self._prog.stop(); self._prog.configure(mode="determinate"); self._prog.set(1)
        self._status.configure(text=status_txt)
        # Hide progress bar after a brief delay
        self.after(2000, lambda: self._prog.grid_remove())

    def _draw_loading(self):
        if not self._busy: return
        self._cv.delete("all")
        self._cv.update_idletasks()
        cw = max(self._cv.winfo_width(), 300)
        ch = max(self._cv.winfo_height(), 200)
        cx, cy = cw // 2, ch // 2

        import math
        a = self._anim_angle
        pulse = 0.5 + 0.5 * math.sin(math.radians(a * 2))

        ring_r = 60 + int(pulse * 8)
        self._cv.create_oval(cx-ring_r, cy-40-ring_r, cx+ring_r, cy-40+ring_r, outline=C['blue_d'], width=1)
        ar = 50
        self._cv.create_arc(cx-ar, cy-40-ar, cx+ar, cy-40+ar, start=a, extent=80, style='arc', outline=C['blue_l'], width=3)
        self._cv.create_arc(cx-ar, cy-40-ar, cx+ar, cy-40+ar, start=a+180, extent=60, style='arc', outline=C['blue_d'], width=2)
        ir = 35
        self._cv.create_arc(cx-ir, cy-40-ir, cx+ir, cy-40+ir, start=-a*1.5, extent=50, style='arc', outline=C['cyan'], width=2)
        dr = 5
        self._cv.create_oval(cx-dr, cy-40-dr, cx+dr, cy-40+dr, fill=C['blue_l'], outline="")

        label = self._anim_label or "Processing…"
        dots = "." * (1 + (a // 30) % 3)
        self._cv.create_text(cx, cy + 40, text=label.rstrip("…") + dots, font=("Segoe UI", 16, "bold"), fill=C['text'])
        self._cv.create_text(cx, cy + 66, text="Accelerating via Neural Backend", font=("Segoe UI", 11), fill=C['dim'])

        self._anim_angle = (a + 6) % 360
        self.after(33, self._draw_loading)

    def _draw_success(self, main_text, sub_text):
        self._cv.delete("all")
        self._cv.update_idletasks()
        cw = max(self._cv.winfo_width(), 300)
        ch = max(self._cv.winfo_height(), 200)
        cx, cy = cw // 2, ch // 2

        # Draw Green Checkmark Circle
        r = 45
        self._cv.create_oval(cx-r, cy-40-r, cx+r, cy-40+r, outline=C['green'], width=3)
        self._cv.create_line(cx-15, cy-40, cx-5, cy-30, fill=C['green'], width=3, capstyle="round")
        self._cv.create_line(cx-5, cy-30, cx+20, cy-55, fill=C['green'], width=3, capstyle="round")

        # Text
        self._cv.create_text(cx, cy + 30, text=main_text, font=("Segoe UI", 18, "bold"), fill=C['text'])
        self._cv.create_text(cx, cy + 60, text=sub_text, font=("Segoe UI", 12), fill=C['muted'])

    # ── Actions ───────────────────────────────────────────────────
    def _action_select(self):
        if self._busy: return
        (self._compress if self._mode=="compress" else self._decompress)()

    def _compress(self):
        path = filedialog.askopenfilename(title="Select Image", filetypes=[("Images","*.jpg *.jpeg *.png *.bmp *.webp")])
        if not path: return
        orig = Image.open(path).convert("RGB")
        self._show(orig)
        self._card_lbl.configure(text=f"ORIGINAL IMAGE — {orig.width}×{orig.height} px")
        self._lock("Compressing…")

        def w():
            try:
                fic, s = api_compress(path)
                
                sp = filedialog.asksaveasfilename(defaultextension=".fic",
                    initialfile=os.path.splitext(os.path.basename(path))[0]+".fic",
                    filetypes=[("FIC","*.fic")])
                
                if sp: 
                    open(sp,'wb').write(fic)
                    def success_flow():
                        self._stat("RATIO", f"{s['ratio']:.1f}:1")
                        self._stat("SIZE", human_size(s['compressed_size']))
                        self._stat("TIME", f"{s['time']:.1f}s")
                        self._unlock("Select Image", "Compression Complete ✓")
                        self._draw_success("Compression Successful!", f"Saved to: {os.path.basename(sp)}")
                    self.after(0, success_flow)
                else:
                    def cancel_flow():
                        self._unlock("Select Image", "Save Cancelled")
                        self._draw_placeholder()
                    self.after(0, cancel_flow)
            except Exception as e:
                self.after(0, lambda: self._unlock("Select Image", f"Error: {str(e)[:50]}"))
        threading.Thread(target=w, daemon=True).start()

    def _decompress(self):
        path = filedialog.askopenfilename(title="Select .fic File", filetypes=[("FIC","*.fic")])
        if not path: return
        self._cv.delete("all")
        self._card_lbl.configure(text="DECOMPRESSING ARCHIVE…")
        self._lock("Decompressing…")

        def w():
            try:
                img, png, s = api_decompress(path)
                self._pending_img = img
                self._pending_name = os.path.splitext(os.path.basename(path))[0]

                def finalize():
                    # ALWAYS unlock first so the loading animation stops immediately
                    self._unlock("Select .fic File", "Preview ready — Save when ready")
                    self._show(img)
                    self._card_lbl.configure(text=f"DECODED OUTPUT — {s['width']}×{s['height']} px")
                    self._stat("SIZE", human_size(s['output_size']))
                    self._stat("TIME", f"{s['time']:.1f}s")
                    self._stat("PSNR", "—")
                    self._stat("RMSE", "—")
                    self._btn_save.grid()
                
                self.after(0, finalize)
            except Exception as e:
                self.after(0, lambda: self._unlock("Select .fic File", f"Error: {str(e)[:50]}"))
        threading.Thread(target=w, daemon=True).start()

    def _save_result(self):
        if not self._pending_img: return
        sp = filedialog.asksaveasfilename(defaultextension=".png",
            initialfile=self._pending_name + "_decoded.png",
            filetypes=[("PNG","*.png"),("JPEG","*.jpg")])
        if sp:
            self._pending_img.save(sp)
            self._status.configure(text="Image saved ✓")
            self._btn_save.grid_remove()

if __name__ == "__main__":
    app = DeepFractApp()
    app.after(100, app._draw_placeholder)
    app.mainloop()
