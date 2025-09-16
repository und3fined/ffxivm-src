---
--- Author: eddardchen
--- DateTime: 2021-04-07 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MainSkillTouchPadView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainSkillTouchPadView = LuaClass(UIView, true)

function MainSkillTouchPadView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.bIsHovered = false
end

function MainSkillTouchPadView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainSkillTouchPadView:OnInit()

end

function MainSkillTouchPadView:OnDestroy()

end

function MainSkillTouchPadView:OnShow()

end

function MainSkillTouchPadView:OnHide()

end

function MainSkillTouchPadView:OnRegisterUIEvent()

end

function MainSkillTouchPadView:OnRegisterGameEvent()

end

function MainSkillTouchPadView:OnRegisterTimer()

end

function MainSkillTouchPadView:OnRegisterBinder()

end

-- ReturnHandle 是蓝图中的函数, 作用是阻止事件穿透

function MainSkillTouchPadView:OnTouchStarted(MyGeometry, MouseEvent)
	if nil ~= self.parent and false == self.parent.CDMask then 
		self.parent:OnPrePressSkillSelect()
		self.parent:OnParentTouchMoved(MyGeometry, MouseEvent)
	end
	return self:ReturnHandleCapture()
end

function MainSkillTouchPadView:OnTouchEnded(MyGeometry, MouseEvent)
	if nil ~= self.parent then
		self.parent:OnParentTouchEnded()
	end
	return self:ReturnHandle()
end

function MainSkillTouchPadView:OnTouchMoved(MyGeometry, InTouchEvent)
	if nil ~= self.parent then
		self.parent:OnParentTouchMoved(MyGeometry, InTouchEvent)
	end
	return self:ReturnHandle()
end

function MainSkillTouchPadView:OnMouseEnter(MyGeometry, MouseEvent)
	-- 出范围后释放被屏蔽了
	-- self.bIsHovered = true
end

function MainSkillTouchPadView:OnMouseLeave(MouseEvent)
	-- 出范围后释放被屏蔽了
	-- self.bIsHovered = false
end


return MainSkillTouchPadView