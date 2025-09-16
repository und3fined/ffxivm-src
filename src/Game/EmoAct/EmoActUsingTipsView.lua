---
--- Author: Administrator
--- DateTime: 2023-09-13 14:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local EventID = require("Define/EventID")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")
local EmotionCfg = require("TableCfg/EmotionCfg")
local EmotionMgr = require("Game/Emotion/EmotionMgr")
local CommonUtil = require("Utils/CommonUtil")

---@class EmoActUsingTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgBanner UFImage
---@field ImgBar UFImage
---@field ImgEmoj UFImage
---@field ImgPic UFImage
---@field RichTextMeet URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActUsingTipsView = LuaClass(UIView, true)

function EmoActUsingTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgBanner = nil
	--self.ImgBar = nil
	--self.ImgEmoj = nil
	--self.ImgPic = nil
	--self.RichTextMeet = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActUsingTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActUsingTipsView:OnInit()
	self.ShowTime = 2.0    --显示时间
	self.Interval = 0.02    --调整频率
	self.ScreenLocation = _G.UE.FVector2D()
	self.DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)  --获取视口大小
	self.DPIScale = (self.DPIScale == 0) and 1 or self.DPIScale
end

-- ---注册计时器
-- function EmoActUsingTipsView:OnRegisterTimer()
-- 	self.Super:OnRegisterTimer()
-- 	self:RegisterTimer(self.OnTimer, self.ShowTime, 0, 1)
-- end

-- ---计时器
-- function EmoActUsingTipsView:OnTimer()
-- 	print("EmoActShowTipsView:OnTimer:ShowTime = 2.0 s")
-- 	_G.UIViewMgr:HideView(_G.UIViewID.EmotionUsingTips)
-- end

---注册计时器
function EmoActUsingTipsView:OnRegisterTimer()
	self.Super:OnRegisterTimer()
--	self:RegisterTimer(self.OnTimer, 0.0, self.Interval, self.ShowTime / self.Interval + 1)
end

---计时器(实时调整Tips的位置)
function EmoActUsingTipsView:OnTimer()
	self.ShowTime = self.ShowTime - self.Interval
	if self.ShowTime >= 0 then
		if self.Params ~= nil then
			self:UpdatePos(self.Params.EntityID)
		end
		return
	end
	self.ScreenLocation = _G.UE.FVector2D(0)
	_G.UIViewMgr:HideView(_G.UIViewID.EmotionUsingTips)
end

function EmoActUsingTipsView:OnDestroy()
end

function EmoActUsingTipsView:OnHide()
	self.Params = nil
	self.ShowTime = 2.0
	self.ScreenLocation = _G.UE.FVector2D(0)
end

function EmoActUsingTipsView:OnShow()
	local EmotionID = self.Params.EmotionID
	local EntityID = self.Params.EntityID
	if EmotionID == EmotionMgr.EXD_EMOTE_BAjAFIRE then
		self.Interval = 0.01
	end
	self:RegisterTimer(self.OnTimer, 0.0, self.Interval, self.ShowTime / self.Interval + 1)

	self:UpdatePos(EntityID)
	self:SetIcon(EmotionID)
	if self.RichTextMeet ~= nil then
		self.RichTextMeet:SetText(self.Params.TipsDesc)
	end
end

function EmoActUsingTipsView:SetText(EmotionID, EntityID)
	local TargetID = self.Params.TargetID
	
	if TargetID == nil or TargetID == 0 then  		--没有选中目标
		self:NoTargetTips()

	else
		local CompanionName = EmotionMgr:GetCompanionName(TargetID, self.Params.IDType)
		if CompanionName ~= nil then				--选中宠物
			self:TargetTips(EmotionID, TargetID, CompanionName)
		elseif TargetID ~= EntityID then 			--选中其他玩家
			local TargetName = ActorUtil.GetActorName(TargetID)
			self:TargetTips(EmotionID, TargetID, TargetName)

		elseif TargetID == EntityID then 			--选中自身
			self:NoTargetTips()

		end
	end
end

--- 无选中目标
function EmoActUsingTipsView:NoTargetTips()
	local MyName = ActorUtil.GetActorName(self.Params.EntityID)
	local EmotionDesc = self.Params.TipsText
	EmotionDesc = self:MatchStringPatern(EmotionDesc)
	if string.isnilorempty(EmotionDesc) then
		UIUtil.SetIsVisible(self, false)
		return
	end
	
	local TipsDesc = string.format("<span color=\"#%s\">%s</>", "FFFFFF", EmotionDesc)  --头顶气泡字体的颜色
	local ChatDesc = string.format("<span color=\"%s\">%s</>", "#c6c6c6", EmotionDesc)--附近聊天字体颜色
	MyName = string.format("<span color=\"#%s\">%s</>", "7ecef4", MyName)		     	  --修改自己名字的颜色
	if self.RichTextMeet ~= nil then
		self.RichTextMeet:SetText(TipsDesc)  		  	 ---将文本信息显示在人物头顶
	end
	if nil ~= self.ChatTimeID then
		_G.TimerMgr:CancelTimer(self.ChatTimeID)
		self.ChatTimeID = nil
	end
	self.ChatTimeID = _G.TimerMgr:AddTimer(self, function()
		EmotionMgr:SendChatMessage(MyName .. ChatDesc)  	 ---附近频道发送聊天消息
	end, 0.5, 0, 1)
end

--- 有选中目标
function EmoActUsingTipsView:TargetTips(EmotionID, TargetID, TargetName)
	local MyName = ActorUtil.GetActorName(self.Params.EntityID)

	local EmotionDescPrefix, EmotionDesc = EmotionMgr:GetEmotionDesc(TargetID, EmotionID)
	EmotionDesc = self:MatchStringPatern(EmotionDesc)
	if EmotionDesc == nil and EmotionDescPrefix == nil or EmotionDesc == "" and EmotionDescPrefix == "" then
		UIUtil.SetIsVisible(self, false)
		return
	end

	local ChatDescPrefix, ChatDesc
	do
		local _ <close> = CommonUtil.MakeProfileTag("EmoActUsingTipsView:RichTextMeet:SetText")

		local TipsDesc = string.format("<span color=\"#%s\">%s</>", "FFFFFF", EmotionDesc)--头顶气泡颜色
		local TipsDescPrefix = string.format("<span color=\"#%s\">%s</>", "FFFFFF", EmotionDescPrefix)
		ChatDesc = string.format("<span color=\"%s\">%s</>", "#c6c6c6", EmotionDesc)--附近聊天颜色
		ChatDescPrefix = string.format("<span color=\"%s\">%s</>", "#c6c6c6", EmotionDescPrefix)
		MyName = string.format("<span color=\"#%s\">%s</>", "7ecef4", MyName)
		TargetName = string.format("<span color=\"#%s\">%s</>", "83cb68", TargetName)
		if self.RichTextMeet == nil then
			return
		end 
		self.RichTextMeet:SetText(TipsDescPrefix .. TargetName .. TipsDesc)  		  		 ---将文本信息显示在人物头顶
	end

	local _ <close> = CommonUtil.MakeProfileTag("EmoActUsingTipsView:RichTextMeet:SendChatMessage")
	EmotionMgr:SendChatMessage(MyName .. ChatDescPrefix .. TargetName .. ChatDesc)  	 ---向附近频道发送聊天消息
end

--- 设置显示的情感动作图标
function EmoActUsingTipsView:SetIcon(EmotionID)
	local Emotion = EmotionCfg:FindCfgByKey(EmotionID)
	if self.ImgEmoj and not string.isnilorempty(Emotion.IconPath) then
		UIUtil.ImageSetBrushFromAssetPath(self.ImgEmoj, EmotionUtils.GetEmoActIconPath(Emotion.IconPath))
	end
end

---将UI显示在人物头顶
function EmoActUsingTipsView:UpdatePos(CharacterID)
	if CharacterID == nil then return end
	local FromActor = ActorUtil.GetActorByEntityID(CharacterID)
	if FromActor == nil then return end
	local ActorInfo = _G.HUDMgr:GetActorInfoObject(CharacterID)
	if ActorInfo == nil then return end
	local NameLocation = _G.UE.FVector(0, 0, 0)
	local Success = ActorInfo:GetTopLocation(NameLocation)  	--名字的场景位置
	if Success == false then return end
		
	-- --若有实时偏移了名字位置时，需要根据名字位置调整UI
	-- if EmotionMgr.IsNameOffset == true and EmotionMgr.NameScreenLocation ~= nil then
	-- 	self.ScreenLocation = EmotionMgr.NameScreenLocation / self.DPIScale
	-- 	self.ScreenLocation.Y = self.ScreenLocation.Y - 110 * self.DPIScale
		
	-- 	local ScreenLocX = _G.UE.FVector2D()
	-- 	UIUtil.ProjectWorldLocationToScreen(NameLocation, ScreenLocX)
	-- 	ScreenLocX = ScreenLocX / self.DPIScale --名字的屏幕位置
	-- 	self.ScreenLocation.X = ScreenLocX.X	--固定X轴水平位置
		
	-- 	self.Slot:SetPosition(self.ScreenLocation)
	-- 	return
	-- end
	
	--将UI固定在名字上方
	UIUtil.ProjectWorldLocationToScreen(NameLocation, self.ScreenLocation)
	self.DPIScale = tonumber(string.format("%.3f", self.DPIScale))
	self.ScreenLocation.Y = self.ScreenLocation.Y - 120 * self.DPIScale
	self.ScreenLocation = self.ScreenLocation / self.DPIScale   --名字的屏幕位置
	self.ScreenLocation.X = tonumber(string.format("%.1f", self.ScreenLocation.X))
	self.ScreenLocation.Y = tonumber(string.format("%.1f", self.ScreenLocation.Y))
	self.Slot:SetPosition(self.ScreenLocation)
end

function EmoActUsingTipsView:OnGameEventPostEmotionEnd(InParams)
	-- local FromID = InParams.ULongParam1
	-- local TargetID = InParams.ULongParam2
	-- local EmotionID = InParams.IntParam1

	-- if FromID == self.Params.EntityID and TargetID == self.Params.TargetID and EmotionID == self.Params.EmotionID then
	-- 	if not self.bMajorHit then
	-- 		_G.UIViewMgr:HideView(_G.UIViewID.EmotionUsingTips)
	-- 	end
	-- end
end

function EmoActUsingTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PostEmotionEnd, self.OnGameEventPostEmotionEnd)
	self:RegisterGameEvent(EventID.MajorHit, self.OnGameEventMajorHit)
end

--- 被攻击受伤不停止气泡
function EmoActUsingTipsView:OnGameEventMajorHit(Params)
	local HitEntityID = Params.ULongParam1
	if self.Params then
		if HitEntityID == self.Params.EntityID then
			self.bMajorHit = true
		else
			self.bMajorHit = false
		end
	end
end

--- 获取主角与屏幕的距离、视角 (这里没有找到弹簧臂)
function EmoActUsingTipsView:GetDistance(CharacterID)
	local FromActor = ActorUtil.GetActorByEntityID(CharacterID)
	FromActor = FromActor:Cast(_G.UE.ABaseCharacter)
	if FromActor ~= nil then
		local WorldPosition = _G.UE.FVector()
		local WorldDirection = _G.UE.FVector()
		local RotationAt = _G.UE.FVector()
		local DistanceLocation

		UIUtil.DeprojectScreenToWorld(self.ScreenLocation, WorldPosition, WorldDirection)
		DistanceLocation = _G.UE.UKismetMathLibrary.Vector_Distance(WorldPosition, FromActor:K2_GetActorLocation())
		RotationAt = _G.UE.UKismetMathLibrary.FindLookAtRotation(WorldPosition, FromActor:K2_GetActorLocation())
	
		return DistanceLocation, math.abs(RotationAt.Pitch)
	end
    return 0, 0
end

return EmoActUsingTipsView