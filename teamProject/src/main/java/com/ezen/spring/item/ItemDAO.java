package com.ezen.spring.item;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;

import lombok.extern.slf4j.Slf4j;

@Repository("itemDAO")
@Slf4j
public class ItemDAO {

	@Autowired
	@Qualifier("itemMapper")
	private ItemMapper itemMapper;

	@Transactional
	public boolean addItem(Item item)
	{
		boolean iSaved = itemMapper.addAndGetKey(item)>0;
		//아이템을 DB에 저장한 후 item.getItemNum을 하면 아이템 번호가 나옴.
		int parentsNum = item.getItemNum();
		
		List<ItemAttach> list = item.getAttList();
		for(int i=0;i<list.size();i++) {
			list.get(i).setItemAttachParentsNum(parentsNum);
			//그 번호를 ItemAttach의 parentsNum으로 set 해줌.
		}
		boolean aSaved = false;
		
		if(item.getAttList().size()>0) { //첨부파일이 없어도 글 저장이 가능하도록
			aSaved = itemMapper.addAttach(item.getAttList())>0;
		}else {
			aSaved = true;
		}
		
		// 아이템 옵션을 저장
		List<ItemOption> optList = item.getOptList();
		boolean oSaved = true; // 기본적으로 옵션이 없는 경우로 초기화

		if (optList != null && !optList.isEmpty()) { // 옵션 리스트가 비어있지 않으면
		    for (int i = 0; i < optList.size(); i++) {
		        ItemOption option = optList.get(i);
		        option.setItemOptionParentsNum(parentsNum);
		    }

		    oSaved = itemMapper.addOption(optList) > 0;
		}
		
		return iSaved && aSaved && oSaved;
	}

	@Transactional
	public List<Map<String, String>> getItem(int itemNum)
	{
		List<Map<String,String>> list = itemMapper.getItem(itemNum);
		return list;
	}

	public PageInfo<Map> getList(int pageNum) {
		PageHelper.startPage(pageNum, 10);
		PageInfo<Map> pageInfo = new PageInfo<>(itemMapper.getList());
		return pageInfo;
	}

	public boolean delete(int itemNum) {
		return itemMapper.delItem(itemNum)>0;
	}

	public boolean update(Item item) {
		return itemMapper.update(item)>0;
	}

	public PageInfo<Map> getCategoryList(int pageNum, String category) {
		PageHelper.startPage(pageNum, 10);
		PageInfo<Map> pageInfo = new PageInfo<>(itemMapper.getCategoryList(category));
		return pageInfo;
	}

	public boolean deleteAttach(int itemAttachNum) {
		return itemMapper.deleteAttach(itemAttachNum)>0;
	}

	public boolean addAttach(List<ItemAttach> attList) {
		return itemMapper.addAttach(attList)>0;
	}
	
	public List<Map<String, String>> getTopItems(int limit) { //best top 10 가져오기 
        return itemMapper.getTopItems(limit);
    }

}
