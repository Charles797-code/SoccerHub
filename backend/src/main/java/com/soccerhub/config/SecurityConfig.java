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
                .requestMatchers("/auth/**").permitAll()
                .requestMatchers("/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html").permitAll()
                .requestMatchers("/ws/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/clubs/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/players/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/coaches/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/matches/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/ratings/target/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/follows/*/followers").permitAll()
                .requestMatchers(HttpMethod.GET, "/news/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/standings/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/social/circles").permitAll()
                .requestMatchers(HttpMethod.GET, "/social/circles/**").permitAll()
                .requestMatchers("/social/circles/**").authenticated()
                .requestMatchers(HttpMethod.POST, "/social/posts").authenticated()
                .requestMatchers(HttpMethod.GET, "/social/posts").permitAll()
                .requestMatchers(HttpMethod.GET, "/social/posts/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/social/user/**").permitAll()
                .requestMatchers("/social/favorites").authenticated()
                .requestMatchers(HttpMethod.GET, "/social/followers/**").permitAll()
                .requestMatchers(HttpMethod.GET, "/social/following/**").permitAll()
                .requestMatchers(HttpMethod.POST, "/social/follow/*").authenticated()
                .requestMatchers("/social/admin/**").hasRole("SUPER_ADMIN")
                .requestMatchers("/uploads/**").permitAll()
                .requestMatchers("/ai/**").authenticated()
                .requestMatchers("/admin/**").hasRole("SUPER_ADMIN")
                .requestMatchers("/club-admin/**").hasAnyRole("CLUB_ADMIN", "SUPER_ADMIN")
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
