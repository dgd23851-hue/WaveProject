package com.myspring.myproject.board.dto;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * CommentDTO (통합본) - 기존 필드 유지 + depth(대댓글 들여쓰기 레벨) 추가 - int/long 혼용을 막기 위한 오버로드
 * 세터 제공 - NPE 방지를 위한 안전한 게터들 제공
 */
public class CommentDTO {

	/** 댓글 PK */
	private Long id;

	/** 게시글 번호 (t_board.id) */
	private Integer articleNo;

	/** 부모 댓글 PK (루트면 0 또는 null) */
	private Long parentId;

	/** 화면 표시용 작성자 이름(닉네임) */
	private String authorName;

	/** 로그인 아이디(FK: t_member.id) */
	private String memberId;

	/** 백업/호환용: 작성자 문자열(예전 스키마) */
	private String writer;

	/** 내용 */
	private String content;

	/** 생성/수정 시간 */
	private Date createdAt;
	private Date updatedAt;

	/** 자식 댓글(대댓글) */
	private List<CommentDTO> replies;

	/** 본인 여부(삭제/수정 버튼 표시용) */
	private Boolean own;

	/** 들여쓰기 깊이 (0부터 시작) */
	private Integer depth;

	// ---------- 게터/세터 (안전 버전) ----------

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	// articleNo
	public Integer getArticleNo() {
		return articleNo;
	}

	public void setArticleNo(Integer articleNo) {
		this.articleNo = articleNo;
	}

	// 오버로드: int/long도 받기
	public void setArticleNo(int articleNo) {
		this.articleNo = Integer.valueOf(articleNo);
	}

	public void setArticleNo(Long articleNo) {
		this.articleNo = (articleNo == null ? null : articleNo.intValue());
	}

	// parentId
	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	// 오버로드: int/Integer도 받기
	public void setParentId(int parentId) {
		this.parentId = Long.valueOf(parentId);
	}

	public void setParentId(Integer parentId) {
		this.parentId = (parentId == null ? null : parentId.longValue());
	}

	public String getAuthorName() {
		return authorName;
	}

	public void setAuthorName(String authorName) {
		this.authorName = authorName;
	}

	public String getMemberId() {
		return memberId;
	}

	public void setMemberId(String memberId) {
		this.memberId = memberId;
	}

	public String getWriter() {
		return writer;
	}

	public void setWriter(String writer) {
		this.writer = writer;
	}

	public String getContent() {
		return content == null ? "" : content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public Date getCreatedAt() {
		return createdAt;
	}

	public void setCreatedAt(Date createdAt) {
		this.createdAt = createdAt;
	}

	public Date getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(Date updatedAt) {
		this.updatedAt = updatedAt;
	}

	public List<CommentDTO> getReplies() {
		if (replies == null)
			replies = new ArrayList<CommentDTO>();
		return replies;
	}

	public void setReplies(List<CommentDTO> replies) {
		this.replies = replies;
	}

	public void addReply(CommentDTO child) {
		if (this.replies == null)
			this.replies = new ArrayList<CommentDTO>();
		this.replies.add(child);
	}

	public Boolean getOwn() {
		return own == null ? Boolean.FALSE : own;
	}

	public void setOwn(Boolean own) {
		this.own = own;
	}

	/** JSP에서 바로 쓸 수 있도록 null이면 0으로 반환 */
	public int getDepth() {
		return depth == null ? 0 : depth.intValue();
	}

	public void setDepth(Integer depth) {
		this.depth = depth;
	}

	// 편의: depth ++
	public void setDepthFromParent(CommentDTO parent) {
		int d = 0;
		if (parent != null)
			d = parent.getDepth() + 1;
		this.depth = Integer.valueOf(d);
	}

	// 화면 표시용 통합 이름 (authorName > writer > memberId 순)
	public String getDisplayName() {
		if (authorName != null && !authorName.isEmpty())
			return authorName;
		if (writer != null && !writer.isEmpty())
			return writer;
		return memberId;
	}
}
