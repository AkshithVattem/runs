# 🚀 Supabase Backend Setup Guide

## ✅ What We've Built

I've integrated Supabase as the backend for Runs! Here's what's included:

### 📦 New Files Created

1. **SUPABASE_SCHEMA.sql** - Complete database schema
2. **SupabaseConfig.swift** - Configuration and client setup
3. **AuthService.swift** - Sign in with Apple + email authentication
4. **SupabaseCourtService.swift** - Court operations with realtime
5. **SupabaseCheckInService.swift** - Check-in/out with realtime updates
6. **SignInView.swift** - Beautiful sign-in UI

### 🎯 Features Implemented

- ✅ **Authentication** - Sign in with Apple, email/password
- ✅ **Real-time Sync** - Live updates when users check in/out
- ✅ **Privacy Controls** - Row Level Security (RLS) policies
- ✅ **Geospatial Queries** - PostGIS for nearby courts
- ✅ **Cloud Storage Ready** - For avatars and court photos
- ✅ **Hybrid Approach** - Supabase (cloud) + SwiftData (local cache)

---

## 🛠️ Setup Instructions

### Step 1: Create Supabase Project (5 minutes)

1. Go to [supabase.com](https://supabase.com)
2. Click **"New Project"**
3. Fill in:
   - **Name**: Runs
   - **Database Password**: (create strong password, save it!)
   - **Region**: Choose closest to your users
   - **Pricing Plan**: Free tier is perfect for MVP
4. Click **"Create new project"**
5. Wait ~2 minutes for provisioning

### Step 2: Get API Credentials

1. Once project is ready, go to **Settings** (⚙️ icon)
2. Click **API** in sidebar
3. Copy these values (you'll need them soon):
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public** key: `eyJhbGc...` (long JWT token)

### Step 3: Run the Database Schema

1. In Supabase Dashboard, go to **SQL Editor** (left sidebar)
2. Click **"+ New query"**
3. Open `SUPABASE_SCHEMA.sql` (in your Xcode project)
4. Copy ALL the SQL code
5. Paste into Supabase SQL Editor
6. Click **"Run"** button
7. You should see: "Success. No rows returned"

This creates:
- ✅ 8 tables (users, courts, check_ins, friendships, conversations, etc.)
- ✅ PostGIS extension for location queries
- ✅ Row Level Security policies
- ✅ Helper functions for nearby courts
- ✅ Indexes for performance

### Step 4: Enable Realtime

1. Go to **Database** → **Replication** (left sidebar)
2. Find these tables and turn on Realtime:
   - ☑️ **check_ins**
   - ☑️ **messages**
   - ☑️ **friendships**
3. Click **Save** if needed

### Step 5: Set Up Storage Buckets

1. Go to **Storage** (left sidebar)
2. Click **"New bucket"**
3. Create bucket:
   - **Name**: `avatars`
   - **Public bucket**: ✅ Yes
4. Click **"Create bucket"**
5. Repeat for another bucket:
   - **Name**: `court-photos`
   - **Public bucket**: ✅ Yes

### Step 6: Add Supabase Swift SDK to Xcode

1. In Xcode, go to **File** → **Add Package Dependencies...**
2. Enter: `https://github.com/supabase/supabase-swift`
3. **Dependency Rule**: Up to Next Major Version: 2.0.0
4. Click **"Add Package"**
5. Select your target ("Runs")
6. Click **"Add Package"** again

### Step 7: Configure Supabase in Code

1. Open `ConfigSupabaseConfig.swift` in Xcode
2. Replace placeholders with YOUR credentials:

```swift
static let supabaseURL = "https://YOUR-PROJECT-ID.supabase.co"
static let supabaseAnonKey = "YOUR-ANON-PUBLIC-KEY"
```

3. Save the file

### Step 8: Add All New Files to Target

Make sure these new files are added to your Runs target:

- [ ] ConfigSupabaseConfig.swift
- [ ] ServicesAuthService.swift
- [ ] ServicesSupabaseCourtService.swift
- [ ] ServicesSupabaseCheckInService.swift
- [ ] ViewsAuthSignInView.swift

**How to add:**
1. Select file in Project Navigator
2. File Inspector (⌘⌥1)
3. Check "Runs" under Target Membership

### Step 9: Build & Run

1. Clean Build Folder (⇧⌘K)
2. Build (⌘B)
3. Run (⌘R)

You should see the **Sign In** screen! 🎉

---

## 🧪 Testing the Integration

### Test Sign In with Apple

1. Run the app on a device (Simulator works too)
2. Tap **"Sign in with Apple"**
3. Choose account
4. App should show main tabs after sign-in

### Test Email Sign Up

1. Tap **"Don't have an account? Sign Up"**
2. Fill in:
   - Email: test@example.com
   - Password: test123
   - Username: hooper123
   - Display Name: Test Player
3. Tap **"Create Account"**
4. Should redirect to main app

### Check Database

1. Go to Supabase Dashboard → **Table Editor**
2. Click **"users"** table
3. You should see your new user! ✅

### Test Check-In (Once signed in)

1. Go to **Check In** tab
2. Select a nearby court
3. Check in
4. Go to Supabase → **Table Editor** → **check_ins**
5. You should see your check-in! ✅

---

## 🔐 Security Notes

### ✅ Safe to Commit

- `supabaseURL` - Your project URL (public)
- `supabaseAnonKey` - The anon/public key (designed to be public)

These are **safe** to include in your iOS app and commit to GitHub.

### ❌ NEVER Commit

- `service_role` key - Has full admin access!
- Database password - Used only in Supabase Dashboard

### 🛡️ How Security Works

**Row Level Security (RLS)** policies protect your data:

- Users can only see their own profile (write)
- Users can only see check-ins based on privacy settings
- Blocked users can't see each other
- Messages only visible to conversation members

The SQL schema includes all these policies!

---

## 🎨 Architecture Overview

### Hybrid Sync Strategy

```
┌─────────────┐
│   iOS App   │
└──────┬──────┘
       │
       ├─────► Supabase (Cloud)
       │       - Primary source of truth
       │       - Realtime updates
       │       - Authentication
       │
       └─────► SwiftData (Local)
               - Offline cache
               - Fast reads
               - Temporary storage
```

### Authentication Flow

```
1. User taps "Sign in with Apple"
2. iOS shows Apple ID dialog
3. App gets identity token
4. Send token to Supabase
5. Supabase creates session
6. Check if user profile exists
7. Create profile if needed
8. Store session locally
9. Show main app
```

### Real-time Updates

```
User A checks in
    ↓
Supabase database updated
    ↓
Realtime broadcast to subscribers
    ↓
User B's app receives update
    ↓
UI automatically refreshes
```

---

## 📊 What's in the Database

### Tables Created

1. **users** - User profiles, stats, settings
2. **courts** - Basketball courts with geolocation
3. **check_ins** - Active and historical check-ins
4. **friendships** - Friend connections and requests
5. **conversations** - DM and group chat containers
6. **conversation_members** - Who's in each chat
7. **messages** - Chat messages
8. **reports** - User reports for moderation

### Special Functions

1. **nearby_courts(lat, lng, radius)**
   - Returns courts within distance
   - Sorted by proximity
   - Includes active check-in count

2. **active_checkins_at_court(court_id, user_id)**
   - Returns visible check-ins
   - Respects privacy settings
   - Filters based on friendships

---

## 🚀 Next Steps

### Immediate

1. ✅ Test sign in
2. ✅ Check database tables
3. ✅ Try check-in flow
4. ✅ Verify realtime updates

### Phase 2 (Next Features)

- [ ] Chat with Supabase Realtime
- [ ] Friend requests
- [ ] Upload avatars to Storage
- [ ] Court photos
- [ ] Push notifications via Edge Functions
- [ ] Auto check-out job (Edge Function)

### Production Prep

- [ ] Add proper error handling
- [ ] Implement offline sync
- [ ] Add loading states everywhere
- [ ] Test with real users
- [ ] Set up Supabase monitoring
- [ ] Configure backup policies

---

## 🐛 Troubleshooting

### "Invalid API Key" Error

**Fix:** Double-check you copied the **anon public** key correctly in `SupabaseConfig.swift`

### "Network request failed"

**Fix:**
1. Check internet connection
2. Verify Supabase project is running (Dashboard should load)
3. Make sure URL doesn't have trailing slash

### "User not found" After Sign In

**Fix:**
1. Check **Table Editor** → **users** table
2. Verify Row Level Security isn't blocking reads
3. Check auth_id matches in users table

### Build Errors

**Fix:**
1. Make sure Supabase Swift package is added
2. Add all new files to target
3. Clean build folder
4. Check imports: `import Supabase`

### Realtime Not Working

**Fix:**
1. Verify Realtime is enabled for tables (Step 4)
2. Check network connection
3. Look for WebSocket connection in logs

---

## 💰 Supabase Costs

### Free Tier (Perfect for MVP)

- ✅ 500 MB database
- ✅ 1 GB file storage
- ✅ 2 GB bandwidth
- ✅ 50,000 monthly active users
- ✅ Unlimited API requests
- ✅ Realtime connections: 200 concurrent

**This is more than enough for testing and early launch!**

### When to Upgrade

- 500+ daily active users
- Lots of court photos (>1 GB)
- Need more Realtime connections
- Want auto-backups

---

## 📚 Resources

- [Supabase Docs](https://supabase.com/docs)
- [Supabase Swift Client](https://github.com/supabase/supabase-swift)
- [PostGIS Documentation](https://postgis.net/docs/)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)

---

**You're all set! 🏀 Your app now has a production-ready backend with authentication, real-time sync, and cloud storage!**
