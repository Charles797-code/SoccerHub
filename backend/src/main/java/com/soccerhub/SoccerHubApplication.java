package com.soccerhub;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@MapperScan("com.soccerhub.mapper")
@EnableScheduling
@EnableAsync
public class SoccerHubApplication {
    public static void main(String[] args) {
        SpringApplication.run(SoccerHubApplication.class, args);
    }
}
