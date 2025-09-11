package com.myspring.myproject.board.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.myspring.myproject.board.dao.BoardDAO;
import com.myspring.myproject.board.dto.CommentDTO;
import com.myspring.myproject.board.mapper.CommentMapper;
import com.myspring.myproject.board.vo.ArticleVO;

@Service
public class BoardServiceImpl implements BoardService {

	@Autowired
	private BoardDAO boardDAO;

	@Autowired
	private CommentMapper commentMapper;

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

	// ===== 댓글 트리 반환 =====
	@Override
	public List<CommentDTO> listCommentsWithReplies(int articleNO) {
		List<CommentDTO> flat = commentMapper.selectCommentsByArticle(articleNO);

		// 트리 변환
		Map<Long, CommentDTO> byId = new HashMap<>();
		List<CommentDTO> roots = new ArrayList<>();

		for (CommentDTO c : flat) {
			if (c.getReplies() == null)
				c.setReplies(new ArrayList<CommentDTO>());
			byId.put(c.getId(), c);
		}
		for (CommentDTO c : flat) {
			Long pid = c.getParentId();
			if (pid == null || pid == 0L) {
				roots.add(c);
			} else {
				CommentDTO p = byId.get(pid);
				if (p != null)
					p.getReplies().add(c);
				else
					roots.add(c); // 고아 방지
			}
		}
		return roots;
	}
}