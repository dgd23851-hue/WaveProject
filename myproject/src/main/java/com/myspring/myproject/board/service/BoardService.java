package com.myspring.myproject.board.service;

import java.util.List;
import java.util.Map;

import com.myspring.myproject.board.vo.ArticleVO;

public interface BoardService {
    List<ArticleVO> listArticles(Map<String, Object> params) throws Exception;
    List<CommentDTO> listCommentsWithReplies(int articleNO);
    int addNewArticle(Map<String, Object> articleMap) throws Exception;
    ArticleVO viewArticle(int articleNO) throws Exception;
    void modArticle(Map<String, Object> articleMap) throws Exception;
    void removeArticle(int articleNO) throws Exception;
}