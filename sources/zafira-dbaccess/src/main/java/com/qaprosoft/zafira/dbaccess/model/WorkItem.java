package com.qaprosoft.zafira.dbaccess.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;

@JsonInclude(Include.NON_NULL)
public class WorkItem extends AbstractEntity 
{
	private static final long serialVersionUID = 5440580857483390564L;
	
	private String jiraId;
	
	public WorkItem()
	{
	}

	public WorkItem(String jiraId)
	{
		this.jiraId = jiraId;
	}

	public String getJiraId()
	{
		return jiraId;
	}

	public void setJiraId(String jiraId)
	{
		this.jiraId = jiraId;
	}
}
