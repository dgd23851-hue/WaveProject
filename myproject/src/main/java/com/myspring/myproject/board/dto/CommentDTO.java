package com.myspring.myproject.board.dto;

public class CommentDTO {
	private Integer articleNo; // ★
	private Long parentId;
	private String writer;
	private String content;
	private java.util.Date createdAt;
	private java.util.Date updatedAt;
	private Long id;
	private String authorName;
	private String memberId;

	public String getMemberId() {
		return memberId;
	}

	public void setMemberId(String memberId) {
		this.memberId = memberId;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getArticleNo() {
		return articleNo;
	}

	public void setArticleNo(long articleNo) {
		this.articleNo = (int) articleNo;
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

	// 안전한 게터/세터 추가
	public String getAuthorName() {
		return (authorName != null) ? authorName : writer;
	}

	public void setAuthorName(String authorName) {
		this.authorName = authorName;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public java.util.Date getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(java.util.Date createdAt) {
		this.createdAt = createdAt;
	}

	public java.util.Date getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(java.util.Date updatedAt) {
		this.updatedAt = updatedAt;
	}
	// import java.util.List; import java.util.ArrayList; 필요

	private java.util.List<CommentDTO> replies;

	public java.util.List<CommentDTO> getReplies() {
		if (replies == null) {
			replies = new java.util.ArrayList<>();
		}
		return replies;
	}

	public void setReplies(java.util.List<CommentDTO> replies) {
		this.replies = replies;
	}

}
