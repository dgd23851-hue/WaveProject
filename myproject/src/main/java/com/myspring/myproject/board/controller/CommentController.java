package com.myspring.myproject.board.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import com.myspring.myproject.board.service.CommentService;
import com.myspring.myproject.board.dto.CommentDTO;

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
	public String addComment(@RequestParam("articleNO") Integer articleNo, @RequestParam("content") String content,
			@RequestParam(value = "writer", required = false) String writer,
			@RequestParam(value = "parentId", required = false) Long parentId) {

		CommentDTO dto = new CommentDTO();
		dto.setArticleNo(articleNo); // CommentDTO: setArticleNo(Integer) 사용
		dto.setParentId(parentId);
		dto.setWriter((writer == null || writer.trim().isEmpty()) ? "익명" : writer.trim());
		dto.setContent(content);

		commentService.addComment(dto);
		return "redirect:/board/viewArticle.do?articleNO=" + articleNo;
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
