---
--- Author: chriswang
--- DateTime: 2024-09-24 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local SettingsUtils = require("Game/Settings/SettingsUtils")
local SettingsDefine = require("Game/Settings/SettingsDefine")
local MsgBoxUtil = require("Utils/MsgBoxUtil")

local LSTR = _G.LSTR
local ItemDisplayStyle = SettingsDefine.ItemDisplayStyle

---@class SettingsItemColorView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelSettingsColor UFCanvasPanel
---@field SettingsColorSettingsItem SettingsColorSettingsItemView
---@field TextItemContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsItemColorView = LuaClass(UIView, true)

function SettingsItemColorView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelSettingsColor = nil
	--self.SettingsColorSettingsItem = nil
	--self.TextItemContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsItemColorView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SettingsColorSettingsItem)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsItemColorView:OnInit()

end

function SettingsItemColorView:OnDestroy()

end

function SettingsItemColorView:OnShow()
	if nil == self.Params or nil == self.Params.Data then
		return
	end

	self.ItemVM = self.Params.Data

	self:SetColorPaletteItem()
end

function SettingsItemColorView:OnHide()

end

function SettingsItemColorView:OnRegisterUIEvent()

end

function SettingsItemColorView:OnRegisterGameEvent()

end

function SettingsItemColorView:OnRegisterBinder()

end

---调色板。
function SettingsItemColorView:SetColorPaletteItem()
	-- 设置描述
	self.TextItemContent:SetText(self.ItemVM.Desc or "")

	UIUtil.SetIsVisible(self.PanelSettingsColor, true)
	
	-- 更新本条目显示的颜色
	local CurColorID = self:GetCurrentColorID()
	self.SettingsColorSettingsItem:SetColor(CurColorID)

	-- 设置点击回调
	UIUtil.AddOnClickedEvent(self, self.SettingsColorSettingsItem:GetButton(), self.OnColorPaletteItemClick)
end

function SettingsItemColorView:GetCurrentColorID()
	return SettingsUtils.GetValue(self.ItemVM.GetValueFunc, self.ItemVM.SettingCfg) or 0
end

function SettingsItemColorView:OnColorPaletteItemClick()
	-- 打开调色盘界面
	local CurColorID = self:GetCurrentColorID()
	local MainPanel = (self.ParentView or {}).ParentView
	if MainPanel then
		MainPanel:ShowColorPalette(CurColorID, self, self.OnColorPaletteClose)
	end
end

function SettingsItemColorView:OnColorPaletteClose(ColorID)
	-- 更新本条目显示的颜色
	self.SettingsColorSettingsItem:SetColor(ColorID)

	-- 设置值
	SettingsUtils.SetValue(self.ItemVM.SetValueFunc, self.ItemVM.SettingCfg, ColorID, true)
end

return SettingsItemColorView