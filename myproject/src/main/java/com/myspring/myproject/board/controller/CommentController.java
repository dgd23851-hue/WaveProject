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
	public String add(@RequestParam(value = "articleId", required = false) String articleIdStr,
			@RequestParam(value = "articleNO", required = false) String articleNOStr, // 화면 복귀용
			@RequestParam(value = "content", required = false) String content,
			@RequestParam(value = "parentId", required = false) String parentIdStr, HttpServletRequest request,
			HttpSession session) {

		// 0) 원문 디버그 (문제 재현시 추적에 유용)
		System.out.println("[CC] RAW articleIdStr=" + articleIdStr + ", req.articleId="
				+ request.getParameter("articleId") + ", content=" + content);

		// 1) articleId는 오직 숫자로만 (비/비정상은 즉시 차단)
		if (!isDigits(articleIdStr) && !isDigits(request.getParameter("articleId"))) {
			System.out.println("[CC] FAIL: non-numeric articleId. raw=" + articleIdStr);
			return "redirect:/board/listArticles.do?r=aid_null";
		}
		Long aid = toLong(articleIdStr);
		if (aid == null)
			aid = toLong(request.getParameter("articleId"));

		// 상세화면 복귀용 파라미터
		String articleNOForView = (StringUtils.hasText(articleNOStr)) ? articleNOStr
				: (aid == null ? "" : String.valueOf(aid));

		// 2) 내용 비었으면 상세로 복귀
		if (!StringUtils.hasText(content) || content.trim().isEmpty()) {
			return "redirect:/board/viewArticle.do?articleNO=" + articleNOForView + "&r=empty";
		}

		// 3) writer는 세션에서만 읽어서 writer 필드에만 (articleId에 섞이지 않게)
		String writer = resolveLoginId(session);
		if (!StringUtils.hasText(writer))
			writer = "anonymous";

		// 4) 실제로 서비스에 무엇을 보낼지 출력 (최종 방어선)
		System.out.println("[CC] add(): articleId(Long)=" + aid + ", parentId=" + parentIdStr + ", writer=" + writer);

		// 5) DTO 구성 (★ articleId에는 Long만!)
		CommentDTO dto = new CommentDTO();
		dto.setArticleId(aid); // Long
		dto.setParentId(toLong(parentIdStr)); // Long 또는 null
		dto.setWriter(writer); // 문자열은 writer에만
		dto.setContent(content);

		// 6) 서비스 호출 (Service가 resolveArticleId(Long) → exists → insert 수행)
		commentService.addComment(dto);

		// 7) 성공 시 상세로 복귀
		return "redirect:/board/viewArticle.do?articleNO=" + articleNOForView + "&r=ok&id=" + dto.getId();
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
