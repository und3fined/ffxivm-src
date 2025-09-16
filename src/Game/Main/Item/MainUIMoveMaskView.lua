---
--- Author: eddardchen
--- DateTime: 2021-05-10 16:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local EventMgr = _G.EventMgr
local EventID = _G.EventID

---@class MainUIMoveMaskView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackGroundImage UImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainUIMoveMaskView = LuaClass(UIView, true)

function MainUIMoveMaskView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackGroundImage = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainUIMoveMaskView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainUIMoveMaskView:OnInit()

end

function MainUIMoveMaskView:OnDestroy()

end

function MainUIMoveMaskView:OnShow()

end

function MainUIMoveMaskView:OnHide()

end

function MainUIMoveMaskView:OnRegisterUIEvent()

end

function MainUIMoveMaskView:OnRegisterGameEvent()

end

function MainUIMoveMaskView:OnRegisterTimer()

end

function MainUIMoveMaskView:OnRegisterBinder()

end

function MainUIMoveMaskView:OnTouchStarted(MyGeometry, InTouchEvent)
	EventMgr:SendEvent(EventID.WidgetDragCancel, nil)
	return UE.UWidgetBlueprintLibrary.Handled()
end

return MainUIMoveMaskView