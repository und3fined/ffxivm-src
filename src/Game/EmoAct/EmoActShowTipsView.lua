---
--- Author: moodliu
--- DateTime: 2021-12-07 13:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local EmotionCfg = require("TableCfg/EmotionCfg")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")

---@class EmoActShowTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon_Emoj UFImage
---@field Img_TipsBkg UFImage
---@field Text_EmoName UFTextBlock
---@field Text_Meet UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActShowTipsView = LuaClass(UIView, true)

function EmoActShowTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon_Emoj = nil
	--self.Img_TipsBkg = nil
	--self.Text_EmoName = nil
	--self.Text_Meet = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EmoActShowTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActShowTipsView:OnInit()
	self.ShowTime = 2.0
	self.ScreenLocation = _G.UE.FVector2D()
	self.DPIScale = _G.UE.UWidgetLayoutLibrary.GetViewportScale(self)  --获取视口大小
end

function EmoActShowTipsView:OnDestroy()
end

function EmoActShowTipsView:OnShow()
	local TargetID = self.Params.TargetID
	if TargetID == 0 then
		TargetID = nil
	end
	local EmotionID = self.Params.EmotionID
	local EmotionDescPrefix, EmotionDesc = _G.EmotionMgr:GetEmotionDesc(TargetID, EmotionID)
	local Pattern = "[%s.。]+$"  -- 匹配字符串末尾所有空白字符和标点符号的正则表达式

	if string.match(EmotionDesc, Pattern) then
		EmotionDesc = string.gsub(EmotionDesc, Pattern, "") -- 用空字符串替换匹配到的末尾标点符号
	end

	UIUtil.SetIsVisible(self.Text_Meet, TargetID and true or false)
	self.Text_Meet:SetText(TargetID and EmotionDescPrefix .. ActorUtil.GetActorName(TargetID) or "")  --设置对其他玩家情感显示的文字
	self.Text_EmoName:SetText(EmotionDesc)  --设置情感动作在屏幕上显示的文字，UMG中控件文本“Text_EmoName”

	local Emotion = EmotionCfg:FindCfgByKey(EmotionID)
	local IconPath = Emotion.IconPath  --获取图片路径

	--异步加载图片，设置UMG中图像控件“Icon_Emoj”的图片
	UIUtil.ImageSetBrushFromAssetPath(self.Icon_Emoj, EmotionUtils.GetEmoActIconPath(IconPath))
end

function EmoActShowTipsView:OnRegisterTimer()   --注册计时器
	self.Super:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, self.ShowTime, 0, 1)
end

function EmoActShowTipsView:OnTimer()  --计时器
	print("EmoActShowTipsView:OnTimer")
	-- self:SetVisible(false)
	-- self:HideView(self.Params)
	UIUtil.SetIsVisible(self, false)
end

---将UI显示在人物头顶，其会保证最⼤的Tips显示数量为5。
function EmoActShowTipsView:UpdatePos()
	local FromActor = ActorUtil.GetActorByEntityID(self.Params.EntityID)
	if FromActor then
		local OffsetFactor = 1.2  --显示高度权重参数
		UIUtil.ProjectWorldLocationToScreen(FromActor:FGetActorLocation() +
			_G.UE.FVector(0, 0, FromActor:GetCapsuleHalfHeight()) * OffsetFactor, self.ScreenLocation)   --获取人物头顶世界位置转为屏幕位置
		self.Slot:SetPosition(self.ScreenLocation / self.DPIScale)   --设置UI在屏幕上的位置
	end
end

function EmoActShowTipsView:OnHide()

end

function EmoActShowTipsView:OnRegisterUIEvent()

end

function EmoActShowTipsView:OnGameEventPostEmotionEnd(InParams)
	local FromID = InParams.ULongParam1
	local TargetID = InParams.ULongParam2
	local EmotionID = InParams.IntParam1

	if FromID == self.Params.EntityID and TargetID == self.Params.TargetID and EmotionID == self.Params.EmotionID then
		self:OnTimer()
	end
end

function EmoActShowTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PostEmotionEnd, self.OnGameEventPostEmotionEnd)
end

function EmoActShowTipsView:OnRegisterBinder()

end

return EmoActShowTipsView