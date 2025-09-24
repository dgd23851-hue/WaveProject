package com.myspring.myproject.board.dto;

import java.io.Serializable;
import java.sql.Timestamp;

/**
 * comments 테이블 DTO
 *
 * - id : BIGINT UNSIGNED (PK, AUTO_INCREMENT) - articleId : INT
 * (t_board.articleNO 참조) - parentId : BIGINT UNSIGNED (대댓글의 부모 댓글 id, nullable)
 * - writer : VARCHAR(50) - content : TEXT - writeDate : DATETIME (DEFAULT
 * CURRENT_TIMESTAMP) - updateDate : DATETIME (DEFAULT CURRENT_TIMESTAMP ON
 * UPDATE CURRENT_TIMESTAMP)
 */
public class CommentDTO implements Serializable {

	private static final long serialVersionUID = 1L;

	/** comments.id */
	private Long id;

	/** t_board.articleNO 를 참조하는 글 번호(INT) */
	private Integer articleId;

	/** 부모 댓글 id (null 가능) */
	private Long parentId;

	/** 작성자 로그인 아이디(세션에서 getId()) */
	private String writer;

	/** 댓글 본문 */
	private String content;

	/** 생성 시각 */
	private Timestamp writeDate;

	/** 수정 시각 */
	private Timestamp updateDate;

	// --- constructors ---
	public CommentDTO() {
	}

	public CommentDTO(Long id, Integer articleId, Long parentId, String writer, String content, Timestamp writeDate,
			Timestamp updateDate) {
		this.id = id;
		this.articleId = articleId;
		this.parentId = parentId;
		this.writer = writer;
		this.content = content;
		this.writeDate = writeDate;
		this.updateDate = updateDate;
	}

	// --- getters/setters ---
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getArticleId() {
		return articleId;
	}

	public void setArticleId(Integer articleId) {
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

	public Timestamp getWriteDate() {
		return writeDate;
	}

	public void setWriteDate(Timestamp writeDate) {
		this.writeDate = writeDate;
	}

	public Timestamp getUpdateDate() {
		return updateDate;
	}

	public void setUpdateDate(Timestamp updateDate) {
		this.updateDate = updateDate;
	}

	// --- convenience ---
	public boolean hasParent() {
		return parentId != null;
	}

	@Override
	public String toString() {
		return "CommentDTO{" + "id=" + id + ", articleId=" + articleId + ", parentId=" + parentId + ", writer='"
				+ writer + '\'' + ", content='"
				+ (content != null ? (content.length() > 20 ? content.substring(0, 20) + "..." : content) : null) + '\''
				+ ", writeDate=" + writeDate + ", updateDate=" + updateDate + '}';
	}
}
