# Supabase Backend Integration Guide

## 🎯 Overview

This guide walks through integrating Supabase as the backend for the Runs app, replacing local SwiftData with cloud-synced PostgreSQL + Realtime.

## 📋 Supabase Features We'll Use

1. **Authentication** - Sign in with Apple, email/password
2. **PostgreSQL Database** - Cloud storage for all data
3. **Realtime** - Live updates when users check in/out
4. **Storage** - Avatar and court photos
5. **Edge Functions** - Auto check-out jobs, notifications
6. **Row Level Security (RLS)** - Privacy controls

## 🛠️ Setup Steps

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up / Sign in
3. Click "New Project"
4. Fill in:
   - **Name**: Runs
   - **Database Password**: (save this!)
   - **Region**: Choose closest to your users
5. Wait for project to provision (~2 minutes)

### Step 2: Get API Credentials

Once your project is ready:

1. Go to **Project Settings** → **API**
2. Copy these values:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public** key: `eyJhbGc...` (long string)

You'll need these for the iOS app.

### Step 3: Set Up Database Schema

Run this SQL in the Supabase **SQL Editor**:

```sql
-- See SUPABASE_SCHEMA.sql for complete schema
-- (I'll create this file next)
```

### Step 4: Add Supabase Swift SDK

In Xcode:

1. File → Add Package Dependencies
2. Enter: `https://github.com/supabase/supabase-swift`
3. Add to your target
4. Import in your Swift files: `import Supabase`

## 📁 Files I'm Creating

1. **SUPABASE_SCHEMA.sql** - Complete database schema
2. **SupabaseConfig.swift** - Configuration and client setup
3. **AuthService.swift** - Sign in with Apple, email auth
4. **SupabaseUserService.swift** - User CRUD operations
5. **SupabaseCourtService.swift** - Court operations
6. **SupabaseCheckInService.swift** - Check-in/out with realtime
7. **SupabaseChatService.swift** - Messages with realtime
8. **Migration Guide** - How to migrate from SwiftData

## 🔐 Authentication Flow

```
1. User opens app
2. If not logged in → Show sign in screen
3. Sign in with Apple (or email)
4. Supabase creates session
5. Store session token
6. All API calls use authenticated user
```

## 📊 Data Sync Strategy

**Hybrid Approach:**
- Primary source: Supabase (cloud)
- Local cache: SwiftData (for offline)
- Realtime subscriptions for live updates

## 🚀 Next Steps

I'll now create:
1. Complete SQL schema
2. Supabase service layer
3. Migration from SwiftData to Supabase
4. Authentication views
5. Real-time sync logic

Let's start building! 🏀
