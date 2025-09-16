---
--- Author: xingcaicao
--- DateTime: 2024-01-31 11:03
--- Description:
---

local UIUtil = require("Utils/UIUtil")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

-- TODO(loiafeng): 更通用的颜色表格
local ActorUIColorCfg = require("TableCfg/ActorUiColorCfg")

---@class SettingsColorSettingsItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field ImgColor UFImage
---@field PanelColor UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SettingsColorSettingsItemView = LuaClass(UIView, true)

function SettingsColorSettingsItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.ImgColor = nil
	--self.PanelColor = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SettingsColorSettingsItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SettingsColorSettingsItemView:OnInit()

end

function SettingsColorSettingsItemView:OnDestroy()

end

function SettingsColorSettingsItemView:OnShow()

end

function SettingsColorSettingsItemView:OnHide()

end

function SettingsColorSettingsItemView:OnRegisterUIEvent()

end

function SettingsColorSettingsItemView:OnRegisterGameEvent()

end

function SettingsColorSettingsItemView:OnRegisterBinder()

end

function SettingsColorSettingsItemView:SetColor(ColorID)
	local Cfg = ActorUIColorCfg:FindCfgByKey(ColorID)
	local Color = Cfg and Cfg.Palette
	UIUtil.ImageSetColorAndOpacityHex(self.ImgColor, Color)
end

function SettingsColorSettingsItemView:GetButton()
	return self.Btn
end

return SettingsColorSettingsItemView