package com.myspring.myproject.common.file;

import java.io.*;
import java.net.URLConnection;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/board")
public class FileDownloadController {

    @RequestMapping("/download.do")
    public void download(@RequestParam("imageFileName") String imageFileName,
                         @RequestParam("articleNO") int articleNO,
                         HttpServletRequest request,
                         HttpServletResponse response) throws IOException {

        String repo = getImageRepo(request);
        if (repo == null || repo.trim().length() == 0) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "image repo not configured");
            return;
        }

        File imageFile = new File(new File(repo, String.valueOf(articleNO)), imageFileName);

        if (!imageFile.exists() || !imageFile.isFile()) {
            // 필요하면 placeholder로 리다이렉트 (정적 리소스가 있을 때)
            // response.sendRedirect(request.getContextPath() + "/resources/img/no-image.png");
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String mime = URLConnection.guessContentTypeFromName(imageFile.getName());
        if (mime == null) mime = "application/octet-stream";

        response.setContentType(mime);
        response.setHeader("Content-Length", String.valueOf(imageFile.length()));
        // 캐시 헤더(선택)
        response.setHeader("Cache-Control", "public, max-age=31536000");

        try (BufferedInputStream in = new BufferedInputStream(new FileInputStream(imageFile));
             BufferedOutputStream out = new BufferedOutputStream(response.getOutputStream())) {

            byte[] buf = new byte[8192];
            int read;
            while ((read = in.read(buf)) != -1) {
                out.write(buf, 0, read);
            }
            out.flush();
        }
    }

    private String getImageRepo(HttpServletRequest request) {
        String repo = request.getServletContext().getInitParameter("articleImageRepo");
        // 경로 끝에 구분자가 없어도 동작하도록 normalize
        if (repo != null && repo.endsWith(File.separator)) {
            repo = repo.substring(0, repo.length() - 1);
        }
        return repo;
    }
}
