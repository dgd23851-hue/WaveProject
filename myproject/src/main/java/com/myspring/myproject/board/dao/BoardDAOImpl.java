package com.myspring.myproject.board.dao;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.myspring.myproject.board.vo.ArticleVO;

@Repository
public class BoardDAOImpl implements BoardDAO {

    @Autowired
    private SqlSession sqlSession;

    private static final String NS = "mapper.board";

    @Override
    public List<ArticleVO> selectAllArticles(Map<String, Object> params) throws Exception {
        // 매퍼 id는 아래 XML과 맞춥니다.
        return sqlSession.selectList(NS + ".selectAllArticles", params);
    }

    @Override
    public int insertNewArticle(Map<String, Object> articleMap) {
        sqlSession.insert("mapper.board.insertNewArticle", articleMap);
        Object key = articleMap.get("articleNO"); // selectKey가 넣어줌
        return (key instanceof Number) ? ((Number) key).intValue() : 0;
    }

    @Override
    public ArticleVO selectArticle(int articleNO) {
        return sqlSession.selectOne("mapper.board.selectArticle", articleNO);
    }

    @Override
    public void updateArticle(Map<String, Object> articleMap) {
        sqlSession.update("mapper.board.updateArticle", articleMap);
    }

    @Override
    public void deleteArticle(int articleNO) {
        sqlSession.delete("mapper.board.deleteArticle", articleNO);
    }
}
