import flet as ft
import subprocess
import os
import json
import threading
import datetime
import webbrowser
import shutil
from pathlib import Path

CONFIG_FILE = "smart_deploy_config.json"

class DeployApp:
    def __init__(self, page: ft.Page):
        self.page = page
        self.page.title = "Smart Deploy - BHU Control"
        self.page.theme_mode = ft.ThemeMode.DARK
        self.page.padding = 0
        
        self.page.window.width = 900
        self.page.window.height = 700
        self.page.window.min_width = 800
        self.page.window.min_height = 600
        
        self.projects = []
        self.current_project = None
        self.console_output = ""
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
        else:
            self.projects = []
    
    def save_config(self):
        with open(CONFIG_FILE, "w") as f:
            json.dump({"projects": self.projects}, f, indent=2)
    
    def log(self, message: str, level: str = "info"):
        timestamp = datetime.datetime.now().strftime("%H:%M:%S")
        prefix = {"info": "📘", "success": "✅", "error": "❌", "warning": "⚠️", "process": "🔄"}.get(level, "ℹ️")
        self.console_output += f"[{timestamp}] {prefix} {message}\n"
        if self.console_text:
            self.console_text.value = self.console_output
            self.page.update()
    
    def setup_ui(self):
        self.project_dropdown = ft.Dropdown(
            label="Proyecto",
            options=[ft.dropdown.Option(p["name"], p["path"]) for p in self.projects],
            on_select=self.on_project_change,
            expand=True,
        )
        
        self.status_text = ft.Text("Listo", size=14, color=ft.Colors.GREEN)
        self.progress_bar = ft.ProgressBar(width=400, visible=False)
        self.console_text = ft.Text(self.console_output, selectable=True, size=11, font_family="Consolas")
        
        self.page.add(
            ft.Container(
                content=ft.Column([
                    ft.Row([
                        ft.Text("Smart Deploy", size=24, weight=ft.FontWeight.BOLD),
                        ft.Container(expand=True),
                        ft.IconButton(icon=ft.Icons.ADD, tooltip="Agregar Proyecto", on_click=self.add_project),
                        ft.IconButton(icon=ft.Icons.EDIT, tooltip="Editar Proyecto", on_click=self.edit_project),
                        ft.IconButton(icon=ft.Icons.REFRESH, tooltip="Detectar Proyecto", on_click=self.detect_project_click),
                    ]),
                    ft.Row([self.project_dropdown, self.status_text]),
                    ft.Divider(),
                    ft.Row([
                        ft.Column([
                        ft.Button("Deploy Web (GitHub)", icon=ft.Icons.WEB, on_click=self.deploy_web, disabled=self.is_running),
                        ft.Button("Build Windows", icon=ft.Icons.DESKTOP_WINDOWS, on_click=self.build_windows, disabled=self.is_running),
                        ft.Button("Build Android APK", icon=ft.Icons.ANDROID, on_click=self.build_android, disabled=self.is_running),
                        ft.Button("Build Web Local", icon=ft.Icons.CODE, on_click=self.build_web_local, disabled=self.is_running),
                        ], spacing=10),
                        ft.Column([
                        ft.Button("Clean", icon=ft.Icons.DELETE, on_click=self.clean, disabled=self.is_running),
                        ft.Button("Info", icon=ft.Icons.INFO, on_click=self.show_info),
                        ft.Button("Abrir Build", icon=ft.Icons.FOLDER_OPEN, on_click=self.open_build_folder),
                        ft.Button("Salir", icon=ft.Icons.CLOSE, on_click=self.exit_app),
                        ], spacing=10),
                    ], spacing=40),
                    ft.Divider(),
                    ft.Text("Consola:", size=14, weight=ft.FontWeight.BOLD),
                    ft.Container(
                        content=self.console_text,
                        height=280,
                        border=ft.Border.all(1, ft.Colors.OUTLINE),
                        padding=10,
                        bgcolor=ft.Colors.BLACK,
                    ),
                    self.progress_bar,
                ], spacing=10, expand=True),
                padding=20,
            )
        )
    
    def on_project_change(self, e):
        selected = e.control.value
        for p in self.projects:
            if p["path"] == selected:
                self.current_project = p
                self.log(f"Proyecto seleccionado: {p['name']}", "info")
                break
    
    def detect_project_click(self, e):
        self.detect_project()
    
    def detect_project(self, e=None):
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
            self.current_project = existing or next((p for p in self.projects if p["path"] == detected), None)
            if self.current_project:
                self.project_dropdown.value = self.current_project["path"]
            self.page.update()
        else:
            self.log("No se detectó ningún proyecto Flutter", "warning")
    
    def update_dropdown(self):
        self.project_dropdown.options = [ft.dropdown.Option(p["name"], p["path"]) for p in self.projects]
        self.page.update()
    
    def get_project_path(self):
        if not self.current_project:
            self.log("Selecciona un proyecto primero", "error")
            return None
        return self.current_project["path"]
    
    def run_command(self, cmd: str, cwd: str = None):
        if cwd is None:
            cwd = self.get_project_path()
        
        if not cwd:
            return False, ""
        
        self.log(f"> {cmd}", "process")
        
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
        
        output = []
        for line in iter(process.stdout.readline, ''):
            if not line:
                break
            line = line.strip()
            if line:
                output.append(line)
                if "error" in line.lower() or "failed" in line.lower():
                    self.log(line, "error")
                elif "success" in line.lower() or "done" in line.lower():
                    self.log(line, "success")
                else:
                    self.log(line, "info")
        
        process.wait()
        return process.returncode == 0, "\n".join(output)
    
    def run_command_async(self, cmd: str, cwd: str = None):
        def task():
            self.is_running = True
            self.progress_bar.visible = True
            self.status_text.value = "Ejecutando..."
            self.status_text.color = ft.Colors.ORANGE
            self.page.update()
            
            success, output = self.run_command(cmd, cwd)
            
            self.is_running = False
            self.progress_bar.visible = False
            self.status_text.value = "Completado" if success else "Error"
            self.status_text.color = ft.Colors.GREEN if success else ft.Colors.RED
            self.page.update()
        
        thread = threading.Thread(target=task)
        thread.start()
    
    def deploy_web(self, e):
        self.log("=== DEPLOY WEB (GitHub Pages) ===", "info")
        path = self.get_project_path()
        if not path:
            return
        
        self.run_command_async("flutter build web --release", path)
    
    def build_windows(self, e):
        self.log("=== BUILD WINDOWS ===", "info")
        path = self.get_project_path()
        if not path:
            return
        
        self.run_command_async("flutter build windows --release", path)
    
    def build_android(self, e):
        self.log("=== BUILD ANDROID APK ===", "info")
        path = self.get_project_path()
        if not path:
            return
        
        if "OneDrive" in path:
            temp_path = "C:\\Temp\\bhu_build"
            if os.path.exists(temp_path):
                shutil.rmtree(temp_path)
            os.makedirs(temp_path)
            self.log(f"Copiando a {temp_path}...", "warning")
            shutil.copytree(path, os.path.join(temp_path, os.path.basename(path)))
            path = os.path.join(temp_path, os.path.basename(path))
            self.log("Compilando desde directorio temporal...", "info")
        
        self.run_command_async("flutter build apk --debug", path)
    
    def build_web_local(self, e):
        self.log("=== BUILD WEB LOCAL ===", "info")
        path = self.get_project_path()
        if not path:
            return
        
        self.run_command_async("flutter build web", path)
    
    def clean(self, e):
        self.log("=== CLEAN ===", "info")
        path = self.get_project_path()
        if not path:
            return
        
        self.run_command_async("flutter clean", path)
    
    def show_info(self, e):
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
                        info += f"Versión: {line.split(':')[1].strip()}"
                        break
        
        git_dir = os.path.join(path, ".git")
        if os.path.exists(git_dir):
            try:
                result = subprocess.run("git remote -v", shell=True, cwd=path, capture_output=True, text=True)
                if result.stdout:
                    info += f"\nGit: {result.stdout.strip()}"
            except:
                pass
        
        self.log(info, "info")
    
    def open_build_folder(self, e):
        path = self.get_project_path()
        if not path:
            return
        
        build_path = os.path.join(path, "build", "web")
        if os.path.exists(build_path):
            webbrowser.open(build_path)
            self.log(f"Abrido: {build_path}", "success")
        else:
            self.log("Build no encontrado. Ejecuta un build primero.", "warning")
    
    def add_project(self, e):
        def close_dialog(e):
            self.page.pop_dialog()
        
        def save_project(e):
            name = name_field.value.strip()
            path = path_field.value.strip()
            if name and path and os.path.exists(path):
                self.projects.append({"name": name, "path": path})
                self.save_config()
                self.update_dropdown()
                self.log(f"Proyecto agregado: {name}", "success")
                self.page.pop_dialog()
        
        async def pick_folder(e):
            fp = ft.FilePicker()
            result = await fp.get_directory_path()
            if result:
                path_field.value = result
                self.page.update()
        
        name_field = ft.TextField(label="Nombre", hint_text="Mi Proyecto")
        path_field = ft.TextField(label="Ruta", hint_text="C:\\ruta\\al\\proyecto")
        
        dialog = ft.AlertDialog(
            title=ft.Text("Agregar Proyecto"),
            content=ft.Column([name_field, path_field, ft.Button("Seleccionar Carpeta", on_click=pick_folder)], height=180),
            actions=[
                ft.TextButton("Cancelar", on_click=close_dialog),
                ft.Button("Guardar", on_click=save_project),
            ],
        )
        self.page.show_dialog(dialog)
    
    def edit_project(self, e):
        if not self.current_project:
            self.log("Selecciona un proyecto para editar", "warning")
            return
        
        def close_dialog(e):
            self.page.pop_dialog()
        
        def save_edit(e):
            name = name_field.value.strip()
            path = path_field.value.strip()
            if name and path and os.path.exists(path):
                self.current_project["name"] = name
                self.current_project["path"] = path
                self.save_config()
                self.update_dropdown()
                self.log(f"Proyecto actualizado: {name}", "success")
                self.page.pop_dialog()
        
        name_field = ft.TextField(label="Nombre", value=self.current_project["name"])
        path_field = ft.TextField(label="Ruta", value=self.current_project["path"])
        
        dialog = ft.AlertDialog(
            title=ft.Text("Editar Proyecto"),
            content=ft.Column([name_field, path_field], height=150),
            actions=[
                ft.TextButton("Cancelar", on_click=close_dialog),
                ft.Button("Guardar", on_click=save_edit),
            ],
        )
        self.page.show_dialog(dialog)
    
    def exit_app(self, e):
        import os
        os._exit(0)


def main(page: ft.Page):
    DeployApp(page)


if __name__ == "__main__":
    ft.run(main)
