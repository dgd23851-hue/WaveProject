package com.myspring.myproject.board.dto;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class CommentDTO {
    private long id;                 // 댓글 PK
    private int articleNo;           // 원글 번호
    private Long parentId;           // 부모 댓글(대댓글용), 최상위면 null
    private String authorName;       // 작성자 표시명
    private String content;          // 내용(서버에서 XSS 필터링 권장)
    private Date createdAt;          // 작성일시
    private boolean own;             // 로그인 사용자 본인 댓글 여부

    private List<ImageDTO> attachments = new ArrayList<>(); // 이미지 첨부
    private List<CommentDTO> replies = new ArrayList<>();    // 대댓글

    public CommentDTO() {}

    // --- getters / setters ---
    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public int getArticleNo() { return articleNo; }
    public void setArticleNo(int articleNo) { this.articleNo = articleNo; }

    public Long getParentId() { return parentId; }
    public void setParentId(Long parentId) { this.parentId = parentId; }

    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }

    public boolean isOwn() { return own; }
    public void setOwn(boolean own) { this.own = own; }

    public List<ImageDTO> getAttachments() { return attachments; }
    public void setAttachments(List<ImageDTO> attachments) { this.attachments = attachments; }

    public List<CommentDTO> getReplies() { return replies; }
    public void setReplies(List<CommentDTO> replies) { this.replies = replies; }
}
