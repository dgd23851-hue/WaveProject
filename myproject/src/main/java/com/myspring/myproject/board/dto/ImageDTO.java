package com.myspring.myproject.board.dto;

public class ImageDTO {
    private String url;           // 접근 URL (예: /files/comments/2025/09/uuid.jpg)
    private String originalName;  // 업로드 당시 파일명

    public ImageDTO() {}

    public ImageDTO(String url, String originalName) {
        this.url = url;
        this.originalName = originalName;
    }

    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }

    public String getOriginalName() { return originalName; }
    public void setOriginalName(String originalName) { this.originalName = originalName; }
}
