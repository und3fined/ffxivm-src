---
--- Author: anypkvcai
--- DateTime: 2023-03-27 17:13
--- Description:
---

local WidgetCallback = require("UI/WidgetCallback")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommBtnParentView = require("Game/Common/Btn/CommBtnParentView")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class CommBtnLView : CommBtnParentView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field Img UFImage
---@field ProBarLongPress UProgressBar
---@field TextContent UFTextBlock
---@field AnimLongClickReleased UWidgetAnimation
---@field AnimPressed UWidgetAnimation
---@field AnimReleased UWidgetAnimation
---@field ParamLongPress bool
---@field ParamPressTime float
---@field bAutoAddSpace bool
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBtnLView = LuaClass(CommBtnParentView, true)

function CommBtnLView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.Img = nil
	--self.ProBarLongPress = nil
	--self.TextContent = nil
	--self.AnimLongClickReleased = nil
	--self.AnimPressed = nil
	--self.AnimReleased = nil
	--self.ParamLongPress = nil
	--self.ParamPressTime = nil
	--self.bAutoAddSpace = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	self.IsLongPressFinished = false
end

function CommBtnLView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBtnLView:OnInit()
	self:SetImgAssetPath()
	self.Super:OnInit()

	if self.ParamLongPress then
		self.OnLongPressed = WidgetCallback.New()
		self.ProBarLongPress:SetPercent(0)
		UIUtil.ImageSetBrushFromAssetPath(self.Img, self.ImgDoneAssetPath)
		UIUtil.SetIsVisible(self.ProBarLongPress, true)
	else
		UIUtil.SetIsVisible(self.ProBarLongPress, false)
	end
end

function CommBtnLView:OnDestroy()
	if nil ~= self.OnLongPressed then
		self.OnLongPressed:Clear()
		self.OnLongPressed = nil
	end
	self.Super:OnDestroy()
end

function CommBtnLView:OnShow()
	self.Super:OnShow()

	self.ProBarLongPress:SetPercent(0)
	if(self.bAutoAddSpace == true) then
		UIUtil.AutoAddSpaceForTwoWords(self.TextContent)
	end
	---初始化时播放Released动画的结尾，防止上一次动画异常中断导致的按钮表现异常
	self:SetReleaseAnimEnd()
end

function CommBtnLView:OnHide()

end

function CommBtnLView:OnRegisterUIEvent()
	self.Super:OnRegisterUIEvent()

	UIUtil.AddOnPressedEvent(self, self.Button, self.OnPressedButton)
	UIUtil.AddOnReleasedEvent(self, self.Button, self.OnReleasedButton)

	UIUtil.AddOnClickedEvent(self, self.Button, self.OnClickButtonItem)
end

function CommBtnLView:OnRegisterGameEvent()

end

function CommBtnLView:OnRegisterBinder()
	--[[local Params = self.Params
	if nil == Params then return end

	if type(Params) ==  "table" then
		local ViewModel = Params.Data
		if nil == ViewModel then return end
		

		local Binders = {
			{ "Name", UIBinderSetText.New(self, self.TextContent) },
		}

		self:RegisterBinders(ViewModel, Binders)
	end]]--

end

function  CommBtnLView:SetBtnName(Name)
	self.TextContent:SetText(Name or "")
end


function CommBtnLView:OnPressedButton()
	self:PlayAnimation(self.AnimPressed)
	if not self.ParamLongPress then
		return
	end

	self.IsLongPressFinished = false

	self:UnRegisterAllTimer()

	self:RegisterTimer(self.OnTimer, 0, 0.05, 0)

	self.ProBarLongPress:SetPercent(0)
end

function CommBtnLView:OnReleasedButton()
	if not self.IsLongPressFinished then
		self:PlayAnimation(self.AnimReleased)
	end
	if not self.ParamLongPress then
		return
	end

	if not self.IsLongPressFinished then
		self:UnRegisterAllTimer()

		self.ProBarLongPress:SetPercent(0)
	end
end

function CommBtnLView:OnTimer(_, ElapsedTime)
	local Time = self.ParamPressTime
	if ElapsedTime < Time then
		self.ProBarLongPress:SetPercent(ElapsedTime / Time)
	else
		self.IsLongPressFinished = true
		self:PlayAnimation(self.AnimLongClickReleased)
		self.ProBarLongPress:SetPercent(1)

		self:UnRegisterAllTimer()
	end
end

function CommBtnLView:OnAnimationFinished(Animation)
	if nil == self.OnLongPressed then
		return
	end

	if Animation == self.AnimLongClickReleased and self.IsLongPressFinished then
		self.OnLongPressed:OnTriggered()
	end
end

function CommBtnLView:SetButtonText(Text)
	self.TextContent:SetText(Text)
end

function CommBtnLView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

function CommBtnLView:SetTextColorAndOpacityHex(Color)
	UIUtil.SetColorAndOpacityHex(self.TextContent, Color)
end

return CommBtnLView