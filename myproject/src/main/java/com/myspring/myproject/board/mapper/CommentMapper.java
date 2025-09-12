package com.myspring.myproject.board.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;

import com.myspring.myproject.board.dto.CommentDTO;

public interface CommentMapper {
    int insertComment(CommentDTO dto);
    List<CommentDTO> selectCommentsByArticle(@Param("articleNO") int articleNO);
    List<CommentDTO> selectReplies(@Param("parentId") int parentId);
    int countReplies(@Param("parentId") int parentId);
    int updateComment(CommentDTO dto);
    int deleteComment(@Param("id") int id);
}
