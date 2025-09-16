---
--- Author: chaooren
--- DateTime: 2022-03-10 17:27
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
-- local EventID = require("Define/EventID")
local KIL = _G.UE.UKismetInputLibrary

---@class SkillCancelJoyStickView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn_Cancel UFButton
---@field ImgCancelBkg UFImage
---@field ImgCancelBkgInvalid UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillCancelJoyStickView = LuaClass(UIView, true)

function SkillCancelJoyStickView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn_Cancel = nil
	--self.ImgCancelBkg = nil
	--self.ImgCancelBkgInvalid = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillCancelJoyStickView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillCancelJoyStickView:OnInit()
	--(listener, oldstatus, newstatus)
	self.OnMoveCallback = nil

	self.OnMoveCallbackPtr = nil

	self.bInvalidateWhenEnter = false
end

function SkillCancelJoyStickView:OnDestroy()

end

function SkillCancelJoyStickView:OnShow()
	self.bEnter = false
	local Params = self:GetParams()
	if Params then
		self.OnMoveCallback = Params.OnMoveCallback
		self.OnMoveCallbackPtr = Params.OnMoveCallbackPtr
		self.bInvalidateWhenEnter = Params.bInvalidateWhenEnter or false
	end
	UIUtil.SetIsVisible(self.ImgCancelBkg, true)
	UIUtil.SetIsVisible(self.ImgCancelBkgInvalid, false)
end

--极限技使用，因为是事先show，但是没有参数
function SkillCancelJoyStickView:OnDragSkillStart(Params)
	self.bEnter = false
	self:SetParams(Params)
	if Params then
		self.OnMoveCallback = Params.OnMoveCallback
		self.OnMoveCallbackPtr = Params.OnMoveCallbackPtr
		self.bInvalidateWhenEnter = Params.bInvalidateWhenEnter or false
	end
	UIUtil.SetIsVisible(self.ImgCancelBkg, true)
	UIUtil.SetIsVisible(self.ImgCancelBkgInvalid, false)
end

function SkillCancelJoyStickView:OnHide()
	self.OnMoveCallback = nil
	self.OnMoveCallbackPtr = nil
	self.bInvalidateWhenEnter = false
	self.Params = nil
end

function SkillCancelJoyStickView:OnRegisterUIEvent()
	-- UIUtil.AddOnClickedEvent(self, self.Btn_Cancel, self.OnClickCanelBtn)
end

function SkillCancelJoyStickView:OnRegisterGameEvent()

end

function SkillCancelJoyStickView:OnRegisterBinder()

end

function SkillCancelJoyStickView:GetCancelStatus()
	return self.bEnter
end

-- --极限技取消释放相关逻辑（从释放状态的ui切换到 技能技入口的ui）
-- function SkillCancelJoyStickView:OnClickCanelBtn()
-- 	_G.EventMgr:SendEvent(EventID.SkillLimitCancelBtnClick)
-- end

function SkillCancelJoyStickView:MouseEnter()
	if self.OnMoveCallback then
		if self.OnMoveCallbackPtr then
			self.OnMoveCallback(self.OnMoveCallbackPtr, self.bEnter, true)
		else
			self.OnMoveCallback(self.bEnter, true)
		end
	end

	if self.bInvalidateWhenEnter then
		UIUtil.SetIsVisible(self.ImgCancelBkg, false)
		UIUtil.SetIsVisible(self.ImgCancelBkgInvalid, true)
	end

	self.bEnter = true
end

function SkillCancelJoyStickView:MouseLeave()
	if self.OnMoveCallback then
		if self.OnMoveCallbackPtr then
			self.OnMoveCallback(self.OnMoveCallbackPtr, self.bEnter, false)
		else
			self.OnMoveCallback(self.bEnter, false)
		end
	end

	if self.bInvalidateWhenEnter then
		UIUtil.SetIsVisible(self.ImgCancelBkg, true)
		UIUtil.SetIsVisible(self.ImgCancelBkgInvalid, false)
	end

	self.bEnter = false
end

function SkillCancelJoyStickView:RouteMouseMove(_, MouseEvent)
	local MousePosition = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
    local bEnter = UIUtil.IsUnderLocation(self.ImgCancelBkg, MousePosition)
	if bEnter == true and self.bEnter == false then
		self:MouseEnter()
	elseif bEnter == false and self.bEnter == true then
		self:MouseLeave()
	end
end

return SkillCancelJoyStickView