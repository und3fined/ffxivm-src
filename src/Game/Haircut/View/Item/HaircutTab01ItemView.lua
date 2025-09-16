---
--- Author: jamiyang
--- DateTime: 2024-01-23 09:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class HaircutTab01ItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSelect UFButton
---@field ImgNormal UFImage
---@field ImgSelect UFImage
---@field PanelTabItem UFCanvasPanel
---@field AnimCheck UWidgetAnimation
---@field AnimUncheck UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutTab01ItemView = LuaClass(UIView, true)

function HaircutTab01ItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSelect = nil
	--self.ImgNormal = nil
	--self.ImgSelect = nil
	--self.PanelTabItem = nil
	--self.AnimCheck = nil
	--self.AnimUncheck = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutTab01ItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutTab01ItemView:OnInit()

end

function HaircutTab01ItemView:OnDestroy()

end

function HaircutTab01ItemView:OnShow()
	if self.Params and self.Params.Data then
		local Cfg = self.Params.Data
		UIUtil.ImageSetBrushFromAssetPath(self.ImgNormal, Cfg.UnCheckIcon)
		UIUtil.ImageSetBrushFromAssetPath(self.ImgSelect, Cfg.CheckIcon)
	end
end

function HaircutTab01ItemView:OnHide()

end

function HaircutTab01ItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSelect, self.OnMainBtnClick)
end

function HaircutTab01ItemView:OnRegisterGameEvent()

end

function HaircutTab01ItemView:OnRegisterBinder()

end

function HaircutTab01ItemView:OnSelectChanged(IsSelected)
	if IsSelected then
		self:PlayAnimation(self.AnimCheck)
	else
		self:PlayAnimation(self.AnimUncheck)
	end
end

function HaircutTab01ItemView:OnMainBtnClick()
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

return HaircutTab01ItemView