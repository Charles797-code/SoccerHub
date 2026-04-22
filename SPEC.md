# Soccer Community Management System - Technical Specification
## Oracle 21 + Spring Boot 3.2 + Vue 3 Modern Architecture Edition

---

## 1. Project Overview

**Project Name:** SoccerHub - 体育社区管理系统
**Project Type:** Full-stack modern sports community platform
**Core Summary:** A comprehensive football/soccer community platform enabling fans to follow clubs, rate players/coaches, participate in club chatrooms, and browse real-time match schedules. Built with Oracle 21 as the core data engine, Spring Boot 3.2 + JDK 21 (Virtual Threads) for the backend API layer, and Vue 3 + TypeScript + Vite for the frontend, packaged as a Tauri desktop application.

---

## 2. Technology Stack

### Client (Frontend)
- **Framework:** Vue 3 (Composition API + `<script setup>`)
- **Language:** TypeScript 5.x
- **Build Tool:** Vite 5.x
- **UI Library:** Element Plus (desktop-optimized)
- **State Management:** Pinia
- **Router:** Vue Router 4
- **HTTP Client:** Axios
- **WebSocket:** Native WebSocket API
- **Desktop Packaging:** Tauri 2.x (Rust-based)

### Server (Backend)
- **Framework:** Spring Boot 3.2.x
- **Language:** Java 21 (Virtual Threads)
- **ORM:** MyBatis-Plus 3.5.x
- **Database Driver:** Oracle JDBC (23.x compatible)
- **Cache:** Redis (for match schedules, leaderboards)
- **Security:** Spring Security 6 + JWT + Bcrypt
- **WebSocket:** Spring WebSocket (STOMP)
- **API Docs:** SpringDoc OpenAPI 3 (Swagger)
- **Build Tool:** Maven 3.9+

### Data Layer
- **DBMS:** Oracle Database 21c (Docker)
- **PL/SQL:** Stored procedures, triggers, packages, materialized views
- **JSON Support:** Oracle JSON relational duality

### DevOps
- **Container:** Docker + Docker Compose
- **Database Container:** gvenzl/oracle-free:21-slim

---

## 3. System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Tauri Desktop Client                     │
│         (Vue 3 + Element Plus + WebSocket)                 │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTPS/WSS
┌──────────────────────▼──────────────────────────────────────┐
│              Spring Boot 3.2 (JDK 21)                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Auth    │  │  Club/   │  │  Match/  │  │  Chat/   │   │
│  │ Module   │  │  Roster  │  │  Rating  │  │  WebSocket│   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Spring Security 6 (JWT + RBAC)          │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              MyBatis-Plus ORM Layer                   │  │
│  └──────────────────────────────────────────────────────┘  │
└──────────┬──────────────────┬──────────────────┬───────────┘
           │                  │                  │
    ┌──────▼──────┐   ┌──────▼──────┐   ┌──────▼──────┐
    │   Redis     │   │  Oracle 21  │   │  External   │
    │  (Cache)    │   │  (Primary)  │   │  (Fixtures) │
    └─────────────┘   └─────────────┘   └─────────────┘
```

---

## 4. User Roles & Permissions (RBAC)

| Role | Code | Permissions |
|------|------|-------------|
| 普通球迷 (Fan) | `FAN` | Browse clubs/players/matches, follow up to 3 clubs, post in followed club chatrooms, rate players in followed clubs, edit own profile |
| 俱乐部管理员 (Club Admin) | `CLUB_ADMIN` | All FAN permissions + manage own club roster (add/remove/update players), moderate own club chat (delete/collapse messages), view own club analytics |
| 系统超级管理员 (Super Admin) | `SUPER_ADMIN` | All permissions + create/edit/delete clubs, manage system dictionaries, full audit log access, global user management |

---

## 5. Database Schema (Oracle 21)

### 5.1 Entity Tables

#### SYS_USER (用户表)
| Column | Type | Constraints |
|--------|------|-------------|
| USER_ID | NUMBER | PK, IDENTITY |
| USERNAME | VARCHAR2(50) | UNIQUE, NOT NULL |
| PASSWORD_HASH | VARCHAR2(255) | NOT NULL |
| NICKNAME | VARCHAR2(100) | NOT NULL |
| EMAIL | VARCHAR2(100) | UNIQUE |
| AVATAR_URL | VARCHAR2(500) | |
| ROLE | VARCHAR2(20) | NOT NULL, CHECK (FAN/CLUB_ADMIN/SUPER_ADMIN) |
| STATUS | VARCHAR2(20) | DEFAULT 'ACTIVE' |
| CREATED_AT | TIMESTAMP | DEFAULT SYSTIMESTAMP |
| UPDATED_AT | TIMESTAMP | |

#### CLUB (俱乐部表)
| Column | Type | Constraints |
|--------|------|-------------|
| CLUB_ID | NUMBER | PK, IDENTITY |
| NAME | VARCHAR2(100) | NOT NULL |
| SHORT_NAME | VARCHAR2(20) | |
| LEAGUE | VARCHAR2(50) | NOT NULL |
| CITY | VARCHAR2(100) | |
| COUNTRY | VARCHAR2(100) | |
| STADIUM | VARCHAR2(200) | |
| ESTABLISH_DATE | DATE | |
| STADIUM_CAPACITY | NUMBER | |
| LOGO_URL | VARCHAR2(500) | |
| DESCRIPTION | CLOB | |
| TOTAL_SCORE | NUMBER(10,2) | DEFAULT 0 |
| CREATED_AT | TIMESTAMP | |

#### PLAYER (球员表)
| Column | Type | Constraints |
|--------|------|-------------|
| PLAYER_ID | NUMBER | PK, IDENTITY |
| NAME | VARCHAR2(100) | NOT NULL |
| NAME_CN | VARCHAR2(100) | |
| POSITION | VARCHAR2(20) | CHECK (GK/DF/MF/FW) |
| CLUB_ID | NUMBER | FK -> CLUB |
| JERSEY_NUMBER | NUMBER | |
| NATIONALITY | VARCHAR2(100) | |
| BIRTH_DATE | DATE | |
| HEIGHT_CM | NUMBER | |
| WEIGHT_KG | NUMBER | |
| STATUS | VARCHAR2(20) | DEFAULT 'ACTIVE' CHECK (ACTIVE/RETIRED/INJURED/FREE) |
| MARKET_VALUE | NUMBER | |
| AVATAR_URL | VARCHAR2(500) | |
| AVG_SCORE | NUMBER(4,2) | DEFAULT 0 |
| TOTAL_RATINGS | NUMBER | DEFAULT 0 |

#### COACH (教练表)
| Column | Type | Constraints |
|--------|------|-------------|
| COACH_ID | NUMBER | PK, IDENTITY |
| NAME | VARCHAR2(100) | NOT NULL |
| NAME_CN | VARCHAR2(100) | |
| CLUB_ID | NUMBER | FK -> CLUB |
| IS_HEAD_COACH | NUMBER(1) | DEFAULT 0 (Oracle 21 boolean emulation) |
| NATIONALITY | VARCHAR2(100) | |
| BIRTH_DATE | DATE | |
| AVATAR_URL | VARCHAR2(500) | |
| AVG_SCORE | NUMBER(4,2) | DEFAULT 0 |
| TOTAL_RATINGS | NUMBER | DEFAULT 0 |

#### MATCH_SCHEDULE (赛程表)
| Column | Type | Constraints |
|--------|------|-------------|
| MATCH_ID | VARCHAR2(50) | PK |
| HOME_CLUB_ID | NUMBER | FK -> CLUB |
| AWAY_CLUB_ID | NUMBER | FK -> CLUB |
| MATCH_TIME | TIMESTAMP | NOT NULL |
| HOME_SCORE | NUMBER | |
| AWAY_SCORE | NUMBER | |
| STATUS | VARCHAR2(20) | DEFAULT 'PENDING' CHECK (PENDING/IN_PROGRESS/FINISHED/CANCELLED) |
| ROUND | VARCHAR2(20) | |
| VENUE | VARCHAR2(200) | |
| REFEREE | VARCHAR2(100) | |
| LEAGUE | VARCHAR2(50) | |
| SEASON | VARCHAR2(20) | |
| UPDATED_AT | TIMESTAMP | |

### 5.2 Business & Relation Tables

#### USER_CLUB_FOLLOW (关注表)
| Column | Type | Constraints |
|--------|------|-------------|
| USER_ID | NUMBER | PK, FK -> SYS_USER |
| CLUB_ID | NUMBER | PK, FK -> CLUB |
| IS_PRIMARY | NUMBER(1) | DEFAULT 0 |
| FOLLOW_TIME | TIMESTAMP | DEFAULT SYSTIMESTAMP |

#### RATING_RECORD (评分明细表)
| Column | Type | Constraints |
|--------|------|-------------|
| RECORD_ID | NUMBER | PK, IDENTITY |
| USER_ID | NUMBER | FK -> SYS_USER |
| TARGET_ID | NUMBER | NOT NULL |
| TARGET_TYPE | VARCHAR2(10) | CHECK (PLAYER/COACH) |
| SCORE | NUMBER(2,0) | CHECK (1-10) |
| COMMENT_TEXT | VARCHAR2(500) | |
| RATING_TYPE | VARCHAR2(20) | CHECK (MATCH/SASON/GENERAL) |
| MATCH_ID | VARCHAR2(50) | FK -> MATCH_SCHEDULE |
| IS_COLLAPSED | NUMBER(1) | DEFAULT 0 |
| CREATED_AT | TIMESTAMP | DEFAULT SYSTIMESTAMP |

#### CLUB_CHAT_MESSAGE (聊天室消息表)
| Column | Type | Constraints |
|--------|------|-------------|
| MESSAGE_ID | NUMBER | PK, IDENTITY |
| CLUB_ID | NUMBER | FK -> CLUB, INDEX |
| USER_ID | NUMBER | FK -> SYS_USER |
| CONTENT | CLOB | NOT NULL |
| MESSAGE_TYPE | VARCHAR2(20) | DEFAULT 'TEXT' CHECK (TEXT/IMAGE/LINK/SYSTEM) |
| IS_DELETED | NUMBER(1) | DEFAULT 0 |
| DELETED_BY | NUMBER | |
| DELETED_AT | TIMESTAMP | |
| CREATED_AT | TIMESTAMP | DEFAULT SYSTIMESTAMP |

### 5.3 Audit & System Tables

#### TRANSFER_HISTORY_LOG (转会变动审计表)
| Column | Type | Constraints |
|--------|------|-------------|
| LOG_ID | NUMBER | PK, IDENTITY |
| PLAYER_ID | NUMBER | FK -> PLAYER |
| OLD_CLUB_ID | NUMBER | |
| NEW_CLUB_ID | NUMBER | |
| TRANSFER_TYPE | VARCHAR2(20) | CHECK (IN/OUT/LOAN/FREE) |
| TRANSFER_FEE | NUMBER | |
| SEASON | VARCHAR2(20) | |
| ACTION_USER_ID | NUMBER | FK -> SYS_USER |
| ACTION_TIME | TIMESTAMP | DEFAULT SYSTIMESTAMP |
| NOTES | VARCHAR2(500) | |

#### SYSTEM_DICTIONARY (系统字典表)
| Column | Type | Constraints |
|--------|------|-------------|
| DICT_ID | NUMBER | PK, IDENTITY |
| DICT_TYPE | VARCHAR2(50) | NOT NULL |
| DICT_KEY | VARCHAR2(100) | NOT NULL |
| DICT_VALUE | VARCHAR2(200) | NOT NULL |
| SORT_ORDER | NUMBER | DEFAULT 0 |
| IS_ENABLED | NUMBER(1) | DEFAULT 1 |
| DESCRIPTION | VARCHAR2(500) | |
| CREATED_AT | TIMESTAMP | |
| UPDATED_AT | TIMESTAMP | |

#### AUDIT_LOG (操作审计表)
| Column | Type | Constraints |
|--------|------|-------------|
| LOG_ID | NUMBER | PK, IDENTITY |
| USER_ID | NUMBER | FK -> SYS_USER |
| ACTION_MODULE | VARCHAR2(50) | |
| ACTION_TYPE | VARCHAR2(50) | |
| TARGET_TYPE | VARCHAR2(50) | |
| TARGET_ID | NUMBER | |
| OLD_VALUE | CLOB | |
| NEW_VALUE | CLOB | |
| IP_ADDRESS | VARCHAR2(50) | |
| USER_AGENT | VARCHAR2(500) | |
| ACTION_TIME | TIMESTAMP | DEFAULT SYSTIMESTAMP |

#### LEAGUE_STANDINGS (联赛积分榜表)
| Column | Type | Constraints |
|--------|------|-------------|
| STANDING_ID | NUMBER | PK, IDENTITY |
| LEAGUE | VARCHAR2(50) | NOT NULL |
| SEASON | VARCHAR2(20) | NOT NULL |
| CLUB_ID | NUMBER | FK -> CLUB |
| POSITION | NUMBER | |
| PLAYED | NUMBER | DEFAULT 0 |
| WON | NUMBER | DEFAULT 0 |
| DRAWN | NUMBER | DEFAULT 0 |
| LOST | NUMBER | DEFAULT 0 |
| GOALS_FOR | NUMBER | DEFAULT 0 |
| GOALS_AGAINST | NUMBER | DEFAULT 0 |
| GOAL_DIFF | NUMBER | DEFAULT 0 |
| POINTS | NUMBER | DEFAULT 0 |
| UPDATED_AT | TIMESTAMP | |

#### NEWS_ARTICLE (新闻文章表)
| Column | Type | Constraints |
|--------|------|-------------|
| ARTICLE_ID | NUMBER | PK, IDENTITY |
| TITLE | VARCHAR2(300) | NOT NULL |
| SUMMARY | VARCHAR2(500) | |
| CONTENT | CLOB | NOT NULL |
| AUTHOR_ID | NUMBER | FK -> SYS_USER |
| CLUB_ID | NUMBER | FK -> CLUB (nullable) |
| TAGS | VARCHAR2(500) | |
| COVER_IMAGE_URL | VARCHAR2(500) | |
| VIEW_COUNT | NUMBER | DEFAULT 0 |
| IS_PUBLISHED | NUMBER(1) | DEFAULT 1 |
| PUBLISHED_AT | TIMESTAMP | |
| CREATED_AT | TIMESTAMP | |

---

## 6. PL/SQL Components

### 6.1 Stored Procedures
- `osp_Submit_User_Rating` - Rating submission with anti-spam (24h limit + club follow check)
- `osp_Upsert_Match_Schedule` - UPSERT match data via MERGE INTO
- `osp_Transfer_Player` - Player transfer with history logging
- `osp_Moderate_Message` - Admin message moderation with audit trail
- `osp_Batch_Update_Standings` - Batch update league standings after matches

### 6.2 Triggers
- `tr_Calculate_Average_Score` - Auto-calculate player/coach average scores
- `tr_Audit_User_Rating` - Log all rating changes to audit table
- `tr_Auto_Maintain_Standings` - Auto-update standings on match completion
- `tr_Transfer_History_On_Player_Update` - Log club changes on player updates

### 6.3 Views
- `v_Club_Overview` - Club dashboard with player count, avg score, top player, head coach
- `v_Match_Live_Score` - Live match scores for real-time display
- `v_Player_Rankings` - Global player rankings by avg score
- `v_League_Standings_View` - Full league standings with club logos
- `v_Chat_Message_History` - Chat history with user info (non-deleted)

### 6.4 Sequences
- SEQ_SYS_USER, SEQ_CLUB, SEQ_PLAYER, SEQ_COACH, SEQ_RATING, SEQ_MESSAGE, SEQ_AUDIT, SEQ_TRANSFER, SEQ_DICTIONARY, SEQ_NEWS

---

## 7. API Endpoints

### Auth Module (`/api/auth`)
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | /register | User registration | Public |
| POST | /login | JWT login | Public |
| POST | /refresh | Refresh JWT token | JWT |
| GET | /profile | Get current user profile | JWT |
| PUT | /profile | Update user profile | JWT |

### Club Module (`/api/clubs`)
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | / | List all clubs (paginated, filterable) | Public |
| GET | /{id} | Get club detail | Public |
| GET | /{id}/overview | Club dashboard (view) | Public |
| GET | /{id}/players | Get club players | Public |
| GET | /{id}/coaches | Get club coaches | Public |
| POST | / | Create club | SUPER_ADMIN |
| PUT | /{id} | Update club | SUPER_ADMIN |
| DELETE | /{id} | Delete club | SUPER_ADMIN |

### Player Module (`/api/players`)
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | / | List players (paginated, filterable) | Public |
| GET | /{id} | Get player detail | Public |
| GET | /rankings | Get player rankings | Public |
| POST | / | Add player | CLUB_ADMIN (own club) |
| PUT | /{id} | Update player | CLUB_ADMIN (own club) |
| POST | /{id}/transfer | Transfer player | CLUB_ADMIN |
| DELETE | /{id} | Remove player | CLUB_ADMIN |

### Match Module (`/api/matches`)
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | / | List matches (filterable by date/league) | Public |
| GET | /{id} | Get match detail | Public |
| GET | /today | Today's matches | Public |
| GET | /live | Live matches | Public |
| POST | /upsert | Upsert match (from crawler) | API_KEY |

### Rating Module (`/api/ratings`)
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | / | Submit a rating | FAN |
| GET | /target/{type}/{id} | Get ratings for target | Public |
| GET | /my-ratings | Get current user's ratings | JWT |

### Follow Module (`/api/follows`)
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | / | Follow a club | FAN |
| DELETE | /{clubId} | Unfollow a club | FAN |
| GET | /my-follows | Get my followed clubs | JWT |
| GET | /{clubId}/followers | Get club followers | Public |

### Chat Module (`/api/chat`)
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | /{clubId}/messages | Get chat history | JWT (must follow) |
| POST | /{clubId}/messages | Send a message | JWT (must follow) |
| DELETE | /{clubId}/messages/{id} | Delete message | CLUB_ADMIN (own club) |
| PUT | /{clubId}/messages/{id}/collapse | Collapse message | CLUB_ADMIN |

### Admin Module (`/api/admin`)
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | /users | List users | SUPER_ADMIN |
| PUT | /users/{id}/role | Update user role | SUPER_ADMIN |
| GET | /audit-logs | Get audit logs | SUPER_ADMIN |
| GET | /dictionary | Get system dictionary | SUPER_ADMIN |
| POST | /dictionary | Add dictionary entry | SUPER_ADMIN |
| GET | /dashboard/stats | Dashboard statistics | SUPER_ADMIN |

### News Module (`/api/news`)
| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| GET | / | List news articles | Public |
| GET | /{id} | Get article detail | Public |
| POST | / | Create article | CLUB_ADMIN (own club) |
| PUT | /{id} | Update article | CLUB_ADMIN (own club) |

### WebSocket Endpoints
- `/ws/chat` - Real-time club chat (STOMP)
- `/ws/match` - Real-time match score updates

---

## 8. Security Architecture

### JWT Token Structure
```json
{
  "sub": "user_id",
  "username": "string",
  "role": "FAN|CLUB_ADMIN|SUPER_ADMIN",
  "managedClubId": "number (for CLUB_ADMIN)",
  "iat": "timestamp",
  "exp": "timestamp (24h)"
}
```

### Bcrypt Configuration
- Password encoder strength: 12 rounds
- Min password length: 8 characters

### API Security Matrix
| Table | FAN | CLUB_ADMIN | SUPER_ADMIN |
|-------|-----|------------|-------------|
| SYS_USER | R (self) | R (self) | CRUD |
| CLUB | R | R | CRUD |
| PLAYER | R | CRUD (own) | CRUD |
| COACH | R | CRUD (own) | CRUD |
| USER_CLUB_FOLLOW | CRU (self) | CRU (self) | CRUD |
| RATING_RECORD | C (SP), R | CRU, D | CRUD |
| CLUB_CHAT_MESSAGE | C, R | CRU, D (own) | CRUD |
| MATCH_SCHEDULE | R | R | R |
| TRANSFER_HISTORY_LOG | - | R (own) | R |
| AUDIT_LOG | - | - | R |

---

## 9. Seed Data - Five Major Leagues

### Clubs (30 total)
| ID | Name | League | City |
|----|------|--------|------|
| 101 | Real Madrid | La Liga | Madrid |
| 102 | Barcelona | La Liga | Barcelona |
| 103 | Manchester City | Premier League | Manchester |
| 104 | Arsenal | Premier League | London |
| 105 | Bayern Munich | Bundesliga | Munich |
| 106 | Borussia Dortmund | Bundesliga | Dortmund |
| 107 | Inter Milan | Serie A | Milan |
| 108 | AC Milan | Serie A | Milan |
| 109 | Paris Saint-Germain | Ligue 1 | Paris |
| 110 | Olympique Marseille | Ligue 1 | Marseille |

### Players (80+ players across all clubs)
### Coaches (30 coaches across all clubs)
### Sample Users (10 demo accounts)
### Sample Matches (120+ matches across leagues)
### League Standings (for current season)

---

## 10. Acceptance Criteria

1. Oracle 21 Docker container runs and accepts connections
2. All 12 tables created with proper constraints, indexes, and sequences
3. All 5 stored procedures compile and execute without errors
4. All 4 triggers compile successfully
5. All 5 views return correct data
6. Seed data loaded for 10 clubs, 80+ players, 30 coaches, 10 users
7. Spring Boot application starts and connects to Oracle
8. All REST API endpoints respond correctly with proper authentication
9. JWT authentication works across all protected endpoints
10. RBAC enforcement correctly blocks unauthorized operations
11. Vue 3 frontend builds and runs without errors
12. All frontend pages render correctly with data from backend
13. WebSocket chat functionality works in real-time
14. Rating system enforces 24h anti-spam via stored procedure
15. Tauri desktop build completes successfully
