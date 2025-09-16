local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local UIUtil = require("Utils/UIUtil")
local HelpCfg = require("TableCfg/HelpCfg")
local UUIUtil = _G.UE.UUIUtil
local FLOG_WARNING = _G.FLOG_WARNING

local DefaultFVector2D = _G.UE.FVector2D(0, 0)

local TipsUtil = {}

-- 展示文字说明Tips
---ShowInfoTips
---@param Content (string, table)        显示内容{Title, <Content>}
---@param InTargetWidget Widget 对齐控件 可以nil
---@param Offset FVector2D	    Tips的偏移位置
---@param Alignment FVector2D   Tips的对齐方式
---@param HidePopUpBG boolean   隐藏关闭View
---@param ClickedParams <View, HidePopUpBGCallback>  需要重写点击PopBgCallback事件，HidePopUpBG = false
---@return UIView	
function TipsUtil.ShowInfoTips(Content, InTargetWidget, Offset, Alignment, HidePopUpBG, ClickedParams)
	local ViewID = UIViewID.CommHelpInfoTipsView
	local Params = {}
	Params.Data = table.is_nil_empty(Content) and {{Title = "", Content = {Content}}} or Content
	Params.Offset = Offset or DefaultFVector2D
	Params.Alignment = Alignment or DefaultFVector2D
	Params.InTargetWidget = InTargetWidget
	Params.HidePopUpBG = HidePopUpBG
	if ClickedParams then
		Params.View = ClickedParams.View or nil
		Params.HidePopUpBGCallback = ClickedParams.HidePopUpBGCallback or nil
	end
    return UIViewMgr:ShowView(ViewID, Params)
end

---@param Content table        显示内容{Title, <Content>}
---@param InTargetWidget Widget 对齐控件
---@param Offset FVector2D	    Tips的偏移位置
---@param Alignment FVector2D   Tips的对齐方式
---@param HidePopUpBG boolean   隐藏关闭View
---@param ClickedParams <View, HidePopUpBGCallback>  需要重写点击PopBgCallback事件，HidePopUpBG = false
---@return UIView	
function TipsUtil.ShowInfoTitleTips(Content, InTargetWidget, Offset, Alignment, HidePopUpBG, ClickedParams)
	local ViewID = UIViewID.CommHelpInfoTitleTipsView
	local Params = {}
	Params.Data = Content
	Params.Offset = Offset or DefaultFVector2D
	Params.Alignment = Alignment or DefaultFVector2D
	Params.InTargetWidget = InTargetWidget
	Params.HidePopUpBG = HidePopUpBG
	if ClickedParams then
		Params.View = ClickedParams.View or nil
		Params.HidePopUpBGCallback = ClickedParams.HidePopUpBGCallback or nil
	end
    return UIViewMgr:ShowView(ViewID, Params)
end

-- example:
-- local Data = {
-- 	Title = "职业",
-- 	Content = {self.ViewModel.ProfDescription},
-- 	SubTitle = "转职途径",
-- 	JumpWay = {
-- 		JumpTitle = "1111",
-- 		JumpIcon = "Texture2D'/Game/Assets/Icon/071000HUD/UI_Icon_071241.UI_Icon_071241'",
-- 		IsRedirect = true,
-- 		View = self, 
-- 		GoClickedCallback = function ()
-- 			print("111111")
-- 		end,
-- 	}
-- }
---@param Content table         显示内容
---@param InTargetWidget Widget 对齐控件
---@param Offset FVector2D	    Tips的偏移位置
---@param Alignment FVector2D   Tips的对齐方式
---@param HidePopUpBG boolean   隐藏关闭View
---@param ClickedParams <View, HidePopUpBGCallback>  需要重写点击PopBgCallback事件，HidePopUpBG = false
---@return UIView
function TipsUtil.ShowInfoJumpTips(Content, InTargetWidget, Offset, Alignment, HidePopUpBG, ClickedParams)
	local ViewID = UIViewID.CommHelpInfoJumpTipsView
	local Params = {}
	Params.Data = Content
	Params.Offset = Offset or DefaultFVector2D
	Params.Alignment = Alignment or DefaultFVector2D
	Params.InTargetWidget = InTargetWidget
	Params.HidePopUpBG = HidePopUpBG
	if ClickedParams then
		Params.View = ClickedParams.View or nil
		Params.HidePopUpBGCallback = ClickedParams.HidePopUpBGCallback or nil
	end
    return UIViewMgr:ShowView(ViewID, Params)
end

-- 展示按钮组Tips
---@param BtnList <Content, ClickItemCallback, View>
---@param InTargetWidget Widget 对齐控件
---@param Offset FVector2D		偏移位置
---@param Alignment FVector2D	偏移位置
---@param HidePopUpBG boolean 	隐藏关闭View
---@param ClickedParams <View, HidePopUpBGCallback>  需要重写点击PopBgCallback事件，HidePopUpBG = false
---@return UIView
function TipsUtil.ShowStorageBtnsTips(BtnList, InTargetWidget, Offset, Alignment, HidePopUpBG, ClickedParams)
	local ViewID = UIViewID.CommStorageTipsView
	local Params = {}
	Params.Data = BtnList -- 按钮组数据
	Params.InTargetWidget = InTargetWidget
	Params.Offset = Offset or DefaultFVector2D
	Params.Alignment = Alignment or DefaultFVector2D
	Params.HidePopUpBG = HidePopUpBG

	if ClickedParams then
		Params.View = ClickedParams.View or nil
		Params.HidePopUpBGCallback = ClickedParams.HidePopUpBGCallback or nil
	end

    return UIViewMgr:ShowView(ViewID, Params)
end

-- 展示跳转tips 带标题带Icon带箭头的Tips
---@param DataList <Icon,Content,ArrowVisible,ClickItemCallback>
---@param Title string 标题
---@param InTargetWidget Widget 目标控件
---@param Offset FVector2D		偏移位置
---@param Alignment FVector2D	偏移位置
---@param HidePopUpBG boolean 隐藏关闭View
---@param ClickedParams <View, HidePopUpBGCallback>  需要重写点击PopBgCallback事件，HidePopUpBG = false
---@return UIView
function TipsUtil.ShowJumpTitleTips(DataList, Title,  InTargetWidget, Offset, Alignment, HidePopUpBG, ClickedParams)
	local ViewID = UIViewID.CommJumpWayTitleTipsView
	local Params = {}
	Params.Data = DataList
	Params.Title = Title
	Params.InTagetView = InTargetWidget
	Params.Offset = Offset or DefaultFVector2D
	Params.Alignment = Alignment or DefaultFVector2D
	Params.HidePopUpBG = HidePopUpBG
	if ClickedParams then
		Params.View = ClickedParams.View or nil
		Params.HidePopUpBGCallback = ClickedParams.HidePopUpBGCallback or nil
	end
    return UIViewMgr:ShowView(ViewID, Params)
end

-- 展示获取途径的界面
---@param TipsVM 如需上报 TipsVM 需给Source赋值 BagDefine.ItemGetWaySource
---@param InParams <Icon,IsEnabled,ClickItemCallback>
---@param InTargetWidget Widget 对齐控件
---@param Offset FVector2D	偏移位置
---@param Alignment FVector2D	对齐方式
---@param HidePopUpBG boolean 隐藏关闭View
---@param ClickedParams <View, HidePopUpBGCallback>  需要重写点击PopBgCallback事件，HidePopUpBG = false
---@return UIView
function TipsUtil.ShowGetWayTips(TipsVM, ForbidRangeWidget, InTargetWidget, Offset, Alignment, HidePopUpBG, ClickedParams, ParentViewID, AdjustTips)
	local ViewID = UIViewID.CommGetWayTipsView
	local Params = {}
	Params.ViewModel = TipsVM
	Params.ViewModel.ParentViewID = ParentViewID
	Params.InTagetView = InTargetWidget
	Params.ForbidRangeWidget = ForbidRangeWidget
	Params.Offset = Offset or DefaultFVector2D
	Params.Alignment = Alignment or DefaultFVector2D
	Params.HidePopUpBG = HidePopUpBG
	Params.AdjustTips = AdjustTips
	if ClickedParams then
		Params.View = ClickedParams.View or nil
		Params.HidePopUpBGCallback = ClickedParams.HidePopUpBGCallback or nil
	end
    return UIViewMgr:ShowView(ViewID, Params)
end

-- 展示跳转tips 不带标题带Icon带箭头的Tips
---@param InParams.DataList <Icon,Content,ArrowVisible,ClickItemCallback, View>
---@param InParams.SelectedIndex 选中Index
---@param InTargetWidget Widget 目标控件
---@param Offset FVector2D	偏移位置
---@param Alignment FVector2D 对齐位置
---@param HidePopUpBG boolean 隐藏关闭View
---@param ClickedParams <View, HidePopUpBGCallback>  需要重写点击PopBgCallback事件，HidePopUpBG = false
---@return UIView
function TipsUtil.ShowJumpToTips(InParams, InTargetWidget, Offset, Alignment, HidePopUpBG, ClickedParams)
	local ViewID = UIViewID.CommJumpWayTipsView
	local Params = {}
	Params.Data = InParams.Data
	Params.SelectedIndex = InParams.SelectedIndex and InParams.SelectedIndex or 1
	Params.InTargetWidget = InTargetWidget
	Params.Offset = Offset or DefaultFVector2D
	Params.Alignment = Alignment or DefaultFVector2D
	Params.HidePopUpBG = HidePopUpBG
	if ClickedParams then
		Params.View = ClickedParams.View or nil
		Params.HidePopUpBGCallback = ClickedParams.HidePopUpBGCallback or nil
	end
    return UIViewMgr:ShowView(ViewID, Params)
end

-- 展示IconListTips, 全是图标的界面
---@param InParams <Icon,IsEnabled,ClickItemCallback>
---@param InTargetWidget Widget 对齐控件
---@param Offset FVector2D	偏移位置
---@param Alignment FVector2D	对齐方式
---@param HidePopUpBG boolean 隐藏关闭View
---@param ClickedParams <View, HidePopUpBGCallback>  需要重写点击PopBgCallback事件，HidePopUpBG = false 
---@return UIView
function TipsUtil.ShowIconListTips(InParams, InTargetWidget, Offset, Alignment, HidePopUpBG, ClickedParams)
	local ViewID = UIViewID.CommJumpWayIconTipsView
	local Params = {}
	Params.Data = InParams.Data  -- Icon数据
	Params.SelectedIndex = InParams.SelectedIndex and InParams.SelectedIndex or 1
	Params.ClickItemCallback = InParams.ClickItemCallback
	Params.InTargetWidget = InTargetWidget
	Params.View = InParams.View
	Params.Offset = Offset or DefaultFVector2D
	Params.Alignment = Alignment or DefaultFVector2D
	Params.HidePopUpBG = HidePopUpBG
	if ClickedParams then
		Params.View = ClickedParams.View or nil
		Params.HidePopUpBGCallback = ClickedParams.HidePopUpBGCallback or nil
	end
	return UIViewMgr:ShowView(ViewID, Params)
end

-- 展示简单的title+Content的Tips界面
---@param InParams <ID, Title, Content> 有ID就查表，没有ID就直接用Title，Content
---@param InTargetWidget Widget 对齐控件
---@param Offset FVector2D	偏移位置
---@param Alignment FVector2D	对齐方式
---@param HidePopUpBG boolean 隐藏关闭View
---@param ClickedParams <View, HidePopUpBGCallback>  需要重写点击PopBgCallback事件，HidePopUpBG = false 
---@return UIView
function TipsUtil.ShowSimpleTipsView(InParams, InTargetWidget, Offset, Alignment, HidePopUpBG, ClickedParams)
	local Params = {}
	if InParams.ID == nil then
		Params.Title = InParams.Title
		Params.Content = InParams.Content
	else
		local HelpCfgs = HelpCfg:FindAllHelpIDCfg(InParams.ID)
		if HelpCfgs == nil then
			FLOG_WARNING("TipsUtil.ShowSimpleTipsView ID %d Cfg is Nil", InParams.ID)
			return
		end
		Params.Title = HelpCfgs[1].TitleName
		Params.Content = HelpCfgs[1].SecContent
	end
	Params.InTargetWidget = InTargetWidget
	Params.View = InParams.View
	Params.Offset = Offset or DefaultFVector2D
	Params.Alignment = Alignment or DefaultFVector2D
	Params.HidePopUpBG = HidePopUpBG
	if ClickedParams then
		Params.View = ClickedParams.View or nil
		Params.HidePopUpBGCallback = ClickedParams.HidePopUpBGCallback or nil
	end
	return UIViewMgr:ShowView(UIViewID.CommHelpInfoSimpleTipsView, Params)
end

---@param InTargetWidget Widget  对齐控件
---@param Offset FVector2D	     Tips的偏移位置
---@param Alignment FVector2D    Tips的对齐方式
---@param Alignment FVector2D    Tips的对齐方式
---@param ClickCallback function 按钮的回调
---@param HidePopUpBG boolean    隐藏关闭View
---@param ClickedParams <View, HidePopUpBGCallback>  需要重写点击PopBgCallback事件，HidePopUpBG = false
---@return UIView
function TipsUtil.ShowReportTips(InTargetWidget, Offset, Alignment, ClickCallback, HidePopUpBG, ClickedParams)
	local ViewID = UIViewID.ReportTips
	local Params = {}
	Params.Offset = Offset or DefaultFVector2D
	Params.Alignment = Alignment or DefaultFVector2D
	Params.InTargetWidget = InTargetWidget
	Params.HidePopUpBG = HidePopUpBG
	Params.ClickCallback = ClickCallback
	if ClickedParams then
		Params.View = ClickedParams.View or nil
		Params.HidePopUpBGCallback = ClickedParams.HidePopUpBGCallback or nil
	end
    return UIViewMgr:ShowView(ViewID, Params)
end

--- 调整tips位置
---@param InTipsWidget string Tips控件
---@param InTargetWidget Widget 目标控件
---@param InOffset FVector2D 偏移位置
---@param Alignment FVector2D 对齐方式-(锚点位置)
---@param MaxSize FVector2D 当获取不到tip的实际大小时，使用它的最大值
function TipsUtil.AdjustTipsPosition(InTipsWidget, InTargetWidget, InOffset, Alignment, MaxSize, Params)
	if nil == InTipsWidget then
		return
	end
    if nil == InTargetWidget then
		return
	end

	local ScreenSize = UIUtil.GetScreenSize()
	local ViewportSize = UIUtil.GetViewportSize()
	--local TargetWidgetSize = UUIUtil.CanvasSlotGetSize(InTargetWidget)
	local TargetWidgetSize = UIUtil.GetWidgetSize(InTargetWidget)
	local TipsWidgetSize = UIUtil.CanvasSlotGetSize(InTipsWidget)

	local IsAutoSize = UIUtil.CanvasSlotGetAutoSize(InTipsWidget) -- BP资源中勾选SizeToContent
	if IsAutoSize then
		TipsWidgetSize = UIUtil.GetLocalSize(InTipsWidget)
	else
		TipsWidgetSize = UIUtil.CanvasSlotGetSize(InTipsWidget)
	end

	local MinY = 26
	local MinX = 34

	local TargetWidgetPosition = {}

	local TragetAbsolute = UIUtil.GetWidgetAbsolutePosition(InTargetWidget)
	local WidgetPixelPosition = UIUtil.AbsoluteToViewport(TragetAbsolute)

	TargetWidgetPosition.X = WidgetPixelPosition.X * ScreenSize.X / ViewportSize.X
	TargetWidgetPosition.Y = WidgetPixelPosition.Y * ScreenSize.Y / ViewportSize.Y

	local Position = _G.UE.FVector2D(0, 0)
	local Margin = 10

	Position.X = TargetWidgetPosition.X + TargetWidgetSize.X + Margin
	if nil ~= InOffset and nil ~= InOffset.X then
		Position.X = Position.X + InOffset.X
	end


	Position.Y = TargetWidgetPosition.Y


	if nil ~= InOffset and nil ~= InOffset.Y then
		Position.Y = Position.Y + InOffset.Y
	end

	local BottomMargin = 12

	if Alignment.Y == 0.0 then
		if ScreenSize.Y - BottomMargin - Position.Y < TipsWidgetSize.Y then
			Position.Y = ScreenSize.Y - BottomMargin - TipsWidgetSize.Y
		end
	end

	-- 安全区判断
    local SelfSize = _G.UE.FVector2D(0, 0)

	local IsAutoSize = UIUtil.CanvasSlotGetAutoSize(InTipsWidget) -- BP资源中勾选SizeToContent
	if IsAutoSize then
		SelfSize = UIUtil.GetLocalSize(InTipsWidget)
	else
		SelfSize = UIUtil.CanvasSlotGetSize(InTipsWidget)
	end

	if SelfSize.X == 0 and SelfSize.Y == 0 and MaxSize ~= nil then
		SelfSize = MaxSize
	end

	-- 上下浮动
	if Alignment.Y == 0.0 then
		local MaxPosY = ScreenSize.Y - MinY
		-- 偏移的大小等于最大位置
		if Position.Y + SelfSize.Y > MaxPosY then  
			-- 将对象向上移动，使其顶部不超过MaxPosY  
			Position.Y = MaxPosY - SelfSize.Y  - MinY
		elseif Position.Y  < MinY then  
			-- 如果对象在安全区域之上，将其移动到安全区域顶部  
			Position.Y = MinY  
		end  

	elseif Alignment.Y == 1.0 then
		local MaxPosY = ScreenSize.Y - MinY
		if Position.Y > MaxPosY then  
			-- 将对象向下移动，使其底部不超过MaxPosY  
			Position.Y = MaxPosY
		elseif Position.Y < MinY + SelfSize.Y then  
			Position.Y = MinY  + SelfSize.Y 
		end  
	end

	-- 左右浮动,
	if Alignment.X == 0.0 then  
		local MaxPosX = ScreenSize.X - MinX
		if Position.X + SelfSize.X > MaxPosX then  
			-- 右边界对齐到MaxPosX
			Position.X = MaxPosX - SelfSize.X - MinX
		elseif Position.X < MinX then  
			Position.X = MinX -- 左边界对齐到MinX
		end
	elseif Alignment.X == 1.0 then
		local SafeMarginRight = MinX -- 假设右侧边距与左侧相同
		local MaxPosX = ScreenSize.X - SafeMarginRight
		local MinPosX = MinX + SelfSize.X -- 确保对象左边界不越界
		
		if Position.X < MinPosX then
			Position.X = MinPosX
		elseif Position.X > MaxPosX then
			Position.X = MaxPosX
		end
	end

	local Slot = UIUtil.SlotAsCanvasSlot(InTipsWidget)
	if nil == Slot then
		return
	end

	Slot:SetAlignment(Alignment)
	Slot:SetPosition(Position)

end

function TipsUtil.AdjustTipsPositionByPos(InTipsWidget, ScreenPosition, Alignment, MaxSize, Params)
	if nil == InTipsWidget then
		return
	end
	local TipsWidgetSize = UIUtil.CanvasSlotGetSize(InTipsWidget)
	local IsAutoSize = UIUtil.CanvasSlotGetAutoSize(InTipsWidget) -- BP资源中勾选SizeToContent
	if IsAutoSize then
		TipsWidgetSize = UIUtil.GetLocalSize(InTipsWidget)
	else
		TipsWidgetSize = UIUtil.CanvasSlotGetSize(InTipsWidget)
	end
	local TargetWidgetPosition  = UIUtil.LocalToViewport(InTipsWidget, ScreenPosition)
	local Position = _G.UE.FVector2D(0, 0)

	Position.X = TargetWidgetPosition.X
	Position.Y = TargetWidgetPosition.Y
	local Slot = UIUtil.SlotAsCanvasSlot(InTipsWidget)
	if nil == Slot then
		return
	end
	Slot:SetAlignment(Alignment)
	Slot:SetPosition(Position)
end


return TipsUtil