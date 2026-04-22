package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.ChatMessageVO;
import com.soccerhub.entity.ClubChatMessage;
import com.soccerhub.entity.Club;
import com.soccerhub.entity.SysUser;
import com.soccerhub.entity.UserClubFollow;
import com.soccerhub.mapper.ClubChatMessageMapper;
import com.soccerhub.mapper.ClubMapper;
import com.soccerhub.mapper.SysUserMapper;
import com.soccerhub.mapper.UserClubFollowMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ClubChatMessageMapper messageMapper;
    private final UserClubFollowMapper followMapper;
    private final SysUserMapper userMapper;
    private final ClubMapper clubMapper;
    private final SimpMessagingTemplate messagingTemplate;

    public Page<ChatMessageVO> getMessages(Long clubId, int page, int pageSize) {
        Page<ClubChatMessage> p = new Page<>(page, pageSize);
        QueryWrapper<ClubChatMessage> wrapper = new QueryWrapper<>();
        wrapper.eq("CLUB_ID", clubId);
        wrapper.eq("IS_DELETED", 0);
        wrapper.orderByDesc("CREATED_AT");
        p = messageMapper.selectPage(p, wrapper);

        List<ChatMessageVO> voList = toVOList(p.getRecords().reversed());

        Page<ChatMessageVO> voPage = new Page<>(p.getCurrent(), p.getSize(), p.getTotal());
        voPage.setRecords(voList);
        return voPage;
    }

    public List<ChatMessageVO> getRecentMessages(Long clubId, int limit) {
        QueryWrapper<ClubChatMessage> wrapper = new QueryWrapper<>();
        wrapper.eq("CLUB_ID", clubId);
        wrapper.eq("IS_DELETED", 0);
        wrapper.orderByDesc("CREATED_AT");
        wrapper.last("FETCH FIRST " + limit + " ROWS ONLY");
        List<ClubChatMessage> messages = messageMapper.selectList(wrapper);
        return toVOList(messages.reversed());
    }

    @Transactional
    public ChatMessageVO sendMessage(Long clubId, Long userId, String content, String messageType) {
        QueryWrapper<UserClubFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId);
        wrapper.eq("CLUB_ID", clubId);
        if (followMapper.selectCount(wrapper) == 0) {
            throw new RuntimeException("必须先关注该俱乐部才能发言！");
        }

        ClubChatMessage message = new ClubChatMessage();
        message.setClubId(clubId);
        message.setUserId(userId);
        message.setContent(content);
        message.setMessageType(messageType != null ? messageType : "TEXT");
        message.setIsDeleted(0);
        message.setCreatedAt(LocalDateTime.now());
        messageMapper.insert(message);

        ChatMessageVO vo = toVO(message);

        Map<String, Object> broadcastMsg = new LinkedHashMap<>();
        broadcastMsg.put("messageId", message.getMessageId());
        broadcastMsg.put("clubId", message.getClubId());
        broadcastMsg.put("userId", message.getUserId());
        broadcastMsg.put("username", vo.getUsername());
        broadcastMsg.put("nickname", vo.getNickname());
        broadcastMsg.put("fanClub", vo.getFanClub());
        broadcastMsg.put("content", message.getContent());
        broadcastMsg.put("messageType", message.getMessageType());
        broadcastMsg.put("createdAt", message.getCreatedAt());
        messagingTemplate.convertAndSend("/topic/chat/" + clubId, broadcastMsg);

        return vo;
    }

    @Transactional
    public void deleteMessage(Long messageId, Long userId, Long managedClubId, String userRole) {
        ClubChatMessage message = messageMapper.selectById(messageId);
        if (message == null) throw new RuntimeException("Message not found");

        boolean canDelete = "SUPER_ADMIN".equals(userRole) ||
                ("CLUB_ADMIN".equals(userRole) && message.getClubId().equals(managedClubId)) ||
                message.getUserId().equals(userId);

        if (!canDelete) {
            throw new RuntimeException("您没有权限删除此消息！");
        }

        message.setIsDeleted(1);
        message.setDeletedBy(userId);
        message.setDeletedAt(LocalDateTime.now());
        messageMapper.updateById(message);
    }

    private List<ChatMessageVO> toVOList(List<ClubChatMessage> messages) {
        if (messages.isEmpty()) return Collections.emptyList();

        Set<Long> userIds = messages.stream().map(ClubChatMessage::getUserId).collect(Collectors.toSet());
        Map<Long, SysUser> userMap = new LinkedHashMap<>();
        for (Long uid : userIds) {
            SysUser u = userMapper.selectById(uid);
            if (u != null) userMap.put(uid, u);
        }

        Set<Long> allClubIds = new LinkedHashSet<>();
        for (SysUser u : userMap.values()) {
            if (u.getManagedClubId() != null) allClubIds.add(u.getManagedClubId());
        }
        QueryWrapper<UserClubFollow> fw = new QueryWrapper<>();
        fw.in("USER_ID", userIds);
        fw.eq("IS_PRIMARY", 1);
        List<UserClubFollow> primaryFollows = followMapper.selectList(fw);
        for (UserClubFollow f : primaryFollows) allClubIds.add(f.getClubId());

        Map<Long, Club> clubMap = new LinkedHashMap<>();
        if (!allClubIds.isEmpty()) {
            QueryWrapper<Club> cw = new QueryWrapper<>();
            cw.in("CLUB_ID", allClubIds);
            clubMapper.selectList(cw).forEach(c -> clubMap.put(c.getClubId(), c));
        }

        Map<Long, String> userFanClubMap = new LinkedHashMap<>();
        for (UserClubFollow f : primaryFollows) {
            Club c = clubMap.get(f.getClubId());
            if (c != null) userFanClubMap.put(f.getUserId(), c.getShortName() != null ? c.getShortName() : c.getName());
        }

        return messages.stream().map(msg -> {
            ChatMessageVO vo = new ChatMessageVO();
            vo.setMessageId(msg.getMessageId());
            vo.setClubId(msg.getClubId());
            vo.setUserId(msg.getUserId());
            vo.setContent(msg.getContent());
            vo.setMessageType(msg.getMessageType());
            vo.setCreatedAt(msg.getCreatedAt());

            SysUser u = userMap.get(msg.getUserId());
            if (u != null) {
                vo.setUsername(u.getUsername());
                vo.setNickname(u.getNickname());
            }

            String fanClub = userFanClubMap.get(msg.getUserId());
            if (fanClub == null && u != null && u.getManagedClubId() != null) {
                Club mc = clubMap.get(u.getManagedClubId());
                if (mc != null) fanClub = mc.getShortName() != null ? mc.getShortName() : mc.getName();
            }
            vo.setFanClub(fanClub);

            return vo;
        }).collect(Collectors.toList());
    }

    private ChatMessageVO toVO(ClubChatMessage message) {
        List<ChatMessageVO> list = toVOList(List.of(message));
        return list.isEmpty() ? new ChatMessageVO() : list.get(0);
    }
}
