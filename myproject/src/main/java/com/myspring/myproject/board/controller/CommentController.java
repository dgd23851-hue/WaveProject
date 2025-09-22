package com.myspring.myproject.board.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.myspring.myproject.board.dto.CommentDTO;
import com.myspring.myproject.board.service.CommentService;

@Controller
@RequestMapping("/comment")
public class CommentController {

	@Autowired
	private CommentService commentService;

	public CommentController() {
	}

	// 경로 점검용 핑 (GET)
	@RequestMapping(value = "/ping.do", method = RequestMethod.GET)
	@ResponseBody
	public String ping() {
		return "OK /comment";
	}

	// 댓글 목록(JSON)
	@RequestMapping(value = "/list.do", method = RequestMethod.GET)
	@ResponseBody
	public Map<String, Object> listByArticle(@RequestParam(value = "articleId", required = false) Long articleId,
			@RequestParam(value = "articleNO", required = false) Long articleNO) {
		Long aid = coalesce(articleId, articleNO);
		Map<String, Object> res = new HashMap<String, Object>();
		if (aid == null) {
			res.put("ok", false);
			res.put("error", "MISSING_ARTICLE_ID");
			return res;
		}
		List<CommentDTO> list = commentService.listByArticle(aid);
		res.put("ok", true);
		res.put("count", list == null ? 0 : list.size());
		res.put("items", list);
		return res;
	}

	// 댓글 등록(POST) — 파라미터 유연 처리
	@RequestMapping(value = "/add.do", method = RequestMethod.POST)
	public String add(@RequestParam(value = "articleId", required = false) Long articleId,
			@RequestParam(value = "articleNO", required = false) Long articleNO,
			@RequestParam(value = "content", required = false) String content,
			@RequestParam(value = "parentId", required = false) Long parentId, HttpServletRequest request,
			HttpSession session, ModelMap model) {

		Long aid = coalesce(articleId, articleNO, toLong(request.getParameter("articleId")),
				toLong(request.getParameter("articleNO")));
		if (aid == null) {
			return "redirect:/board/listArticles.do";
		}
		if (!StringUtils.hasText(content)) {
			return "redirect:/board/viewArticle.do?articleNO=" + aid;
		}

		String writer = resolveLoginId(session);

		CommentDTO dto = new CommentDTO();
		dto.setArticleId(aid);
		dto.setParentId(parentId);
		dto.setWriter(writer);
		dto.setContent(content);

		commentService.addComment(dto);
		return "redirect:/board/viewArticle.do?articleNO=" + aid;
	}

	// 댓글 삭제(POST)
	@RequestMapping(value = "/delete.do", method = RequestMethod.POST)
	public String delete(@RequestParam("id") Long id,
			@RequestParam(value = "articleId", required = false) Long articleId,
			@RequestParam(value = "articleNO", required = false) Long articleNO, HttpServletRequest request,
			HttpSession session) {
		Long aid = coalesce(articleId, articleNO, toLong(request.getParameter("articleId")),
				toLong(request.getParameter("articleNO")));
		if (aid == null) {
			return "redirect:/board/listArticles.do";
		}
		String loginId = resolveLoginId(session);
		CommentDTO found = commentService.findById(id);
		if (found != null) {
			if (equalsSafe(found.getWriter(), loginId) || isAdmin(session)) {
				commentService.deleteById(id);
			}
		}
		return "redirect:/board/viewArticle.do?articleNO=" + aid;
	}

	// ======================== helpers ===========================
	private String resolveLoginId(HttpSession session) {
		Object m = session == null ? null : session.getAttribute("member");
		if (m == null)
			return null;
		try {
			return (String) m.getClass().getMethod("getId").invoke(m);
		} catch (Exception ignore) {
			return null;
		}
	}

	private boolean isAdmin(HttpSession session) {
		Object m = session == null ? null : session.getAttribute("member");
		if (m == null)
			return false;
		try {
			Object role = m.getClass().getMethod("getRole").invoke(m);
			return role != null && "ADMIN".equals(String.valueOf(role));
		} catch (Exception ignore) {
			return false;
		}
	}

	private boolean equalsSafe(Object a, Object b) {
		return (a == b) || (a != null && a.equals(b));
	}

	private Long toLong(String s) {
		if (s == null)
			return null;
		try {
			return Long.valueOf(s.trim());
		} catch (Exception e) {
			return null;
		}
	}

	private Long coalesce(Long... vals) {
		if (vals == null)
			return null;
		for (Long v : vals)
			if (v != null)
				return v;
		return null;
	}
}
