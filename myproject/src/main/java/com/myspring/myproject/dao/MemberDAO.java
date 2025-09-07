package com.myspring.myproject.dao;

import java.util.List;
import com.myspring.myproject.vo.MemberVO;

public interface MemberDAO {
    MemberVO login(MemberVO vo) throws Exception;
    List<MemberVO> listMembers() throws Exception;            // ★ 제네릭
    List<MemberVO> searchMemberList(String name) throws Exception; // ★ 제네릭
    void addMember(MemberVO vo) throws Exception;
    void updateMember(MemberVO vo) throws Exception;
    void delMember(String id) throws Exception;

    int countById(String id) throws Exception; // 아이디 중복 체크
}
