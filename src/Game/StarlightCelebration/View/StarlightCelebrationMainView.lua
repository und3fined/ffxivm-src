---
--- Author: Administrator
--- DateTime: 2025-08-11 10:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local StarlightCelebrationMainVM = require("Game/StarlightCelebration/VM/StarlightCelebrationMainVM")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OpsSeasonActivityDefine = require("Game/Ops/OpsSeasonActivityDefine")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local LSTR = _G.LSTR
local OpsSeasonActivityMgr
---@class StarlightCelebrationMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityTime OpsActivityTimeItemView
---@field BtnGreetingCard UFButton
---@field BtnNewYearsEve UFButton
---@field BtnNightGift UFButton
---@field BtnRhythmGame UFButton
---@field BtnShop UFButton
---@field BtnTask UFButton
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field ImgCheck UFImage
---@field ImgLock UFImage
---@field RedDot_1 CommonRedDotView
---@field RedDot_2 CommonRedDotView
---@field RedDot_3 CommonRedDotView
---@field RedDot_4 CommonRedDotView
---@field ShareTips OpsActivityShareTipsItemView
---@field StarlightCelebrationTransition_UIBP StarlightCelebrationTransitionView
---@field TextDate_1 UFTextBlock
---@field TextGreetingCard UFTextBlock
---@field TextNewYearsEve UFTextBlock
---@field TextNightGift UFTextBlock
---@field TextRhythmGame UFTextBlock
---@field TextShop UFTextBlock
---@field TextTask UFTextBlock
---@field TextTitle UFTextBlock
---@field TextTitle02 UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimMissionBeforeFinishLoop UWidgetAnimation
---@field AnimMissionFinish UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local StarlightCelebrationMainView = LuaClass(UIView, true)

function StarlightCelebrationMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityTime = nil
	--self.BtnGreetingCard = nil
	--self.BtnNewYearsEve = nil
	--self.BtnNightGift = nil
	--self.BtnRhythmGame = nil
	--self.BtnShop = nil
	--self.BtnTask = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.ImgCheck = nil
	--self.ImgLock = nil
	--self.RedDot_1 = nil
	--self.RedDot_2 = nil
	--self.RedDot_3 = nil
	--self.RedDot_4 = nil
	--self.ShareTips = nil
	--self.StarlightCelebrationTransition_UIBP = nil
	--self.TextDate_1 = nil
	--self.TextGreetingCard = nil
	--self.TextNewYearsEve = nil
	--self.TextNightGift = nil
	--self.TextRhythmGame = nil
	--self.TextShop = nil
	--self.TextTask = nil
	--self.TextTitle = nil
	--self.TextTitle02 = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimMissionBeforeFinishLoop = nil
	--self.AnimMissionFinish = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function StarlightCelebrationMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityTime)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.RedDot_1)
	self:AddSubView(self.RedDot_2)
	self:AddSubView(self.RedDot_3)
	self:AddSubView(self.RedDot_4)
	self:AddSubView(self.ShareTips)
	self:AddSubView(self.StarlightCelebrationTransition_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function StarlightCelebrationMainView:OnInit()
	OpsSeasonActivityMgr = _G.OpsSeasonActivityMgr
	self.ViewModel = StarlightCelebrationMainVM.New()
	self.Binders = {
        {"TitleText", UIBinderSetText.New(self, self.TextTitle)},
		{"SubTitleText", UIBinderSetText.New(self, self.TextTitle02)},
		{"TaskTitleText", UIBinderSetText.New(self, self.TextTask)},
		{"TaskFinishVisible", UIBinderSetIsVisible.New(self, self.ImgCheck)},
		{"TextDateText", UIBinderSetText.New(self, self.TextDate_1)},
		{"RhythmGameLockVisible", UIBinderSetIsVisible.New(self, self.ImgLock)},
    }
end

function StarlightCelebrationMainView:OnDestroy()

end

function StarlightCelebrationMainView:OnShow()
	if self.Params == nil then
		return
	end
	
	if self.Params.ActivityID == nil then
		return
	end

	self.RedDot_1:SetRedDotNameByString(OpsSeasonActivityMgr:GetRedDotName(tostring(self.Params.ActivityID).."/Task"))
	self.RedDot_2:SetRedDotNameByString(OpsSeasonActivityMgr:GetRedDotName(tostring(self.Params.ActivityID).."/NightGift"))

	local Detail = _G.OpsActivityMgr.ActivityNodeMap[self.Params.ActivityID] or {}
	local NodeList = Detail.NodeList or {}
	local Node, ActivityNode = OpsSeasonActivityMgr:NodeByNodeTitle(NodeList, LSTR(1700045))

	if Node and ActivityNode then
		self.RedDot_3:SetRedDotNameByString(OpsSeasonActivityMgr:GetRedDotName(tostring(self.Params.ActivityID).."/"..tostring(Node.Head.NodeID)))
	end

	self.RedDot_4:SetRedDotNameByString(OpsSeasonActivityMgr:GetRedDotName(tostring(self.Params.ActivityID).."/"..tostring(OpsSeasonActivityDefine.StarlightRhythmGameNodeID)))

	self.ViewModel:Update(self.Params)
	self:PlayTaskAni()
end

function StarlightCelebrationMainView:OnHide()

end

function StarlightCelebrationMainView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnNightGift, self.OnClickNightGiftButton)
	UIUtil.AddOnClickedEvent(self, self.BtnNewYearsEve, self.OnClickNewYearsButton)
	UIUtil.AddOnClickedEvent(self, self.BtnGreetingCard, self.OnClickGreetingCardButton)
	UIUtil.AddOnClickedEvent(self, self.BtnRhythmGame, self.OnClickRhythmGameButton)
	UIUtil.AddOnClickedEvent(self, self.BtnTask, self.OnClickTaskButton)
	UIUtil.AddOnClickedEvent(self, self.BtnShop, self.OnClickSeasonShop)
end

function StarlightCelebrationMainView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.OpsActivityUpdate, self.UpdateActivityUI)
end

function StarlightCelebrationMainView:UpdateActivityUI()
	if self.Params == nil then
		return
	end
	
	if self.Params.ActivityID == nil then
		return
	end

	local Activity = self.Params.Activity
    local Detail = _G.OpsActivityMgr.ActivityNodeMap[self.Params.ActivityID] or {}
    self.Params:UpdateVM({Activity = Activity, Detail = Detail})

	self.ViewModel:Update(self.Params)

	if self.ViewModel.TaskFinishVisible then
		self:StopAnimLoop(self.AnimMissionBeforeFinishLoop)
	end
end

function StarlightCelebrationMainView:PlayTaskAni()
	if self.ViewModel.TaskFinishVisible then
		self:PlayAnimation(self.AnimMissionFinish)
	else
		self:PlayAnimation(self.AnimMissionBeforeFinishLoop, 0, 0)
	end
end

function StarlightCelebrationMainView:OnRegisterBinder()
	self:RegisterBinders(self.ViewModel, self.Binders)
	self.TextGreetingCard:SetText(LSTR(1700044))
	self.TextNewYearsEve:SetText(LSTR(1700045))
	self.TextNightGift:SetText(LSTR(1700042))
	self.TextRhythmGame:SetText(LSTR(1700046))
	self.TextShop:SetText(LSTR(1560002))
end

function StarlightCelebrationMainView:OnClickNightGiftButton()

	if (not _G.OpsActivityMgr:IsActivityOpen(self.Params.ActivityID)) then
        _G.MsgTipsUtil.ShowTipsByID(342006)
        return
    end

	_G.UIViewMgr:ShowView(_G.UIViewID.OpsNightGiftMainPanel, self.Params)
end

function StarlightCelebrationMainView:OnClickNewYearsButton()
	if (not _G.OpsActivityMgr:IsActivityOpen(self.Params.ActivityID)) then
        _G.MsgTipsUtil.ShowTipsByID(342006)
        return
    end

	_G.UIViewMgr:ShowView(_G.UIViewID.OpsStarLightNewYearActivityPanel, self.Params)

	local Detail = _G.OpsActivityMgr.ActivityNodeMap[self.Params.ActivityID] or {}
	local NodeList = Detail.NodeList or {}
	local Node, ActivityNode = OpsSeasonActivityMgr:NodeByNodeTitle(NodeList, LSTR(1700045))

	if Node and ActivityNode then
		local StartTime = _G.OpsActivityMgr:GetTimeStampByTimeStr(ActivityNode.StartTime)
		local TimeUtil = require("Utils/TimeUtil")
		if StartTime <= TimeUtil.GetServerLogicTime() then
			OpsSeasonActivityMgr:RecordRedDotClicked(Node.Head.NodeID)
		end
	end
end

function StarlightCelebrationMainView:OnClickRhythmGameButton()
	if (not _G.OpsActivityMgr:IsActivityOpen(self.Params.ActivityID)) then
        _G.MsgTipsUtil.ShowTipsByID(342006)
        return
    end
	local NodeList = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeStatistic)
    if NodeList then
		for _, Node in ipairs(NodeList) do
			local NodeID  = Node.Head.NodeID
			local Finished = Node.Head.Finished
		    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                if ActivityNode.NodeTitle == LSTR(1700048) then
					if Finished == false then
						_G.MsgTipsUtil.ShowTips(LSTR(1700056))
						return
					else
						_G.UIViewMgr:ShowView(_G.UIViewID.StarLightRhythmGameActivityPanelView, self.Params)
					end
					break
				end
            end
		end
    end

	OpsSeasonActivityMgr:RecordRedDotClicked(OpsSeasonActivityDefine.StarlightRhythmGameNodeID)

end

function StarlightCelebrationMainView:OnClickGreetingCardButton()

	if (not _G.OpsActivityMgr:IsActivityOpen(self.Params.ActivityID)) then
        _G.MsgTipsUtil.ShowTipsByID(342006)
        return
    end

	_G.GreetingCardWinVM:OpenChoosingFriendsPanel(true)
end

function StarlightCelebrationMainView:OnClickTaskButton()
	if (not _G.OpsActivityMgr:IsActivityOpen(self.Params.ActivityID)) then
        _G.MsgTipsUtil.ShowTipsByID(342006)
        return
    end

	local NodeList = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeStatistic)
    if NodeList then
		table.sort(NodeList, function(A, B)
			return A.Head.NodeID < B.Head.NodeID
		end )
		_G.UIViewMgr:ShowView(_G.UIViewID.OpsStarlightCelebrationTaskWin, NodeList)
		local CurIndex = 1
		for i = 1, #NodeList do
			local Node =  NodeList[i]
			CurIndex = i
			if Node.Head.Finished == false then
				break
			end
		end

		OpsSeasonActivityMgr:RecordRedDotClicked(NodeList[CurIndex].Head.NodeID)
    end
	_G.UIViewMgr:ShowView(_G.UIViewID.OpsStarlightCelebrationTaskWin, NodeList)
end

function StarlightCelebrationMainView:OnClickSeasonShop()
	if (not _G.OpsActivityMgr:IsActivityOpen(self.Params.ActivityID)) then
        _G.MsgTipsUtil.ShowTipsByID(342006)
        return
    end
	local NodeList = self.Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
    if NodeList then
		for _, Node in ipairs(NodeList) do
			local NodeID  = Node.Head.NodeID
		    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                if ActivityNode.NodeTitle == LSTR(1560002) then
					_G.OpsActivityMgr:Jump(ActivityNode.JumpType, ActivityNode.JumpParam)
					return
				end
            end
		end
	end
end

return StarlightCelebrationMainView