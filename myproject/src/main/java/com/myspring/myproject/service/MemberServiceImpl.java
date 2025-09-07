package com.myspring.myproject.service;

import java.util.List;                        // ★ import
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.myspring.myproject.dao.MemberDAO;
import com.myspring.myproject.vo.MemberVO;

@Service("memberService")
public class MemberServiceImpl implements MemberService {

    @Autowired
    private MemberDAO memberDAO;

    @Override
    public MemberVO login(MemberVO vo) throws Exception {
        return memberDAO.login(vo);
    }

    @Override
    public List<MemberVO> listMembers() throws Exception {                 // ★ 동일
        return memberDAO.listMembers();
    }

    @Override
    public List<MemberVO> searchMemberList(String name) throws Exception { // ★ 동일
        return memberDAO.searchMemberList(name);
    }

    @Override
    public void addMember(MemberVO vo) throws Exception {
        memberDAO.addMember(vo);
    }

    @Override
    public void updateMember(MemberVO vo) throws Exception {
        memberDAO.updateMember(vo);
    }

    @Override
    public void delMember(String id) throws Exception {
        memberDAO.delMember(id);
    }

    @Override
    public boolean isIdAvailable(String id) throws Exception {
        if (id == null || id.trim().isEmpty()) return false;
        return memberDAO.countById(id.trim()) == 0;
    }
}
