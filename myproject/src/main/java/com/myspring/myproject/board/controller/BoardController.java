package com.myspring.myproject.board.controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

public interface BoardController {

    ModelAndView listArticles(HttpServletRequest request, HttpServletResponse response) throws Exception;

    ResponseEntity addNewArticle(MultipartHttpServletRequest multipartRequest, HttpServletResponse response) throws Exception;

    ModelAndView viewArticle(@RequestParam("articleNO") int articleNO,
                             HttpServletRequest request, HttpServletResponse response) throws Exception;

    ResponseEntity removeArticle(@RequestParam("articleNO") int articleNO,
                                 HttpServletRequest request, HttpServletResponse response) throws Exception;

    /** ✅ 글쓰기 폼 (사건사고 클릭 시 진입) */
    ModelAndView articleForm(HttpServletRequest request, HttpServletResponse response) throws Exception;
}
