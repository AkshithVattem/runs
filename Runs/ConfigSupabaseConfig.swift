//
//  SupabaseConfig.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import Supabase

/// Supabase configuration and shared client instance
struct SupabaseConfig {
    
    // MARK: - Configuration
    
    /// Your Supabase project URL
    /// Get this from: Supabase Dashboard → Settings → API → Project URL
    static let supabaseURL = "https://your-project-id.supabase.co"
    
    /// Your Supabase anon/public key
    /// Get this from: Supabase Dashboard → Settings → API → Project API keys → anon public
    static let supabaseAnonKey = "your-anon-key-here"
    
    // MARK: - Shared Client
    
    /// Shared Supabase client instance
    /// Use this throughout the app for all Supabase operations
    static let shared: SupabaseClient = {
        guard let url = URL(string: supabaseURL) else {
            fatalError("Invalid Supabase URL: \(supabaseURL)")
        }
        
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseAnonKey,
            options: SupabaseClientOptions(
                db: SupabaseClientOptions.DatabaseOptions(
                    schema: "public"
                ),
                auth: SupabaseClientOptions.AuthOptions(
                    autoRefreshToken: true,
                    persistSession: true,
                    detectSessionInUrl: false
                ),
                global: SupabaseClientOptions.GlobalOptions(
                    headers: [
                        "X-Client-Info": "runs-ios/1.0.0"
                    ]
                )
            )
        )
    }()
}

// MARK: - Environment-based Configuration (Optional)

extension SupabaseConfig {
    /// Use this for different environments (dev/staging/prod)
    static func client(for environment: Environment = .production) -> SupabaseClient {
        let config = environment.config
        
        guard let url = URL(string: config.url) else {
            fatalError("Invalid Supabase URL for \(environment): \(config.url)")
        }
        
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: config.anonKey
        )
    }
    
    enum Environment {
        case development
        case staging
        case production
        
        var config: (url: String, anonKey: String) {
            switch self {
            case .development:
                return (
                    url: "https://your-dev-project.supabase.co",
                    anonKey: "your-dev-anon-key"
                )
            case .staging:
                return (
                    url: "https://your-staging-project.supabase.co",
                    anonKey: "your-staging-anon-key"
                )
            case .production:
                return (
                    url: SupabaseConfig.supabaseURL,
                    anonKey: SupabaseConfig.supabaseAnonKey
                )
            }
        }
    }
}

// MARK: - Configuration Instructions

/*
 📝 SETUP INSTRUCTIONS:
 
 1. Create a Supabase project at https://supabase.com
 
 2. Get your credentials:
    - Go to: Project Settings → API
    - Copy "Project URL"
    - Copy "anon public" key
 
 3. Update this file:
    - Replace `supabaseURL` with your Project URL
    - Replace `supabaseAnonKey` with your anon public key
 
 4. Run the SQL schema:
    - Go to: SQL Editor in Supabase Dashboard
    - Run the contents of SUPABASE_SCHEMA.sql
 
 5. Enable Realtime:
    - Go to: Database → Replication
    - Enable for: check_ins, messages, friendships
 
 6. Set up Storage (for avatars/photos):
    - Go to: Storage
    - Create bucket: "avatars" (public)
    - Create bucket: "court-photos" (public)
 
 7. Test the connection:
    - Run the app
    - Check for connection errors
    - Try signing in
 
 ⚠️ SECURITY NOTE:
 The anon key is safe to use in your iOS app. It's designed to be public.
 Row Level Security (RLS) policies protect your data.
 Never commit your service_role key to source control!
 */
