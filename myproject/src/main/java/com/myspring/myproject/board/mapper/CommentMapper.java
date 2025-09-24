package com.myspring.myproject.board.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.myspring.myproject.board.dto.CommentDTO;

public interface CommentMapper {
	int existsArticle(@Param("id") Integer id);

	int insert(CommentDTO dto);

	List<CommentDTO> listByArticle(@Param("articleId") Integer articleId);

	CommentDTO findById(@Param("id") Long id);

	int deleteById(@Param("id") Long id);
}
