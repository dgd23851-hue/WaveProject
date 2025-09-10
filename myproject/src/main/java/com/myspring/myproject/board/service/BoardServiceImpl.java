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

	@Autowired
	private com.myspring.myproject.board.mapper.CommentMapper commentMapper;

	@Override
	public List<ArticleVO> listArticles(Map<String, Object> params) throws Exception {
		// null 방어
		if (params == null)
			params = new HashMap<String, Object>();
		return boardDAO.selectAllArticles(params);
	}

	@Override
	public java.util.List<com.myspring.myproject.board.dto.CommentDTO> listCommentsWithReplies(int articleNO) {
		java.util.List<com.myspring.myproject.board.dto.CommentDTO> flat = commentMapper
				.selectCommentsWithReplies(articleNO);
		return buildTree(flat); // 트리 변환
	}

	private java.util.List<com.myspring.myproject.board.dto.CommentDTO> buildTree(
			java.util.List<com.myspring.myproject.board.dto.CommentDTO> flat) {

		java.util.Map<Long, com.myspring.myproject.board.dto.CommentDTO> byId = new java.util.HashMap<Long, com.myspring.myproject.board.dto.CommentDTO>();

		java.util.List<com.myspring.myproject.board.dto.CommentDTO> roots = new java.util.ArrayList<com.myspring.myproject.board.dto.CommentDTO>();

		for (com.myspring.myproject.board.dto.CommentDTO c : flat) {
			byId.put(c.getId(), c);
		}

		for (com.myspring.myproject.board.dto.CommentDTO c : flat) {
			Long pid = c.getParentId();
			if (pid == null) {
				roots.add(c);
			} else {
				com.myspring.myproject.board.dto.CommentDTO p = byId.get(pid);
				if (p != null)
					p.getReplies().add(c);
				else
					roots.add(c);
			}
		}
		return roots;
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
