# Add Family Member - Debug Guide

## 🚨 **Current Issue:**
When pressing the "Continue" button in the Add Member screen:
1. Member is not being added
2. Screen is not navigating to home

## 🔍 **Debugging Steps:**

### **Step 1: Check Console Logs**
When you press "Continue", look for these debug messages in VS Code Debug Console:

```
🚀 Adding family member: [nickname] ([role])
📡 Sending add family member request to http://10.0.2.2:8000/users
👤 Member name: [nickname]
📨 Add member response status: [status_code]
```

**If you see:**
- ✅ `✅ Family member added successfully` → API worked, check navigation
- ❌ `❌ Failed to add family member` → API failed, check backend
- 🌐 `No internet connection` → Check your backend server

### **Step 2: Common Issues & Solutions:**

#### **Issue 1: Backend Not Running**
```bash
# Start your backend server
cd path/to/guardian-grove-backend
npm start
# Should see: "server is running on port 8000"
```

#### **Issue 2: Wrong Field Names**
The frontend now sends:
```json
{
  "name": "Johnny",
  "birthday": "2015-06-22T00:00:00.000Z", 
  "gender": "male",
  "role": "child",
  "avatar": "assets/images/avatars/child/avatar1.png",
  "interests": ["sports", "music"]
}
```

Your backend expects these exact field names in the `createUser` controller.

#### **Issue 3: Authorization Issues**
Make sure the parent is logged in and has a valid JWT token.

#### **Issue 4: MongoDB Not Running**
```bash
# Windows (run as Administrator)
net start MongoDB
```

### **Step 3: Test Backend Directly**
Test your backend `/users` endpoint with Postman or curl:

```bash
curl -X POST http://localhost:8000/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "name": "TestChild",
    "birthday": "2015-01-01T00:00:00.000Z",
    "gender": "male", 
    "role": "child",
    "avatar": "assets/images/avatars/child/avatar1.png",
    "interests": ["sports"]
  }'
```

### **Step 4: Check Network Traffic**
In Chrome DevTools Network tab (if using web), look for:
- POST request to `/users`
- Response status (200 = success, 4xx/5xx = error)
- Response body with error details

## 🛠️ **Quick Fixes:**

### **Fix 1: Ensure Backend is Running**
1. Navigate to your backend folder
2. Run `npm start` or `node server.js`
3. Verify you see "server is running on port 8000"

### **Fix 2: Check JWT Token**
The parent must be logged in. If not, the request will fail with 401 Unauthorized.

### **Fix 3: Verify Field Mapping**
Check that your backend `createUser` controller expects:
- `name` (not `nickname`)
- `role` (not `type`)
- All other fields match

## 📱 **Test The Flow:**

1. **Login as Parent** first
2. **Navigate to Add Member** screen
3. **Fill all required fields**:
   - Member type (Child/Parent)
   - Avatar selection
   - Nickname
   - Birthday
   - Gender
   - Interests (for children)
4. **Press Continue**
5. **Watch Debug Console** for error messages
6. **Check if success message appears**
7. **Verify navigation to home screen**

## 🔧 **Expected Behavior:**

When everything works correctly:
1. ✅ Debug logs show API call details
2. ✅ Backend creates user and sends temp password email
3. ✅ Green success snackbar appears
4. ✅ Navigation to main app home screen
5. ✅ Family member appears in family list

Try these debugging steps and let me know what specific error messages you see!
