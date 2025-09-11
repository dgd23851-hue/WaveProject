package com.myspring.myproject.board.dao;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.myspring.myproject.board.vo.ArticleVO;

@Repository
public class BoardDAOImpl implements BoardDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    // 매퍼 네임스페이스는 실제 XML 네임스페이스에 맞추세요 (예: mapper.board)
    private static final String NS = "mapper.board.";

    @Override
    public List<ArticleVO> selectAllArticles(Map<String, Object> params) {
        return sqlSession.selectList(NS + "selectAllArticles", params);
    }

    @Override
    public int insertNewArticle(Map<String, Object> articleMap) {
        return sqlSession.insert(NS + "insertNewArticle", articleMap);
    }

    @Override
    public ArticleVO selectArticle(int articleNO) {
        return sqlSession.selectOne(NS + "selectArticle", articleNO);
    }

    @Override
    public void updateArticle(Map<String, Object> articleMap) {
        sqlSession.update(NS + "updateArticle", articleMap);
    }

    @Override
    public void deleteArticle(int articleNO) {
        sqlSession.delete(NS + "deleteArticle", articleNO);
    }
}