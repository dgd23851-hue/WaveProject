package com.myspring.myproject.board.mapper;

import com.myspring.myproject.board.dto.CommentDTO;
import java.util.List;

public interface CommentMapper {
	List<CommentDTO> selectCommentsWithReplies(int articleNO);

	int insertComment(CommentDTO dto);
}