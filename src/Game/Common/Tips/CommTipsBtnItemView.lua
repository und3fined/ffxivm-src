---
--- Author: xingcaicao
--- DateTime: 2024-09-10 20:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommTipsBtnItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn CommBtnLView
---@field Money1 CommMoneySlotView
---@field PanelMoney UFCanvasPanel
---@field PanelText UFCanvasPanel
---@field RichTextTips URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommTipsBtnItemView = LuaClass(UIView, true)

function CommTipsBtnItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Money1 = nil
	--self.PanelMoney = nil
	--self.PanelText = nil
	--self.RichTextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommTipsBtnItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Btn)
	self:AddSubView(self.Money1)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommTipsBtnItemView:OnInit()

end

function CommTipsBtnItemView:OnDestroy()

end

function CommTipsBtnItemView:OnShow()

end

function CommTipsBtnItemView:OnHide()

end

function CommTipsBtnItemView:OnRegisterUIEvent()

end

function CommTipsBtnItemView:OnRegisterGameEvent()

end

function CommTipsBtnItemView:OnRegisterBinder()

end

return CommTipsBtnItemView