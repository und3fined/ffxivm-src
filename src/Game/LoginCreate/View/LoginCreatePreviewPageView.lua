
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local LoginRoleShowPageVM = require("Game/LoginRole/LoginRoleShowPageVM")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")

local LoginRoleProfVM = require("Game/LoginRole/LoginRoleProfVM")
---@class LoginCreatePreviewPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field LoginRoleBackPage LoginCreateBackPageView
---@field TableViewEnvironment UTableView
---@field TableViewPreviewMenu UTableView
---@field TableViewPreviewText UTableView
---@field TableViewTime UTableView
---@field TableViewWeather UTableView
---@field TextContent UFTextBlock
---@field AnimBtnEnvChecked UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local LoginCreatePreviewPageView = LuaClass(UIView, true)

function LoginCreatePreviewPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.LoginRoleBackPage = nil
	--self.TableViewEnvironment = nil
	--self.TableViewPreviewMenu = nil
	--self.TableViewPreviewText = nil
	--self.TableViewTime = nil
	--self.TableViewWeather = nil
	--self.TextContent = nil
	--self.AnimBtnEnvChecked = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function LoginCreatePreviewPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.LoginRoleBackPage)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function LoginCreatePreviewPageView:OnInit()
	self.ViewModel = LoginRoleShowPageVM
	self.TableViewMenu = UIAdapterTableView.CreateAdapter(self, self.TableViewPreviewMenu, self.OnTableViewMenuSelectChange, true)

	self.TableViewTextMenu = UIAdapterTableView.CreateAdapter(self, self.TableViewPreviewText, self.OnTableViewTextSelectChange, true)
	self.TableViewMap = UIAdapterTableView.CreateAdapter(self, self.TableViewEnvironment, self.OnTableViewMapSelectChange, true)
	self.TableViewWrapWeather = UIAdapterTableView.CreateAdapter(self, self.TableViewWeather, self.OnTableViewWeatherSelectChange, true)

	self.IsHideTextContent = false
end

function LoginCreatePreviewPageView:OnDestroy()

end

function LoginCreatePreviewPageView:OnShow()
	local ShowType = self.Params or self.ViewModel.CurLoginShowType
	if ShowType then
		--ShowType也是一级菜单的Index，从1开始的
		self.ViewModel:InitAllMenu()

		if _G.LoginShowType.Action == ShowType then		--动作
			self.ViewModel.CurrentActionIndex = -1
			-- self.TableViewTextMenu:SetSelectedIndex(self.ViewModel.CurrentActionIndex)
		end

		self.TableViewMenu:SetSelectedIndex(ShowType)

		-- self:SwitchTo(ShowType) 不需要，上面SetSelectedIndex会执行的
	end

	-- 预览界面也有束发按钮
	-- _G.LoginAvatarMgr:TieUpHair(false) -- 关闭束发，束发功能只在有束发按钮界面生效
end

function LoginCreatePreviewPageView:HideTextContent()
	self.IsHideTextContent = true
end

function LoginCreatePreviewPageView:SwitchTo(ShowType, IsByClick)
	--试穿、动作、时间可以共用一个二级菜单 TableViewPreviewText
	self.ViewModel:OnRolePageViewShow(ShowType)

	if IsByClick then
		_G.LoginUIMgr:SetFeedbackAnimType(0)
	end

	UIUtil.SetIsVisible(self.TextContent, false)

	if _G.LoginShowType.Suit == ShowType then			--试穿
		self:OnTextTableViewShow(true)

		if not self.IsHideTextContent then
			UIUtil.SetIsVisible(self.TextContent, true)
		end

		--已经确定好套装list和CurrentSuitIndex（已经是默认的种族或者职业套）
		FLOG_INFO("Login Preview Suit, select %d", self.ViewModel.CurrentSuitIndex)
		self.TableViewTextMenu:SetSelectedIndex(self.ViewModel.CurrentSuitIndex)
	elseif _G.LoginShowType.Action == ShowType then		--动作
		self:OnTextTableViewShow(true)

		FLOG_INFO("Login Preview action, select %d", self.ViewModel.CurrentActionIndex)
		--默认选中第一个
		self.TableViewTextMenu:SetSelectedIndex(self.ViewModel.CurrentActionIndex)

	elseif _G.LoginShowType.Map == ShowType then		--环境
		self:OnTextTableViewShow(false)
		UIUtil.SetIsVisible(self.TableViewEnvironment, true, true)
		self.TableViewMap:SetSelectedIndex(self.ViewModel.CurMapIndex)
		FLOG_INFO("Login Preview Map, select %d", self.ViewModel.CurMapIndex)
	elseif _G.LoginShowType.Time == ShowType then		--时间
		self:OnTextTableViewShow(true)
		self.TableViewTextMenu:SetSelectedIndex(self.ViewModel.CurTimeIndex)
		FLOG_INFO("Login Preview Time, select %d", self.ViewModel.CurTimeIndex)

		if not self.IsHideTextContent and #self.ViewModel.TextSecondMenuList == 0 then
			self.TextContent:SetText(_G.LSTR(980028))
			UIUtil.SetIsVisible(self.TextContent, true)
		else
			UIUtil.SetIsVisible(self.TextContent, false)
		end
	elseif _G.LoginShowType.Weather == ShowType then		--天气
		self:OnTextTableViewShow(false)
		UIUtil.SetIsVisible(self.TableViewWeather, true, true)
		FLOG_INFO("Login Preview Weather, select %d", self.ViewModel.CurWeatherIndex)
		self.TableViewWrapWeather:SetSelectedIndex(self.ViewModel.CurWeatherIndex)

		if not self.IsHideTextContent and #self.ViewModel.WeatherList == 0 then
			self.TextContent:SetText(_G.LSTR(980027))
			UIUtil.SetIsVisible(self.TextContent, true)
		else
			UIUtil.SetIsVisible(self.TextContent, false)
		end
	end
end

function LoginCreatePreviewPageView:OnTextTableViewShow(IsShow)
	if IsShow then
		UIUtil.SetIsVisible(self.TableViewPreviewText, true, false)
		UIUtil.SetIsVisible(self.TableViewWeather, false)
		UIUtil.SetIsVisible(self.TableViewEnvironment, false)
		UIUtil.SetIsVisible(self.TableViewTime, false)
	else
		UIUtil.SetIsVisible(self.TableViewPreviewText, false)
		UIUtil.SetIsVisible(self.TableViewWeather, false)
		UIUtil.SetIsVisible(self.TableViewEnvironment, false)
		UIUtil.SetIsVisible(self.TableViewTime, false)
	end
end

function LoginCreatePreviewPageView:OnHide()
	-- _G.LoginUIMgr:SetFeedbackAnimType(0)
end

function LoginCreatePreviewPageView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.LoginRoleBackPage.BtnBack, self.OnBtnBackClick)
end

function LoginCreatePreviewPageView:OnRegisterGameEvent()

end

function LoginCreatePreviewPageView:OnRegisterBinder()

	local Binders = {
		{ "TitleName", UIBinderSetText.New(self, self.LoginRoleBackPage.TextTitle) },
		{ "SubTitleName", UIBinderSetText.New(self, self.LoginRoleBackPage.TextSubtile) },
		{ "MainMenuList", UIBinderUpdateBindableList.New(self, self.TableViewMenu) },
		{ "TextSecondMenuList", UIBinderUpdateBindableList.New(self, self.TableViewTextMenu) },
		{ "MapList", UIBinderUpdateBindableList.New(self, self.TableViewMap) },
		{ "WeatherList", UIBinderUpdateBindableList.New(self, self.TableViewWrapWeather) },
		-- { "AnimList", UIBinderUpdateBindableList.New(self, self.TableViewShowAction) },
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function LoginCreatePreviewPageView:OnBtnBackClick()
	self:Hide()

	-- local Rlt = _G.LoginMapMgr:BackToOrignMap()
	-- local bSameMap = false
	-- if Rlt and Rlt == -1 then
	-- 	bSameMap = true
	-- end

	_G.LoginUIMgr:ReturnCurPhaseView(false)--, bSameMap)
end

function LoginCreatePreviewPageView:OnTableViewMenuSelectChange(Index, ItemData, ItemView, IsByClick)
	FLOG_INFO("Login Preview LoginShowType:%d", Index)
	self:SwitchTo(Index, IsByClick)
end

function LoginCreatePreviewPageView:OnTableViewMapSelectChange(Index, ItemData, ItemView)
	FLOG_INFO("Login Preview Map Select:%d", Index)
	local MapList = self.ViewModel.MapList
	if #MapList >= Index then
		local LoginMapCfgID = MapList[Index].ID
		if _G.LoginMapMgr:IsRealLoginMap() then
			_G.LoginMapMgr:ChangeLoginMap(LoginMapCfgID)
		else
			_G.LoginMapMgr:RequestChangeLoginMap(LoginMapCfgID)
		end
	end
end

function LoginCreatePreviewPageView:OnTableViewWeatherSelectChange(Index, ItemData, ItemView)
	local WeatherList = self.ViewModel.WeatherList
	if Index >= 1 and Index <= #WeatherList then
		local WeatherID = WeatherList[Index].WeatherID
		FLOG_INFO("Login Preview Weather Select:%d WeatherID:%d", Index, WeatherID)
		_G.LoginMapMgr:SetWeather(WeatherID)
	end
end

function LoginCreatePreviewPageView:OnTableViewTextSelectChange(Index, ItemData, ItemView, IsByClick)
	local CurShowType = self.ViewModel.CurLoginShowType
	if CurShowType == _G.LoginShowType.Suit then
		local SuitList = self.ViewModel.RaceAndProfSuitList
		if Index >= 1 and #SuitList >= Index then
			local SuitCfg = SuitList[Index]
			FLOG_INFO("Login SelectSuitName : %s index:%d SuitID:%d", SuitCfg.SuitName, Index, SuitCfg.ID)

			self.TextContent:SetText(SuitCfg.SuitDesc or "")

			self.ViewModel.CurrentSuitIndex = Index
			_G.LoginUIMgr:WearSuit(SuitCfg)

			if SuitCfg.SuitIcon and IsByClick then
				_G.LoginUIMgr:SetFeedbackAnimType(1)
			end

			if _G.LoginUIMgr:GetCurRolePhase() == LoginRolePhase.Prof then
				LoginRoleProfVM.bBackFromPreview = true
			end

			--试穿的是职业装
			if SuitCfg.Prof and SuitCfg.Prof > 0 then
				_G.LoginUIMgr:RecordProfSuit(SuitCfg)
			else
				_G.LoginUIMgr:RecordProfSuit(nil)	--选了非职业装，清空记录
			end
		end
	elseif CurShowType == _G.LoginShowType.Action then
		local AnimList = self.ViewModel.AnimList
		if Index >= 1 and #AnimList >= Index then
			FLOG_INFO("Login SelectAction : %s index:%d", AnimList[Index].Name, Index)

			self.ViewModel:PlayAnim(Index)
		end
	elseif CurShowType == _G.LoginShowType.Time then
		FLOG_INFO("Login SelectTime : index:%d", Index)
		_G.LoginMapMgr:SetWeatherTime(Index)
	end
end

-- function LoginCreatePreviewPageView:OnTableViewActionSelectChange(Index, ItemData, ItemView)
-- 	local AnimList = self.ViewModel.AnimList
-- 	if Index >= 1 and #AnimList >= Index then
-- 		FLOG_INFO("Login SelectAction : %s index:%d", AnimList[Index].Name, Index)

-- 		self.ViewModel:PlayAnim(Index)
-- 	end
-- end

return LoginCreatePreviewPageView