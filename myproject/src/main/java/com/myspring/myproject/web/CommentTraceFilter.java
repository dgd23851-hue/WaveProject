package com.myspring.myproject.web;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;

public class CommentTraceFilter implements Filter {

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		if (request instanceof HttpServletRequest) {
			HttpServletRequest req = (HttpServletRequest) request;
			String uri = req.getRequestURI();
			if (uri.contains("/comment/")) {
				System.out.println("[TRACE/FILTER] " + req.getMethod() + " " + uri);
			}
		}
		chain.doFilter(request, response);
	}

	@Override
	public void destroy() {
	}
}
