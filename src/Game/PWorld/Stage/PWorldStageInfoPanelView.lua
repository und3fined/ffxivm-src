--
-- Author: haialexzhou
-- Date: 2020-12-21 20:41:25
-- Description:
--

local LuaClass = require("Core/LuaClass")
local UIView = require("UI/UIView")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIAdapterDynamicEntryBox = require("UI/Adapter/UIAdapterDynamicEntryBox")

local PWorldStageInfoPanelView = LuaClass(UIView, true)
local UpdateTimerID = 0

--local DefaultActiveWidgetIndex = 1
--local CurrActiveWidgetIndex = DefaultActiveWidgetIndex

---@class PWorldStageInfoPanelView : UIView
--AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY

--AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
function PWorldStageInfoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnPopup = nil
	--self.DynamicEntryBoxStage = nil
	--self.ImgPWorldType = nil
	--self.LeftTime = nil
	--self.Switcher = nil
	--self.Title = nil
	--self.AnimationHide = nil
	--self.AnimationShow = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldStageInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldStageInfoPanelView:OnInit()
	self.AdapterPlayer = UIAdapterDynamicEntryBox.CreateAdapter(self, self.DynamicEntryBoxStage)
end

function PWorldStageInfoPanelView:OnDestroy()
end

function PWorldStageInfoPanelView:OnPopupButtonClicked()
	--暂时先屏蔽这个功能
	-- if (CurrActiveWidgetIndex == 1) then
	-- 	CurrActiveWidgetIndex = 0
	-- 	if nil ~= self.AnimationHide then
	-- 		self:PlayAnimation(self.AnimationHide)
	-- 	end
	-- else
	-- 	CurrActiveWidgetIndex = 1
	-- 	if nil ~= self.AnimationShow then
	-- 		self:PlayAnimation(self.AnimationShow)
	-- 	end
	-- end

	-- self.Switcher:SetActiveWidgetIndex(CurrActiveWidgetIndex)
end

function PWorldStageInfoPanelView:UpdateLeftTime()
	local LeftTime = _G.PWorldMgr.BaseInfo.EndTime - _G.TimeUtil.GetServerTime()
	if (LeftTime <= 0) then
		LeftTime = 0
		self:UnRegisterTimer(UpdateTimerID)
	end

	local LeftTimeStr = _G.DateTimeTools.TimeFormat(LeftTime, "mm:ss")
	self.LeftTime:SetText(LeftTimeStr)
end

function PWorldStageInfoPanelView:UpdateStageInfo()
	local StageInfoList = _G.PWorldStageMgr.StageInfoList
	if (StageInfoList ~= nil) then
		UIUtil.SetIsVisible(self.DynamicEntryBoxStage, true)
		self.AdapterPlayer:UpdateAll(StageInfoList)
	else
		UIUtil.SetIsVisible(self.DynamicEntryBoxStage, false)
	end

	local CurrMapTableCfg = _G.PWorldMgr:GetCurrMapTableCfg()
	if (CurrMapTableCfg) then
		self.Title:SetText(CurrMapTableCfg.DisplayName)
	else
		self.Title:SetText(_G.LSTR(1320115))
	end

	if (_G.PWorldStageMgr.CurrIconPath ~= nil) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgPWorldType, _G.PWorldStageMgr.CurrIconPath)
	end
end

function PWorldStageInfoPanelView:OnShow()
	self:UpdateStageInfo()
end

function PWorldStageInfoPanelView:OnHide()
end

function PWorldStageInfoPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnPopup, self.OnPopupButtonClicked)
	UIUtil.AddOnClickedEvent(self, self.BtnQuest, function()
		_G.PWorldQuestMgr:ShowPWQuestView()
	end)
end

function PWorldStageInfoPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldStageInfoUpdate, self.UpdateStageInfo)
end

function PWorldStageInfoPanelView:OnRegisterTimer()
	UpdateTimerID = self:RegisterTimer(self.UpdateLeftTime, 0, 1, 0)
end

function PWorldStageInfoPanelView:OnRegisterBinder()

end

return PWorldStageInfoPanelView