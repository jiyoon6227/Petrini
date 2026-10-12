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
