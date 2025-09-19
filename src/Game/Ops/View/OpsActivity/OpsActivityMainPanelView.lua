---
--- Author: Administrator
--- DateTime: 2024-10-24 19:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local UIAdapterTreeView = require("UI/Adapter/UIAdapterTreeView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local OpsActivityMainVM = require("Game/Ops/VM/OpsActivityMainVM")
local ActivityCfg = require("TableCfg/ActivityCfg")
local EventID = require("Define/EventID")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local DataReportUtil = require("Utils/DataReportUtil")
local ReportButtonType = require("Define/ReportButtonType")
local OperationUtil = require("Utils/OperationUtil")
local ObjectGCType = require("Define/ObjectGCType")
local UIViewConfig = require("Define/UIViewConfig")

local ParentDesiredSize = 114
local ChildDesiredSize = 84
local MenuDesiredSize = 0
local OpsActivityMgr

---@class OpsActivityMainPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ActvityPanel UFCanvasPanel
---@field BtnConsult UFButton
---@field CloseBtn CommonCloseBtnView
---@field CommMenu OpsCommTabView
---@field CommonTitle CommonTitleView
---@field ImgBG UFImage
---@field ImgDown UFImage
---@field ImgMask UFImage
---@field PanelBG UFCanvasPanel
---@field AnimChangeActivity UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimMenuBack UWidgetAnimation
---@field AnimMenuOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsActivityMainPanelView = LuaClass(UIView, true)

function OpsActivityMainPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ActvityPanel = nil
	--self.BtnConsult = nil
	--self.CloseBtn = nil
	--self.CommMenu = nil
	--self.CommonTitle = nil
	--self.ImgBG = nil
	--self.ImgDown = nil
	--self.ImgMask = nil
	--self.PanelBG = nil
	--self.AnimChangeActivity = nil
	--self.AnimIn = nil
	--self.AnimMenuBack = nil
	--self.AnimMenuOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsActivityMainPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.CommMenu)
	self:AddSubView(self.CommonTitle)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsActivityMainPanelView:OnInit()
	self.TreeViewAdapter = UIAdapterTreeView.CreateAdapter(self, self.CommMenu.TreeViewMenu, self.OnTreeViewTabsSelectChanged, true, false)
    self.Binders = {
        { "ActivityTreeList", UIBinderUpdateBindableList.New(self, self.TreeViewAdapter)},
    }

	OpsActivityMgr = _G.OpsActivityMgr
end

function OpsActivityMainPanelView:OnDestroy()
end

function OpsActivityMainPanelView:OnTreeViewTabsSelectChanged(Index, ItemData, ItemView)
    if nil == ItemData then
        return
    end
    local ActivityData = ItemData
    if nil == ActivityData or string.isnilorempty(ActivityData:GetBPName()) then
        return
    end

	if self.DisplayKey ~= nil then
		local Cfg = ActivityCfg:FindCfgByKey(self.DisplayKey)
		if Cfg and Cfg.ClassifyID ~= ActivityData:GetClasscifyID() then
			self.TreeViewAdapter:SetIsExpansion(Cfg.ClassifyID, false)
		end
	end

	if ActivityData.CanExpanded == true then
		self:SetSelectedKey(ActivityData:GetFirstActivityID())
		self:FitScrollRealPos(ActivityData:GetClasscifyID(), ActivityData:GetFirstActivityID())
		return
	end

	if self.DisplayKey == ActivityData:GetKey() then
		return
	end

	if ActivityData.Activity and ActivityData.Activity.MaskSwitch == 1 then
		UIUtil.SetIsVisible(self.ImgMask, true)
	else
		UIUtil.SetIsVisible(self.ImgMask, false)
	end

	if ActivityData.Activity and ActivityData.Activity.MaskBottom == 1 then
		UIUtil.SetIsVisible(self.ImgDown, true)
	else
		UIUtil.SetIsVisible(self.ImgDown, false)
	end
	--选中是只有一级菜单的父菜单（月卡，攻略）ActivityData = OpsCommTabParentItemVM， 否则选中是二级菜单  ActivityData = OpsCommTabChildItemVM
	self:SetCurOpsActivity(ActivityData)
	self.DisplayKey = ActivityData:GetKey()
	OpsActivityMainVM:SetSelectedActivityID(self.DisplayKey)
	self:PlayAnimation(self.AnimChangeActivity)

	DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.OpsActivityOpen), "1", self.DisplayKey)
end

function OpsActivityMainPanelView:OnShow()
	_G.EventMgr:SendEvent(EventID.OpsActivityMainPanelShowed)
	MenuDesiredSize = UIUtil.GetWidgetSize(self.CommMenu.TreeViewMenu).Y
	OpsActivityMgr:SendQueryActivityList()
	self:UpdateActivityUI()

	if self.Params == nil or  self.Params.JumpData == nil  or  #self.Params.JumpData < 1 then
		DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.OpsActivityOpen), "2", OpsActivityMainVM:GetDefaultKey(), 1)
	else
		DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.OpsActivityOpen), "2", self.Params.JumpData[1], 2)
	end
	
	if nil ~= OperationUtil.IsEnableCustomService and OperationUtil.IsEnableCustomService() then
		UIUtil.SetIsVisible(self.CommonTitle.CommInforBtn, true, true)
		UIUtil.ImageSetBrushFromAssetPath(self.CommonTitle.CommInforBtn.Imgnfor,
			"PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_CustomerService_png.UI_Comm_Btn_CustomerService_png'")
	else
		UIUtil.SetIsVisible(self.CommonTitle.CommInforBtn, false)
	end
end

function OpsActivityMainPanelView:UpdateActivityUI()
	OpsActivityMainVM:UpdateOpsActivityInfo()
	self.CommMenu.TreeViewMenu:CollapseAll()
	if self.DisplayKey == nil then
		if self.Params == nil or  self.Params.JumpData == nil  or  #self.Params.JumpData < 1 then
			self:SetSelectedKey(OpsActivityMainVM:GetDefaultKey())
		else
			self:SetSelectedKey(self.Params.JumpData[1])
			local Cfg = ActivityCfg:FindCfgByKey(self.Params.JumpData[1])
			if Cfg and next(Cfg) then
				self:FitScrollRealPos(Cfg.ClassifyID, Cfg.ActivityID)
			end
		end
	else
		self:SetSelectedKey(self.DisplayKey)
	end
end


function OpsActivityMainPanelView:SetSelectedKey(Key)
	if Key == nil then
		return
	end

	local Cfg = ActivityCfg:FindCfgByKey(Key)
	if Cfg then
		self.TreeViewAdapter:SetIsExpansion(Cfg.ClassifyID, true)
	end
	self.TreeViewAdapter:SetSelectedKey(Key)

end

function OpsActivityMainPanelView:OnHide()
	self:HideOpsActivity()
	self.DisplayKey = nil

	local ImageDownloader = self.ImageDownloader
	if ImageDownloader and ImageDownloader:IsValid() then
		ImageDownloader:Stop()
	end
end

function OpsActivityMainPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.CommonTitle.CommInforBtn.BtnInfor, self.OnClickBtnInfor)
end

function OpsActivityMainPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdate, self.UpdateActivityUI)
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.OpsActivityUpdateInfo)
	self:RegisterGameEvent(EventID.OpsActivityNodeGetReward, self.OpsActivityUpdateInfo)

	self:RegisterGameEvent(EventID.StartAutoPathMove, self.Hide) -- 监听自动寻路事件，关闭活动界面
	self:RegisterGameEvent(EventID.MapFollowAdd, self.Hide)

	self:RegisterGameEvent(EventID.PandoraActivityClosed, self.OnPandoraActivityClose)
end

function OpsActivityMainPanelView:OnRegisterBinder()
	self:RegisterBinders(OpsActivityMainVM, self.Binders)

	self.CommonTitle:SetTextTitleName(_G.LSTR(970003))
end

function OpsActivityMainPanelView:OnClickBtnInfor()
	--_G.FLOG_INFO("OpsActivityMainPanelView:OnClickBtnInfor")
	OperationUtil.OpenCustomService(OperationUtil.CustomServiceSceneID.OpsActivity)
end

function OpsActivityMainPanelView:SetCurOpsActivity(ActivityData)
	if self.DisplayActivtiyWidget and self:IsPandoraActivity(self.DisplayActivtiyWidget.Params) then
		if nil ~= self.DisplayActivtiyWidget.Params.AppId and nil ~= self.DisplayActivtiyWidget.Params.ActivityID then
			_G.PandoraMgr:NotifyActivityClose(self.DisplayActivtiyWidget.Params.AppId, self.DisplayActivtiyWidget.Params.ActivityID)
		end
		_G.PandoraMgr:CloseApp(self.DisplayActivtiyWidget.Params.AppId)
		self.SwithPandoraData = {CloseAppID = self.DisplayActivtiyWidget.Params.AppId, ActivityData = ActivityData}
		return
	end

	self:SwitchActivity(ActivityData)
end

function OpsActivityMainPanelView:SwitchActivity(ActivityData)
	if ActivityData == nil then
		return
	end
	local function OnLoadComplete(Widget)
		if self and _G.UE.UCommonUtil.IsObjectValid(self.ActvityPanel)  then
			self:HideOpsActivity()
			if Widget then
				self.ActvityPanel:AddChildToCanvas(Widget)
				local Anchor = _G.UE.FAnchors()
				Anchor.Minimum = _G.UE.FVector2D(0, 0)
				Anchor.Maximum = _G.UE.FVector2D(1, 1)
				UIUtil.CanvasSlotSetAnchors(Widget, Anchor)
				UIUtil.CanvasSlotSetPosition(Widget, _G.UE.FVector2D(0, 0))
				local Offset = UIUtil.CanvasSlotGetOffsets(self.PanelBG)
				UIUtil.CanvasSlotSetOffsets(Widget, Offset)
				UIUtil.CanvasSlotSetAlignment(Widget, _G.UE.FVector2D(0, 0))
				self:AddSubView(Widget)
				self.DisplayActivtiyWidget = Widget
				if nil ~= self.DisplayActivtiyWidget.Params.AppId and nil ~= self.DisplayActivtiyWidget.Params.ActivityID then
					_G.PandoraMgr:NotifyActivityShow(self.DisplayActivtiyWidget.Params.AppId, self.DisplayActivtiyWidget.Params.ActivityID)
				end
			end
		else
			WidgetPoolMgr:RecycleWidget(Widget)
		end
	end

	local GCType = nil
	if self:IsPandoraActivity(ActivityData) then
		GCType = ObjectGCType.NoCache
	end

	WidgetPoolMgr:CreateWidgetAsyncByName(ActivityData:GetBPName(), GCType, OnLoadComplete, true, true, ActivityData)
	self.BGPicPath = ActivityData:GetBGPicPath()
	if string.match(self.BGPicPath, "http") then
		UIUtil.SetIsVisible(self.ImgBG, false)
		self:SetUrlPic(self.BGPicPath)
	else
		if string.isnilorempty(self.BGPicPath) then
			UIUtil.SetIsVisible(self.ImgBG, false)
		else
			UIUtil.SetIsVisible(self.ImgBG, true)
			UIUtil.ImageSetBrushFromAssetPath(self.ImgBG, self.BGPicPath)
		end
	end
end

function OpsActivityMainPanelView:SetUrlPic(Url)
	_G.FLOG_INFO('[OpsActivity][OpsActivityMainPanelView][OnBinderPortUrl] Download image start url = %s', Url)
	if string.isnilorempty(Url) then
		return
	end

    local ImageDownloader = _G.UE.UImageDownloader.MakeDownloader("OpsActivityCDNBG", true, 100)
    ImageDownloader.OnSuccess:Add(ImageDownloader,
		function(_, texture)
			if texture then
				_G.FLOG_INFO('[OpsActivity][OpsActivityMainPanelView][OnBinderPortUrl] Download image successurl = %s', Url)
				if self and self.BGPicPath == Url and self.ImgBG then
					UIUtil.ImageSetBrushResourceObject(self.ImgBG, texture)
					UIUtil.SetIsVisible(self.ImgBG, true)
				end
				
			end
		end
    )

    ImageDownloader.OnFail:Add(ImageDownloader,
		function()
			_G.FLOG_INFO('[OpsActivity][OpsActivityMainPanelView][OnBinderPortUrl] Download image failedurl = %s', Url)
		end
	)
		
    ImageDownloader:Start(Url, "", true)
	self.ImageDownloader = ImageDownloader
end

function OpsActivityMainPanelView:ClearFixPosTimer()
	if self.FixScrollPosTimer then
		self:UnRegisterTimer(self.FixScrollPosTimer)
		self.FixScrollPosTimer = nil
	end

	if self.GetIndexTimer then
		self:UnRegisterTimer(self.GetIndexTimer)
		self.GetIndexTimer = nil
	end
end

function OpsActivityMainPanelView:FitScrollRealPos(ClasscifyID, ActivityID)
	self:ClearFixPosTimer()
	if not ClasscifyID then return end

	self.GetIndexTimer = self:RegisterTimer(function()
		local ParentRealIndex =  OpsActivityMainVM:GetItemParentRealIndex(ClasscifyID)
		local ChildRealIndex =  OpsActivityMainVM:GetItemChildRealIndexInParent(ClasscifyID, ActivityID)
		local RealSize = ParentRealIndex * ParentDesiredSize + ChildDesiredSize * ChildRealIndex
		local ScrollOffset
		if RealSize and MenuDesiredSize ~= 0 and RealSize > MenuDesiredSize then
			if RealSize - ParentRealIndex * ParentDesiredSize > MenuDesiredSize then
				ScrollOffset = (RealSize - MenuDesiredSize - ParentRealIndex * ParentDesiredSize) / ChildDesiredSize + ParentRealIndex
			else
				ScrollOffset = (RealSize - MenuDesiredSize) / ParentDesiredSize
			end
		end

		if ScrollOffset then
			local CurOffset = 0
			self.FixScrollPosTimer = self:RegisterTimer(function()
				CurOffset = (CurOffset + 1) < ScrollOffset and CurOffset + 1 or ScrollOffset
				self.TreeViewAdapter:SetScrollOffset(CurOffset)
			end, 0.1, 0.01, math.ceil(ScrollOffset))
		end
	end, 1, 0, 1)
end

function OpsActivityMainPanelView:HideOpsActivity()
	if self.DisplayActivtiyWidget == nil then
		return
	end
	
	DataReportUtil.ReportButtonClickData(tostring(ReportButtonType.OpsActivityOpen), "3", self.DisplayActivtiyWidget.Params.ActivityID)

	self.DisplayActivtiyWidget:HideView()
	self:RemoveSubView(self.DisplayActivtiyWidget)
	self.ActvityPanel:ClearChildren()
	WidgetPoolMgr:RecycleWidget(self.DisplayActivtiyWidget)
	self.DisplayActivtiyWidget = nil
end

function OpsActivityMainPanelView:OnPandoraActivityClose(Param)
	if self.SwithPandoraData == nil then
		return
	end
	if self.SwithPandoraData.CloseAppID == Param.AppId then
		self:SwitchActivity(self.SwithPandoraData.ActivityData)
		self.SwithPandoraData = nil
	end
end

function OpsActivityMainPanelView:OpsActivityUpdateInfo()
	self:UpdateActivityUI()
end

function OpsActivityMainPanelView:IsPandoraActivity(ActivityData)
	local ActivityBPName = ActivityData:GetBPName()
	--_G.FLOG_INFO("OpsActivityMainPanelView:SetCurOpsActivity, ActivityBPName = %s", ActivityBPName)
	if ActivityBPName == UIViewConfig[_G.UIViewID.PandoraMainPanelView].BPName or
		ActivityBPName == UIViewConfig[_G.UIViewID.PandoraActivityPanelView].BPName then
		return true
	end

	return false
end


return OpsActivityMainPanelView