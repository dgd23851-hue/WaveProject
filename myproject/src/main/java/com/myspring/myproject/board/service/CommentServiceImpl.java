package com.myspring.myproject.board.service;

import java.util.List;
import javax.sql.DataSource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.myspring.myproject.board.dto.CommentDTO;
import com.myspring.myproject.board.mapper.CommentMapper;

@Service
@Transactional
public class CommentServiceImpl implements CommentService {

	@Autowired
	private CommentMapper commentMapper;
	@Autowired
	private DataSource dataSource; // (선택) 디버그용

	public CommentServiceImpl() {
	}

	@Override
	public List<CommentDTO> listByArticle(Long articleId) throws DataAccessException {
		return commentMapper.listByArticle(articleId);
	}

	@Override
	public void addComment(CommentDTO dto) {
	    if (dto == null) throw new IllegalArgumentException("dto is null");
	    if (dto.getArticleId() == null) throw new IllegalArgumentException("articleId is null");

	    // 디버그: 실제 값 확인
	    System.out.println("[COMMENT/DEBUG] articleId=" + dto.getArticleId()
	        + " (" + dto.getArticleId().getClass().getName() + "), writer=" + dto.getWriter());

	    // ★ 반드시 Long만
	    Long key = dto.getArticleId();               // ← 절대 writer 등 문자열 넣지 말기
	    Long resolvedId = commentMapper.resolveArticleId(key);
	    if (resolvedId == null) throw new IllegalArgumentException("Article not found (idOrNo=" + key + ")");
	    dto.setArticleId(resolvedId);

	    if (commentMapper.existsArticle(dto.getArticleId()) == 0)
	        throw new IllegalArgumentException("Article not found after resolve: id=" + dto.getArticleId());

	    int n = commentMapper.insert(dto);
	    if (n != 1) throw new IllegalStateException("Insert affected=" + n);
	}

	@Override
	public CommentDTO findById(Long id) throws DataAccessException {
		return commentMapper.findById(id);
	}

	@Override
	public void deleteById(Long id) throws DataAccessException {
		commentMapper.deleteById(id);
	}

	@Override
	public void deleteByArticle(Long articleId) throws DataAccessException {
		List<CommentDTO> list = commentMapper.listByArticle(articleId);
		if (list != null)
			for (CommentDTO c : list)
				if (c.getId() != null)
					commentMapper.deleteById(c.getId());
	}
}
