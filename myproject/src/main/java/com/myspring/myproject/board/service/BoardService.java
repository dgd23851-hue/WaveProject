package com.myspring.myproject.board.service;

import java.util.List;
import java.util.Map;
import com.myspring.myproject.board.vo.ArticleVO;

public interface BoardService {
	ArticleVO viewArticle(int articleNO);
	int addNewArticle(Map<String, Object> articleMap);
	void modArticle(Map<String, Object> articleMap);
	void removeArticle(int articleNO);
    List<ArticleVO> listArticles(Map<String, Object> params);
}
