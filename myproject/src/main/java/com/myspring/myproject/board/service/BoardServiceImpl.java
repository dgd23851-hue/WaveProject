package com.myspring.myproject.board.service;

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
	public List<ArticleVO> listArticles(Map<String, Object> params) {
		return boardDAO.selectAllArticles(params);
	}

	@Override
	public int addNewArticle(Map<String, Object> articleMap) {
		return boardDAO.insertNewArticle(articleMap);
	}

	@Override
	public ArticleVO viewArticle(int articleNO) {
		return boardDAO.selectArticle(articleNO);
	}

	@Override
	public void modArticle(Map<String, Object> articleMap) {
		boardDAO.updateArticle(articleMap);
	}

	@Override
	public void removeArticle(int articleNO) {
		boardDAO.deleteArticle(articleNO);
	}
}