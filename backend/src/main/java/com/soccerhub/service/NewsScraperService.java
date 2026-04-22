package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.soccerhub.entity.NewsArticle;
import com.soccerhub.mapper.NewsArticleMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class NewsScraperService {

    private final NewsArticleMapper newsMapper;
    private final JdbcTemplate jdbcTemplate;

    private static final String UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

    public void ensureTableExists() {
        try {
            jdbcTemplate.execute("SELECT 1 FROM NEWS_ARTICLE WHERE 1=0");
            ensureColumnsExist();
        } catch (Exception e) {
            log.info("NEWS_ARTICLE table not found, creating...");
            jdbcTemplate.execute("""
                CREATE TABLE NEWS_ARTICLE (
                    ARTICLE_ID      NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                    TITLE           VARCHAR2(500) NOT NULL,
                    SUMMARY         VARCHAR2(2000),
                    CONTENT         CLOB,
                    SOURCE_URL      VARCHAR2(1000),
                    SOURCE_NAME     VARCHAR2(100),
                    AUTHOR_ID       NUMBER,
                    CLUB_ID         NUMBER,
                    TAGS            VARCHAR2(500),
                    COVER_IMAGE_URL VARCHAR2(500),
                    VIEW_COUNT      NUMBER        DEFAULT 0,
                    IS_PUBLISHED    NUMBER        DEFAULT 1,
                    PUBLISHED_AT    TIMESTAMP     DEFAULT SYSTIMESTAMP,
                    CREATED_AT      TIMESTAMP     DEFAULT SYSTIMESTAMP,
                    UPDATED_AT      TIMESTAMP
                )
                """);
            log.info("NEWS_ARTICLE table created successfully");
        }
    }

    private void ensureColumnsExist() {
        String[][] columns = {
            {"SOURCE_URL", "VARCHAR2(1000)"},
            {"SOURCE_NAME", "VARCHAR2(100)"},
            {"AUTHOR_ID", "NUMBER"},
            {"CLUB_ID", "NUMBER"},
            {"TAGS", "VARCHAR2(500)"},
            {"COVER_IMAGE_URL", "VARCHAR2(500)"},
            {"VIEW_COUNT", "NUMBER DEFAULT 0"},
            {"IS_PUBLISHED", "NUMBER DEFAULT 1"},
            {"PUBLISHED_AT", "TIMESTAMP"},
            {"CREATED_AT", "TIMESTAMP"},
            {"UPDATED_AT", "TIMESTAMP"},
            {"SUMMARY", "VARCHAR2(2000)"},
            {"CONTENT", "CLOB"}
        };
        for (String[] col : columns) {
            addColumnIfNotExists("NEWS_ARTICLE", col[0], col[1]);
        }
    }

    private void addColumnIfNotExists(String table, String column, String definition) {
        try {
            jdbcTemplate.execute("SELECT " + column + " FROM " + table + " WHERE 1=0");
        } catch (Exception e) {
            log.info("Adding column {} to {}", column, table);
            try {
                jdbcTemplate.execute("ALTER TABLE " + table + " ADD " + column + " " + definition);
                log.info("Column {} added successfully", column);
            } catch (Exception ex) {
                log.warn("Failed to add column {}: {}", column, ex.getMessage());
            }
        }
    }

    @Transactional
    public List<NewsArticle> scrapeFromDongqiudi() {
        ensureTableExists();
        List<NewsArticle> articles = new ArrayList<>();
        try {
            Document doc = Jsoup.connect("https://www.dongqiudi.com/")
                    .userAgent(UA)
                    .timeout(15000)
                    .followRedirects(true)
                    .get();

            Elements newsItems = doc.select("a[href]");
            int count = 0;
            for (Element item : newsItems) {
                if (count >= 20) break;
                try {
                    String title = item.text().trim();
                    String link = item.absUrl("href");

                    if (title.isEmpty() || title.length() < 8) continue;
                    if (link.isEmpty()) continue;
                    if (!link.contains("dongqiudi.com")) continue;

                    QueryWrapper<NewsArticle> check = new QueryWrapper<>();
                    check.eq("TITLE", title.length() > 200 ? title.substring(0, 200) : title);
                    if (newsMapper.selectCount(check) > 0) continue;

                    NewsArticle article = new NewsArticle();
                    article.setTitle(title.length() > 200 ? title.substring(0, 200) : title);
                    article.setSourceUrl(link);
                    article.setSourceName("懂球帝");
                    article.setSummary("");
                    article.setContent("");
                    article.setViewCount(0);
                    article.setIsPublished(1);
                    article.setPublishedAt(LocalDateTime.now());
                    article.setCreatedAt(LocalDateTime.now());

                    newsMapper.insert(article);
                    articles.add(article);
                    count++;
                } catch (Exception ex) {
                    log.warn("Failed to parse news item: {}", ex.getMessage());
                }
            }
            log.info("Scraped {} articles from dongqiudi", articles.size());
        } catch (Exception e) {
            log.error("Failed to scrape from dongqiudi: {}", e.getMessage());
        }
        return articles;
    }

    @Transactional
    public List<NewsArticle> scrapeFromSinaSports() {
        ensureTableExists();
        List<NewsArticle> articles = new ArrayList<>();
        try {
            Document doc = Jsoup.connect("https://sports.sina.com.cn/g/")
                    .userAgent(UA)
                    .timeout(15000)
                    .followRedirects(true)
                    .get();

            Elements links = doc.select("a[href]");
            int count = 0;
            for (Element link : links) {
                if (count >= 20) break;
                try {
                    String title = link.text().trim();
                    String href = link.absUrl("href");

                    if (title.isEmpty() || title.length() < 8) continue;
                    if (!href.contains("sina")) continue;

                    QueryWrapper<NewsArticle> check = new QueryWrapper<>();
                    check.eq("TITLE", title.length() > 200 ? title.substring(0, 200) : title);
                    if (newsMapper.selectCount(check) > 0) continue;

                    NewsArticle article = new NewsArticle();
                    article.setTitle(title.length() > 200 ? title.substring(0, 200) : title);
                    article.setSourceUrl(href);
                    article.setSourceName("新浪体育");
                    article.setSummary("");
                    article.setContent("");
                    article.setViewCount(0);
                    article.setIsPublished(1);
                    article.setPublishedAt(LocalDateTime.now());
                    article.setCreatedAt(LocalDateTime.now());

                    newsMapper.insert(article);
                    articles.add(article);
                    count++;
                } catch (Exception ex) {
                    log.warn("Failed to parse news item: {}", ex.getMessage());
                }
            }
            log.info("Scraped {} articles from sina sports", articles.size());
        } catch (Exception e) {
            log.error("Failed to scrape from sina sports: {}", e.getMessage());
        }
        return articles;
    }

    @Transactional
    public NewsArticle scrapeArticleDetail(Long articleId) {
        ensureTableExists();
        NewsArticle article = newsMapper.selectById(articleId);
        if (article == null) throw new RuntimeException("Article not found");
        if (article.getSourceUrl() == null || article.getSourceUrl().isEmpty()) return article;

        try {
            Document doc = Jsoup.connect(article.getSourceUrl())
                    .userAgent(UA)
                    .timeout(15000)
                    .followRedirects(true)
                    .get();

            Elements contentElements = doc.select("article, .article-content, .content, .news-content, .detail-content, #artibody, .article_body");
            if (contentElements.isEmpty()) {
                contentElements = doc.select("p");
            }

            StringBuilder content = new StringBuilder();
            for (Element el : contentElements) {
                String text = el.text().trim();
                if (!text.isEmpty() && text.length() > 10) {
                    content.append(text).append("\n\n");
                }
            }

            if (content.length() > 0) {
                article.setContent(content.toString());
                article.setUpdatedAt(LocalDateTime.now());
                newsMapper.updateById(article);
            }

            if (article.getSummary() == null || article.getSummary().isEmpty()) {
                String summary = content.length() > 200 ? content.substring(0, 200) + "..." : content.toString();
                article.setSummary(summary);
                newsMapper.updateById(article);
            }

            Elements imgs = doc.select("article img, .article-content img, .content img, .news-content img");
            if (!imgs.isEmpty() && (article.getCoverImageUrl() == null || article.getCoverImageUrl().isEmpty())) {
                String imgSrc = imgs.first().absUrl("src");
                if (!imgSrc.isEmpty()) {
                    article.setCoverImageUrl(imgSrc);
                    newsMapper.updateById(article);
                }
            }
        } catch (Exception e) {
            log.error("Failed to scrape article detail: {}", e.getMessage());
        }
        return article;
    }

    @Transactional
    public void incrementViewCount(Long articleId) {
        ensureTableExists();
        try {
            NewsArticle article = newsMapper.selectById(articleId);
            if (article != null) {
                article.setViewCount(article.getViewCount() != null ? article.getViewCount() + 1 : 1);
                article.setUpdatedAt(LocalDateTime.now());
                newsMapper.updateById(article);
            }
        } catch (Exception e) {
            log.error("Failed to increment view count: {}", e.getMessage());
        }
    }
}
