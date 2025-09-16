---
--- Author: xingcaicao
--- DateTime: 2023-03-21 10:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local SettingsUtils = require("Game/Settings/SettingsUtils")
local PWorldCfg = require("TableCfg/PworldCfg")

---@class SettingsSubCategoryView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommInforBtn_UIBP CommInforBtnView
---@field FButtonColor UFButton
---@field FTextName UFTextBlock
---@field ImgColorIcon UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsSubCategoryView = LuaClass(UIView, true)

function SettingsSubCategoryView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommInforBtn_UIBP = nil
	--self.FButtonColor = nil
	--self.FTextName = nil
	--self.ImgColorIcon = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsSubCategoryView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommInforBtn_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsSubCategoryView:OnInit()

end

function SettingsSubCategoryView:OnDestroy()

end

function SettingsSubCategoryView:OnShow()
	if nil == self.VM then
		return
	end

	UIUtil.SetIsVisible(self.ImgColorIcon, self.VM.IsSetColor)
	UIUtil.SetIsVisible(self.FButtonColor, self.VM.IsSetColor)

	if self.VM.HID == 0 then
		UIUtil.SetIsVisible(self.CommInforBtn_UIBP, false)
	else
		self.CommInforBtn_UIBP.HelpInfoID = self.VM.HID
		UIUtil.SetIsVisible(self.CommInforBtn_UIBP, true)
		
		if self.VM.HID == 22 then	--副本
			local IDList = _G.SettingsMgr.FpsModeDungeonList
			local NameList = ""
			local Cnt = #IDList
			if IDList and Cnt >= 1 then
				local Cfg = PWorldCfg:FindCfgByKey(IDList[1])
				if Cfg then
					NameList = Cfg.PWorldName
				end

				for index = 2, Cnt do
					local Cfg = PWorldCfg:FindCfgByKey(IDList[index])
					if Cfg then
						NameList = string.format( "%s，%s", NameList, Cfg.PWorldName)
					end
				end
			end
			
			self.CommInforBtn_UIBP:SetArgs(NameList)
		end
	end

	if self.VM.ButtonFunc then
		UIUtil.SetIsVisible(self.SubCategoryBtn, true)
		self.SubCategoryBtn:SetBtnName(self.VM.ButtonText)
	else
		UIUtil.SetIsVisible(self.SubCategoryBtn, false)
	end

	self.FTextName:SetText(self.VM.SubCategoryName or "")
end

function SettingsSubCategoryView:OnHide()

end

function SettingsSubCategoryView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButtonColor, self.OnClickButtonColor)
	UIUtil.AddOnClickedEvent(self, self.SubCategoryBtn.Button, self.OnClickSubCategoryBtn)
end

function SettingsSubCategoryView:OnRegisterGameEvent()

end

function SettingsSubCategoryView:OnRegisterBinder()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	self.VM = self.Params.Data

	local Binders = {
		{ "Color", UIBinderSetColorAndOpacityHex.New(self, self.ImgColorIcon) },
	}

	self:RegisterBinders(self.Params.Data, Binders)
end

function SettingsSubCategoryView:OnClickButtonColor()
    UIViewMgr:ShowView(UIViewID.SettingsColor, self.VM)
end

function SettingsSubCategoryView:OnClickSubCategoryBtn()
    FLOG_INFO("SettingsSubCategoryView:OnClickSubCategoryBtn")
	SettingsUtils.CallFunc(self.VM.ButtonFunc)
end

return SettingsSubCategoryView