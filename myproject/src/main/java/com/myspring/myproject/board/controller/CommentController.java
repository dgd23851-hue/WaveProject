package com.myspring.myproject.board.controller;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.myspring.myproject.board.dto.CommentDTO;
import com.myspring.myproject.board.service.CommentService;

@Controller
@RequestMapping("/board") // <- /board 고정
public class CommentController {

	@Autowired
	private CommentService commentService;

	// 헬스체크: 이게 404면 컨트롤러 스캔/매핑 자체가 안 된 것
	@RequestMapping(value = "/comment/ping.do", method = RequestMethod.GET)
	@ResponseBody
	public String ping() {
		return "OK";
	}

	@RequestMapping(value = "/comment/add.do", method = RequestMethod.POST)
	public String addComment(
	        HttpServletRequest request,
	        @RequestParam(value = "articleNO", required = false) Integer articleNO,
	        @RequestParam(value = "articleNo", required = false) Integer articleNo2,
	        @RequestParam(value = "articleId", required = false) Integer articleId,
	        @RequestParam(value = "article_no", required = false) Integer article_no_alt,
	        @ModelAttribute CommentDTO commentDTO
	) {
	    // 1) 어떤 파라미터로 오든 하나로 정리
	    Integer aNo = firstNonNull(articleNO, articleNo2, articleId, article_no_alt, commentDTO.getArticleNo());

	    if (aNo == null) {
	        // 필요하면 여기서 request.getParameterMap()을 로그로 찍어 보세요
	        throw new IllegalArgumentException("articleNO(=게시글 번호) 파라미터가 누락되었습니다.");
	    }

	    // 2) DTO에 확실히 세팅
	    commentDTO.setArticleNo(aNo);

	    // 3) 저장
	    commentService.addComment(commentDTO);

	    // 4) 원문으로 리다이렉트 (프로젝트 경로에 맞게)
	    return "redirect:/board/viewArticle.do?articleNO=" + aNo;
	}

	// 유틸: 첫 번째 non-null 반환
	@SafeVarargs
	private static <T> T firstNonNull(T... values) {
	    for (T v : values) if (v != null) return v;
	    return null;
	}

	@RequestMapping(value = "/comment/reply.do", method = RequestMethod.POST)
	public String replyComment(@RequestParam("articleNO") Integer articleNo, @RequestParam("parentId") Long parentId,
			@RequestParam("content") String content, @RequestParam(value = "writer", required = false) String writer) {

		CommentDTO dto = new CommentDTO();
		dto.setArticleNo(articleNo);
		dto.setParentId(parentId);
		dto.setWriter((writer == null || writer.trim().isEmpty()) ? "익명" : writer.trim());
		dto.setContent(content);

		commentService.addComment(dto);
		return "redirect:/board/viewArticle.do?articleNO=" + articleNo;
	}
}
