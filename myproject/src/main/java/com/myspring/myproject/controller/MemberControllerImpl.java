package com.myspring.myproject.controller;

import java.util.List;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.multiaction.MultiActionController;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.myspring.myproject.service.MemberService;
import com.myspring.myproject.vo.MemberVO;

@Controller("memberController")
public class MemberControllerImpl extends MultiActionController implements MemberController {

    private static final Logger logger = LoggerFactory.getLogger(MemberControllerImpl.class);

    @Autowired
    private MemberService memberService;

    @Autowired
    private MemberVO memberVO;

    /** 이름으로 회원 검색 */
    @RequestMapping(value = "/member/searchMemberList.do", method = {RequestMethod.GET, RequestMethod.POST})
    public ModelAndView searchMemberList(@RequestParam("name") String name,
                                         HttpServletRequest request, HttpServletResponse response) throws Exception {
        String viewName = getViewName(request);
        ModelAndView mav = new ModelAndView(viewName);
        List searchMemberList = memberService.searchMemberList(name);
        mav.addObject("membersList", searchMemberList);
        mav.addObject("name", name);
        return mav;
    }

    /** 회원 목록 조회 */
    @RequestMapping(value = "/member/listMembers.do", method = {RequestMethod.GET, RequestMethod.POST})
    public ModelAndView listMembers(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String viewName = getViewName(request);
        logger.info("listMembers viewName = {}", viewName);
        List membersList = memberService.listMembers();
        ModelAndView mav = new ModelAndView(viewName);
        mav.addObject("membersList", membersList);
        return mav;
    }

    /** 로그인 폼 이동 */
    @RequestMapping(value = "/member/loginForm.do", method = RequestMethod.GET)
    public ModelAndView loginForm(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String viewName = getViewName(request);
        return new ModelAndView(viewName);
    }

    /** 회원가입 폼 이동 */
    @RequestMapping(value = "/member/memberForm.do", method = RequestMethod.GET)
    public ModelAndView memberForm(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String viewName = getViewName(request);
        return new ModelAndView(viewName);
    }

    /**
     * 로그인 처리 (POST)
     * - 성공: 세션 저장 후 메인으로 redirect
     * - 실패: Flash Attribute("error"="loginFailed") 후 로그인폼 redirect
     */
    @RequestMapping(value = "/member/login.do", method = RequestMethod.POST)
    public ModelAndView login(@ModelAttribute("member") MemberVO member,
                              HttpServletRequest request,
                              HttpServletResponse response,
                              RedirectAttributes ra) throws Exception {

        String viewName = getViewName(request);
        ModelAndView mav = new ModelAndView(viewName);

        memberVO = memberService.login(member);

        if (memberVO != null) {
            HttpSession session = request.getSession();
            session.setAttribute("member", memberVO);
            session.setAttribute("isLogOn", true);
            mav.setViewName("redirect:/main.do");
        } else {
            logger.info("로그인 실패: 아이디/비밀번호 불일치");
            ra.addFlashAttribute("error", "loginFailed");
            mav.setViewName("redirect:/member/loginForm.do");
        }
        return mav;
    }

    /** 로그아웃 */
    @RequestMapping(value = "/member/logout.do", method = RequestMethod.GET)
    public ModelAndView logout(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.removeAttribute("member");
            session.removeAttribute("isLogOn");
        }
        return new ModelAndView("redirect:/main.do");
    }

    /**
     * 회원가입 처리 (POST)
     * - 가입 전 아이디 중복 검사
     * - 중복이면 가입 탭 열고 경고 표시
     */
    @RequestMapping(value = "/member/addMember.do", method = RequestMethod.POST)
    public ModelAndView addMember(@ModelAttribute("member") MemberVO formVO,
                                  HttpServletRequest request,
                                  HttpServletResponse response,
                                  RedirectAttributes ra) throws Exception {

        request.setCharacterEncoding("utf-8");
        response.setContentType("text/html; charset=utf-8");

        String id = formVO.getId() != null ? formVO.getId().trim() : "";
        if (id.isEmpty() || !memberService.isIdAvailable(id)) {
            // 가입 탭 열리게 신호 + 메시지
            ra.addFlashAttribute("signupError", "idExists");
            ra.addFlashAttribute("signupId", id);
            return new ModelAndView("redirect:/member/loginForm.do");
        }

        memberService.addMember(formVO);   // 실제 저장
        return new ModelAndView("redirect:/main.do");
    }

    /** 회원정보 수정 폼 이동 */
    @RequestMapping(value = "/member/memberUpdateForm.do", method = {RequestMethod.GET, RequestMethod.POST})
    public ModelAndView updateForm(@ModelAttribute("member") MemberVO memberVO,
                                   HttpServletRequest request, HttpServletResponse response) throws Exception {
        String viewName = getViewName(request);
        ModelAndView mav = new ModelAndView(viewName);
        mav.addObject("member", memberVO);
        return mav;
    }

    /** 회원정보 수정 처리 */
    @RequestMapping(value = "/member/updateMember.do", method = {RequestMethod.GET, RequestMethod.POST})
    public ModelAndView updateMember(@ModelAttribute("member") MemberVO memberVO,
                                     HttpServletRequest request, HttpServletResponse response) throws Exception {
        request.setCharacterEncoding("utf-8");
        response.setContentType("text/html; charset=utf-8");
        memberService.updateMember(memberVO);
        return new ModelAndView("redirect:/member/listMembers.do");
    }

    /** 회원 삭제 */
    @RequestMapping(value = "/member/delete.do", method = {RequestMethod.GET, RequestMethod.POST})
    public ModelAndView delMember(@RequestParam("id") String id,
                                  HttpServletRequest request, HttpServletResponse response) throws Exception {
        request.setCharacterEncoding("utf-8");
        response.setContentType("text/html; charset=utf-8");
        logger.info("삭제 요청 id = {}", id);
        memberService.delMember(id);
        return new ModelAndView("redirect:/member/listMembers.do");
    }

    /**
     * 아이디 중복 확인 (AJAX)
     * 응답: OK (사용 가능) / DUP (중복)
     */
    @RequestMapping(value = "/member/checkId.do", method = RequestMethod.GET)
    public void checkId(@RequestParam("id") String id,
                        HttpServletResponse response) throws Exception {
        boolean ok = memberService.isIdAvailable(id != null ? id.trim() : "");
        response.setContentType("text/plain; charset=UTF-8");
        response.getWriter().write(ok ? "OK" : "DUP");
    }

    /** URI → viewName */
    private String getViewName(HttpServletRequest request) throws Exception {
        String contextPath = request.getContextPath();
        String uri = (String) request.getAttribute("javax.servlet.include.request_uri");
        if (uri == null || uri.trim().isEmpty()) uri = request.getRequestURI();

        int begin = (contextPath != null) ? contextPath.length() : 0;
        int end = (uri.indexOf(";") != -1) ? uri.indexOf(";") : (uri.indexOf("?") != -1 ? uri.indexOf("?") : uri.length());

        String fileName = uri.substring(begin, end);
        if (fileName.indexOf(".") != -1) fileName = fileName.substring(0, fileName.lastIndexOf("."));
        if (fileName.lastIndexOf("/") != -1) fileName = fileName.substring(fileName.lastIndexOf("/"));
        return fileName;
    }
}
