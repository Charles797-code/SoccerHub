package com.soccerhub.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;

@Component
@Slf4j
public class RedisCacheWrapper {

    private final RedisTemplate<String, Object> redisTemplate;
    private volatile boolean available = true;

    public RedisCacheWrapper(RedisTemplate<String, Object> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    public void delete(String key) {
        if (!available) return;
        try {
            redisTemplate.delete(key);
        } catch (Exception e) {
            log.warn("Redis unavailable, skipping delete for key: {}", key);
            available = false;
        }
    }

    public void deleteWithFallback(String key) {
        delete(key);
    }

    public void deleteMultiple(java.util.Collection<String> keys) {
        if (!available) return;
        try {
            redisTemplate.delete(keys);
        } catch (Exception e) {
            log.warn("Redis unavailable, skipping delete for keys");
            available = false;
        }
    }
}
