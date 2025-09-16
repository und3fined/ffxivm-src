---
--- Author: zhangyuhao
--- DateTime: 2025-03-07 20:40
--- Description: 职业任务View
---

local BaseView = require("Game/Adventure/View/AdventureChildPageBaseView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AdventureProfCareerVM = require("Game/Adventure/AdventureProfCareerVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local AdventureCareerMgr = require("Game/Adventure/AdventureCareerMgr")
local MajorUtil = require("Utils/MajorUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")

---@class AdventureProfCareerTaskView : AdventureChildPageBaseView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AdventureJobListTitleItem AdventureJobListTitleItemView
---@field DropDownList CommDropDownListView
---@field PanelJob UFCanvasPanel
---@field TableViewJob UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureProfCareerTaskView = LuaClass(BaseView, true)

function AdventureProfCareerTaskView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AdventureJobListTitleItem = nil
	--self.DropDownList = nil
	--self.PanelJob = nil
	--self.TableViewJob = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureProfCareerTaskView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AdventureJobListTitleItem)
	self:AddSubView(self.DropDownList)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureProfCareerTaskView:OnInit()
	self.CurClassType = nil
	self.CurPageProf = nil
	self.VM = AdventureProfCareerVM.New()
	self.AdapterProfCareerList = UIAdapterTableView.CreateAdapter(self, self.TableViewJob)
	self.CreateUILock = false
end

function AdventureProfCareerTaskView:OnShow()
	if not self.Params or not next(self.Params) then return end

	local TabData = self.Params.CurTabData or {}
	local SubIndex
	if self.Params.MainKey and self.Params.SubKey then
		SubIndex = self.Params.SubKey - 10 * self.Params.MainKey
	end

	if SubIndex then
		local ChildData = TabData.Children and TabData.Children[SubIndex] or {}
		self.CurClassType = ChildData.ClassType
		
		local DropDownData, FistSelectDropIndex = AdventureCareerMgr:GetCurClassDropDownData(ChildData.ClassType, self.Params.JumpID)
		self.Params.JumpID = nil
		self.DropDownList:SetForceTrigger(true)
		self.DropDownList:UpdateItems(DropDownData, FistSelectDropIndex)
		self.DropDownList.RedDot:SetRedDotNameByString(ChildData.RedDotName)
		local LinearColor = _G.UE.FLinearColor.FromHex("9c9788")
		self.DropDownList.ImgIcon:SetColorAndOpacity(LinearColor)
	end
end

function AdventureProfCareerTaskView:OnRegisterUIEvent()
	UIUtil.AddOnSelectionChangedEvent(self, self.DropDownList, self.OnDropDownListSelectionChanged)
end

function AdventureProfCareerTaskView:OnDropDownListSelectionChanged(Index, ItemData, ItemView, IsByClick)
	UIUtil.SetIsVisible(self.PanelJob, false)
	UIUtil.SetIsVisible(self.PanelPreview, false)
	self.AdapterProfCareerList:ReleaseAllItem(true)
	local CurClassData = AdventureCareerMgr:GetCurClassTypeData(self.CurClassType)
	local CurSelectProfData = CurClassData[Index]
	if CurSelectProfData.IsUnLock then
		UIUtil.SetIsVisible(self.PanelJob, true)
		self.AdventureJobListTitleItem:UpdateProfData(CurSelectProfData)
		AdventureCareerMgr:UpdateQuestStatusByProf(CurSelectProfData.Prof)
		local ProfCfg = RoleInitCfg:FindProfForPAdvance(CurSelectProfData.Prof)
		if ProfCfg and ProfCfg.Prof then
			AdventureCareerMgr:UpdateQuestStatusByProf(ProfCfg.Prof)
		end

		local ItemListData = self.VM:GetShowTaskData(CurSelectProfData)
		self:CreatItemList(ItemListData)
	else
		UIUtil.SetIsVisible(self.PanelPreview, true)
		self:ShowLockProfDetail(CurSelectProfData.Prof)
	end
	
	if self.Params and self.Params.MainView then
		self.Params.MainView:IsShowBgTwoType(not CurSelectProfData.IsUnLock)
	end

	self.VM:ClearNewRed(self.CurPageProf)
	self.CurPageProf = CurSelectProfData.Prof
end

---- 职业未解锁时展示模型图片
function AdventureProfCareerTaskView:ShowLockProfDetail(Prof)
	if not self.AdventureJobView and not self.CreateUILock then
		self.CreateUILock = true
		local Data = {Prof = Prof or 0, NeedRenderActor = true}
		local PageView = _G.UIViewMgr:CreateViewByName("Adventure/AdventureJobPanel_UIBP.AdventureJobPanel_UIBP", nil, self, true, true, Data)
		if PageView then
			self.AdventureJobView = PageView
			self.CreateUILock = false
		end
		self.PanelPreview:AddChildToCanvas(PageView)
		local Anchor = _G.UE.FAnchors()
		Anchor.Minimum = _G.UE.FVector2D(0, 0)
		Anchor.Maximum = _G.UE.FVector2D(1, 1)
		UIUtil.CanvasSlotSetAnchors(PageView, Anchor)
		UIUtil.CanvasSlotSetPosition(PageView, _G.UE.FVector2D(0, 0))
	else
		self.AdventureJobView:OnSelectJobChange(Prof)
	end
end

function AdventureProfCareerTaskView:OnRegisterBinder()
	local CareerTaskBinders = {
		{"ItemList", UIBinderUpdateBindableList.New(self, self.AdapterProfCareerList)},
	}

	self:RegisterBinders(self.VM, CareerTaskBinders)
end

function AdventureProfCareerTaskView:OnHide()
	self.Super.OnHide(self)
	self.VM:ClearNewRed(self.CurPageProf)
	self.CurPageProf = nil
	self.CurClassType = nil
	if self.AdventureJobView then
		self.PanelPreview:RemoveChild(self.PanelPreview)
		UIViewMgr:RecycleView(self.AdventureJobView)
		self.AdventureJobView = nil
	end
	self.CreateUILock = false
end

return AdventureProfCareerTaskView