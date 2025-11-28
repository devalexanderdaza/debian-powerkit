# Config - Archivos de Configuración

Este directorio contiene archivos de configuración recomendados para diversas herramientas y aplicaciones.

## 📄 Contenido

### `vscode_settings.json`

Configuración recomendada para Visual Studio Code optimizada para desarrollo en Debian.

## 🎯 Uso

### Visual Studio Code

**Aplicar configuración:**

```bash
# Copiar al directorio de configuración de VS Code
cp config/vscode_settings.json ~/.config/Code/User/settings.json

# O fusionar con tu configuración existente
cat config/vscode_settings.json
```

**Configuraciones incluidas:**
- Formato automático al guardar
- Configuración de terminal integrada
- Tema y fuentes optimizadas
- Extensiones recomendadas
- Configuración de Git

## 📝 Personalización

Puedes modificar estos archivos según tus preferencias:

```bash
# Editar configuración de VS Code
nano config/vscode_settings.json
```

## 💡 Añadir Más Configuraciones

Este directorio está diseñado para almacenar archivos de configuración adicionales:

```bash
# Ejemplos de archivos que puedes añadir:
config/
  ├── .bashrc              # Configuración de Bash
  ├── .zshrc               # Configuración de Zsh
  ├── .gitconfig           # Configuración global de Git
  ├── .vimrc               # Configuración de Vim
  └── tmux.conf            # Configuración de Tmux
```

## 🔗 Recursos

- [VS Code Settings](https://code.visualstudio.com/docs/getstarted/settings)
- [Dotfiles Best Practices](https://dotfiles.github.io/)

---

💡 **Tip:** Mantén tus configuraciones en control de versiones para sincronizarlas entre diferentes sistemas.
