package com.myspring.myproject.board.service;

import java.util.List;
import org.springframework.dao.DataAccessException;
import com.myspring.myproject.board.dto.CommentDTO;

public interface CommentService {
	List<CommentDTO> listByArticle(Long articleId) throws DataAccessException;

	void addComment(CommentDTO dto) throws DataAccessException;

	CommentDTO findById(Long id) throws DataAccessException;

	void deleteById(Long id) throws DataAccessException;

	void deleteByArticle(Long articleId) throws DataAccessException;
}
