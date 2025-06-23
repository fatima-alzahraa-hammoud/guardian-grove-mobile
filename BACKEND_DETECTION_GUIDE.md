# Backend Detection & Setup Guide

## 🔍 Quick Backend Detection

To find your running backend server, you can:

### Method 1: Use the Flutter App

1. Run your Flutter app
2. Go to the **Profile** tab (bottom navigation)
3. Tap **"Test Backend Connection"**
4. The app will automatically scan for your backend and show results

### Method 2: Check Manually

Open Command Prompt and run:

```cmd
# Check what's running on common ports
netstat -an | findstr :3000
netstat -an | findstr :8000
netstat -an | findstr :5000

# Or check all listening ports
netstat -an | findstr LISTENING
```

## 🎯 Expected Results

### If Backend is Running on Port 8000:

```
TCP    0.0.0.0:8000           0.0.0.0:0              LISTENING
TCP    [::]:8000              [::]:0                 LISTENING
```

### If Backend is Running on Port 3000:

```
TCP    0.0.0.0:3000           0.0.0.0:0              LISTENING
TCP    [::]:3000              [::]:0                 LISTENING
```

## 🛠️ Backend Setup Instructions

### If No Backend Found:

1. **Check if your backend server is running**
2. **Verify the correct port** (should be 8000 for your app)
3. **Ensure it's accessible from localhost**

### If Backend on Wrong Port:

- **Change your backend to port 8000**, OR
- **Update Flutter app config** to match your backend port

### Backend Endpoints Needed:

Your backend needs these endpoints for the chat feature:

```
GET    /chats/getChats          - Return user's chat list
POST   /chats/createChat        - Create new chat
POST   /chats/sendMessage       - Send message
POST   /ai/chat                 - AI chat endpoint (optional)
```

## 📱 App Configuration

Current app configuration:

- **Base URL**: `http://10.0.2.2:8000` (for Android emulator)
- **Alternative**: `http://localhost:8000` (for web/desktop)
- **Chat Endpoint**: `/ai/chat`

## 🔧 Quick Test Commands

### Test Backend Connectivity:

```cmd
# Test if backend responds
curl http://localhost:8000/
curl http://localhost:8000/health
curl http://localhost:8000/api/
```

### Test Chat Endpoints:

```cmd
# Test chat endpoints (if they exist)
curl http://localhost:8000/chats/getChats
curl http://localhost:8000/ai/chat
```

## 📊 Current Status

✅ **Flutter App**: Ready for backend integration
✅ **Chat UI**: Complete and functional with mock data
✅ **API Integration**: Configured and waiting for backend
⏳ **Backend**: Needs verification/setup

## 🆘 Troubleshooting

### Common Issues:

1. **"Connection refused"**

   - Backend server not running
   - Check if process is actually listening on the port

2. **"404 Not Found"**

   - Backend running but endpoints don't exist
   - Check your backend route configuration

3. **"500 Internal Server Error"**

   - Backend has errors
   - Check backend logs for details

4. **"Timeout"**
   - Backend taking too long to respond
   - Firewall blocking connection
   - Network issues

### Solutions:

- Use the Backend Test Screen in the app for automatic detection
- Check Windows Firewall settings
- Verify backend server logs
- Ensure correct IP/port configuration
