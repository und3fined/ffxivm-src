---
--- Author: ZhengJanChuan
--- DateTime: 2023-05-19 10:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local TutorialCfg = require("TableCfg/TutorialCfg")
local TutorialUtil = require("Game/Tutorial/TutorialUtil")
local TimeUtil = require("Utils/TimeUtil")
local TutorialBaseView = require("Game/Tutorial/View/TutorialBaseView")
local UIViewMgr = require("UI/UIViewMgr")
local ProtoRes = require("Protocol/ProtoRes")
local CommonUtil = require("Utils/CommonUtil")


---@class TutorialGestureMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Comm TutorialGuidanceItemView
---@field Friend TutorialGestureFriendItemView
---@field Function UFCanvasPanel
---@field FunctionSelect TutorialGestureSelectSmallItemView
---@field FunctionTips TutorialGestureTips2ItemView
---@field ImgDown UImage
---@field ImgLeft UImage
---@field ImgRight UImage
---@field ImgTop UImage
---@field Jump UFCanvasPanel
---@field JumpSelect TutorialGestureSelectItemView
---@field JumpTips TutorialGestureTips2ItemView
---@field Map TutorialGestureSelectSmallItemView
---@field MiniMapSelect TutorialGestureSelectItemView
---@field MiniMapTips TutorialGestureTips2ItemView
---@field PanelMount UFCanvasPanel
---@field PanelMountSelect TutorialGestureSelectItemView
---@field PanelMountTips TutorialGestureTips2ItemView
---@field Secondary TutorialGestureSecondaryItemView
---@field SkillGenAttack UFCanvasPanel
---@field SkillGenAttackSelect TutorialGestureSelectItemView
---@field SkillGenAttackTips TutorialGestureTips2ItemView
---@field AnimMaskIn UWidgetAnimation
---@field AnimMaskOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TutorialGestureMainPanelView = LuaClass(UIView, true)

function TutorialGestureMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Comm = nil
	--self.Friend = nil
	--self.Function = nil
	--self.FunctionSelect = nil
	--self.FunctionTips = nil
	--self.ImgDown = nil
	--self.ImgLeft = nil
	--self.ImgRight = nil
	--self.ImgTop = nil
	--self.Jump = nil
	--self.JumpSelect = nil
	--self.JumpTips = nil
	--self.Map = nil
	--self.MiniMapSelect = nil
	--self.MiniMapTips = nil
	--self.PanelMount = nil
	--self.PanelMountSelect = nil
	--self.PanelMountTips = nil
	--self.Secondary = nil
	--self.SkillGenAttack = nil
	--self.SkillGenAttackSelect = nil
	--self.SkillGenAttackTips = nil
	--self.AnimMaskIn = nil
	--self.AnimMaskOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TutorialGestureMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Comm)
	self:AddSubView(self.Friend)
	self:AddSubView(self.FunctionSelect)
	self:AddSubView(self.FunctionTips)
	self:AddSubView(self.JumpSelect)
	self:AddSubView(self.JumpTips)
	self:AddSubView(self.Map)
	self:AddSubView(self.MiniMapSelect)
	self:AddSubView(self.MiniMapTips)
	self:AddSubView(self.PanelMountSelect)
	self:AddSubView(self.PanelMountTips)
	self:AddSubView(self.Secondary)
	self:AddSubView(self.SkillGenAttackSelect)
	self:AddSubView(self.SkillGenAttackTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TutorialGestureMainPanelView:OnInit()
	self.NoFuncForce = false
	self.ResetPosTimer = nil
	self.InputModeUIOnly = false
end

function TutorialGestureMainPanelView:OnDestroy()
end

function TutorialGestureMainPanelView:OnHide()
	self:RemoveTimer()
	self.Comm:RemoveTimer()
	self.InputModeUIOnly = false

	local SubGroup = _G.NewTutorialMgr:GetRunningSubGroup()

	if SubGroup ~= nil then
		--如果当前小组已经结束了说明播之前就是最后一步，这里要判断一下整个大组情况(这里主要是软引用可以被其它界面关了导致大组无法结束)
		if SubGroup["Progress"] == 0 then
			if _G.NewTutorialMgr:GetTutorialCurID() ~= nil then
				_G.NewTutorialMgr:CheckAndSetGroupFinish(SubGroup)
			end
		end
	end

	--_G.TipsQueueMgr:Pause(false)
end

function TutorialGestureMainPanelView:RemoveTimer()
	if self.TimerHdl ~= nil then
		self:UnRegisterTimer(self.TimerHdl)
		self.TimerHdl = nil
	end

	if self.ResetPosTimer ~= nil then
		self:UnRegisterTimer(self.ResetPosTimer)
		self.ResetPosTimer = nil
	end
end

function TutorialGestureMainPanelView:OnShow()
	if not self.Params then
		return 
	end

	self.NoFuncForce = false

	self.TutorialID = self.Params.TutorialID
	local TutorialID = self.TutorialID

	self.Cfg = _G.NewTutorialMgr:GetRunningCfg(TutorialID)

	if self.Cfg ~= nil then
		if self.Cfg.Type == TutorialDefine.TutorialType.Soft then
			UIUtil.SetIsVisible(self.Btn, false, false)
		elseif self.Cfg.Type == TutorialDefine.TutorialType.Force or self.Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
			UIUtil.SetIsVisible(self.Btn, true, true)
			self.InputModeUIOnly = true

			if self.Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
				self.NoFuncForce = true
			end
		end
	else
		FLOG_ERROR("Cant find Cfg")
		return
	end
	
	--local GuideWidgetPath = self.Cfg.GuideWidgetPath
	--local GuideWidget =  TutorialUtil:GetTutorialWidget(self,GuideWidgetPath)
	local Type = self.Cfg.Type
	local Content = self.Cfg.Content
	local ContentDir = TutorialUtil:GetContentDir(self.Cfg.Dir)

	local UIBPName = self.Cfg.BPName
	local ViewID = UIViewMgr:GetViewIDByName(UIBPName)
	local View = UIViewMgr:FindVisibleView(ViewID)
	local WidgetPath = self.Cfg.WidgetPath
	local Widget = nil

	if string.find(WidgetPath,"Adapter") and self.Cfg.HandleType ~= TutorialDefine.TutorialHandleType.TableView then
		Widget = TutorialUtil:GetTutorialWidgetWithAdapter(View, WidgetPath,self.Cfg.StartParam)
	else
		Widget = TutorialUtil:GetTutorialWidget(View, WidgetPath)
	end

	local Time = self.Cfg.Time
	self.TimerHdl = nil

	self.Type = Type
	self.Widget = Widget

	if Type == TutorialDefine.TutorialType.NoFuncForce then
		self.Comm.GestureSelect:SetFunc(false)
	else
		self.Comm.GestureSelect:SetFunc(true)
	end

	if self.Widget == nil then
		FLOG_WARNING("Widget is nil and WidgetPath is %s",WidgetPath)

		--找不到控件强制关闭当前引导
		--local Params = {}
		--Params.TutorialID = self.TutorialID
		--_G.EventMgr:SendEvent(_G.EventID.TutorialEnd, Params)
	end

	if self:SetCommViewSize(self.Cfg) then

		--每0.2秒重新算一下位置
		if self.ResetPosTimer == nil then
			self.ResetPosTimer = self:RegisterTimer(function()
				self:SetCommViewSize(self.Cfg)
			end,0.2,0.2,0)
		end

		self:SetCommPanel( Content, ContentDir, Time,self.EndFuncCallback,self.Cfg.IsSystemUI,self.Cfg)

		----------------通用控件逻辑----------------
		local IsForce = Type == TutorialDefine.TutorialType.Force or Type == TutorialDefine.TutorialType.NoFuncForce
		UIUtil.SetIsVisible(self.ImgDown, IsForce, true)
		UIUtil.SetIsVisible(self.ImgLeft, IsForce, true)
		UIUtil.SetIsVisible(self.ImgTop, IsForce, true)
		UIUtil.SetIsVisible(self.ImgRight, IsForce, true)

		if IsForce then
			self.AnimIn = self.AnimMaskIn
			self.AnimOut = self.AnimMaskOut
			self:PlayAnimIn()
			return
		end

	else
		self:SetCommPanel( Content, ContentDir, Time,self.EndFuncCallback,self.Cfg.IsSystemUI,self.Cfg)
		--找不到控件(强引导就强制结束)
		--if Type == TutorialDefine.TutorialType.Force or Type == TutorialDefine.TutorialType.NoFuncForce then
			--FLOG_WARNING("Cant Find View")
			--_G.EventMgr:SendEvent(_G.EventID.ForceCloseTutorial)
		--end
	end

	--[[
	if not self:SetCommViewSize(self.Cfg) then
		self.TimerHdl = self:RegisterTimer(function()
			--过0.5秒还是找不到则报错，有可能INDEX填错了
			if not self:SetCommViewSize(self.Cfg) then
				FLOG_ERROR("can not find itemview")
				self:RemoveTimer()

				local Params = {}
				Params.TutorialID = self.Cfg.TutorialID
				_G.EventMgr:SendEvent(_G.EventID.TutorialEnd, Params)
				return
			end

			self:SetCommPanel( Content, ContentDir, Time,self.EndFuncCallback,self.Cfg.IsSystemUI)
			self:RemoveTimer()
			----------------通用控件逻辑----------------
			local IsForce = Type == TutorialDefine.TutorialType.Force
			UIUtil.SetIsVisible(self.ImgDown, IsForce, true)
			UIUtil.SetIsVisible(self.ImgLeft, IsForce, true)
			UIUtil.SetIsVisible(self.ImgTop, IsForce, true)
			UIUtil.SetIsVisible(self.ImgRight, IsForce, true)

			if Type == TutorialDefine.TutorialType.Force then
				self.AnimIn = self.AnimMaskIn
				self.AnimOut = self.AnimMaskOut
				self:PlayAnimIn()
			end
		end, 1, 0, 1)
	else
		self:SetCommPanel( Content, ContentDir, Time,self.EndFuncCallback,self.Cfg.IsSystemUI)

		----------------通用控件逻辑----------------
		local IsForce = Type == TutorialDefine.TutorialType.Force
		UIUtil.SetIsVisible(self.ImgDown, IsForce, true)
		UIUtil.SetIsVisible(self.ImgLeft, IsForce, true)
		UIUtil.SetIsVisible(self.ImgTop, IsForce, true)
		UIUtil.SetIsVisible(self.ImgRight, IsForce, true)

		if Type == TutorialDefine.TutorialType.Force then
			self.AnimIn = self.AnimMaskIn
			self.AnimOut = self.AnimMaskOut
			self:PlayAnimIn()
			return
		end
	end
	--]]
end

---@field GuideWidget 引导层控件
function TutorialGestureMainPanelView:OnCalculateFunctionMask(GuideWidget, Widget)

	local Parent = GuideWidget:GetParent()
	local ScreenSize = UIUtil.GetScreenSize()
	local GuideWidgetSize = UIUtil.CanvasSlotGetSize(GuideWidget)
	local GuideWidgetPos = UIUtil.CanvasSlotGetPosition(GuideWidget)

	local ParentPanelPos = UIUtil.CanvasSlotGetPosition(Parent)
	local ParentPanelSize = UIUtil.CanvasSlotGetSize(Parent)

	local Left = ScreenSize.X + ParentPanelPos.X + 30
	local Right = ScreenSize.X - (ScreenSize.X + ParentPanelPos.X + ParentPanelSize.X - 30)

	-- local Top = ParentPanelPos.Y + GuideWidgetPos.X 
	local Bottom = ScreenSize.Y - GuideWidgetSize.Y + GuideWidgetPos.Y + 20

	UIUtil.CanvasSlotSetSize(self.ImgLeft, _G.UE.FVector2D(Left, 0))
	UIUtil.CanvasSlotSetSize(self.ImgRight, _G.UE.FVector2D(-Right, 0))

	local TopOffset = UIUtil.CanvasSlotGetOffsets(self.ImgTop)
	TopOffset.Left = Left
	TopOffset.Right = Right
	TopOffset.Bottom = 0
	UIUtil.CanvasSlotSetOffsets(self.ImgTop, TopOffset)

	local DownOffset = UIUtil.CanvasSlotGetOffsets(self.ImgDown)
	DownOffset.Left = Left
	DownOffset.Right = Right
	DownOffset.Bottom = -Bottom
	UIUtil.CanvasSlotSetOffsets(self.ImgDown, DownOffset)

end

---@field GuideWidget 引导层控件
---@field Widget 外部控件
function TutorialGestureMainPanelView:OnCalculateSecondaryMask(GuideWidget, Widget, Type)
	local Parent = Widget:GetParent()
	local ScreenSize = UIUtil.GetScreenSize()
	local WidgetLocPos = UIUtil.CanvasSlotGetPosition(Widget)

	local ParentPanelPos = UIUtil.CanvasSlotGetPosition(Parent)
	local PosID = tonumber(TutorialCfg:GetTutorialEndParam(self.TutorialID))

	local Row = math.ceil(PosID / 3)
	local Col = PosID % 3

	local ItemWidth = self.Widget.EntryWidth
	local ContentSize = ItemWidth - 20
	local ItemSizeX = (ItemWidth - 20) / 2 
	local ColSpace = 20 * (Col - 1)
	local RowSpace = 20 * (Row - 1)

	UIUtil.CanvasSlotSetAlignment(GuideWidget, _G.UE.FVector2D(0.5, 0.5))

	local WidgetPosX = ScreenSize.X + ParentPanelPos.X + WidgetLocPos.X  +  ItemSizeX + ColSpace + (Col - 1) * ContentSize 
	local WidgetPosY = ParentPanelPos.Y + WidgetLocPos.Y + ItemSizeX + RowSpace + (Row - 1) * ContentSize 

	local Left = WidgetPosX - ItemSizeX - 20
	local Right =  ScreenSize.X - (WidgetPosX + ItemSizeX + 20) 
	local Top = WidgetPosY - (ItemSizeX + 20)
	local Bottom = ScreenSize.Y - (WidgetPosY + ItemSizeX + 20)
	
	UIUtil.CanvasSlotSetPosition(GuideWidget, _G.UE.FVector2D(WidgetPosX, WidgetPosY))

	if Type ~= TutorialDefine.TutorialType.Force then
		return
	end

	UIUtil.CanvasSlotSetSize(self.ImgLeft, _G.UE.FVector2D(Left, 0))
	UIUtil.CanvasSlotSetSize(self.ImgRight, _G.UE.FVector2D(-Right, 0))

	local TopOffset = UIUtil.CanvasSlotGetOffsets(self.ImgTop)
	TopOffset.Left = Left
	TopOffset.Right = Right
	TopOffset.Bottom = Top
	UIUtil.CanvasSlotSetOffsets(self.ImgTop, TopOffset)

	local DownOffset = UIUtil.CanvasSlotGetOffsets(self.ImgDown)
	DownOffset.Left = Left
	DownOffset.Right = Right
	DownOffset.Bottom = -Bottom
	UIUtil.CanvasSlotSetOffsets(self.ImgDown, DownOffset)
	
end


---@field GuideWidget 引导层控件
---@field Widget 外部控件
function TutorialGestureMainPanelView:OnCalculateFriendMask(GuideWidget, Widget, Type)
	local Parent = Widget:GetParent()
	local Grandpa = Parent:GetParent()
	local ScreenSize = UIUtil.GetScreenSize()
	local WidgetLocalPos = UIUtil.GetLocalTopLeft(Widget)
	local WidgetSize = UIUtil.CanvasSlotGetSize(Widget)
	local Col = tonumber(TutorialCfg:GetTutorialEndParam(self.TutorialID))
	local GuideWidgetSize = UIUtil.CanvasSlotGetSize(GuideWidget)

	local ParentPanelPos = UIUtil.GetLocalTopLeft(Parent)
	local GrandpaPos = UIUtil.GetLocalTopLeft(Grandpa)

	local ContentSize = 120
	local Space = 40

	UIUtil.CanvasSlotSetAlignment(GuideWidget, _G.UE.FVector2D(1, 0))

	local WidgetPosX = ParentPanelPos.X + WidgetLocalPos.X + WidgetSize.X + GrandpaPos.X + 20
	local WidgetPosY = ParentPanelPos.Y + GrandpaPos.Y  + ContentSize * (Col - 1) +  Space * (Col - 1)
	UIUtil.CanvasSlotSetPosition(GuideWidget, _G.UE.FVector2D(WidgetPosX, WidgetPosY))

	if Type ~= TutorialDefine.TutorialType.Force then
		return
	end

	local Left = WidgetPosX - GuideWidgetSize.X + 30
	local Right = ScreenSize.X - WidgetPosX + 30
	local Top = WidgetPosY + 30
	local Bottom = ScreenSize.Y - (WidgetPosY + GuideWidgetSize.Y) + 30

	UIUtil.CanvasSlotSetSize(self.ImgLeft, _G.UE.FVector2D(Left, 0))
	UIUtil.CanvasSlotSetSize(self.ImgRight, _G.UE.FVector2D(-Right, 0))

	local TopOffset = UIUtil.CanvasSlotGetOffsets(self.ImgTop)
	TopOffset.Left = Left
	TopOffset.Right = Right
	TopOffset.Bottom = Top
	UIUtil.CanvasSlotSetOffsets(self.ImgTop, TopOffset)

	local DownOffset = UIUtil.CanvasSlotGetOffsets(self.ImgDown)
	DownOffset.Left = Left
	DownOffset.Right = Right
	DownOffset.Bottom = -Bottom
	UIUtil.CanvasSlotSetOffsets(self.ImgDown, DownOffset)
end

function TutorialGestureMainPanelView: OnCalculateBigMask(PosX,PosY,Width,Height)
	local ScreenSize = UIUtil.GetScreenSize()
	local ViewportSize = UIUtil.GetViewportSize()
	--local TargetWidgetSize = UIUtil.GetWidgetSize(Widget)
	--local TargetAbsolutePosition = UIUtil.GetWidgetAbsoluteTopLeft(Widget)

	--local TargetPosition = _G.UE.FVector2D(0, 0)
	--local TargetWidgetSize = _G.UE.FVector2D(Width, Height)
	--local WindowAbsolute = UIUtil.ScreenToWidgetAbsolute( _G.UE.FVector2D(0, 0), false)

	UIUtil.CanvasSlotSetSize(self.ImgLeft, _G.UE.FVector2D(PosX - Width / 2.0, 0))
	UIUtil.CanvasSlotSetSize(self.ImgRight, _G.UE.FVector2D(-(ScreenSize.X - PosX - Width / 2.0), 0))

	local TopOffset = UIUtil.CanvasSlotGetOffsets(self.ImgTop)
	TopOffset.Left = PosX - Width / 2.0
	TopOffset.Right = ScreenSize.X - PosX - Width / 2.0
	TopOffset.Bottom = PosY - Height / 2.0
	UIUtil.CanvasSlotSetOffsets(self.ImgTop, TopOffset)

	local DownOffset = UIUtil.CanvasSlotGetOffsets(self.ImgDown)
	DownOffset.Left = PosX - Width / 2.0
	DownOffset.Right = ScreenSize.X - PosX - Width / 2.0
	DownOffset.Bottom = -(ScreenSize.Y - (PosY + Height / 2.0))
	UIUtil.CanvasSlotSetOffsets(self.ImgDown, DownOffset)

end

--- Todo  计算地图任务上的位置
function TutorialGestureMainPanelView:OnCalculateMapItem(GuideWidget)

	local TutorialID = self.TutorialID

	local UIBPName = TutorialCfg:GetTutorialBPName(TutorialID)
    local WidgetPath = TutorialCfg:GetTutorialWidgetPath(TutorialID)
    local ViewID = UIViewMgr:GetViewIDByName(UIBPName)
    local View = UIViewMgr:FindVisibleView(ViewID)
    local Widgets = TutorialUtil:GetTutorialWidget(View, WidgetPath)
	local EndID =  TutorialCfg:GetTutorialEndParam(TutorialID)

	local Widget = nil
	self.Widget = Widgets

	for _, v in pairs(Widgets) do
		if v.ViewModel.MapMarker.ID == tonumber(EndID) then
			Widget = v.View
		end
	end

	if Widget == nil then
		return
	end

	local ScreenSize = UIUtil.GetScreenSize()
	local Parent = Widget:GetParent()

	local ParentPanelSize = UIUtil.CanvasSlotGetSize(Parent)

	local WidgetLocalPos = UIUtil.CanvasSlotGetPosition(Widget)   --Widget在地图里的位置
	local GuideWidgetSize = UIUtil.CanvasSlotGetSize(Widget)

	local WidgetPosX = (ScreenSize.X - ParentPanelSize.X ) / 2 + WidgetLocalPos.X - GuideWidgetSize.X + 30
	local WidgetPosY = (ScreenSize.Y - ParentPanelSize.Y ) / 2 + WidgetLocalPos.Y - GuideWidgetSize.Y - 40

	UIUtil.CanvasSlotSetPosition(GuideWidget, _G.UE.FVector2D(WidgetPosX, WidgetPosY))

end

function TutorialGestureMainPanelView:EndFuncCallback()
	_G.EventMgr:SendEvent(_G.EventID.TutorialTimerEnd, {TutorialID = self.TutorialID})
	--TutorialUtil:HandleClickGuideWidget(self.TutorialID, self.Widget)
end

function TutorialGestureMainPanelView:SetMiniMapPanel(GuideWidgetName, Content, ContentDir, Time, Callback)
	local BMini = self.MiniMapSelect:GetName() == GuideWidgetName
	UIUtil.SetIsVisible(self.MiniMapSelect, BMini, BMini)
	UIUtil.SetIsVisible(self.MiniMapTips, BMini, BMini)
	UIUtil.SetIsVisible(self.MiniMapSelect:GetParent(), BMini, BMini)

	if BMini then
		self.MiniMapTips:NearBy(ContentDir)
		self:SetTipsText(self.MiniMapTips, Content)
		self.MiniMapTips:StartCountDown(Time, self, Callback)
	end
end

function TutorialGestureMainPanelView:SetSkillPanel(GuideWidgetName, Content, ContentDir, Time, Callback)
	local BSkill = self.SkillGenAttackSelect:GetName() == GuideWidgetName
	UIUtil.SetIsVisible(self.SkillGenAttackSelect, BSkill, BSkill)
	UIUtil.SetIsVisible(self.SkillGenAttackTips, BSkill, BSkill)
	UIUtil.SetIsVisible(self.SkillGenAttack, BSkill, BSkill)

	if BSkill then
		self.SkillGenAttackTips:NearBy(ContentDir)
		self:SetTipsText(self.SkillGenAttackTips, Content)
		self.SkillGenAttackTips:StartCountDown(Time, self, Callback)
	end
end

function TutorialGestureMainPanelView:SetMountPanel(GuideWidgetName, Content, ContentDir, Time, Callback)
	local BMountSelect = self.PanelMountSelect:GetName() == GuideWidgetName
	UIUtil.SetIsVisible(self.PanelMountSelect, BMountSelect, BMountSelect)
	UIUtil.SetIsVisible(self.PanelMountTips, BMountSelect, BMountSelect)
	UIUtil.SetIsVisible(self.PanelMount, BMountSelect, BMountSelect)

	if BMountSelect then
		self.PanelMountTips:NearBy(ContentDir)
		self:SetTipsText(self.PanelMountTips, Content)
		self.PanelMountTips:StartCountDown(Time, self, Callback)
	end
end

function TutorialGestureMainPanelView:SetJumpPanel(GuideWidgetName, Content, ContentDir, Time, Callback)
	local BJump = self.JumpSelect:GetName() == GuideWidgetName
	UIUtil.SetIsVisible(self.JumpSelect, BJump, BJump)
	UIUtil.SetIsVisible(self.JumpTips, BJump, BJump)
	UIUtil.SetIsVisible(self.Jump, BJump, BJump)

	if BJump then
		self.JumpTips:NearBy(ContentDir)
		self:SetTipsText(self.JumpTips, Content)
		self.JumpTips:StartCountDown(Time, self, Callback)
	end
end

function TutorialGestureMainPanelView:SetFunctionPanel(GuideWidgetName, Content, ContentDir, Time, Callback)
	local BFunction = self.FunctionSelect:GetName() == GuideWidgetName
	UIUtil.SetIsVisible(self.FunctionSelect, BFunction, BFunction)
	UIUtil.SetIsVisible(self.FunctionTips, BFunction, BFunction)
	UIUtil.SetIsVisible(self.Function, BFunction, BFunction)

	if BFunction then
		self.FunctionTips:NearBy(ContentDir)
		self:SetTipsText(self.FunctionTips, Content)
		self:OnCalculateFunctionMask(self[GuideWidgetName], self.Widget)
		self.FunctionTips:StartCountDown(Time, self, Callback)
	end
end

function TutorialGestureMainPanelView:SetFriendPanel(GuideWidgetName, Content, ContentDir, Time, Callback)
	local BFriend = self.Friend:GetName() == GuideWidgetName
	UIUtil.SetIsVisible(self.Friend, BFriend, BFriend)
	UIUtil.SetIsVisible(self.Map, false, false)

	if BFriend then
		self.Friend:SetTutorialID(self.TutorialID)
		self.Friend:NearBy(ContentDir)
		self.Friend:SetContent(Content)
		self:OnCalculateFriendMask(self[GuideWidgetName], self.Widget, self.Type)
		self.Friend:StartCountDown(Time, self, Callback)
	end
end

function TutorialGestureMainPanelView:SetSecondaryPanel(GuideWidgetName, Content, ContentDir, Time, Callback)
	local BSecondary = self.Secondary:GetName() == GuideWidgetName
	UIUtil.SetIsVisible(self.Secondary, BSecondary, BSecondary)

	if BSecondary then
		self.Secondary:SetTutorialID(self.TutorialID)
		self.Secondary:NearBy(ContentDir)
		self.Secondary:SetContent(Content)
		self:OnCalculateSecondaryMask(self[GuideWidgetName], self.Widget, self.Type)
		self.Secondary:StartCountDown(Time, self, Callback)
	end
end

function TutorialGestureMainPanelView:SetMapPanel(GuideWidgetName, Content, ContentDir, Time, Callback)
	local BMap = self.Map:GetName() == GuideWidgetName
	UIUtil.SetIsVisible(self.Map, BMap, BMap)

	if BMap then
		self.Map:SetTutorialID(self.TutorialID)
		self.Map:NearBy(ContentDir)
		self.Map:SetContent(Content)
		self:StartCountDown(Time, self, Callback)
		self:RegisterTimer(function ()
			self:OnCalculateMapItem(self[GuideWidgetName])
		end, 0.4)
	end
end

function TutorialGestureMainPanelView:SetCommViewSize(Cfg)
	local StartParam = tonumber(Cfg.StartParam)
	local HandleType = Cfg.HandleType
	local WidgetZOrder = 0

	--- 原控件
	local UIBPName = Cfg.BPName
	local ViewID = UIViewMgr:GetViewIDByName(UIBPName)
	local View = UIViewMgr:FindVisibleView(ViewID)
	local WidgetPath = Cfg.WidgetPath
	local Widget = TutorialUtil:GetTutorialWidget(View, WidgetPath)

	local function SetPos(Pos,Size,PivotType)
		if Cfg.Width == 0 and Cfg.Height == 0 then
			if PivotType == TutorialDefine.TutorialPivotType.LeftTop then
				Pos.X = Pos.X + Size.X / 2.0
				Pos.Y = Pos.y + Size.Y / 2.0
			end

			UIUtil.CanvasSlotSetSize(self.Comm.Border_68, UE.FVector2D(Size.X, Size.Y))
			UIUtil.CanvasSlotSetZOrder(self.Comm, WidgetZOrder + 1)
			UIUtil.CanvasSlotSetPosition(self.Comm, Pos)
			UIUtil.CanvasSlotSetSize(self.Comm, UE.FVector2D(Size.X, Size.Y))

			if Cfg.Type == TutorialDefine.TutorialType.Force or Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
				self:OnCalculateBigMask(Pos.X,Pos.Y,Size.X,Size.Y)
			end
		else
			Pos.X = Pos.X + Cfg.OffsetX
			Pos.Y = Pos.y + Cfg.OffsetY

			UIUtil.CanvasSlotSetSize(self.Comm.Border_68, UE.FVector2D(Cfg.Width, Cfg.Height))
			UIUtil.CanvasSlotSetZOrder(self.Comm, WidgetZOrder + 1)
			UIUtil.CanvasSlotSetPosition(self.Comm, Pos)
			UIUtil.CanvasSlotSetSize(self.Comm, UE.FVector2D(Cfg.Width,Cfg.Height))

			if Cfg.Type == TutorialDefine.TutorialType.Force or Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
				self:OnCalculateBigMask(Pos.X,Pos.Y,Cfg.Width,Cfg.Height)
			end
		end
	end

	local function SetProperty(widget)
		if widget ~= nil and widget.GetCachedGeometry ~= nil then
			local Geometry = widget:GetCachedGeometry()
			local Size = UIUtil.GetWidgetSize(widget)

			if Cfg.PivotType == TutorialDefine.TutorialPivotType.LeftTop then
				local _, Pos = _G.UE.USlateBlueprintLibrary.LocalToViewport(View, Geometry, _G.UE.FVector2D(0,0))
				SetPos(Pos,Size,Cfg.PivotType)
			else
				local _, Pos = _G.UE.USlateBlueprintLibrary.LocalToViewport(View, Geometry, _G.UE.FVector2D(Size.X/2.0,Size.Y/2.0))
				--FLOG_INFO("SetCommViewPos %f,%f",Pos.X, Pos.Y)
				SetPos(Pos,Size,Cfg.PivotType)
			end
		else
			FLOG_INFO("widget SetProperty is nil")
		end
	end

	--从对应UI上取位置
	if HandleType == TutorialDefine.TutorialHandleType.TableView then
		--Widget = View[tostring(WidgetPath)]
		local ItemView = self.Widget:GetChildWidget(Cfg.StartParam)

		if ItemView == nil then
			return false
		end

		SetProperty(ItemView)
		return true
	else
		SetProperty(self.Widget)
		return true
	end

	--[[
	if Cfg.PositionX == Cfg.PositionY and Cfg.PositionX == 0 then

	else
		local ScreenSize = UIUtil.GetDesignedSize() --逻辑分辨率
		local ViewportSize = UIUtil.GetViewportSize() --视口大小
		local DPIScale = UIUtil.GetViewportScale()
		local Position = _G.UE.FVector2D(Cfg.PositionX,Cfg.PositionY) --在逻辑分辨率下的位置
		--Position = (Position / ScreenSize) * ViewportSize / DPIScale
		--根据锚点类型重新计算位置
		if Cfg.PivotType == TutorialDefine.TutorialPivotType.Top then
			Position.Y = Position.Y * DPIScale
			Position.X = (ViewportSize.X / 2.0) + (Position.X * DPIScale)
			Position = Position / DPIScale
		elseif Cfg.PivotType == TutorialDefine.TutorialPivotType.RightTop then
			Position.X = ViewportSize.x + (Position.X * DPIScale)
			Position.Y = Position.Y * DPIScale
			Position = Position / DPIScale
		elseif Cfg.PivotType == TutorialDefine.TutorialPivotType.Left then
			Position.X = Position.X * DPIScale
			Position.Y = (ViewportSize.Y / 2.0) + (Position.Y * DPIScale)
			Position = Position / DPIScale
		elseif Cfg.PivotType == TutorialDefine.TutorialPivotType.Center then
			Position.X = (ViewportSize.X / 2.0) + (Position.X * DPIScale)
			Position.Y = (ViewportSize.Y / 2.0) + (Position.Y * DPIScale)
			Position = Position / DPIScale
		elseif Cfg.PivotType == TutorialDefine.TutorialPivotType.Right then
			Position.X = ViewportSize.X + (Position.X * DPIScale)
			Position.Y = (ViewportSize.Y / 2.0) + (Position.Y * DPIScale)
			Position = Position / DPIScale
		elseif Cfg.PivotType == TutorialDefine.TutorialPivotType.LeftBottom then
			Position.X = Position.X * DPIScale
			Position.Y = (ViewportSize.Y) + (Position.Y * DPIScale)
			Position = Position / DPIScale
		elseif Cfg.PivotType == TutorialDefine.TutorialPivotType.Bottom then
			Position.X = (ViewportSize.X / 2.0) + (Position.X * DPIScale)
			Position.Y = (ViewportSize.Y) + (Position.Y * DPIScale)
			Position = Position / DPIScale
		elseif Cfg.PivotType == TutorialDefine.TutorialPivotType.RightBottom then
			Position.X = (ViewportSize.X) + (Position.X * DPIScale)
			Position.Y = (ViewportSize.Y) + (Position.Y * DPIScale)
			Position = Position / DPIScale
		end

		Position.X = Position.X - 5

		--FLOG_WARNING("SetCommViewSize %f,%f",Position.X,Position.Y)

		UIUtil.CanvasSlotSetSize(self.Comm.Border_68, UE.FVector2D(Cfg.Width,Cfg.Height))
		UIUtil.CanvasSlotSetZOrder(self.Comm, WidgetZOrder + 1)
		UIUtil.CanvasSlotSetPosition(self.Comm, Position)
		UIUtil.CanvasSlotSetSize(self.Comm, UE.FVector2D(Cfg.Width,Cfg.Height))

		if Cfg.Type == TutorialDefine.TutorialType.Force or Cfg.Type == TutorialDefine.TutorialType.NoFuncForce then
			self:OnCalculateBigMask(Position.X,Position.Y,Cfg.Width,Cfg.Height)
		end
	end
	--]]
end

function TutorialGestureMainPanelView:SetCommPanel(Content, ContentDir, Time, Callback,IsSystemUI,Cfg)
	self.Comm:SetCurTips(ContentDir,IsSystemUI)
	self.Comm:NearBy(ContentDir,Cfg)
	self.Comm:SetContent(Content)
	self.Comm:SetTutorialID(self.TutorialID)

	--只有软引导才会有时间不然填0
	if Time and Time > 0 then
		self.Comm:StartCountDown(Time, self, Callback)
	end
end

function TutorialGestureMainPanelView:SetTipsText(Widget, Content)
	if UIUtil.IsVisible(Widget) then
		Widget:SetText(Content)
	end
end

function TutorialGestureMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickeBtn)
end

--- 监听移除界面
function TutorialGestureMainPanelView:OnTutorialRemoveGuideView(Params)
	FLOG_WARNING("OnTutorialRemoveGuideView %d,%d",Params.TutorialID,self.TutorialID)
	if Params.TutorialID == self.TutorialID then
		self:RemoveFromParent()
		UIViewMgr:RecycleView(self)
	end
end

function TutorialGestureMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.TutorialRemoveGuideView, self.OnTutorialRemoveGuideView)
end

function TutorialGestureMainPanelView:OnRegisterBinder()
end

function TutorialGestureMainPanelView:OnClickeBtn()
	--无功能强制引导点击黑暗处等于点功能处
	if self.NoFuncForce then
		local Params = {}
		Params.TutorialID = self.TutorialID
		_G.EventMgr:SendEvent(_G.EventID.TutorialEnd, Params)
		return
	else
		_G.EventMgr:SendEvent(_G.EventID.ForceCloseTutorial)
	end
end

return TutorialGestureMainPanelView