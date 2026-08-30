package com.petcare.petcare.file.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.petcare.petcare.file.vo.FileVO;

@Mapper
public interface FileMapper {
    public int insertFile(FileVO vo) throws Exception;
    
    public FileVO selectFile(Long fileId) throws Exception;
    public List<FileVO> selectFileList(FileVO vo) throws Exception;  // refType + refId로 조회
    
    public int deleteFile(Long fileId) throws Exception; 
    public int deleteFilesByRefId(FileVO vo) throws Exception;  
}
