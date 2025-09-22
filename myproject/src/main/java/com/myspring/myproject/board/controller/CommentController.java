package com.myspring.myproject.board.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
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

	@Autowired
	private DataSource dataSource;

	public CommentController() {
	}

	// quick ping
	@RequestMapping(value = { "/ping.do", "/ping" }, method = RequestMethod.GET)
	@ResponseBody
	public String ping() {
		return "OK /comment";
	}

	@RequestMapping(value = { "/add.do", "/add" }, method = RequestMethod.POST)
	public String add(@RequestParam(value = "articleId", required = false) String articleIdStr,
			@RequestParam(value = "articleNO", required = false) String articleNOStr,
			@RequestParam(value = "content", required = false) String content,
			@RequestParam(value = "parentId", required = false) String parentIdStr, HttpServletRequest request,
			HttpSession session, ModelMap model) {

		Long aid = toLong(articleIdStr);
		if (aid == null)
			aid = toLong(articleNOStr);
		if (aid == null)
			aid = toLong(request.getParameter("articleId"));
		if (aid == null)
			aid = toLong(request.getParameter("articleNO"));

		System.out.println("[COMMENT/ADD] aId=" + aid + ", aNO=" + articleNOStr + ", contentLen="
				+ (content == null ? 0 : content.length()));

		if (aid == null) {
			System.out.println("[COMMENT/ADD] aid null → redirect list");
			return "redirect:/board/listArticles.do";
		}
		if (!StringUtils.hasText(content)) {
			System.out.println("[COMMENT/ADD] empty content → redirect view");
			return "redirect:/board/viewArticle.do?articleNO=" + aid;
		}
		Long parentId = toLong(parentIdStr);
		String writer = resolveLoginId(session);
		if (!StringUtils.hasText(writer))
			writer = "anonymous";

		CommentDTO dto = new CommentDTO();
		dto.setArticleId(aid);
		dto.setParentId(parentId);
		dto.setWriter(writer);
		dto.setContent(content);

		try {
			commentService.addComment(dto);
			System.out.println("[COMMENT/ADD] inserted newId=" + dto.getId());
		} catch (DataAccessException e) {
			System.err.println("[COMMENT/ADD][ERROR] " + e.getClass().getSimpleName() + " : " + e.getMessage());
		}

		return "redirect:/board/viewArticle.do?articleNO=" + aid;
	}

	@RequestMapping(value = { "/delete.do", "/delete" }, method = RequestMethod.POST)
	public String delete(@RequestParam("id") String idStr,
			@RequestParam(value = "articleId", required = false) String articleIdStr,
			@RequestParam(value = "articleNO", required = false) String articleNOStr, HttpServletRequest request,
			HttpSession session) {

		Long id = toLong(idStr);
		Long aid = toLong(articleIdStr);
		if (aid == null)
			aid = toLong(articleNOStr);
		if (aid == null)
			aid = toLong(request.getParameter("articleId"));
		if (aid == null)
			aid = toLong(request.getParameter("articleNO"));

		if (id != null) {
			try {
				commentService.deleteById(id);
				System.out.println("[COMMENT/DEL] deleted id=" + id);
			} catch (DataAccessException e) {
				System.err.println("[COMMENT/DEL][ERROR] " + e.getClass().getSimpleName() + " : " + e.getMessage());
			}
		}
		return "redirect:/board/viewArticle.do?articleNO=" + (aid == null ? "" : aid.toString());
	}

	// ===== Diagnostics
	@RequestMapping(value = { "/diag.do", "/diag" }, method = RequestMethod.GET)
	@ResponseBody
	public Map<String, Object> diag(@RequestParam(value = "articleId", required = false) Long articleId) {
		Map<String, Object> res = new HashMap<String, Object>();
		res.put("ok", true);
		Connection conn = null;
		try {
			res.put("dataSourceClass", dataSource.getClass().getName());
			try {
				res.put("url", (String) dataSource.getClass().getMethod("getUrl").invoke(dataSource));
			} catch (Exception ignore) {
			}
			try {
				res.put("jdbcUrl", (String) dataSource.getClass().getMethod("getJdbcUrl").invoke(dataSource));
			} catch (Exception ignore) {
			}

			conn = dataSource.getConnection();
			res.put("catalog", safe(conn.getCatalog()));
			try (PreparedStatement ps = conn.prepareStatement("SELECT DATABASE()"); ResultSet rs = ps.executeQuery()) {
				if (rs.next())
					res.put("database()", safe(rs.getString(1)));
			}
			try (PreparedStatement ps = conn.prepareStatement("SHOW TABLES LIKE 'comments'");
					ResultSet rs = ps.executeQuery()) {
				res.put("has_comments_table", rs.next());
			}
			if (articleId != null) {
				try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM comments WHERE articleId=?")) {
					ps.setLong(1, articleId);
					try (ResultSet rs = ps.executeQuery()) {
						if (rs.next())
							res.put("count_by_article", rs.getLong(1));
					}
				}
			} else {
				try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM comments");
						ResultSet rs = ps.executeQuery()) {
					if (rs.next())
						res.put("count_total", rs.getLong(1));
				}
			}
			List<Map<String, Object>> recent = new ArrayList<Map<String, Object>>();
			try (PreparedStatement ps = conn.prepareStatement(
					"SELECT id, articleId, writer, LEFT(content,60) AS snippet, writeDate FROM comments ORDER BY id DESC LIMIT 5");
					ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {
					Map<String, Object> row = new HashMap<String, Object>();
					row.put("id", rs.getLong("id"));
					row.put("articleId", rs.getLong("articleId"));
					row.put("writer", safe(rs.getString("writer")));
					row.put("snippet", safe(rs.getString("snippet")));
					Timestamp ts = rs.getTimestamp("writeDate");
					row.put("writeDate", ts == null ? null : ts.toString());
					recent.add(row);
				}
			}
			res.put("recent", recent);
		} catch (Exception e) {
			res.put("ok", false);
			res.put("error", e.getClass().getSimpleName() + ": " + e.getMessage());
		} finally {
			try {
				if (conn != null)
					conn.close();
			} catch (Exception ignore) {
			}
		}
		return res;
	}

	private String safe(String s) {
		return s == null ? null : s;
	}

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
}
