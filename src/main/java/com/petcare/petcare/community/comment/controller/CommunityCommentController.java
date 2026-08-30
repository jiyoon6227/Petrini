/**
 * 역할: 커뮤니티 댓글 API 처리 → Service 호출
 *
 * - 박유정 / 2026-07-09~10
 *
 * [현재 구조]
 * - 댓글 등록은 give/report 와 동일하게 CommunityPostController 에서 처리
 *   POST /community/comment → communityCommentService.insertComment()
 * - 이 클래스는 대댓글·수정·삭제 API 분리 시 사용 예정
 *
 * 연결
 * - Service: CommunityCommentService
 * - 화면: community/detail.jsp, give/report/detail.jsp
 *
 * 참고 테이블
 * - TB_POST_COMMENT (SEQ_TB_POST_COMMENT)
 */

package com.petcare.petcare.community.comment.controller;

public class CommunityCommentController {}
