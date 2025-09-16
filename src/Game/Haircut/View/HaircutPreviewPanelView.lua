---
--- Author: jamiyang
--- DateTime: 2024-01-23 20:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local LoginRoleShowPageVM = require("Game/LoginRole/LoginRoleShowPageVM")
local LoginRoleProfVM = require("Game/LoginRole/LoginRoleProfVM")

local LSTR = _G.LSTR
local LoginShowType = nil
local HaircutMgr = nil
local LoginUIMgr = nil
local LoginMapMgr = nil

---@class HaircutPreviewPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBack CommBackBtnView
---@field CommonTitleNew CommonTitleView
---@field PanelPreviewText UFCanvasPanel
---@field TableViewEnvironment UTableView
---@field TableViewList UTableView
---@field TableViewPreviewText UTableView
---@field TableViewTextTab UTableView
---@field TableViewWeather UTableView
---@field TextPreview UFTextBlock
---@field TextPreview1 UFTextBlock
---@field TextSubTitle UFTextBlock
---@field TextTitle UFTextBlock
---@field VerIconTabsNew CommVerIconTabsView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutPreviewPanelView = LuaClass(UIView, true)

function HaircutPreviewPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBack = nil
	--self.CommonTitleNew = nil
	--self.PanelPreviewText = nil
	--self.TableViewEnvironment = nil
	--self.TableViewList = nil
	--self.TableViewPreviewText = nil
	--self.TableViewTextTab = nil
	--self.TableViewWeather = nil
	--self.TextPreview = nil
	--self.TextPreview1 = nil
	--self.TextSubTitle = nil
	--self.TextTitle = nil
	--self.VerIconTabsNew = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutPreviewPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBack)
	self:AddSubView(self.CommonTitleNew)
	self:AddSubView(self.VerIconTabsNew)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutPreviewPanelView:OnInit()
	HaircutMgr = _G.HaircutMgr
	LoginUIMgr = _G.LoginUIMgr
	LoginShowType = _G.LoginShowType
	LoginMapMgr = _G.LoginMapMgr
	HaircutMgr.RealLeaveHaircut = false
	self.ViewModel = LoginRoleShowPageVM
	--self.TableViewMenu = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnTableViewMenuSelectChange, true)

	self.TableViewTextMenu = UIAdapterTableView.CreateAdapter(self, self.TableViewPreviewText, self.OnTableViewTextSelectChange, true)
	self.TableViewMap = UIAdapterTableView.CreateAdapter(self, self.TableViewEnvironment, self.OnTableViewMapSelectChange, true)
	self.TableViewWrapWeather = UIAdapterTableView.CreateAdapter(self, self.TableViewWeather, self.OnTableViewWeatherSelectChange, true)

	self.IsHideTextContent = false
	--self.TextTitle:SetText(LSTR(1250007)) --"预览"
	self.CommonTitleNew:SetTextTitleName(LSTR(1250007))
	self.TextPreview1:SetText(LSTR(1250008)) --"当前外观仅为预览"
end

function HaircutPreviewPanelView:OnDestroy()

end

function HaircutPreviewPanelView:OnShow()
	-- 音效
	HaircutMgr:PlayBGM(true)
	self.ViewModel:ClearSuit()
	UIUtil.SetIsVisible(self.CommonTitleNew, true)
	self.CommonTitleNew:SetSubTitleIsVisible(true)
	self.CommonTitleNew:SetCommInforBtnIsVisible(false)
	local ShowType = self.Params or self.ViewModel.CurLoginShowType
	if ShowType then
		--ShowType也是一级菜单的Index，从1开始的
		self.ViewModel:InitAllMenu()

		if LoginShowType.Action == ShowType then		--动作
			self.ViewModel.CurrentActionIndex = -1
			-- self.TableViewTextMenu:SetSelectedIndex(self.ViewModel.CurrentActionIndex)
		end
		self:InitMainMenu()
		--self.TableViewMenu:SetSelectedIndex(ShowType)
		self.VerIconTabsNew:SetSelectedIndex(ShowType)

		-- self:SwitchTo(ShowType) 不需要，上面SetSelectedIndex会执行的

		-- 默认当前
		-- self.TableViewTextMenu:SetSelectedIndex(1)
	end
end

function HaircutPreviewPanelView:InitMainMenu()
	local MenuList = self.ViewModel.MainMenuList
	local ListData = {}
	for _, Item in ipairs(MenuList) do
        local Data = {}
        Data.IconPath = Item.UnCheckIcon
        Data.SelectIcon = Item.CheckIcon
        Data.bShowlock = false
        table.insert(ListData, Data)
    end
	if ListData ~= nil and table.size(ListData) > 0 then
		self.VerIconTabsNew:UpdateItems(ListData, 1)
	end
	self.VerIconTabsNew:SetIsSwitchPanelVisible(false)
end

function HaircutPreviewPanelView:HideTextContent()
	self.IsHideTextContent = true
end

function HaircutPreviewPanelView:SwitchTo(ShowType, IsByClick)
	--试穿、动作、时间可以共用一个二级菜单 TableViewPreviewText
	self.ViewModel:OnRolePageViewShow(ShowType)

	if IsByClick then
		LoginUIMgr:SetFeedbackAnimType(0)
	end

	UIUtil.SetIsVisible(self.TextPreview, false)

	if LoginShowType.Suit == ShowType then			--试穿
		self:OnTextTableViewShow(true)

		if not self.IsHideTextContent then
			UIUtil.SetIsVisible(self.TextPreview, true)
		end

		--已经确定好套装list和CurrentSuitIndex（已经是默认的种族或者职业套）
		FLOG_INFO("Login Preview Suit, select %d", self.ViewModel.CurrentSuitIndex)
		self.TableViewTextMenu:SetSelectedIndex(self.ViewModel.CurrentSuitIndex)
	elseif LoginShowType.Action == ShowType then		--动作
		self:OnTextTableViewShow(true)

		FLOG_INFO("Login Preview action, select %d", self.ViewModel.CurrentActionIndex)
		--默认选中第一个
		self.TableViewTextMenu:SetSelectedIndex(self.ViewModel.CurrentActionIndex)

	elseif LoginShowType.Map == ShowType then		--环境
		self:OnTextTableViewShow(false)
		UIUtil.SetIsVisible(self.TableViewEnvironment, true, true)
		self.TableViewMap:SetSelectedIndex(self.ViewModel.CurMapIndex)
		FLOG_INFO("Login Preview Map, select %d", self.ViewModel.CurMapIndex)
	elseif LoginShowType.Time == ShowType then		--时间
		self:OnTextTableViewShow(true)
		self.TableViewTextMenu:SetSelectedIndex(self.ViewModel.CurTimeIndex)
		FLOG_INFO("Login Preview Time, select %d", self.ViewModel.CurTimeIndex)

		if #self.ViewModel.TextSecondMenuList == 0 then
			self.TextPreview:SetText(LSTR(1250016))--"此环境不可调整时间"
			UIUtil.SetIsVisible(self.TextPreview, true)
		else
			UIUtil.SetIsVisible(self.TextPreview, false)
		end
	elseif LoginShowType.Weather == ShowType then		--天气
		self:OnTextTableViewShow(false)
		UIUtil.SetIsVisible(self.TableViewWeather, true, true)
		FLOG_INFO("Login Preview Weather, select %d", self.ViewModel.CurWeatherIndex)
		self.TableViewWrapWeather:SetSelectedIndex(self.ViewModel.CurWeatherIndex)

		if #self.ViewModel.TextSecondMenuList == 0 then
			self.TextPreview:SetText(LSTR(1250017)) --"此环境不可调整天气"
			UIUtil.SetIsVisible(self.TextPreview, true)
		else
			UIUtil.SetIsVisible(self.TextPreview, false)
		end
	end
end

function HaircutPreviewPanelView:OnTextTableViewShow(IsShow)
	if IsShow then
		UIUtil.SetIsVisible(self.TableViewPreviewText, true, true)
		UIUtil.SetIsVisible(self.TableViewWeather, false)
		UIUtil.SetIsVisible(self.TableViewEnvironment, false)
		UIUtil.SetIsVisible(self.TableViewTextTab, false)
	else
		UIUtil.SetIsVisible(self.TableViewPreviewText, false)
		UIUtil.SetIsVisible(self.TableViewWeather, false)
		UIUtil.SetIsVisible(self.TableViewEnvironment, false)
		UIUtil.SetIsVisible(self.TableViewTextTab, false)
	end
end


function HaircutPreviewPanelView:OnHide()
	self.ViewModel:ClearSuit()
	-- 音效
	-- HaircutMgr:PlayBGM(false)
end

function HaircutPreviewPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnBack.Button, self.OnBtnBackClick)
	UIUtil.AddOnSelectionChangedEvent(self, self.VerIconTabsNew, self.OnTableViewMenuSelectChange)
end

function HaircutPreviewPanelView:OnRegisterGameEvent()

end

function HaircutPreviewPanelView:OnRegisterBinder()
	local Binders = {
		--{ "TitleName", UIBinderSetText.New(self, self.LoginRoleBackPage.TextTitle) },
		{ "SubTitleName", UIBinderSetText.New(self, self.CommonTitleNew.TextSubtitle) },
		--{ "MainMenuList", UIBinderUpdateBindableList.New(self, self.TableViewMenu) },
		{ "TextSecondMenuList", UIBinderUpdateBindableList.New(self, self.TableViewTextMenu) },
		{ "MapList", UIBinderUpdateBindableList.New(self, self.TableViewMap) },
		{ "WeatherList", UIBinderUpdateBindableList.New(self, self.TableViewWrapWeather) },
		-- { "AnimList", UIBinderUpdateBindableList.New(self, self.TableViewShowAction) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function HaircutPreviewPanelView:OnBtnBackClick()
	self:Hide()

	-- local Rlt = LoginMapMgr:BackToOrignMap()
	-- local bSameMap = false
	-- if Rlt and Rlt == -1 then
	-- 	bSameMap = true
	-- end

	LoginUIMgr:ReturnCurPhaseView(false)--, bSameMap)
end

function HaircutPreviewPanelView:OnTableViewMenuSelectChange(Index, ItemData, ItemView, IsByClick)
	FLOG_INFO("Login Preview LoginShowType:%d", Index)
	self:SwitchTo(Index, IsByClick)
end

function HaircutPreviewPanelView:OnTableViewMapSelectChange(Index, ItemData, ItemView)
	FLOG_INFO("Login Preview Map Select:%d", Index)

	local MapList = self.ViewModel.MapList
	if #MapList >= Index then
		local LoginMapCfgID = MapList[Index].ID
		if LoginMapMgr:IsRealLoginMap() then
			LoginMapMgr:ChangeLoginMap(LoginMapCfgID)
		else
			LoginMapMgr:RequestChangeLoginMap(LoginMapCfgID)
		end
	end
end

function HaircutPreviewPanelView:OnTableViewWeatherSelectChange(Index, ItemData, ItemView)
	local WeatherList = self.ViewModel.WeatherList
	if Index >= 1 and Index <= #WeatherList then
		local WeatherID = WeatherList[Index].WeatherID
		FLOG_INFO("Login Preview Weather Select:%d WeatherID:%d", Index, WeatherID)
		LoginMapMgr:SetWeather(WeatherID)
	end
end

function HaircutPreviewPanelView:OnTableViewTextSelectChange(Index, ItemData, ItemView)
	local CurShowType = self.ViewModel.CurLoginShowType
	if CurShowType == LoginShowType.Suit then
		local SuitList = self.ViewModel.RaceAndProfSuitList
		if Index >= 1 and #SuitList >= Index then
			local SuitCfg = SuitList[Index]
			FLOG_INFO("Login SelectSuitName : %s index:%d SuitID:%d", SuitCfg.SuitName, Index, SuitCfg.ID)
	
			self.TextPreview:SetText(SuitCfg.SuitDesc or "")

			self.ViewModel.CurrentSuitIndex = Index
			if SuitCfg.ID > 10000 then
				LoginUIMgr:WearSuit(SuitCfg)
				UIUtil.SetIsVisible(self.TextPreview1, true)
				HaircutMgr:SetSuitTips(true)
			else
				LoginUIMgr:SetSuitInHaircut(SuitCfg)
				UIUtil.SetIsVisible(self.TextPreview1, false)
				HaircutMgr:SetSuitTips(false)
			end

			if SuitCfg.SuitIcon then
				LoginUIMgr:SetFeedbackAnimType(1)
			end
	
			if LoginUIMgr:GetCurRolePhase() == LoginRolePhase.Prof then
				LoginRoleProfVM.bBackFromPreview = true
			end

			LoginUIMgr:RecordProfSuit(SuitCfg)
			-- --试穿的是职业装
			-- if SuitCfg.Prof and SuitCfg.Prof > 0 then
			-- 	LoginUIMgr:RecordProfSuit(SuitCfg)
			-- else
			-- 	LoginUIMgr:RecordProfSuit(nil)	--选了非职业装，清空记录
			-- end
		end
	elseif CurShowType == LoginShowType.Action then
		local AnimList = self.ViewModel.AnimList
		if Index >= 1 and #AnimList >= Index then
			FLOG_INFO("Login SelectAction : %s index:%d", AnimList[Index].Name, Index)
	
			self.ViewModel:PlayAnim(Index)
		end
	elseif CurShowType == LoginShowType.Time then
		FLOG_INFO("Login SelectTime : index:%d", Index)
		LoginMapMgr:SetWeatherTime(Index)
	end
end

return HaircutPreviewPanelView