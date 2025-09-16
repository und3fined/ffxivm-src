---
--- Author: ds_herui
--- DateTime: 2023-12-26 16:10
--- Description:
---


local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBindableList = require("UI/UIBindableList")
local AchievementUtil = require("Game/Achievement/AchievementUtil")
local AchievementItemVM = require("Game/Achievement/VM/Item/AchievementItemVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local AchievementGroupCfg = require("TableCfg/AchievementGroupCfg")
local MsgTipsID = require("Define/MsgTipsID")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local EToggleButtonState = _G.UE.EToggleButtonState
local AchievementMgr = _G.AchievementMgr
local LSTR = _G.LSTR

---@class AchievementDetailWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field TableViewDetail UTableView
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AchievementDetailWinView = LuaClass(UIView, true)

function AchievementDetailWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.TableViewDetail = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AchievementDetailWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AchievementDetailWinView:OnInit()
	self.AchievementTypeDataList = UIBindableList.New( AchievementItemVM )
	self.AdapterTableViewDetail = UIAdapterTableView.CreateAdapter(self, self.TableViewDetail, nil , false)
end

function AchievementDetailWinView:OnDestroy()

end

function AchievementDetailWinView:OnShow()
	self.TextTitle:SetText(LSTR(720020))
	local ShowAchievementDataList = {}
	local Params = self.Params 
	if Params and Params.AchievemwntGroupID then
		local GroupCfg = AchievementGroupCfg:FindCfgByKey(Params.AchievemwntGroupID) or {}
		local Details = GroupCfg.Details or {}
		for i = 1, #Details do
			local Data = AchievementMgr:GetAchievementInfo(Details[i]) 
			if Data ~= nil then
				Data.IsShow = true 
				table.insert(ShowAchievementDataList, Data)
			end
		end
	end
	ShowAchievementDataList = AchievementUtil.CheckShowFromHideType(ShowAchievementDataList)
	self.AchievementTypeDataList:UpdateByValues(ShowAchievementDataList)
	self.AdapterTableViewDetail:UpdateAll(self.AchievementTypeDataList)
end

function AchievementDetailWinView:OnHide()
	self.AdapterTableViewDetail:CancelSelected()
end

function AchievementDetailWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self,  self.BtnClose, self.OnBtnCloseClick)
end

function AchievementDetailWinView:OnRegisterGameEvent()

end

function AchievementDetailWinView:OnRegisterBinder()
end

function AchievementDetailWinView:OnBtnCloseClick()
	self:Hide()
end

function AchievementDetailWinView:CollectionSucceed(IsAdd, AchieveIDs)
	for i = 1, #AchieveIDs do
		local ViewModel = self.AchievementTypeDataList:Find(function(Item) return Item.ID == AchieveIDs[i] end )
		if ViewModel ~= nil then
			if IsAdd then
				ViewModel:SetToggleBtnFavorState(EToggleButtonState.Checked)  
				MsgTipsUtil.ShowTipsByID(MsgTipsID.AchievementAddTarget, nil, string.formatint(AchievementMgr:GetTargetAchievementNum())) 
		    else
				ViewModel:SetToggleBtnFavorState(EToggleButtonState.Unchecked)
				MsgTipsUtil.ShowTipsByID(MsgTipsID.AchievementRemoveTarget, nil, string.formatint(AchievementMgr:GetTargetAchievementNum()))
			end
		end
	end
end

return AchievementDetailWinView