package com.myspring.myproject.board.controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.myspring.myproject.board.dto.CommentDTO;
import com.myspring.myproject.board.service.CommentService;
import com.myspring.myproject.vo.MemberVO; // 사용 중인 VO 패키지에 맞춰 조정

@Controller
@RequestMapping("/board/comment")
public class CommentController {

	@Autowired
	private CommentService commentService;

	// 로그인 정보 헬퍼
	private static class Login {
		final String id; // FK 저장용(문자열로 통일)
		final String displayName; // 댓글 표시용

		Login(HttpSession session) {
			String idStr = null, nameStr = null;

			Object u = session.getAttribute("member");
			if (u == null)
				u = session.getAttribute("loginUser");
			if (u instanceof MemberVO) {
				MemberVO m = (MemberVO) u;
				// m.getId()가 숫자면 문자열로 바꿔줌
				idStr = String.valueOf(m.getId());
				nameStr = m.getName();
				if (nameStr == null || nameStr.trim().isEmpty())
					nameStr = idStr;
			}
			this.id = idStr;
			this.displayName = nameStr;
		}

		boolean loggedIn() {
			return id != null;
		}
	}

	/** 댓글 등록 (최상위/대댓글 공용) */
	@RequestMapping(value = "/add.do", method = RequestMethod.POST)
	public String addComment(@RequestParam("articleNO") int articleNo,
			@RequestParam(value = "parentId", required = false) Long parentId, @RequestParam("content") String content,
			HttpSession session, RedirectAttributes rttr) {

		Login login = new Login(session);
		if (!login.loggedIn()) {
			rttr.addFlashAttribute("error", "로그인 후 댓글을 작성할 수 있습니다.");
			return "redirect:/board/viewArticle.do?articleNO=" + articleNo;
		}

		// DTO 채우기 (타입 맞춤: setArticleNo(Integer), setParentId(Long),
		// setMemberId(String))
		CommentDTO dto = new CommentDTO();
		dto.setArticleNo(Integer.valueOf(articleNo));
		dto.setParentId((parentId != null && parentId > 0) ? parentId : null);
		dto.setContent(content);
		dto.setWriter(login.displayName); // 화면 표시용
		dto.setMemberId(login.id); // FK 저장용

		commentService.addComment(dto);
		return "redirect:/board/viewArticle.do?articleNO=" + articleNo;
	}

	/** 대댓글 전용 엔드포인트 (폼 action='comment/reply.do'인 경우 여기로) */
	@RequestMapping(value = "/reply.do", method = RequestMethod.POST)
	public String replyComment(@RequestParam("articleNO") int articleNo, @RequestParam("parentId") Long parentId,
			@RequestParam("content") String content, HttpSession session, RedirectAttributes rttr) {

		// 결국 add.do 로직 그대로 사용
		return addComment(articleNo, parentId, content, session, rttr);
	}
}
