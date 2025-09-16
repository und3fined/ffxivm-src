---
--- Author: Administrator
--- DateTime: 2023-09-19 19:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EmotionUtils = require("Game/Emotion/Common/EmotionUtils")
local EmoActPanelVM = require("Game/EmoAct/EmoActPanelVM")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local EmotionMgr = require("Game/Emotion/EmotionMgr")
local UIBinderSetText = require("Binder/UIBinderSetText")
local EmotionDefines = require("Game/Emotion/Common/EmotionDefines")
local CommonUtil = require("Utils/CommonUtil")

---@class EmoActSlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnSlot UFButton
---@field CommonRedDot2 CommonRedDot2View
---@field IconTask UFImage
---@field ImgDisable UFImage
---@field ImgFavorite UFImage
---@field ImgIcon UFImage
---@field ImgName UFTextBlock
---@field ImgSelect UFImage
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EmoActSlotView = LuaClass(UIView, true)

function EmoActSlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnSlot = nil
	--self.CommonRedDot2 = nil
	--self.IconTask = nil
	--self.ImgDisable = nil
	--self.ImgFavorite = nil
	--self.ImgIcon = nil
	--self.ImgName = nil
	--self.ImgSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY

	self.bEnableItem = nil  	 --设置启用可点击
end

function EmoActSlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommonRedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EmoActSlotView:OnInit()

end

function EmoActSlotView:OnHide()
	self.bEnableItem = nil
	if self.TimerIDs then
		for _, TimerID in pairs(self.TimerIDs) do
			if TimerID then
				_G.TimerMgr:CancelTimer(TimerID)
			end
		end
		self.TimerIDs = nil
	end
end

function EmoActSlotView:OnShow()
	if self:IsNull() then
		self:NullSlot()	--空格
	else
		UIUtil.SetIsVisible(self, true, true)
		UIUtil.SetIsVisible(self.ImgSelect, false)
	end
end

function EmoActSlotView:OnRegisterBinder()
	if self.Binders == nil then
		self.Binders = {
			{ "bIsFavorite", UIBinderValueChangedCallback.New(self, nil, self.SetFavoriteEmotion) },
			{ "EmotionShowQuestID", UIBinderValueChangedCallback.New(self, nil, self.SetShowQuestIcon) },
		}
	end
	self:RegisterBinders(EmoActPanelVM, self.Binders)

	if self.Params.Data then
		if self.Binders2 == nil then
			self.Binders2 = {
				{ "EmotionName", UIBinderSetText.New(self, self.ImgName) },
				{ "ID", UIBinderValueChangedCallback.New(self, nil, self.OnEmotionIDChanged) },
				{ "IconPath", UIBinderValueChangedCallback.New(self, nil, self.OnIconPathChanged) },
			}
		end
		self:RegisterBinders(self.Params.Data, self.Binders2)
	end
end

function EmoActSlotView:OnEmotionIDChanged()
	self:SetEnable( EmoActPanelVM.CanUseList[self.Params.Data.ID])
	self:SetSelectVisibity(false)

	--配置红点路径
	if self.Params.Data.ID and self.CommonRedDot2 then
		local TabNum = EmoActPanelVM:GetEmotionFilter()
		local TabName = EmotionDefines.TabKeyRedDots[TabNum - 1]
		if string.isnilorempty(TabName) then return end
		local RedDotName = string.format( "%s/%s", TabName, self.Params.Data.ID)
		UIUtil.SetIsVisible( self.CommonRedDot2, true )
		self.CommonRedDot2:SetRedDotNameByString(RedDotName)
	end

	--显示任务情感动作U
	self:SetShowQuestIcon(EmoActPanelVM.EmotionShowQuestID)
end

function EmoActSlotView:OnIconPathChanged()
	local IconPath = self.Params.Data.IconPath
	if not string.isnilorempty(IconPath) then
		if self.ImgIcon then
			UIUtil.SetIsVisible(self.ImgIcon, true, true, true)
			UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, EmotionUtils.GetEmoActIconPath(IconPath))
			self:SetFavoriteEmotion()
			return
		end
	end
	if self.Params.Data.ID then
		print("[EmoActSlotView] ID =",self.Params.Data.ID,"Path is = (",IconPath,")widget:",self.ImgIcon)
	end
end

function EmoActSlotView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSlot, self.RequiredIcon)
end

--- 显示收藏图标
function EmoActSlotView:SetFavoriteEmotion()
	if self:IsNull() then
		return
	end
	if self.ImgFavorite then
		UIUtil.SetIsVisible(self.ImgFavorite, EmotionMgr:IsSavedFavoriteID(self.Params.Data.ID))
	end
end

--- 发送情感动作播放请求
function EmoActSlotView:SendEmotionReq(EmotionID)
	if EmotionMgr:IsChangePoseEmotion(EmotionID) then
		EmotionMgr:ReqChangeIdleAnim() 		 --是 ID = 90（改变姿势）
	else
		EmotionMgr:SendEmotionReq(EmotionID)

		if (self.ParentView ~= nil and self.ParentView.Params ~= nil and self.ParentView.Params.ClickCallback ~= nil) then
			self.ParentView.Params.ClickCallback(EmotionID)
		end
	end
end

--- 图标交互（点击触发）
function EmoActSlotView:RequiredIcon(IsSelected)
	if self:IsNull() then
		return
	end
	local EmoActID = self.Params.Data.ID
	
	print("【情感动作】点击图标时检测图标状态", 
	"动作ID:",EmoActID, 
	"列表数量：", #EmoActPanelVM.CanUseList, 
	"此动作是否可用：",EmoActPanelVM.CanUseList[EmoActID], 
	self.Params.Data.CanUse[EmotionMgr.MajorCanUseType], 
	"主角状态",EmotionMgr.MajorCanUseType,
	"存在动作路径：",self.Params.Data.HasAnimPath)

	if EmoActPanelVM.CanUseList[EmoActID] ~= false then	--可用按钮
		self:SendEmotionReq(EmoActID)	     --请求情感动作

		EmotionMgr:SaveRecentEmotion(EmoActID)			--记录最近使用
		EmotionMgr:SetRecentTime()
		EmoActPanelVM.SelectList[TimeUtil.GetLocalTimeMS()] = {ID = EmoActID, ItemView = self}
		self:SetSpecialVisible(EmoActID)

		EmotionMgr:DelRedDot(EmoActID)	--红点相关
	else
		EmotionMgr:ShowCannotUseTips(EmoActID)
	end
end

--- 检测空格
function EmoActSlotView:IsNull()
	return self.Params == nil or self.Params.Data == nil
	or string.isnilorempty(self.Params.Data.EmotionName)
	or self.Params.Data.ID == nil
end

--- 补充空格占位状态
function EmoActSlotView:NullSlot()
	self.ImgName:SetText("")
	UIUtil.SetIsVisible(self.ImgIcon, false, true, true)
	UIUtil.SetIsVisible(self.ImgSelect, false)
	UIUtil.SetIsVisible(self.ImgFavorite, false)
	UIUtil.SetIsVisible(self, true, true, true)
end

--- 设置选中状态 边框高亮
function EmoActSlotView:SetSelectVisibity(bVisibility)
	if self.ImgSelect then
		UIUtil.SetIsVisible(self.ImgSelect, bVisibility)
	end

	if bVisibility == true then
		if EmoActPanelVM.EnableID ~= self.Params.Data.ID then
			EmoActPanelVM.EnableID = self.Params.Data.ID
		end
	end
end

--- 设置启用可点击
function EmoActSlotView:SetEnable(bEnable)
	if self.bEnableItem == bEnable or self:IsNull() then
		return
	end
	self.bEnableItem = bEnable

	if CommonUtil.IsObjectValid(self) and self.ImgIcon and self.ImgName then
		local Color = not bEnable and "#696969FF" or "#FFFFFFFF"
		UIUtil.SetColorAndOpacityHex(self.ImgIcon, Color)
		UIUtil.SetColorAndOpacityHex(self.ImgName, Color)
		UIUtil.SetIsVisible(self, true, bEnable, true)
	end
end

--- 显示任务情感动作UI
function EmoActSlotView:SetShowQuestIcon(QuestLiat)
	if not CommonUtil.IsObjectValid(self.IconTask) then
		return
	end
	local EmoActID = self.Params.Data.ID
	if EmoActID == nil then
		UIUtil.SetIsVisible(self.IconTask, false)
		return
	end
	local IsTag = EmoActPanelVM.ShowTemporaryTagID == EmoActID
	if IsTag then
		--直接显示临时标记（临时标记暂同任务icon代替）
		UIUtil.SetIsVisible(self.IconTask, IsTag)
		EmotionMgr:DelRedDot(EmoActID)
		return
	end

	if nil == QuestLiat then
		UIUtil.SetIsVisible(self.IconTask, false)
		return
	end
	if (type(QuestLiat) == "table") and #QuestLiat == 0 then
		UIUtil.SetIsVisible(self.IconTask, false)
		return
	end

	local _, id = table.find_item( QuestLiat, EmoActID )
	local bShow = id ~= nil
	UIUtil.SetIsVisible(self.IconTask, bShow)
	if bShow then
		EmotionMgr:DelRedDot(EmoActID)	--当任务Icon和红点同时存在时，隐藏红点
	end
end

--- 延迟关闭选中框UI
function EmoActSlotView:SetDelayVisible(EmotionID)
	self:SetSelectVisibity(true)
	if EmotionID == self.Params.Data.ID then
		self.TimerIDs = self.TimerIDs or {}
		self.TimerIDs[#self.TimerIDs + 1] = _G.TimerMgr:AddTimer(self, function()
			if EmotionID == self.Params.Data.ID then
				self:SetSelectVisibity(false)
			end
		end, 1.25, 0, 1, EmotionID)
	end
end

--- 特殊情况下选中框
function EmoActSlotView:SetSpecialVisible(EmoActID)
	if not EmotionMgr then
		return
	end
	if EmotionMgr:IsEquipEmotion(EmoActID) then
		self:SetDelayVisible(EmoActID)
	end
	if EmotionMgr:IsChangePoseEmotion(EmoActID) then
		EmotionMgr:FaceToChangePose(EmoActID)
		self:SetDelayVisible(EmoActID)
	end
	if EmotionMgr.IsSitEmotionID(EmoActID) then
		EmotionMgr:FaceToChangePose(EmoActID)
		self:SetDelayVisible(EmoActID)
	end
end

return EmoActSlotView