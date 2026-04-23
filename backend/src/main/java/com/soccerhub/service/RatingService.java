package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.entity.RatingRecord;
import com.soccerhub.mapper.RatingRecordMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Types;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRecordMapper ratingMapper;
    private final JdbcTemplate jdbcTemplate;

    @Transactional
    public Map<String, Object> submitRating(Long userId, Long targetId, String targetType,
                                             Integer score, String comment, Long clubId,
                                             String ratingType, String matchId) {
        Map<String, Object> result = new HashMap<>();

        try {
            String sql = "{call osp_Submit_User_Rating(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
            
            Map<String, Object> inParams = new HashMap<>();
            inParams.put("p_User_ID", userId);
            inParams.put("p_Target_ID", targetId);
            inParams.put("p_Target_Type", targetType);
            inParams.put("p_Score", score);
            inParams.put("p_Comment", comment);
            inParams.put("p_Club_ID", clubId);
            inParams.put("p_Rating_Type", ratingType != null ? ratingType : "GENERAL");
            inParams.put("p_Match_ID", matchId);
            
            List<SqlParameter> declaredParams = List.of(
                new SqlParameter("p_User_ID", Types.NUMERIC),
                new SqlParameter("p_Target_ID", Types.NUMERIC),
                new SqlParameter("p_Target_Type", Types.VARCHAR),
                new SqlParameter("p_Score", Types.NUMERIC),
                new SqlParameter("p_Comment", Types.VARCHAR),
                new SqlParameter("p_Club_ID", Types.NUMERIC),
                new SqlParameter("p_Rating_Type", Types.VARCHAR),
                new SqlParameter("p_Match_ID", Types.VARCHAR),
                new SqlOutParameter("p_Result", Types.VARCHAR),
                new SqlOutParameter("p_Record_ID", Types.NUMERIC)
            );
            
            Map<String, Object> outParams = jdbcTemplate.call(conn -> {
                var cs = conn.prepareCall(sql);
                cs.setLong(1, userId);
                cs.setLong(2, targetId);
                cs.setString(3, targetType);
                cs.setInt(4, score);
                cs.setString(5, comment);
                cs.setLong(6, clubId != null ? clubId : 0);
                cs.setString(7, ratingType != null ? ratingType : "GENERAL");
                cs.setString(8, matchId);
                cs.registerOutParameter(9, Types.VARCHAR);
                cs.registerOutParameter(10, Types.NUMERIC);
                return cs;
            }, declaredParams);
            
            String procResult = (String) outParams.get("p_Result");
            Number recordIdNum = (Number) outParams.get("p_Record_ID");
            
            if (procResult != null && procResult.startsWith("SUCCESS")) {
                result.put("success", true);
                result.put("message", procResult);
                result.put("recordId", recordIdNum != null ? recordIdNum.longValue() : 0);
            } else {
                result.put("success", false);
                result.put("message", procResult != null ? procResult : "评分失败");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "评分失败：" + e.getMessage());
        }
        
        return result;
    }

    public Page<RatingRecord> getTargetRatings(String targetType, Long targetId, int page, int pageSize) {
        Page<RatingRecord> p = new Page<>(page, pageSize);
        QueryWrapper<RatingRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("TARGET_TYPE", targetType);
        wrapper.eq("TARGET_ID", targetId);
        wrapper.eq("IS_COLLAPSED", 0);
        wrapper.orderByDesc("CREATED_AT");
        return ratingMapper.selectPage(p, wrapper);
    }

    public Page<RatingRecord> getUserRatings(Long userId, int page, int pageSize) {
        Page<RatingRecord> p = new Page<>(page, pageSize);
        QueryWrapper<RatingRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId);
        wrapper.orderByDesc("CREATED_AT");
        return ratingMapper.selectPage(p, wrapper);
    }

    public BigDecimal getTargetAverageScore(String targetType, Long targetId) {
        QueryWrapper<RatingRecord> wrapper = new QueryWrapper<>();
        wrapper.eq("TARGET_TYPE", targetType);
        wrapper.eq("TARGET_ID", targetId);
        wrapper.eq("IS_COLLAPSED", 0);
        List<RatingRecord> records = ratingMapper.selectList(wrapper);
        if (records.isEmpty()) return BigDecimal.ZERO;
        double avg = records.stream().mapToInt(RatingRecord::getScore).average().orElse(0);
        return BigDecimal.valueOf(avg);
    }

    public void deleteRating(Long recordId, Long userId, String userRole) {
        if ("SUPER_ADMIN".equals(userRole) || "CLUB_ADMIN".equals(userRole)) {
            ratingMapper.deleteById(recordId);
        }
    }
}
