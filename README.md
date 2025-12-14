# 🚌 UIDE-Link: Offline-First Bus Telemetry System

**Next-generation telemetry system for Universidad Internacional del Ecuador (UIDE) transportation**

[![Offline-First](https://img.shields.io/badge/Offline-First-success)](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)
[![PWA](https://img.shields.io/badge/PWA-Enabled-blue)](https://web.dev/progressive-web-apps/)
[![Node.js](https://img.shields.io/badge/Node.js-18+-green)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-12+-blue)](https://www.postgresql.org/)

---

## 📋 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Deployment](#deployment)
- [Testing Offline Functionality](#testing-offline-functionality)
- [API Documentation](#api-documentation)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

UIDE-Link is an **offline-first** telemetry system designed to track student ridership on university buses, even in zones with **ZERO internet connectivity**. The system uses Progressive Web App (PWA) technology with Service Workers and IndexedDB to queue scans locally and automatically sync when connection is restored.

### The Problem
- University buses travel through areas with no cellular signal
- Traditional systems fail when offline
- Students need instant feedback when scanning QR codes

### The Solution
- **Offline-first architecture**: Scans recorded instantly without network
- **Automatic background sync**: Data syncs when connection restored
- **Service Workers**: Cache app for offline use
- **IndexedDB**: Local database for scan queue
- **Static QR codes**: No tablets needed on buses

---

## ✨ Key Features

### 🔌 Offline-First Design
- ✅ Scan QR codes without internet connection
- ✅ Automatic retry with Background Sync API
- ✅ Visual offline/online indicator
- ✅ Pending scan counter

### 🚀 Performance
- ⚡ Scan recording in <1 second
- ⚡ Bulk sync (100 scans in <2 seconds)
- ⚡ Service Worker caching for instant load

### 🔒 Security
- 🔐 JWT authentication (24-hour tokens)
- 🔐 Static QR codes with bus ID validation
- 🔐 Conflict detection for duplicate scans
- 🔐 HTTPS required for Service Workers

### 📊 Analytics
- 📈 Real-time bus occupancy tracking
- 📈 Daily ridership reports
- 📈 Route usage statistics

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────┐
│         Student Device (Offline)            │
│  ┌─────────────────────────────────────┐   │
│  │  PWA (HTML/CSS/JS)                  │   │
│  │  - QR Scanner                       │   │
│  │  - Login/Auth                       │   │
│  └─────────────────────────────────────┘   │
│           ↓                                 │
│  ┌─────────────────────────────────────┐   │
│  │  Service Worker                     │   │
│  │  - Cache static assets              │   │
│  │  - Network-first for API            │   │
│  │  - Background Sync                  │   │
│  └─────────────────────────────────────┘   │
│           ↓                                 │
│  ┌─────────────────────────────────────┐   │
│  │  IndexedDB                          │   │
│  │  - Scan queue (offline)             │   │
│  │  - User data (token)                │   │
│  │  - Routes cache                     │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
                    ↓ (when online)
         ┌──────────────────────┐
         │   Express API        │
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

### Tech Stack

**Backend:**
- Node.js 18+ with Express
- PostgreSQL 12+
- JWT for authentication
- bcrypt for password hashing

**Frontend:**
- Progressive Web App (PWA)
- Vanilla JavaScript (no framework - optimized for speed)
- Service Worker API
- IndexedDB API
- Background Sync API
- html5-qrcode library

**Deployment:**
- AWS (EC2 for backend, RDS for PostgreSQL, S3 for static files)
- HTTPS required (Let's Encrypt)

---

## 📦 Prerequisites

Before installation, ensure you have:

- **Node.js** 18+ ([download](https://nodejs.org/))
- **PostgreSQL** 12+ ([download](https://www.postgresql.org/download/))
- **Git** ([download](https://git-scm.com/))
- **Web browser** with Service Worker support (Chrome, Firefox, Safari, Edge)

---

## 🚀 Installation

### 1. Clone Repository

```bash
git clone <repository-url>
cd "proyecto de buses UIDE"
```

### 2. Database Setup

#### Create PostgreSQL database:

```bash
# Login to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE uide_link;
\q
```

#### Run migrations:

```bash
cd database
psql -U postgres -d uide_link -f schema.sql
psql -U postgres -d uide_link -f seed.sql
```

### 3. Backend Setup

```bash
cd backend

# Install dependencies
npm install

# Create .env file
cp .env.example .env

# Edit .env with your settings
# Windows:
notepad .env
# Linux/Mac:
nano .env
```

**Configure `.env`:**

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/uide_link
JWT_SECRET=your-super-secret-key-change-this
PORT=3000
FRONTEND_URL=http://localhost:8080
```

#### Start backend:

```bash
npm run dev
```

Server should start on `http://localhost:3000`

### 4. Frontend Setup

```bash
cd ../frontend

# Install a simple HTTP server
npm install -g http-server

# Serve the frontend
http-server public -p 8080 -c-1
```

Frontend should be available at `http://localhost:8080`

### 5. Generate PWA Icons

You need to create two icon files in `frontend/public/icons/`:
- `icon-192.png` (192x192px)
- `icon-512.png` (512x512px)

Use any graphic design tool or online generator with the UIDE logo/branding.

---

## 📱 Usage

### For Students

1. **Open the app**: Navigate to `http://localhost:8080/student.html`
2. **Login**:
   - Email: `maria.garcia@uide.edu.ec`
   - Password: `uide2024`
3. **Scan QR code**: Click "Escanear Código QR"
4. **Select type**: Choose "Ingreso" (entering bus) or "Salida" (exiting bus)
5. **View history**: See your scans in the history section

**Offline Mode:**
- Turn on airplane mode on your device
- Scan QR codes as normal
- Scans are queued locally
- Turn off airplane mode → automatic sync

### For Drivers

1. **Open the app**: Navigate to `http://localhost:8080/driver.html`
2. **Login**:
   - Email: `raul.rivera@uide.edu.ec`
   - Password: `driver2024`
3. **Display QR code**: Show the QR code to students
4. **View stats**: See real-time boarding statistics

---

## 🌐 Deployment

### AWS Deployment (Recommended)

#### 1. Backend Deployment (EC2)

```bash
# SSH into EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-ip

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install PostgreSQL or use RDS
# (Recommended: Use AWS RDS for production)

# Clone repository
git clone <repository-url>
cd "proyecto de buses UIDE/backend"

# Install dependencies
npm install --production

# Set up environment
nano .env
# Configure production DATABASE_URL, JWT_SECRET, etc.

# Install PM2 for process management
sudo npm install -g pm2

# Start server
pm2 start server.js --name uide-link-api
pm2 startup
pm2 save
```

#### 2. Frontend Deployment (S3 + CloudFront)

```bash
# Install AWS CLI
aws configure

# Build frontend (if using bundler) or upload directly
cd frontend/public

# Upload to S3
aws s3 sync . s3://your-bucket-name --acl public-read

# Configure CloudFront distribution
# Point to S3 bucket
# Enable HTTPS (required for Service Workers)
```

#### 3. Database (RDS)

- Create PostgreSQL RDS instance
- Security groups: Allow backend EC2 to connect
- Run migrations:

```bash
psql -h your-rds-endpoint -U postgres -d uide_link -f schema.sql
psql -h your-rds-endpoint -U postgres -d uide_link -f seed.sql
```

### HTTPS Setup (Required for PWA)

```bash
# Install Nginx
sudo apt-get install nginx

# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com
```

---

## 🧪 Testing Offline Functionality

### Test Scenario 1: Basic Offline Scan

1. Open student app in Chrome
2. Login successfully
3. Open DevTools → Network tab
4. Select "Offline" from throttling dropdown
5. Scan a QR code (use QR from driver dashboard)
6. Verify: Scan recorded instantly, shows "1 escaneo pendiente"
7. Select "Online" from throttling
8. Verify: Auto-sync happens, shows "Todo sincronizado"

### Test Scenario 2: Bulk Offline Sync

1. Scan 10 QR codes while offline
2. Check IndexedDB (DevTools → Application → IndexedDB → UIDELinkDB → scans)
3. Verify: 10 records in queue
4. Go online
5. Verify: All 10 synced within 2 seconds

### Test Scenario 3: Service Worker Caching

1. Open app while online
2. Go offline
3. Close tab and reopen
4. Verify: App loads from cache, UI visible
5. Verify: Static assets served from cache

---

## 📚 API Documentation

### Authentication

#### `POST /api/auth/login`
Login for students, drivers, or admins.

**Request:**
```json
{
  "email": "student@uide.edu.ec",
  "password": "password123",
  "userType": "student"
}
```

**Response:**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": { "id": 1, "first_name": "Maria", ... },
  "userType": "student",
  "expiresIn": "24h"
}
```

### Scans

#### `POST /api/scans/bulk`
Sync offline scans (bulk endpoint).

**Headers:**
```
Authorization: Bearer <token>
```

**Request:**
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

**Response:**
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
Get scan history for a student.

**Query params:** `?days=7&limit=50`

### Routes

#### `GET /api/routes`
Get all active routes.

#### `GET /api/schedules`
Get operation hours (arrivals/departures).

---

## 🐛 Troubleshooting

### Service Worker Not Registering

**Problem:** Console shows "Service Worker registration failed"

**Solutions:**
1. Ensure HTTPS (or localhost for testing)
2. Check browser compatibility
3. Clear browser cache and re-register

### Database Connection Failed

**Problem:** Backend shows "Database connection error"

**Solutions:**
1. Verify PostgreSQL is running: `sudo systemctl status postgresql`
2. Check `DATABASE_URL` in `.env`
3. Test connection: `psql -U postgres -d uide_link`

### Scans Not Syncing

**Problem:** Scans stay in "pending" state

**Solutions:**
1. Check browser console for errors
2. Verify backend is running and accessible
3. Check JWT token not expired (re-login)
4. Inspect Network tab for failed requests

### QR Scanner Not Working

**Problem:** Camera doesn't start

**Solutions:**
1. Grant camera permissions
2. Use HTTPS (camera requires secure context)
3. Test on different browser
4. Check browser compatibility

---

## 📖 Additional Resources

- **Progressive Web Apps**: [web.dev/progressive-web-apps](https://web.dev/progressive-web-apps/)
- **Service Workers**: [developer.mozilla.org](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- **Background Sync**: [web.dev/background-sync](https://web.dev/background-sync/)
- **IndexedDB**: [developer.mozilla.org](https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API)

---

## 📝 License

© 2024 Universidad Internacional del Ecuador (UIDE). All rights reserved.

---

## 👥 Support

For support, contact the UIDE IT department or create an issue in the repository.

---

## 🎓 About UIDE

Universidad Internacional del Ecuador (UIDE) is committed to providing quality education and innovative solutions for student transportation.

**UIDE-Link** is designed to improve the safety and efficiency of university transportation services through modern web technology.
