package com.myspring.myproject.board.mapper;

import org.apache.ibatis.annotations.Param;
import com.myspring.myproject.board.vo.ArticleVO;

public interface BoardMapper {
    ArticleVO selectArticle(@Param("articleNO") int articleNO);
}