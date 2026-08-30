/**
 * 역할: 커뮤니티 좋아요 DB 접근 (MyBatis interface)
 *
 * - 박유정 / 2026-07-09
 *
 * XML: resources/mybatis/mapper/community/reaction/CommunityReactionMapper.xml
 *
 * 쿼리
 * - countLikeByPostAndMember   좋아요 존재 여부
 * - insertLike                 TB_POST_LIKE INSERT (SEQ_TB_POST_LIKE)
 * - deleteLikeByPostAndMember  좋아요 취소 DELETE
 *
 * 참고 테이블
 * - TB_POST_LIKE
 *
 * SQL은 XML에만 작성
 */

package com.petcare.petcare.community.reaction.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.community.reaction.vo.CommunityReactionVO;

@Mapper
public interface CommunityReactionMapper {

    int countLikeByPostAndMember(
            @Param("postId") long postId,
            @Param("memberNo") long memberNo);

    int insertLike(CommunityReactionVO vo);

    int deleteLikeByPostAndMember(
            @Param("postId") long postId,
            @Param("memberNo") long memberNo);
}
