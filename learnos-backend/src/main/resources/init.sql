-- ============================================================
-- LearnOS LMS — Database Initialization Script
-- PostgreSQL 15+
-- Run this ONCE before starting the application
-- ============================================================

-- Create database (run as postgres superuser)
-- CREATE DATABASE learnos_db;
-- \c learnos_db;

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ── Companies (Tenants) ──
CREATE TABLE IF NOT EXISTS companies (
                                         id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name            VARCHAR(255) NOT NULL UNIQUE,
    subdomain       VARCHAR(100) UNIQUE,
    logo_url        TEXT,
    primary_color   VARCHAR(10) DEFAULT '#01696F',
    contact_email   VARCHAR(255) NOT NULL UNIQUE,
    contact_phone   VARCHAR(20),
    status          VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    max_learners    INT NOT NULL DEFAULT 100,
    can_create_courses BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- ── Users ──
CREATE TABLE IF NOT EXISTS users (
                                     id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email            VARCHAR(255) NOT NULL UNIQUE,
    password         VARCHAR(255) NOT NULL,
    first_name       VARCHAR(100) NOT NULL,
    last_name        VARCHAR(100) NOT NULL,
    phone            VARCHAR(20),
    profile_image_url TEXT,
    role             VARCHAR(30) NOT NULL DEFAULT 'USER',
    company_id       UUID REFERENCES companies(id) ON DELETE SET NULL,
    enabled          BOOLEAN NOT NULL DEFAULT FALSE,
    email_verified   BOOLEAN NOT NULL DEFAULT FALSE,
    active           BOOLEAN NOT NULL DEFAULT TRUE,
    otp_code         VARCHAR(6),
    otp_expiry       TIMESTAMP,
    refresh_token    TEXT,
    login_attempts   INT NOT NULL DEFAULT 0,
    last_login_at    TIMESTAMP,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- Indexes
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_company ON users(company_id);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_companies_subdomain ON companies(subdomain);

-- ── Auto update timestamp trigger ──
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
                         FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE OR REPLACE TRIGGER trg_companies_updated_at
    BEFORE UPDATE ON companies
                      FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── Seed Super Admin ──
-- Password: Admin@LearnOS2026 (BCrypt encoded)
INSERT INTO users (id, email, password, first_name, last_name, role, enabled, email_verified)
VALUES (
           uuid_generate_v4(),
           'admin@learnos.in',
           '$2a$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
           'Super',
           'Admin',
           'ADMIN',
           TRUE,
           TRUE
       ) ON CONFLICT (email) DO NOTHING;

-- ── Seed Demo Company ──
INSERT INTO companies (id, name, subdomain, contact_email, status)
VALUES (
           uuid_generate_v4(),
           'Sagar Hospitals',
           'sagar',
           'training@sagarhospitals.in',
           'ACTIVE'
       ) ON CONFLICT DO NOTHING;

SELECT 'LearnOS database initialized successfully!' AS status;