---
--- Author: chriswang
--- DateTime: 2024-07-25 16:53
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local SettingsVoiceResVM = require("Game/Settings/VM/SettingsVoiceResVM")

---@class SettingsVoiceResourcesListItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field SingleBox CommCheckBoxView
---@field TextSize UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsVoiceResourcesListItemView = LuaClass(UIView, true)

function SettingsVoiceResourcesListItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.SingleBox = nil
	--self.TextSize = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsVoiceResourcesListItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsVoiceResourcesListItemView:OnInit()

end

function SettingsVoiceResourcesListItemView:OnDestroy()

end

function SettingsVoiceResourcesListItemView:OnShow()
	local Data = self.Params.Data
	if Data then
		if Data.IsUsing then
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextTitle, "#D1BA8E")
		elseif Data.IsExist then
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextTitle, "#D5D5D5")
		else
			UIUtil.TextBlockSetColorAndOpacityHex(self.TextTitle, "#828282")
		end

		-- local Size = _G.UE.UVersionMgr.Get():GetL10nSize(_G.UE.EGameL10nType.Voices, Data.LanguageType)
		-- local PkgSize = Size / (1024 * 1024)
		self.TextSize:SetText(string.format(("%.2fM"), Data.PkgSize))
		self.TextTitle:SetText(Data.Text)

		self.SingleBox:SetText("")
	end
end

function SettingsVoiceResourcesListItemView:OnHide()

end

function SettingsVoiceResourcesListItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnCheckBoxClick)
end

function SettingsVoiceResourcesListItemView:OnRegisterGameEvent()

end

function SettingsVoiceResourcesListItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	-- local ViewModel = self.Params.Data
	-- if nil == ViewModel then
	-- 	return
	-- end

	-- self:RegisterBinders(ViewModel, self.Binders)
end

function SettingsVoiceResourcesListItemView:OnCheckBoxClick()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

function SettingsVoiceResourcesListItemView:OnSelectChanged(IsSelected)
	-- FLOG_INFO("SettingsVoiceResourcesListItemView:OnSelectChanged : %s", tostring(IsSelected))

	self.SingleBox:SetChecked(IsSelected, false)
end

return SettingsVoiceResourcesListItemView