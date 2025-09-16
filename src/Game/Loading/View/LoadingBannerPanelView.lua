---
--- Author: loiafeng
--- DateTime: 2024-05-09 10:33
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local LoadingMgr = require("Game/Loading/LoadingMgr")
local LoadingVM = require("Game/Loading/LoadingVM")
local ProtoRes = require("Protocol/ProtoRes")
local CommonUtil = require("Utils/CommonUtil")
local WidgetPoolMgr = require("UI/WidgetPoolMgr")
local LoadingDefine = require("Game/Loading/LoadingDefine")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

---@class LoadingBannerPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CopyPanel LoadingCopyItemView
---@field GoldSaucerPanel LoadingGoldEventItemView
---@field HorizontalBoxCombat UFHorizontalBox
---@field HorizontalBoxCrafter UFHorizontalBox
---@field ObjectPanel LoadingObjectItemView
---@field ProBar LoadingProBarItemView
---@field TableViewCombat UTableView
---@field TableViewOccupation UTableView
---@field TaskPanel LoadingTaskItemView
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoadingBannerPanelView = LuaClass(UIView, true)

function LoadingBannerPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CopyPanel = nil
	--self.GoldSaucerPanel = nil
	--self.HorizontalBoxCombat = nil
	--self.HorizontalBoxCrafter = nil
	--self.ObjectPanel = nil
	--self.ProBar = nil
	--self.TableViewCombat = nil
	--self.TableViewOccupation = nil
	--self.TaskPanel = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoadingBannerPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CopyPanel)
	self:AddSubView(self.GoldSaucerPanel)
	self:AddSubView(self.ObjectPanel)
	self:AddSubView(self.ProBar)
	self:AddSubView(self.TaskPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoadingBannerPanelView:OnInit()
	self.Binders = {
		{ "UIType", UIBinderValueChangedCallback.New(self, nil, self.UITypeChangedCallback) },
		{ "DisplayName", UIBinderSetText.New(self, self.TextTitle) },
		{ "RegionName", UIBinderSetText.New(self, self.TextSubTitle) },
		{ "CombatProfList", UIBinderValueChangedCallback.New(self, nil, self.UpdateCombatProfList) },
		{ "CrafterProfList", UIBinderValueChangedCallback.New(self, nil, self.UpdateCrafterProfList) },
	}

	-- TODO(loiafeng): 非Editor模式下，loading的slate会在非主线程执行，这里暂时先禁用掉
	-- if CommonUtil.IsWithEditor() then
	-- 	self.AdaptorTableViewCombat = UIAdapterTableView.CreateAdapter(self, self.TableViewCombat)
	-- 	self.AdaptorTableViewCrafter = UIAdapterTableView.CreateAdapter(self, self.TableViewOccupation)
	-- 	table.insert(self.Binders, { "CombatProfList", UIBinderUpdateBindableList.New(self, self.AdaptorTableViewCombat) })
	-- 	table.insert(self.Binders, { "CrafterProfList", UIBinderUpdateBindableList.New(self, self.AdaptorTableViewCrafter) })
    -- end

	self.PanelList = {
		self.CopyPanel,
		self.GoldSaucerPanel,
		self.ObjectPanel,
		self.TaskPanel,
	}

	self.SubPanelMapping = {
		[ProtoRes.LoadingUIType.LOADING_UI_NONE] = nil,  -- Error case
        [ProtoRes.LoadingUIType.LOADING_UI_MAIN_CITY] = nil,  -- Error case
        [ProtoRes.LoadingUIType.LOADING_UI_SINGLE_DUNGEON] = self.TaskPanel,
        [ProtoRes.LoadingUIType.LOADING_UI_TEAM_DUNGEON] = self.CopyPanel,
        [ProtoRes.LoadingUIType.LOADING_UI_CREATURE] = self.ObjectPanel,
        [ProtoRes.LoadingUIType.LOADING_UI_LANDSCAPE] = self.GoldSaucerPanel,
	}

	self.CombatProfWidgets = {}
	self.CrafterProfWidgets = {}
end

function LoadingBannerPanelView:OnDestroy()

end

function LoadingBannerPanelView:OnShow()

end

local function RecycleWidgets(Widgets)
	for _, Widget in ipairs(Widgets) do
		local function Callback()
			Widget:UnloadView()
			WidgetPoolMgr:RecycleWidget(Widget)
		end
		Widget:ExecuteHideView(Callback, true, nil)
	end
end

function LoadingBannerPanelView:OnHide()
	self.HorizontalBoxCombat:ClearChildren()
	RecycleWidgets(self.CombatProfWidgets)
	self.CombatProfWidgets = {}

	self.HorizontalBoxCrafter:ClearChildren()
	RecycleWidgets(self.CrafterProfWidgets)
	self.CrafterProfWidgets = {}

	if LoadingMgr:IsLoadingView() then
		-- LoadingUI有可能被UIViewMgr通过其他途径关闭，故这里需要主动通知LoadingMgr
		LoadingMgr:HideLoadingView()
	end
end

function LoadingBannerPanelView:OnRegisterUIEvent()

end

function LoadingBannerPanelView:OnRegisterGameEvent()

end

function LoadingBannerPanelView:OnRegisterBinder()
	self:RegisterBinders(LoadingVM, self.Binders)
end

function LoadingBannerPanelView:UITypeChangedCallback(NewValue)
	local NextPanel = self.SubPanelMapping[NewValue]
	if NextPanel == nil then
		_G.FLOG_ERROR("LoadingBannerPanelView.UITypeChangedCallback(): Error UIType (%d)", NewValue)
		NextPanel = self.ObjectPanel
	end

	for _, Panel in ipairs(self.PanelList) do
		if Panel == NextPanel then
			UIUtil.SetIsVisible(Panel, true)
		else
			UIUtil.SetIsVisible(Panel, false)
		end
	end
end

function LoadingBannerPanelView:UpdateCombatProfList(NewValue)
	for _, Data in ipairs(NewValue.Items) do
		local Widget = WidgetPoolMgr:CreateWidgetSyncByName(LoadingDefine.ProfItemBPName,
			nil, true, true, {Data = Data})
		if Widget then
			table.insert(self.CombatProfWidgets, Widget)
			self.HorizontalBoxCombat:AddChildToHorizontalBox(Widget)
		end
	end
end

function LoadingBannerPanelView:UpdateCrafterProfList(NewValue)
	for _, Data in ipairs(NewValue.Items) do
		local Widget = WidgetPoolMgr:CreateWidgetSyncByName(LoadingDefine.ProfItemBPName, 
			nil, true, true, {Data = Data})
		if Widget then
			table.insert(self.CrafterProfWidgets, Widget)
			self.HorizontalBoxCrafter:AddChildToHorizontalBox(Widget)
		end
	end
end

return LoadingBannerPanelView