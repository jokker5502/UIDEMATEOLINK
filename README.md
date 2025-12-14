# 🚌 UIDE-Link: Sistema de Telemetría de Autobuses con Enfoque Offline-First

**Sistema de telemetría de próxima generación para el transporte de la Universidad Internacional del Ecuador (UIDE)**

[![Offline-First](https://img.shields.io/badge/Offline-First-success)](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)
[![PWA](https://img.shields.io/badge/PWA-Enabled-blue)](https://web.dev/progressive-web-apps/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12+-blue)](https://www.postgresql.org/)

---

## 📋 Tabla de Contenidos

- [Descripción General](#descripción-general)
- [Características Principales](#características-principales)
- [Arquitectura](#arquitectura)
- [Prerrequisitos](#prerrequisitos)
- [Instalación](#instalación)
- [Uso](#uso)
- [Despliegue](#despliegue)
- [Probando la Funcionalidad Offline](#probando-la-funcionalidad-offline)
- [Documentación de la API](#documentación-de-la-api)
- [Solución de Problemas](#solución-de-problemas)

---

## 🎯 Descripción General

UIDE-Link es un sistema de telemetría con enfoque **offline-first** diseñado para rastrear el uso de autobuses universitarios por parte de los estudiantes, incluso en zonas con **CERO conectividad a internet**. El sistema utiliza tecnología de Progressive Web App (PWA) con Service Workers e IndexedDB para encolar escaneos localmente y sincronizar automáticamente cuando se restablece la conexión.

### El Problema
- Los autobuses universitarios atraviesan zonas sin señal celular
- Los sistemas tradicionales fallan cuando no hay conexión
- Los estudiantes necesitan retroalimentación instantánea al escanear códigos QR

### La Solución
- **Arquitectura offline-first**: Los escaneos se registran instantáneamente sin red
- **Sincronización automática en segundo plano**: Los datos se sincronizan cuando se restablece la conexión
- **Service Workers**: Cachean la aplicación para uso offline
- **IndexedDB**: Base de datos local para la cola de escaneos
- **Códigos QR estáticos**: No se necesitan tablets en los autobuses

---

## ✨ Características Principales

### 🔌 Diseño Offline-First
- ✅ Escanear códigos QR sin conexión a internet
- ✅ Reintento automático con Background Sync API
- ✅ Indicador visual de estado offline/online
- ✅ Contador de escaneos pendientes

### 🚀 Rendimiento
- ⚡ Registro de escaneos en <1 segundo
- ⚡ Sincronización masiva (100 escaneos en <2 segundos)
- ⚡ Cache con Service Worker para carga instantánea

### 🔒 Seguridad
- 🔐 Autenticación JWT (tokens de 24 horas)
- 🔐 Códigos QR estáticos con validación de ID de autobús
- 🔐 Detección de conflictos para escaneos duplicados
- 🔐 HTTPS requerido para Service Workers

### 📊 Analítica
- 📈 Seguimiento en tiempo real de la ocupación de autobuses
- 📈 Reportes diarios de uso
- 📈 Estadísticas de uso de rutas

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────┐
│      Dispositivo del Estudiante (Offline)   │
│  ┌─────────────────────────────────────┐   │
│  │  PWA (HTML/CSS/JS)                  │   │
│  │  - Escáner QR                       │   │
│  │  - Login/Autenticación              │   │
│  └─────────────────────────────────────┘   │
│           ↓                                 │
│  ┌─────────────────────────────────────┐   │
│  │  Service Worker                     │   │
│  │  - Cache de recursos estáticos      │   │
│  │  - Estrategia network-first para API│   │
│  │  - Background Sync                  │   │
│  └─────────────────────────────────────┘   │
│           ↓                                 │
│  ┌─────────────────────────────────────┐   │
│  │  IndexedDB                          │   │
│  │  - Cola de escaneos (offline)       │   │
│  │  - Datos de usuario (token)         │   │
│  │  - Cache de rutas                   │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
                    ↓ (cuando hay conexión)
         ┌──────────────────────┐
         │   API Express        │
         │   - /api/auth/*      │
         │   - /api/scans/*     │
         │   - /api/routes      │
         └──────────────────────┘
                    ↓
         ┌──────────────────────┐
         │   PostgreSQL         │
         │   - scan_events      │
         │   - students         │
         │   - buses            │
         └──────────────────────┘
```

### Stack Tecnológico

**Backend:**
- Node.js 18+ con Express
- PostgreSQL 12+
- JWT para autenticación
- bcrypt para hash de contraseñas

**Frontend:**
- Progressive Web App (PWA)
- JavaScript Vanilla (sin frameworks - optimizado para velocidad)
- Service Worker API
- IndexedDB API
- Background Sync API
- Librería html5-qrcode

**Despliegue:**
- AWS (EC2 para backend, RDS para PostgreSQL, S3 para archivos estáticos)
- HTTPS requerido (Let's Encrypt)

---

## 📦 Prerrequisitos

Antes de la instalación, asegúrate de tener:

- **Node.js** 18+ ([descargar](https://nodejs.org/))
- **PostgreSQL** 12+ ([descargar](https://www.postgresql.org/download/))
- **Git** ([descargar](https://git-scm.com/))
- **Navegador web** con soporte para Service Workers (Chrome, Firefox, Safari, Edge)

---

## 🚀 Instalación

### 1. Clonar el Repositorio

```bash
git clone <url-del-repositorio>
cd "proyecto de buses UIDE"
```

### 2. Configuración de la Base de Datos

#### Crear la base de datos PostgreSQL:

```bash
# Iniciar sesión en PostgreSQL
psql -U postgres

# Crear base de datos
CREATE DATABASE uide_link;
\q
```

#### Ejecutar migraciones:

```bash
cd database
psql -U postgres -d uide_link -f schema.sql
psql -U postgres -d uide_link -f seed.sql
```

### 3. Configuración del Backend

```bash
cd backend

# Instalar dependencias
npm install

# Crear archivo .env
cp .env.example .env

# Editar .env con tus configuraciones
# Windows:
notepad .env
# Linux/Mac:
nano .env
```

**Configurar `.env`:**

```env
DATABASE_URL=postgresql://postgres:TU_CONTRASEÑA@localhost:5432/uide_link
JWT_SECRET=tu-clave-super-secreta-cambia-esto
PORT=3000
FRONTEND_URL=http://localhost:8080
```

#### Iniciar el backend:

```bash
npm run dev
```

El servidor debería iniciarse en `http://localhost:3000`

### 4. Configuración del Frontend

```bash
cd ../frontend

# Instalar un servidor HTTP simple
npm install -g http-server

# Servir el frontend
http-server public -p 8080 -c-1
```

El frontend debería estar disponible en `http://localhost:8080`

### 5. Generar Iconos para la PWA

Necesitas crear dos archivos de icono en `frontend/public/icons/`:
- `icon-192.png` (192x192px)
- `icon-512.png` (512x512px)

Usa cualquier herramienta de diseño gráfico o generador en línea con el logo/marca de la UIDE.

---

## 📱 Uso

### Para Estudiantes

1. **Abrir la aplicación**: Navegar a `http://localhost:8080/student.html`
2. **Iniciar sesión**:
   - Email: `maria.garcia@uide.edu.ec`
   - Contraseña: `uide2024`
3. **Escanear código QR**: Hacer clic en "Escanear Código QR"
4. **Seleccionar tipo**: Elegir "Ingreso" (entrando al autobús) o "Salida" (saliendo del autobús)
5. **Ver historial**: Ver tus escaneos en la sección de historial

**Modo Offline:**
- Activar el modo avión en tu dispositivo
- Escanear códigos QR normalmente
- Los escaneos se encolan localmente
- Desactivar modo avión → sincronización automática

### Para Conductores

1. **Abrir la aplicación**: Navegar a `http://localhost:8080/driver.html`
2. **Iniciar sesión**:
   - Email: `raul.rivera@uide.edu.ec`
   - Contraseña: `driver2024`
3. **Mostrar código QR**: Mostrar el código QR a los estudiantes
4. **Ver estadísticas**: Ver estadísticas de embarque en tiempo real

---

## 🌐 Despliegue

### Despliegue en AWS (Recomendado)

#### 1. Despliegue del Backend (EC2)

```bash
# SSH a la instancia EC2
ssh -i tu-clave.pem ubuntu@tu-ip-ec2

# Instalar Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Instalar PostgreSQL o usar RDS
# (Recomendado: Usar AWS RDS para producción)

# Clonar repositorio
git clone <url-del-repositorio>
cd "proyecto de buses UIDE/backend"

# Instalar dependencias
npm install --production

# Configurar entorno
nano .env
# Configurar DATABASE_URL, JWT_SECRET, etc. para producción

# Instalar PM2 para gestión de procesos
sudo npm install -g pm2

# Iniciar servidor
pm2 start server.js --name uide-link-api
pm2 startup
pm2 save
```

#### 2. Despliegue del Frontend (S3 + CloudFront)

```bash
# Instalar AWS CLI
aws configure

# Construir frontend (si se usa bundler) o subir directamente
cd frontend/public

# Subir a S3
aws s3 sync . s3://nombre-de-tu-bucket --acl public-read

# Configurar distribución de CloudFront
# Apuntar al bucket S3
# Habilitar HTTPS (requerido para Service Workers)
```

#### 3. Base de Datos (RDS)

- Crear instancia RDS de PostgreSQL
- Grupos de seguridad: Permitir conexión desde el EC2 del backend
- Ejecutar migraciones:

```bash
psql -h tu-endpoint-rds -U postgres -d uide_link -f schema.sql
psql -h tu-endpoint-rds -U postgres -d uide_link -f seed.sql
```

### Configuración HTTPS (Requerido para PWA)

```bash
# Instalar Nginx
sudo apt-get install nginx

# Instalar Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtener certificado SSL
sudo certbot --nginx -d tudominio.com
```

---

## 🧪 Probando la Funcionalidad Offline

### Escenario de Prueba 1: Escaneo Offline Básico

1. Abrir la aplicación de estudiante en Chrome
2. Iniciar sesión exitosamente
3. Abrir DevTools → pestaña Network
4. Seleccionar "Offline" del menú de throttling
5. Escanear un código QR (usar QR del panel del conductor)
6. Verificar: Escaneo registrado instantáneamente, muestra "1 escaneo pendiente"
7. Seleccionar "Online" del throttling
8. Verificar: La auto-sincronización ocurre, muestra "Todo sincronizado"

### Escenario de Prueba 2: Sincronización Masiva Offline

1. Escanear 10 códigos QR estando offline
2. Revisar IndexedDB (DevTools → Application → IndexedDB → UIDELinkDB → scans)
3. Verificar: 10 registros en la cola
4. Volver a estar online
5. Verificar: Los 10 sincronizados en menos de 2 segundos

### Escenario de Prueba 3: Cache con Service Worker

1. Abrir la aplicación estando online
2. Pasar a offline
3. Cerrar la pestaña y reabrir
4. Verificar: La aplicación carga desde el cache, la interfaz es visible
5. Verificar: Los recursos estáticos son servidos desde el cache

---

## 📚 Documentación de la API

### Autenticación

#### `POST /api/auth/login`
Inicio de sesión para estudiantes, conductores o administradores.

**Solicitud:**
```json
{
  "email": "student@uide.edu.ec",
  "password": "password123",
  "userType": "student"
}
```

**Respuesta:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { "id": 1, "first_name": "Maria", ... },
  "userType": "student",
  "expiresIn": "24h"
}
```

### Escaneos

#### `POST /api/scans/bulk`
Sincronizar escaneos offline (endpoint masivo).

**Encabezados:**
```
Authorization: Bearer <token>
```

**Solicitud:**
```json
{
  "scans": [
    {
      "clientId": "uuid-here",
      "busId": 1,
      "eventType": "ingress",
      "localTimestamp": "2024-01-15T07:05:00Z"
    }
  ]
}
```

**Respuesta:**
```json
{
  "success": true,
  "summary": {
    "total": 1,
    "synced": 1,
    "conflicts": 0,
    "errors": 0
  }
}
```

#### `GET /api/scans/student/:studentId`
Obtener historial de escaneos de un estudiante.

**Parámetros de consulta:** `?days=7&limit=50`

### Rutas

#### `GET /api/routes`
Obtener todas las rutas activas.

#### `GET /api/schedules`
Obtener horarios de operación (llegadas/salidas).

---

## 🐛 Solución de Problemas

### Service Worker No Se Registra

**Problema:** La consola muestra "Service Worker registration failed"

**Soluciones:**
1. Asegurar HTTPS (o localhost para pruebas)
2. Verificar compatibilidad del navegador
3. Limpiar cache del navegador y re-registrar

### Conexión a Base de Datos Fallida

**Problema:** El backend muestra "Database connection error"

**Soluciones:**
1. Verificar que PostgreSQL esté corriendo: `sudo systemctl status postgresql`
2. Revisar `DATABASE_URL` en `.env`
3. Probar conexión: `psql -U postgres -d uide_link`

### Escaneos No Se Sincronizan

**Problema:** Los escaneos se quedan en estado "pendiente"

**Soluciones:**
1. Revisar la consola del navegador en busca de errores
2. Verificar que el backend esté corriendo y accesible
3. Verificar que el token JWT no haya expirado (re-iniciar sesión)
4. Inspeccionar la pestaña Network en busca de solicitudes fallidas

### Escáner QR No Funciona

**Problema:** La cámara no inicia

**Soluciones:**
1. Otorgar permisos de cámara
2. Usar HTTPS (la cámara requiere contexto seguro)
3. Probar en otro navegador
4. Verificar compatibilidad del navegador

---

## 📖 Recursos Adicionales

- **Progressive Web Apps**: [web.dev/progressive-web-apps](https://web.dev/progressive-web-apps/)
- **Service Workers**: [developer.mozilla.org](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- **Background Sync**: [web.dev/background-sync](https://web.dev/background-sync/)
- **IndexedDB**: [developer.mozilla.org](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)

---

## 📝 Licencia

© 2024 Universidad Internacional del Ecuador (UIDE). Todos los derechos reservados.

---

## 👥 Soporte

Para soporte, contacta al departamento de TI de la UIDE o crea un issue en el repositorio.

---

## 🎓 Acerca de la UIDE

La Universidad Internacional del Ecuador (UIDE) está comprometida con proveer educación de calidad y soluciones innovadoras para el transporte estudiantil.

**UIDE-Link** está diseñado para mejorar la seguridad y eficiencia de los servicios de transporte universitario a través de tecnología web moderna.
