---
--- Author: Administrator
--- DateTime: 2023-09-18 09:31
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local JumboCactpotVM = require("Game/JumboCactpot/JumboCactpotVM")
local JumboCactpotMgr = require("Game/JumboCactpot/JumboCactpotMgr")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local AudioUtil = require("Utils/AudioUtil")
---@class JumboCactpotRewardResumeView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field BtnLeft UFButton
---@field BtnRight UFButton
---@field PopUpBG CommonPopUpBGView
---@field TableViewMiddle UTableView
---@field TableViewdian UTableView
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotRewardResumeView = LuaClass(UIView, true)

function JumboCactpotRewardResumeView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.PopUpBG = nil
	--self.TableViewMiddle = nil
	--self.TableViewdian = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotRewardResumeView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotRewardResumeView:OnInit()
    self.ResumeMiddleAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewMiddle, nil, true)
    self.ResumeDianAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewdian, nil, true)

	self.Binders = {
		{ "ResumeMiddleList", UIBinderUpdateBindableList.New(self, self.ResumeMiddleAdapter)},
		{ "ResumeDianList", UIBinderUpdateBindableList.New(self, self.ResumeDianAdapter)},
	}

end

function JumboCactpotRewardResumeView:OnDestroy()

end

function JumboCactpotRewardResumeView:OnShow()
	self:UpdataBtnVisible()
	self:SubViewOnShow()
	AudioUtil.LoadAndPlayUISound(JumboCactpotDefine.JumboUIAudioPath.LottoryRecord)

	self.TextTitle:SetText(_G.LSTR(240092)) -- 一等奖公告栏
end

function JumboCactpotRewardResumeView:OnHide()
	JumboCactpotMgr.ResumSlideData = {}
	JumboCactpotMgr.bClickBtnWaitOpen = false
end

function JumboCactpotRewardResumeView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnLeft, self.OnBtnLeftClick)
	UIUtil.AddOnClickedEvent(self, self.BtnRight, self.OnBtnRightClick)

	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnBtnCloseClick)
end

function JumboCactpotRewardResumeView:OnRegisterGameEvent()

end

function JumboCactpotRewardResumeView:OnRegisterBinder()
    self:RegisterBinders(JumboCactpotVM, self.Binders)
end

function JumboCactpotRewardResumeView:OnBtnLeftClick()
	local DianSelectIndex = JumboCactpotMgr.DianSelectIndex
	JumboCactpotMgr:SelectLastDianItem(DianSelectIndex)
	self:UpdataBtnVisible()
	local NeedList = JumboCactpotMgr:UpdateNeedList()
    JumboCactpotVM:UpdateList(JumboCactpotVM.ResumeMiddleList, NeedList)
	self:SubViewOnShow()
end

function JumboCactpotRewardResumeView:OnBtnRightClick()
	local DianSelectIndex = JumboCactpotMgr.DianSelectIndex
	JumboCactpotMgr:SelectNextDianItem(DianSelectIndex)
	self:UpdataBtnVisible()
	local NeedList = JumboCactpotMgr:UpdateNeedList()
    JumboCactpotVM:UpdateList(JumboCactpotVM.ResumeMiddleList, NeedList)
	self:SubViewOnShow()
end

function JumboCactpotRewardResumeView:SubViewOnShow()
	local SubViews = self.ResumeMiddleAdapter.SubViews
	for _, v in pairs(SubViews) do
		local Elem = v
		Elem:OnShow()
	end
end


function JumboCactpotRewardResumeView:OnBtnCloseClick()
	self:Hide()
end

function JumboCactpotRewardResumeView:UpdataBtnVisible()
	local ResumeDianList = JumboCactpotVM.ResumeDianList
	local AllDianVMs = ResumeDianList:GetItems()

	if #AllDianVMs == 0 then
		UIUtil.SetIsVisible(self.BtnLeft, false)
		UIUtil.SetIsVisible(self.BtnRight, false)
		return
	end

	for i, v in pairs(AllDianVMs) do
		local Elem = v
		if Elem.bIsSelect then
			JumboCactpotMgr.DianSelectIndex = i
		end
	end
	local DianSelectIndex = JumboCactpotMgr.DianSelectIndex
	local bShowLeftBtn, bShowRightBtn = false, false
	local CurDianCount = #AllDianVMs
	if DianSelectIndex == 1 then
		bShowLeftBtn = false
		bShowRightBtn = true
	elseif DianSelectIndex == CurDianCount then
		bShowLeftBtn = true
		bShowRightBtn = false
	elseif DianSelectIndex == 2 then
		bShowLeftBtn = true
		bShowRightBtn = true
	end
	UIUtil.SetIsVisible(self.BtnLeft, bShowLeftBtn, bShowLeftBtn)
	UIUtil.SetIsVisible(self.BtnRight, bShowRightBtn, bShowRightBtn)
end

return JumboCactpotRewardResumeView