---
--- Author: Administrator
--- DateTime: 2024-05-15 10:50
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ArmyJumpWayTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommonPopUpBG CommonPopUpBGView
---@field PanelTips UFCanvasPanel
---@field TableViewList UTableView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ArmyJumpWayTipsView = LuaClass(UIView, true)

function ArmyJumpWayTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommonPopUpBG = nil
	--self.PanelTips = nil
	--self.TableViewList = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ArmyJumpWayTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ArmyJumpWayTipsView:OnInit()

end

function ArmyJumpWayTipsView:OnDestroy()

end

function ArmyJumpWayTipsView:OnShow()

end

function ArmyJumpWayTipsView:OnHide()

end

function ArmyJumpWayTipsView:OnRegisterUIEvent()

end

function ArmyJumpWayTipsView:OnRegisterGameEvent()

end

function ArmyJumpWayTipsView:OnRegisterBinder()

end

return ArmyJumpWayTipsView