---
--- Author: Administrator
--- DateTime: 2023-08-29 19:17
--- Description: 聊天打开地图发送位置超链接
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local WorldMapVM = require("Game/Map/VM/WorldMapVM")

local WorldMapMgr = _G.WorldMapMgr
local ChatMgr = _G.ChatMgr
local LSTR = _G.LSTR


---@class WorldMapSendMarkPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnOK1 CommBtnSView
---@field BtnOK2 CommBtnSView
---@field SendLoctionPanel UFCanvasPanel
---@field SendMarkPanel UFCanvasPanel
---@field TableViewMark UTableView
---@field TextLoction URichTextBox
---@field TextMark URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapSendMarkPanelView = LuaClass(UIView, true)

function WorldMapSendMarkPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnOK1 = nil
	--self.BtnOK2 = nil
	--self.SendLoctionPanel = nil
	--self.SendMarkPanel = nil
	--self.TableViewMark = nil
	--self.TextLoction = nil
	--self.TextMark = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapSendMarkPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnOK1)
	self:AddSubView(self.BtnOK2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapSendMarkPanelView:OnInit()
	self.AdapterTableViewMark = UIAdapterTableView.CreateAdapter(self, self.TableViewMark, self.TableViewMarkSelectChanged)

	self.SelectedMapID = nil
	self.SelectedPosition = nil
end

function WorldMapSendMarkPanelView:OnDestroy()

end

function WorldMapSendMarkPanelView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	if Params.IsShowMarkPanel then
		UIUtil.SetIsVisible(self.SendMarkPanel, true)
		UIUtil.SetIsVisible(self.SendLoctionPanel, false)

		local TraceMarkerListUsed = WorldMapMgr:GetTraceMarkerListUsed()
		if #TraceMarkerListUsed > 0 then
			for i = 1, #TraceMarkerListUsed do
				TraceMarkerListUsed[i].SendMarkerPanelMode = true
			end
			self.AdapterTableViewMark:UpdateAll(TraceMarkerListUsed)
		end
		self.BtnOK2:SetIsEnabled(false)
		self.BtnOK2:SetBtnName(_G.LSTR(700018))
		self.AdapterTableViewMark:CancelSelected()

	elseif Params.IsShowLoctionPanel then
		UIUtil.SetIsVisible(self.SendMarkPanel, false)
		UIUtil.SetIsVisible(self.SendLoctionPanel, true)
		self.BtnOK1:SetIsEnabled(false)
		self.BtnOK1:SetBtnName(_G.LSTR(700018)) -- "发送"
		self.TextLoction:SetText(LSTR(700013)) -- "点击地图可发送位置"
	end
end

function WorldMapSendMarkPanelView:OnHide()

end

function WorldMapSendMarkPanelView:TableViewMarkSelectChanged()
	local MarkerCfg = self.AdapterTableViewMark:GetSelectedItemData()
	if nil ~= MarkerCfg then
		self.BtnOK2:SetIsEnabled(true)
	end
end

function WorldMapSendMarkPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnOK2, self.OnClickedBtnOK2)
	UIUtil.AddOnClickedEvent(self, self.BtnOK1, self.OnClickedBtnOK1)
end

function WorldMapSendMarkPanelView:OnRegisterGameEvent()

end

function WorldMapSendMarkPanelView:OnRegisterBinder()

end

function WorldMapSendMarkPanelView:OnClickedBtnOK2()
	local MarkerCfg = self.AdapterTableViewMark:GetSelectedItemData()
	if nil == MarkerCfg then
		WorldMapVM:CloseWorldMapPanel()
		return
	end
	local Marker = WorldMapMgr:FindPlacedMarker(MarkerCfg.ID)
	if nil == Marker then
		WorldMapVM:CloseWorldMapPanel()
		return
	end
	local PosX, PosY = Marker:GetPosition()
	ChatMgr:AddLocationHref(MapUtil.GetMapID(Marker:GetUIMapID()), { X = PosX, Y = PosY })
	WorldMapVM:CloseWorldMapPanel()
end

function WorldMapSendMarkPanelView:OnClickedBtnOK1()
	if nil == self.SelectedPosition or nil == self.SelectedMapID then
		WorldMapVM:CloseWorldMapPanel()
		return
	end
	ChatMgr:AddLocationHref(self.SelectedMapID, self.SelectedPosition)
	WorldMapVM:CloseWorldMapPanel()
end

function WorldMapSendMarkPanelView:SetSelectedPosition(UIMapID, Pos)
	local MapID = MapUtil.GetMapID(UIMapID)
	self.SelectedMapID = MapID
	self.SelectedPosition = { X = Pos.X , Y = Pos.Y }
	local ShowText = string.format("%s(%.1f,%.1f)", MapUtil.GetChatHyperlinkMapName(MapID), (Pos.X) or 0 , (Pos.Y) or 0 )
	self.TextLoction:SetText(string.format(LSTR(700014), RichTextUtil.GetText(ShowText, "D1BA8EFF"))) -- "确认发送%s？"
	self.BtnOK1:SetIsEnabled(true)
end

return WorldMapSendMarkPanelView