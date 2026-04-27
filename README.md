# SoccerHub - 足球社区管理系统

一个功能完备的现代化足球社区平台，基于 Oracle 21c + Spring Boot 3.2 + Vue 3 构建，涵盖俱乐部管理、球员评分、实时赛程、聊天室、新闻资讯、社区社交、AI智能助手等完整功能。

## 目录

- [技术架构](#技术架构)
- [功能详解](#功能详解)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [部署指南](#部署指南)
- [数据库说明](#数据库说明)
- [配置说明](#配置说明)
- [演示账号](#演示账号)
- [API 文档](#api-文档)

***

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

### 技术栈详情

#### 前端

| 技术           | 版本    | 说明                                   |
| ------------ | ----- | ------------------------------------ |
| Vue 3        | 3.4+  | 前端框架（Composition API + script setup） |
| TypeScript   | 5.x   | 类型安全                                 |
| Vite         | 5.x   | 构建工具                                 |
| Element Plus | 2.7+  | UI组件库                                |
| Pinia        | 2.1+  | 状态管理                                 |
| Vue Router   | 4.3+  | 路由管理                                 |
| Axios        | 1.7+  | HTTP客户端                              |
| Sass         | 1.77+ | CSS预处理器                              |

#### 后端

| 技术                | 版本     | 说明                    |
| ----------------- | ------ | --------------------- |
| Spring Boot       | 3.2.x  | Web框架                 |
| Java              | 21     | 运行环境（Virtual Threads） |
| MyBatis-Plus      | 3.5.x  | ORM框架                 |
| Oracle JDBC       | 23.x   | 数据库驱动                 |
| Spring Security   | 6.x    | 安全框架                  |
| JWT (JJWT)        | 0.12.5 | 令牌认证                  |
| Springdoc OpenAPI | 2.5.0  | API文档                 |
| Spring WebSocket  | 6.x    | 实时通信                  |
| Spring Data Redis | 3.x    | 缓存                    |
| HikariCP          | 5.x    | 连接池                   |

#### 数据库与容器

| 技术              | 版本     | 说明     |
| --------------- | ------ | ------ |
| Oracle Database | 21c XE | 关系型数据库 |
| Redis           | 7.x    | 缓存（可选） |
| Docker          | 24+    | 容器化部署  |

***

## 功能详解

### 一、用户与权限系统

#### 1.1 多角色认证

系统支持三种用户角色：

| 角色     | 代码           | 权限说明                         |
| ------ | ------------ | ---------------------------- |
| 普通球迷   | FAN          | 浏览、关注、评分、发帖、评论、参与聊天室         |
| 俱乐部管理员 | CLUB\_ADMIN  | 上述权限 + 管理俱乐部阵容、管理聊天室、管理俱乐部新闻 |
| 超级管理员  | SUPER\_ADMIN | 全部权限 + 系统管理、用户管理、数据导入导出      |

#### 1.2 JWT认证体系

- **注册登录**：支持用户名、邮箱注册，登录后获取JWT令牌
- **令牌刷新**：支持Token刷新机制
- **密码安全**：Bcrypt加密存储
- **RBAC**：基于角色的访问控制

#### 1.3 关注系统

- 用户可关注其他用户（互相关注成为好友）
- 用户可关注俱乐部（最多3个）
- 关注后可进行评分、参与聊天室

***

### 二、俱乐部管理

#### 2.1 俱乐部列表

- 展示五大联赛（英超、西甲、德甲、意甲、法甲）共10支俱乐部
- 支持按联赛筛选
- 显示俱乐部Logo、名称、主场城市

#### 2.2 俱乐部详情页

- **基本信息**：俱乐部名称、简称、联赛、城市、国家、主场球场、成立日期、球场容量
- **阵容列表**：展示球员名单（位置、号码、姓名）
- **教练组**：主教练信息
- **近期赛程**：即将进行的比赛
- **聊天室入口**：进入俱乐部专属聊天室
- **积分排名**：该俱乐部在联赛的排名

#### 2.3 俱乐部关注

- 球迷可关注喜爱的俱乐部
- 关注后可对俱乐部球员进行评分
- 关注列表展示

***

### 三、球员管理

#### 3.1 球员信息

完整展示球员档案：

- **基本信息**：姓名（中英文）、头像、球衣号码、位置、国籍
- **身体数据**：身高、体重、出生日期（年龄）
- **竞技数据**：市场身价、当前状态（现役/退役/伤病/自由身）
- **评分数据**：平均评分（根据用户评分计算）

#### 3.2 球员列表

- 分页展示所有球员
- 支持按联赛筛选
- 支持按位置筛选（门将/后卫/中场/前锋）
- 支持按状态筛选
- 支持关键词搜索（姓名）

#### 3.3 球员详情页

- 完整个人信息展示
- 生涯数据统计
- 评分历史

#### 3.4 球员评分榜

- 按平均评分降序排列
- 支持按联赛筛选
- 支持按位置筛选
- 展示排名、球员信息、评分

***

### 四、教练管理

#### 4.1 教练信息

- 姓名、国籍、所属俱乐部
- 是否主教练
- 执教平均评分

#### 4.2 教练列表与详情

- 分页展示教练
- 支持按俱乐部筛选
- 教练详情页

#### 4.3 教练评分

- 与球员评分机制一致
- 支持1-10分评分
- 24小时防刷保护

***

### 五、比赛与评分系统

#### 5.1 赛程管理

- **今日赛事**：展示今天即将/正在进行的比赛
- **直播比赛**：展示正在进行的比赛
- **即将开始**：展示即将进行的比赛
- **全部赛程**：支持按日期、按联赛、按俱乐部筛选

#### 5.2 比赛详情

- **基本信息**：主客队、比赛时间、联赛、场地
- **比分信息**：实时比分（如比赛进行中）
- **比赛状态**：未开始/进行中/已结束/已取消

#### 5.3 球员评分

- 每场比赛可对两队球员进行1-10分打分
- 支持选择评分类型（进攻/防守/组织/关键表现等）
- **评分防刷**：同一目标24小时内不可重复评分
- **平均分**：实时计算并展示球员平均评分

#### 5.4 比赛评论（弹幕）

- 用户可在比赛页面发送评论
- 实时显示最新评论
- 支持删除自己的评论

***

### 六、聊天室系统

#### 6.1 俱乐部聊天室

- 每个俱乐部有专属聊天室
- 基于WebSocket实现实时消息推送
- 支持文字消息发送
- 支持查看历史消息

#### 6.2 消息管理

- 俱乐部管理员可删除不当消息
- 俱乐部管理员可折叠（屏蔽）消息
- 超级管理员可管理所有聊天室消息

#### 6.3 在线状态

- 显示当前在线人数
- 用户进入/离开提示

***

### 七、新闻资讯系统

#### 7.1 新闻浏览

- 新闻列表分页展示
- 支持按俱乐部筛选新闻
- 支持关键词搜索
- 显示封面图、标题、摘要、发布时间、浏览量

#### 7.2 新闻详情

- 完整新闻内容展示
- 富文本支持
- 自动增加浏览量

#### 7.3 新闻评论

- 用户可对新闻发表评论
- 评论分页展示
- 支持删除评论

#### 7.4 新闻爬取

- 集成懂球帝API自动爬取足球新闻
- 备用：新浪体育爬虫
- 爬取后自动入库

#### 7.5 新闻管理（管理员）

- 创建新闻
- 编辑新闻
- 删除新闻
- 设置新闻封面、分类

***

### 八、社区社交系统

#### 8.1 用户主页

- 展示用户昵称、头像、个人简介
- 关注的俱乐部列表
- 粉丝/关注数量
- 用户发布的帖子列表

#### 8.2 帖子功能

- 发布帖子（文字内容）
- 查看帖子列表
- 帖子详情页

#### 8.3 帖子互动

- **点赞**：对帖子点赞/取消点赞
- **收藏**：收藏帖子
- **评论**：对帖子进行评论
- 显示点赞数、评论数、收藏数

#### 8.4 用户互关

- 关注其他用户
- 相互关注成为好友
- 查看粉丝列表
- 查看关注列表

#### 8.5 球迷圈子

- 每个俱乐部有专属球迷圈子
- 官方主社区
- 圈子成员管理

***

### 九、AI智能助手（HubBot）

#### 9.1 智能问答

- 集成通义千问（阿里云）大模型
- 支持足球相关知识问答
- 支持闲聊模式

#### 9.2 实时响应

- 基于WebSocket的流式输出
- 打字机效果展示

***

### 十、联赛积分榜

#### 10.1 五大联赛积分榜

- 英超、西甲、德甲、意甲、法甲
- 显示：排名、俱乐部、场次、胜/平/负、进失球数、积分
- 自动更新（比赛结束后通过存储过程更新）

#### 10.2 数据榜单

- **射手榜**：按进球数排名
- **助攻榜**：按助攻数排名
- **黄牌榜**：按黄牌数排名
- 支持按联赛、赛季筛选

***

### 十一、转会管理

#### 11.1 球员转会

- 俱乐部管理员可为旗下球员发起转会
- 转会类型：永久转会、租借
- 转会费用记录
- 赛季记录

#### 11.2 转会历史

- 完整转会记录日志
- 可查询球员转会历史

***

### 十二、管理后台

#### 12.1 管理员仪表盘

- 系统统计数据概览
- 用户总数、俱乐部总数、球员总数
- 今日比赛数、在线用户数

#### 12.2 用户管理

- 用户列表（分页、筛选）
- 修改用户角色（FAN/CLUB\_ADMIN/SUPER\_ADMIN）
- 修改用户状态（ACTIVE/BANNED）
- 分配俱乐部管理员管理的俱乐部
- 查看用户详情

#### 12.3 审计日志

- 记录所有敏感操作
- 按模块、操作用户筛选
- 操作类型：用户管理、评分、发帖、聊天等

#### 12.4 系统字典

- 系统参数配置
- 位置、球员状态、联赛等枚举值管理

#### 12.5 数据导入导出

- **导出Excel**：支持导出用户、球员、比赛等数据
- **导出CSV**：支持CSV格式导出
- **导入球员**：从Excel文件批量导入球员数据
- **导入比赛**：从Excel文件批量导入比赛数据

***

### 十三、文件上传

#### 13.1 头像上传

- 用户可上传/修改头像
- 支持图片格式：jpg、png、gif
- 自动压缩和裁剪

#### 13.2 新闻图片

- 新闻封面图上传
- 新闻内容图片上传

#### 13.3 俱乐部Logo

- 管理员可上传俱乐部Logo

***

### 十四、赛季管理

#### 14.1 赛季概述

- 系统支持多联赛多赛季管理
- 每个联赛可有独立的赛季历史记录
- 赛季状态：ACTIVE（进行中）、FINISHED（已结束）

#### 14.2 当前赛季

- 显示所有联赛的当前活跃赛季
- 查看赛季基本信息：联赛名称、赛季名称、总轮数、开始/结束年份
- 查看当前进行中的赛季

#### 14.3 历史赛季

- 展示所有已结束的赛季
- 保留历史数据用于查询

#### 14.4 开启新赛季

- **功能描述**：管理员可为任意联赛开启新赛季
- **支持联赛**：Premier League、La Liga、Serie A、Bundesliga、Ligue 1、Chinese Super League等
- **支持自定义**：可输入新的联赛名称创建新联赛的赛季
- **自动操作**：
  - 将当前赛季状态设为 FINISHED
  - 清空 LEAGUE\_STANDINGS（积分榜数据）
  - 清空 PLAYER\_SEASON\_STATS（球员赛季统计）
  - 清空 MATCH\_SCHEDULE（比赛日程）
  - 创建新的赛季记录

#### 14.5 比赛轮数设置

- 管理员在创建/编辑比赛时可设置轮数
- 支持批量设置比赛所属轮次
- 便于赛程管理和展示

#### 14.6 重置赛季数据

- **功能描述**：清空指定联赛的积分榜和球员统计
- **影响范围**：LEAGUE\_STANDINGS、PLAYER\_SEASON\_STATS、MATCH\_SCHEDULE
- **使用场景**：赛季中期重新开始、测试数据清理

#### 14.7 结束赛季

- **功能描述**：将指定联赛的当前赛季状态设为 FINISHED
- **影响**：赛季结束标记，不删除历史数据

***

## 项目结构

```
soccer_community/
├── backend/                              # Spring Boot 后端项目
│   ├── src/main/java/com/soccerhub/
│   │   ├── config/                       # 配置类
│   │   │   ├── SecurityConfig.java       # Spring Security + JWT配置
│   │   │   ├── WebMvcConfig.java         # Web MVC配置（CORS、静态资源）
│   │   │   ├── WebSocketConfig.java      # WebSocket配置（STOMP）
│   │   │   ├── RedisConfig.java          # Redis缓存配置
│   │   │   ├── MyBatisPlusConfig.java    # MyBatis-Plus配置
│   │   │   ├── SpaFallbackController.java # SPA路由回退控制器
│   │   │   └── GlobalExceptionHandler.java # 全局异常处理器
│   │   ├── controller/                   # REST API控制器
│   │   │   ├── AuthController.java       # 认证：登录、注册、刷新Token、当前用户
│   │   │   ├── ClubController.java       # 俱乐部：列表、详情、搜索
│   │   │   ├── PlayerController.java     # 球员：列表、详情、评分榜、统计
│   │   │   ├── CoachController.java      # 教练：列表、详情、评分榜
│   │   │   ├── MatchController.java      # 比赛：列表、今日、直播、赛程管理
│   │   │   ├── MatchPlayerRatingController.java # 比赛球员评分
│   │   │   ├── MatchCommentController.java # 比赛评论（弹幕）
│   │   │   ├── ChatController.java       # 聊天室：消息、发送、WebSocket
│   │   │   ├── NewsController.java       # 新闻：列表、详情、爬取、评论
│   │   │   ├── SocialController.java     # 社区：用户、关注、帖子、点赞、收藏
│   │   │   ├── FollowController.java      # 俱乐部关注
│   │   │   ├── StandingsController.java  # 积分榜、射手榜、助攻榜
│   │   │   ├── RatingController.java     # 评分：提交、查询、防刷
│   │   │   ├── AdminController.java      # 超级管理员：仪表盘、用户、字典、审计
│   │   │   ├── ClubAdminController.java  # 俱乐部管理员：阵容、教练、转户管理
│   │   │   ├── AnalyticsController.java  # 数据分析：导入导出Excel/CSV
│   │   │   ├── AiChatController.java     # AI助手：通义千问对话
│   │   │   └── FileUploadController.java # 文件上传：头像、图片
│   │   │   └── SeasonController.java     # 赛季管理：赛季CRUD、新赛季开启
│   │   ├── service/                      # 业务逻辑层（Service）
│   │   │   ├── AuthService.java          # 认证业务
│   │   │   ├── ClubService.java          # 俱乐部业务
│   │   │   ├── PlayerService.java        # 球员业务
│   │   │   ├── CoachService.java         # 教练业务
│   │   │   ├── MatchService.java         # 比赛业务
│   │   │   ├── MatchPlayerRatingService.java # 比赛评分业务
│   │   │   ├── MatchCommentService.java  # 比赛评论业务
│   │   │   ├── ChatService.java          # 聊天室业务
│   │   │   ├── NewsService.java          # 新闻业务
│   │   │   ├── NewsScraperService.java   # 新闻爬取业务
│   │   │   ├── NewsCommentService.java  # 新闻评论业务
│   │   │   ├── SocialService.java        # 社区业务
│   │   │   ├── FollowService.java        # 关注业务
│   │   │   ├── RatingService.java        # 评分业务
│   │   │   ├── AdminService.java         # 管理员业务
│   │   │   ├── ClubAdminService.java     # 俱乐部管理员业务
│   │   │   ├── AnalyticsService.java     # 数据分析业务
│   │   │   ├── AiChatService.java        # AI聊天业务
│   │   │   └── FileUploadService.java    # 文件上传业务
│   │   │   └── SeasonService.java        # 赛季管理业务
│   │   ├── mapper/                       # MyBatis Mapper接口
│   │   │   ├── SysUserMapper.java        # 用户Mapper
│   │   │   ├── ClubMapper.java           # 俱乐部Mapper
│   │   │   ├── PlayerMapper.java         # 球员Mapper
│   │   │   ├── CoachMapper.java          # 教练Mapper
│   │   │   ├── MatchScheduleMapper.java  # 赛程Mapper
│   │   │   ├── MatchPlayerRatingMapper.java # 评分Mapper
│   │   │   ├── MatchCommentMapper.java   # 评论Mapper
│   │   │   ├── ClubChatMessageMapper.java # 聊天室消息Mapper
│   │   │   ├── NewsArticleMapper.java    # 新闻Mapper
│   │   │   ├── NewsCommentMapper.java    # 新闻评论Mapper
│   │   │   ├── PostMapper.java           # 帖子Mapper
│   │   │   ├── PostCommentMapper.java    # 帖子评论Mapper
│   │   │   ├── PostLikeMapper.java       # 帖子点赞Mapper
│   │   │   ├── PostFavoriteMapper.java   # 帖子收藏Mapper
│   │   │   ├── UserFollowMapper.java     # 用户关注Mapper
│   │   │   ├── UserClubFollowMapper.java # 俱乐部关注Mapper
│   │   │   ├── CircleMapper.java         # 球迷圈子Mapper
│   │   │   ├── CircleMemberMapper.java   # 圈子成员Mapper
│   │   │   ├── LeagueStandingMapper.java # 积分榜Mapper
│   │   │   ├── TransferHistoryLogMapper.java # 转会记录Mapper
│   │   │   ├── AuditLogMapper.java       # 审计日志Mapper
│   │   │   └── SystemDictionaryMapper.java # 字典Mapper
│   │   │   └── SeasonMapper.java          # 赛季Mapper
│   │   ├── entity/                       # 数据库实体（Entity）
│   │   │   ├── SysUser.java             # 用户实体
│   │   │   ├── Club.java                # 俱乐部实体
│   │   │   ├── Player.java              # 球员实体
│   │   │   ├── Coach.java               # 教练实体
│   │   │   ├── MatchSchedule.java       # 赛程实体
│   │   │   ├── MatchPlayerRating.java   # 球员评分实体
│   │   │   ├── MatchComment.java        # 比赛评论实体
│   │   │   ├── ClubChatMessage.java     # 聊天室消息实体
│   │   │   ├── NewsArticle.java         # 新闻实体
│   │   │   ├── NewsComment.java         # 新闻评论实体
│   │   │   ├── Post.java                # 帖子实体
│   │   │   ├── PostComment.java         # 帖子评论实体
│   │   │   ├── PostLike.java            # 点赞实体
│   │   │   ├── PostFavorite.java        # 收藏实体
│   │   │   ├── UserFollow.java          # 用户关注实体
│   │   │   ├── UserClubFollow.java      # 俱乐部关注实体
│   │   │   ├── Circle.java              # 球迷圈子实体
│   │   │   ├── CircleMember.java        # 圈子成员实体
│   │   │   ├── LeagueStanding.java      # 积分榜实体
│   │   │   ├── TransferHistoryLog.java  # 转会记录实体
│   │   │   ├── AuditLog.java            # 审计日志实体
│   │   │   ├── SystemDictionary.java     # 字典实体
│   │   │   └── Season.java               # 赛季实体
│   │   │   └── ...
│   │   ├── dto/                          # 数据传输对象（DTO）
│   │   │   ├── ApiResponse.java         # 统一API响应
│   │   │   ├── PageResponse.java        # 分页响应
│   │   │   ├── LoginRequest.java        # 登录请求
│   │   │   ├── LoginResponse.java       # 登录响应
│   │   │   ├── RegisterRequest.java     # 注册请求
│   │   │   ├── RatingRequest.java       # 评分请求
│   │   │   ├── TransferRequest.java     # 转会请求
│   │   │   ├── MatchUpsertRequest.java  # 赛程Upsert请求
│   │   │   ├── UserProfileDTO.java      # 用户资料DTO
│   │   │   ├── PlayerRanking.java       # 球员排名DTO
│   │   │   ├── PlayerStatsRanking.java  # 球员数据排名DTO
│   │   │   ├── CircleDTO.java           # 球迷圈子DTO
│   │   │   ├── PostDTO.java             # 帖子DTO
│   │   │   ├── CommentDTO.java          # 评论DTO
│   │   │   ├── ChatMessageRequest.java  # 聊天消息请求
│   │   │   ├── ChatMessageVO.java       # 聊天消息VO
│   │   │   ├── DashboardStats.java      # 仪表盘统计
│   │   │   ├── AnalyticsStats.java      # 分析统计
│   │   │   └── UpdateProfileRequest.java # 更新资料请求
│   │   ├── security/                     # 安全相关组件
│   │   │   ├── JwtTokenProvider.java    # JWT令牌提供者
│   │   │   ├── JwtAuthenticationFilter.java # JWT认证过滤器
│   │   │   └── CustomUserDetailsService.java # 用户详情服务
│   │   └── SoccerHubApplication.java    # 启动类
│   ├── src/main/resources/
│   │   ├── mapper/                       # MyBatis XML映射文件
│   │   │   ├── SysUserMapper.xml
│   │   │   ├── ClubMapper.xml
│   │   │   └── PlayerMapper.xml
│   │   ├── static/                       # 静态资源（前端打包文件）
│   │   │   ├── index.html               # SPA入口
│   │   │   ├── assets/                  # 打包后的JS/CSS
│   │   │   └── uploads/                 # 上传的文件
│   │   └── application.yml               # 应用配置文件
│   └── pom.xml                           # Maven依赖配置
│
├── frontend/                             # Vue 3 前端项目
│   ├── src/
│   │   ├── api/                          # API请求封装
│   │   │   └── index.ts                 # Axios实例和拦截器
│   │   ├── components/                   # 公共组件
│   │   │   ├── AppButton.vue           # 自定义按钮组件
│   │   │   ├── Chat.vue                # 聊天室组件（WebSocket）
│   │   │   ├── FollowButton.vue        # 关注按钮组件
│   │   │   ├── HubBot.vue              # AI助手组件
│   │   │   └── ImageUpload.vue         # 图片上传组件
│   │   ├── views/                       # 页面视图
│   │   │   ├── Home.vue                # 首页
│   │   │   ├── Login.vue               # 登录页
│   │   │   ├── Register.vue            # 注册页
│   │   │   ├── Clubs.vue               # 俱乐部列表页
│   │   │   ├── ClubDetail.vue          # 俱乐部详情页
│   │   │   ├── Players.vue             # 球员列表页
│   │   │   ├── PlayerDetail.vue        # 球员详情页
│   │   │   ├── Rankings.vue            # 球员评分榜
│   │   │   ├── Matches.vue             # 赛程页面
│   │   │   ├── MatchDetail.vue         # 比赛详情页
│   │   │   ├── Standings.vue           # 积分榜页面
│   │   │   ├── News.vue                # 新闻列表页
│   │   │   ├── NewsDetail.vue          # 新闻详情页
│   │   │   ├── Community.vue           # 社区页面（帖子、评论）
│   │   │   ├── Chat.vue                # 聊天室页面
│   │   │   ├── Profile.vue             # 个人中心
│   │   │   ├── UserDetail.vue          # 用户详情页
│   │   │   ├── Admin.vue               # 超级管理后台
│   │   │   ├── ClubAdmin.vue           # 俱乐部管理后台
│   │   │   └── Layout.vue              # 布局组件
│   │   ├── stores/                      # Pinia状态管理
│   │   │   ├── auth.ts                 # 认证状态（用户信息、Token）
│   │   │   └── app.ts                  # 应用状态
│   │   ├── router/                      # Vue Router配置
│   │   │   └── index.ts                # 路由定义和守卫
│   │   ├── styles/                      # 样式文件
│   │   │   ├── main.scss               # 全局样式
│   │   │   ├── _tokens.scss            # 设计令牌
│   │   │   └── _components.scss        # 组件样式
│   │   ├── App.vue                      # 根组件
│   │   └── main.ts                      # 入口文件
│   ├── index.html                        # HTML入口
│   ├── package.json                      # NPM依赖
│   └── vite.config.ts                    # Vite配置
│
├── database/                             # 数据库脚本
│   └── init/
│       ├── 00_create_user.sql           # 创建SOCCERHUB用户
│       ├── 01_schema.sql                # 完整建表+存储过程+触发器+初始数据
│       ├── social_tables.sql            # 社区功能表（帖子、评论、点赞、收藏）
│       ├── post_comment_table.sql       # 帖子评论表
│       ├── circle_tables.sql            # 球迷圈子表
│       ├── update_player_stats*.sql     # 球员统计更新脚本
│       ├── add_match_event.sql          # 比赛事件表
│       ├── add_standings_triggers.sql   # 积分榜触发器
│       ├── create_season_table.sql      # 赛季管理表
│       ├── seed_seasons.sql             # 赛季初始数据
│       └── database_compatible.sql    # 数据库优化脚本（索引、视图、序列）
│
├── docker-compose.yml                    # Docker编排（Oracle数据库）
└── README.md
```

***

## 快速开始

### 环境要求

| 组件              | 版本     | 说明     |
| --------------- | ------ | ------ |
| JDK             | 21+    | 后端运行环境 |
| Node.js         | 18+    | 前端构建环境 |
| Maven           | 3.9+   | 后端构建工具 |
| Oracle Database | 21c XE | 数据库    |
| Docker          | 24+    | 容器化部署  |

### 步骤1：启动Oracle数据库

```bash
# 使用Docker启动Oracle 21c
docker compose up -d oracle21

# 等待数据库启动完成（约3-5分钟）
docker logs soccer_oracle21 --tail 20
# 看到 "DATABASE IS READY TO USE!" 表示启动完成
```

### 步骤2：初始化数据库

```bash
# 方式A：使用sqlplus
sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1 @database/init/01_schema.sql

# 方式B：使用Docker exec
docker exec -it soccer_oracle21 bash -c "sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1 @/path/to/01_schema.sql"
```

### 步骤3：启动后端

```bash
cd backend
mvn spring-boot:run
```

后端启动成功后，API地址：`http://localhost:8080/api`
Swagger文档：`http://localhost:8080/api/swagger-ui.html`

### 步骤4：启动前端

```bash
cd frontend
npm install
npm run dev
```

访问 `http://localhost:3000`

***

## 部署指南

### Docker部署（推荐）

```bash
# 克隆项目
git clone https://github.com/Charles797-code/SoccerHub.git
cd SoccerHub

# 启动Oracle数据库
docker compose up -d oracle21

# 等待数据库就绪
sleep 180

# 初始化数据库
sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1 @database/init/01_schema.sql

# 启动后端
cd backend && mvn spring-boot:run &

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

#### Nginx配置

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # 前端静态资源
    location / {
        root /path/to/frontend/dist;
        try_files $uri $uri/ /index.html;
    }

    # API反向代理
    location /api/ {
        proxy_pass http://127.0.0.1:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # WebSocket代理
    location /ws/ {
        proxy_pass http://127.0.0.1:8080/ws/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # 上传文件
    location /uploads/ {
        alias /path/to/uploads/;
    }
}
```

***

## 核心数据库说明

### 核心数据表（33个）

| 序号 | 表名 | 说明 |
|------|------|------|
| 1 | SYS_USER | 用户表 |
| 2 | CLUB | 俱乐部表 |
| 3 | PLAYER | 球员表 |
| 4 | COACH | 教练表 |
| 5 | MATCH_SCHEDULE | 赛程表 |
| 6 | MATCH_PLAYER_RATING | 球员评分表 |
| 7 | MATCH_COMMENT | 比赛评论表 |
| 8 | MATCH_EVENT | 比赛事件表 |
| 9 | MATCH_STATISTICS | 比赛统计表 |
| 10 | CLUB_CHAT_MESSAGE | 俱乐部聊天室消息表 |
| 11 | CLUB_HONOR | 俱乐部荣誉表 |
| 12 | NEWS_ARTICLE | 新闻表 |
| 13 | NEWS_COMMENT | 新闻评论表 |
| 14 | NEWS_MEDIA | 新闻媒体表 |
| 15 | POST | 帖子表 |
| 16 | POST_COMMENT | 帖子评论表 |
| 17 | POST_LIKE | 帖子点赞表 |
| 18 | POST_FAVORITE | 帖子收藏表 |
| 19 | USER_FOLLOW | 用户关注表 |
| 20 | USER_CLUB_FOLLOW | 用户俱乐部关注表 |
| 21 | CIRCLE | 球迷圈子表 |
| 22 | CIRCLE_MEMBER | 圈子成员表 |
| 23 | LEAGUE_STANDINGS | 联赛积分表 |
| 24 | PLAYER_SEASON_STATS | 球员赛季数据表 |
| 25 | PLAYER_INJURY | 球员伤病表 |
| 26 | PLAYER_PROFILE | 球员档案表 |
| 27 | RATING_RECORD | 评分记录表 |
| 28 | TRANSFER_HISTORY_LOG | 转会记录表 |
| 29 | AUDIT_LOG | 审计日志表 |
| 30 | SYSTEM_DICTIONARY | 系统字典表 |
| 31 | SYSTEM_CONFIG | 系统配置表 |
| 32 | USER_NOTIFICATION | 用户通知表 |
| 33 | SEASON | 赛季管理表 |

### 存储过程

| 过程名                           | 功能                      |
| ----------------------------- | ----------------------- |
| osp\_Submit\_User\_Rating     | 评分提交（含24小时防刷保护）         |
| osp\_Upsert\_Match\_Schedule  | 赛程Upsert（插入或更新）         |
| osp\_Transfer\_Player         | 球员转会（含权限校验）             |
| osp\_Moderate\_Message        | 消息审核（删除/折叠）             |
| osp\_Batch\_Update\_Standings | 批量更新联赛积分榜               |
| osp\_Start\_New\_Season       | 开启新赛季（结束旧赛季、清空数据、创建新赛季） |
| osp\_Reset\_Season\_Data      | 重置赛季数据（清空积分榜、球员统计、比赛）   |
| osp\_Finish\_Season           | 结束赛季（将赛季状态设为FINISHED）   |

### 触发器

- 评分提交后自动更新球员/教练平均分
- 比赛结束后自动更新积分榜
- 进球/助攻后自动更新球员赛季统计
- 赛季结束时自动将状态更新为FINISHED
- 新赛季开始后自动清空上赛季数据（积分榜、球员统计、比赛日程）

***

## 数据库优化

### 表空间（5个）

| 表空间名     | 状态     |
| -------- | ------ |
| SYSAUX   | ONLINE |
| SYSTEM   | ONLINE |
| TEMP     | ONLINE |
| UNDOTBS1 | ONLINE |
| USERS    | ONLINE |

### 序列（45个）

| 序列名                                                                          |
| ---------------------------------------------------------------------------- |
| ISEQ$$\_76328, ISEQ$$\_76332, ISEQ$$\_76337, ISEQ$$\_76620, ISEQ$$\_76794    |
| SEQ\_AUDIT, SEQ\_AUDIT\_ID, SEQ\_CHAT\_ID, SEQ\_CIRCLE, SEQ\_CIRCLE\_ID      |
| SEQ\_CIRCLE\_MEMBER, SEQ\_CLUB, SEQ\_CLUB\_HONOR, SEQ\_CLUB\_ID, SEQ\_COACH  |
| SEQ\_COACH\_ID, SEQ\_COMMENT\_ID, SEQ\_DICTIONARY, SEQ\_MATCH\_EVENT         |
| SEQ\_MATCH\_STATS, SEQ\_MESSAGE, SEQ\_NEWS, SEQ\_NEWS\_ID, SEQ\_NEWS\_MEDIA  |
| SEQ\_NOTIFICATION, SEQ\_PLAYER, SEQ\_PLAYER\_ID, SEQ\_PLAYER\_INJURY         |
| SEQ\_PLAYER\_PROFILE, SEQ\_PLAYER\_STATS, SEQ\_POST, SEQ\_POST\_FAVORITE     |
| SEQ\_POST\_ID, SEQ\_POST\_LIKE, SEQ\_RATING, SEQ\_SEASON\_ID, SEQ\_STANDINGS |
| SEQ\_STANDING\_ID, SEQ\_STATS\_ID, SEQ\_SYSTEM\_CONFIG, SEQ\_SYS\_USER       |
| SEQ\_SYS\_USER\_ID, SEQ\_TRANSFER, SEQ\_TRANSFER\_ID, SEQ\_USER\_FOLLOW      |

### 索引（203个）

| 表名                     | 索引                                                                                                                                                                          |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| AUDIT\_LOG             | SYS\_C008436\~438                                                                                                                                                           |
| CHAT\_MESSAGE          | IDX\_CHAT\_CLUB, IDX\_CHAT\_TIME, IDX\_CHAT\_USER                                                                                                                           |
| CIRCLE                 | IDX\_CIRCLE\_CLUB, IDX\_CIRCLE\_STATUS, SYS\_C008450\~452                                                                                                                   |
| CIRCLE\_MEMBER         | IDX\_CIRCLE\_MEMBER\_CIRCLE, IDX\_CIRCLE\_MEMBER\_USER, SYS\_C008455\~457                                                                                                   |
| CLUB                   | IDX\_CLUB\_LEAGUE, IDX\_CLUB\_NAME, SYS\_C008444\~447                                                                                                                       |
| CLUB\_HONOR            | SYS\_C008468\~470                                                                                                                                                           |
| COACH                  | IDX\_COACH\_CLUB, IDX\_COACH\_LEAGUE, SYS\_C008476\~478                                                                                                                     |
| MATCH\_COMMENT         | IDX\_MATCH\_COMMENT\_MATCH, IDX\_MATCH\_COMMENT\_TIME, IDX\_MATCH\_COMMENT\_USER                                                                                            |
| MATCH\_EVENT           | IDX\_EVENT\_MATCH, IDX\_EVENT\_PLAYER, IDX\_EVENT\_TYPE                                                                                                                     |
| MATCH\_SCHEDULE        | IDX\_MATCH\_AWAY\_CLUB, IDX\_MATCH\_HOME\_CLUB, IDX\_MATCH\_LEAGUE, IDX\_MATCH\_LEAGUE\_SEASON, IDX\_MATCH\_ROUND, IDX\_MATCH\_SEASON, IDX\_MATCH\_STATUS, IDX\_MATCH\_TIME |
| NEWS\_ARTICLE          | IDX\_NEWS\_AUTHOR, IDX\_NEWS\_CLUB, IDX\_NEWS\_PUBLISHED, IDX\_NEWS\_TITLE                                                                                                  |
| NEWS\_COMMENT          | IDX\_NEWS\_COMMENT\_ARTICLE, IDX\_NEWS\_COMMENT\_TIME, IDX\_NEWS\_COMMENT\_USER                                                                                             |
| PLAYER                 | IDX\_PLAYER\_CLUB, IDX\_PLAYER\_LEAGUE, IDX\_PLAYER\_NAME, IDX\_PLAYER\_NAME\_CN, IDX\_PLAYER\_POSITION, IDX\_PLAYER\_STATUS                                                |
| PLAYER\_INJURY         | IDX\_INJURY\_PLAYER, IDX\_INJURY\_STATUS, SYS\_C008527\~529                                                                                                                 |
| PLAYER\_PROFILE        | IDX\_PROFILE\_PLAYER, SYS\_C008532\~533                                                                                                                                     |
| PLAYER\_SEASON\_STATS  | IDX\_STATS\_ASSISTS, IDX\_STATS\_CLUB, IDX\_STATS\_GOALS, IDX\_STATS\_LEAGUE, IDX\_STATS\_LEAGUE\_GOALS, IDX\_STATS\_PLAYER\_SEASON, IDX\_STATS\_SEASON                     |
| POST                   | IDX\_POST\_CIRCLE, IDX\_POST\_CLUB, IDX\_POST\_CREATED, IDX\_POST\_PINNED, IDX\_POST\_TIME, IDX\_POST\_USER                                                                 |
| POST\_COMMENT          | IDX\_COMMENT\_PARENT, IDX\_COMMENT\_POST, IDX\_COMMENT\_USER, IDX\_POST\_COMMENT\_TIME                                                                                      |
| POST\_FAVORITE         | IDX\_POST\_FAVORITE\_POST, IDX\_POST\_FAVORITE\_USER, UK\_POST\_FAVORITE                                                                                                    |
| POST\_LIKE             | IDX\_POST\_LIKE\_POST, IDX\_POST\_LIKE\_USER, UK\_POST\_LIKE                                                                                                                |
| RATING\_RECORD         | BITMAP\_RATING\_TYPE, IDX\_RATING\_CREATED, IDX\_RATING\_TARGET, IDX\_RATING\_TARGET\_SCORE, IDX\_RATING\_TYPE\_CREATED, IDX\_RATING\_USER, IDX\_RATING\_USER\_TARGET       |
| SEASON                 | IDX\_SEASON\_LEAGUE, IDX\_SEASON\_NAME, IDX\_SEASON\_STATUS                                                                                                                 |
| SYSTEM\_CONFIG         | SYS\_C008565\~566                                                                                                                                                           |
| SYSTEM\_DICTIONARY     | IDX\_DICT\_ENABLED, IDX\_DICT\_TYPE                                                                                                                                         |
| SYS\_USER              | BITMAP\_USER\_ROLE, IDX\_USER\_STATUS, IDX\_USER\_USERNAME\_UPPER                                                                                                           |
| TRANSFER\_HISTORY\_LOG | IDX\_TRANSFER\_NEW\_CLUB, IDX\_TRANSFER\_OLD\_CLUB, IDX\_TRANSFER\_PLAYER, IDX\_TRANSFER\_PLAYER\_SEASON, IDX\_TRANSFER\_SEASON, IDX\_TRANSFER\_TIME, IDX\_TRANSFER\_TYPE   |
| USER\_CLUB\_FOLLOW     | IDX\_FOLLOW\_CLUB, IDX\_FOLLOW\_IS\_PRIMARY, IDX\_FOLLOW\_USER                                                                                                              |
| USER\_FOLLOW           | IDX\_USER\_FOLLOW\_FOLLOWER, IDX\_USER\_FOLLOW\_FOLLOWING, UK\_USER\_FOLLOW                                                                                                 |
| USER\_NOTIFICATION     | BITMAP\_NOTIFICATION\_READ, IDX\_NOTIFICATION\_CREATED, IDX\_NOTIFICATION\_READ, IDX\_NOTIFICATION\_TYPE, IDX\_NOTIFICATION\_USER                                           |

### 视图（27个）

| 视图名                                                                                                |
| -------------------------------------------------------------------------------------------------- |
| V\_CHAT\_MESSAGE\_HISTORY, V\_CHAT\_STATS, V\_CLUB\_FULL\_INFO, V\_CLUB\_HONORS, V\_CLUB\_OVERVIEW |
| V\_COACH\_RANKINGS, V\_DISCIPLINE\_RANKINGS                                                        |
| V\_LEAGUE\_STANDINGS\_VIEW, V\_LEAGUE\_SUMMARY                                                     |
| V\_MATCH\_DETAILS, V\_MATCH\_DETAIL\_STATS, V\_MATCH\_LIVE\_SCORE                                  |
| V\_NEWS\_FULL                                                                                      |
| V\_NOTIFICATION\_SUMMARY                                                                           |
| V\_PLAYER\_FULL\_INFO, V\_PLAYER\_INJURY\_STATUS, V\_PLAYER\_RANKINGS                              |
| V\_POST\_FULL                                                                                      |
| V\_PUBLIC\_CLUB\_INFO, V\_PUBLIC\_PLAYER\_INFO                                                     |
| V\_SCORERS\_FULL, V\_SEASON\_SUMMARY                                                               |
| V\_TOP\_ASSISTS, V\_TOP\_SCORERS                                                                   |
| V\_USER\_ACTIVITY, V\_USER\_DASHBOARD, V\_USER\_DETAILS                                            |

### 触发器（19个）

| 触发器名                                            | 表/视图            | 类型              |
| ----------------------------------------------- | --------------- | --------------- |
| TRG\_CLUB\_CREATE\_CIRCLE                       | CLUB            | -               |
| TR\_INIT\_STANDINGS\_ON\_NEW\_CLUB              | CLUB            | AFTER EACH ROW  |
| TR\_UPDATE\_STANDINGS\_ON\_CLUB\_LEAGUE\_CHANGE | CLUB            | COMPOUND        |
| TR\_MAINTAIN\_CLUB\_TOTAL\_SCORE\_COACH         | COACH           | COMPOUND        |
| TR\_UPDATE\_MATCH\_EVENT\_COUNT                 | MATCH\_EVENT    | AFTER STATEMENT |
| TR\_MATCH\_FINISH\_NOTIFICATION                 | MATCH\_SCHEDULE | AFTER EACH ROW  |
| TR\_UPDATE\_STANDINGS\_ON\_MATCH\_RESULT        | MATCH\_SCHEDULE | COMPOUND        |
| TR\_VALIDATE\_MATCH\_LEAGUE                     | MATCH\_SCHEDULE | BEFORE EACH ROW |
| TR\_NEWS\_PUBLISH\_TIME                         | NEWS\_ARTICLE   | BEFORE EACH ROW |
| TR\_MAINTAIN\_CLUB\_TOTAL\_SCORE                | PLAYER          | COMPOUND        |
| TR\_PLAYER\_STATUS\_CHANGE                      | PLAYER          | AFTER EACH ROW  |
| TR\_TRANSFER\_HISTORY\_ON\_PLAYER\_UPDATE       | PLAYER          | COMPOUND        |
| TR\_AUDIT\_USER\_RATING                         | RATING\_RECORD  | COMPOUND        |
| TR\_CALCULATE\_AVERAGE\_SCORE                   | RATING\_RECORD  | COMPOUND        |
| TR\_RATING\_ANTI\_SPAM                          | RATING\_RECORD  | BEFORE EACH ROW |
| TR\_AUDIT\_USER\_ROLE\_CHANGE                   | SYS\_USER       | AFTER EACH ROW  |
| TR\_AUDIT\_USER\_STATUS\_CHANGE                 | SYS\_USER       | AFTER EACH ROW  |
| TR\_USER\_LOGIN\_UPDATE                         | SYS\_USER       | AFTER EACH ROW  |
| TR\_INSTEADOF\_CLUB\_HONORS                     | V\_CLUB\_HONORS | INSTEAD OF      |

### 大对象LOB（16个）

| 表名                  | 列名                                                       |
| ------------------- | -------------------------------------------------------- |
| AUDIT\_LOG          | OLD\_VALUE, NEW\_VALUE                                   |
| CLUB                | DESCRIPTION                                              |
| CLUB\_CHAT\_MESSAGE | CONTENT                                                  |
| CLUB\_HONOR         | DESCRIPTION                                              |
| NEWS\_ARTICLE       | CONTENT                                                  |
| NEWS\_MEDIA         | FILE\_BLOB                                               |
| PLAYER\_INJURY      | DESCRIPTION                                              |
| PLAYER\_PROFILE     | BIO\_NCLOB, CAREER\_HISTORY, DOCUMENT\_BLOB, PHOTO\_BLOB |
| POST                | CONTENT                                                  |
| SYSTEM\_CONFIG      | CONFIG\_BLOB, CONFIG\_CLOB                               |
| USER\_NOTIFICATION  | CONTENT                                                  |

***

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
  secret: SoccerHub2024SecretKeyForJWTTokenGeneration
  expiration: 86400000  # 24小时

upload:
  path: uploads

ai:
  qwen:
    api-key: your-api-key  # 通义千问API Key
```

### 前端环境变量

```bash
# .env.production
VITE_API_BASE_URL=/api
```

***

## 演示账号

| 用户名               | 密码       | 角色           | 说明           |
| ----------------- | -------- | ------------ | ------------ |
| admin             | admin123 | SUPER\_ADMIN | 超级管理员，拥有所有权限 |
| realmadrid\_admin | admin123 | CLUB\_ADMIN  | 皇家马德里俱乐部管理员  |
| fan\_lionel       | admin123 | FAN          | 普通球迷用户       |
| mancity\_admin    | admin123 | CLUB\_ADMIN  | 曼城俱乐部管理员     |
| bayern\_admin     | admin123 | CLUB\_ADMIN  | 拜仁俱乐部管理员     |

***

## API 文档

启动后端后，访问完整API文档：

```
http://localhost:8080/api/swagger-ui.html
```

### 认证模块

| 方法   | 端点                 | 说明       |
| ---- | ------------------ | -------- |
| POST | /api/auth/login    | 用户登录     |
| POST | /api/auth/register | 用户注册     |
| POST | /api/auth/refresh  | 刷新Token  |
| GET  | /api/auth/user/me  | 获取当前用户信息 |

### 俱乐部模块

| 方法  | 端点              | 说明    |
| --- | --------------- | ----- |
| GET | /api/clubs      | 俱乐部列表 |
| GET | /api/clubs/{id} | 俱乐部详情 |

### 球员模块

| 方法  | 端点                         | 说明      |
| --- | -------------------------- | ------- |
| GET | /api/players               | 球员列表    |
| GET | /api/players/{id}          | 球员详情    |
| GET | /api/players/rankings      | 球员评分榜   |
| GET | /api/players/club/{clubId} | 俱乐部球员列表 |

### 教练模块

| 方法  | 端点                    | 说明    |
| --- | --------------------- | ----- |
| GET | /api/coaches          | 教练列表  |
| GET | /api/coaches/{id}     | 教练详情  |
| GET | /api/coaches/rankings | 教练评分榜 |

### 比赛模块

| 方法     | 端点                    | 说明      |
| ------ | --------------------- | ------- |
| GET    | /api/matches          | 比赛列表    |
| GET    | /api/matches/{id}     | 比赛详情    |
| GET    | /api/matches/today    | 今日赛事    |
| GET    | /api/matches/live     | 直播比赛    |
| GET    | /api/matches/upcoming | 即将开始的比赛 |
| POST   | /api/matches/upsert   | 创建/更新赛程 |
| DELETE | /api/matches/{id}     | 删除赛程    |

### 评分模块

| 方法   | 端点                                      | 说明     |
| ---- | --------------------------------------- | ------ |
| POST | /api/ratings                            | 提交评分   |
| GET  | /api/ratings/target/{type}/{id}         | 获取评分列表 |
| GET  | /api/ratings/target/{type}/{id}/average | 获取平均分  |

### 聊天室模块

| 方法   | 端点                          | 说明          |
| ---- | --------------------------- | ----------- |
| GET  | /api/chat/{clubId}/messages | 获取聊天记录      |
| POST | /api/chat/{clubId}/messages | 发送消息        |
| WS   | /ws/topic/club/{clubId}     | WebSocket订阅 |

### 新闻模块

| 方法     | 端点                      | 说明     |
| ------ | ----------------------- | ------ |
| GET    | /api/news               | 新闻列表   |
| GET    | /api/news/{id}          | 新闻详情   |
| POST   | /api/news/scrape        | 爬取新闻   |
| POST   | /api/news               | 创建新闻   |
| PUT    | /api/news/{id}          | 更新新闻   |
| DELETE | /api/news/{id}          | 删除新闻   |
| GET    | /api/news/{id}/comments | 获取新闻评论 |
| POST   | /api/news/{id}/comments | 添加新闻评论 |

### 社区模块

| 方法     | 端点                              | 说明       |
| ------ | ------------------------------- | -------- |
| GET    | /api/social/user/{userId}       | 获取用户资料   |
| PUT    | /api/social/profile             | 更新个人资料   |
| POST   | /api/social/follow/{userId}     | 关注用户     |
| GET    | /api/social/followers/{userId}  | 获取粉丝列表   |
| GET    | /api/social/following/{userId}  | 获取关注列表   |
| GET    | /api/social/circles             | 获取所有球迷圈子 |
| GET    | /api/social/posts               | 获取帖子列表   |
| POST   | /api/social/posts               | 发布帖子     |
| GET    | /api/social/posts/{id}          | 帖子详情     |
| POST   | /api/social/posts/{id}/like     | 点赞帖子     |
| DELETE | /api/social/posts/{id}/like     | 取消点赞     |
| POST   | /api/social/posts/{id}/favorite | 收藏帖子     |
| DELETE | /api/social/posts/{id}/favorite | 取消收藏     |
| GET    | /api/social/posts/{id}/comments | 获取帖子评论   |
| POST   | /api/social/posts/{id}/comments | 添加评论     |

### 关注模块

| 方法     | 端点                              | 说明        |
| ------ | ------------------------------- | --------- |
| POST   | /api/follows                    | 关注俱乐部     |
| DELETE | /api/follows/{clubId}           | 取消关注      |
| GET    | /api/follows/my-follows         | 获取我关注的俱乐部 |
| GET    | /api/follows/{clubId}/followers | 获取俱乐部粉丝数  |

### 积分榜模块

| 方法   | 端点                          | 说明      |
| ---- | --------------------------- | ------- |
| GET  | /api/standings              | 联赛积分榜   |
| POST | /api/standings              | 创建/更新积分 |
| GET  | /api/standings/scorers      | 射手榜     |
| GET  | /api/standings/assists      | 助攻榜     |
| GET  | /api/standings/yellow-cards | 黄牌榜     |

### 管理后台（SUPER\_ADMIN）

| 方法   | 端点                            | 说明     |
| ---- | ----------------------------- | ------ |
| GET  | /api/admin/dashboard/stats    | 仪表盘统计  |
| GET  | /api/admin/users              | 用户列表   |
| PUT  | /api/admin/users/{id}/role    | 修改用户角色 |
| PUT  | /api/admin/users/{id}/status  | 修改用户状态 |
| GET  | /api/admin/audit-logs         | 审计日志   |
| GET  | /api/admin/dictionary         | 系统字典   |
| PUT  | /api/admin/dictionary/{id}    | 更新字典   |
| GET  | /api/analytics/stats          | 数据分析统计 |
| GET  | /api/analytics/export/{type}  | 导出数据   |
| POST | /api/analytics/import/players | 导入球员   |
| POST | /api/analytics/import/matches | 导入比赛   |

### 赛季管理模块

| 方法   | 端点                           | 说明                   |
| ---- | ---------------------------- | -------------------- |
| GET  | /api/seasons                 | 获取所有赛季               |
| GET  | /api/seasons/active          | 获取所有活跃赛季             |
| GET  | /api/seasons/league/{league} | 按联赛获取赛季              |
| GET  | /api/seasons/active/{league} | 获取联赛当前赛季             |
| POST | /api/seasons                 | 创建赛季（SUPER\_ADMIN）   |
| POST | /api/seasons/start-new       | 开启新赛季（SUPER\_ADMIN）  |
| POST | /api/seasons/reset/{league}  | 重置赛季数据（SUPER\_ADMIN） |
| PUT  | /api/seasons/finish/{league} | 结束赛季（SUPER\_ADMIN）   |
| POST | /api/seasons/init-db         | 初始化赛季表（仅首次）          |
| POST | /api/seasons/seed            | 初始化赛季数据              |

### 俱乐部管理员（CLUB\_ADMIN）

| 方法     | 端点                                    | 说明      |
| ------ | ------------------------------------- | ------- |
| GET    | /api/club-admin/club                  | 我的俱乐部信息 |
| PUT    | /api/club-admin/club                  | 更新俱乐部信息 |
| GET    | /api/club-admin/players               | 我的球员列表  |
| POST   | /api/club-admin/players               | 添加球员    |
| PUT    | /api/club-admin/players/{id}          | 更新球员    |
| DELETE | /api/club-admin/players/{id}          | 删除球员    |
| POST   | /api/club-admin/players/{id}/transfer | 球员转会    |

### AI助手

| 方法   | 端点           | 说明   |
| ---- | ------------ | ---- |
| POST | /api/ai/chat | 发送对话 |

### 文件上传

| 方法   | 端点                 | 说明   |
| ---- | ------------------ | ---- |
| POST | /api/upload/image  | 上传图片 |
| POST | /api/upload/avatar | 上传头像 |

***

## License

MIT License
