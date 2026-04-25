package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.opencsv.CSVWriter;
import com.soccerhub.dto.AnalyticsStats;
import com.soccerhub.entity.*;
import com.soccerhub.mapper.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class AnalyticsService {

    private final SysUserMapper userMapper;
    private final ClubMapper clubMapper;
    private final PlayerMapper playerMapper;
    private final MatchScheduleMapper matchMapper;
    private final RatingRecordMapper ratingMapper;
    private final NewsArticleMapper newsMapper;
    private final MatchEventMapper matchEventMapper;
    private final PlayerSeasonStatsMapper playerSeasonStatsMapper;
    private final LeagueStandingMapper standingMapper;
    private final JdbcTemplate jdbcTemplate;

    public AnalyticsStats getAnalytics() {
        AnalyticsStats stats = new AnalyticsStats();

        AnalyticsStats.Overview overview = new AnalyticsStats.Overview();
        overview.setTotalUsers(userMapper.selectCount(null));
        overview.setTotalClubs(clubMapper.selectCount(null));
        overview.setTotalPlayers(playerMapper.selectCount(null));
        overview.setTotalMatches(matchMapper.selectCount(null));
        overview.setTotalRatings(ratingMapper.selectCount(null));
        overview.setTotalNews(newsMapper.selectCount(null));

        QueryWrapper<MatchSchedule> finishedW = new QueryWrapper<>();
        finishedW.eq("STATUS", "FINISHED");
        overview.setFinishedMatches(matchMapper.selectCount(finishedW));

        QueryWrapper<MatchSchedule> pendingW = new QueryWrapper<>();
        pendingW.eq("STATUS", "PENDING");
        overview.setPendingMatches(matchMapper.selectCount(pendingW));

        QueryWrapper<MatchSchedule> inProgressW = new QueryWrapper<>();
        inProgressW.eq("STATUS", "IN_PROGRESS");
        overview.setInProgressMatches(matchMapper.selectCount(inProgressW));

        QueryWrapper<MatchEvent> goalW = new QueryWrapper<>();
        goalW.in("EVENT_TYPE", "GOAL", "PENALTY");
        overview.setTotalGoals(matchEventMapper.selectCount(goalW));

        QueryWrapper<MatchEvent> assistW = new QueryWrapper<>();
        assistW.eq("EVENT_TYPE", "ASSIST");
        overview.setTotalAssists(matchEventMapper.selectCount(assistW));

        QueryWrapper<MatchEvent> yellowW = new QueryWrapper<>();
        yellowW.eq("EVENT_TYPE", "YELLOW_CARD");
        overview.setTotalYellowCards(matchEventMapper.selectCount(yellowW));

        QueryWrapper<MatchEvent> redW = new QueryWrapper<>();
        redW.eq("EVENT_TYPE", "RED_CARD");
        overview.setTotalRedCards(matchEventMapper.selectCount(redW));

        QueryWrapper<Player> activeW = new QueryWrapper<>();
        activeW.eq("STATUS", "ACTIVE");
        overview.setActivePlayers(playerMapper.selectCount(activeW));

        QueryWrapper<Player> injuredW = new QueryWrapper<>();
        injuredW.eq("STATUS", "INJURED");
        overview.setInjuredPlayers(playerMapper.selectCount(injuredW));

        stats.setOverview(overview);

        List<AnalyticsStats.LeagueStats> leagueStatsList = new ArrayList<>();
        List<Map<String, Object>> leagueRows = jdbcTemplate.queryForList(
            "SELECT c.LEAGUE, COUNT(DISTINCT c.CLUB_ID) AS CLUB_COUNT, " +
            "COUNT(DISTINCT p.PLAYER_ID) AS PLAYER_COUNT, " +
            "NVL((SELECT COUNT(1) FROM MATCH_SCHEDULE m WHERE m.LEAGUE = c.LEAGUE), 0) AS MATCH_COUNT, " +
            "NVL((SELECT COUNT(1) FROM MATCH_EVENT me WHERE me.EVENT_TYPE IN ('GOAL','PENALTY') " +
            "AND me.CLUB_ID IN (SELECT c2.CLUB_ID FROM CLUB c2 WHERE c2.LEAGUE = c.LEAGUE)), 0) AS GOAL_COUNT " +
            "FROM CLUB c LEFT JOIN PLAYER p ON c.CLUB_ID = p.CLUB_ID " +
            "GROUP BY c.LEAGUE ORDER BY c.LEAGUE");
        for (Map<String, Object> row : leagueRows) {
            AnalyticsStats.LeagueStats ls = new AnalyticsStats.LeagueStats();
            ls.setLeague((String) row.get("LEAGUE"));
            ls.setClubCount(((Number) row.get("CLUB_COUNT")).intValue());
            ls.setPlayerCount(((Number) row.get("PLAYER_COUNT")).intValue());
            ls.setMatchCount(((Number) row.get("MATCH_COUNT")).intValue());
            ls.setTotalGoals(((Number) row.get("GOAL_COUNT")).intValue());
            leagueStatsList.add(ls);
        }
        stats.setLeagueStats(leagueStatsList);

        List<AnalyticsStats.PositionDist> posList = new ArrayList<>();
        List<Map<String, Object>> posRows = jdbcTemplate.queryForList(
            "SELECT POSITION, COUNT(1) AS CNT FROM PLAYER WHERE STATUS = 'ACTIVE' GROUP BY POSITION ORDER BY POSITION");
        for (Map<String, Object> row : posRows) {
            AnalyticsStats.PositionDist pd = new AnalyticsStats.PositionDist();
            pd.setPosition((String) row.get("POSITION"));
            pd.setCount(((Number) row.get("CNT")).intValue());
            posList.add(pd);
        }
        stats.setPositionDist(posList);

        List<AnalyticsStats.MonthlyMatch> monthlyList = new ArrayList<>();
        List<Map<String, Object>> monthRows = jdbcTemplate.queryForList(
            "SELECT TO_CHAR(MATCH_TIME, 'YYYY-MM') AS MONTH, COUNT(1) AS MATCH_COUNT, " +
            "NVL(SUM(NVL(HOME_SCORE,0) + NVL(AWAY_SCORE,0)), 0) AS GOAL_COUNT " +
            "FROM MATCH_SCHEDULE GROUP BY TO_CHAR(MATCH_TIME, 'YYYY-MM') " +
            "ORDER BY MONTH DESC");
        int limit = Math.min(monthRows.size(), 12);
        for (int i = 0; i < limit; i++) {
            Map<String, Object> row = monthRows.get(i);
            AnalyticsStats.MonthlyMatch mm = new AnalyticsStats.MonthlyMatch();
            mm.setMonth((String) row.get("MONTH"));
            mm.setMatchCount(((Number) row.get("MATCH_COUNT")).intValue());
            mm.setGoalCount(((Number) row.get("GOAL_COUNT")).intValue());
            monthlyList.add(mm);
        }
        stats.setMonthlyMatches(monthlyList);

        return stats;
    }

    public byte[] exportExcel(String type) throws IOException {
        try (XSSFWorkbook workbook = new XSSFWorkbook(); ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            switch (type) {
                case "clubs" -> writeClubsSheet(workbook);
                case "players" -> writePlayersSheet(workbook);
                case "matches" -> writeMatchesSheet(workbook);
                case "standings" -> writeStandingsSheet(workbook);
                case "playerStats" -> writePlayerStatsSheet(workbook);
                default -> throw new RuntimeException("Unknown export type: " + type);
            }
            workbook.write(out);
            return out.toByteArray();
        }
    }

    public byte[] exportCsv(String type) throws IOException {
        StringWriter sw = new StringWriter();
        try (CSVWriter writer = new CSVWriter(sw)) {
            switch (type) {
                case "clubs" -> writeClubsCsv(writer);
                case "players" -> writePlayersCsv(writer);
                case "matches" -> writeMatchesCsv(writer);
                case "standings" -> writeStandingsCsv(writer);
                case "playerStats" -> writePlayerStatsCsv(writer);
                default -> throw new RuntimeException("Unknown export type: " + type);
            }
        }
        return sw.toString().getBytes("UTF-8");
    }

    private void writeClubsSheet(XSSFWorkbook wb) {
        Sheet sheet = wb.createSheet("Clubs");
        String[] headers = {"ID", "名称", "简称", "联赛", "城市", "国家", "主场", "容量", "成立日期"};
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) headerRow.createCell(i).setCellValue(headers[i]);

        List<Club> clubs = clubMapper.selectList(null);
        int rowIdx = 1;
        for (Club c : clubs) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(c.getClubId());
            row.createCell(1).setCellValue(c.getName());
            row.createCell(2).setCellValue(c.getShortName() != null ? c.getShortName() : "");
            row.createCell(3).setCellValue(c.getLeague());
            row.createCell(4).setCellValue(c.getCity() != null ? c.getCity() : "");
            row.createCell(5).setCellValue(c.getCountry() != null ? c.getCountry() : "");
            row.createCell(6).setCellValue(c.getStadium() != null ? c.getStadium() : "");
            row.createCell(7).setCellValue(c.getStadiumCapacity() != null ? c.getStadiumCapacity() : 0);
            row.createCell(8).setCellValue(c.getEstablishDate() != null ? c.getEstablishDate().toString() : "");
        }
        autoSizeColumns(sheet, headers.length);
    }

    private void writePlayersSheet(XSSFWorkbook wb) {
        Sheet sheet = wb.createSheet("Players");
        String[] headers = {"ID", "英文名", "中文名", "位置", "俱乐部ID", "号码", "国籍", "身高cm", "体重kg", "状态", "身价", "评分"};
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) headerRow.createCell(i).setCellValue(headers[i]);

        List<Player> players = playerMapper.selectList(null);
        int rowIdx = 1;
        for (Player p : players) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(p.getPlayerId());
            row.createCell(1).setCellValue(p.getName());
            row.createCell(2).setCellValue(p.getNameCn() != null ? p.getNameCn() : "");
            row.createCell(3).setCellValue(p.getPosition() != null ? p.getPosition() : "");
            row.createCell(4).setCellValue(p.getClubId() != null ? p.getClubId() : 0);
            row.createCell(5).setCellValue(p.getJerseyNumber() != null ? p.getJerseyNumber() : 0);
            row.createCell(6).setCellValue(p.getNationality() != null ? p.getNationality() : "");
            row.createCell(7).setCellValue(p.getHeightCm() != null ? p.getHeightCm() : 0);
            row.createCell(8).setCellValue(p.getWeightKg() != null ? p.getWeightKg() : 0);
            row.createCell(9).setCellValue(p.getStatus() != null ? p.getStatus() : "");
            row.createCell(10).setCellValue(p.getMarketValue() != null ? p.getMarketValue() : 0);
            row.createCell(11).setCellValue(p.getAvgScore() != null ? p.getAvgScore().doubleValue() : 0);
        }
        autoSizeColumns(sheet, headers.length);
    }

    private void writeMatchesSheet(XSSFWorkbook wb) {
        Sheet sheet = wb.createSheet("Matches");
        String[] headers = {"比赛ID", "联赛", "赛季", "主队ID", "客队ID", "主队得分", "客队得分", "状态", "比赛时间"};
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) headerRow.createCell(i).setCellValue(headers[i]);

        List<MatchSchedule> matches = matchMapper.selectList(null);
        int rowIdx = 1;
        for (MatchSchedule m : matches) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(m.getMatchId());
            row.createCell(1).setCellValue(m.getLeague() != null ? m.getLeague() : "");
            row.createCell(2).setCellValue(m.getSeason() != null ? m.getSeason() : "");
            row.createCell(3).setCellValue(m.getHomeClubId());
            row.createCell(4).setCellValue(m.getAwayClubId());
            row.createCell(5).setCellValue(m.getHomeScore() != null ? m.getHomeScore() : 0);
            row.createCell(6).setCellValue(m.getAwayScore() != null ? m.getAwayScore() : 0);
            row.createCell(7).setCellValue(m.getStatus() != null ? m.getStatus() : "");
            row.createCell(8).setCellValue(m.getMatchTime() != null ? m.getMatchTime().toString() : "");
        }
        autoSizeColumns(sheet, headers.length);
    }

    private void writeStandingsSheet(XSSFWorkbook wb) {
        Sheet sheet = wb.createSheet("Standings");
        String[] headers = {"联赛", "赛季", "俱乐部ID", "排名", "场次", "胜", "平", "负", "进球", "失球", "净胜球", "积分"};
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) headerRow.createCell(i).setCellValue(headers[i]);

        List<LeagueStanding> standings = standingMapper.selectList(null);
        int rowIdx = 1;
        for (LeagueStanding s : standings) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(s.getLeague());
            row.createCell(1).setCellValue(s.getSeason());
            row.createCell(2).setCellValue(s.getClubId());
            row.createCell(3).setCellValue(s.getPosition() != null ? s.getPosition() : 0);
            row.createCell(4).setCellValue(s.getPlayed());
            row.createCell(5).setCellValue(s.getWon());
            row.createCell(6).setCellValue(s.getDrawn());
            row.createCell(7).setCellValue(s.getLost());
            row.createCell(8).setCellValue(s.getGoalsFor());
            row.createCell(9).setCellValue(s.getGoalsAgainst());
            row.createCell(10).setCellValue(s.getGoalDiff());
            row.createCell(11).setCellValue(s.getPoints());
        }
        autoSizeColumns(sheet, headers.length);
    }

    private void writePlayerStatsSheet(XSSFWorkbook wb) {
        Sheet sheet = wb.createSheet("PlayerStats");
        String[] headers = {"球员ID", "赛季", "联赛", "俱乐部ID", "进球", "助攻", "黄牌", "红牌", "出场", "上场分钟"};
        Row headerRow = sheet.createRow(0);
        for (int i = 0; i < headers.length; i++) headerRow.createCell(i).setCellValue(headers[i]);

        List<PlayerSeasonStats> stats = playerSeasonStatsMapper.selectList(null);
        int rowIdx = 1;
        for (PlayerSeasonStats s : stats) {
            Row row = sheet.createRow(rowIdx++);
            row.createCell(0).setCellValue(s.getPlayerId());
            row.createCell(1).setCellValue(s.getSeason());
            row.createCell(2).setCellValue(s.getLeague());
            row.createCell(3).setCellValue(s.getClubId());
            row.createCell(4).setCellValue(s.getGoals());
            row.createCell(5).setCellValue(s.getAssists());
            row.createCell(6).setCellValue(s.getYellowCards());
            row.createCell(7).setCellValue(s.getRedCards());
            row.createCell(8).setCellValue(s.getAppearances());
            row.createCell(9).setCellValue(s.getMinutesPlayed());
        }
        autoSizeColumns(sheet, headers.length);
    }

    private void writeClubsCsv(CSVWriter writer) {
        writer.writeNext(new String[]{"ID", "名称", "简称", "联赛", "城市", "国家", "主场", "容量", "成立日期"});
        for (Club c : clubMapper.selectList(null)) {
            writer.writeNext(new String[]{
                String.valueOf(c.getClubId()), c.getName(),
                c.getShortName() != null ? c.getShortName() : "",
                c.getLeague(), c.getCity() != null ? c.getCity() : "",
                c.getCountry() != null ? c.getCountry() : "",
                c.getStadium() != null ? c.getStadium() : "",
                c.getStadiumCapacity() != null ? String.valueOf(c.getStadiumCapacity()) : "0",
                c.getEstablishDate() != null ? c.getEstablishDate().toString() : ""
            });
        }
    }

    private void writePlayersCsv(CSVWriter writer) {
        writer.writeNext(new String[]{"ID", "英文名", "中文名", "位置", "俱乐部ID", "号码", "国籍", "身高cm", "体重kg", "状态", "身价", "评分"});
        for (Player p : playerMapper.selectList(null)) {
            writer.writeNext(new String[]{
                String.valueOf(p.getPlayerId()), p.getName(),
                p.getNameCn() != null ? p.getNameCn() : "",
                p.getPosition() != null ? p.getPosition() : "",
                p.getClubId() != null ? String.valueOf(p.getClubId()) : "",
                p.getJerseyNumber() != null ? String.valueOf(p.getJerseyNumber()) : "",
                p.getNationality() != null ? p.getNationality() : "",
                p.getHeightCm() != null ? String.valueOf(p.getHeightCm()) : "",
                p.getWeightKg() != null ? String.valueOf(p.getWeightKg()) : "",
                p.getStatus() != null ? p.getStatus() : "",
                p.getMarketValue() != null ? String.valueOf(p.getMarketValue()) : "",
                p.getAvgScore() != null ? String.valueOf(p.getAvgScore()) : ""
            });
        }
    }

    private void writeMatchesCsv(CSVWriter writer) {
        writer.writeNext(new String[]{"比赛ID", "联赛", "赛季", "主队ID", "客队ID", "主队得分", "客队得分", "状态", "比赛时间"});
        for (MatchSchedule m : matchMapper.selectList(null)) {
            writer.writeNext(new String[]{
                m.getMatchId(), m.getLeague() != null ? m.getLeague() : "",
                m.getSeason() != null ? m.getSeason() : "",
                String.valueOf(m.getHomeClubId()), String.valueOf(m.getAwayClubId()),
                m.getHomeScore() != null ? String.valueOf(m.getHomeScore()) : "",
                m.getAwayScore() != null ? String.valueOf(m.getAwayScore()) : "",
                m.getStatus() != null ? m.getStatus() : "",
                m.getMatchTime() != null ? m.getMatchTime().toString() : ""
            });
        }
    }

    private void writeStandingsCsv(CSVWriter writer) {
        writer.writeNext(new String[]{"联赛", "赛季", "俱乐部ID", "排名", "场次", "胜", "平", "负", "进球", "失球", "净胜球", "积分"});
        for (LeagueStanding s : standingMapper.selectList(null)) {
            writer.writeNext(new String[]{
                s.getLeague(), s.getSeason(), String.valueOf(s.getClubId()),
                s.getPosition() != null ? String.valueOf(s.getPosition()) : "",
                String.valueOf(s.getPlayed()), String.valueOf(s.getWon()),
                String.valueOf(s.getDrawn()), String.valueOf(s.getLost()),
                String.valueOf(s.getGoalsFor()), String.valueOf(s.getGoalsAgainst()),
                String.valueOf(s.getGoalDiff()), String.valueOf(s.getPoints())
            });
        }
    }

    private void writePlayerStatsCsv(CSVWriter writer) {
        writer.writeNext(new String[]{"球员ID", "赛季", "联赛", "俱乐部ID", "进球", "助攻", "黄牌", "红牌", "出场", "上场分钟"});
        for (PlayerSeasonStats s : playerSeasonStatsMapper.selectList(null)) {
            writer.writeNext(new String[]{
                String.valueOf(s.getPlayerId()), s.getSeason(), s.getLeague(),
                String.valueOf(s.getClubId()), String.valueOf(s.getGoals()),
                String.valueOf(s.getAssists()), String.valueOf(s.getYellowCards()),
                String.valueOf(s.getRedCards()), String.valueOf(s.getAppearances()),
                String.valueOf(s.getMinutesPlayed())
            });
        }
    }

    @Transactional
    public int importPlayersFromExcel(byte[] data) throws IOException {
        try (XSSFWorkbook wb = new XSSFWorkbook(new java.io.ByteArrayInputStream(data))) {
            Sheet sheet = wb.getSheetAt(0);
            int count = 0;
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                Player player = new Player();
                player.setName(getCellString(row, 0));
                player.setNameCn(getCellString(row, 1));
                player.setPosition(getCellString(row, 2));
                String clubIdStr = getCellString(row, 3);
                if (!clubIdStr.isEmpty()) player.setClubId(Long.valueOf(clubIdStr));
                String jerseyStr = getCellString(row, 4);
                if (!jerseyStr.isEmpty()) player.setJerseyNumber(Integer.valueOf(jerseyStr));
                player.setNationality(getCellString(row, 5));
                String heightStr = getCellString(row, 6);
                if (!heightStr.isEmpty()) player.setHeightCm(Integer.valueOf(heightStr));
                String weightStr = getCellString(row, 7);
                if (!weightStr.isEmpty()) player.setWeightKg(Integer.valueOf(weightStr));
                player.setStatus(getCellString(row, 8));
                if (player.getStatus() == null || player.getStatus().isEmpty()) player.setStatus("ACTIVE");
                player.setAvgScore(java.math.BigDecimal.ZERO);
                player.setTotalRatings(0);
                player.setCreatedAt(LocalDateTime.now());
                playerMapper.insert(player);
                count++;
            }
            return count;
        }
    }

    @Transactional
    public int importMatchesFromExcel(byte[] data) throws IOException {
        try (XSSFWorkbook wb = new XSSFWorkbook(new java.io.ByteArrayInputStream(data))) {
            Sheet sheet = wb.getSheetAt(0);
            int count = 0;
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;
                MatchSchedule match = new MatchSchedule();
                match.setLeague(getCellString(row, 0));
                match.setSeason(getCellString(row, 1));
                String homeIdStr = getCellString(row, 2);
                if (!homeIdStr.isEmpty()) match.setHomeClubId(Long.valueOf(homeIdStr));
                String awayIdStr = getCellString(row, 3);
                if (!awayIdStr.isEmpty()) match.setAwayClubId(Long.valueOf(awayIdStr));
                match.setStatus(getCellString(row, 4));
                if (match.getStatus() == null || match.getStatus().isEmpty()) match.setStatus("PENDING");
                matchMapper.insert(match);
                count++;
            }
            return count;
        }
    }

    private String getCellString(Row row, int idx) {
        Cell cell = row.getCell(idx);
        if (cell == null) return "";
        return switch (cell.getCellType()) {
            case STRING -> cell.getStringCellValue().trim();
            case NUMERIC -> {
                double v = cell.getNumericCellValue();
                if (v == Math.floor(v)) yield String.valueOf((long) v);
                yield String.valueOf(v);
            }
            case BOOLEAN -> String.valueOf(cell.getBooleanCellValue());
            default -> "";
        };
    }

    private void autoSizeColumns(Sheet sheet, int colCount) {
        for (int i = 0; i < colCount; i++) {
            sheet.autoSizeColumn(i);
        }
    }
}
