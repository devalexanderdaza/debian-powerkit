# Contribuyendo a Debian PowerKit

¡Gracias por tu interés en contribuir a Debian PowerKit! 🎉

## 🤝 Cómo Contribuir

### Reportar Bugs

Si encuentras un bug, por favor:

1. Verifica que no haya sido reportado previamente en [Issues](https://github.com/devalexanderdaza/debian-powerkit/issues)
2. Crea un nuevo issue incluyendo:
   - Descripción clara del problema
   - Pasos para reproducirlo
   - Comportamiento esperado vs comportamiento actual
   - Versión de Debian
   - Logs relevantes (si aplica)

### Sugerir Mejoras

¿Tienes una idea para mejorar el proyecto?

1. Abre un issue con la etiqueta `enhancement`
2. Describe claramente tu propuesta
3. Explica por qué sería útil para la comunidad

### Pull Requests

1. **Fork** el repositorio
2. **Crea una rama** desde `main`:
   ```bash
   git checkout -b feature/nueva-funcionalidad
   ```
3. **Realiza tus cambios** siguiendo las guías de estilo
4. **Prueba tus cambios** en un entorno Debian limpio
5. **Commit** tus cambios con mensajes descriptivos
6. **Push** a tu fork
7. **Abre un Pull Request** con una descripción clara

## 📝 Guías de Estilo

### Scripts Bash

- Usa 4 espacios para indentación
- Incluye comentarios explicativos
- Usa nombres descriptivos para funciones y variables
- Sigue el formato de los scripts existentes
- Añade funciones de logging (`log_info`, `log_warn`, `log_error`)

### Documentación

- Escribe en español (idioma principal del proyecto)
- Usa markdown con formato consistente
- Incluye ejemplos de uso
- Documenta parámetros y opciones

### Commits

Usa el formato:

```
tipo: descripción breve

Descripción detallada del cambio (opcional)

- Detalle 1
- Detalle 2
```

**Tipos:**
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Formato, no cambia funcionalidad
- `refactor`: Refactorización de código
- `test`: Añadir o modificar tests
- `chore`: Mantenimiento

**Ejemplos:**
```
feat: agregar soporte para PostgreSQL en setup.sh

- Añade función install_postgresql
- Incluye configuración inicial
- Actualiza menú interactivo
```

```
fix: corregir detección de ZRAM en optimize.sh

El script fallaba al verificar si zramctl existía.
Ahora usa command -v para verificación correcta.
```

## ✅ Checklist para Pull Requests

Antes de enviar tu PR, verifica:

- [ ] El código funciona en Debian 13
- [ ] Los scripts son idempotentes (pueden ejecutarse múltiples veces)
- [ ] Se incluye documentación actualizada
- [ ] Los mensajes de commit son claros
- [ ] No hay código comentado innecesario
- [ ] Se respetan las convenciones de estilo del proyecto
- [ ] Se añaden respaldos antes de modificar archivos del sistema (si aplica)

## 🧪 Probando tus Cambios

```bash
# En un contenedor o VM con Debian 13
git clone https://github.com/TU_USUARIO/debian-powerkit.git
cd debian-powerkit
git checkout tu-rama

# Probar el script principal
sudo ./run.sh

# Probar módulos específicos
sudo ./setup/setup.sh
sudo ./optimization/optimize.sh
./tools/cleanup.sh
```

## 🎯 Áreas donde Necesitamos Ayuda

- 🌐 Traducción al inglés
- 🧪 Tests automatizados
- 📦 Soporte para otras distribuciones (Ubuntu, etc.)
- 🔧 Nuevas optimizaciones
- 📝 Mejoras en la documentación
- 🐛 Corrección de bugs

## 💬 Comunicación

- **Issues:** Para bugs y sugerencias
- **Pull Requests:** Para contribuciones de código
- **Discussions:** Para preguntas generales (si está habilitado)

## 📜 Código de Conducta

Este proyecto sigue un código de conducta simple:

- Sé respetuoso y profesional
- Acepta críticas constructivas
- Enfócate en lo mejor para la comunidad
- Ayuda a otros contribuidores

## 🙏 Reconocimientos

Todos los contribuidores serán mencionados en el CHANGELOG y en la sección de agradecimientos del README.

---

**¿Primera vez contribuyendo a un proyecto de código abierto?**  
¡No te preocupes! Todos comenzamos en algún lugar. Si tienes dudas, no dudes en preguntar en los issues.

¡Gracias por hacer de Debian PowerKit un mejor proyecto! 🚀
