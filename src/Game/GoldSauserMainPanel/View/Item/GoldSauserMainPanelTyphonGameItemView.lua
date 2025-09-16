---
--- Author: Administrator
--- DateTime: 2023-12-29 20:14
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local EventID = require("Define/EventID")
local UIViewID = _G.UIViewID
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local GoldSauserMainPanelMgr = require("Game/GoldSauserMainPanel/GoldSauserMainPanelMgr")
local GoldSauserMainPanelTyphonGameItemVM
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local UIAdapterCountDown = require("UI/Adapter/UIAdapterCountDown")
local UIBinderUpdateCountDown = require("Binder/UIBinderUpdateCountDown")
local KIL = _G.UE.UKismetInputLibrary

---@class GoldSauserMainPanelTyphonGameItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BackBtn CommBackBtnView
---@field FImageCactus UFImage
---@field FImageClickBg UFImage
---@field FImageWindRectangle UFImage
---@field FImageWindRing UFImage
---@field FImageWindRound UFImage
---@field FImageWindSector UFImage
---@field TextTime UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GoldSauserMainPanelTyphonGameItemView = LuaClass(UIView, true)

local TyphonRegionEnum = 
{
	WindRing = 1,
	WindRound = 2,
	WindSector = 3,
	WindRectangle = 4,
}

function GoldSauserMainPanelTyphonGameItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BackBtn = nil
	--self.FImageCactus = nil
	--self.FImageClickBg = nil
	--self.FImageWindRectangle = nil
	--self.FImageWindRing = nil
	--self.FImageWindRound = nil
	--self.FImageWindSector = nil
	--self.TextTime = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelTyphonGameItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BackBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GoldSauserMainPanelTyphonGameItemView:OnInit()
	GoldSauserMainPanelTyphonGameItemVM = GoldSauserMainPanelMainVM:GetGoldSauserMainPanelTyphonGameItemVM()

	self.BackBtn:AddBackClick(self, self.OnBackBtnClicked)
	--获取点击区域大小
	local Size = UIUtil.CanvasSlotGetSize(self.FImageClickBg)
	self.FImageClickBgSizeX = Size.X
	self.FImageClickBgSizeY = Size.Y
	local CactuseSize = UIUtil.CanvasSlotGetSize(self.FImageCactus)
	self.CactuseRadius = CactuseSize.X
	self.IsClickFollow = true
	--获取吹风矩形大小
	local RectangleSize = UIUtil.CanvasSlotGetSize(self.FImageWindRectangle)
	self.FImageWindRectangleSizeX = RectangleSize.X
	self.FImageWindRectangleSizeY = RectangleSize.Y
	---扇形参数后续等有效果后，给重构配置
	--扇形起始角度,以X轴方向为0度
	self.SectorStartAngle = -150
	--扇形角度大小
	self.SectorSizeAngle = 120
	self.WindWidgetList = {
		[TyphonRegionEnum.WindRing] = self.FImageWindRing,
		[TyphonRegionEnum.WindRound] = self.FImageWindRound,
		[TyphonRegionEnum.WindSector] = self.FImageWindSector,
		[TyphonRegionEnum.WindRectangle] = self.FImageWindRectangle,
	}

	self.AdapterCountDownTime = UIAdapterCountDown.CreateAdapter(self, self.TextTime, nil, "%.0f")
	self.Binders = {
		{ "MiniGameTime", UIBinderUpdateCountDown.New(self, self.AdapterCountDownTime, 0.5, true, true)},
	}
	self.CactusePos = _G.UE.FVector2D(0, 0)
end

function GoldSauserMainPanelTyphonGameItemView:TimeOutCallback()
	print("GoldSauserMainPanelTyphonGameItemView:TimeOutCallback()")
end

-- ---@param LeftTime number 剩余时间
-- function GoldSauserMainPanelTyphonGameItemView:TimeUpdateCallback(LeftTime)
-- 	print("GoldSauserMainPanelTyphonGameItemView:TimeUpdateCallback() "..LeftTime..GoldSauserMainPanelTyphonGameItemVM.MiniGameTime)
-- 	self.TextTime:SetText(LeftTime)
-- end

function GoldSauserMainPanelTyphonGameItemView:OnDestroy()

end

function GoldSauserMainPanelTyphonGameItemView:OnShow()
	---仙人掌位置回正
	self.CactusePos = _G.UE.FVector2D(0, 0)
	UIUtil.CanvasSlotSetPosition(self.FImageCactus, self.CactusePos)

	for _, WindWidget in ipairs(self.WindWidgetList) do
		UIUtil.SetIsVisible(WindWidget,false)
	end
	---todo 游戏结束计时器时间走配表, 小游戏自然消失时间
	self.MiniGameTimer = _G.TimerMgr:AddTimer(self, self.SetGameEnd, 10, 0, 1, GoldSauserMainPanelDefine.MiniGameEndCondition.Succeed)
	---todo 首轮吹风计时器时间走配表
	self.WinderTimer = _G.TimerMgr:AddTimer(self, self.WinderGenerate, 2, 0, 1, 1)
end

function GoldSauserMainPanelTyphonGameItemView:OnHide()
	self:SetGameEnd(GoldSauserMainPanelDefine.MiniGameEndCondition.Interrupt)
end

function GoldSauserMainPanelTyphonGameItemView:OnRegisterUIEvent()
	
end

function GoldSauserMainPanelTyphonGameItemView:OnBackBtnClicked()
	GoldSauserMainPanelMainVM:SetIsEventSquareCenter(false)
	UIViewMgr:HideView(UIViewID.GoldSauserMainPanelTyphonGameItem)
end

function GoldSauserMainPanelTyphonGameItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function GoldSauserMainPanelTyphonGameItemView:OnRegisterBinder()
	self:RegisterBinders(GoldSauserMainPanelTyphonGameItemVM, self.Binders)
end

---@param number Index 第几次生成
function GoldSauserMainPanelTyphonGameItemView:WinderGenerate(Index)
	---todo 需要读表配置时间
	---吹风计时器销毁
	if self.WinderTimer then
		_G.TimerMgr:CancelTimer(self.WinderTimer)
		self.WinderTimer = nil
	end
	---随机吹风
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 3)))
	local WinderIndex = math.random(1, 4)
	---矩形和扇形需要随机角度
	local Angle = 0
	if WinderIndex == TyphonRegionEnum.WindRectangle or WinderIndex == TyphonRegionEnum.WindSector  then
		Angle = math.random(0, 360)
		self.WindWidgetList[WinderIndex]:SetRenderTransformAngle(Angle)
	end
	UIUtil.SetIsVisible(self.WindWidgetList[WinderIndex],true)
	local Params = {Angle = Angle, WinderIndex = WinderIndex }
	self.WinderShowTimer = _G.TimerMgr:AddTimer(self, self.WinderHide, 1.2, 0, 1, Params)
	self.WinderTimer = _G.TimerMgr:AddTimer(self, self.WinderGenerate, 2, 0, 1, Index + 1)
end

function GoldSauserMainPanelTyphonGameItemView:WinderHide(InParams)
	---吹风显示计时器销毁
	if self.WinderShowTimer then
		_G.TimerMgr:CancelTimer(self.WinderShowTimer)
		self.WinderShowTimer = nil
	end
	UIUtil.SetIsVisible(self.WindWidgetList[InParams.WinderIndex],false)
	---失败判定
	if self:IsBlowFly(InParams.WinderIndex, InParams.Angle) then
		self:SetGameEnd(GoldSauserMainPanelDefine.MiniGameEndCondition.Fail)
	end
end

function GoldSauserMainPanelTyphonGameItemView.DotProduct2D(v1, v2)
    -- 计算点积
    local Dotproduct = v1.X * v2.X + v1.Y * v2.Y
	return Dotproduct
end

function GoldSauserMainPanelTyphonGameItemView:IsBlowFly(InWinderIndex, Angle)
	if InWinderIndex == TyphonRegionEnum.WindRing then
		if self.CactusePos then
			local CentrePos = _G.UE.FVector2D(0, 0)
			local Distance = _G.UE.UKismetMathLibrary.Distance2D(self.CactusePos, CentrePos)
			---todo 环的宽度代码拿不到，后续看时给策划配置还是蓝图重构配置
			if Distance > self.FImageClickBgSizeX / 2 - 30 - self.CactuseRadius then
				return true
			end
		end	
	elseif InWinderIndex == TyphonRegionEnum.WindRound then
		if self.CactusePos then
			local CentrePos = _G.UE.FVector2D(0, 0)
			local Distance = _G.UE.UKismetMathLibrary.Distance2D(self.CactusePos, CentrePos)
			local Size = UIUtil.CanvasSlotGetSize(self.FImageWindRound)
			if Distance < Size.X / 2 + self.CactuseRadius then
				return true
			end
		end	
	elseif InWinderIndex == TyphonRegionEnum.WindSector then
		if self.CactusePos and Angle then
			---计算与x轴的夹角
			local XVector = {X = 1, Y = 0}
			local CactusePosVector =  _G.UE.FVector2D(self.CactusePos.X, self.CactusePos.Y)
			_G.UE.FVector2D.Normalize(CactusePosVector)
			local CentreAngle = math.deg(math.acos(self.DotProduct2D(XVector, CactusePosVector)))
			if self.CactusePos.Y < 0 then
				CentreAngle = -CentreAngle
			end
			if CentreAngle > self.SectorStartAngle + Angle and CentreAngle <  self.SectorStartAngle + self.SectorSizeAngle + Angle then
				return true
			end
		end	
	elseif InWinderIndex == TyphonRegionEnum.WindRectangle then
		if self.CactusePos and Angle then
			---逆时针旋转
			local PosX = self.CactusePos.X * math.cos(math.rad(-Angle)) - self.CactusePos.Y * math.sin(math.rad(-Angle))
			local PosY = self.CactusePos.Y * math.cos(math.rad(-Angle)) + self.CactusePos.X * math.sin(math.rad(-Angle))
			PosX = math.abs(PosX)
			PosY = math.abs(PosY)
			if PosX < self.FImageWindRectangleSizeX / 2 and PosY < self.FImageWindRectangleSizeY / 2 then
				return true
			end
		end	
	else
	end
	return false
end

function GoldSauserMainPanelTyphonGameItemView:SetGameEnd(EndCondition)
	if EndCondition == GoldSauserMainPanelDefine.MiniGameEndCondition.Succeed then
		---todo 成功动画接入，消失可能要延时处理
		---小游戏成功协议发送
		GoldSauserMainPanelMgr:SendGoldSauserMainGameFinishedNumMsg(GoldSauserMainPanelTyphonGameItemVM:GetMiniGameType())
		MsgTipsUtil.ShowTips(LSTR("游戏成功(本地)"))
		self:OnBackBtnClicked()
	elseif EndCondition == GoldSauserMainPanelDefine.MiniGameEndCondition.Fail then
		---todo 失败动画接入，消失可能要延时处理
		MsgTipsUtil.ShowTips(LSTR("游戏失败"))
		self:OnBackBtnClicked()
	end
	---游戏计时器销毁
	if self.MiniGameTimer then
		_G.TimerMgr:CancelTimer(self.MiniGameTimer)
		self.MiniGameTimer = nil
	end
	---吹风计时器销毁
	if self.WinderTimer then
		_G.TimerMgr:CancelTimer(self.WinderTimer)
		self.WinderTimer = nil
	end
	
end

function GoldSauserMainPanelTyphonGameItemView:SetIsClickFollow(InIsClickFollow)
	self.IsClickFollow = InIsClickFollow
end

function GoldSauserMainPanelTyphonGameItemView:GetIsClickFollow()
	return self.IsClickFollow
end

function GoldSauserMainPanelTyphonGameItemView:SetClickFollow(InIsClickFollow)
	self:SetIsClickFollow(InIsClickFollow)
	---点击限制计时器销毁
	if self.ClickFollowTimer then
		_G.TimerMgr:CancelTimer(self.ClickFollowTimer)
		self.ClickFollowTimer = nil
	end
end

function GoldSauserMainPanelTyphonGameItemView:OnPreprocessedMouseButtonDown(MouseEvent)
	if self.IsClickFollow then
		self.IsClickFollow = false
		---todo 点击限制时间走配表
		self.ClickFollowTimer = _G.TimerMgr:AddTimer(self, self.SetClickFollow, 0.3, 0, 1, true)
	else
		return
	end
	local MousePosition = KIL.PointerEvent_GetScreenSpacePosition(MouseEvent)
	local ClickBgMousePosition = UIUtil.AbsoluteToLocal(self.FImageClickBg, MousePosition)
	local CentrePos = _G.UE.FVector2D(self.FImageClickBgSizeX  / 2, self.FImageClickBgSizeY / 2)
	local Distance = _G.UE.UKismetMathLibrary.Distance2D(ClickBgMousePosition, CentrePos)
	if Distance < self.FImageClickBgSizeX / 2 then -- 设置仙人掌位置
		local CactusePos = _G.UE.FVector2D(ClickBgMousePosition.X - CentrePos.X, ClickBgMousePosition.Y - CentrePos.Y)
		UIUtil.CanvasSlotSetPosition(self.FImageCactus, CactusePos)
		self.CactusePos = CactusePos
	end
end

return GoldSauserMainPanelTyphonGameItemView