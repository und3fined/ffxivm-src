---
--- Author: jamiyang
--- DateTime: 2023-08-08 17:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local SkillTipsMgr = require("Game/Skill/SkillTipsMgr")
local DataReportUtil = require("Utils/DataReportUtil")

---@class MountActionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIcon UFImage
---@field ImgSelect UFImage
---@field ToggleButtonAction UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MountActionItemView = LuaClass(UIView, true)

function MountActionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIcon = nil
	--self.ImgSelect = nil
	--self.ToggleButtonAction = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MountActionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MountActionItemView:OnInit()

end

function MountActionItemView:OnDestroy()

end

function MountActionItemView:OnShow()
	self:SetActionData()
	UIUtil.SetIsVisible(self.ImgSelect, false)
end

function MountActionItemView:OnHide()

end

function MountActionItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.ToggleButtonAction, self.OnClicked)
end

function MountActionItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ActionSelectChanged, self.SkillCallbackChanged)
end

function MountActionItemView:OnRegisterBinder()

end

function MountActionItemView:SetActionData()
	if nil == self.Params.Data then
		return
	end

	if self.Params.Data.Cfg and self.Params.Data.Cfg.ID ~= nil then
		self.ID = self.Params.Data.Cfg.ID
		self.Icon = self.Params.Data.Cfg.Icon
		self.SkillName = self.Params.Data.Cfg.SkillName
		self.SkillTag = self.Params.Data.Cfg.SkillTag
		self.Distance = self.Params.Data.Cfg.Distance
		self.Range = self.Params.Data.Cfg.Range
		self.SingTimeDescribe = self.Params.Data.Cfg.SingTimeDescribe
		self.SingTime2 = self.Params.Data.Cfg.SingTime2
		self.SkillDescribe = self.Params.Data.Cfg.SkillDescribe
		self.SelectedMountID = self.Params.Data.ViewModel.SelectedMountID
		UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, self.Params.Data.Cfg.Icon)
	end
end

function MountActionItemView:OnClicked()
	local Params = {}
	Params.SkillName = self.SkillName
	Params.SkillTag = {}
	Params.SkillTag[1] = self.SkillTag
	Params.SkillInfoList = {}
	Params.SkillInfoList[1] = LSTR(1090042)..self.Distance..LSTR(1090044)
	Params.SkillInfoList[2] = LSTR(1090043)..self.Range..LSTR(1090044)
	Params.SkillInfoList[3] = "      "
	Params.SkillInfoList[4] = string.format("<span color=\"#%s\">%s</>", "C9BB9CFF", LSTR(1090045)..self.SingTimeDescribe)
	Params.SkillInfoList[5] = string.format("<span color=\"#%s\">%s</>", "C9BB9CFF", LSTR(1090046)..self.SingTime2..LSTR(1090047))
	Params.SkillInfoList[6] = "      "
	Params.SkillInfoList[7] = self.SkillDescribe
	Params.SkillInfoList[8] = LSTR(1090048)
--	Params.SkillInfoList[9] = LSTR(1090049)
	Params.InTargetWidget = self
	Params.IsAutoFlip = true
	Params.InfoTipGap = 520+190
	Params.NameColor = "FFFFFFFF"
	SkillTipsMgr:ShowMountSkillTips(Params, true)

	self:SetHideCallback()
	DataReportUtil.ReportMountInterSystemFlowData(6, self.SelectedMountID, self.ID)
	_G.EventMgr:SendEvent(_G.EventID.ActionSelectChanged, { ID = self.ID } )
end

function MountActionItemView:SetHideCallback()
	if self.Params and self.Params.Data and nil ~= self.Params.Data.ViewModel then
		if nil ~= self.Params.Data.ViewModel.IsShowSkillTips then
			self.Params.Data.ViewModel.IsShowSkillTips = true
		end
	end
end

function MountActionItemView:SkillCallbackChanged(Params)
	if Params and Params.ID == self.ID then
		UIUtil.SetIsVisible(self.ImgSelect, true)
	else
		UIUtil.SetIsVisible(self.ImgSelect, false)
	end
end

return MountActionItemView