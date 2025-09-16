---
--- Author: jamiyang
--- DateTime: 2023-07-28 14:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MagicsparSucceedTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelSucceed UFCanvasPanel
---@field TextSucceed URichTextBox
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MagicsparSucceedTipsView = LuaClass(UIView, true)

function MagicsparSucceedTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelSucceed = nil
	--self.TextSucceed = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MagicsparSucceedTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MagicsparSucceedTipsView:OnInit()

end

function MagicsparSucceedTipsView:OnDestroy()

end

function MagicsparSucceedTipsView:OnShow()
	self.TextSucceed:SetText(_G.LSTR(1060004)) -- "镶嵌成功"
end

function MagicsparSucceedTipsView:OnHide()

end

function MagicsparSucceedTipsView:OnRegisterUIEvent()

end

function MagicsparSucceedTipsView:OnRegisterGameEvent()

end

function MagicsparSucceedTipsView:OnRegisterBinder()

end

return MagicsparSucceedTipsView