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
local HelpCfg = require("TableCfg/HelpCfg")
local HelpInfoUtil = require("Utils/HelpInfoUtil")
local TipsUtil = require("Utils/TipsUtil")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")

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
		elseif self.VM.HID == 11215 then
			self.CommInforBtn_UIBP.View = self.CommInforBtn_UIBP
			self.CommInforBtn_UIBP.Callback = function(View)
				if nil ~= View then
					local TipContent = {{Title = "", Content = {}}}
					local HelpCfgs = HelpCfg:FindAllHelpIDCfg(self.VM.HID)
					if #HelpCfgs == 0 then
						return
					end
					local  HandleText1= "LB"
					local  HandleText2= _G.SettingsHandleMgr:GetHandleInputActionTextByCusAction(SettingsHandleDefine.HandleCustomActionType.NormalSkill)
					local Type = HelpCfgs[1].Type
					TipContent[1].Content[1] = HelpCfgs[1].SecContent
					TipContent[1].Content[2] = string.format(HelpCfgs[2].SecContent, HandleText1)
					TipContent[1].Content[3] = string.format(HelpCfgs[3].SecContent, HandleText2, HandleText2)
					local Dir = HelpCfgs[1].Direction and HelpCfgs[1].Direction or 1
        			local Offset, Alignment = HelpInfoUtil.GetOffsetAndAlignment(View.BtnInfor, Dir)
					TipsUtil.ShowInfoTips(TipContent, View.BtnInfor, Offset, Alignment, false, nil, Type)
				end
			end
		end
	end

	if self.VM.ButtonFunc then
		UIUtil.SetIsVisible(self.PanelReset, true)
		self.TextReset:SetText(self.VM.ButtonText)
	else
		UIUtil.SetIsVisible(self.PanelReset, false)
	end

	self:SetSubCategoryName()
end

function SettingsSubCategoryView:OnHide()

end

function SettingsSubCategoryView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FButtonColor, self.OnClickButtonColor)
	UIUtil.AddOnClickedEvent(self, self.BtnReset, self.OnClickBtnReset)
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

function SettingsSubCategoryView:OnClickBtnReset()
    FLOG_INFO("SettingsSubCategoryView:OnClickBtnReset")
	SettingsUtils.CallFunc(self.VM.ButtonFunc)
end

function SettingsSubCategoryView:SetSubCategoryName()
	if self.VM.SubCategoryFunc then
		local CurSubCategoryName = SettingsUtils.CallFunc(self.VM.SubCategoryFunc, self.VM.SubCategoryName)
		if CurSubCategoryName then
			self.FTextName:SetText(CurSubCategoryName or "")
			return
		end
	end
	self.FTextName:SetText(self.VM.SubCategoryName or "")
end

return SettingsSubCategoryView