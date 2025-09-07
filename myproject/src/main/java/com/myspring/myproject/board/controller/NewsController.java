package com.myspring.myproject.board.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import com.myspring.myproject.board.service.BoardService;

@Controller
@RequestMapping("/news")
public class NewsController {

	@Autowired
	private BoardService boardService;

	// /news/{cat}
	@RequestMapping(value = "/{cat}", method = RequestMethod.GET)
	public String listByCat(@PathVariable("cat") String cat, Model model) throws Exception {
		Map<String, Object> param = new HashMap<>();
		param.put("cat", cat);
		model.addAttribute("articlesList", boardService.listArticles(param));
		return "board/listArticles";
	}

	@RequestMapping(value = "/{cat}/{sub}", method = RequestMethod.GET)
	public String listByCatSub(@PathVariable("cat") String cat, @PathVariable("sub") String sub, Model model)
			throws Exception {
		Map<String, Object> param = new HashMap<>();
		param.put("cat", cat);
		param.put("sub", sub);
		model.addAttribute("articlesList", boardService.listArticles(param));
		return "board/listArticles";
	}
}
