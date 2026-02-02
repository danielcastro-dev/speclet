# Guía de Instalación - Speclet

## Instalación Rápida (Recomendado)

### Windows (PowerShell)

```powershell
powershell -ExecutionPolicy Bypass -Command "IEX (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/danielcastro-dev/speclet/main/install-universal.ps1').Content"
```

Esto descargará e instalará Speclet en el directorio actual con un comando único.

### Linux / macOS (Bash)

```bash
bash <(curl -s https://raw.githubusercontent.com/danielcastro-dev/speclet/main/install-universal.sh)
```

## Instalación desde Repositorio Clonado

Si prefieres clonar el repositorio primero:

### Windows (PowerShell)

```powershell
git clone https://github.com/danielcastro-dev/speclet.git
cd speclet
.\install.ps1
cd ..
Remove-Item -Recurse -Force speclet
```

### Linux / macOS (Bash)

```bash
git clone https://github.com/danielcastro-dev/speclet.git
cd speclet
bash install.sh
cd ..
rm -rf speclet
```

## Instalación Personalizada

Si necesitas instalar en un directorio específico:

### Windows (PowerShell)

```powershell
powershell -ExecutionPolicy Bypass -Command "& { `
  IEX (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/danielcastro-dev/speclet/main/install-universal.ps1').Content `
} -TargetDir 'C:\ruta\a\tu\proyecto'"
```

O localmente:

```powershell
.\install-universal.ps1 -TargetDir '..\otro-proyecto'
```

### Linux / macOS (Bash)

```bash
bash install-universal.sh https://github.com/danielcastro-dev/speclet.git main /ruta/a/tu/proyecto
```

O localmente:

```bash
bash install-universal.sh https://github.com/danielcastro-dev/speclet.git main ../otro-proyecto
```

## Lo que se Instala

### Estructura de Directorios

```
tu-proyecto/
├── .speclet/
│   ├── GUIDE.md                  # Instrucciones para el LLM (permanente)
│   ├── loop.md                   # Documentación del loop runner
│   ├── DECISIONS.md              # Decisiones arquitectónicas (tracked)
│   ├── templates/                # Plantillas de draft y spec
│   │   ├── draft.md
│   │   ├── spec.json
│   │   ├── spec-lite.json
│   │   ├── progress.md
│   │   └── ticket.md
│   ├── tickets/                  # Carpeta para tickets individuales
│   └── archive/                  # Trabajos completados
├── .opencode/skill/
│   ├── speclet-draft/            # Skill: generar drafts
│   ├── speclet-spec/             # Skill: generar specs
│   ├── speclet-council/          # Skill: validar specs (múltiples modelos)
│   ├── speclet-ticket/           # Skill: dividir en tickets
│   └── speclet-learn/            # Skill: extraer aprendizajes
├── speclet.sh                    # Loop runner (Linux/macOS)
├── speclet.ps1                   # Loop runner (Windows)
└── .gitignore                    # Actualizado con reglas de .speclet/
```

## Requisitos Previos

- **OpenCode** instalado en tu sistema
  - [Instrucciones de instalación](https://opencode.ai/docs/install)
- **Git** (opcional, el instalador puede funcionar sin él descargando un ZIP)
- **PowerShell 5.0+** (Windows) o **bash 4.0+** (Linux/macOS)
- **Acceso a modelos LLM** (Opus, GPT, Gemini, GLM, Sonnet) configurado en OpenCode

## Uso Después de Instalar

### Con OpenCode Skills (Recomendado)

```
Use the speclet-draft skill for [descripción de feature]
Use the speclet-council skill
Use the speclet-spec skill
Use the speclet-ticket skill
```

### Loop Autónomo

```powershell
# Windows
.\speclet.ps1

# Linux/macOS
./speclet.sh
```

## Solución de Problemas

### "OpenCode no encontrado"

Instala OpenCode primero desde https://opencode.ai/docs/install

### "Git no encontrado" en el instalador universal

El instalador automáticamente descargará un ZIP si Git no está disponible. No hay acción requerida.

### Los permisos deniegos en Linux/macOS

```bash
chmod +x speclet.sh
chmod +x install-universal.sh
```

### Conflicto con .gitignore existente

El instalador añade las reglas de Speclet al final de tu `.gitignore` existente. Verifica que incluya:

```
# Speclet
.speclet/*
!.speclet/DECISIONS.md
```

## Actualizar Speclet

Para actualizar a la última versión:

```powershell
# Windows
powershell -ExecutionPolicy Bypass -Command "IEX (Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/danielcastro-dev/speclet/main/install-universal.ps1').Content"
```

```bash
# Linux/macOS
bash <(curl -s https://raw.githubusercontent.com/danielcastro-dev/speclet/main/install-universal.sh)
```

Los archivos existentes serán sobrescritos, pero tus datos en `.speclet/DECISIONS.md` se preservan.
