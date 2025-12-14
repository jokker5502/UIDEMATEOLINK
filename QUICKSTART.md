# UIDE-Link Quick Reference Card

## 🚀 Quick Start (Windows)

### 1. Start Database
```powershell
net start postgresql-x64-12
```

### 2. Start Backend (in project/backend)
```powershell
npm run dev
```
Backend runs on: **http://localhost:3000**

### 3. Start Frontend (in project/frontend/public)
```powershell
http-server -p 8080 -c-1
```
Frontend runs on: **http://localhost:8080**

---

## 🔐 Test Credentials

### Student
- **URL:** http://localhost:8080/student.html
- **Email:** maria.garcia@uide.edu.ec
- **Pass:** uide2024

### Driver
- **URL:** http://localhost:8080/driver.html  
- **Email:** raul.rivera@uide.edu.ec
- **Pass:** driver2024

---

## 📡 Testing Offline Mode

1. Open student.html in Chrome
2. Login
3. Press **F12** → Network tab
4. Select "**Offline**" from dropdown
5. Scan QR code
6. Verify: "1 escaneo pendiente"
7. Select "**Online**"
8. Auto-sync happens ✓

---

## 🔗 Key URLs

| Service | URL |
|---------|-----|
| Landing | http://localhost:8080 |
| Student | http://localhost:8080/student.html |
| Driver | http://localhost:8080/driver.html |
| API Health | http://localhost:3000/health |
| API Docs | http://localhost:3000/api |

---

## 📊 Database Quick Check

```sql
-- Check routes
SELECT COUNT(*) FROM routes;  -- Should be 31

-- Check students
SELECT COUNT(*) FROM students;  -- Should be 50

-- Check buses
SELECT COUNT(*) FROM buses;  -- Should be 15

-- View scans
SELECT * FROM scan_events ORDER BY local_timestamp DESC LIMIT 10;
```

---

## 🛠️ Troubleshooting

### Backend not starting?
```powershell
# Check PostgreSQL
Get-Service postgresql*

# Test database connection
psql -U postgres -d uide_link -c "SELECT 1;"
```

### Service Worker issues?
- Use **localhost** or **HTTPS**
- Clear cache: **Ctrl+Shift+Delete**
- Hard reload: **Ctrl+F5**

### QR Scanner not working?
- Grant camera permissions
- Use **Chrome** (best support)
- Check HTTPS/localhost

---

## 📁 Project Structure

```
proyecto de buses UIDE/
├── database/
│   ├── schema.sql      # Database schema
│   └── seed.sql        # Test data (31 routes)
├── backend/
│   ├── server.js       # Express API
│   ├── routes/         # API endpoints
│   └── .env            # Config (create from .env.example)
└── frontend/public/
    ├── index.html      # Landing page
    ├── student.html    # Student interface
    ├── driver.html     # Driver dashboard
    ├── sw.js           # Service Worker
    ├── js/
    │   ├── db.js       # IndexedDB
    │   ├── sync.js     # Sync manager
    │   └── scanner.js  # QR scanner
    └── css/
        └── styles.css  # Design system
```

---

## ⚡ Common Commands

```powershell
# Database
psql -U postgres -d uide_link -f database/schema.sql
psql -U postgres -d uide_link -f database/seed.sql

# Backend
cd backend
npm install
npm run dev

# Frontend
cd frontend/public
http-server -p 8080 -c-1

# Reset database
psql -U postgres -c "DROP DATABASE uide_link;"
psql -U postgres -c "CREATE DATABASE uide_link;"
# Then run schema.sql and seed.sql again
```

---

## 📞 Support

- **README.md** - Full documentation
- **SETUP.md** - Detailed setup guide
- **walkthrough.md** - Implementation details

**Need help?** Contact UIDE IT Department
