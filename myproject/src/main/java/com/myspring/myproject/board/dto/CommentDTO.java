package com.myspring.myproject.board.dto;

import java.io.Serializable;
import java.util.Date;

/**
 * 댓글 DTO DB 컬럼: id, articleId, parentId, writer, content, writeDate, updateDate
 */
public class CommentDTO implements Serializable {
	private static final long serialVersionUID = 1L;

	private Long id; // PK (comments.id)
	private Long articleId; // FK → article.id
	private Long parentId; // 부모 댓글 id (대댓글 아니면 null)
	private String writer; // 작성자(세션 아이디 등)
	private String content; // 본문
	private Date writeDate; // 생성일시
	private Date updateDate; // 수정일시

	public CommentDTO() {
	}

	public CommentDTO(Long id, Long articleId, Long parentId, String writer, String content, Date writeDate,
			Date updateDate) {
		this.id = id;
		this.articleId = articleId;
		this.parentId = parentId;
		this.writer = writer;
		this.content = content;
		this.writeDate = writeDate;
		this.updateDate = updateDate;
	}

	// 편의 생성자 (insert 시 주로 사용)
	public CommentDTO(Long articleId, Long parentId, String writer, String content) {
		this.articleId = articleId;
		this.parentId = parentId;
		this.writer = writer;
		this.content = content;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getArticleId() {
		return articleId;
	}

	public void setArticleId(Long articleId) {
		this.articleId = articleId;
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

	public Date getWriteDate() {
		return writeDate;
	}

	public void setWriteDate(Date writeDate) {
		this.writeDate = writeDate;
	}

	public Date getUpdateDate() {
		return updateDate;
	}

	public void setUpdateDate(Date updateDate) {
		this.updateDate = updateDate;
	}

	@Override
	public String toString() {
		return "CommentDTO{" + "id=" + id + ", articleId=" + articleId + ", parentId=" + parentId + ", writer='"
				+ writer + '\'' + ", content='"
				+ (content != null ? (content.length() > 20 ? content.substring(0, 20) + "..." : content) : null) + '\''
				+ ", writeDate=" + writeDate + ", updateDate=" + updateDate + '}';
	}

	@Override
	public int hashCode() {
		return (id == null ? 0 : id.hashCode());
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (!(obj instanceof CommentDTO))
			return false;
		CommentDTO other = (CommentDTO) obj;
		if (this.id == null || other.id == null)
			return false;
		return this.id.equals(other.id);
	}
}
