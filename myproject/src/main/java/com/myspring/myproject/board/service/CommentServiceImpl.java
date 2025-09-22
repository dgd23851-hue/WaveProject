package com.myspring.myproject.board.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.myspring.myproject.board.dto.CommentDTO;
import com.myspring.myproject.board.mapper.CommentMapper;

@Service
@Transactional
public class CommentServiceImpl implements CommentService {

	@Autowired
	private CommentMapper commentMapper;

	// 기본 생성자 (스프링이 사용)
	public CommentServiceImpl() {
	}

	@Override
	public List<CommentDTO> listByArticle(Long articleId) {
		return commentMapper.listByArticle(articleId);
	}

	@Override
	public void addComment(CommentDTO dto) {
		commentMapper.insert(dto);
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
	public void deleteById(Long id) {
		commentMapper.deleteById(id);
	}

	@Override
	public void deleteByArticle(Long articleId) {
		commentMapper.deleteByArticle(articleId);
	}
}
