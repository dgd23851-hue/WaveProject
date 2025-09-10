package com.myspring.myproject.board.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.myspring.myproject.board.dto.CommentDTO;
import com.myspring.myproject.board.service.CommentService;

@Controller
@RequestMapping("/board")
public class CommentController {

    @Autowired
    private CommentService commentService;

    // /board/addComment.do 와 /board/comment/reply.do 를 둘 다 POST로 처리
    @RequestMapping(value = {"/addComment.do", "/comment/reply.do"}, method = RequestMethod.POST)
    public String addComment(
            // 둘 중 오는 걸로 받음 (JSP가 articleNo를 쓰든 articleNO를 쓰든 OK)
            @RequestParam(value = "articleNo", required = false) Integer articleNo1,
            @RequestParam(value = "articleNO", required = false) Integer articleNo2,
            @RequestParam(value = "parentId",  required = false) Long parentId,
            @RequestParam("content") String content,
            HttpSession session,
            HttpServletRequest request,
            RedirectAttributes ra) {

        // 글 번호 확정
        Integer articleNo = (articleNo1 != null) ? articleNo1 : articleNo2;
        if (articleNo == null || articleNo <= 0) {
            ra.addFlashAttribute("msg", "잘못된 요청입니다.");
            return "redirect:/board/listArticles.do";
        }

        // 작성자 ID (세션 키는 프로젝트에 맞춰 수정)
        String writerId = (String) session.getAttribute("memberId");
        if (writerId == null) writerId = "anonymous";

        // DTO 구성
        CommentDTO dto = new CommentDTO();
        dto.setArticleNo(articleNo);     // ★ FK 컬럼에 맞춘 이름
        dto.setParentId(parentId);       // null이면 일반 댓글, 있으면 답글
        dto.setWriter(writerId);
        dto.setContent(content);

        // 저장
        commentService.addComment(dto);

        // 상세로 리다이렉트 (네 컨트롤러가 articleNO로 받는다면 그대로 맞춰 보냄)
        ra.addAttribute("articleNO", articleNo);
        return "redirect:/board/viewArticle.do";
    }
}
