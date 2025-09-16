---
--- Author: Administrator
--- DateTime: 2024-01-18 20:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local EventID = require("Define/EventID")
local FishAreaPanelItemVM = require("Game/Fish/ItemVM/FishAreaPanelItemVM")
local FishVM = require("Game/Fish/FishVM")

local FVector2D = _G.UE.FVector2D
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID


local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local PanelAutoReleaseTime = 10

---@class FishNewPanelItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field IconArrowON UFImage
---@field IconArrowUnder UFImage
---@field PanelIcon UFCanvasPanel
---@field TableViewItem UTableView
---@field TextFishGroundName UFTextBlock
---@field AnimFold UWidgetAnimation
---@field AnimHide UWidgetAnimation
---@field AnimShow UWidgetAnimation
---@field AnimUnfold UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local FishNewPanelItemView = LuaClass(UIView, true)

function FishNewPanelItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.IconArrowON = nil
	--self.IconArrowUnder = nil
	--self.PanelIcon = nil
	--self.TableViewItem = nil
	--self.TextFishGroundName = nil
	--self.AnimFold = nil
	--self.AnimHide = nil
	--self.AnimShow = nil
	--self.AnimUnfold = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function FishNewPanelItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function FishNewPanelItemView:OnInit()
	self.FishReleaseTip = nil
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewItem, self.OnTableViewSelectChanged, false, true)
	self.TableViewAdapter:SetOnClickedCallback(self.OnTableViewItemClicked)
	self.FishAreaPanelItemVM = FishAreaPanelItemVM.New()
	self.FishAreaID = nil
	self.CurAinm = nil
	self.Binder =  {
		{ "FishAreaName", UIBinderSetText.New(self, self.TextFishGroundName) },
		{ "FishItemList", UIBinderUpdateBindableList.New(self, self.TableViewAdapter) },
		{ "bShowPanel",UIBinderSetIsVisible.New(self, self.IconArrowON, false, true)},
		{ "bHidePanel",UIBinderSetIsVisible.New(self, self.IconArrowUnder, false, true)},
		{ "bShowPanel",UIBinderSetIsVisible.New(self, self.TableViewItem, false, true)},
	}
end

function FishNewPanelItemView:OnDestroy()

end

function FishNewPanelItemView:OnShow()
	local Params = self.Params
	if Params then
		local AreaID = Params.AreaID or 0
		self.FishAreaPanelItemVM:SetFishAreaID(AreaID)
		self.FishAreaID = AreaID
	end
end

function FishNewPanelItemView:OnHide()

end

function FishNewPanelItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.Btn, self.OnBtnShowClicked)
end

function FishNewPanelItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.FishNoteRefreshGuideList, self.OnRefreshFishData)
	self:RegisterGameEvent(EventID.FishNoteRefreshFishData, self.OnRefreshFishData)
	self:RegisterGameEvent(EventID.FishNoteRefreshLocationList, self.OnRefreshFishArea)
end

function FishNewPanelItemView:OnRegisterBinder()
	self:RegisterBinders(self.FishAreaPanelItemVM,self.Binder)
end

function FishNewPanelItemView:OnTableViewSelectChanged(_, ItemData,ItemView)
	local SelectedIndex = self.TableViewAdapter:GetSelectedIndex() or -1
	if SelectedIndex >= 0 then
		self.FishAreaPanelItemVM:SetFishSelected(SelectedIndex)
	end
end

function FishNewPanelItemView:OnTableViewItemClicked(Index,ItemData,ItemView)
	local Offset = FVector2D(-84, 74)
	local SelectedWidget = self.TableViewAdapter:GetChildWidget(Index)
	local PosData = {Offset = Offset,SelectedWidget = SelectedWidget}
	-- 这里暂时不需要传PosData
	if self.FishReleaseTip and UIViewMgr:IsViewVisible(UIViewID.FishReleaseTipsPanel) then
		self.FishReleaseTip:UpdateItem(ItemData,PosData,ItemView)
	else
		self.FishReleaseTip = UIViewMgr:ShowView(UIViewID.FishReleaseTipsPanel,{Item = ItemData,PosData = PosData,ItemView = ItemView})
	end
end

function FishNewPanelItemView:OnFishLift(FishID,FishNum)
	if self.FishAreaPanelItemVM.bHidePanel then
		self.FishAreaPanelItemVM:OnShowPanel(true)
		self:PlayAnimation(self.AnimUnfold)
	end
	self.FishAreaPanelItemVM:OnFishLift(FishID,FishNum)
end

function FishNewPanelItemView:SetTableViewIntemUnClicked()
	self.FishAreaPanelItemVM:SetFishUnSelected()
end

function FishNewPanelItemView:OnBtnShowClicked()
	if self.FishAreaPanelItemVM.bHidePanel then
		self.FishAreaPanelItemVM:OnShowPanel(true)
		self:PlayAnimation(self.AnimUnfold)
	else
		if UIViewMgr:IsViewVisible(UIViewID.FishReleaseTipsPanel) then
			UIViewMgr:HideView(UIViewID.FishReleaseTipsPanel)
		end
		self.FishAreaPanelItemVM:OnShowPanel(false)
		self:PlayAnimation(self.AnimFold)
	end
end

function FishNewPanelItemView:StorageReleaseFishData(FishID)
	self.FishAreaPanelItemVM:StorageReleaseFishData(FishID)
end

function FishNewPanelItemView:SetFishAreaID(AreaID)
	self.FishAreaPanelItemVM:SetFishAreaID(AreaID)
	self.FishAreaID = AreaID
end

function FishNewPanelItemView:PlayShowAnimation(bShow)
	-- 清理正在播放的动画，防止出现bug
	if self.CurAinm and self:IsAnimationPlaying(self.CurAinm) then
		self:StopAnimation(self.CurAinm)
	end
	if bShow then
		-- 展开逻辑
		self:PlayAnimation(self.AnimShow)
		FLOG_INFO("[FishNewPanelItemView]:FishMainPanel PlayAnimation Show")
		self.CurAinm = self.AnimShow
	else
		--收起逻辑
		self:PlayAnimation(self.AnimHide)
		FLOG_INFO("[FishNewPanelItemView]:FishMainPanel PlayAnimation Hide")
		self.CurAinm = self.AnimHide
	end
end

-- function FishNewPanelItemView:AutoReleasePanel()
-- 	-- 假如面板在执行收起逻辑的时候判断之前进行过操作则延后收起
-- 	-- if self.boperation then
-- 	-- 	self.PanelShowTimer = self:RegisterTimer(self.AutoReleasePanel,PanelAutoReleaseTime,1,1)
-- 	-- 	self.boperation = false
-- 	-- 	return
-- 	-- end
-- 	if UIViewMgr:IsViewVisible(UIViewID.FishReleaseTipsPanel) then
-- 		UIViewMgr:HideView(UIViewID.FishReleaseTipsPanel)
-- 	end
-- 	self.FishAreaPanelItemVM:OnShowPanel(false)
-- 	self:PlayAnimation(self.AnimFold)
-- 	-- self.PanelShowTimer = nil
-- 	-- self.boperation = false
-- end

function FishNewPanelItemView:FishIsNew(FishID)
	return self.FishAreaPanelItemVM:FishIsNew(FishID)
end

function FishNewPanelItemView:OnRefreshFishData(Params)
	self.FishAreaPanelItemVM:InitFishLockMap()
end

function FishNewPanelItemView:OnRefreshFishArea()
	if self.FishAreaID  then
		self.FishAreaPanelItemVM:UpdateFishAreaLockState(self.FishAreaID)
	end
end

function FishNewPanelItemView:OnExitFishArea()
	if UIViewMgr:IsViewVisible(UIViewID.FishReleaseTipsPanel) then
		UIViewMgr:HideView(UIViewID.FishReleaseTipsPanel)
	end
	self:ClearFishReleaseData()
end

function FishNewPanelItemView:ClearFishReleaseData()
	self:SetTableViewIntemUnClicked()
	self.FishAreaPanelItemVM:ClearStorageReleaseFishData()
end


return FishNewPanelItemView