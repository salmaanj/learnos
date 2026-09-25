CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(255),
    system_role BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(120) NOT NULL UNIQUE,
    description VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS role_permissions (
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE RESTRICT,
    PRIMARY KEY (user_id, role_id)
);

CREATE INDEX IF NOT EXISTS idx_user_roles_user_id
    ON user_roles(user_id);

CREATE INDEX IF NOT EXISTS idx_user_roles_role_id
    ON user_roles(role_id);

INSERT INTO roles (name, description, system_role)
VALUES
    ('SUPER_ADMIN', 'Full platform access across all companies', TRUE),
    ('ADMIN', 'Full company administration access', TRUE),
    ('TUTOR', 'Course and teaching access', TRUE),
    ('USER', 'Content management and learner management access', TRUE)
ON CONFLICT (name) DO NOTHING;

INSERT INTO permissions (code, description)
VALUES
    ('PLATFORM_ADMIN', 'Access platform-wide administration'),
    ('COMPANY_ADMIN', 'Manage company administration'),
    ('USERS_VIEW', 'View staff users'),
    ('USERS_CREATE', 'Create staff users'),
    ('USERS_UPDATE', 'Update staff users'),
    ('USERS_DELETE', 'Delete staff users'),
    ('COURSES_VIEW', 'View courses'),
    ('COURSES_CREATE', 'Create courses'),
    ('COURSES_UPDATE', 'Update courses'),
    ('COURSES_DELETE', 'Delete courses'),
    ('LIVE_CLASSES_VIEW', 'View live classes'),
    ('LIVE_CLASSES_MANAGE', 'Create and manage live classes'),
    ('CONTENT_LIBRARY_MANAGE', 'Manage content library'),
    ('QUIZZES_MANAGE', 'Manage quizzes'),
    ('CERTIFICATES_MANAGE', 'Manage certificates'),
    ('ADS_MANAGE', 'Manage advertisements')
ON CONFLICT (code) DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
CROSS JOIN permissions p
WHERE r.name = 'SUPER_ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p
  ON p.code IN (
      'COMPANY_ADMIN',
      'USERS_VIEW',
      'USERS_CREATE',
      'USERS_UPDATE',
      'USERS_DELETE',
      'COURSES_VIEW',
      'COURSES_CREATE',
      'COURSES_UPDATE',
      'COURSES_DELETE',
      'LIVE_CLASSES_VIEW',
      'LIVE_CLASSES_MANAGE',
      'CONTENT_LIBRARY_MANAGE',
      'QUIZZES_MANAGE',
      'CERTIFICATES_MANAGE'
  )
WHERE r.name = 'ADMIN'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p
  ON p.code IN (
      'COURSES_VIEW',
      'COURSES_CREATE',
      'COURSES_UPDATE',
      'COURSES_DELETE',
      'LIVE_CLASSES_VIEW',
      'LIVE_CLASSES_MANAGE',
      'CONTENT_LIBRARY_MANAGE',
      'QUIZZES_MANAGE',
      'CERTIFICATES_MANAGE'
  )
WHERE r.name = 'TUTOR'
ON CONFLICT DO NOTHING;

INSERT INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p
  ON p.code IN (
      'USERS_VIEW',
      'USERS_CREATE',
      'COURSES_VIEW',
      'COURSES_CREATE',
      'COURSES_UPDATE',
      'LIVE_CLASSES_VIEW',
      'LIVE_CLASSES_MANAGE',
      'CONTENT_LIBRARY_MANAGE',
      'QUIZZES_MANAGE',
      'CERTIFICATES_MANAGE'
  )
WHERE r.name = 'USER'
ON CONFLICT DO NOTHING;

INSERT INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u
JOIN roles r ON r.name = CASE
    WHEN LOWER(u.email) = 'admin@blute.co.in' THEN 'SUPER_ADMIN'
    ELSE u.role
END
WHERE u.role IN ('ADMIN', 'TUTOR', 'USER')
   OR LOWER(u.email) = 'admin@blute.co.in'
ON CONFLICT DO NOTHING;
