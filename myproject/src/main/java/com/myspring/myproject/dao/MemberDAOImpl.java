package com.myspring.myproject.dao;

import java.util.List;                           // ★ import 꼭
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import com.myspring.myproject.vo.MemberVO;

@Repository("memberDAO") // ★ 스캔되도록
public class MemberDAOImpl implements MemberDAO {

    private static final String NS = "mapper.member.";

    @Autowired
    private SqlSession sqlSession;

    @Override
    public MemberVO login(MemberVO vo) throws Exception {
        return sqlSession.selectOne(NS + "login", vo);
    }

    @Override
    public List<MemberVO> listMembers() throws Exception {             // ★ 인터페이스와 동일
        return sqlSession.selectList(NS + "listMembers");
    }

    @Override
    public List<MemberVO> searchMemberList(String name) throws Exception { // ★ 동일
        return sqlSession.selectList(NS + "searchMemberList", name);
    }

    @Override
    public void addMember(MemberVO vo) throws Exception {
        sqlSession.insert(NS + "addMember", vo);
    }

    @Override
    public void updateMember(MemberVO vo) throws Exception {
        sqlSession.update(NS + "updateMember", vo);
    }

    @Override
    public void delMember(String id) throws Exception {
        sqlSession.delete(NS + "delMember", id);
    }

    @Override
    public int countById(String id) throws Exception {
        return sqlSession.selectOne(NS + "countById", id);
    }
}
