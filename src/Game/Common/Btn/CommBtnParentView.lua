---
--- Author: anypkvcai
--- DateTime: 2023-03-27 17:07
--- Description:
--- 为了满足新需求及兼容之前的功能，新加了SetIsNormalState、SetIsRecommendState、SetIsDisabledState、SetIsDoneState接口
--- 建议后面都用新接口，支持灰色状态扔可以点击等，不要直接调用SetColorType等要传入颜色值的接口

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIDefine = require("Define/UIDefine")
local WidgetCallback = require("UI/WidgetCallback")

local CommBtnColorType = UIDefine.CommBtnColorType

local COLOR_ENABLE 		= "ffffffff"
local COLOR_RECOM		= "f5f0dfff"
local COLOR_DISABLE 	= "9e9c96ff"
local COLOR_DONE 		= "d5d5d5ff"
local COLOR_DONE_LIGHT	= "6c6964ff"

local COLOR_ENABLE_OUTLINE 		= "4d3a004c"
local COLOR_RECOM_OUTLINE		= "6a52334c"
local COLOR_DISABLE_OUTLINE 	= "3131314c"
local COLOR_DONE_OUTLINE 		= "0000004c"
local COLOR_DONE_LIGHT_OUTLINE	= "6c696400"

---@class CommBtnParentView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ParamColor CommBtnColorType
---@field ParamText text
---@field ParamDoneText text
---@field ImgNormalAssetPath string
---@field ImgRecommendAssetPath string
---@field ImgDisableAssetPath string
---@field ImgDoneAssetPath string
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommBtnParentView = LuaClass(UIView, true)

---Ctor
---@ParamColor 蓝图里设置的默认颜色  Normal 或 Recommend
function CommBtnParentView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ParamColor = nil
	--self.ParamText = nil
	--self.ParamDoneText = nil
	--self.ImgNormalAssetPath = nil
	--self.ImgRecommendAssetPath = nil
	--self.ImgDisableAssetPath = nil
	--self.ImgDoneAssetPath = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommBtnParentView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommBtnParentView:OnInit()
	--self.OnClicked = self.Button.OnClicked
	self.OnClicked = WidgetCallback.New()
	self:SetColorType(self.ParamColor)
	-- self:SetText(self.ParamText) -- Fixed 玩法那边在OnInit设置按钮文本不成功问题
	self.DoneCache = {} -- 缓存Done之前的状态以便恢复
end

function CommBtnParentView:OnDestroy()
	local OnClicked = self.OnClicked
	if nil ~= OnClicked then
		OnClicked:Clear()
		self.OnClicked = nil
	end
end

function CommBtnParentView:OnShow()
	-- self:SetColorType(self.ParamColor)
end

function CommBtnParentView:OnHide()
	self:EndCounterdown()
end

function CommBtnParentView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Button, self.OnClickedButton)
end

function CommBtnParentView:OnRegisterGameEvent()

end

function CommBtnParentView:OnRegisterBinder()

end

function CommBtnParentView:OnClickedButton()
	if self.ColorType == CommBtnColorType.Done then
		return
	end

	local OnClicked = self.OnClicked
	if nil ~= OnClicked then
		OnClicked:OnTriggered()
	end
end

---SetIsNormal
---@param IsNormal boolean
---@deprecated @建议统一用 SetIsNormalState接口
function CommBtnParentView:SetIsNormal(IsNormal)
	self.ParamColor = IsNormal and CommBtnColorType.Normal or CommBtnColorType.Recommend

	self:SetColorType(self.ParamColor)
end

--function CommBtnParentView:SetIsProgressBar(IsProgressBar)
--	if IsProgressBar then
--		self:SetColorType(CommBtnColorType.ProgressBar)
--	else
--		self:SetColorType(self.ParamColor)
--	end
--end

---SetText 设置按钮文字
---@param Text string
function CommBtnParentView:SetLongPress(Enable, Time, CB, Caller)
	self.ParamLongPress = Enable

	if Enable then
		
	end
end

---SetText 设置按钮文字
---@param Text string
function CommBtnParentView:SetText(Text)
	self.TextContent:SetText(Text)
end

---GetText
---@return string 获取按钮文字
function CommBtnParentView:GetText()
	return self.TextContent:GetText()
end

---SetIsEnabled 设置是否可用 不可用时按钮灰色 不能响应事件
---@param IsEnabled boolean @只控制颜色，不影响按钮点击事件
---@param IsHitTestVisible boolean @控制按钮是否可以点击，和颜色无关
function CommBtnParentView:SetIsEnabled(IsEnabled, IsHitTestVisible)
	self.IsHitTestVisibleEnable = IsHitTestVisible
	if IsEnabled then
		self:SetColorType(self.ParamColor)
	else
		self:SetColorType(CommBtnColorType.Disable)
	end
end

---SetIsDone
---@param IsDone boolean
---@param DoneText string
---@deprecated @建议统一用SetIsDoneState
function CommBtnParentView:SetIsDone(IsDone, DoneText)
	DoneText = DoneText or self.ParamDoneText
	self.DoneCache.Text = self:GetText()
	self.DoneCache.ColorType = self.ColorType

	if IsDone then
		self:SetColorType(CommBtnColorType.Done)
		self:SetText(DoneText)

	else 
		if self.DoneCache.Text then
			self:SetText(self.DoneCache.Text)
			self.DoneCache.Text = nil
		end

		if self.DoneCache.ColorType then
			self:SetColorType(self.DoneCache.ColorType)
			self.DoneCache.ColorType = nil
		end

	end
end

---SetColorType
---@param ColorType CommBtnColorType
---@private
function CommBtnParentView:SetColorType(ColorType)
	self:UpdateBtnEnable(ColorType)
	-- if ColorType == self.ColorType then 
	-- 	return
	-- end

	self.ColorType = ColorType
	self:UpdateColorType()
end

---UpdateColorType
---@private
function CommBtnParentView:UpdateColorType()
	self:UpdateImage(self.ColorType)
	self:UpdateTextColor(self.ColorType)
end

---UpdateImage
---@param ColorType CommBtnColorType
---@private
function CommBtnParentView:UpdateImage(ColorType)
	if CommBtnColorType.Normal == ColorType then
		UIUtil.ImageSetBrushFromAssetPath(self.Img, self.ImgNormalAssetPath)
	elseif CommBtnColorType.Recommend == ColorType then
		UIUtil.ImageSetBrushFromAssetPath(self.Img, self.ImgRecommendAssetPath)
	elseif CommBtnColorType.Disable == ColorType then
		UIUtil.ImageSetBrushFromAssetPath(self.Img, self.ImgDisableAssetPath)
	elseif  CommBtnColorType.Done == ColorType then
		if self.bUseLightStyleDone then 
			UIUtil.ImageSetBrushFromAssetPath(self.Img, self.ImgLightDoneAssetPath)
		else
			UIUtil.ImageSetBrushFromAssetPath(self.Img, self.ImgDoneAssetPath)
		end
	end
	
	UIUtil.SetIsVisible(self.Img, true)
end

---UpdateTextColor
---@param ColorType CommBtnColorType
---@private
function CommBtnParentView:UpdateTextColor(ColorType)
	if ColorType == CommBtnColorType.Disable then
		UIUtil.SetColorAndOpacityHex(self.TextContent, COLOR_DISABLE)
	elseif ColorType == CommBtnColorType.Done then
		if self.bUseLightStyleDone then 
			UIUtil.SetColorAndOpacityHex(self.TextContent, COLOR_DONE_LIGHT)
		else
			UIUtil.SetColorAndOpacityHex(self.TextContent, COLOR_DONE)
		end
	elseif ColorType == CommBtnColorType.Normal then 
		UIUtil.SetColorAndOpacityHex(self.TextContent, COLOR_ENABLE)
	elseif ColorType == CommBtnColorType.Recommend then 
		UIUtil.SetColorAndOpacityHex(self.TextContent, COLOR_RECOM)
	end

	self:UpdateTextColorOutline(ColorType)
end

function CommBtnParentView:UpdateTextColorOutline(ColorType)
	if ColorType == CommBtnColorType.Disable then
		UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextContent, COLOR_DISABLE_OUTLINE)
	elseif ColorType == CommBtnColorType.Done then
		if self.bUseLightStyleDone then 
			UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextContent, COLOR_DONE_LIGHT_OUTLINE)
		else
			UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextContent, COLOR_DONE_OUTLINE)
		end
	elseif ColorType == CommBtnColorType.Normal then 
		UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextContent, COLOR_ENABLE_OUTLINE)
	elseif ColorType == CommBtnColorType.Recommend then 
		UIUtil.TextBlockSetOutlineColorAndOpacityHex(self.TextContent, COLOR_RECOM_OUTLINE)
	end
end

---UpdateBtnEnable
---@param ColorType CommBtnColorType
---@private
function CommBtnParentView:UpdateBtnEnable(ColorType)
	UIUtil.SetIsVisible(self.Button, true, true)

	if ColorType == CommBtnColorType.Disable then
		if not self.IsHitTestVisibleEnable then
			self.Button:SetIsEnabled(false)
		else
			self.Button:SetIsEnabled(true)
		end
	elseif ColorType == CommBtnColorType.Done then
		self.Button:SetVisibility( _G.UE.ESlateVisibility.selfHitTestInvisible)

		-- if self.bUseLightStyleDone then
		-- 	self.Button:SetIsEnabled(true)
		-- 	-- UIUtil.SetIsVisible(self.Button, false)
		-- else
		-- 	self.Button:SetIsEnabled(false)
		-- end
	else
		self.Button:SetIsEnabled(true)
	end
end

function CommBtnParentView:SetCounterdown(Time, EnableColor, Callback)
	self:EndCounterdown()

	self.CDInfo = {
		Time = Time,
		StartTime = _G.TimeUtil.GetServerTime(),
		EnableColor = EnableColor or self.ColorType,
		Text = self:GetText(),
		Callback = Callback,
	}

	self:SetIsEnabled(false)
	self:StartCounterdown()
end

function CommBtnParentView:StartCounterdown()
	self.CDInfo.TimerHdl = self:RegisterTimer(self.OnCounterdown, 0, 1, 0)
end

function CommBtnParentView:OnCounterdown(_, ElapsedTime)
	if self.CDInfo then
		local CDTime = self.CDInfo.Time or 0

		local Callback = self.CDInfo.Callback
		if Callback ~= nil then
			Callback(CDTime - ElapsedTime)

		else
			local Now = _G.TimeUtil.GetServerTime()
			local Delta = Now - self.CDInfo.StartTime
			if Delta >= CDTime then
				self:EndCounterdown()
			else
				local Text = string.format("%s %s", self.CDInfo.Text, tostring(math.floor((self.CDInfo.Time - Delta) + 0.5)))
				self:SetText(Text)
			end
		end
	end
end

function CommBtnParentView:EndCounterdown()
	if self.CDInfo and self.CDInfo.TimerHdl then
		self:UnRegisterTimer(self.CDInfo.TimerHdl)
		self:SetText(self.CDInfo.Text)
		self:SetColorType(self.CDInfo.EnableColor)
		self.CDInfo = nil
	end
end

---SetIsNormalState
---@param bNormalState boolean
function CommBtnParentView:SetIsNormalState(bNormalState)
	if bNormalState then
		self:SetColorType(CommBtnColorType.Normal)
	else
		self:SetColorType(self.ParamColor)
	end
end

---SetIsRecommendState
---@param bRecommendState boolean
function CommBtnParentView:SetIsRecommendState(bRecommendState)
	if bRecommendState then
		self:SetColorType(CommBtnColorType.Recommend)
	else
		self:SetColorType(self.ParamColor)
	end
end

---SetIsDisabledState
---@param bDisabledState boolean @只控制是否显示灰色，和是否能点击无关
---@param bDisabledState boolean @控制是否点击， 灰色状态也支持能点击
function CommBtnParentView:SetIsDisabledState(bDisabledState, IsHitTestEnable)
	self.IsHitTestVisibleEnable = IsHitTestEnable
	if bDisabledState then
		self:SetColorType(CommBtnColorType.Disable)
	else
		self:SetColorType(self.ParamColor)
	end
end

---SetIsDoneState
---@param bDoneState boolean
function CommBtnParentView:SetIsDoneState(bDoneState, DoneText)
	self:SetIsDone(bDoneState, DoneText)
end

---强制设置按钮释放动画结束
function CommBtnParentView:SetReleaseAnimEnd()
	if nil ~= self.AnimReleased then
		local EndTime = self.AnimReleased:GetEndTime()
		self:PlayAnimationTimeRangeToEndTime(self.AnimReleased, EndTime)
	end
end
return CommBtnParentView