---
--- Author: kanohchen
--- DateTime: 2025-08-27 16:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonStateUtil = require("Game/CommonState/CommonStateUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local SettingsTabRole = require("Game/Settings/SettingsTabRole")
local SettingsHandleDefine = require("Game/Settings/SettingsHandleDefine")
local EventID = require("Define/EventID")
local ProtoRes = require("Protocol/ProtoRes")

local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local MajorUtil = require("Utils/MajorUtil")

local OneVector2D = _G.UE.FVector2D(1, 1)

---@class SkillHandleJumpBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnEntrance UFButton
---@field HandleState SkillHandleStateLView
---@field ImgIcon UFImage
---@field ImgSlot UFImage
---@field Panel UFCanvasPanel
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillHandleJumpBtnView = LuaClass(UIView, true)

function SkillHandleJumpBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnEntrance = nil
	--self.HandleState = nil
	--self.ImgIcon = nil
	--self.ImgSlot = nil
	--self.Panel = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillHandleJumpBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.HandleState)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function SkillHandleJumpBtnView:OnInit()

end

function SkillHandleJumpBtnView:OnDestroy()

end

function SkillHandleJumpBtnView:OnShow()
	self:OnGamePadUpdateCombatType()
end

function SkillHandleJumpBtnView:OnHide()

end

function SkillHandleJumpBtnView:OnRegisterUIEvent()
	UIUtil.AddOnPressedEvent(self, self.BtnEntrance, self.OnBtnPressed)
	UIUtil.AddOnReleasedEvent(self, self.BtnEntrance, self.OnBtnRelease)
end

function SkillHandleJumpBtnView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.GamePadUpdateCombatType, self.OnGamePadUpdateCombatType)
	self:RegisterGameEvent(EventID.GamePadJump, self.OnGamePadJump)
end

function SkillHandleJumpBtnView:OnRegisterBinder()

end

function SkillHandleJumpBtnView:OnBtnPressed()
	self:SetRenderScale(OneVector2D* SkillCommonDefine.SkillBtnClickFeedback)
	local MajorController = MajorUtil.GetMajorController()
    if not MajorController then
        return
    end
	MajorController:NewJumpStart()
end

function SkillHandleJumpBtnView:OnBtnRelease()
	self:SetRenderScale(OneVector2D)
	local MajorController = MajorUtil.GetMajorController()
    if not MajorController then
        return
    end
	 MajorController:NewJumpEnd()
end

function SkillHandleJumpBtnView:OnGamePadUpdateCombatType()
    local HandleButtonText = _G.SettingsHandleMgr:GetHandleInputActionTextByCusAction(SettingsHandleDefine.HandleCustomActionType.Jump)
	if HandleButtonText then
		self.HandleState:SetHandleButtonText(HandleButtonText)
	end
end

local IE_Pressed = _G.UE.EInputEvent.IE_Pressed
local IE_Released = _G.UE.EInputEvent.IE_Released

function SkillHandleJumpBtnView:OnGamePadJump(Params)
	if Params and Params.EventType == IE_Pressed then
        --由于关闭了BtnRun的输入，需要模拟点击的效果
        self:SetRenderScale(OneVector2D * 0.9)
    elseif Params and Params.EventType == IE_Released then
        self:SetRenderScale(OneVector2D)
    end
end

return SkillHandleJumpBtnView