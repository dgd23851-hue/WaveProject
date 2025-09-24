package com.myspring.myproject.board.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.myspring.myproject.board.dto.CommentDTO;
import com.myspring.myproject.board.mapper.CommentMapper;

@Service
@Transactional
public class CommentServiceImpl implements CommentService {
	@Autowired
	private CommentMapper commentMapper;

	@Override
	public void addComment(CommentDTO dto) {
		if (dto == null)
			throw new IllegalArgumentException("dto is null");
		if (dto.getArticleId() == null)
			throw new IllegalArgumentException("articleId is null");

		// articleNO 기준 존재 확인
		if (commentMapper.existsArticle(dto.getArticleId()) == 0) {
			throw new IllegalArgumentException("Article not found: articleNO=" + dto.getArticleId());
		}

		int n = commentMapper.insert(dto);
		if (n != 1)
			throw new IllegalStateException("Insert affected=" + n);
		System.out.println("[COMMENT] insert OK, id=" + dto.getId());
	}

	@Override
	public List<CommentDTO> listByArticle(Integer articleId) throws DataAccessException {
		return commentMapper.listByArticle(articleId);
	}

	@Override
	public CommentDTO findById(Long id) {
		return commentMapper.findById(id);
	}

	@Override
	public void deleteById(Long id) {
		commentMapper.deleteById(id);
	}

	@Override
	public void deleteByArticle(Integer articleId) throws DataAccessException {
		List<CommentDTO> list = commentMapper.listByArticle(articleId);
		if (list != null) {
			for (CommentDTO c : list) {
				if (c.getId() != null)
					commentMapper.deleteById(c.getId());
			}
		}
	}
}
