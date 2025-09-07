package com.myspring.myproject.board.dao;

import java.util.List;
import java.util.Map;

import com.myspring.myproject.board.vo.ArticleVO;


public interface BoardDAO {
    List<ArticleVO> selectAllArticles(Map<String, Object> params) throws Exception;
    int insertNewArticle(Map<String, Object> articleMap);
    ArticleVO selectArticle(int articleNO);
    void updateArticle(Map<String, Object> articleMap);
    void deleteArticle(int articleNO);
}