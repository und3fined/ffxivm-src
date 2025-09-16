---
--- Author: Administrator
--- DateTime: 2025-01-14 14:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local SkillTipsMgr = require("Game/Skill/SkillTipsMgr")
local UIUtil = require("Utils/UIUtil")
local TipsUtil = require("Utils/TipsUtil")
local CommonUtil = require("Utils/CommonUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local CommSkillTipsVM = require("Game/Common/Tips/VM/CommSkillTipsVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")

local UIAsyncTaskMgr <const> = _G.UIAsyncTaskMgr
local FVector2D <const>      = UE.FVector2D
local SkillTipsType <const>  = SkillCommonDefine.SkillTipsType
local AdjustPosDelay <const> = 0.1                  -- 更新Tips位置的延迟
local TipsAlignment <const>  = FVector2D(1, 1)      -- 对齐右下角

-- # TODO - 这俩参数如果后面会频繁变动, 放到蓝图里
local SafeMinY <const>       = 26                   -- Y轴安全区距离
local VisualOffset <const>   = FVector2D(-10, 0)    -- 视觉上向左偏移的Offset

-- TableView更新有延迟, 刚开始拿到Widget大小不准, 需要延迟一下
local MountAdjustPosDelay <const> = 0.1



---@class CommSkillTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FCanvasPanel_39 UFCanvasPanel
---@field TableView UTableView
---@field TableViewSkillTag UTableView
---@field TextSkillName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSkillTipsView = LuaClass(UIView, true)

function CommSkillTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.FCanvasPanel_39 = nil
	--self.TableView = nil
	--self.TableViewSkillTag = nil
	--self.TextSkillName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSkillTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSkillTipsView:OnInit()
	self.AdapterContent = UIAdapterTableView.CreateAdapter(self, self.TableView)
	self.AdapterSkillTag = UIAdapterTableView.CreateAdapter(self, self.TableViewSkillTag)

	local ChildCanvas = self.FCanvasPanel_39:GetChildAt(0)
	if ChildCanvas then
		local CanvasOffset = UIUtil.CanvasSlotGetOffsets(ChildCanvas)
		self.ReviseOffset = FVector2D(CanvasOffset.Right, CanvasOffset.Bottom)  -- Tips本身布局产生的Offset
	else
		self.ReviseOffset = FVector2D(0, 0)
	end
end

function CommSkillTipsView:OnDestroy()

end

function CommSkillTipsView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Type = Params.Type
	self.Type = Type

	do
		local _ <close> = CommonUtil.MakeProfileTag("SkillTipsMgr:ShowTipsBySkillID")
		local bSync = Params.bSync
		if bSync then
			CommSkillTipsVM:UpdateVM(Params, bSync)
		else
			local co = coroutine.create(CommSkillTipsVM.UpdateVM)
			CommSkillTipsVM.bUpdateFinished = false  -- 异步更新有延迟, 先置为false避免穿帮
			self.AsyncTaskID = UIAsyncTaskMgr:RegisterTask(co, CommSkillTipsVM, Params, bSync)
		end
	end

	if Type == SkillTipsType.Mount then
		-- self:AdjustPosition_Mount()
		self:RegisterTimer(self.AdjustPosition_Mount, MountAdjustPosDelay, 0, 1)
	end
end

function CommSkillTipsView:OnHide()
	if self.AsyncTaskID then
		UIAsyncTaskMgr:UnRegisterTask(self.AsyncTaskID)
		self.AsyncTaskID = nil
	end
end

function CommSkillTipsView:OnRegisterUIEvent()

end

function CommSkillTipsView:OnRegisterGameEvent()
	local Params = self.Params
	if nil == Params then
		return
	end
	if Params.bHideAfterClick then
		self:RegisterGameEvent(EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
	end
end

function CommSkillTipsView:OnRegisterBinder()
	local Binders = {
		{ "SkillName", UIBinderSetText.New(self, self.TextSkillName) },
		{ "SkillNameColor", UIBinderSetColorAndOpacityHex.New(self, self.TextSkillName) },
		{ "ContentList", UIBinderUpdateBindableList.New(self, self.AdapterContent) },
		{ "SkillTagList", UIBinderUpdateBindableList.New(self, self.AdapterSkillTag) },
		{ "bUpdateFinished", UIBinderValueChangedCallback.New(self, nil, self.OnUpdateFinished) },
	}

	self:RegisterBinders(CommSkillTipsVM, Binders)
end

function CommSkillTipsView:OnPreprocessedMouseButtonUp()
	local Params = self.Params
	if not Params.bHideAfterClick then
		FLOG_ERROR("[CommSkillTipsView] bHideAfterClick == false but register event!")
		return
	end
	SkillTipsMgr:HideTipsByHandleID(Params.HandleID)
end

function CommSkillTipsView:OnUpdateFinished(bIsFinished, bLastIsFinished)
	if bLastIsFinished == nil then
		return
	end
	if bIsFinished then
		self.AsyncTaskID = nil
		-- 更新完内容, 等控件伸展开再调整位置, 这样获取到的WidgetSize比较准确
		self:RegisterTimer(self.UpdateVisibilityAndAdjustPosition, AdjustPosDelay, 0, 1, true)
	else
		self:UpdateVisibilityAndAdjustPosition(false)
	end
end

function CommSkillTipsView:UpdateVisibilityAndAdjustPosition(bVisible)
	self.FCanvasPanel_39:SetRenderOpacity(bVisible and 1 or 0)
	-- Mount类技能调整布局应当在OnShow的时候走单独的逻辑, 不走后面的逻辑
	if self.Type == SkillTipsType.Mount then
		return
	end

	local Params = self.Params
	if nil == Params then
		return
	end
	local Pos = Params.Pos
	if not Pos then
		return
	end
	local ReviseOffset = self.ReviseOffset

	Pos = Pos + VisualOffset
	local Widget = self.FCanvasPanel_39
	local TipsWidgetSize = UIUtil.GetLocalSize(Widget) - ReviseOffset
	if Pos.Y - TipsWidgetSize.Y < SafeMinY then
		Pos.Y = SafeMinY + TipsWidgetSize.Y
	end
	Pos = Pos + ReviseOffset

	UIUtil.CanvasSlotSetAlignment(Widget, TipsAlignment)
	UIUtil.CanvasSlotSetPosition(Widget, Pos)
end

-- 坐骑技能调整位置不走统一逻辑, 坐骑模块维护
function CommSkillTipsView:AdjustPosition_Mount()
	local Params = self.Params.MountParams
	local IsAutoFlip = Params.IsAutoFlip
	local FVector2D = _G.UE.FVector2D
	local UUIUtil = _G.UE.UUIUtil
	local InfoTipMargin = {
		Left = -35,
		Top = -26,
		Right = -35,
		Bottom = -16,
	}

	local InfoTipGap = Params.InfoTipGap or 10
	local Offset = Params.Offset or FVector2D(0, 0)	
	local Alignment = Params.Alignment or FVector2D(0, 0)

	if Params.InTargetWidget then
		local TargetWidgetSize = UUIUtil.GetLocalSize(Params.InTargetWidget)
		Offset = FVector2D( - TargetWidgetSize.X, 0)
		if IsAutoFlip then
			local TargetWidget = Params.InTargetWidget
			local WindowAbsolute = UIUtil.ScreenToWidgetAbsolute(FVector2D(0, 0), false) or FVector2D(0, 0)
			local ViewportSize = UIUtil.GetViewportSize()
			local TragetAbsolute = UIUtil.GetWidgetAbsolutePosition(TargetWidget)
			if TragetAbsolute.Y - WindowAbsolute.Y  > ViewportSize.Y / 2 then
				Alignment.Y = 1
				Offset.Y = Offset.Y + TargetWidgetSize.Y
			else
				Alignment.Y = 0
			end
		end

		if Alignment.X == 0.0 and Alignment.Y  == 0.0 then
			Offset.X = Offset.X - InfoTipMargin.Left - InfoTipGap
			Offset.Y = Offset.Y - InfoTipMargin.Top
		elseif Alignment.X == 1.0 and Alignment.Y == 1.0 then
			Offset.X = Offset.X + InfoTipMargin.Right - InfoTipGap
			Offset.Y = Offset.Y + InfoTipMargin.Bottom
		elseif Alignment.X == 1.0 and Alignment.Y == 0.0 then
			Offset.X = Offset.X + InfoTipMargin.Right - InfoTipGap
			Offset.Y = Offset.Y - InfoTipMargin.Top
		elseif Alignment.X == 0.0 and Alignment.Y == 1.0 then
			Offset.X = Offset.X - InfoTipMargin.Left - InfoTipGap
			Offset.Y = Offset.Y + InfoTipMargin.Bottom
		end

		UIUtil.CanvasSlotSetPosition(self.FCanvasPanel_39, FVector2D(0, 0))
		UIUtil.CanvasSlotSetAlignment(self.FCanvasPanel_39, FVector2D(0, 0))
		TipsUtil.AdjustTipsPosition(self.FCanvasPanel_39, Params.InTargetWidget, Offset, Alignment)
	end
end

return CommSkillTipsView