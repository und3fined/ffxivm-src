---
--- Author: xingcaicao
--- DateTime: 2024-09-10 20:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommMoneyBarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field HorizontalMoney UFHorizontalBox
---@field Money1 CommMoneySlotView
---@field Money2 CommMoneySlotView
---@field Money3 CommMoneySlotView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommMoneyBarView = LuaClass(UIView, true)

function CommMoneyBarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.HorizontalMoney = nil
	--self.Money1 = nil
	--self.Money2 = nil
	--self.Money3 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommMoneyBarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Money1)
	self:AddSubView(self.Money2)
	self:AddSubView(self.Money3)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommMoneyBarView:OnInit()

end

function CommMoneyBarView:OnDestroy()

end

function CommMoneyBarView:OnShow()

end

function CommMoneyBarView:OnHide()

end

function CommMoneyBarView:OnRegisterUIEvent()

end

function CommMoneyBarView:OnRegisterGameEvent()

end

function CommMoneyBarView:OnRegisterBinder()

end

return CommMoneyBarView