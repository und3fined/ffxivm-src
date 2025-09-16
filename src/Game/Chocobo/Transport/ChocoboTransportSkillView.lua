---
--- Author: sammrli
--- DateTime: 2024-06-20 11:57
--- Description:陆行鸟运输技能按钮面板
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local EventID = require("Define/EventID")

local UIUtil = require("Utils/UIUtil")
local TimeUtil = require("Utils/TimeUtil")
local SkillUtil = require("Utils/SkillUtil")

local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local ChocoboTransportDefine = require("Game/Chocobo/Transport/ChocoboTransportDefine")

local TICK_INTERVAL = ChocoboTransportDefine.TICK_INTERVAL
local TIME_ACCE_SKILL_CD = ChocoboTransportDefine.TIME_ACCE_SKILL_CD

---@class ChocoboTransportSkillView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnDown UFButton
---@field BtnSprint UFButton
---@field ImgCD URadialImage
---@field ImgCall UFImage
---@field PanelCall UFCanvasPanel
---@field PanelSkillNew UFCanvasPanel
---@field SkillChocoboAttackBtn SkillChocoboAttackBtnView
---@field SkillMountBtn SkillMountBtnView
---@field SkillMusicBtn SkillMusicBtnView
---@field TextCD UTextBlock
---@field ToggleBtnRide UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboTransportSkillView = LuaClass(UIView, true)

function ChocoboTransportSkillView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnDown = nil
	--self.BtnSprint = nil
	--self.ImgCD = nil
	--self.ImgCall = nil
	--self.PanelCall = nil
	--self.PanelSkillNew = nil
	--self.SkillChocoboAttackBtn = nil
	--self.SkillMountBtn = nil
	--self.SkillMusicBtn = nil
	--self.TextCD = nil
	--self.ToggleBtnRide = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboTransportSkillView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SkillChocoboAttackBtn)
	--self:AddSubView(self.SkillMountBtn) --注释，不用坐骑的GetDown逻辑
	self:AddSubView(self.SkillMusicBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboTransportSkillView:OnInit()
	self.MaxAcceSkillID = 1
	self.TimerAcceID = nil
	self.IsJump = false
end

function ChocoboTransportSkillView:OnDestroy()

end

function ChocoboTransportSkillView:OnShow()
	local bFly = _G.ChocoboTransportMgr:IsFlyMode()
	--UIUtil.SetIsVisible(self.BtnDown, true, true)
	UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Btn_Attack, true, not bFly)
	UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Img_CD, false)
	UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Text_SkillCD, false)
	self.SkillChocoboAttackBtn:SetDisabled(bFly)
end

function ChocoboTransportSkillView:OnHide()
	self.TimerAcceID = nil
end

function ChocoboTransportSkillView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.SkillMountBtn.BtnRun, self.OnClickBtnDown)
	UIUtil.AddOnClickedEvent(self, self.SkillChocoboAttackBtn.Btn_Attack, self.OnClickBtnSprint)
	--UIUtil.AddOnClickedEvent(self, self.ToggleBtnRide, self.OnClickBtnRide)
	SkillUtil.RegisterPressScaleEvent(self, self.SkillChocoboAttackBtn.Btn_Attack, SkillCommonDefine.SkillBtnClickFeedback)
end

function ChocoboTransportSkillView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.SkillSetSkillCD, self.OnSkillSetSkillCD)
end

function ChocoboTransportSkillView:OnRegisterBinder()

end

function ChocoboTransportSkillView:OnClickBtnSprint()
	if _G.ChocoboTransportMgr:IsFlyMode() then
		return
	end
	_G.ChocoboTransportMgr:DoAccelerationSkill()
end

function ChocoboTransportSkillView:OnClickBtnRide()
	if not _G.ChocoboTransportMgr:GetIsCanUseSkill() then
		return
	end

	_G.ChocoboTransportMgr:CancelTrasport()
end

function ChocoboTransportSkillView:OnClickBtnDown()
	if not _G.ChocoboTransportMgr:GetIsTransporting() then
		_G.ChocoboTransportMgr:CancelTrasport()
		return
	end

	if not _G.ChocoboTransportMgr:GetIsCanUseSkill() then
		return
	end

	_G.ChocoboTransportMgr:CancelTrasport()
end

function ChocoboTransportSkillView:OnJumpEnd()
	self.IsJump = false
end

function ChocoboTransportSkillView:OnAcceSkillCDTick()
	local CDTimeMS = (self.TimeMSClearCD - TimeUtil.GetServerTimeMS()) * 0.001
	if CDTimeMS < 0 then
		if self.TimerAcceID then
			self:UnRegisterTimer(self.TimerAcceID)
			self.TimerAcceID = nil
		end
		UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Btn_Attack, true, true)
		UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Img_CD, false)
		UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Text_SkillCD, false)
		return
	end
	local Percent = CDTimeMS / self.MaxAcceSkillID
	self.SkillChocoboAttackBtn.Img_CD:SetPercent(1 - Percent)
	local Second = math.ceil(CDTimeMS)
	self.SkillChocoboAttackBtn.Text_SkillCD:SetText(tostring(Second))
end

function ChocoboTransportSkillView:OnSkillEnd()
end

function ChocoboTransportSkillView:OnSkillSetSkillCD(Param)
	self.MaxAcceSkillID = math.max(1,  Param.BaseCD or TIME_ACCE_SKILL_CD)
	local TimeAcceSkillCD = (Param.SkillCD or TIME_ACCE_SKILL_CD)
	self.TimeMSClearCD = TimeUtil.GetServerTimeMS() + TimeAcceSkillCD * 1000
	self.SkillChocoboAttackBtn.Img_CD:SetPercent(0)
	self.SkillChocoboAttackBtn.Text_SkillCD:SetText(tostring(TimeAcceSkillCD))
	UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Btn_Attack, true, false)
	UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Img_CD, true)
	UIUtil.SetIsVisible(self.SkillChocoboAttackBtn.Text_SkillCD, true)

	if self.TimerAcceID then
		self:UnRegisterTimer(self.TimerAcceID)
	end
	self.TimerAcceID = self:RegisterTimer(self.OnAcceSkillCDTick, 0, TICK_INTERVAL, -1)
end

return ChocoboTransportSkillView