package com.soccerhub.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class AiChatService {

    private final JdbcTemplate jdbcTemplate;

    @Value("${ai.qwen.api-key}")
    private String apiKey;

    @Value("${ai.qwen.model}")
    private String model;

    @Value("${ai.qwen.base-url}")
    private String baseUrl;

    private final RestTemplate restTemplate = new RestTemplate();

    private static final String DB_SCHEMA = """
            你可以查询以下Oracle数据库表（表名和字段名均为大写）：

            1. PLAYER（球员表）
               - PLAYER_ID NUMBER 主键
               - NAME VARCHAR2 球员英文名（如 Kylian Mbappé）
               - NAME_CN VARCHAR2 球员中文名（如 姆巴佩）
               - POSITION VARCHAR2 位置（FW=前锋, MF=中场, DF=后卫, GK=门将）
               - CLUB_ID NUMBER 所属俱乐部ID（外键关联CLUB）
               - JERSEY_NUMBER NUMBER 球衣号码
               - NATIONALITY VARCHAR2 国籍
               - BIRTH_DATE DATE 出生日期
               - HEIGHT_CM NUMBER 身高(cm)
               - WEIGHT_KG NUMBER 体重(kg)
               - STATUS VARCHAR2 状态（ACTIVE=活跃, INJURED=伤病, TRANSFER=转会中）
               - MARKET_VALUE NUMBER 身价(欧元)
               - AVG_SCORE NUMBER 平均评分
               - TOTAL_RATINGS NUMBER 评分人数

            2. CLUB（俱乐部表）
               - CLUB_ID NUMBER 主键
               - NAME VARCHAR2 俱乐部英文名（如 Real Madrid）
               - SHORT_NAME VARCHAR2 俱乐部中文简称（如 皇家马德里）
               - LEAGUE VARCHAR2 所属联赛（Premier League/La Liga/Bundesliga/Serie A/Ligue 1）
               - CITY VARCHAR2 城市
               - COUNTRY VARCHAR2 国家
               - STADIUM VARCHAR2 主场名称
               - ESTABLISH_DATE DATE 成立日期
               - STADIUM_CAPACITY NUMBER 主场容量
               - TOTAL_SCORE NUMBER 总评分

            3. COACH（教练表）
               - COACH_ID NUMBER 主键
               - NAME VARCHAR2 英文名
               - NAME_CN VARCHAR2 中文名
               - CLUB_ID NUMBER 所属俱乐部ID
               - ROLE VARCHAR2 职务（HEAD_COACH=主教练, ASSISTANT_COACH=助理教练, GOALKEEPER_COACH=守门员教练, FITNESS_COACH=体能教练, TACTICAL_ANALYST=战术分析师, TEAM_DOCTOR=队医）
               - IS_HEAD_COACH NUMBER 是否主教练(1=是,0=否)
               - NATIONALITY VARCHAR2 国籍
               - AVG_SCORE NUMBER 平均评分

            4. MATCH_SCHEDULE（比赛表）
               - MATCH_ID VARCHAR2 主键
               - HOME_CLUB_ID NUMBER 主场俱乐部ID
               - AWAY_CLUB_ID NUMBER 客场俱乐部ID
               - MATCH_TIME TIMESTAMP 比赛时间
               - HOME_SCORE NUMBER 主场得分
               - AWAY_SCORE NUMBER 客场得分
               - STATUS VARCHAR2 状态（SCHEDULED=未开始, LIVE=进行中, FINISHED=已结束）
               - ROUND VARCHAR2 轮次
               - VENUE VARCHAR2 场地
               - LEAGUE VARCHAR2 联赛
               - SEASON VARCHAR2 赛季

            5. TRANSFER_HISTORY_LOG（转会记录表）
               - LOG_ID NUMBER 主键
               - PLAYER_ID NUMBER 球员ID
               - OLD_CLUB_ID NUMBER 原俱乐部ID
               - NEW_CLUB_ID NUMBER 新俱乐部ID
               - TRANSFER_TYPE VARCHAR2 转会类型
               - TRANSFER_FEE NUMBER 转会费(欧元)
               - SEASON VARCHAR2 赛季
               - NOTES VARCHAR2 备注

            6. LEAGUE_STANDINGS（联赛积分榜）
               - STANDING_ID NUMBER 主键
               - LEAGUE VARCHAR2 联赛
               - SEASON VARCHAR2 赛季
               - CLUB_ID NUMBER 俱乐部ID
               - POSITION NUMBER 排名
               - PLAYED NUMBER 已赛场次
               - WON NUMBER 胜场
               - DRAWN NUMBER 平场
               - LOST NUMBER 负场
               - GOALS_FOR NUMBER 进球数
               - GOALS_AGAINST NUMBER 失球数
               - GOAL_DIFF NUMBER 净胜球
               - POINTS NUMBER 积分

            7. NEWS_ARTICLE（新闻资讯表）
               - ARTICLE_ID NUMBER 主键
               - TITLE VARCHAR2 标题
               - SUMMARY VARCHAR2 摘要
               - CONTENT CLOB 内容
               - AUTHOR_ID NUMBER 作者ID
               - CLUB_ID NUMBER 关联俱乐部ID
               - TAGS VARCHAR2 标签
               - VIEW_COUNT NUMBER 浏览量
               - IS_PUBLISHED NUMBER 是否发布(1/0)
               - PUBLISHED_AT TIMESTAMP 发布时间

            8. RATING_RECORD（评分记录表）
               - RECORD_ID NUMBER 主键
               - USER_ID NUMBER 评分用户ID
               - TARGET_ID NUMBER 评分对象ID
               - TARGET_TYPE VARCHAR2 评分对象类型（PLAYER/COACH/CLUB）
               - SCORE NUMBER 评分(1-10)
               - COMMENT_TEXT VARCHAR2 评论内容
               - MATCH_ID VARCHAR2 关联比赛ID

            9. USER_CLUB_FOLLOW（用户关注俱乐部表）
               - USER_ID NUMBER 用户ID
               - CLUB_ID NUMBER 俱乐部ID
               - IS_PRIMARY NUMBER 是否主队(1/0)

            10. SYS_USER（系统用户表）
                - USER_ID NUMBER 主键
                - USERNAME VARCHAR2 用户名
                - NICKNAME VARCHAR2 昵称
                - ROLE VARCHAR2 角色（USER/CLUB_ADMIN/SUPER_ADMIN）
                - MANAGED_CLUB_ID NUMBER 管理的俱乐部ID（俱乐部管理员）

            重要提示：
            - 数据库是Oracle，字符串拼接用 || 而不是CONCAT，分页用 FETCH FIRST N ROWS ONLY 而不是 LIMIT
            - 中文名字段存的是中文（如NAME_CN存"姆巴佩"），英文名字段存英文（如NAME存"Kylian Mbappé"）
            - 查询球员时建议同时匹配NAME和NAME_CN字段
            - 联赛名称用英文存储：Premier League, La Liga, Bundesliga, Serie A, Ligue 1
            - 俱乐部SHORT_NAME存的是中文简称（如"皇家马德里"），NAME存英文名（如"Real Madrid"）
            - POSITION字段：FW=前锋, MF=中场, DF=后卫, GK=门将
            """;

    private static final String SQL_GEN_SYSTEM_PROMPT = """
            你是Hub球宝，SoccerHub足球社区平台的AI助手。你的任务是根据用户的自然语言问题，生成Oracle SQL查询语句来从数据库获取信息。

            规则：
            1. 只生成SELECT查询，绝不生成INSERT/UPDATE/DELETE/DROP等修改语句
            2. 生成的SQL必须是Oracle语法
            3. 字符串匹配用LIKE或=，模糊匹配用 LIKE '%关键词%'
            4. 分页用 FETCH FIRST 50 ROWS ONLY
            5. 只输出一条SQL语句，不要输出多条
            6. 不要用markdown代码块包裹，直接输出纯SQL文本
            7. 查询结果要有意义，选择合适的字段，不要SELECT *
            8. 涉及多表关联时使用JOIN，确保关联条件正确
            9. 对于中文人名/俱乐部名查询，同时匹配NAME和NAME_CN字段
            10. 如果用户的问题不需要查询数据库（如打招呼、闲聊），请输出 NO_SQL

            以下是数据库表结构：
            """ + DB_SCHEMA;

    private static final String ANSWER_SYSTEM_PROMPT = """
            你是Hub球宝，SoccerHub足球社区平台的AI助手⚽。你友好、专业、热情，回答时适当使用emoji增加趣味性。

            你会收到用户的原始问题和从数据库查询到的结果。你需要：
            1. 根据查询结果准确回答用户的问题
            2. 用自然流畅的中文组织回答，不要简单罗列数据
            3. 如果查询结果为空，说明数据库中暂无相关数据，并尝试用你的足球知识给出一般性回答
            4. 如果数据量较多，重点突出用户关心的信息，适当归纳总结
            5. 涉及球员、俱乐部时，同时展示中英文名称
            6. 回答要有温度，像一个懂球的伙伴在聊天

            请用中文回答。
            """;

    public String chat(String userMessage) {
        try {
            String sql = generateSql(userMessage);

            if ("NO_SQL".equalsIgnoreCase(sql.trim())) {
                return callQwen(ANSWER_SYSTEM_PROMPT, "用户问题：" + userMessage + "\n\n（此问题不需要查询数据库，请直接回答）");
            }

            log.info("Generated SQL: {}", sql);

            if (!isSafeSelect(sql)) {
                return "⚠️ 抱歉，出于安全考虑，我只能执行查询操作，无法执行修改数据的语句。";
            }

            String queryResult = executeSql(sql);
            log.info("Query result: {}", queryResult);

            String userPrompt = "用户问题：" + userMessage + "\n\n执行的SQL查询：\n" + sql +
                    "\n\n查询结果：\n" + queryResult;

            return callQwen(ANSWER_SYSTEM_PROMPT, userPrompt);
        } catch (Exception e) {
            log.error("AI chat error: {}", e.getMessage(), e);
            return "抱歉，处理您的问题时出现错误：" + e.getMessage() + "。请换个方式再试试吧！";
        }
    }

    private String generateSql(String userMessage) {
        String prompt = "用户问题：" + userMessage + "\n\n请生成对应的Oracle SQL查询语句（只输出SQL，不要其他内容）：";
        String raw = callQwen(SQL_GEN_SYSTEM_PROMPT, prompt);

        String sql = raw.trim();
        if (sql.startsWith("```sql")) {
            sql = sql.substring(6);
        } else if (sql.startsWith("```")) {
            sql = sql.substring(3);
        }
        if (sql.endsWith("```")) {
            sql = sql.substring(0, sql.length() - 3);
        }
        return sql.trim();
    }

    private boolean isSafeSelect(String sql) {
        String upper = sql.toUpperCase().trim();
        if (!upper.startsWith("SELECT")) return false;
        String[] forbidden = {"INSERT", "UPDATE", "DELETE", "DROP", "ALTER", "CREATE", "TRUNCATE", "EXEC", "EXECUTE", "GRANT", "REVOKE"};
        for (String word : forbidden) {
            if (upper.contains(word)) return false;
        }
        return true;
    }

    private String executeSql(String sql) {
        try {
            List<Map<String, Object>> rows = jdbcTemplate.queryForList(sql);
            if (rows.isEmpty()) {
                return "（查询结果为空，数据库中没有匹配的数据）";
            }

            StringBuilder sb = new StringBuilder();
            int count = 0;
            for (Map<String, Object> row : rows) {
                if (count >= 50) {
                    sb.append("... 共查询到 ").append(rows.size()).append(" 条记录，仅展示前50条\n");
                    break;
                }
                List<String> parts = new ArrayList<>();
                for (Map.Entry<String, Object> entry : row.entrySet()) {
                    parts.add(entry.getKey() + ": " + (entry.getValue() != null ? entry.getValue() : "NULL"));
                }
                sb.append(String.join(" | ", parts)).append("\n");
                count++;
            }
            return sb.toString();
        } catch (Exception e) {
            log.error("SQL execution error: {}", e.getMessage());
            return "（SQL执行出错：" + e.getMessage() + "）";
        }
    }

    private String callQwen(String systemPrompt, String userPrompt) {
        Map<String, Object> requestBody = new LinkedHashMap<>();
        requestBody.put("model", model);
        requestBody.put("messages", List.of(
                Map.of("role", "system", "content", systemPrompt),
                Map.of("role", "user", "content", userPrompt)
        ));
        requestBody.put("temperature", 0.3);
        requestBody.put("max_tokens", 2048);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth(apiKey);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        try {
            String url = baseUrl + "/chat/completions";
            @SuppressWarnings("unchecked")
            Map<String, Object> response = restTemplate.postForObject(url, entity, Map.class);

            if (response != null && response.containsKey("choices")) {
                @SuppressWarnings("unchecked")
                List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
                if (!choices.isEmpty()) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
                    return (String) message.get("content");
                }
            }
            return "抱歉，AI服务暂时无法响应。";
        } catch (Exception e) {
            log.error("Qwen API call error: {}", e.getMessage(), e);
            throw new RuntimeException("AI服务调用失败：" + e.getMessage());
        }
    }
}
