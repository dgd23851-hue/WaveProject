package com.myspring.myproject.board.mapper;

import java.util.List;
import com.myspring.myproject.board.dto.CommentDTO;

public interface CommentMapper {
    List<CommentDTO> listByArticle(Long articleId);
    CommentDTO findById(Long id);
    int insert(CommentDTO dto);
    int deleteById(Long id);
    int deleteByArticle(Long articleId);
}