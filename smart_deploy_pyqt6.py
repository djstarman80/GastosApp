import sys
import os
import json
import subprocess
import threading
import datetime
import webbrowser
import shutil
from pathlib import Path

from PyQt6.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
    QHBoxLayout, QLabel, QComboBox, QPushButton, QTextEdit, QProgressBar, 
    QMessageBox, QInputDialog, QFileDialog, QFrame, QStatusBar)
from PyQt6.QtCore import QThread, pyqtSignal, Qt
from PyQt6.QtGui import QFont, QIcon, QColor, QTextCursor

CONFIG_FILE = "smart_deploy_config.json"


class BuildThread(QThread):
    log_signal = pyqtSignal(str, str)
    finished_signal = pyqtSignal(bool)
    
    def __init__(self, cmd, cwd):
        super().__init__()
        self.cmd = cmd
        self.cwd = cwd
    
    def run(self):
        self.log_signal.emit(f"> {self.cmd}", "info")
        
        process = subprocess.Popen(
            self.cmd,
            shell=True,
            cwd=self.cwd,
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
                    self.log_signal.emit(line, "error")
                elif "success" in line.lower() or "done" in line.lower():
                    self.log_signal.emit(line, "success")
                else:
                    self.log_signal.emit(line, "info")
        
        process.wait()
        self.finished_signal.emit(process.returncode == 0)


class SmartDeployPyQt(QMainWindow):
    def __init__(self):
        super().__init__()
        self.projects = []
        self.current_project = None
        self.is_running = False
        self.build_thread = None
        
        self.load_config()
        self.init_ui()
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
        self.console.append(f"[{timestamp}] {prefix} {message}")
        
        color = {
            "info": "#00BFFF",
            "success": "#00FF00",
            "error": "#FF0000",
            "warning": "#FFA500"
        }.get(level, "#FFFFFF")
        
        cursor = self.console.textCursor()
        cursor.movePosition(QTextCursor.MoveOperation.End)
        cursor.select(QTextCursor.SelectionType.LineUnderCursor)
        format = cursor.charFormat()
        format.setForeground(QColor(color))
        cursor.setCharFormat(format)
        
        self.console.moveCursor(QTextCursor.MoveOperation.End)
    
    def init_ui(self):
        self.setWindowTitle("Smart Deploy - PyQt6")
        self.setGeometry(100, 100, 900, 700)
        
        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        
        title = QLabel("Smart Deploy")
        title.setFont(QFont("Arial", 18, QFont.Weight.Bold))
        layout.addWidget(title)
        
        project_layout = QHBoxLayout()
        project_layout.addWidget(QLabel("Proyecto:"))
        self.project_combo = QComboBox()
        self.project_combo.addItems([p["name"] for p in self.projects])
        self.project_combo.currentIndexChanged.connect(self.on_project_change)
        project_layout.addWidget(self.project_combo)
        
        self.add_btn = QPushButton("Agregar")
        self.add_btn.clicked.connect(self.add_project)
        project_layout.addWidget(self.add_btn)
        
        self.edit_btn = QPushButton("Editar")
        self.edit_btn.clicked.connect(self.edit_project)
        project_layout.addWidget(self.edit_btn)
        
        self.refresh_btn = QPushButton("Detectar")
        self.refresh_btn.clicked.connect(self.detect_project)
        project_layout.addWidget(self.refresh_btn)
        
        layout.addLayout(project_layout)
        
        layout.addWidget(self.create_line())
        
        buttons_layout = QHBoxLayout()
        
        left_frame = QVBoxLayout()
        btn1 = QPushButton("Deploy Web (GitHub)")
        btn1.clicked.connect(self.deploy_web)
        btn1.setMaximumWidth(180)
        left_frame.addWidget(btn1)
        
        btn2 = QPushButton("Build Windows")
        btn2.clicked.connect(self.build_windows)
        btn2.setMaximumWidth(180)
        left_frame.addWidget(btn2)
        
        btn3 = QPushButton("Build Android APK")
        btn3.clicked.connect(self.build_android)
        btn3.setMaximumWidth(180)
        left_frame.addWidget(btn3)
        
        btn4 = QPushButton("Build Web Local")
        btn4.clicked.connect(self.build_web_local)
        btn4.setMaximumWidth(180)
        left_frame.addWidget(btn4)
        
        right_frame = QVBoxLayout()
        btn5 = QPushButton("Clean")
        btn5.clicked.connect(self.clean)
        btn5.setMaximumWidth(180)
        right_frame.addWidget(btn5)
        
        btn6 = QPushButton("Info")
        btn6.clicked.connect(self.show_info)
        btn6.setMaximumWidth(180)
        right_frame.addWidget(btn6)
        
        btn7 = QPushButton("Abrir Build")
        btn7.clicked.connect(self.open_build_folder)
        btn7.setMaximumWidth(180)
        right_frame.addWidget(btn7)
        
        btn8 = QPushButton("Salir")
        btn8.clicked.connect(self.exit_app)
        btn8.setMaximumWidth(180)
        right_frame.addWidget(btn8)
        
        buttons_layout.addLayout(left_frame)
        buttons_layout.addStretch()
        buttons_layout.addLayout(right_frame)
        layout.addLayout(buttons_layout)
        
        layout.addWidget(self.create_line())
        
        layout.addWidget(QLabel("Consola:"))
        self.console = QTextEdit()
        self.console.setFont(QFont("Consolas", 10))
        self.console.setMaximumHeight(280)
        self.console.setReadOnly(True)
        layout.addWidget(self.console)
        
        self.progress = QProgressBar()
        self.progress.setVisible(False)
        layout.addWidget(self.progress)
        
        self.status_bar = QStatusBar()
        self.setStatusBar(self.status_bar)
        self.status_bar.showMessage("Listo")
    
    def create_line(self):
        line = QFrame()
        line.setFrameShape(QFrame.Shape.HLine)
        return line
    
    def on_project_change(self, index):
        if 0 <= index < len(self.projects):
            self.current_project = self.projects[index]
            self.log(f"Proyecto seleccionado: {self.current_project['name']}", "info")
    
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
            self.log("No se detectó ningún proyecto Flutter", "warning")
    
    def update_dropdown(self):
        self.project_combo.clear()
        self.project_combo.addItems([p["name"] for p in self.projects])
    
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
        
        self.is_running = True
        self.progress.setVisible(True)
        self.status_bar.showMessage("Ejecutando...")
        
        self.build_thread = BuildThread(cmd, cwd)
        self.build_thread.log_signal.connect(lambda m, l: self.log(m, l))
        self.build_thread.finished_signal.connect(self.on_build_finished)
        self.build_thread.start()
    
    def on_build_finished(self, success):
        self.is_running = False
        self.progress.setVisible(False)
        self.status_bar.showMessage("Completado" if success else "Error")
    
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
        name, ok1 = QInputDialog.getText(self, "Agregar Proyecto", "Nombre:")
        if not ok1 or not name:
            return
        
        path, ok2 = QFileDialog.getExistingDirectory(self, "Seleccionar Carpeta")
        if not ok2 or not path:
            return
        
        if os.path.exists(os.path.join(path, "pubspec.yaml")):
            self.projects.append({"name": name.strip(), "path": path})
            self.save_config()
            self.update_dropdown()
            self.log(f"Proyecto agregado: {name}", "success")
        else:
            QMessageBox.warning(self, "Error", "La carpeta seleccionada no es un proyecto Flutter")
    
    def edit_project(self):
        if not self.current_project:
            self.log("Selecciona un proyecto para editar", "warning")
            return
        
        name, ok1 = QInputDialog.getText(self, "Editar Proyecto", "Nombre:", 
            text=self.current_project["name"])
        if not ok1:
            return
        
        path, ok2 = QFileDialog.getExistingDirectory(self, "Seleccionar Carpeta",
            dir=self.current_project["path"])
        if not ok2:
            return
        
        if os.path.exists(os.path.join(path, "pubspec.yaml")):
            self.current_project["name"] = name.strip()
            self.current_project["path"] = path
            self.save_config()
            self.update_dropdown()
            self.log(f"Proyecto actualizado: {name}", "success")
        else:
            QMessageBox.warning(self, "Error", "La carpeta seleccionada no es un proyecto Flutter")
    
    def exit_app(self):
        self.close()


def main():
    app = QApplication(sys.argv)
    window = SmartDeployPyQt()
    window.show()
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
