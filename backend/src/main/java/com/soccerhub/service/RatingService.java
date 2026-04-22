package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.entity.RatingRecord;
import com.soccerhub.entity.SysUser;
import com.soccerhub.entity.UserClubFollow;
import com.soccerhub.mapper.RatingRecordMapper;
import com.soccerhub.mapper.SysUserMapper;
import com.soccerhub.mapper.UserClubFollowMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class RatingService {

    private final RatingRecordMapper ratingMapper;
    private final UserClubFollowMapper followMapper;
    private final SysUserMapper userMapper;
    private final JdbcTemplate jdbcTemplate;

    @Transactional
    public Map<String, Object> submitRating(Long userId, Long targetId, String targetType,
                                             Integer score, String comment, Long clubId,
                                             String ratingType, String matchId) {
        Map<String, Object> result = new HashMap<>();
        
        SysUser user = userMapper.selectById(userId);
        
        // Check follow relationship for non-SUPER_ADMIN
        if (!"SUPER_ADMIN".equals(user.getRole())) {
            QueryWrapper<UserClubFollow> followWrapper = new QueryWrapper<>();
            followWrapper.eq("USER_ID", userId);
            followWrapper.eq("CLUB_ID", clubId);
            if (followMapper.selectCount(followWrapper) == 0) {
                result.put("success", false);
                result.put("message", "必须先关注该俱乐部才能评分！");
                return result;
            }
        }

        // Call Oracle stored procedure
        try {
            String procCall = """
                BEGIN
                    osp_Submit_User_Rating(
                        p_User_ID => ?,
                        p_Target_ID => ?,
                        p_Target_Type => ?,
                        p_Score => ?,
                        p_Comment => ?,
                        p_Club_ID => ?,
                        p_Rating_Type => ?,
                        p_Match_ID => ?,
                        p_Result => ?,
                        p_Record_ID => ?
                    );
                END;
                """;
            
            Map<String, Object> procResult = jdbcTemplate.call(conn -> {
                var cs = conn.prepareCall(procCall);
                cs.setLong(1, userId);
                cs.setLong(2, targetId);
                cs.setString(3, targetType);
                cs.setInt(4, score);
                cs.setString(5, comment);
                cs.setLong(6, clubId);
                cs.setString(7, ratingType != null ? ratingType : "GENERAL");
                cs.setString(8, matchId);
                cs.registerOutParameter(9, oracle.jdbc.OracleTypes.VARCHAR);
                cs.registerOutParameter(10, oracle.jdbc.OracleTypes.NUMBER);
                return cs;
            }, List.of(new org.springframework.jdbc.core.SqlParameter("result", oracle.jdbc.OracleTypes.VARCHAR)));

            String procMessage = (String) procResult.get("p_Result");
            Number recordIdNum = (Number) procResult.get("p_Record_ID");

            if (procMessage != null && procMessage.startsWith("SUCCESS")) {
                result.put("success", true);
                result.put("message", procMessage);
                result.put("recordId", recordIdNum != null ? recordIdNum.longValue() : 0);
            } else {
                result.put("success", false);
                result.put("message", procMessage);
            }
        } catch (Exception e) {
            // Fallback to direct insert if SP fails
            RatingRecord record = new RatingRecord();
            record.setUserId(userId);
            record.setTargetId(targetId);
            record.setTargetType(targetType);
            record.setScore(score);
            record.setCommentText(comment);
            record.setRatingType(ratingType != null ? ratingType : "GENERAL");
            record.setMatchId(matchId);
            record.setIsCollapsed(0);
            record.setCreatedAt(LocalDateTime.now());
            ratingMapper.insert(record);
            
            result.put("success", true);
            result.put("message", "评分成功！");
            result.put("recordId", record.getRecordId());
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
