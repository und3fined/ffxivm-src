---
--- Author: Administrator
--- DateTime: 2023-12-18 16:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MagicCardBoxItmeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field FCanvasPanel UFCanvasPanel
---@field ImgProgressBar URadialImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicCardBoxItmeItemView = LuaClass(UIView, true)

function MagicCardBoxItmeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.FCanvasPanel = nil
	--self.ImgProgressBar = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicCardBoxItmeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicCardBoxItmeItemView:OnInit()

end

function MagicCardBoxItmeItemView:OnDestroy()

end

function MagicCardBoxItmeItemView:OnShow()
	
end

function MagicCardBoxItmeItemView:OnHide()

end

function MagicCardBoxItmeItemView:OnRegisterUIEvent()

end

function MagicCardBoxItmeItemView:OnRegisterGameEvent()

end

function MagicCardBoxItmeItemView:OnRegisterBinder()

end

function MagicCardBoxItmeItemView:OnPerCentChanged(Percent)
	self.ImgProgressBar:SetPercent(Percent)
end

return MagicCardBoxItmeItemView