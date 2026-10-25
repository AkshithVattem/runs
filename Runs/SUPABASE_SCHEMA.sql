-- Runs Basketball App - Supabase Database Schema
-- Run this in your Supabase SQL Editor

-- ============================================
-- EXTENSIONS
-- ============================================

-- Enable PostGIS for location queries
CREATE EXTENSION IF NOT EXISTS postgis;

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLES
-- ============================================

-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    skill_level INTEGER DEFAULT 3 CHECK (skill_level >= 1 AND skill_level <= 5),
    positions TEXT[] DEFAULT '{}',
    height_inches INTEGER,
    checkin_visibility TEXT DEFAULT 'friends' CHECK (checkin_visibility IN ('everyone', 'friends', 'private')),
    total_checkins INTEGER DEFAULT 0,
    hours_played DECIMAL DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on username for fast lookups
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_auth_id ON users(auth_id);

-- Courts Table
CREATE TABLE courts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    geofence_radius_m INTEGER DEFAULT 150,
    is_indoor BOOLEAN DEFAULT false,
    num_hoops INTEGER DEFAULT 1,
    surface_type TEXT,
    has_lights BOOLEAN DEFAULT false,
    hours TEXT,
    photo_urls TEXT[] DEFAULT '{}',
    qr_secret TEXT,
    status TEXT DEFAULT 'approved' CHECK (status IN ('pending', 'approved', 'rejected')),
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Spatial index for fast location queries
CREATE INDEX idx_courts_location ON courts USING GIST(location);
CREATE INDEX idx_courts_status ON courts(status);

-- Check-ins Table
CREATE TABLE check_ins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    court_id UUID REFERENCES courts(id) ON DELETE CASCADE NOT NULL,
    status TEXT DEFAULT 'playing' CHECK (status IN ('playing', 'waiting', 'watching')),
    party_size INTEGER DEFAULT 1,
    method TEXT CHECK (method IN ('qr', 'geofence')),
    checked_in_at TIMESTAMPTZ DEFAULT NOW(),
    checked_out_at TIMESTAMPTZ,
    checkout_reason TEXT CHECK (checkout_reason IN ('manual', 'geofence_exit', 'timeout')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Unique constraint: one active check-in per user
CREATE UNIQUE INDEX idx_one_active_checkin 
ON check_ins(user_id) 
WHERE checked_out_at IS NULL;

-- Indexes for queries
CREATE INDEX idx_checkins_user ON check_ins(user_id);
CREATE INDEX idx_checkins_court ON check_ins(court_id);
CREATE INDEX idx_checkins_active ON check_ins(checked_out_at) WHERE checked_out_at IS NULL;

-- Friendships Table
CREATE TABLE friendships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    friend_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, friend_id)
);

CREATE INDEX idx_friendships_user ON friendships(user_id);
CREATE INDEX idx_friendships_friend ON friendships(friend_id);
CREATE INDEX idx_friendships_status ON friendships(status);

-- Conversations Table
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type TEXT CHECK (type IN ('dm', 'group')),
    name TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Conversation Members Table
CREATE TABLE conversation_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    last_read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(conversation_id, user_id)
);

CREATE INDEX idx_conv_members_conversation ON conversation_members(conversation_id);
CREATE INDEX idx_conv_members_user ON conversation_members(user_id);

-- Messages Table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    body TEXT,
    image_url TEXT,
    shared_court_id UUID REFERENCES courts(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_created_at ON messages(created_at DESC);

-- Reports Table (for moderation)
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    target_type TEXT CHECK (target_type IN ('user', 'message', 'court')),
    target_id UUID NOT NULL,
    reason TEXT NOT NULL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_target ON reports(target_type, target_id);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courts_updated_at BEFORE UPDATE ON courts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_friendships_updated_at BEFORE UPDATE ON friendships
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conversations_updated_at BEFORE UPDATE ON conversations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to get courts within radius
CREATE OR REPLACE FUNCTION nearby_courts(
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION,
    radius_meters INTEGER DEFAULT 10000
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    distance_meters DOUBLE PRECISION,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    is_indoor BOOLEAN,
    num_hoops INTEGER,
    has_lights BOOLEAN,
    active_checkins_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        ST_Distance(c.location, ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography) as distance_meters,
        ST_Y(c.location::geometry) as latitude,
        ST_X(c.location::geometry) as longitude,
        c.is_indoor,
        c.num_hoops,
        c.has_lights,
        COUNT(ci.id) as active_checkins_count
    FROM courts c
    LEFT JOIN check_ins ci ON ci.court_id = c.id AND ci.checked_out_at IS NULL
    WHERE c.status = 'approved'
        AND ST_DWithin(
            c.location,
            ST_SetSRID(ST_MakePoint(lng, lat), 4326)::geography,
            radius_meters
        )
    GROUP BY c.id
    ORDER BY distance_meters;
END;
$$ LANGUAGE plpgsql;

-- Function to get active check-ins with user visibility
CREATE OR REPLACE FUNCTION active_checkins_at_court(
    p_court_id UUID,
    p_requesting_user_id UUID
)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    username TEXT,
    display_name TEXT,
    avatar_url TEXT,
    status TEXT,
    party_size INTEGER,
    checked_in_at TIMESTAMPTZ,
    duration_seconds INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ci.id,
        ci.user_id,
        u.username,
        u.display_name,
        u.avatar_url,
        ci.status,
        ci.party_size,
        ci.checked_in_at,
        EXTRACT(EPOCH FROM (NOW() - ci.checked_in_at))::INTEGER as duration_seconds
    FROM check_ins ci
    JOIN users u ON u.id = ci.user_id
    WHERE ci.court_id = p_court_id
        AND ci.checked_out_at IS NULL
        AND (
            -- Show if visibility is everyone
            u.checkin_visibility = 'everyone'
            -- Or if they're friends
            OR (u.checkin_visibility = 'friends' AND EXISTS (
                SELECT 1 FROM friendships f
                WHERE f.status = 'accepted'
                    AND ((f.user_id = p_requesting_user_id AND f.friend_id = ci.user_id)
                        OR (f.friend_id = p_requesting_user_id AND f.user_id = ci.user_id))
            ))
            -- Or if it's the requesting user themselves
            OR ci.user_id = p_requesting_user_id
        )
    ORDER BY ci.checked_in_at;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE courts ENABLE ROW LEVEL SECURITY;
ALTER TABLE check_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Users Policies
CREATE POLICY "Users are viewable by everyone" ON users
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON users
    FOR UPDATE USING (auth.uid() = auth_id);

CREATE POLICY "Users can insert own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = auth_id);

-- Courts Policies
CREATE POLICY "Approved courts viewable by everyone" ON courts
    FOR SELECT USING (status = 'approved');

CREATE POLICY "Users can suggest courts" ON courts
    FOR INSERT WITH CHECK (auth.uid() IN (SELECT auth_id FROM users WHERE id = created_by));

-- Check-ins Policies
CREATE POLICY "Check-ins visible based on user privacy" ON check_ins
    FOR SELECT USING (
        -- User can see their own
        user_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
        -- Or if visibility allows
        OR user_id IN (
            SELECT id FROM users 
            WHERE checkin_visibility = 'everyone'
                OR (checkin_visibility = 'friends' AND id IN (
                    SELECT friend_id FROM friendships 
                    WHERE user_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
                        AND status = 'accepted'
                    UNION
                    SELECT user_id FROM friendships 
                    WHERE friend_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
                        AND status = 'accepted'
                ))
        )
    );

CREATE POLICY "Users can create own check-ins" ON check_ins
    FOR INSERT WITH CHECK (user_id IN (SELECT id FROM users WHERE auth_id = auth.uid()));

CREATE POLICY "Users can update own check-ins" ON check_ins
    FOR UPDATE USING (user_id IN (SELECT id FROM users WHERE auth_id = auth.uid()));

-- Friendships Policies
CREATE POLICY "Users can view friendships they're part of" ON friendships
    FOR SELECT USING (
        user_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
        OR friend_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
    );

CREATE POLICY "Users can create friendships" ON friendships
    FOR INSERT WITH CHECK (user_id IN (SELECT id FROM users WHERE auth_id = auth.uid()));

CREATE POLICY "Users can update friendships they're part of" ON friendships
    FOR UPDATE USING (
        user_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
        OR friend_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
    );

-- Messages Policies
CREATE POLICY "Users can view messages in their conversations" ON messages
    FOR SELECT USING (
        conversation_id IN (
            SELECT conversation_id FROM conversation_members
            WHERE user_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
        )
    );

CREATE POLICY "Users can send messages to their conversations" ON messages
    FOR INSERT WITH CHECK (
        sender_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
        AND conversation_id IN (
            SELECT conversation_id FROM conversation_members
            WHERE user_id = sender_id
        )
    );

-- Conversation Members Policies
CREATE POLICY "Users can view members of their conversations" ON conversation_members
    FOR SELECT USING (
        conversation_id IN (
            SELECT conversation_id FROM conversation_members cm
            WHERE cm.user_id IN (SELECT id FROM users WHERE auth_id = auth.uid())
        )
    );

-- Reports Policies
CREATE POLICY "Users can create reports" ON reports
    FOR INSERT WITH CHECK (reporter_id IN (SELECT id FROM users WHERE auth_id = auth.uid()));

-- ============================================
-- REALTIME PUBLICATION
-- ============================================

-- Enable realtime for tables that need live updates
ALTER PUBLICATION supabase_realtime ADD TABLE check_ins;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE friendships;

-- ============================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================

-- This will be inserted via the app after authentication
-- But you can add test courts here:

/*
INSERT INTO courts (name, location, is_indoor, num_hoops, surface_type, has_lights, hours, qr_secret) VALUES
('Mountain House Park', ST_SetSRID(ST_MakePoint(-122.4194, 37.7749), 4326), false, 2, 'Concrete', true, '6am - 10pm', 'secret_mountain_house'),
('Downtown Community Center', ST_SetSRID(ST_MakePoint(-122.4094, 37.7849), 4326), true, 4, 'Hardwood', true, '8am - 9pm', 'secret_downtown_cc'),
('Lakeside Recreation Area', ST_SetSRID(ST_MakePoint(-122.4294, 37.7649), 4326), false, 3, 'Asphalt', false, 'Dawn - Dusk', 'secret_lakeside');
*/

-- ============================================
-- INDEXES FOR PERFORMANCE
-- ============================================

-- Additional performance indexes
CREATE INDEX idx_checkins_duration ON check_ins(checked_in_at) WHERE checked_out_at IS NULL;
CREATE INDEX idx_messages_recent ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_users_lookup ON users(username, display_name);
