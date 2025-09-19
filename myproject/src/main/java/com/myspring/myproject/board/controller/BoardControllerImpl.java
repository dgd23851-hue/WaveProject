package com.myspring.myproject.board.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.security.Principal;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.myspring.myproject.board.mapper.BoardMapper;
import com.myspring.myproject.board.service.BoardService;
import com.myspring.myproject.board.service.CommentService;
import com.myspring.myproject.board.vo.ArticleVO;

@Controller
@RequestMapping("/board")
public class BoardControllerImpl {
	@Autowired
	private BoardMapper boardMapper;
	@Autowired
	private BoardService boardService;
	@Autowired
	private ServletContext servletContext;
	@Autowired
	private CommentService commentService;

	/* ---------- JDK 8 유틸 ---------- */
	private static boolean isBlank(String s) {
		return s == null || s.trim().isEmpty();
	}

	private static String trim(String s) {
		return (s == null) ? null : s.trim();
	}

	private static void putIfNotBlank(Map<String, Object> m, String k, String v) {
		if (!isBlank(v))
			m.put(k, v);
	}

	/** 업로드 베이스 경로 (web.xml context-param: articleImageRepo 우선) */
	private String getImageRepo() {
		String path = servletContext.getInitParameter("articleImageRepo");
		if (isBlank(path)) {
			// 로컬(Windows) vs 카페24(Linux) 기본값
			path = (File.separatorChar == '\\') ? "C:\\board\\article_image"
					: "/home/hosting_users/계정명/www/board/article_image";
		}
		return path;
	}

	/** 업로드 파라미터 이름이 제각각일 때 첫 파일 하나 고르기 */
	private MultipartFile pickFirstFile(MultipartHttpServletRequest req) {
		MultipartFile f = req.getFile("imageFile"); // 새 이름
		if (f == null || f.isEmpty())
			f = req.getFile("imageFileName"); // 예전 이름
		if ((f == null || f.isEmpty()) && req.getFileNames().hasNext()) {
			String name = (String) req.getFileNames().next();
			f = req.getFile(name);
		}
		return (f != null && !f.isEmpty()) ? f : null;
	}

	/** temp에 저장하고 파일명 반환 */
	private String saveToTempAndReturnFileName(MultipartFile file) throws Exception {
		if (file == null || file.isEmpty())
			return null;
		String repo = getImageRepo();
		File tempDir = new File(repo, "temp");
		if (!tempDir.exists())
			tempDir.mkdirs();
		String fileName = file.getOriginalFilename();
		File dest = new File(tempDir, fileName);
		file.transferTo(dest);
		return fileName;
	}

	/** temp -> /{articleNO}/ 로 이동 */
	private void moveImageFromTemp(int articleNO, String imageFileName) throws Exception {
		if (isBlank(imageFileName))
			return;
		String repo = getImageRepo();
		File src = new File(new File(repo, "temp"), imageFileName);
		File destDir = new File(repo + File.separator + articleNO);
		if (!destDir.exists())
			destDir.mkdirs();
		File dest = new File(destDir, imageFileName);
		if (src.exists()) {
			FileCopyUtils.copy(src, dest);
			try {
				src.delete();
			} catch (Exception ignore) {
			}
		}
	}

	/** 세션/파라미터/Principal 등에서 로그인 아이디 찾기 */
	private String resolveLoginId(HttpServletRequest request) {
		String id = trim(request.getParameter("id"));
		if (!isBlank(id))
			return id;

		Principal p = request.getUserPrincipal();
		if (p != null && !isBlank(p.getName()))
			return p.getName();

		HttpSession session = request.getSession(false);
		if (session != null) {
			Object v;
			v = session.getAttribute("id");
			if (v instanceof String && !isBlank((String) v))
				return (String) v;

			v = session.getAttribute("member");
			String from = getIdByReflection(v);
			if (!isBlank(from))
				return from;

			v = session.getAttribute("memberInfo");
			from = getIdByReflection(v);
			if (!isBlank(from))
				return from;

			v = session.getAttribute("loginMember");
			from = getIdByReflection(v);
			if (!isBlank(from))
				return from;

			v = session.getAttribute("user");
			from = getIdByReflection(v);
			if (!isBlank(from))
				return from;

			v = session.getAttribute("loginId");
			if (v instanceof String && !isBlank((String) v))
				return (String) v;
		}
		return null;
	}

	private String getIdByReflection(Object obj) {
		if (obj == null)
			return null;
		try {
			return (String) obj.getClass().getMethod("getId").invoke(obj);
		} catch (Exception ignore) {
			return null;
		}
	}

	/* ============================== 목록 ============================== */
	@RequestMapping(value = "/listArticles.do", method = RequestMethod.GET)
	public ModelAndView listArticles(HttpServletRequest request) throws Exception {
		String cat = trim(request.getParameter("cat"));
		String sub = trim(request.getParameter("sub"));
		String page = trim(request.getParameter("page"));
		String size = trim(request.getParameter("size"));
		String q = trim(request.getParameter("q")); // 검색어

		Map<String, Object> searchMap = new HashMap<String, Object>();
		putIfNotBlank(searchMap, "cat", cat);
		putIfNotBlank(searchMap, "category", cat); // 매퍼 별칭 호환
		putIfNotBlank(searchMap, "sub", sub);
		putIfNotBlank(searchMap, "subcategory", sub);
		putIfNotBlank(searchMap, "q", q);
		putIfNotBlank(searchMap, "keyword", q);
		if (!isBlank(page))
			searchMap.put("page", Integer.parseInt(page));
		if (!isBlank(size))
			searchMap.put("size", Integer.parseInt(size));

		java.util.List<ArticleVO> list = boardService.listArticles(searchMap);

		// 매퍼가 검색을 아직 지원하지 않아도 동작하도록 메모리에서 2차 필터
		if (!isBlank(q) && list != null && !list.isEmpty()) {
			final String needle = q.toLowerCase();
			java.util.List<ArticleVO> filtered = new java.util.ArrayList<>();
			for (ArticleVO a : list) {
				boolean hit = false;
				try {
					String title = null;
					try {
						title = (String) a.getClass().getMethod("getTitle").invoke(a);
					} catch (Exception ignore) {
					}
					String content = null;
					try {
						content = (String) a.getClass().getMethod("getContent").invoke(a);
					} catch (Exception ignore) {
					}
					String summary = null;
					try {
						summary = (String) a.getClass().getMethod("getSummary").invoke(a);
					} catch (Exception ignore) {
					}
					String tags = null;
					try {
						tags = (String) a.getClass().getMethod("getTags").invoke(a);
					} catch (Exception ignore) {
					}
					if (title != null && title.toLowerCase().contains(needle))
						hit = true;
					else if (content != null && content.toLowerCase().contains(needle))
						hit = true;
					else if (summary != null && summary.toLowerCase().contains(needle))
						hit = true;
					else if (tags != null && tags.toLowerCase().contains(needle))
						hit = true;
				} catch (Exception ignore) {
				}
				if (hit)
					filtered.add(a);
			}
			list = filtered;
		}

		ModelAndView mav = new ModelAndView("board/listArticles");
		mav.addObject("articlesList", list);
		Map<String, Object> resultMap = new HashMap<String, Object>();
		resultMap.put("articlesList", list);
		resultMap.put("totalCount", (list != null) ? list.size() : 0);
		mav.addObject("resultMap", resultMap); // 예전 JSP 호환
		mav.addObject("cat", cat);
		mav.addObject("sub", sub);
		mav.addObject("curCat", cat);
		mav.addObject("curSub", sub);
		mav.addObject("q", q); // 현재 검색어 유지
		return mav;
	}

	/* ============================== 글쓰기 폼 ============================== */
	@RequestMapping(value = "/articleForm.do", method = RequestMethod.GET)
	public ModelAndView articleForm(HttpServletRequest request) {
		ModelAndView mav = new ModelAndView("board/articleForm");
		HttpSession s = request.getSession(false);
		if (s != null) {
			Object d = s.getAttribute("draftArticle");
			if (d instanceof Map) {
				mav.addObject("draft", d);
				Object n = ((Map) d).get("imageFileName");
				if (n instanceof String)
					mav.addObject("draftImageFileName", (String) n);
			}
		}
		return mav;
	}

	/* ============================== 글 등록 ============================== */
	@RequestMapping(value = "/addNewArticle.do", method = RequestMethod.POST)
	public ModelAndView addNewArticle(MultipartHttpServletRequest req, HttpServletResponse resp) throws Exception {
		req.setCharacterEncoding("utf-8");

		String loginId = resolveLoginId(req);
		if (isBlank(loginId))
			loginId = "anonymous";

		Map<String, Object> map = new HashMap<String, Object>();
		for (Enumeration<?> e = req.getParameterNames(); e.hasMoreElements();) {
			String name = (String) e.nextElement();
			map.put(name, req.getParameter(name));
		}
		map.put("id", loginId); // ★ 반드시 id 넣기

		MultipartFile imageFile = pickFirstFile(req);
		String imageFileName = saveToTempAndReturnFileName(imageFile);
		if (!isBlank(imageFileName))
			map.put("imageFileName", imageFileName);

		int articleNO = boardService.addNewArticle(map); // ★ 실제 PK 받기
		if (!isBlank(imageFileName))
			moveImageFromTemp(articleNO, imageFileName);

		return new ModelAndView("redirect:/board/viewArticle.do?articleNO=" + articleNO);
	}

	/* ============================== 글 보기 ============================== */
	@RequestMapping(value = "/viewArticle.do", method = RequestMethod.GET)
	public ModelAndView viewArticle(@RequestParam(value = "articleNO", required = false) Integer articleNO) {
		if (articleNO == null)
			return new ModelAndView("redirect:/board/listArticles.do");

		Object data = boardService.viewArticle(articleNO);
		ModelAndView mav = new ModelAndView("board/viewArticle");

		if (data instanceof ArticleVO) {
			mav.addObject("article", (ArticleVO) data);
		} else if (data instanceof Map) {
			@SuppressWarnings("unchecked")
			Map<String, Object> map = (Map<String, Object>) data;
			mav.addAllObjects(map);
			if (!map.containsKey("article")) {
				mav.addObject("articleNO", articleNO);
			}
		} else {
			mav.addObject("articleNO", articleNO);
		}

		mav.addObject("comments", boardService.listCommentsWithReplies(articleNO));
		mav.addObject("actionCommentAdd", "comment/add.do");
		mav.addObject("actionCommentReply", "comment/reply.do");
		return mav;
	}

	/* ---------- 내부 헬퍼(뷰 모델) ---------- */
	private Map<String, Object> toArticleViewModel(ArticleVO a) {
		Map<String, Object> m = new java.util.LinkedHashMap<>();
		m.put("id", getByAny(a, new String[] { "getArticleNO", "getId", "getNo" }, Integer.class, 0));
		m.put("title", nvl(getByAny(a, new String[] { "getTitle" }, String.class, null), "제목 없음"));
		m.put("authorName", nvl(
				getByAny(a, new String[] { "getWriter", "getId", "getAuthor", "getAuthorName" }, String.class, null),
				"익명"));
		java.util.Date published = getByAny(a, new String[] { "getWriteDate", "getCreatedAt", "getRegDate" },
				java.util.Date.class, null);
		m.put("publishedAt", published);
		Integer views = getByAny(a, new String[] { "getViewCnt", "getViews", "getHit", "getReadCount" }, Integer.class,
				null);
		m.put("views", views != null ? views : 0);
		String imageName = getByAny(a, new String[] { "getImageFileName", "getThumbnail", "getHero" }, String.class,
				null);
		m.put("heroUrl", imageName == null || imageName.isEmpty() ? null : ("/files/article/" + imageName));
		String content = getByAny(a, new String[] { "getContent", "getHtml", "getBody" }, String.class, null);
		m.put("html", content);
		m.put("images", java.util.Collections.emptyList());
		m.put("tags", java.util.Collections.emptyList());
		return m;
	}

	private Map<String, Object> minimumArticleVM(int articleNO) {
		Map<String, Object> m = new java.util.LinkedHashMap<>();
		m.put("id", articleNO);
		m.put("title", "게시글");
		m.put("authorName", "익명");
		m.put("publishedAt", null);
		m.put("views", 0);
		m.put("heroUrl", null);
		m.put("html", "");
		m.put("images", java.util.Collections.emptyList());
		m.put("tags", java.util.Collections.emptyList());
		return m;
	}

	@SuppressWarnings("unchecked")
	private static <T> T getByAny(Object bean, String[] getters, Class<T> type, T defVal) {
		for (String g : getters) {
			try {
				java.lang.reflect.Method m = bean.getClass().getMethod(g);
				Object v = m.invoke(bean);
				if (v != null && type.isAssignableFrom(v.getClass()))
					return (T) v;
				if (v != null && type == String.class)
					return (T) v.toString();
			} catch (NoSuchMethodException ignore) {
			} catch (Exception e) {
				// 필요 시 로깅
			}
		}
		return defVal;
	}

	private static String nvl(String s, String def) {
		return (s == null || s.trim().isEmpty()) ? def : s;
	}

	private static Object firstNonNull(Object... arr) {
		for (Object o : arr)
			if (o != null)
				return o;
		return null;
	}

	private static void ensureKeys(Map<String, Object> m) {
		m.putIfAbsent("id", 0);
		m.putIfAbsent("title", "게시글");
		m.putIfAbsent("authorName", "익명");
		m.putIfAbsent("publishedAt", null);
		m.putIfAbsent("views", 0);
		m.putIfAbsent("heroUrl", null);
		m.putIfAbsent("html", "");
		m.putIfAbsent("images", java.util.Collections.emptyList());
		m.putIfAbsent("tags", java.util.Collections.emptyList());
	}

	/*
	 * ============================== 글 수정 (GET/POST 호환)
	 * ==============================
	 */
	@RequestMapping(value = "/modArticleForm.do", method = RequestMethod.GET)
	public ModelAndView modArticleForm(HttpServletRequest request) throws Exception {
		String sNo = request.getParameter("articleNO");
		if (sNo == null || sNo.trim().isEmpty())
			return new ModelAndView("redirect:/board/listArticles.do");
		int articleNO = Integer.parseInt(sNo);

		Object data = boardService.viewArticle(articleNO);

		ModelAndView mav = new ModelAndView("board/modArticleForm"); // 수정 전용 JSP
		if (data instanceof ArticleVO) {
			mav.addObject("article", data);
		} else if (data instanceof Map) {
			@SuppressWarnings("unchecked")
			Map<String, Object> m = (Map<String, Object>) data;
			mav.addAllObjects(m);
		}
		mav.addObject("mode", "edit");
		mav.addObject("formAction", request.getContextPath() + "/board/modArticle.do"); // ★ 글쓰기 폼과 action 구분
		return mav;
	}

	@RequestMapping(value = "/modArticle.do", method = RequestMethod.POST)
	public ModelAndView modArticle(MultipartHttpServletRequest req) throws Exception {
		req.setCharacterEncoding("utf-8");

		String sNo = req.getParameter("articleNO");
		if (sNo == null || sNo.trim().isEmpty())
			return new ModelAndView("redirect:/board/listArticles.do");
		int articleNO = Integer.parseInt(sNo);

		Map<String, Object> map = new HashMap<String, Object>();
		for (Enumeration<?> e = req.getParameterNames(); e.hasMoreElements();) {
			String name = (String) e.nextElement();
			map.put(name, req.getParameter(name));
		}
		map.put("articleNO", articleNO);

		String loginId = resolveLoginId(req);
		if (!isBlank(loginId))
			map.put("id", loginId);

		MultipartFile imageFile = pickFirstFile(req);
		String newImage = saveToTempAndReturnFileName(imageFile);
		if (!isBlank(newImage))
			map.put("imageFileName", newImage); // 매퍼에서 null/empty 체크로 반영

		boardService.modArticle(map);

		if (!isBlank(newImage))
			moveImageFromTemp(articleNO, newImage);

		return new ModelAndView("redirect:/board/viewArticle.do?articleNO=" + articleNO);
	}

	/* ============================== 글 삭제 ============================== */
	@RequestMapping(value = { "/removeArticle.do", "/deleteArticle.do", "/article/removeArticle.do" }, method = {
			RequestMethod.GET, RequestMethod.POST })
	public ModelAndView removeArticle(HttpServletRequest request) throws Exception {
		String sNo = request.getParameter("articleNO");
		if (isBlank(sNo))
			return new ModelAndView("redirect:/board/listArticles.do");
		int articleNO = Integer.parseInt(sNo);

		boardService.removeArticle(articleNO);

		// 첨부 폴더 정리
		File dir = new File(getImageRepo() + File.separator + articleNO);
		if (dir.exists()) {
			File[] files = dir.listFiles();
			if (files != null)
				for (File f : files)
					try {
						f.delete();
					} catch (Exception ignore) {
					}
			try {
				dir.delete();
			} catch (Exception ignore) {
			}
		}
		return new ModelAndView("redirect:/board/listArticles.do");
	}

	/* ============================== 이미지 출력(공용) ============================== */
	@RequestMapping(value = "/img/{articleNO}/{fileName:.+}", method = RequestMethod.GET)
	public void serveImage(@PathVariable("articleNO") int articleNO, @PathVariable("fileName") String fileName,
			HttpServletResponse response) throws Exception {
		File file = new File(getImageRepo() + File.separator + articleNO, fileName);
		if (!file.exists() || !file.isFile()) {
			response.setStatus(HttpServletResponse.SC_NOT_FOUND);
			return;
		}
		String mime = servletContext.getMimeType(file.getName());
		if (isBlank(mime))
			mime = "application/octet-stream";
		response.setContentType(mime);
		response.setContentLengthLong(file.length());
		response.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");

		byte[] buf = new byte[8192];
		FileInputStream in = null;
		OutputStream out = null;
		try {
			in = new FileInputStream(file);
			out = response.getOutputStream();
			int len;
			while ((len = in.read(buf)) != -1) {
				out.write(buf, 0, len);
			}
			out.flush();
		} finally {
			try {
				if (in != null)
					in.close();
			} catch (Exception ignore) {
			}
		}
	}

	/*
	 * ============================== (구버전 호환) download.do
	 * ==============================
	 */
	@RequestMapping(value = "/download.do", method = RequestMethod.GET)
	public void download(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String sNo = request.getParameter("articleNO");
		String fileName = request.getParameter("imageFileName");
		if (isBlank(sNo) || isBlank(fileName)) {
			response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
			return;
		}
		serveImage(Integer.parseInt(sNo), fileName, response);
	}

	/* ============================== 댓글 ============================== */
	@RequestMapping(value = "/addComment.do", method = RequestMethod.POST)
	public String addComment(@RequestParam("articleNO") int articleNO, @RequestParam("content") String content,
			@RequestParam(value = "parentId", required = false) Long parentId,
			@RequestParam(value = "photos", required = false) java.util.List<MultipartFile> photos,
			javax.servlet.http.HttpSession session) {

		String writer = null;
		Object m = session.getAttribute("member");
		if (m != null) {
			try {
				writer = (String) m.getClass().getMethod("getId").invoke(m);
			} catch (Exception ignore) {
			}
		}

		com.myspring.myproject.board.dto.CommentDTO dto = new com.myspring.myproject.board.dto.CommentDTO();
		dto.setArticleNo(articleNO);
		dto.setContent(content);
		dto.setParentId(parentId);
		dto.setWriter(writer);

		commentService.addComment(dto); // 파일첨부 확장은 추후
		return "redirect:/board/viewArticle.do?articleNO=" + articleNO;
	}

	@RequestMapping(value = "/replyComment.do", method = RequestMethod.POST)
	public String replyComment(@RequestParam("articleNO") int articleNO, @RequestParam("content") String content,
			@RequestParam("parentId") Long parentId) {
		com.myspring.myproject.board.dto.CommentDTO dto = new com.myspring.myproject.board.dto.CommentDTO();
		dto.setArticleNo(articleNO);
		dto.setContent(content);
		dto.setParentId(parentId);
		commentService.addComment(dto);
		return "redirect:/board/viewArticle.do?articleNO=" + articleNO;
	}

	/*
	 * ============================== (추가) 임시저장 + 임시파일 이동 유틸
	 * ==============================
	 */

	/** 임시 디렉토리 결정: 외부(System property) 우선, 없으면 톰캣 내부(/board/img/temp) */
	private Path resolveTempDir(HttpServletRequest req) throws IOException {
		Path p = Paths.get(req.getServletContext().getRealPath("/board/img/temp"));
		Files.createDirectories(p);
		return p;
	}

	/**
	 * 임시저장: 제목/본문/태그/카테고리 + 이미지(옵션) - JSP의 <input type="file" name="imageFile"> 와
	 * name 일치 - 응답: { ok: true, imageFileName: "xxxx.jpg" }
	 */
	@RequestMapping(value = "/saveDraft.do", method = RequestMethod.POST)
	@ResponseBody
	public Map<String, Object> saveDraft(HttpServletRequest req,
			@RequestParam(value = "title", required = false) String title,
			@RequestParam(value = "cat", required = false) String cat,
			@RequestParam(value = "sub", required = false) String sub,
			@RequestParam(value = "content", required = false) String content,
			@RequestParam(value = "tags", required = false) String tags,
			@RequestParam(value = "imageFile", required = false) MultipartFile imageFile) {
		Map<String, Object> res = new HashMap<>();
		res.put("ok", false);

		try {
			// 1) 어떤 이름으로 왔는지 전부 수집(진단)
			List<Map<String, Object>> parts = new ArrayList<>();
			if (req instanceof MultipartHttpServletRequest) {
				MultipartHttpServletRequest mreq = (MultipartHttpServletRequest) req;
				for (Map.Entry<String, MultipartFile> e : mreq.getFileMap().entrySet()) {
					MultipartFile mf = e.getValue();
					Map<String, Object> p = new HashMap<>();
					p.put("field", e.getKey());
					p.put("origName", mf != null ? mf.getOriginalFilename() : null);
					p.put("size", (mf != null && !mf.isEmpty()) ? mf.getSize() : 0);
					parts.add(p);
				}
			}
			res.put("parts", parts);

			// 2) 기본 imageFile이 비었으면 첫 번째 파일로 대체(이름 불일치 방지)
			if ((imageFile == null || imageFile.isEmpty()) && req instanceof MultipartHttpServletRequest) {
				MultipartHttpServletRequest mreq = (MultipartHttpServletRequest) req;
				for (MultipartFile mf : mreq.getFileMap().values()) {
					if (mf != null && !mf.isEmpty()) {
						imageFile = mf;
						break;
					}
				}
			}

			String imageFileName = null;

			// 3) 파일이 실제로 들어왔는지 검사 + 저장
			if (imageFile != null && !imageFile.isEmpty()) {
				String orig = imageFile.getOriginalFilename();
				String ext = "";
				if (orig != null) {
					int dot = orig.lastIndexOf('.');
					if (dot >= 0)
						ext = orig.substring(dot);
				}
				String saveName = System.currentTimeMillis() + "-" + Math.abs((orig + UUID.randomUUID()).hashCode())
						+ ext;

				Path tempDir = resolveTempDir(req); // ★ 임시 저장 경로(네 프로젝트의 현재 정책 그대로 사용)
				Files.createDirectories(tempDir);
				Path dst = tempDir.resolve(saveName);
				imageFile.transferTo(dst.toFile()); // 저장

				imageFileName = saveName;
				res.put("saved", dst.toString());
			} else {
				res.put("reason", "no_file_in_request"); // ★ 파일이 아예 안 왔을 때
			}

			// 4) 세션 임시본 업데이트(제목/본문/이미지)
			HttpSession session = req.getSession();
			@SuppressWarnings("unchecked")
			Map<String, Object> draft = (Map<String, Object>) session.getAttribute("draftArticle");
			if (draft == null)
				draft = new HashMap<>();
			if (title != null)
				draft.put("title", title);
			if (cat != null)
				draft.put("cat", cat);
			if (sub != null)
				draft.put("sub", sub);
			if (content != null)
				draft.put("content", content);
			if (tags != null)
				draft.put("tags", tags);
			if (imageFileName != null)
				draft.put("imageFileName", imageFileName);
			session.setAttribute("draftArticle", draft);

			res.put("imageFileName", imageFileName);
			res.put("ok", true);
			return res;
		} catch (Exception ex) {
			res.put("error", ex.getClass().getSimpleName() + ": " + ex.getMessage());
			return res;
		}
	}

	@RequestMapping(value = "/img/temp/{fileName:.+}", method = RequestMethod.GET)
	public void serveTemp(@PathVariable String fileName, HttpServletRequest req, HttpServletResponse resp)
			throws Exception {
		File f = resolveTempDir(req).resolve(fileName).toFile(); // ★ 임시 저장 위치와 동일
		if (!f.exists() || !f.isFile()) {
			resp.setStatus(404);
			return;
		}
		String mime = servletContext.getMimeType(f.getName());
		if (mime == null || mime.trim().isEmpty())
			mime = "application/octet-stream";
		resp.setContentType(mime);
		resp.setContentLengthLong(f.length());
		try (FileInputStream in = new FileInputStream(f); OutputStream out = resp.getOutputStream()) {
			byte[] buf = new byte[8192];
			int len;
			while ((len = in.read(buf)) != -1)
				out.write(buf, 0, len);
		}
	}

	/** 최종 등록/수정 시: temp 이미지 → 본문 폴더로 이동 */
	private void moveDraftImageIfExists(HttpServletRequest req, String draftImageFileName, long articleNO)
			throws IOException {
		if (draftImageFileName == null || draftImageFileName.isEmpty())
			return;

		Path tempDir = resolveTempDir(req); // 임시 저장소
		Path src = tempDir.resolve(draftImageFileName);
		if (!Files.exists(src))
			return;

		Path articleDir = Paths.get(getImageRepo(), String.valueOf(articleNO)); // 최종 저장소
		Files.createDirectories(articleDir);

		Path dst = articleDir.resolve(draftImageFileName);
		Files.move(src, dst, StandardCopyOption.REPLACE_EXISTING);
	}

	/** 리스트 화면(JSP) — 페이지용 */
	@RequestMapping(value = "/listArticlesPage.do", method = RequestMethod.GET)
	public String listArticlesPage() {
		// /WEB-INF/views/board/listArticlesJsonView.jsp
		return "board/listArticlesJsonView";
	}

	/** 리스트 데이터(JSON) — AJAX용 */
	@RequestMapping(value = "/listArticlesJson.do", method = RequestMethod.GET)
	@ResponseBody
	// CORS가 필요할 때만 아래 주석 해제해서 사용(다른 출처에서 호출한다면)
	// @CrossOrigin(
	// origins = {"http://localhost:8080","https://gusdnd2346.cafe24.com"},
	// allowCredentials = "true"
	// )
	public List<ArticleVO> listArticlesJson(@RequestParam Map<String, String> params) {
		Map<String, Object> cond = new HashMap<String, Object>();
		putIfNotBlank(cond, "cat", params.get("cat"));
		putIfNotBlank(cond, "sub", params.get("sub"));
		putIfNotBlank(cond, "q", params.get("q"));

		int page = toInt(params.get("page"), 1);
		int size = toInt(params.get("size"), 20);
		cond.put("offset", (page - 1) * size);
		cond.put("limit", size);

		return boardService.listArticles(cond); // ← 서비스 시그니처에 맞춤
	}

	/** 서버사이드 렌더링이 필요할 때 쓰는 선택 메서드(필요 없으면 삭제) */
	@RequestMapping(value = "/listArticlesView.do", method = RequestMethod.GET)
	public String listArticlesView(@RequestParam Map<String, String> params, Model model) {
		Map<String, Object> cond = new HashMap<String, Object>();
		putIfNotBlank(cond, "cat", params.get("cat"));
		putIfNotBlank(cond, "sub", params.get("sub"));
		putIfNotBlank(cond, "q", params.get("q"));

		int page = toInt(params.get("page"), 1);
		int size = toInt(params.get("size"), 20);
		cond.put("offset", (page - 1) * size);
		cond.put("limit", size);

		model.addAttribute("articles", boardService.listArticles(cond));
		return "board/listArticles"; // 필요 시 실제 JSP 이름으로 변경
	}

	// ===== helpers =====
	private static int toInt(String s, int def) {
		try {
			return (s == null || s.trim().isEmpty()) ? def : Integer.parseInt(s.trim());
		} catch (NumberFormatException e) {
			return def;
		}
	}

	private static void putIfPresent(Map<String, Object> m, String k, Object v) {
		if (v != null) {
			m.put(k, v);
		}
	}
}