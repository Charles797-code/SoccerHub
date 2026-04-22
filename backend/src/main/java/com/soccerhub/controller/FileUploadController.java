package com.soccerhub.controller;

import com.soccerhub.dto.ApiResponse;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/upload")
@RequiredArgsConstructor
@Tag(name = "Upload", description = "File upload endpoints")
public class FileUploadController {

    @Value("${upload.path:uploads}")
    private String uploadPath;

    @PostMapping("/image")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'CLUB_ADMIN')")
    @Operation(summary = "Upload image file")
    public ResponseEntity<ApiResponse<String>> uploadImage(
            @RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("File is empty"));
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Only image files are allowed"));
        }

        try {
            String originalFilename = file.getOriginalFilename();
            String extension = "";
            if (originalFilename != null && originalFilename.contains(".")) {
                extension = originalFilename.substring(originalFilename.lastIndexOf("."));
            }

            String datePath = LocalDate.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
            String newFilename = UUID.randomUUID().toString() + extension;

            Path uploadDir = Paths.get(uploadPath, datePath);
            if (!Files.exists(uploadDir)) {
                Files.createDirectories(uploadDir);
            }

            Path filePath = uploadDir.resolve(newFilename);
            Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

            String fileUrl = "/uploads/" + datePath + "/" + newFilename;

            return ResponseEntity.ok(ApiResponse.success("Image uploaded", fileUrl));
        } catch (IOException e) {
            log.error("Failed to upload image", e);
            return ResponseEntity.internalServerError().body(ApiResponse.error("Failed to upload image: " + e.getMessage()));
        }
    }

    @DeleteMapping("/image")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'CLUB_ADMIN')")
    @Operation(summary = "Delete image file")
    public ResponseEntity<ApiResponse<Void>> deleteImage(@RequestParam("path") String path) {
        try {
            if (path.startsWith("/uploads/")) {
                path = path.substring("/uploads/".length());
            }

            Path filePath = Paths.get(uploadPath, path);
            if (Files.exists(filePath)) {
                Files.delete(filePath);
            }

            return ResponseEntity.ok(ApiResponse.success("Image deleted", null));
        } catch (IOException e) {
            log.error("Failed to delete image", e);
            return ResponseEntity.internalServerError().body(ApiResponse.error("Failed to delete image"));
        }
    }
}
