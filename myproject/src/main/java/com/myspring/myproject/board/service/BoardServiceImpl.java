package com.myspring.myproject.board.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.myspring.myproject.board.dao.BoardDAO;
import com.myspring.myproject.board.vo.ArticleVO;

@Service
public class BoardServiceImpl implements BoardService {

    @Autowired
    private BoardDAO boardDAO;

    @Override
    public List<ArticleVO> listArticles(Map<String, Object> params) throws Exception {
        // null 방어
        if (params == null) params = new HashMap<String, Object>();
        return boardDAO.selectAllArticles(params);
    }


    @Override
    public int addNewArticle(Map<String, Object> articleMap) throws Exception {
        return boardDAO.insertNewArticle(articleMap); // 생성된 articleNO 반환
    }

    @Override
    public ArticleVO viewArticle(int articleNO) {
        try {
            return boardDAO.selectArticle(articleNO);
        } catch (Exception e) {
            throw new RuntimeException("viewArticle 실패", e);
        }
    }

    @Override
    public void modArticle(Map<String, Object> articleMap) {
        try {
            boardDAO.updateArticle(articleMap);
        } catch (Exception e) {
            throw new RuntimeException("modArticle 실패", e);
        }
    }

    @Override
    public void removeArticle(int articleNO) {
        try {
            boardDAO.deleteArticle(articleNO);
        } catch (Exception e) {
            throw new RuntimeException("removeArticle 실패", e);
        }
    }
}
