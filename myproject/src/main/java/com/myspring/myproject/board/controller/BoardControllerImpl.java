package com.myspring.myproject.board.controller;

import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.security.Principal;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.myspring.myproject.board.service.BoardService;
import com.myspring.myproject.board.vo.ArticleVO;

@Controller
@RequestMapping("/board")
public class BoardControllerImpl {

	@Autowired
	private BoardService boardService;
	@Autowired
	private ServletContext servletContext;

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

	/** 업로드 베이스 경로 (web.xml의 context-param: articleImageRepo 우선) */
	private String getImageRepo() {
		String path = servletContext.getInitParameter("articleImageRepo");
		if (isBlank(path)) {
			// 로컬(Windows) 기본값 vs 카페24(Linux) 기본값
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

			String from;
			v = session.getAttribute("member");
			from = getIdByReflection(v);
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

	/** MemberVO 등에 getId()가 있으면 꺼낸다 */
	private String getIdByReflection(Object obj) {
		if (obj == null)
			return null;
		try {
			return (String) obj.getClass().getMethod("getId").invoke(obj);
		} catch (Exception ignore) {
			return null;
		}
	}

	/*
	 * ============================== 목록 ==============================
	 */
	@RequestMapping(value = "/listArticles.do", method = RequestMethod.GET)
	public ModelAndView listArticles(HttpServletRequest request) throws Exception {
		String cat = trim(request.getParameter("cat"));
		String sub = trim(request.getParameter("sub"));
		String page = trim(request.getParameter("page"));
		String size = trim(request.getParameter("size"));

		Map<String, Object> searchMap = new HashMap<String, Object>();
		putIfNotBlank(searchMap, "cat", cat);
		putIfNotBlank(searchMap, "category", cat); // 매퍼 별칭 호환
		putIfNotBlank(searchMap, "sub", sub);
		putIfNotBlank(searchMap, "subcategory", sub);
		if (!isBlank(page))
			searchMap.put("page", Integer.parseInt(page));
		if (!isBlank(size))
			searchMap.put("size", Integer.parseInt(size));

		List<ArticleVO> list = boardService.listArticles(searchMap);

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
		return mav;
	}

	/*
	 * ============================== 글쓰기 폼 ==============================
	 */
	@RequestMapping(value = "/articleForm.do", method = RequestMethod.GET)
	public ModelAndView articleForm(HttpServletRequest request) {
		ModelAndView mav = new ModelAndView("board/articleForm");
		mav.addObject("cat", trim(request.getParameter("cat")));
		mav.addObject("sub", trim(request.getParameter("sub")));
		return mav;
	}

	/*
	 * ============================== 글 등록 (완료 후 해당 글 보기로 리다이렉트)
	 * ==============================
	 */
	@RequestMapping(value = "/addNewArticle.do", method = RequestMethod.POST)
	public ModelAndView addNewArticle(MultipartHttpServletRequest req, HttpServletResponse resp) throws Exception {
		req.setCharacterEncoding("utf-8");

		// 로그인 확인 & id 주입 (DB NOT NULL 보호: 최후엔 anonymous)
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

		// 컨텍스트 자동부착되는 redirect:/ 사용 → /myproject 중복 제거
		return new ModelAndView("redirect:/board/viewArticle.do?articleNO=" + articleNO);
	}

	/*
	 * ============================== 글 보기 ==============================
	 */
	@RequestMapping(value = "/viewArticle.do", method = RequestMethod.GET)
	public ModelAndView viewArticle(HttpServletRequest request) throws Exception {
	    String sNo = request.getParameter("articleNO");
	    if (isBlank(sNo)) return new ModelAndView("redirect:/board/listArticles.do");
	    int articleNO = Integer.parseInt(sNo);

	    Object data = boardService.viewArticle(articleNO);

	    ModelAndView mav = new ModelAndView("board/viewArticle");

	    // 1) ArticleVO -> 뷰 모델(Map)로 변환
	    if (data instanceof ArticleVO) {
	        Map<String, Object> articleVM = toArticleViewModel((ArticleVO) data);
	        mav.addObject("article", articleVM);

	    // 2) Map이 온 경우도 'article' 키를 보장
	    } else if (data instanceof Map) {
	        @SuppressWarnings("unchecked")
	        Map<String, Object> fromSvc = (Map<String, Object>) data;
	        mav.addAllObjects(fromSvc);

	        Object a = firstNonNull(
	            fromSvc.get("article"),
	            fromSvc.get("articleVO"),
	            fromSvc.get("vo"),
	            fromSvc.get("data")
	        );

	        if (a instanceof ArticleVO) {
	            mav.addObject("article", toArticleViewModel((ArticleVO) a));
	        } else if (a instanceof Map) {
	            // 이미 article이 Map이면 그대로 쓰되, 필수 키가 없으면 기본값 채움
	            @SuppressWarnings("unchecked")
	            Map<String, Object> articleMap = (Map<String, Object>) a;
	            ensureKeys(articleMap);
	            mav.addObject("article", articleMap);
	        } else if (!mav.getModel().containsKey("article")) {
	            // 최소 안전 기본값
	            mav.addObject("article", minimumArticleVM(articleNO));
	        }

	    // 3) 알 수 없는 타입 → 최소 안전 기본값
	    } else {
	        mav.addObject("article", minimumArticleVM(articleNO));
	    }

	    // 댓글 리스트 주입(서비스명은 프로젝트에 맞게 바꿔줘)
	    try {
	        List<?> comments = boardService.listCommentsWithReplies(articleNO);
	        mav.addObject("comments", comments != null ? comments : java.util.Collections.emptyList());
	    } catch (Throwable ignore) {
	        mav.addObject("comments", java.util.Collections.emptyList());
	    }

	    return mav;
	}
	
	/* ----------  헬퍼들 ---------- */
	private Map<String, Object> toArticleViewModel(ArticleVO a) {
	    Map<String, Object> m = new java.util.LinkedHashMap<>();
	    // id / 번호
	    m.put("id",  getByAny(a, new String[]{"getArticleNO","getId","getNo"}, Integer.class, 0));
	    // 제목
	    m.put("title", nvl(getByAny(a, new String[]{"getTitle"}, String.class, null), "제목 없음"));
	    // 작성자 표시명(authorName): writer, id, author 순으로 시도
	    m.put("authorName", nvl(getByAny(a, new String[]{"getWriter","getId","getAuthor","getAuthorName"}, String.class, null), "익명"));
	    // 작성일(publishedAt): writeDate, createdAt, regDate 순
	    java.util.Date published = getByAny(a, new String[]{"getWriteDate","getCreatedAt","getRegDate"}, java.util.Date.class, null);
	    m.put("publishedAt", published);
	    // 조회수(views): viewCnt, views, hit, readCount 순
	    Integer views = getByAny(a, new String[]{"getViewCnt","getViews","getHit","getReadCount"}, Integer.class, null);
	    m.put("views", views != null ? views : 0);
	    // 대표 이미지 -> heroUrl
	    String imageName = getByAny(a, new String[]{"getImageFileName","getThumbnail","getHero"}, String.class, null);
	    m.put("heroUrl", imageName == null || imageName.isEmpty() ? null : ("/files/article/" + imageName));
	    // 본문 -> html 로 내려서 JSP에서 바로 출력 (XSS 필터링은 서비스단에서)
	    String content = getByAny(a, new String[]{"getContent","getHtml","getBody"}, String.class, null);
	    m.put("html", content);
	    // 옵션 필드들(없어도 JSP는 문제 없음)
	    m.put("images", java.util.Collections.emptyList());
	    m.put("tags",   java.util.Collections.emptyList());
	    return m;
	}

	private Map<String,Object> minimumArticleVM(int articleNO){
	    Map<String,Object> m = new java.util.LinkedHashMap<>();
	    m.put("id", articleNO);
	    m.put("title", "게시글");
	    m.put("authorName", "익명");
	    m.put("publishedAt", null);
	    m.put("views", 0);
	    m.put("heroUrl", null);
	    m.put("html", "");
	    m.put("images", java.util.Collections.emptyList());
	    m.put("tags",   java.util.Collections.emptyList());
	    return m;
	}

	@SuppressWarnings("unchecked")
	private static <T> T getByAny(Object bean, String[] getters, Class<T> type, T defVal) {
	    for (String g : getters) {
	        try {
	            java.lang.reflect.Method m = bean.getClass().getMethod(g);
	            Object v = m.invoke(bean);
	            if (v != null && type.isAssignableFrom(v.getClass())) return (T) v;
	            if (v != null && type == String.class) return (T) v.toString();
	        } catch (NoSuchMethodException ignore) {
	        } catch (Exception e) {
	            // 로깅 원하면 추가
	        }
	    }
	    return defVal;
	}

	private static String nvl(String s, String def){ return (s == null || s.trim().isEmpty()) ? def : s; }

	private static Object firstNonNull(Object... arr){
	    for(Object o: arr) if(o != null) return o;
	    return null;
	}

	/** Map으로 기사 내려온 경우, JSP 필수 키 최소 보장 */
	private static void ensureKeys(Map<String,Object> m){
	    m.putIfAbsent("id", 0);
	    m.putIfAbsent("title", "게시글");
	    m.putIfAbsent("authorName", "익명");
	    m.putIfAbsent("publishedAt", null);
	    m.putIfAbsent("views", 0);
	    m.putIfAbsent("heroUrl", null);
	    m.putIfAbsent("html", "");
	    m.putIfAbsent("images", java.util.Collections.emptyList());
	    m.putIfAbsent("tags",   java.util.Collections.emptyList());
	}

	/*
	 * ============================== 글 수정 (GET/POST 호환)
	 * ==============================
	 */
	// 수정 폼 열기 (GET)
	@RequestMapping(value="/modArticleForm.do", method=RequestMethod.GET)
	public ModelAndView modArticleForm(HttpServletRequest request) throws Exception {
	    String sNo = request.getParameter("articleNO");
	    if (sNo == null || sNo.trim().isEmpty()) {
	        return new ModelAndView("redirect:/board/listArticles.do");
	    }
	    int articleNO = Integer.parseInt(sNo);

	    // 기존 글 불러오기 (ArticleVO 또는 Map 반환 지원)
	    Object data = boardService.viewArticle(articleNO);

	    ModelAndView mav = new ModelAndView("board/modArticleForm"); // 수정 전용 JSP
	    if (data instanceof ArticleVO) {
	        mav.addObject("article", data);
	    } else if (data instanceof Map) {
	        @SuppressWarnings("unchecked")
	        Map<String,Object> m = (Map<String,Object>) data;
	        mav.addAllObjects(m);
	    }
	    mav.addObject("mode", "edit");
	    // 폼 action을 명확히 지정(기본이 addNewArticle로 가는 문제 방지)
	    mav.addObject("formAction", request.getContextPath() + "/board/modArticle.do");
	    return mav;
	}

	// 수정 저장 (POST)
	@RequestMapping(value="/modArticle.do", method=RequestMethod.POST)
	public ModelAndView modArticle(MultipartHttpServletRequest req) throws Exception {
	    req.setCharacterEncoding("utf-8");

	    // 글번호 필수
	    String sNo = req.getParameter("articleNO");
	    if (sNo == null || sNo.trim().isEmpty()) {
	        return new ModelAndView("redirect:/board/listArticles.do");
	    }
	    int articleNO = Integer.parseInt(sNo);

	    // 파라미터 수집
	    Map<String,Object> map = new HashMap<String,Object>();
	    for (Enumeration<?> e = req.getParameterNames(); e.hasMoreElements();) {
	        String name = (String) e.nextElement();
	        map.put(name, req.getParameter(name));
	    }
	    map.put("articleNO", articleNO);

	    // 로그인 아이디 들어가야 권한 체크/갱신 되는 매퍼라면 주입
	    String loginId = resolveLoginId(req);
	    if (loginId != null && loginId.trim().length() > 0) {
	        map.put("id", loginId);
	    }

	    // 새 파일이 올라온 경우에만 교체
	    MultipartFile imageFile = pickFirstFile(req); // imageFile / imageFileName 둘 다 대응
	    String newImage = saveToTempAndReturnFileName(imageFile);
	    if (newImage != null && newImage.trim().length() > 0) {
	        map.put("imageFileName", newImage); // mapper에서 <if test="imageFileName != null and imageFileName != ''"> 로 처리
	    }

	    // DB 업데이트
	    boardService.modArticle(map);

	    // 파일 이동(새 파일이 있는 경우만)
	    if (newImage != null && newImage.trim().length() > 0) {
	        moveImageFromTemp(articleNO, newImage);
	    }

	    // 수정 후 해당 글 보기로 이동
	    return new ModelAndView("redirect:/board/viewArticle.do?articleNO=" + articleNO);
	}

	/*
	 * ============================== 글 삭제 (GET/POST 호환)
	 * ==============================
	 */
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

	/*
	 * ============================== 이미지 출력 (공용 엔드포인트) <img
	 * src="${ctx}/board/img/${no}/${file}"> ==============================
	 */
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
	 * ============================== (구버전 호환) download.do 방식도 유지
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
}
