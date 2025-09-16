---
--- Author: v_hggzhang
--- DateTime: 2022-05-10 15:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local BuffDefine = require("Game/Buff/BuffDefine")
local Switcher = require("Utils/ActionSwitcher")


---@class MainBuffPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MainBuffTips MainBuffGroupAndTipsView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainBuffPanelView = LuaClass(UIView, true)

function MainBuffPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MainBuffTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainBuffPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MainBuffTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainBuffPanelView:OnInit()
end


function MainBuffPanelView:OnDestroy()

end

function MainBuffPanelView:OnShow()

end

function MainBuffPanelView:OnHide()

end

function MainBuffPanelView:OnRegisterUIEvent()

end

function MainBuffPanelView:OnRegisterGameEvent()

end

function MainBuffPanelView:OnRegisterBinder()

end


return MainBuffPanelView