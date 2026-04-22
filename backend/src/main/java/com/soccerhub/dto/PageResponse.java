package com.soccerhub.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PageResponse<T> {
    private Long total;
    private Long page;
    private Long pageSize;
    private Long totalPages;
    private java.util.List<T> records;
    
    public static <T> PageResponse<T> of(java.util.List<T> records, Long total, Long page, Long pageSize) {
        long totalPages = (total + pageSize - 1) / pageSize;
        return new PageResponse<>(total, page, pageSize, totalPages, records);
    }
}
