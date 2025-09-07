package com.myspring.myproject;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

@Controller("homeController")
public class HomeController {

  // 루트 -> 게시판 목록으로 보냄
  @RequestMapping(value = {"/", "/home"}, method = RequestMethod.GET)
  public String home() {
    return "redirect:/board/listArticles.do";
  }

  // 메인 페이지: 딱 1개만! (/main.do)
  @RequestMapping(value = "/main.do", method = RequestMethod.GET)
  public String main(Model model) throws Exception {
    model.addAttribute("name", "홍길동");
    return "main";
  }
}
