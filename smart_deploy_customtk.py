import sys
import os
import json
import subprocess
import threading
import datetime
import webbrowser
import shutil
from pathlib import Path
import customtkinter as ctk
from tkinter import filedialog

CONFIG_FILE = "smart_deploy_config.json"


class SmartDeployCustomTk(ctk.CTk):
    def __init__(self):
        super().__init__()
        
        self.projects = []
        self.current_project = None
        self.is_running = False
        
        self.load_config()
        self.setup_ui()
        self.detect_project()
    
    def load_config(self):
        if os.path.exists(CONFIG_FILE):
            try:
                with open(CONFIG_FILE, "r") as f:
                    data = json.load(f)
                    self.projects = data.get("projects", [])
            except:
                self.projects = []
    
    def save_config(self):
        with open(CONFIG_FILE, "w") as f:
            json.dump({"projects": self.projects}, f, indent=2)
    
    def log(self, message: str, level: str = "info"):
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        prefix = {"info": "[INFO]", "success": "[OK]", "error": "[ERR]", "warning": "[WARN]"}.get(level, "")
        
        color = {
            "info": "#00BFFF",
            "success": "#00FF00",
            "error": "#FF4444",
            "warning": "#FFA500"
        }.get(level, "#FFFFFF")
        
        self.console.insert("end", f"[{timestamp}] {prefix} {message}\n")
        self.console.see("end")
        
        if level == "error":
            self.console.tag_add("error", "end-2l", "end-1l")
            self.console.tag_config("error", foreground="#FF4444")
        elif level == "success":
            self.console.tag_add("success", "end-2l", "end-1l")
            self.console.tag_config("success", foreground="#00FF00")
        elif level == "warning":
            self.console.tag_add("warning", "end-2l", "end-1l")
            self.console.tag_config("warning", foreground="#FFA500")
    
    def setup_ui(self):
        self.title("Smart Deploy - CustomTkinter")
        self.geometry("900x700")
        
        ctk.set_appearance_mode("dark")
        ctk.set_default_color_theme("blue")
        
        main_frame = ctk.CTkFrame(self)
        main_frame.pack(fill="both", expand=True, padx=10, pady=10)
        
        title = ctk.CTkLabel(main_frame, text="Smart Deploy", font=ctk.CTkFont(size=24, weight="bold"))
        title.pack(pady=10)
        
        project_frame = ctk.CTkFrame(main_frame)
        project_frame.pack(fill="x", padx=10, pady=5)
        
        ctk.CTkLabel(project_frame, text="Proyecto:").pack(side="left", padx=5)
        
        self.project_var = ctk.StringVar()
        self.project_combo = ctk.CTkComboBox(project_frame, variable=self.project_var, 
            values=[p["name"] for p in self.projects], command=self.on_project_change)
        self.project_combo.pack(side="left", padx=5, fill="x", expand=True)
        
        ctk.CTkButton(project_frame, text="Agregar", width=80, command=self.add_project).pack(side="left", padx=5)
        ctk.CTkButton(project_frame, text="Editar", width=80, command=self.edit_project).pack(side="left", padx=5)
        ctk.CTkButton(project_frame, text="Detectar", width=80, command=self.detect_project).pack(side="left", padx=5)
        
        buttons_frame = ctk.CTkFrame(main_frame)
        buttons_frame.pack(fill="x", padx=10, pady=10)
        
        left_frame = ctk.CTkFrame(buttons_frame)
        left_frame.pack(side="left", padx=10, pady=10)
        
        ctk.CTkButton(left_frame, text="Deploy Web (GitHub)", command=self.deploy_web).pack(pady=5, padx=10, fill="x")
        ctk.CTkButton(left_frame, text="Build Windows", command=self.build_windows).pack(pady=5, padx=10, fill="x")
        ctk.CTkButton(left_frame, text="Build Android APK", command=self.build_android).pack(pady=5, padx=10, fill="x")
        ctk.CTkButton(left_frame, text="Build Web Local", command=self.build_web_local).pack(pady=5, padx=10, fill="x")
        
        right_frame = ctk.CTkFrame(buttons_frame)
        right_frame.pack(side="right", padx=10, pady=10)
        
        ctk.CTkButton(right_frame, text="Clean", command=self.clean).pack(pady=5, padx=10, fill="x")
        ctk.CTkButton(right_frame, text="Info", command=self.show_info).pack(pady=5, padx=10, fill="x")
        ctk.CTkButton(right_frame, text="Abrir Build", command=self.open_build_folder).pack(pady=5, padx=10, fill="x")
        ctk.CTkButton(right_frame, text="Salir", command=self.exit_app, fg_color="#AA3333").pack(pady=5, padx=10, fill="x")
        
        console_frame = ctk.CTkFrame(main_frame)
        console_frame.pack(fill="both", expand=True, padx=10, pady=5)
        
        ctk.CTkLabel(console_frame, text="Consola:").pack(anchor="w", padx=5)
        
        self.console = ctk.CTkTextbox(console_frame, font=("Consolas", 10))
        self.console.pack(fill="both", expand=True, padx=5, pady=5)
        
        self.progress = ctk.CTkProgressBar(main_frame, mode="indeterminate")
        self.progress.pack(fill="x", padx=10, pady=5)
        self.progress.stop()
        self.progress.pack_forget()
        
        self.status_label = ctk.CTkLabel(main_frame, text="Listo", anchor="w")
        self.status_label.pack(fill="x", padx=10, pady=5)
    
    def on_project_change(self, choice):
        for p in self.projects:
            if p["name"] == choice:
                self.current_project = p
                self.log(f"Proyecto seleccionado: {p['name']}", "info")
                break
    
    def detect_project(self):
        paths_to_check = [
            os.getcwd(),
            str(Path(__file__).parent),
            os.path.expanduser("~\\Documents\\Proyectos\\bhu_control_app"),
            "C:\\Users\\Usuario\\OneDrive\\Projectos\\bhu_control_app",
        ]
        
        detected = None
        for path in paths_to_check:
            if os.path.exists(os.path.join(path, "pubspec.yaml")):
                detected = path
                break
        
        if detected:
            self.log(f"Proyecto detectado: {detected}", "success")
            existing = next((p for p in self.projects if p["path"] == detected), None)
            if not existing:
                name = os.path.basename(detected)
                self.log(f"Agregando proyecto: {name}", "info")
                self.projects.append({"name": name, "path": detected})
                self.save_config()
                self.update_dropdown()
        else:
            self.log("No se detecto ningun proyecto Flutter", "warning")
    
    def update_dropdown(self):
        self.project_combo.configure(values=[p["name"] for p in self.projects])
    
    def get_project_path(self):
        if not self.current_project:
            self.log("Selecciona un proyecto primero", "error")
            return None
        return self.current_project["path"]
    
    def run_command(self, cmd, cwd=None):
        if cwd is None:
            cwd = self.get_project_path()
        
        if not cwd:
            return
        
        def task():
            self.is_running = True
            self.progress.pack(fill="x", padx=10, pady=5)
            self.progress.start()
            self.after(0, lambda: self.status_label.configure(text="Ejecutando..."))
            
            self.log(f"> {cmd}", "info")
            
            process = subprocess.Popen(
                cmd,
                shell=True,
                cwd=cwd,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                encoding="utf-8",
                errors="replace"
            )
            
            for line in iter(process.stdout.readline, ''):
                if not line:
                    break
                line = line.strip()
                if line:
                    if "error" in line.lower() or "failed" in line.lower():
                        self.after(0, lambda: self.log(line, "error"))
                    elif "success" in line.lower() or "done" in line.lower():
                        self.after(0, lambda: self.log(line, "success"))
                    else:
                        self.after(0, lambda: self.log(line, "info"))
            
            process.wait()
            success = process.returncode == 0
            
            self.after(0, lambda: self.progress.stop())
            self.after(0, lambda: self.progress.pack_forget())
            self.after(0, lambda: self.status_label.configure(text="Completado" if success else "Error"))
            self.is_running = False
        
        thread = threading.Thread(target=task)
        thread.start()
    
    def deploy_web(self):
        self.log("=== DEPLOY WEB (GitHub Pages) ===", "info")
        self.run_command("flutter build web --release")
    
    def build_windows(self):
        self.log("=== BUILD WINDOWS ===", "info")
        self.run_command("flutter build windows --release")
    
    def build_android(self):
        self.log("=== BUILD ANDROID APK ===", "info")
        path = self.get_project_path()
        if path and "OneDrive" in path:
            temp_path = "C:\\Temp\\bhu_build"
            if os.path.exists(temp_path):
                shutil.rmtree(temp_path)
            os.makedirs(temp_path)
            self.log(f"Copiando a {temp_path}...", "warning")
            shutil.copytree(path, os.path.join(temp_path, os.path.basename(path)))
            path = os.path.join(temp_path, os.path.basename(path))
        self.run_command("flutter build apk --debug", path)
    
    def build_web_local(self):
        self.log("=== BUILD WEB LOCAL ===", "info")
        self.run_command("flutter build web")
    
    def clean(self):
        self.log("=== CLEAN ===", "info")
        self.run_command("flutter clean")
    
    def show_info(self):
        path = self.get_project_path()
        if not path:
            return
        
        info = f"Proyecto: {self.current_project['name']}\n"
        info += f"Ruta: {path}\n"
        
        pubspec = os.path.join(path, "pubspec.yaml")
        if os.path.exists(pubspec):
            with open(pubspec, "r") as f:
                for line in f:
                    if line.startswith("version:"):
                        info += f"Version: {line.split(':')[1].strip()}"
                        break
        
        self.log(info, "info")
    
    def open_build_folder(self):
        path = self.get_project_path()
        if not path:
            return
        
        build_path = os.path.join(path, "build", "web")
        if os.path.exists(build_path):
            webbrowser.open(build_path)
            self.log(f"Abrido: {build_path}", "success")
        else:
            self.log("Build no encontrado. Ejecuta un build primero.", "warning")
    
    def add_project(self):
        dialog = ctk.CTkInputDialog(title="Agregar Proyecto", text="Nombre del proyecto:")
        name = dialog.get_input()
        if not name:
            return
        
        path = filedialog.askdirectory(title="Seleccionar Carpeta")
        if not path:
            return
        
        if os.path.exists(os.path.join(path, "pubspec.yaml")):
            self.projects.append({"name": name.strip(), "path": path})
            self.save_config()
            self.update_dropdown()
            self.log(f"Proyecto agregado: {name}", "success")
        else:
            self.log("La carpeta no es un proyecto Flutter", "error")
    
    def edit_project(self):
        if not self.current_project:
            self.log("Selecciona un proyecto para editar", "warning")
            return
        
        dialog = ctk.CTkInputDialog(title="Editar Proyecto", text="Nombre del proyecto:",
            entry_text=self.current_project["name"])
        name = dialog.get_input()
        if not name:
            return
        
        path = filedialog.askdirectory(title="Seleccionar Carpeta", 
            initialdir=self.current_project["path"])
        if not path:
            return
        
        if os.path.exists(os.path.join(path, "pubspec.yaml")):
            self.current_project["name"] = name.strip()
            self.current_project["path"] = path
            self.save_config()
            self.update_dropdown()
            self.log(f"Proyecto actualizado: {name}", "success")
        else:
            self.log("La carpeta no es un proyecto Flutter", "error")
    
    def exit_app(self):
        self.destroy()


def main():
    app = SmartDeployCustomTk()
    app.mainloop()


if __name__ == "__main__":
    main()
