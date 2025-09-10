package com.myspring.myproject.board.dto;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CommentDTO {

	private Long id;
	private Integer articleNo; // 컨트롤러의 setArticleNo와 맞춤 (또는 articleNO로 모두 통일)
	private Long parentId;
	private String writer;
	private String content;
	private LocalDateTime createdAt;
	private List<CommentDTO> replies = new ArrayList<>();

	public CommentDTO() {
	} // ★ 기본 생성자

	// --- Getter/Setter ---
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getArticleNo() {
		return articleNo;
	}

	public void setArticleNo(Integer articleNo) {
		this.articleNo = articleNo;
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public String getWriter() {
		return writer;
	}

	public void setWriter(String writer) {
		this.writer = writer;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public LocalDateTime getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(LocalDateTime createdAt) {
		this.createdAt = createdAt;
	}

	public List<CommentDTO> getReplies() {
		return replies;
	}

	public void setReplies(List<CommentDTO> replies) {
		this.replies = replies;
	}
}
