# Deprecated - Scripts Antiguos

Este directorio contiene scripts antiguos que han sido reemplazados por las nuevas versiones consolidadas.

## ⚠️ Advertencia

Los scripts en esta carpeta **NO deben usarse** en producción. Se mantienen únicamente como referencia histórica.

## 📁 Contenido

### Subdirectorio `Debian/`

Contiene los scripts originales individuales que fueron consolidados en:
- `setup/setup.sh` - Reemplaza todos los scripts de instalación
- `optimization/optimize.sh` - Reemplaza todos los scripts de optimización

## 🔄 Migración

Si anteriormente usabas scripts individuales, ahora usa:

| Script Antiguo | Reemplazo Nuevo |
|----------------|-----------------|
| `install_docker.sh` | `setup/setup.sh` |
| `configure_nodejs.sh` | `setup/setup.sh` |
| `optimize_cpu.sh` | `optimization/optimize.sh` |
| `optimize_memory.sh` | `optimization/optimize.sh` |
| `enable_bbr.sh` | `optimization/optimize.sh` |
| ... | ... |

## 🗑️ ¿Puedo Eliminar Esta Carpeta?

Sí, puedes eliminar esta carpeta de forma segura:

```bash
rm -rf deprecated/
```

Sin embargo, se recomienda mantenerla si:
- Necesitas consultar configuraciones antiguas
- Quieres comparar con las nuevas implementaciones
- Estás en proceso de migración

## 📚 Valor Histórico

Estos scripts representan la evolución del proyecto y pueden ser útiles para:
- Entender decisiones de diseño
- Recuperar funcionalidades específicas
- Aprender de implementaciones anteriores

---

💡 **Nota:** Usa siempre los scripts actuales en `setup/`, `optimization/` y `tools/`.
