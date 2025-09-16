---
--- Author: Administrator
--- DateTime: 2023-10-18 15:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class TestMinimizationView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MaxText UTextBlock
---@field Maximize UFButton
---@field DragOffset Vector2D
---@field DragedWidget UserWidget
---@field DragCall mcdelegate
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TestMinimizationView = LuaClass(UIView, true)

function TestMinimizationView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MaxText = nil
	--self.Maximize = nil
	--self.DragOffset = nil
	--self.DragedWidget = nil
	--self.DragCall = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TestMinimizationView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TestMinimizationView:OnInit()

end

function TestMinimizationView:OnDestroy()

end

function TestMinimizationView:OnShow()
	self.MaxText:SetText(_G.LSTR(1440015))
end

function TestMinimizationView:OnHide()

end

function TestMinimizationView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Maximize, self.MaximizeHandle)
end

function TestMinimizationView:OnRegisterGameEvent()

end

function TestMinimizationView:OnRegisterBinder()

end

-- 最大化GM界面
function TestMinimizationView:MaximizeHandle()
	local View  = _G.UIViewMgr:ShowView(_G.UIViewID.FieldTestPanel)
	if View ~= nil then
		View:ShowMovePanel()
	end
	_G.UIViewMgr:HideView(_G.UIViewID.FieldTestMinimizationView)
end

return TestMinimizationView