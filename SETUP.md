# UIDE-Link Setup Guide

This script will help you set up the UIDE-Link system on Windows.

## Prerequisites Check

Before running this setup, make sure you have installed:
- [x] Node.js 18+ (https://nodejs.org/)
- [x] PostgreSQL 12+ (https://www.postgresql.org/download/windows/)
- [x] Git (https://git-scm.com/)

## Step 1: Database Setup

1. Open PowerShell as Administrator
2. Start PostgreSQL service:
   ```powershell
   net start postgresql-x64-12
   ```

3. Create database:
   ```powershell
   psql -U postgres -c "CREATE DATABASE uide_link;"
   ```

4. Run migrations (from project root):
   ```powershell
   cd database
   psql -U postgres -d uide_link -f schema.sql
   psql -U postgres -d uide_link -f seed.sql
   cd ..
   ```

## Step 2: Backend Setup

1. Navigate to backend directory:
   ```powershell
   cd backend
   ```

2. Install dependencies:
   ```powershell
   npm install
   ```

3. Create .env file:
   ```powershell
   copy .env.example .env
   ```

4. Edit .env file with your settings:
   ```
   DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/uide_link
   JWT_SECRET=change-this-to-a-random-secret-key
   PORT=3000
   FRONTEND_URL=http://localhost:8080
   ```

5. Start backend server:
   ```powershell
   npm run dev
   ```

   Backend should now be running on http://localhost:3000

## Step 3: Frontend Setup

1. Open a NEW PowerShell window
2. Navigate to project root
3. Install http-server globally:
   ```powershell
   npm install -g http-server
   ```

4. Navigate to frontend:
   ```powershell
   cd frontend/public
   ```

5. Start frontend server:
   ```powershell
   http-server -p 8080 -c-1
   ```

   Frontend should now be running on http://localhost:8080

## Step 4: Create Icons (Optional)

You need two icon files in `frontend/public/icons/`:
- icon-192.png (192x192 pixels)
- icon-512.png (512x512 pixels)

Use the generated icon from artifacts or create your own with UIDE branding.

## Step 5: Access the Application

### Student Interface
URL: http://localhost:8080/student.html
Login: maria.garcia@uide.edu.ec / uide2024

### Driver Interface
URL: http://localhost:8080/driver.html
Login: raul.rivera@uide.edu.ec / driver2024

### Landing Page
URL: http://localhost:8080/

## Testing Offline Functionality

1. Open student interface in Chrome
2. Login successfully
3. Press F12 to open DevTools
4. Go to Network tab
5. Select "Offline" from throttling dropdown
6. Scan a QR code (use driver dashboard to get QR)
7. Verify scan is recorded and queued
8. Select "Online" to test auto-sync

## Production Deployment

For production deployment to AWS, follow the deployment guide in README.md.

Key considerations:
- Use AWS RDS for PostgreSQL
- Deploy backend on EC2 with PM2
- Host frontend on S3 + CloudFront
- Enable HTTPS (required for PWA)
- Set secure JWT_SECRET
- Configure CORS for production domain

## Troubleshooting

### Backend won't start
- Check PostgreSQL is running
- Verify DATABASE_URL in .env
- Check port 3000 is not in use

### Frontend won't load
- Check http-server is running
- Verify port 8080 is not in use
- Clear browser cache

### Service Worker issues
- HTTPS is required (or localhost for testing)
- Clear browser cache and reload
- Check browser console for errors

### QR Scanner not working
- Grant camera permissions
- Use HTTPS or localhost
- Try different browser (Chrome recommended)

## Need Help?

Check the README.md for detailed documentation or contact UIDE IT support.
