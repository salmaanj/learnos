# LearnOS Backend — Spring Boot API

## Prerequisites
- Java 17 (OpenJDK)
- PostgreSQL 15+
- Redis 7+
- Maven 3.8+

## Setup

### 1. Create Database
```sql
CREATE DATABASE learnos_db;
```
Then run `src/main/resources/init.sql` in psql.

### 2. Configure application.yml
Update these values in `src/main/resources/application.yml`:
- `spring.datasource.password` — your PostgreSQL password
- `jwt.secret` — change to a secure random 256-bit string
- `aws.s3.*` — your AWS credentials (optional for local dev)
- `spring.mail.*` — SendGrid API key

### 3. Run
```bash
mvn clean install
mvn spring-boot:run
```

### 4. API Docs
Open: http://localhost:8080/api/v1/swagger-ui.html

## Auth Endpoints
| Method | URL | Description |
|--------|-----|-------------|
| POST | /api/v1/auth/register | Register new user |
| POST | /api/v1/auth/verify-otp | Verify email OTP |
| POST | /api/v1/auth/resend-otp | Resend OTP |
| POST | /api/v1/auth/login | Login |
| POST | /api/v1/auth/refresh-token | Refresh JWT |
| POST | /api/v1/auth/forgot-password | Request password reset |
| POST | /api/v1/auth/reset-password | Reset password |
| POST | /api/v1/auth/logout | Logout |
| GET  | /api/v1/auth/me | Current user info |

## Default Super Admin
- Email: `admin@learnos.in`
- Password: `Admin@LearnOS2026`

## Tech Stack
- Spring Boot 3.2.5
- Java 17
- PostgreSQL 15
- Redis 7
- JWT (jjwt 0.11.5)
- AWS S3 SDK v2
- Swagger / SpringDoc OpenAPI
