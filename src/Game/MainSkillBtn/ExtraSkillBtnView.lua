---
--- Author: chriswang
--- DateTime: 2022-08-30 19:38
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MainSkillBaseView = require("Game/MainSkillBtn/MainSkillBaseView")
local ProtoRes = require ("Protocol/ProtoRes")
local SkillUtil = require("Utils/SkillUtil")
local TimeUtil = require("Utils/TimeUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")

local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local TriggerCDTickTime = 50 --ms
---@class ExtraSkillBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field EFF_Goup UCanvasPanel
---@field ExtraCD UFCanvasPanel
---@field Extra_CDMask URadialImage
---@field FImg_CDNormal UFImage
---@field FImg_Extra UFImage
---@field FImg_TimesBkg UFImage
---@field Icon_Extra UFImage
---@field SecondJoyStick SecondJoyStickView
---@field SkillEnergyStorage SkillEnergyStorageView
---@field TagTimes UFCanvasPanel
---@field Text_ExtraTimes UFTextBlock
---@field AnimAlternate UWidgetAnimation
---@field AnimChange UWidgetAnimation
---@field AnimClick UWidgetAnimation
---@field AnimHide UWidgetAnimation
---@field AnimImportLoop UWidgetAnimation
---@field AnimReady UWidgetAnimation
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ExtraSkillBtnView = LuaClass(MainSkillBaseView, true)

function ExtraSkillBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.EFF_Goup = nil
	--self.ExtraCD = nil
	--self.Extra_CDMask = nil
	--self.FImg_CDNormal = nil
	--self.FImg_Extra = nil
	--self.FImg_TimesBkg = nil
	--self.Icon_Extra = nil
	--self.SecondJoyStick = nil
	--self.SkillEnergyStorage = nil
	--self.TagTimes = nil
	--self.Text_ExtraTimes = nil
	--self.AnimAlternate = nil
	--self.AnimChange = nil
	--self.AnimClick = nil
	--self.AnimHide = nil
	--self.AnimImportLoop = nil
	--self.AnimReady = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ExtraSkillBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SecondJoyStick)
	-- self:AddSubView(self.SkillEnergyStorage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ExtraSkillBtnView:OnInit()
	self.Super:OnInit()
	self.bTriggerBtn = true
	self.IsTrigger = false
	self.IsShow = false
end

function ExtraSkillBtnView:OnDestroy()

end

function ExtraSkillBtnView:OnShow()

end

function ExtraSkillBtnView:OnHide()

end

function ExtraSkillBtnView:OnRegisterUIEvent()

end

function ExtraSkillBtnView:OnRegisterGameEvent()
	self.Super:OnRegisterGameEvent()
	-- --需要CD么
	-- if self.bMajor then
	-- 	self:RegisterGameEvent(EventID.SkillCDUpdateLua, self.OnSkillCDUpdate)
	-- end
end

function ExtraSkillBtnView:OnRegisterBinder()
	local Binders = {
		{"SkillIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon_Extra)},
		{"bCommonMask", UIBinderSetIsVisible.New(self, self.FImg_CDNormal)},
	}

	self:RegisterBinders(self.BaseBtnVM, Binders)
end


function ExtraSkillBtnView:OnGameEventMajorUseSkill(Params)
	if not self.LastCount then
		self.LastCount = 0
		FLOG_WARNING("ExtraSkillBtnView:OnGameEventMajorUseSkill,LastCount = nil")
	end
	self.LastCount = self.LastCount - 1
	if self.LastCount <= 0 then
		self:HideTriggerBtn(true)
	else
		self:PlayAnimation(self.AnimClick)
	end
end

function ExtraSkillBtnView:OnPlayerUseSkill(Params)
	self:PlayAnimation(self.AnimClick)
	-- self.Super:OnPlayerUseSkill(Params)	--技能系统应该不需要附加技，所以不触发了
end

--隐藏触发按钮
--bRealHide：true意味着按钮被真正取消触发，与服务器信息同步；反之则隐藏按钮，且在满足条件时重新显示，用于客户端表现
function ExtraSkillBtnView:HideTriggerBtn(bRealHide, bServerMsg)
	if self.IsShow == true and (self.CanUseCount > 0 or self.CanUseCount == 0 and bServerMsg) then
		if self:IsAnimationPlaying(self.AnimClick) == false then
			--使用动效隐藏技能会出现多种表现与逻辑上的问题
			--连招次数为0时，技能应当被隐藏，但动效拖延了技能的隐藏时间导致玩家能看到连招被替换为第一段
			--在播放隐藏动效期间显示触发按钮，会使按钮在显示后立刻隐藏，因此在显示触发按钮前调用了停止隐藏动效来解决

			--如果技能不是一个连招，将不会发生上述第二行问题，因此允许播放隐藏动画
			if _G.SkillSeriesMgr:FindSeriesSkillBaseID(self.BtnSkillID) == nil then
				if self:IsAnyAnimationPlaying() == true then
					self:StopAllAnimations()
				end
			else
				UIUtil.SetIsVisible(self, false)
			end
		else
			UIUtil.SetIsVisible(self, false)
		end
		self.IsShow = false
	end

	if bRealHide == true and self.IsTrigger == true then
		self.IsTrigger = false
		UIUtil.SetIsVisible(self, false)

		_G.SkillSeriesMgr:BreakSkill(self.BtnSkillID)
		if self.ExpireTimerID ~= nil then
			TimerMgr:CancelTimer(self.ExpireTimerID)
			self.ExpireTimerID = nil
		end
	end
end

--触发技能客户端显示
function ExtraSkillBtnView:ShowTriggerBtn()
	--显示触发技能时应先停止(如果有)隐藏动画以确保技能不会在显示后立即被隐藏
	--self:StopAnimation(self.Anim_Vanish)
	if self.IsTrigger == false then
		return
	end

	if self.IsShow == true then
		return
	end

	_G.UIUtil.SetIsVisible(self, true, true)
	self.IsShow = true
	if self.AnimReady ~= nil then
		self:PlayAnimation(self.AnimReady)
	end

	if self:IsAnimationPlaying(self.AnimLoop) == true then
		self:StopAnimation(self.AnimLoop)
	end
end

function ExtraSkillBtnView:OnAnimationFinished(Anim)
	if Anim == self.AnimReady then
		self:PlayAnimation(self.AnimLoop, 0, 0)
	end
end

function ExtraSkillBtnView:OnCastUpdatePerdueSkill(SkillID, ExpireTime, LastCount)
	self.BtnSkillID = SkillID
	self:ChangeSkillIcon(SkillID)
	self:OnUpdateTriggerSkill(ExpireTime, LastCount)
end

function ExtraSkillBtnView:OnUpdateTriggerSkill(ServerTargetTime, LastCount)
	self.IsTrigger = true
	-- self:OnSkillReadyShow(self.BtnSkillID)
	self:ShowTriggerBtn()
	self:ClearCDMask(false)

	--self.ExtraCD 外圈黄色的表示技能可以释放的时间，超时后技能会消失（哪怕还没有释放）
	if ServerTargetTime ~= 0 then
		if self.ExpireTimerID ~= nil then
			TimerMgr:CancelTimer(self.ExpireTimerID)
			self.ExpireTimerID = nil
			self.CurExpireTime = 0
		end
		local ServerTime = TimeUtil.GetServerTime() * 1000
		local ExpireTime = ServerTargetTime - ServerTime
		self.ServerTargetTime = ServerTargetTime
		if ExpireTime > 0 then
			UIUtil.SetIsVisible(self.ExtraCD, true)
			self.Extra_CDMask:SetPercent(1)
			self.CurExpireTime = ExpireTime
			local BaseCD = SkillMainCfg:FindValue(self.BtnSkillID, "SkillValidTime")
			self.ExpireTimerID = TimerMgr:AddTimer(self, self.ExtraSkillCDTick, 0, TriggerCDTickTime / 1000, 0, BaseCD)
		else
			self:HideTriggerBtn(true)
		end
	else
		UIUtil.SetIsVisible(self.ExtraCD, false)
	end

	self.LastCount = LastCount or 0
	self.CanUseCount = SkillMainCfg:FindValue(self.BtnSkillID, "SkillUseCount") or 0
	self.TriggerNumShowType = SkillMainCfg:FindValue(self.BtnSkillID, "TriggerNumShowType")
	if self.TriggerNumShowType == ProtoRes.TriggerNumShowType.TriggerNum_Default then
		UIUtil.SetIsVisible(self.TagTimes, true)
		self.Text_ExtraTimes:SetText(self.LastCount .. "/" .. self.CanUseCount)
	elseif self.TriggerNumShowType == ProtoRes.TriggerNumShowType.TriggerNum_OnlyLeft then
		UIUtil.SetIsVisible(self.TagTimes, true)
		self.Text_ExtraTimes:SetText(self.LastCount)
	else--if self.TriggerNumShowType == ProtoRes.TriggerNumShowType.TriggerNum_NoNum then
		UIUtil.SetIsVisible(self.TagTimes, false)
	end
end

function ExtraSkillBtnView:ExtraSkillCDTick(BaseCD)
	local ServerTime = TimeUtil.GetServerTime() * 1000
	if BaseCD == nil or ServerTime >= self.ServerTargetTime then
		self:HideTriggerBtn(true)
		return
	end

	if BaseCD == 0 then
		BaseCD = 5000
		FLOG_ERROR("ExtraSkillBtnView BaseCD don't config")
	end

	local LeftExpireTime = self.ServerTargetTime - ServerTime
	local Percent = LeftExpireTime / BaseCD
	self.Extra_CDMask:SetPercent(Percent)
end

--替换后的触发技能应判断当前资源值是否满足释放，不满足则隐藏
function ExtraSkillBtnView:OnSkillReplace(Params)
	if Params.SkillIndex ~= self.ButtonIndex then
		return
	end

	self.Super:OnSkillReplace(Params)
	-- self:OnSkillReadyShow(TargetSkillID)
	self:ShowTriggerBtn()
end

function ExtraSkillBtnView:OnResourcesChange(ResourcesType)
end

return ExtraSkillBtnView