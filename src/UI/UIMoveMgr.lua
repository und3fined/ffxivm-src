local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local EventMgr = require("Event/EventMgr")
local TimerMgr = require("Timer/TimerMgr")
local UIViewMgr = require("UI/UIViewMgr")

local UIMoveMgr = LuaClass(MgrBase)

function UIMoveMgr:OnInit()
	self.MoveInfo = {}
	self.CacheInfo = {}
end

function UIMoveMgr:OnBegin()
end

function UIMoveMgr:OnEnd()
end

function UIMoveMgr:OnShutdown()

end

function UIMoveMgr:OnRegisterNetMsg()

end

function UIMoveMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.WidgetDragStart, self.OnWidgetTouchStart)
	self:RegisterGameEvent(EventID.WidgetDragMove, self.OnWidgetTouchMove)
	self:RegisterGameEvent(EventID.WidgetDragEnd, self.OnWidgetTouchEnd)
	self:RegisterGameEvent(EventID.WidgetDragConfirm, self.OnConfirmMove)
	self:RegisterGameEvent(EventID.WidgetDragCancel, self.OnCancelMove)
	self:RegisterGameEvent(EventID.ResetDragUI, self.ResetAllUI)

	-- self:RegisterGameEvent(EventID.DragUIMove, self.OnDragMove)
end

function UIMoveMgr:OnRegisterTimer()

end

function UIMoveMgr:OnWidgetTouchStart(widget, mousex, mousey)
	-- self:print("touch start")
	if nil == widget or nil == widget.ViewID then
		return
	end

	if nil == self.MaskView then
		self:ClearWidgetTimer(widget.ViewID)

		self.MoveInfo[widget.ViewID] = {}
		self.MoveInfo[widget.ViewID].Timer = TimerMgr:AddTimer(self, self.OnWidgetTimeReach, 1.0, 1.0, 1, widget)

		if nil == self.CacheInfo[widget] then
			self.CacheInfo[widget] = {}
			self.CacheInfo[widget].widget = widget
			self.CacheInfo[widget].pos = _G.UE.FVector2D(0,0)
			self.CacheInfo[widget].pos = UIUtil.CanvasSlotGetPosition(widget)
		end
	end
	-- 记录复制控件位置, 用于 复制控件 的拖动
	local info = self.MoveInfo[widget.ViewID]
	if (info ~= nil) then
		info.baseMousePos = _G.UE.FVector2D(mousex, mousey)
		info.clonePos = _G.UE.FVector2D(0,0)
		info.clonePos = UIUtil.WidgetLocalToViewport(widget, 0, 0)
	end
end

function UIMoveMgr:OnWidgetTouchEnd(widget)
	-- self:print("touch end")

	self:ClearWidgetTimer(widget.ViewID)
end

function UIMoveMgr:OnWidgetTouchMove(widget, mousex, mousey)
	-- self:print("touch move")

	if nil == widget then return end



	if nil ~= self.MoveInfo[widget.ViewID] then

		if nil ~= self.MaskView then
			local info = self.MoveInfo[widget.ViewID]
			if info.CloneWidget == widget then
				local diffPos = _G.UE.FVector2D(mousex, mousey) - info.baseMousePos
				local screenDpi = _G.UE.UWidgetLayoutLibrary.GetViewportScale(widget)
				local CurWidgetPos = info.clonePos + diffPos / screenDpi
				-- 复制控件 的拖动
				widget:SetPositionInViewport(CurWidgetPos, false)
			else
				-- hack: 按下后一直没松开, 但是也同样要移动
				if nil == info.baseMousePos then
					info.baseMousePos = _G.UE.FVector2D(mousex, mousey)
					info.clonePos = _G.UE.FVector2D(0,0)
					info.clonePos = UIUtil.WidgetLocalToViewport(info.CloneWidget, 0, 0)
				else
					self:OnWidgetTouchMove(info.CloneWidget, mousex, mousey)
				end
			end
		end
	end
end

function UIMoveMgr:ClearWidgetTimer(ViewID)
	if nil ~= self.MoveInfo[ViewID] and nil ~= self.MoveInfo[ViewID].Timer then
		TimerMgr:CancelTimer(self.MoveInfo[ViewID].Timer)
		self.MoveInfo[ViewID].Timer = nil
	end
end

function UIMoveMgr:OnWidgetTimeReach(widget)
	if nil == widget or nil == widget.ViewID then
		return
	end
	local info = self.MoveInfo[widget.ViewID]
	if nil ~= info then
		-- 记录原控件位置, 用于 原控件 的移动
		info.originPos = _G.UE.FVector2D(0,0)
		info.originPos = UIUtil.CanvasSlotGetPosition(widget)

		info.EnableMove = true
		info.Timer = nil
		-- 复制控件, 并记录位置, 用于 原控件 的移动
		info.CloneWidget = self:CloneWidgetAtSamePos(widget)
		info.beforePos = _G.UE.FVector2D(0,0)
		info.beforePos = UIUtil.WidgetLocalToViewport(widget, 0, 0)
		info.defaultWidget = widget

		-- hack: 延迟更新
		local delayCallback = function()
			EventMgr:SendEvent(EventID.WidgetDragMove)
		end
		TimerMgr:AddTimer(self, delayCallback, 0.1, 1.0, 1)

		-- 开启遮蔽
		self:EnableMask()
	end
end

function UIMoveMgr:OnConfirmMove(widget)
	if nil == widget or nil == widget.ViewID then
		return
	end

	local info = self.MoveInfo[widget.ViewID]
	if nil == info or nil == info.CloneWidget then
		return
	end

	local ViewID = widget.ViewID
	local afterPos = UIUtil.WidgetLocalToViewport(info.CloneWidget, 0, 0)

	-- 删除拖动控件
	info.CloneWidget:RemoveFromViewport()
	if nil ~= info.CloneWidget.ViewID then
		UIViewMgr:RecycleView(info.CloneWidget)
		--info.CloneWidget:HideView()
		--info.CloneWidget:DestroyView()
		info.CloneWidget = nil
	end

	if nil == info.defaultWidget or nil == info.defaultWidget.ViewID then
		return
	end

	local diffPos = afterPos - info.beforePos
	local screenDpi = _G.UE.UWidgetLayoutLibrary.GetViewportScale(info.defaultWidget)
	local CurWidgetPos = info.originPos + diffPos
	-- 原控件 的移动
	UIUtil.CanvasSlotSetPosition(info.defaultWidget, CurWidgetPos)

	-- 清空信息
	self.MoveInfo[ViewID] = {}
	-- 取消遮蔽
	self:UnableMask()
end

function UIMoveMgr:OnCancelMove(widget)
	-- 点击遮蔽触发的取消
	if nil == widget then
		for key, value in pairs(self.MoveInfo) do
			widget = value.defaultWidget
			break
		end
	end

	if nil == widget or nil == widget.ViewID then
		return
	end
	local ViewID = widget.ViewID
	local info = self.MoveInfo[ViewID]
	if nil == info or nil == info.CloneWidget then
		return
	end

	info.CloneWidget:RemoveFromViewport()
	if nil ~= info.CloneWidget.ViewID then
		UIViewMgr:RecycleView(info.CloneWidget)
		--info.CloneWidget:HideView()
		--info.CloneWidget:DestroyView()
		info.CloneWidget = nil
	end

	if nil == info.defaultWidget or nil == info.defaultWidget.ViewID then
		return
	end
	-- 还原 原控件 的位置
	local CurWidgetPos = info.originPos
	UIUtil.CanvasSlotSetPosition(info.defaultWidget, CurWidgetPos)

	-- 清空信息
	self.MoveInfo[ViewID] = {}
	-- 取消遮蔽
	self:UnableMask()
end

function UIMoveMgr:CloneWidgetAtSamePos(widget)
	local view = UIViewMgr:CloneView(widget, nil, widget.EntityID)
	view.ViewID = widget.ViewID
	-- view.EnableMove = true
	--view:ShowView(widget.EntityID)
	view:AddToViewport(2)

	local DesignSize = widget:GetDesiredSize()

	local viewPortPos = UIUtil.WidgetLocalToViewport(widget, 0 , 0)

	-- self:print("set pos: " .. tostring(viewPortPos))
	view:SetPositionInViewport(viewPortPos, false)

	if nil ~= view.EnableMoveView then
		view:EnableMoveView(DesignSize)
	end

	return view
end

function UIMoveMgr:EnableMask()
	if self.MaskView then
		return
	end

	local view = UIViewMgr:CreateView(UIViewID.MainUIMoveMask, nil, true, true)
	--view:ShowView()
	view:AddToViewport(1)
	self.MaskView = view
end

function UIMoveMgr:UnableMask()
	-- self:print("called unable")

	if nil ~= self.MaskView then
		UIViewMgr:RecycleView(self.MaskView)
		self.MaskView:RemoveFromViewport()
		self.MaskView = nil
	end
end

function UIMoveMgr:ResetAllUI()
	for key, value in pairs(self.CacheInfo) do
		local widget = value.widget
		local pos = value.pos
		UIUtil.CanvasSlotSetPosition(widget, pos)
	end
end

function UIMoveMgr:print(s)
	_G.UE.UKismetSystemLibrary.PrintString(self, tostring(s), true, false, _G.UE.FLinearColor(1,1,1,1),2)
end

return UIMoveMgr