package com.myspring.myproject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;

import com.myspring.myproject.board.service.BoardService;
import com.myspring.myproject.board.vo.ArticleVO;

@Controller
public class HomeController {

	@Autowired
	private BoardService boardService;

	@RequestMapping(value = { "/", "/main.do" }, method = RequestMethod.GET)
	public ModelAndView home(HttpServletRequest request) {
		ModelAndView mav = new ModelAndView("main");

		// latestArticles: main.jsp가 우선적으로 찾는 키
		List<ArticleVO> latest = new ArrayList<ArticleVO>();
		try {
			// 중복 제거 + 입력 순서 유지
			LinkedHashMap<Integer, ArticleVO> bucket = new LinkedHashMap<Integer, ArticleVO>();

			// 1) 전역 최신 글 몇 개
			Map<String, Object> base = new HashMap<String, Object>();
			base.put("size", 12); // 매퍼에 따라 size/limit 둘 다 넣어 안전하게
			base.put("limit", 12);
			addAll(bucket, boardService.listArticles(base));

			// 2) 카테고리별 상위 글 추가(없어도 무관)
			String[] cats = { "politics", "economy", "society", "world", "culture", "sports", "tech", "it" };
			for (int i = 0; i < cats.length; i++) {
				Map<String, Object> m = new HashMap<String, Object>();
				m.put("cat", cats[i]);
				m.put("size", 6);
				m.put("limit", 6);
				addAll(bucket, boardService.listArticles(m));
			}

			latest = new ArrayList<ArticleVO>(bucket.values());
		} catch (Exception ignore) {
			// DB/Mappers 이슈가 있어도 메인은 500 안 나게 빈 리스트로 진행
		}

		mav.addObject("latestArticles", latest);
		return mav;
	}

	// ========== helpers (JDK8 OK) ==========
	private static void addAll(LinkedHashMap<Integer, ArticleVO> bucket, List<ArticleVO> src) {
		if (src == null)
			return;
		for (ArticleVO a : src) {
			if (a == null)
				continue;
			Integer key = null;
			try {
				key = Integer.valueOf(a.getArticleNO());
			} catch (Exception ignore) {
			}
			if (key == null)
				continue;
			if (!bucket.containsKey(key))
				bucket.put(key, a);
		}
	}
}