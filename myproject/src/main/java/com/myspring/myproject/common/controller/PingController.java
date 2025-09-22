package com.myspring.myproject.common.controller;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class PingController {

	@RequestMapping(value = "/ping.do", method = RequestMethod.GET, produces = "text/plain; charset=UTF-8")
	@ResponseBody
	public String ping() {
		return "pong";
	}

	@RequestMapping(value = "/echo.do", method = RequestMethod.GET, produces = "text/plain; charset=UTF-8")
	@ResponseBody
	public String echo(HttpServletRequest req) {
		StringBuilder sb = new StringBuilder();
		sb.append("uri=").append(req.getRequestURI()).append('\n');
		sb.append("ctx=").append(req.getContextPath()).append('\n');
		java.util.Enumeration<String> en = req.getParameterNames();
		while (en.hasMoreElements()) {
			String k = en.nextElement();
			String[] v = req.getParameterValues(k);
			sb.append(k).append("=");
			sb.append(java.util.Arrays.toString(v));
			sb.append('\n');
		}
		return sb.toString();
	}

	@RequestMapping(value = "/comment/ping.do", method = RequestMethod.GET, produces = "text/plain; charset=UTF-8")
	@ResponseBody
	public String commentPing(@RequestParam(value = "articleId", required = false) Long articleId,
			@RequestParam(value = "articleNO", required = false) Long articleNO, HttpServletRequest req) {
		Long aid = firstNonNull(articleId, articleNO, toLong(req.getParameter("articleId")),
				toLong(req.getParameter("articleNO")));
		return "ok\narticleId=" + String.valueOf(aid);
	}

	// helpers
	private Long toLong(String s) {
		if (s == null)
			return null;
		try {
			return Long.valueOf(s.trim());
		} catch (Exception e) {
			return null;
		}
	}

	private Long firstNonNull(Long... vals) {
		if (vals == null)
			return null;
		for (Long v : vals)
			if (v != null)
				return v;
		return null;
	}
}