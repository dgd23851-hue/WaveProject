package com.myspring.myproject.board.service;

import java.util.List;

import com.myspring.myproject.board.dto.CommentDTO;

public interface CommentService {
    List<CommentDTO> listByArticle(Long articleId);
    void addComment(CommentDTO dto);
    CommentDTO findById(Long id);
    void deleteById(Long id);
    void deleteByArticle(Long articleId);
}
