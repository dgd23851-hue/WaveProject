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

	public CommentServiceImpl() {
	}

	@Override
	public List<CommentDTO> listByArticle(Long articleId) {
		return commentMapper.listByArticle(articleId);
	}

	@Override
	public void addComment(CommentDTO dto) throws DataAccessException {
		int n = commentMapper.insert(dto);
		System.out.println("[COMMENT/SERVICE] insert affected=" + n + ", newId=" + dto.getId());
	}

	@Override
	public CommentDTO findById(Long id) {
		try {
			return commentMapper.findById(id);
		} catch (Exception e) {
			return null;
		}
	}

	@Override
	public void deleteById(Long id) throws DataAccessException {
		commentMapper.deleteById(id);
	}

	@Override
	public void deleteByArticle(Long articleId) throws DataAccessException {
		// 방어적으로 구현
		if (articleId != null) {
			List<CommentDTO> existing = commentMapper.listByArticle(articleId);
			if (existing != null && !existing.isEmpty()) {
				for (CommentDTO c : existing) {
					if (c.getId() != null) {
						commentMapper.deleteById(c.getId());
					}
				}
			}
		}
	}
}
