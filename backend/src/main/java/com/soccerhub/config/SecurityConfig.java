package com.soccerhub.config;

import com.soccerhub.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.List;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true)
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final UserDetailsService userDetailsService;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(AbstractHttpConfigurer::disable)
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/auth/login", "/auth/register", "/auth/refresh", "/auth/user/**", "/auth/profile").permitAll()
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/predictions/**").permitAll()
                .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                .requestMatchers("/ws/**").permitAll()
                .requestMatchers("/").permitAll()
                .requestMatchers("/m").permitAll()
                .requestMatchers("/index.html").permitAll()
                .requestMatchers("/error").permitAll()
                .requestMatchers("/assets/**").permitAll()
                .requestMatchers("/vite.svg").permitAll()
                .requestMatchers(HttpMethod.GET, "/clubs/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/clubs/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/clubs/fix-svg").permitAll()
                .requestMatchers(HttpMethod.GET, "/players/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/players/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/coaches/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/coaches/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/matches/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/matches/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/ratings/target/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/ratings/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/follows/*/followers").permitAll()
                .requestMatchers(HttpMethod.GET, "/follows/my-follows").permitAll()
                .requestMatchers("/follows/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/follows/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/news/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/news/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/standings/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/standings/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/social/circles").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/social/circles").permitAll()
                .requestMatchers(HttpMethod.GET, "/social/circles/**").permitAll()
                .requestMatchers("/social/circles/**").authenticated()
                .requestMatchers(HttpMethod.GET, "/social/posts").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/social/posts").permitAll()
                .requestMatchers(HttpMethod.GET, "/social/posts/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/social/posts/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/social/user/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/social/user/**").permitAll()
                .requestMatchers("/social/favorites").authenticated()
                .requestMatchers(HttpMethod.GET, "/social/followers/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/social/followers/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/social/following/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/api/social/following/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/social/follow/*").authenticated()
                .requestMatchers("/social/admin/**").hasRole("SUPER_ADMIN")
                .requestMatchers("/uploads/**").permitAll()
                .requestMatchers("/api/uploads/**").permitAll()
                .requestMatchers("/api/upload/**").permitAll()
                .requestMatchers("/upload/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/api/upload/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/upload/**").permitAll()
                .requestMatchers("/ai/**").authenticated()
                .requestMatchers("/admin/**").hasRole("SUPER_ADMIN")
                .requestMatchers("/club-admin/**").hasAnyRole("CLUB_ADMIN", "SUPER_ADMIN")
                .requestMatchers("/seasons/**").permitAll()
                .requestMatchers("/api/seasons/**").permitAll()
                .requestMatchers("/api/analytics/**").permitAll()
                .anyRequest().authenticated()
            )
            .authenticationProvider(authenticationProvider())
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(List.of("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setExposedHeaders(List.of("Authorization"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
        authProvider.setUserDetailsService(userDetailsService);
        authProvider.setPasswordEncoder(passwordEncoder());
        return authProvider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }
}
