package com.myspring.myproject.board.service;

import org.springframework.beans.factory.annotation.Autowired; // ← 변경
import org.springframework.stereotype.Service;

import com.myspring.myproject.board.dto.CommentDTO;
import com.myspring.myproject.board.mapper.CommentMapper;

@Service
public class CommentServiceImpl implements CommentService {

	@Autowired // ← @Resource 대신
	private CommentMapper commentMapper;

	@Override
	public void addComment(CommentDTO dto) {
		commentMapper.insertComment(dto);
	}
}
