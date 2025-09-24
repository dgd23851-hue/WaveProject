package com.myspring.myproject.board.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;

import com.myspring.myproject.board.dto.CommentDTO;
import com.myspring.myproject.board.service.CommentService;

@Controller
@RequestMapping("/comment")
public class CommentController {

	@Autowired
	private CommentService commentService;

	public CommentController() {
	}

	// =========================
	// 댓글 등록 (4번 방식 적용)
	// =========================
	@RequestMapping(value = { "/add.do", "/add" }, method = RequestMethod.POST)
	public String add(@RequestParam("articleId") int articleId, // ★ 숫자 강제 (articleNO)
			@RequestParam(value = "articleNO", required = false) String articleNOStr,
			@RequestParam("content") String content, @RequestParam(value = "parentId", required = false) Long parentId,
			HttpSession session) {

		if (content == null || content.trim().isEmpty()) {
			String back = (articleNOStr != null && !articleNOStr.trim().isEmpty()) ? articleNOStr
					: String.valueOf(articleId);
			return "redirect:/board/viewArticle.do?articleNO=" + back + "&r=empty";
		}

		String writer = resolveLoginId(session);
		if (writer == null || writer.trim().isEmpty())
			writer = "anonymous";

		CommentDTO dto = new CommentDTO();
		dto.setArticleId(articleId); // Integer로 자동 박싱
		dto.setParentId(parentId);
		dto.setWriter(writer);
		dto.setContent(content);

		commentService.addComment(dto);

		String back = (articleNOStr != null && !articleNOStr.trim().isEmpty()) ? articleNOStr
				: String.valueOf(articleId);
		return "redirect:/board/viewArticle.do?articleNO=" + back + "&r=ok&id=" + dto.getId();
	}

	// =========================
	// 댓글 삭제 (참고용)
	// =========================
	@RequestMapping(value = { "/delete.do", "/delete" }, method = RequestMethod.POST)
	public String delete(@RequestParam("id") String idStr,
			@RequestParam(value = "articleId", required = false) String articleIdStr,
			@RequestParam(value = "articleNO", required = false) String articleNOStr, HttpServletRequest request) {

		Long id = toLong(idStr);
		Long aid = toLong(articleIdStr);
		if (aid == null)
			aid = toLong(request.getParameter("articleId"));

		String articleNOForView = (StringUtils.hasText(articleNOStr)) ? articleNOStr
				: (aid == null ? "" : String.valueOf(aid));

		if (id != null) {
			commentService.deleteById(id);
			return "redirect:/board/viewArticle.do?articleNO=" + articleNOForView + "&r=del_ok";
		} else {
			return "redirect:/board/viewArticle.do?articleNO=" + articleNOForView + "&r=del_missing_id";
		}
	}

	// ---------- helpers ----------
	private Long toLong(String s) {
		if (s == null)
			return null;
		try {
			String t = s.trim();
			return t.isEmpty() ? null : Long.valueOf(t);
		} catch (Exception e) {
			return null;
		}
	}

	private boolean isDigits(String s) {
		return s != null && s.trim().matches("^\\d+$");
	}

	// 세션의 member에서 getId() 호출 (로그인 아이디)
	private String resolveLoginId(HttpSession session) {
		Object m = (session == null) ? null : session.getAttribute("member");
		if (m == null)
			return null;
		try {
			return (String) m.getClass().getMethod("getId").invoke(m);
		} catch (Exception ignore) {
			return null;
		}
	}
}
