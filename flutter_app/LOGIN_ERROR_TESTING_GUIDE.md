## Login Error Testing Guide

### 🔍 Debug Steps to Test Snackbar

After making the changes, here's how to test and debug the login error snackbar:

#### **1. Check Debug Console Output**

When you try to login with wrong credentials, you should see this sequence in the debug console:

```
🔘 Login button pressed
✅ Form validation passed
📤 Sending login request for: wrong@email.com
🚀 Starting login process...
📧 Email: wrong@email.com
📡 Sending login request to http://10.0.2.2:8000/auth/login
🔥 Dio exception during login: DioExceptionType.badResponse
📄 Error response: {"message": "Invalid credentials"}
🔢 Status code: 401
🚨 DioException login error: Your name, email or password is wrong (Status: 401)
🔥 Server error during login: Your name, email or password is wrong
📱 Login page received state: AuthError
🔴 Showing error snackbar: Your name, email or password is wrong
```

#### **2. What You Should See on Screen**

- ✅ **No page refresh**
- ✅ **Red floating snackbar appears** with: "Your name, email or password is wrong"
- ✅ **Snackbar stays for 4 seconds**
- ✅ **Form fields remain filled**

#### **3. If Snackbar Still Doesn't Show**

**Most likely causes:**

1. **MongoDB not running** → Backend returns 500 errors instead of 401

   ```bash
   # Start MongoDB (run as Administrator)
   net start MongoDB
   ```

2. **Backend not running** → Network timeout instead of auth error

   ```bash
   # Check if backend is running on port 8000
   # Should show: "server is running on port 8000"
   ```

3. **Wrong URL configuration** → Check `app_constants.dart`

#### **4. Quick Test Method**

Try these test credentials:

- **Email:** `test@wrong.com`
- **Password:** `wrongpassword`

This should trigger the error flow and show the snackbar.

#### **5. Force Test (if needed)**

If you want to force test the snackbar, temporarily add this to the login button:

```dart
// Temporary test - remove after testing
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Your name, email or password is wrong'),
    backgroundColor: const Color(0xFFE53E3E),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    duration: const Duration(seconds: 4),
  ),
);
```

### 🎯 Expected Result

After trying wrong login credentials, you should see a red floating snackbar with the message "Your name, email or password is wrong" without any page refresh!
