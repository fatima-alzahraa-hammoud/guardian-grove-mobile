# Leaderboard Backend Integration

This document explains how the leaderboard screen is connected to the backend API and database.

## 🏆 Overview

The leaderboard functionality has been successfully integrated with the backend API to fetch real family leaderboard data from the database. The system includes multiple fallback strategies to ensure the app works even when the backend is unavailable.

## 🔗 API Endpoints

The following API endpoints are used for leaderboard functionality:

### Primary Endpoints

- **`/families/leaderboard`** - Main leaderboard endpoint (limit parameter supported)
- **`/family/familyLeaderboard`** - Alternative family leaderboard endpoint
- **`/families`** - Families list endpoint
- **`/leaderboard/my-family`** - Current user's family rank

### Secondary Endpoints (for data aggregation)

- **`/users`** - Users endpoint with family data (`?includeFamily=true&populate=family`)

## 📁 File Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart          # API endpoint constants
│   └── utils/
│       └── leaderboard_backend_tester.dart  # Backend testing utility
├── data/
│   └── datasources/
│       └── remote/
│           └── leaderboard_remote_backend.dart  # Backend-connected data source
├── presentation/
│   ├── bloc/
│   │   └── leaderboard/
│   │       └── leaderboard_bloc.dart    # Updated BLoC with backend integration
│   └── pages/
│       └── main/
│           └── leaderboard_screen.dart  # UI with debug testing (debug mode only)
├── test/
│   └── leaderboard_tester.dart         # Easy testing utilities
└── injection_container.dart           # Updated dependency injection
```

## 🚀 Implementation Details

### 1. Data Source Layer (`leaderboard_remote_backend.dart`)

The main data source implements multiple strategies to fetch leaderboard data:

**Strategy 1**: Primary leaderboard endpoint

```dart
GET /families/leaderboard?limit=20
```

**Strategy 2**: Alternative endpoints when primary fails

- `/family/familyLeaderboard`
- `/families` (with member aggregation)
- `/users?includeFamily=true` (with family grouping)

**Strategy 3**: Fallback to local user data when all backends fail

### 2. Error Handling

The system handles various error scenarios:

- **Network errors**: Connection timeout, no internet
- **Server errors**: 500, 503, etc.
- **Not found errors**: 404 endpoints
- **Data parsing errors**: Invalid JSON structure
- **Authentication errors**: 401, 403

### 3. Data Transformation

The system can handle multiple response formats:

```json
// Format 1: Direct array
[{familyData}, {familyData}, ...]

// Format 2: Wrapped in data
{"data": [{familyData}, {familyData}, ...]}

// Format 3: Wrapped in families
{"families": [{familyData}, {familyData}, ...]}
```

### 4. Fallback System

When backends are unavailable, the system:

1. Uses current user's local data
2. Creates a single-family leaderboard
3. Shows realistic data (user's actual stars/coins)
4. Never shows fake competitor families

## 🧪 Testing & Debugging

### Debug Mode Features

In debug mode, the leaderboard screen includes:

- **Debug FAB**: Floating action button with bug icon
- **Backend Test**: Comprehensive API endpoint testing
- **Results Dialog**: Shows which endpoints are working
- **Console Logging**: Detailed debug information

### Testing Utilities

**Quick Test**:

```dart
import 'package:flutter_app/test/leaderboard_tester.dart';
await LeaderboardTester.quickTest();
```

**Endpoint Test**:

```dart
bool success = await LeaderboardTester.testEndpoint('/families/leaderboard');
```

**Status Check**:

```dart
Map<String, dynamic> status = await LeaderboardTester.getBackendStatus();
print('Backend working: ${status['backendConnection']}');
```

### Console Output Example

```
🧪 Testing Leaderboard Backend Connection
============================================================
🔍 Testing: Main Leaderboard
📡 Endpoint: http://10.0.2.2:8000/families/leaderboard
✅ Main Leaderboard: SUCCESS (200)
📊 Data received: true
📋 Response keys: [data, meta, status]
📈 Records count: 15
----------------------------------------
🎯 LEADERBOARD BACKEND TEST SUMMARY:
==================================================
🔗 Backend Connection: ✅ SUCCESS
📥 Data Retrieval: ✅ SUCCESS
👥 Current User Family: ✅ FOUND
🔄 Fallback System: ✅ WORKING
📊 Working Endpoints: 3/4

🎉 SUCCESS: Leaderboard screen is connected to backend!
```

## 🔧 Configuration

### Backend URL Configuration

Update the base URL in `app_constants.dart`:

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8000';

// For Real Device (replace with your computer's IP)
static const String baseUrl = 'http://192.168.1.100:8000';
```

### API Endpoints

All endpoints are centrally defined in `app_constants.dart`:

```dart
static const String leaderboardEndpoint = '/families/leaderboard';
static const String familyLeaderboardEndpoint = '/family/familyLeaderboard';
static const String familiesEndpoint = '/families';
static const String currentFamilyRankEndpoint = '/leaderboard/my-family';
```

## 📊 Expected API Response Format

### Leaderboard Response

```json
{
  "data": [
    {
      "_id": "family123",
      "name": "The Johnsons",
      "avatar": "https://example.com/avatar.jpg",
      "rank": 1,
      "stars": 150,
      "coins": 300,
      "totalPoints": 450,
      "members": [
        {
          "_id": "user123",
          "name": "John Doe",
          "avatar": "https://example.com/john.jpg"
        }
      ]
    }
  ],
  "meta": {
    "total": 25,
    "limit": 20,
    "page": 1
  }
}
```

### Current Family Rank Response

```json
{
  "data": {
    "_id": "family123",
    "name": "Your Family",
    "rank": 5,
    "stars": 120,
    "coins": 200,
    "totalPoints": 320,
    "members": [...]
  }
}
```

## 🐛 Troubleshooting

### Common Issues

1. **No data showing**:

   - Check backend server is running
   - Verify API endpoints are accessible
   - Check network connectivity
   - Use debug FAB to test endpoints

2. **Wrong base URL**:

   - Android Emulator: Use `10.0.2.2`
   - Real Device: Use your computer's IP address
   - Test with browser: `http://YOUR_IP:8000/families/leaderboard`

3. **Authentication errors**:
   - Ensure user is logged in
   - Check auth token is valid
   - Verify API requires authentication

### Debug Steps

1. **Enable debug mode**: Run app in debug mode
2. **Use debug FAB**: Tap bug icon on leaderboard screen
3. **Check console**: Look for detailed API logs
4. **Test endpoints**: Use `LeaderboardTester.quickTest()`

## 💡 Key Features

✅ **Real Backend Integration**: Fetches actual family data from database  
✅ **Multiple Fallback Strategies**: Works even when some endpoints fail  
✅ **Robust Error Handling**: Graceful degradation for all error types  
✅ **Debug Testing Tools**: Easy testing and troubleshooting  
✅ **Consistent UI**: No difference between backend and fallback modes  
✅ **Performance Optimized**: Caching and efficient API calls  
✅ **Scalable Architecture**: Easy to add new endpoints or modify existing ones

## 🔄 Data Flow

1. **User opens leaderboard screen**
2. **BLoC dispatches LoadLeaderboard event**
3. **Data source tries primary API endpoint**
4. **If successful**: Parse and display real family data
5. **If failed**: Try alternative endpoints
6. **If all fail**: Use fallback with current user data
7. **UI updates**: Shows leaderboard with proper loading/error states

The leaderboard screen is now fully connected to your backend and will display real family leaderboard data from your database! 🎉
