---
--- Author: loiafeng
--- DateTime: 2025-01-17 15:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local MainFunctionPanelVM = require("Game/Main/FunctionPanel/MainFunctionPanelVM")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local MainFunctionDefine = require("Game/Main/FunctionPanel/MainFunctionDefine")
local ButtonType = MainFunctionDefine.ButtonType
local DepartDefine = require("Game/Departure/DepartOfLightDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local AudioUtil = require("Utils/AudioUtil")

---@class MainFunctionListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnFold UToggleButton
---@field ImgDown UFImage
---@field ImgUp UFImage
---@field TableView1 UTableView
---@field TableView2 UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainFunctionListView = LuaClass(UIView, true)

function MainFunctionListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnFold = nil
	--self.ImgDown = nil
	--self.ImgUp = nil
	--self.TableView1 = nil
	--self.TableView2 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainFunctionListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainFunctionListView:OnInit()
	self.AdapterButtonList = UIAdapterTableView.CreateAdapter(self, self.TableView)  ---@type UIAdapterTableView
	self.TimerSeasonActivityAnim = nil
	self.TimerDepartOfLightAnim = nil
	self.Binders = {
		{ "ButtonList", UIBinderUpdateBindableList.New(self, self.AdapterButtonList) },
	}
end

function MainFunctionListView:OnDestroy()

end

function MainFunctionListView:OnShow()
	UIUtil.SetIsVisible(self.BtnFold, false)
	self:TryPlayOpenSeasonActivityAnim()
	self:TryShowNewContentActivity()
end

function MainFunctionListView:OnHide()
end

function MainFunctionListView:OnRegisterUIEvent()
end

function MainFunctionListView:OnRegisterGameEvent()
    self:RegisterGameEvent(_G.EventID.SeasonActivityUpdatRedDot, self.TryPlayOpenSeasonActivityAnim)
	self:RegisterGameEvent(_G.EventID.DepartEntranceOpened, self.TryPlayDepartOfLightAnim)
	self:RegisterGameEvent(_G.EventID.ModuleOpenNotify, self.OnModuleOpenNotify)
end

function MainFunctionListView:OnRegisterBinder()
	self:RegisterBinders(MainFunctionPanelVM, self.Binders)
end

---@param Type number @see MainFunctionButtonType.ButtonType
---@return MainFunctionItemView|nil
---@return number|nil @Index
function MainFunctionListView:GetItemViewInternal(Type)
    if nil == Type or ButtonType.NONE == Type then
        FLOG_ERROR("MainFunctionListView.GetItemViewInternal: Invalid Type " .. tostring(Type))
        return nil, nil
    end

	local WidgetArray = self.TableView:GetDisplayedEntryWidgets()
	for i = 1, WidgetArray:Length() do
		local View = WidgetArray[i]
		if View.FunctionType == Type then
			return View, (View.RowIndex - 1) * 4 + (5 - View.ColumnIndex)
		end
	end

	return nil, nil
end

---@param Type number @see MainFunctionButtonType.ButtonType
---@return number|nil @X 
---@return number|nil @Y
function MainFunctionListView:GetItemPosition(Type)
	local View, Index = self:GetItemViewInternal(Type)
	if nil == View then
		return nil, nil
	end

	-- loiafeng: 这里使用CanvasSlotGetPosition计算的位置不太对，暂时先手动算一下
	-- local ViewPos = UIUtil.CanvasSlotGetPosition(View)

	-- 这里按照Anchors在右上角，Alignment为(1, 0)的情况处理
	local PanelPos = UIUtil.CanvasSlotGetPosition(self.TableView)
	local MaxNumPerLine = self.TableView.MaxNumPerLine
	local ScreenSize = UIUtil.GetScreenSize()
	local PosX = ScreenSize.X + PanelPos.X + (Index % MaxNumPerLine - MaxNumPerLine - 0.5) * self.TableView.EntryWidth
	local PosY = PanelPos.Y + (math.floor(Index / MaxNumPerLine) + 0.5) * self.TableView.EntryHeight

	return PosX, PosY
end

function MainFunctionListView:OnModuleOpenNotify(ModuleID)
	local Type = nil

	if ModuleID == ProtoCommon.ModuleID.ModuleIDMall then
        Type = ButtonType.STORE
    elseif ModuleID == ProtoCommon.ModuleID.ModuleIDActivitySystem then
        Type = ButtonType.ACTIVITY
    elseif ModuleID == ProtoCommon.ModuleID.ModuleIDAdventure then
		Type = ButtonType.ADVENTURE
    elseif ModuleID == ProtoCommon.ModuleID.ModuleIDBattlePass then
        Type = ButtonType.BATTLE_PASS
	elseif _G.ModuleOpenMgr:CheckIsInSwitchByModuleID(ModuleID) then
		Type = ButtonType.MENU
	end

	if nil ~= Type then
		local View = self:GetItemViewInternal(Type)
		if nil ~= View then
			View:PlayUnlockAnim()
		end
	end
end

function MainFunctionListView:TryPlayOpenSeasonActivityAnim()
	if _G.OpsSeasonActivityMgr:HasOpenSeasonAni() and nil == self.TimerSeasonActivityAnim then
		local Callback = function()
			self.TimerSeasonActivityAnim = nil
			_G.OpsSeasonActivityMgr:PlayOpenSeasonAni(function ()
				local View = self:GetItemViewInternal(ButtonType.SEASON_ACTIVITY)
				if nil ~= View then
					View:PlayUnlockAnim()
				end
			end)
		end
		-- 按钮可能还没创建，延迟播放
		self.TimerSeasonActivityAnim = self:RegisterTimer(Callback, 0.2)
	end
end

function MainFunctionListView:TryPlayDepartOfLightAnim()
	local Callback = function()
		self.TimerDepartOfLightAnim = nil
		local View = self:GetItemViewInternal(ButtonType.DEPART_OF_LIGHT)
		if nil ~= View then
			View:PlayUnlockAnim()
			AudioUtil.LoadAndPlayUISound(DepartDefine.UISoundPath.EntranceAnim)
		end
	end
	-- 按钮可能还没创建，延迟播放
	self.TimerDepartOfLightAnim = self:RegisterTimer(Callback, 0.2)
end

function MainFunctionListView:TryShowNewContentActivity()
	if _G.OpsSeasonActivityMgr:IsShowNewContent() then
		if _G.UIViewMgr:IsViewVisible(_G.UIViewID.OpsVersionNoticeContentPanelView) == false then
			_G.OpsSeasonActivityMgr:ShowSeasonActivityUI()
		end
	end
end


return MainFunctionListView