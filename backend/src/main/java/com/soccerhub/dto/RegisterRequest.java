package com.soccerhub.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank(message = "Username cannot be blank")
    @Size(min = 3, max = 50, message = "Username must be 3-50 characters")
    private String username;
    
    @NotBlank(message = "Password cannot be blank")
    @Size(min = 6, max = 100, message = "Password must be at least 6 characters")
    private String password;
    
    @NotBlank(message = "Nickname cannot be blank")
    @Size(max = 100, message = "Nickname cannot exceed 100 characters")
    private String nickname;
    
    @Email(message = "Invalid email format")
    private String email;
}
