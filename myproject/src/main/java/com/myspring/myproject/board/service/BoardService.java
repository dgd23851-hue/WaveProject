package com.myspring.myproject.board.service;

import java.util.List;
import java.util.Map;

import com.myspring.myproject.board.dto.CommentDTO;
import com.myspring.myproject.board.vo.ArticleVO;

public interface BoardService {
	List<CommentDTO> listCommentsWithReplies(int articleNO);
    List<ArticleVO> listArticles(Map<String, Object> params);
    int addNewArticle(Map<String, Object> articleMap);
    ArticleVO viewArticle(int articleNO);
    void modArticle(Map<String, Object> articleMap);
    void removeArticle(int articleNO);
}
