---
--- Author: Administrator
--- DateTime: 2023-08-14 10:33
--- Description: 地图标记界面
---

local UIUtil = require("Utils/UIUtil")
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MapDefine = require("Game/Map/MapDefine")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MapUtil = require("Game/Map/MapUtil")

local WorldMapMgr = _G.WorldMapMgr
local LSTR = _G.LSTR

local MapConstant = MapDefine.MapConstant
local MAP_DEFAULT_MARKER_NAME = MapConstant.MAP_DEFAULT_MARKER_NAME


---@class WorldMapSetMarkPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field BtnDelete CommBtnSView
---@field BtnDelete002 UFButton
---@field BtnDelete01 UFButton
---@field BtnNotrack CommBtnSView
---@field BtnSave CommBtnMView
---@field BtnTrack CommBtnSView
---@field CheckBox01 CommCheckBoxView
---@field CheckBox02 CommCheckBoxView
---@field PanelMark UFCanvasPanel
---@field PanelSetUP UFCanvasPanel
---@field TableViewIconMark UTableView
---@field TableViewSetUPList UTableView
---@field TableViewTraceMark UTableView
---@field TextIconMark UFTextBlock
---@field TextMapSetUp UFTextBlock
---@field TextMark UFTextBlock
---@field TextMarked01 UFTextBlock
---@field TextMarked02 UFTextBlock
---@field TextQuestSetUp UFTextBlock
---@field TextSetUp UFTextBlock
---@field TextTraceMark UFTextBlock
---@field ToggleGroup UToggleGroup
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapSetMarkPanelView = LuaClass(UIView, true)

function WorldMapSetMarkPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.BtnDelete = nil
	--self.BtnDelete002 = nil
	--self.BtnDelete01 = nil
	--self.BtnNotrack = nil
	--self.BtnSave = nil
	--self.BtnTrack = nil
	--self.CheckBox01 = nil
	--self.CheckBox02 = nil
	--self.PanelMark = nil
	--self.PanelSetUP = nil
	--self.TableViewIconMark = nil
	--self.TableViewSetUPList = nil
	--self.TableViewTraceMark = nil
	--self.TextIconMark = nil
	--self.TextMapSetUp = nil
	--self.TextMark = nil
	--self.TextMarked01 = nil
	--self.TextMarked02 = nil
	--self.TextQuestSetUp = nil
	--self.TextSetUp = nil
	--self.TextTraceMark = nil
	--self.ToggleGroup = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapSetMarkPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.BtnDelete)
	self:AddSubView(self.BtnNotrack)
	self:AddSubView(self.BtnSave)
	self:AddSubView(self.BtnTrack)
	self:AddSubView(self.CheckBox01)
	self:AddSubView(self.CheckBox02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapSetMarkPanelView:OnInit()
	self.AdapterTableViewTrace = UIAdapterTableView.CreateAdapter(self, self.TableViewTraceMark, self.OnSelectChangedTrace, true)
	self.AdapterTableViewIcon = UIAdapterTableView.CreateAdapter(self, self.TableViewIconMark, self.OnSelectChangedIcon, true)

	self.IsTrace = true
	self.CurrentTraceSelectIndex = nil

	self.Binder =
	{
		{ "SelectedMarker", UIBinderValueChangedCallback.New(self, nil, self.SetMarker)},
	}
end

function WorldMapSetMarkPanelView:OnDestroy()

end

function WorldMapSetMarkPanelView:OnShow()
	self:InitText()

	self.AdapterTableViewIcon:UpdateAll(WorldMapMgr:GetIconMarkerCfgList())
	self.AdapterTableViewTrace:UpdateAll(WorldMapMgr:GetTraceMarkerCfgList())
	self:UpdateIconMarkerNum()
	self:UpdateTraceMarkerNum()

	UIUtil.SetIsVisible(self.PanelMark, true)
	UIUtil.SetIsVisible(self.PanelSetUP, false)
	self:UpdateMarkerUI()
end

function WorldMapSetMarkPanelView:InitText()
	self.TextMark:SetText(LSTR(700041)) -- "标记"
	self.TextTraceMark:SetText(LSTR(700042)) -- "追踪标记"
	self.TextIconMark:SetText(LSTR(700043)) --"图标标记"
	self.BtnSave:SetText(LSTR(10011)) -- "保存"
	self.BtnDelete:SetText(LSTR(10016)) -- "删除"
end

function WorldMapSetMarkPanelView:UpdateMarkerUI()
	local Marker = self.Marker
	if nil ~= Marker then
		self.IsNewMarker = false

		local Index = Marker:GetMarkerIndex()
		local IsTrace = Marker:IsTraceMarker()
		self.IsTrace = IsTrace
		if IsTrace then
			self:UpdateTraceMarker(Index)
		else
			self:UpdateIconMarker(Index)
		end
	else
		self.IsNewMarker = true

		local MarkerIndex = WorldMapMgr:GetRecommendedTraceMarkerIndex()
		self:UpdateTraceMarker(MarkerIndex)
	end
end

function WorldMapSetMarkPanelView:OnHide()
	WorldMapMgr:SaveMapPlacedMarker()
	WorldMapVM:SetPlacedMarkerVisible(false)
	WorldMapVM:SetMapSetMarkPanelVisible(false)
end

function WorldMapSetMarkPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnDelete, self.OnClickedBtnDelete)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete01, self.DeleteAllTraceMarker)
	UIUtil.AddOnClickedEvent(self, self.BtnDelete002, self.DeleteAllIconMarker)
	UIUtil.AddOnClickedEvent(self, self.BtnSave, self.OnClickedBtnSave)
	UIUtil.AddOnClickedEvent(self, self.BtnTrack, self.OnClickedBtnTrack)
	UIUtil.AddOnClickedEvent(self, self.BtnNotrack, self.OnClickedBtnTrack)
end

function WorldMapSetMarkPanelView:OnRegisterGameEvent()

end

function WorldMapSetMarkPanelView:OnRegisterBinder()
	self:RegisterBinders(WorldMapVM, self.Binder)
end


-- 打开已经存在的标记
function WorldMapSetMarkPanelView:SetMarker(NewValue, OldValue)
	self.Marker = NewValue
	self:UpdateMarkerUI()
end

-- 更新按钮显隐状态
function WorldMapSetMarkPanelView:UpdateButton()
	if self.IsTrace then
		--local IsUsed = WorldMapMgr:IsTraceMarkerUsed(self.TraceCfg.ID)

		if self.IsNewMarker then
			UIUtil.SetIsVisible(self.BtnDelete, false)
			UIUtil.SetIsVisible(self.BtnSave, true)
			UIUtil.SetIsVisible(self.BtnTrack, false)
			UIUtil.SetIsVisible(self.BtnNotrack, false)
		else
			-- local Marker = self.Marker
			-- local IsReplace = IsUsed and ( Marker and self.TraceCfg.ID ~= Marker:GetCfgID() )
			-- UIUtil.SetIsVisible(self.BtnDelete, not IsReplace)
			-- UIUtil.SetIsVisible(self.BtnSave, IsReplace)
			-- UIUtil.SetIsVisible(self.BtnTrack, not IsReplace)
			-- self.IsReplace = IsReplace
			UIUtil.SetIsVisible(self.BtnDelete, true)
			UIUtil.SetIsVisible(self.BtnSave, false)
			UIUtil.SetIsVisible(self.BtnTrack, not self.Marker:GetIsFollow())
			UIUtil.SetIsVisible(self.BtnNotrack, self.Marker:GetIsFollow())
			self:UpdateButtonText()
		end
	else
		if self.IsNewMarker then
			UIUtil.SetIsVisible(self.BtnDelete, false)
			UIUtil.SetIsVisible(self.BtnSave, true)
			UIUtil.SetIsVisible(self.BtnTrack, false)
			UIUtil.SetIsVisible(self.BtnNotrack, false)
		else
			UIUtil.SetIsVisible(self.BtnDelete, true)
			UIUtil.SetIsVisible(self.BtnSave, false)
			UIUtil.SetIsVisible(self.BtnTrack, not self.Marker:GetIsFollow())
			UIUtil.SetIsVisible(self.BtnNotrack, self.Marker:GetIsFollow())
			self:UpdateButtonText()
		end
	end
end

-- 更新按钮文本
function WorldMapSetMarkPanelView:UpdateButtonText()
	if self.Marker == nil then
		return
	end

	local UIMapID = self.Marker:GetAreaUIMapID()
	local MapID = MapUtil.GetMapID(UIMapID)
	local IsOpenAutoPath = _G.WorldMapMgr:IsOpenAutoPath(MapID)

	if self.Marker:GetIsFollow() then
		if IsOpenAutoPath then
			self.BtnNotrack:SetBtnName(LSTR(700021)) -- "取消寻路"
		else
			self.BtnNotrack:SetBtnName(LSTR(700022)) -- "取消追踪"
		end
	else
		if IsOpenAutoPath then
			self.BtnTrack:SetBtnName(LSTR(700019)) -- "寻路"
		else
			self.BtnTrack:SetBtnName(LSTR(700020)) -- "追踪"
		end
	end
end

function WorldMapSetMarkPanelView:OnSelectChangedTrace(Index, ItemData, ItemView, IsByClick)
	if self.Marker and not self.IsTrace then
		self.AdapterTableViewTrace:CancelSelected()
		MsgTipsUtil.ShowTips(LSTR(700023)) -- "仅可切换同类型标记"
		return
	end
	self.IsTrace = true
	self.TraceCfg = ItemData
	self.CurrentTraceSelectIndex = Index
	self:UpdateButton()

	if IsByClick then
		self:UpdateTraceMarker(Index)
		self:UpdateMarker()
	end
end

function WorldMapSetMarkPanelView:OnSelectChangedIcon(Index, ItemData, ItemView, IsByClick)
	if self.Marker and self.IsTrace then
		self.AdapterTableViewIcon:CancelSelected()
		MsgTipsUtil.ShowTips(LSTR(700023))
		return
	end
	self.IsTrace = false
	self.IconCfg = ItemData
	self.CurrentTraceSelectIndex = nil
	self:UpdateButton()

	if IsByClick then
		self:UpdateIconMarker(Index)
		self:UpdateMarker()
	end
end

function WorldMapSetMarkPanelView:UpdateMarker()
	local Marker = self.Marker
	if nil == Marker then
		return
	end

	local Name = self:GetMarkerName()
	if self.IsTrace then
		local TraceCfg = self.TraceCfg
		--local ID = TraceCfg.ID
		--local IsUsed = WorldMapMgr:IsTraceMarkerUsed(ID)
		--local IsReplace = IsUsed and ID ~= Marker:GetCfgID()
		--if not IsReplace then
		WorldMapMgr:UpdatePlacedMarker(Marker, TraceCfg, Name)
		--end
	else
		WorldMapMgr:UpdatePlacedMarker(Marker, self.IconCfg, Name)
	end
end

function WorldMapSetMarkPanelView:GetMarkerName()
	return MAP_DEFAULT_MARKER_NAME
end

function WorldMapSetMarkPanelView:OnClickedBtnSave()
	if self.IsTrace then
		if WorldMapMgr:GetPlacedTraceMarkerNum() == WorldMapMgr:GetTraceMarkerTotalNum() then
			MsgTipsUtil.ShowTips(LSTR(700024)) -- "追踪标记数量已上限"
			return
		end
	else
		if WorldMapMgr:GetPlacedIconMarkerNum() == MapConstant.MAP_MAX_ICON_MARKER then
			MsgTipsUtil.ShowTips(LSTR(700025)) -- "图标标记数量已上限"
			return
		end
	end

	if self.IsReplace then
		local Marker = self.Marker
		local ReplacedMarker = WorldMapMgr:FindPlacedMarker(self.TraceCfg.ID)
		if nil ~= Marker then
			WorldMapMgr:ReplacePlacedMarker(Marker, ReplacedMarker)
			WorldMapMgr:UpdatePlacedMarker(Marker, self.TraceCfg)
		else
			WorldMapMgr:RemovePlacedMarker(ReplacedMarker)
			self:AddPlacedMarker()
		end
		--self:Hide()
		WorldMapMgr:SaveMapPlacedMarker()
		WorldMapVM:SetPlacedMarkerVisible(false)
		self:UpdateButton()
	else
		self:AddPlacedMarker()
		--self:Hide()
		WorldMapMgr:SaveMapPlacedMarker()
		WorldMapVM:SetPlacedMarkerVisible(false)
		--self.IsNewMarker = false
		self:UpdateButton()
		self:UpdateIconMarkerNum()
		self:UpdateTraceMarkerNum()

		local SetMarkType
		if self.IsTrace then
			SetMarkType = 1
		else
			SetMarkType = 2
		end
		WorldMapMgr:ReportData(MapDefine.MapReportType.MapSetMark, SetMarkType)
	end
end

function WorldMapSetMarkPanelView:AddPlacedMarker()
	local ID = MapUtil.GenerateMarkerID()
	local Cfg = self.IsTrace and self.TraceCfg or self.IconCfg
	local UIMapID = WorldMapMgr:GetUIMapID()
	local Name = self:GetMarkerName()
	local PlacedPos = WorldMapMgr:GetPlacedMarkerPos()
	if Cfg and PlacedPos then
		local Marker = WorldMapMgr:AddPlacedMarker(ID, Cfg.ID, UIMapID, Name, PlacedPos.X, PlacedPos.Y, true)
		WorldMapVM.SelectedMarker = Marker
	end
end

function WorldMapSetMarkPanelView:OnClickedBtnDelete()
	local Marker = self.Marker
	if nil == Marker then
		return
	end
	WorldMapMgr:RemovePlacedMarker(Marker)
	self:Hide()
end

-- 追踪或取消追踪
function WorldMapSetMarkPanelView:OnClickedBtnTrack()
	local Marker = self.Marker
	if nil == Marker then
		return
	end
	Marker:ToggleFollow()
	self:Hide()
end

function WorldMapSetMarkPanelView:DeleteAllIconMarker()
	if WorldMapMgr:GetPlacedIconMarkerNum() <= 0 then
		MsgTipsUtil.ShowTips(LSTR(700031)) -- "目前没有图标标记点"
		return
	end

	local function Callback()
		WorldMapMgr:RemoveAllPlacedIconMarkers()
		self:Hide()
		--self:UpdateIconMarkerNum()
	end

	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(700027), nil, Callback, LSTR(700029), LSTR(700030))
end

function WorldMapSetMarkPanelView:DeleteAllTraceMarker()
	if WorldMapMgr:GetPlacedTraceMarkerNum() <= 0 then
		MsgTipsUtil.ShowTips(LSTR(700032)) -- "目前没有追踪标记点"
		return
	end

	local function Callback()
		WorldMapMgr:RemoveAllPlacedTraceMarkers()
		self:Hide()
		--self:UpdateTraceMarkerNum()
		-- if nil ~= self.CurrentTraceSelectIndex then
		-- 	self.AdapterTableViewTrace:UpdateAll(WorldMapMgr:GetTraceMarkerCfgList())
		--     self.AdapterTableViewTrace:SetSelectedIndex(self.CurrentTraceSelectIndex)
		-- end
	end

	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(700028), nil, Callback, LSTR(700029), LSTR(700030))
end

function WorldMapSetMarkPanelView:UpdateIconMarkerNum()
	local Num = WorldMapMgr:GetPlacedIconMarkerNum()
	local Text = LSTR(700026) .. string.format(" %d/%d", Num, MapConstant.MAP_MAX_ICON_MARKER) -- "已标记"
	self.TextMarked02:SetText(Text)
end

function WorldMapSetMarkPanelView:UpdateTraceMarkerNum()
	local Num = WorldMapMgr:GetPlacedTraceMarkerNum()
	local Text = LSTR(700026) .. string.format(" %d/%d", Num, WorldMapMgr:GetTraceMarkerTotalNum()) -- "已标记"
	self.TextMarked01:SetText(Text)
end

function WorldMapSetMarkPanelView:UpdateTraceMarker(SelectedIndex)
	self.AdapterTableViewIcon:CancelSelected()
	self.AdapterTableViewTrace:SetSelectedIndex(SelectedIndex)
end

function WorldMapSetMarkPanelView:UpdateIconMarker(SelectedIndex)
	self.AdapterTableViewTrace:CancelSelected()
	self.AdapterTableViewIcon:SetSelectedIndex(SelectedIndex)
end

return WorldMapSetMarkPanelView