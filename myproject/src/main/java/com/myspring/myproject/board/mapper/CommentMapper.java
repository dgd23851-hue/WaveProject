package com.myspring.myproject.board.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.myspring.myproject.board.dto.CommentDTO;

public interface CommentMapper {
	int insertComment(CommentDTO dto);

	List<CommentDTO> selectCommentsByArticle(@Param("articleNo") int articleNo);
}
