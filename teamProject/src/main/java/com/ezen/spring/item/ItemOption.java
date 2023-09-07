package com.ezen.spring.item;

import org.springframework.stereotype.Component;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Component
@NoArgsConstructor
@AllArgsConstructor
@Setter
@Getter
public class ItemOption 
{
	private int itemOptionNum;
	private int itemOptionParentsNum;
	private String itemOptionName;
	private String itemOptionValue;
}
