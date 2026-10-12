package com.petcare.petcare.main.section.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.main.section.vo.MainCommunityPreviewVO;
import com.petcare.petcare.main.section.vo.MainPopularProductVO;

/*
 *  MainSectionMapper.xml 사용
 */
@Mapper
public interface MainSectionMapper {

    List<MainPopularProductVO> selectPopularProducts(@Param("limit") int limit);

    List<MainCommunityPreviewVO> selectCommunityPreview(@Param("limit") int limit);
}
