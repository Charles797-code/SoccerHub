# SoccerHub - 足球社区管理系统

一个基于 Oracle 21c + Spring Boot 3.2 + Vue 3 构建的现代化足球社区管理平台，涵盖俱乐部管理、球员评分、实时赛程、聊天室、新闻资讯、社区帖子等核心功能。

## 目录

- [技术架构](#技术架构)
- [功能概览](#功能概览)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [部署指南](#部署指南)
- [数据库说明](#数据库说明)
- [配置说明](#配置说明)
- [演示账号](#演示账号)
- [API 文档](#api-文档)

---

## 技术架构

```
┌─────────────────────────────────────────────────────────────┐
│                      Frontend (Vue 3)                        │
│            Vite + TypeScript + Element Plus                  │
│                 Pinia + Vue Router + Axios                   │
├─────────────────────────────────────────────────────────────┤
│                     Backend (Spring Boot 3.2)                │
│              JWT Security + MyBatis-Plus + WebSocket          │
│                     Redis Cache + Swagger                    │
├─────────────────────────────────────────────────────────────┤
│                      Database Layer                         │
│                  Oracle 21c XE + Redis 7.x                   │
│              Stored Procedures + Triggers + Views             │
└─────────────────────────────────────────────────────────────┘
```

### 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| 前端框架 | Vue 3 (Composition API) | 3.4+ |
| 前端语言 | TypeScript | 5.x |
| 构建工具 | Vite | 5.x |
| UI组件库 | Element Plus | 2.7+ |
| 状态管理 | Pinia | 2.1+ |
| 后端框架 | Spring Boot | 3.2.x |
| 后端语言 | Java | 21 |
| ORM框架 | MyBatis-Plus | 3.5.x |
| 数据库 | Oracle Database | 21c XE |
| 缓存 | Redis | 7.x |
| 安全 | Spring Security + JWT | 6.x |
| API文档 | SpringDoc OpenAPI | 2.5.0 |

---

## 功能概览

### 用户与权限
- **多角色系统**：球迷(FAN)、俱乐部管理员(CLUB_ADMIN)、超级管理员(SUPER_ADMIN)
- **JWT认证**：安全的令牌认证体系，支持注册、登录、个人信息管理
- **关注系统**：用户可关注俱乐部（最多3个）

### 俱乐部管理
- **五大联赛俱乐部**：英超、西甲、德甲、意甲、法甲共10支俱乐部
- **俱乐部详情**：阵容、近期赛程、聊天室入口
- **俱乐部关注**：关注后可进行评分、参与聊天室

### 球员管理
- **球员信息**：姓名、位置、号码、国籍、年龄、身高、体重、身价、平均评分
- **球员详情页**：完整展示球员个人信息
- **球员评分榜**：按平均评分排名

### 比赛与评分
- **赛程管理**：比赛日程展示，按日期筛选
- **比赛详情**：展示比赛信息、双方阵容
- **球员评分**：每场比赛可对球员进行1-10分打分
- **评分防刷**：24小时内同一目标不可重复评分

### 教练管理
- **教练信息**：姓名、国籍、所属俱乐部
- **教练评分**：与球员评分机制一致

### 聊天室
- **俱乐部聊天室**：基于WebSocket的实时聊天室
- **消息管理**：俱乐部管理员可删除/折叠不当消息

### 新闻资讯
- **新闻浏览**：用户可浏览新闻列表和详情
- **新闻评论**：用户可对新闻发表评论

### 社区功能
- **帖子发布**：用户可发布帖子
- **帖子评论**：支持帖子的评论功能
- **点赞收藏**：支持对帖子点赞和收藏

### AI助手
- **HubBot智能问答**：集成通义千问大模型，支持足球相关问答

### 联赛积分榜
- **五大联赛积分榜**：展示各联赛的完整积分排名

### 管理后台
- **管理员仪表盘**：展示系统统计数据
- **审计日志**：记录所有敏感操作
- **系统字典管理**：可配置的系统参数

---

## 项目结构

```
soccer_community/
├── backend/                              # Spring Boot 后端项目
│   ├── src/main/java/com/soccerhub/
│   │   ├── config/                       # 配置类
│   │   │   ├── SecurityConfig.java       # Spring Security配置
│   │   │   ├── WebMvcConfig.java         # Web MVC配置
│   │   │   ├── WebSocketConfig.java      # WebSocket配置
│   │   │   ├── RedisConfig.java          # Redis缓存配置
│   │   │   ├── SpaFallbackController.java # SPA路由回退
│   │   │   └── GlobalExceptionHandler.java # 全局异常处理
│   │   ├── controller/                   # REST控制器
│   │   │   ├── AuthController.java       # 认证接口
│   │   │   ├── ClubController.java       # 俱乐部接口
│   │   │   ├── PlayerController.java     # 球员接口
│   │   │   ├── MatchController.java      # 比赛接口
│   │   │   ├── ChatController.java       # 聊天室接口
│   │   │   ├── NewsController.java       # 新闻接口
│   │   │   ├── SocialController.java     # 社区接口
│   │   │   ├── AdminController.java      # 管理后台接口
│   │   │   ├── AiChatController.java     # AI助手接口
│   │   │   └── ...
│   │   ├── service/                      # 业务逻辑层
│   │   ├── mapper/                       # MyBatis Mapper接口
│   │   ├── entity/                       # 数据库实体
│   │   ├── dto/                          # 数据传输对象
│   │   ├── security/                     # JWT安全组件
│   │   └── SoccerHubApplication.java    # 启动类
│   ├── src/main/resources/
│   │   ├── mapper/                       # MyBatis XML映射
│   │   ├── static/                       # 静态资源（前端打包文件）
│   │   └── application.yml               # 应用配置
│   └── pom.xml                           # Maven依赖
│
├── frontend/                             # Vue 3 前端项目
│   ├── src/
│   │   ├── api/                          # API请求封装
│   │   ├── components/                   # 公共组件
│   │   │   ├── AppButton.vue            # 按钮组件
│   │   │   ├── Chat.vue                 # 聊天室组件
│   │   │   ├── FollowButton.vue         # 关注按钮
│   │   │   ├── HubBot.vue               # AI助手组件
│   │   │   └── ImageUpload.vue          # 图片上传组件
│   │   ├── views/                       # 页面视图
│   │   │   ├── Home.vue                 # 首页
│   │   │   ├── Clubs.vue                # 俱乐部列表
│   │   │   ├── ClubDetail.vue           # 俱乐部详情
│   │   │   ├── Players.vue              # 球员列表
│   │   │   ├── PlayerDetail.vue         # 球员详情
│   │   │   ├── Matches.vue              # 赛程页面
│   │   │   ├── MatchDetail.vue          # 比赛详情
│   │   │   ├── Standings.vue            # 积分榜
│   │   │   ├── Rankings.vue             # 球员评分榜
│   │   │   ├── News.vue                 # 新闻列表
│   │   │   ├── NewsDetail.vue           # 新闻详情
│   │   │   ├── Community.vue            # 社区页面
│   │   │   ├── Chat.vue                 # 聊天室页面
│   │   │   ├── Profile.vue              # 个人中心
│   │   │   ├── Login.vue                # 登录页
│   │   │   ├── Register.vue             # 注册页
│   │   │   ├── Admin.vue                # 管理后台
│   │   │   └── ClubAdmin.vue            # 俱乐部管理
│   │   ├── stores/                       # Pinia状态管理
│   │   ├── router/                       # Vue Router配置
│   │   └── styles/                       # 样式文件
│   ├── index.html
│   ├── package.json
│   └── vite.config.ts
│
├── database/                             # 数据库脚本
│   └── init/
│       ├── 00_create_user.sql           # 创建数据库用户
│       ├── 01_schema.sql                # 建表+初始数据
│       └── ...                          # 其他增量脚本
│
├── docker-compose.yml                    # Docker编排
└── README.md
```

---

## 快速开始

### 环境要求

| 组件 | 版本 | 说明 |
|------|------|------|
| JDK | 21+ | 后端运行环境 |
| Node.js | 18+ | 前端构建环境 |
| Maven | 3.9+ | 后端构建工具 |
| Oracle Database | 21c XE | 数据库 |
| Docker | 24+ | 容器化部署 |

### 1. 启动数据库

```bash
docker compose up -d oracle21
```

### 2. 初始化数据库

```bash
sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1 @database/init/01_schema.sql
```

### 3. 启动后端

```bash
cd backend
mvn spring-boot:run
```

### 4. 启动前端

```bash
cd frontend
npm install
npm run dev
```

访问 `http://localhost:3000`

---

## 部署指南

### Docker部署（推荐）

```bash
# 克隆项目
git clone https://github.com/Charles797-code/SoccerHub.git
cd SoccerHub

# 启动Oracle数据库
docker compose up -d oracle21

# 初始化数据库
sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1 @database/init/01_schema.sql

# 启动后端
cd backend && mvn spring-boot:run

# 启动前端（新窗口）
cd frontend && npm install && npm run dev
```

### 生产环境部署

#### 后端构建

```bash
cd backend
mvn clean package -DskipTests
java -jar target/soccerhub-backend-1.0.0.jar --spring.profiles.active=prod
```

#### 前端构建

```bash
cd frontend
npm run build
```

前端构建产物在 `dist/` 目录，部署到nginx等Web服务器。

#### Nginx配置示例

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        root /path/to/frontend/dist;
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8080/api/;
    }

    location /ws/ {
        proxy_pass http://127.0.0.1:8080/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

---

## 数据库说明

### 主要数据表

| 表名 | 说明 |
|------|------|
| SYS_USER | 用户表 |
| CLUB | 俱乐部表 |
| PLAYER | 球员表 |
| COACH | 教练表 |
| MATCH_SCHEDULE | 赛程表 |
| MATCH_PLAYER_RATING | 球员评分表 |
| CLUB_CHAT_MESSAGE | 聊天室消息表 |
| NEWS_ARTICLE | 新闻表 |
| NEWS_COMMENT | 新闻评论表 |
| POST | 帖子表 |
| POST_COMMENT | 帖子评论表 |
| LEAGUE_STANDING | 联赛积分表 |
| USER_CLUB_FOLLOW | 用户关注俱乐部表 |
| AUDIT_LOG | 审计日志表 |

### 存储过程

| 过程名 | 功能 |
|--------|------|
| osp_Submit_User_Rating | 评分提交（含防刷保护） |
| osp_Upsert_Match_Schedule | 赛程UPSERT |
| osp_Transfer_Player | 球员转会 |
| osp_Moderate_Message | 消息审核 |
| osp_Batch_Update_Standings | 积分榜批量更新 |

---

## 配置说明

### 后端配置 (application.yml)

```yaml
server:
  port: 8080

spring:
  datasource:
    url: jdbc:oracle:thin:@localhost:1521/XEPDB1
    username: soccerhub
    password: soccerhub2026
  redis:
    host: localhost
    port: 6379

jwt:
  secret: (内置密钥)
  expiration: 86400000

upload:
  path: uploads
```

---

## 演示账号

| 用户名 | 密码 | 角色 |
|--------|------|------|
| admin | admin123 | SUPER_ADMIN |
| realmadrid_admin | admin123 | CLUB_ADMIN |
| fan_lionel | admin123 | FAN |

---

## API 文档

启动后端后，访问 Swagger UI：

```
http://localhost:8080/api/swagger-ui.html
```

### 主要API端点

| 模块 | 方法 | 端点 | 说明 |
|------|------|------|------|
| 认证 | POST | /api/auth/login | 用户登录 |
| 认证 | POST | /api/auth/register | 用户注册 |
| 俱乐部 | GET | /api/clubs | 俱乐部列表 |
| 俱乐部 | GET | /api/clubs/{id} | 俱乐部详情 |
| 球员 | GET | /api/players | 球员列表 |
| 球员 | GET | /api/players/rankings | 球员评分榜 |
| 球员 | GET | /api/players/{id} | 球员详情 |
| 比赛 | GET | /api/matches/today | 今日赛事 |
| 比赛 | GET | /api/matches/{id} | 比赛详情 |
| 评分 | POST | /api/ratings | 提交评分 |
| 聊天室 | GET | /api/chat/{clubId}/messages | 聊天记录 |
| 聊天室 | WS | /ws/topic/club/{clubId} | WebSocket聊天 |
| 关注 | POST | /api/follow/{clubId} | 关注俱乐部 |
| 积分榜 | GET | /api/standings/{league} | 联赛积分榜 |
| 新闻 | GET | /api/news | 新闻列表 |
| 社区 | GET | /api/social/posts | 帖子列表 |
| AI助手 | POST | /api/ai/chat | AI对话 |

---

## License

MIT License
