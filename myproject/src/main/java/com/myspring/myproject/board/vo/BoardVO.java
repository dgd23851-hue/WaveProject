package com.myspring.myproject.board.vo;

import java.sql.Date;
import org.apache.ibatis.type.Alias;

@Alias("BoardVO") // 선택: alias 쓰고 싶으면
public class BoardVO {
	private Integer articleNO;
	private String title;
	private String content;
	private String imageFileName;
	private String id;
	private Integer parentNO;
	private Date writeDate;
	private String cat;
	private String sub;

	// getter/setter 전부
	public Integer getArticleNO() {
		return articleNO;
	}

	public void setArticleNO(Integer articleNO) {
		this.articleNO = articleNO;
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

	public Integer getParentNO() {
		return parentNO;
	}

	public void setParentNO(Integer parentNO) {
		this.parentNO = parentNO;
	}

	public Date getWriteDate() {
		return writeDate;
	}

	public void setWriteDate(Date writeDate) {
		this.writeDate = writeDate;
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
}