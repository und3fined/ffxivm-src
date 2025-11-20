---
--- Author: Administrator
--- DateTime: 2025-03-17 20:57
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCommon = require("Protocol/ProtoCommon")

---@class WorldExploraMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActivityPanel WorldExploraActivityPanelView
---@field BtnAdventure UFButton
---@field BtnRewardView UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommonBkg02_UIBP CommonBkg02View
---@field CommonBkgMask_UIBP CommonBkgMaskView
---@field CommonTitle CommonTitleView
---@field ExploraPanel WorldExploraExploraPanelView
---@field HorizontalTopBtn UFHorizontalBox
---@field ImgLock UFImage
---@field SelectionPanel WorldExploraSelectionPanelView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldExploraMainView = LuaClass(UIView, true)

function WorldExploraMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActivityPanel = nil
	--self.BtnAdventure = nil
	--self.BtnRewardView = nil
	--self.CloseBtn = nil
	--self.CommonBkg02_UIBP = nil
	--self.CommonBkgMask_UIBP = nil
	--self.CommonTitle = nil
	--self.ExploraPanel = nil
	--self.HorizontalTopBtn = nil
	--self.ImgLock = nil
	--self.SelectionPanel = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldExploraMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ActivityPanel)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommonBkg02_UIBP)
	self:AddSubView(self.CommonBkgMask_UIBP)
	self:AddSubView(self.CommonTitle)
	self:AddSubView(self.ExploraPanel)
	self:AddSubView(self.SelectionPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldExploraMainView:OnInit()

end

function WorldExploraMainView:OnShow()
	self.CommonTitle:SetTextTitleName(LSTR(1610029))
	--是否已经解锁
	local IsOpen = _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDChallengeNote)
	UIUtil.SetIsVisible(self.ImgLock, not IsOpen)

	_G.TouringBandMgr:QueryCollectionReq()
end


function WorldExploraMainView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnAdventure, self.OnBtnAdventureClick)
	UIUtil.AddOnClickedEvent(self, self.BtnRewardView, self.OnBtnRewardViewClick)
end


--- @type 当下选框线选择改变
function WorldExploraMainView:OnSubTabSelectChange(index)
	local bActiviryVisible = index == 1
	UIUtil.SetIsVisible(self.ActivityPanel, bActiviryVisible)
	UIUtil.SetIsVisible(self.ExploraPanel, not bActiviryVisible)
end

function WorldExploraMainView:OnBtnAdventureClick()
	if not _G.ModuleOpenMgr:ModuleState(ProtoCommon.ModuleID.ModuleIDChallengeNote) then
        return
    end

	--挑战笔记
	_G.UIViewMgr:ShowView(_G.UIViewID.WorldExploraAdventureWin)
end

function WorldExploraMainView:OnBtnRewardViewClick()
	--奖励
	_G.UIViewMgr:ShowView(_G.UIViewID.WorldExploraAwardWin)
end

return WorldExploraMainView