# SoccerHub - 足球社区管理系统

一个基于 Oracle 21c + Spring Boot 3.2 + Vue 3 构建的现代化足球社区管理平台，涵盖五大联赛的俱乐部管理、球员评分、实时赛程、聊天室、新闻资讯等核心功能。

## 目录

- [技术架构](#技术架构)
- [功能概览](#功能概览)
- [项目结构](#项目结构)
- [部署指南](#部署指南)
  - [环境要求](#环境要求)
  - [方式一：Docker 部署（推荐）](#方式一docker-部署推荐)
  - [方式二：本地开发部署](#方式二本地开发部署)
  - [方式三：生产环境部署](#方式三生产环境部署)
- [数据库初始化](#数据库初始化)
- [配置说明](#配置说明)
- [演示账号](#演示账号)
- [API 文档](#api-文档)
- [技术栈详情](#技术栈详情)

---

## 技术架构

```
┌──────────────────────────────────────────────────────┐
│                    Frontend (Vue 3)                   │
│          Vite + TypeScript + Element Plus             │
│              Pinia + Vue Router + Axios               │
├──────────────────────────────────────────────────────┤
│                    Backend (Spring Boot 3.2)          │
│      JWT Security + MyBatis-Plus + WebSocket          │
│           Redis Cache + Swagger OpenAPI               │
├──────────────────────────────────────────────────────┤
│                    Database Layer                     │
│         Oracle 21c XE + Redis 7.x                    │
│      Stored Procedures + Triggers + Views             │
└──────────────────────────────────────────────────────┘
```

---

## 功能概览

### 用户与权限系统
- **多角色认证**：支持球迷(FAN)、俱乐部管理员(CLUB_ADMIN)、超级管理员(SUPER_ADMIN)三种角色
- **JWT 令牌认证**：基于 JWT + Bcrypt 的安全认证体系，支持令牌刷新
- **RBAC 权限控制**：基于角色的访问控制，不同角色拥有不同操作权限
- **用户注册/登录**：支持用户注册、登录、个人信息管理

### 俱乐部管理
- **五大联赛俱乐部**：英超、西甲、德甲、意甲、法甲共 25 支俱乐部
- **俱乐部详情页**：展示俱乐部基本信息、阵容、教练组、近期赛程
- **俱乐部关注**：用户可关注喜爱的俱乐部，关注后可进行评分等操作
- **俱乐部聊天室**：基于 WebSocket 的实时聊天室，支持文字消息

### 球员管理
- **球员信息**：姓名、位置、号码、国籍、年龄、身高、体重、身价等
- **球员详情页**：完整展示球员个人信息与统计数据
- **球员评分榜**：按平均评分排名，支持按联赛和位置筛选
- **球员转会**：支持球员转会操作，自动记录转会历史日志

### 比赛与评分
- **赛程管理**：比赛日程展示，支持按日期、联赛筛选
- **比赛详情页**：展示比赛信息、双方阵容、实时比分
- **比赛球员评分**：每场比赛可对球员进行 1-10 分打分
- **实时平均分**：球员平均评分根据用户打分实时更新
- **评分防刷机制**：24 小时内同一目标不可重复评分

### 教练管理
- **教练信息**：姓名、国籍、是否主教练等
- **教练评分**：与球员评分机制一致，支持防刷保护

### 联赛积分榜
- **五大联赛积分榜**：展示各联赛的完整积分排名
- **自动更新**：比赛结束后通过存储过程自动更新积分榜

### 新闻资讯
- **新闻发布**：管理员可发布新闻文章
- **新闻浏览**：用户可浏览新闻列表和详情

### 管理后台
- **管理员仪表盘**：展示系统统计数据（用户数、俱乐部数、球员数等）
- **审计日志**：记录所有敏感操作，支持追溯
- **消息审核**：管理员可删除或折叠不当聊天消息
- **系统字典**：可配置的系统参数管理

### AI 助手
- **智能聊天**：集成通义千问大模型，支持足球相关问答

---

## 项目结构

```
soccer_community/
├── backend/                          # 后端 Spring Boot 项目
│   ├── src/main/java/com/soccerhub/
│   │   ├── config/                   # 配置类（安全、Redis、CORS、WebSocket等）
│   │   ├── controller/               # REST 控制器
│   │   ├── dto/                      # 数据传输对象
│   │   ├── entity/                   # 数据库实体
│   │   ├── mapper/                   # MyBatis-Plus Mapper 接口
│   │   ├── security/                 # JWT 安全组件
│   │   └── service/                  # 业务逻辑层
│   ├── src/main/resources/
│   │   ├── mapper/                   # MyBatis XML 映射文件
│   │   ├── sql/                      # SQL 脚本
│   │   └── application.yml           # 应用配置
│   └── pom.xml                       # Maven 依赖
├── frontend/                         # 前端 Vue 3 项目
│   ├── src/
│   │   ├── api/                      # API 请求封装
│   │   ├── components/               # 公共组件
│   │   ├── views/                    # 页面视图
│   │   ├── App.vue                   # 根组件
│   │   └── main.ts                   # 入口文件
│   ├── src-tauri/                    # Tauri 桌面端配置
│   ├── index.html
│   └── package.json
├── database/                         # 数据库脚本
│   ├── init/                         # 初始化脚本
│   │   ├── 00_create_user.sql        # 创建数据库用户
│   │   └── 01_schema.sql             # 建表+存储过程+触发器+初始数据
│   ├── triggers.sql                  # 触发器脚本
│   └── reset_schema.sql              # 重置脚本
├── docker-compose.yml                # Docker 编排
└── README.md
```

---

## 部署指南

### 环境要求

| 组件           | 最低版本     | 说明                        |
| -------------- | ------------ | --------------------------- |
| JDK            | 21+          | 后端运行环境                |
| Node.js        | 18+          | 前端构建环境                |
| Maven          | 3.9+         | 后端构建工具                |
| Oracle Database | 21c XE      | 数据库（可用 Docker 部署）  |
| Redis          | 7.x          | 缓存（可选，本地开发可不装）|
| Docker         | 24+          | 容器化部署（可选）          |
| Git            | 2.x          | 版本控制                    |

### 方式一：Docker 部署（推荐）

#### 1. 克隆项目

```bash
git clone https://github.com/Charles797-code/SoccerHub.git
cd SoccerHub
```

#### 2. 启动 Oracle 数据库

```bash
docker compose up -d oracle21
```

等待 Oracle 容器启动完成（首次启动约需 3-5 分钟），检查状态：

```bash
docker logs soccer_oracle21 --tail 20
# 看到 "DATABASE IS READY TO USE!" 表示启动完成
```

#### 3. 初始化数据库

```bash
# 方式 A：使用 sqlplus（需安装 Oracle Instant Client）
sqlplus system/SoccerHub2026!@localhost:1521/XEPDB1 @database/init/00_create_user.sql
sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1 @database/init/01_schema.sql

# 方式 B：使用 Docker 内置 sqlplus
docker exec -it soccer_oracle21 bash
sqlplus / as sysdba
@/path/to/init/scripts
```

#### 4. 启动 Redis（可选）

```bash
# 如果已安装 Redis
redis-server

# 或使用 Docker
docker run -d --name soccer_redis -p 6379:6379 redis:7-alpine
```

> 如果不安装 Redis，后端仍可正常运行，但缓存功能不可用。

#### 5. 启动后端

```bash
cd backend
mvn spring-boot:run
```

后端启动成功后，API 地址为 `http://localhost:8080/api`

#### 6. 启动前端

```bash
cd frontend
npm install
npm run dev
```

前端启动成功后，访问 `http://localhost:3000`

### 方式二：本地开发部署

适用于已有 Oracle 和 Redis 本地环境的开发者。

#### 1. 准备数据库

确保 Oracle 21c 已安装并运行，然后执行初始化脚本：

```bash
sqlplus / as sysdba @database/init/00_create_user.sql
sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1 @database/init/01_schema.sql
```

#### 2. 修改后端配置

编辑 `backend/src/main/resources/application.yml`，修改数据库连接信息：

```yaml
spring:
  datasource:
    url: jdbc:oracle:thin:@localhost:1521/XEPDB1
    username: soccerhub
    password: soccerhub2026
  redis:
    host: localhost
    port: 6379
```

#### 3. 启动后端

```bash
cd backend
mvn clean compile
mvn spring-boot:run
```

#### 4. 启动前端

```bash
cd frontend
npm install
npm run dev
```

#### 5. 前端代理配置

前端开发服务器已配置代理，API 请求会自动转发到后端：

```typescript
// vite.config.ts 中已配置
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true
    }
  }
}
```

### 方式三：生产环境部署

#### 1. 构建后端 JAR

```bash
cd backend
mvn clean package -DskipTests
java -jar target/soccerhub-backend-1.0.0.jar --spring.profiles.active=prod
```

#### 2. 构建前端

```bash
cd frontend
npm run build
```

构建产物在 `frontend/dist/` 目录下，可部署到 Nginx 等 Web 服务器。

#### 3. Nginx 配置示例

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # 前端静态资源
    location / {
        root /path/to/SoccerHub/frontend/dist;
        try_files $uri $uri/ /index.html;
    }

    # API 反向代理
    location /api/ {
        proxy_pass http://127.0.0.1:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # WebSocket 代理
    location /api/ws/ {
        proxy_pass http://127.0.0.1:8080/api/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

---

## 数据库初始化

项目提供完整的数据库初始化脚本，按顺序执行：

| 脚本文件                        | 说明                                   |
| ------------------------------- | -------------------------------------- |
| `database/init/00_create_user.sql` | 创建 SOCCERHUB 用户并授权            |
| `database/init/01_schema.sql`      | 建表、索引、存储过程、触发器、初始数据 |

`01_schema.sql` 包含以下内容：

- **13 张数据表**：用户、俱乐部、球员、教练、赛程、评分、聊天、转会、审计、积分榜、新闻、关注、字典
- **5 个存储过程**：
  - `osp_Submit_User_Rating` — 评分提交（含防刷保护）
  - `osp_Upsert_Match_Schedule` — 赛程 UPSERT
  - `osp_Transfer_Player` — 球员转会（含权限校验）
  - `osp_Moderate_Message` — 消息审核
  - `osp_Batch_Update_Standings` — 积分榜批量更新
- **触发器**：评分后自动更新球员/教练平均分
- **视图**：球员视图、比赛直播视图、聊天消息视图
- **初始数据**：25 支俱乐部、100+ 球员、教练、赛程、用户等

---

## 配置说明

### 后端配置 (`backend/src/main/resources/application.yml`)

| 配置项                    | 默认值                                              | 说明               |
| ------------------------- | --------------------------------------------------- | ------------------ |
| `server.port`             | 8080                                                | 后端服务端口       |
| `spring.datasource.url`   | `jdbc:oracle:thin:@localhost:1521/XEPDB1`           | 数据库连接地址     |
| `spring.datasource.username` | soccerhub                                         | 数据库用户名       |
| `spring.datasource.password` | soccerhub2026                                     | 数据库密码         |
| `spring.redis.host`       | localhost                                           | Redis 地址         |
| `spring.redis.port`       | 6379                                                | Redis 端口         |
| `jwt.secret`              | (内置)                                              | JWT 签名密钥       |
| `jwt.expiration`          | 86400000 (24h)                                      | JWT 令牌有效期(ms) |
| `upload.path`             | uploads                                             | 文件上传路径       |
| `ai.qwen.api-key`         | (需配置)                                            | 通义千问 API Key   |

### 前端配置

前端 API 基础路径通过 Vite 代理配置，开发环境自动代理到后端。

---

## 演示账号

| 用户名            | 密码        | 角色          | 说明               |
| ----------------- | ----------- | ------------- | ------------------ |
| admin             | admin123    | SUPER_ADMIN   | 超级管理员         |
| realmadrid_admin  | admin123    | CLUB_ADMIN    | 皇家马德里管理员   |
| fan_lionel        | admin123    | FAN           | 普通球迷用户       |

> 初始数据中的密码可能因 seed 脚本版本不同而异，具体请查看 `database/init/01_schema.sql` 中的 INSERT 语句。

---

## API 文档

启动后端后，访问 Swagger UI 查看完整的 API 文档：

```
http://localhost:8080/api/swagger-ui.html
```

### 主要 API 端点

| 模块         | 方法   | 端点                                         | 说明               |
| ------------ | ------ | -------------------------------------------- | ------------------ |
| 认证         | POST   | `/auth/login`                                | 用户登录           |
| 认证         | POST   | `/auth/register`                             | 用户注册           |
| 俱乐部       | GET    | `/clubs`                                     | 俱乐部列表         |
| 俱乐部       | GET    | `/clubs/{id}`                                | 俱乐部详情         |
| 球员         | GET    | `/players`                                   | 球员列表           |
| 球员         | GET    | `/players/rankings`                          | 球员评分排行       |
| 球员         | GET    | `/players/{id}`                              | 球员详情           |
| 比赛         | GET    | `/matches/today`                             | 今日赛事           |
| 比赛         | GET    | `/matches/live`                              | 直播比赛           |
| 比赛球员评分 | GET    | `/matches/{matchId}/player-ratings`          | 获取球员评分       |
| 比赛球员评分 | POST   | `/matches/{matchId}/player-ratings`          | 给球员打分         |
| 评分         | POST   | `/ratings`                                   | 提交评分           |
| 聊天         | GET    | `/chat/{clubId}/messages`                    | 聊天记录           |
| 聊天         | WS     | `/ws/topic/club/{clubId}`                    | WebSocket 聊天     |
| 关注         | POST   | `/follow/{clubId}`                           | 关注俱乐部         |
| 积分榜       | GET    | `/standings/{league}`                        | 联赛积分榜         |
| 新闻         | GET    | `/news`                                      | 新闻列表           |
| AI 助手      | POST   | `/ai/chat`                                   | AI 对话            |

---

## 技术栈详情

### 后端

| 技术                   | 版本     | 用途                      |
| ---------------------- | -------- | ------------------------- |
| Spring Boot            | 3.2.5    | Web 框架                  |
| JDK                    | 21       | 运行环境（虚拟线程）      |
| MyBatis-Plus           | 3.5.7    | ORM 框架                  |
| Oracle JDBC             | 23.4     | 数据库驱动                |
| Spring Security         | 6.x      | 安全框架                  |
| JJWT                   | 0.12.5   | JWT 令牌                  |
| Springdoc OpenAPI       | 2.5.0    | API 文档                  |
| Spring WebSocket        | 6.x      | 实时通信                  |
| Spring Data Redis       | 3.x      | 缓存                      |
| HikariCP               | 5.x      | 数据库连接池              |

### 前端

| 技术                   | 版本     | 用途                      |
| ---------------------- | -------- | ------------------------- |
| Vue                    | 3.4      | 前端框架                  |
| TypeScript             | 5.4      | 类型安全                  |
| Vite                   | 5.3      | 构建工具                  |
| Element Plus           | 2.7      | UI 组件库                 |
| Pinia                  | 2.1      | 状态管理                  |
| Vue Router             | 4.3      | 路由管理                  |
| Axios                  | 1.7      | HTTP 客户端               |
| @stomp/stompjs         | 7.3      | WebSocket 客户端          |
| Sass                   | 1.77     | CSS 预处理器              |

### 数据库

| 技术                   | 版本     | 用途                      |
| ---------------------- | -------- | ------------------------- |
| Oracle Database        | 21c XE   | 关系型数据库              |
| Redis                  | 7.x      | 缓存                      |

### 桌面端（可选）

| 技术                   | 版本     | 用途                      |
| ---------------------- | -------- | ------------------------- |
| Tauri                  | 2.x      | 桌面应用框架              |
| Rust                   | stable   | Tauri 后端                |

---

## License

MIT License
