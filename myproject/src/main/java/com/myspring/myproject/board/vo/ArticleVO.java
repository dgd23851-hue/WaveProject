package com.myspring.myproject.board.vo;

import java.util.Date;

public class ArticleVO {
	private Integer articleNO;
	private Integer parentNO;
	private String title;
	private String content;
	private Date writeDate;
	private String imageFileName;

	// 작성자/카테고리
	private String id; // t_board.id (로그인ID 문자열)
	private String cat;
	private String sub;

	// JOIN으로 채우는 표시용 필드
	private String writerId; // = a.id
	private String writerName; // = m.name (없으면 a.id)

	// --- getters/setters ---
	public Integer getArticleNO() {
		return articleNO;
	}

	public void setArticleNO(Integer articleNO) {
		this.articleNO = articleNO;
	}

	// alias (articleNo 이름도 지원)
	public Integer getArticleNo() {
		return articleNO;
	}

	public void setArticleNo(Integer articleNo) {
		this.articleNO = articleNo;
	}

	public Integer getParentNO() {
		return parentNO;
	}

	public void setParentNO(Integer parentNO) {
		this.parentNO = parentNO;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
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

	public String getImageFileName() {
		return imageFileName;
	}

	public void setImageFileName(String imageFileName) {
		this.imageFileName = imageFileName;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getCat() {
		return cat;
	}

	public void setCat(String cat) {
		this.cat = cat;
	}

	public String getSub() {
		return sub;
	}

	public void setSub(String sub) {
		this.sub = sub;
	}

	public String getWriterId() {
		return writerId;
	}

	public void setWriterId(String writerId) {
		this.writerId = writerId;
	}

	public String getWriterName() {
		return writerName;
	}

	public void setWriterName(String writerName) {
		this.writerName = writerName;
	}
}
