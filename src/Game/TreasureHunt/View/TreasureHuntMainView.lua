---
--- Author: Administrator
--- DateTime: 2023-11-15 12:13
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local TipsUtil = require("Utils/TipsUtil")
local ItemUtil = require("Utils/ItemUtil")
local RichTextUtil = require("Utils/RichTextUtil")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIAdventureAdapterTableView = require("Game/Adventure/UIAdventureAdapterTableView")

local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ItemTipsUtil = require("Utils/ItemTipsUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetIsEnabled = require("Binder/UIBinderSetIsEnabled")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetSelectedIndex = require("Binder/UIBinderSetSelectedIndex")

local TeamDefine = require("Game/Team/TeamDefine")
local MapCfg = require("TableCfg/MapCfg")

---@class TreasureHuntMainView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field AutoMap TreasureHuntAutoPanelView
---@field BtnCount UFButton
---@field BtnGoFind CommBtnLView
---@field BtnReading CommBtnLView
---@field BtnRecruit UFButton
---@field CloseBtn CommonCloseBtnView
---@field ImgTitleDecoAdvanced UFImage
---@field ImgTitleDecoOrdinary UFImage
---@field InforBtn CommInforBtnView
---@field MapInfoPanel UFCanvasPanel
---@field PanelMapInfo UFCanvasPanel
---@field PanelNoGet UFCanvasPanel
---@field PanelNotOpen UFCanvasPanel
---@field PanelPaperAdvanced UFCanvasPanel
---@field PanelPaperOrdinary UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field RichTextCount URichTextBox
---@field RichTextLevel URichTextBox
---@field TableViewReward UTableView
---@field TableViewWay UTableView
---@field TextMapName UFTextBlock
---@field TextMapReward UFTextBlock
---@field TextNoGet UFTextBlock
---@field TextNotOpen UFTextBlock
---@field TextNumber UFTextBlock
---@field TextTitle UFTextBlock
---@field TextVigour UFTextBlock
---@field TextWay UFTextBlock
---@field TipsBtn CommInforBtnView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TreasureHuntMainView = LuaClass(UIView, true)

function TreasureHuntMainView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.AutoMap = nil
	--self.BtnCount = nil
	--self.BtnGoFind = nil
	--self.BtnReading = nil
	--self.BtnRecruit = nil
	--self.CloseBtn = nil
	--self.ImgTitleDecoAdvanced = nil
	--self.ImgTitleDecoOrdinary = nil
	--self.InforBtn = nil
	--self.MapInfoPanel = nil
	--self.PanelMapInfo = nil
	--self.PanelNoGet = nil
	--self.PanelNotOpen = nil
	--self.PanelPaperAdvanced = nil
	--self.PanelPaperOrdinary = nil
	--self.PopUpBG = nil
	--self.RichTextCount = nil
	--self.RichTextLevel = nil
	--self.TableViewReward = nil
	--self.TableViewWay = nil
	--self.TextMapName = nil
	--self.TextMapReward = nil
	--self.TextNoGet = nil
	--self.TextNotOpen = nil
	--self.TextNumber = nil
	--self.TextTitle = nil
	--self.TextVigour = nil
	--self.TextWay = nil
	--self.TipsBtn = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TreasureHuntMainView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.AutoMap)
	self:AddSubView(self.BtnGoFind)
	self:AddSubView(self.BtnReading)
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.InforBtn)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.TipsBtn)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TreasureHuntMainView:OnInit()
	self.MapCount = 10
	self.RewardTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewReward)
	self.RewardTableView:SetOnClickedCallback(self.OnTableViewRewardsAdapterChange)
	self.RewardTableView:SetScrollbarIsVisible(false)
	self.GetWayTableView = UIAdventureAdapterTableView.CreateAdapter(self, self.TableViewWay, nil, true)
	self.GetWayTableView:SetScrollbarIsVisible(false)
	self.InforBtn.HelpInfoID = 13

    for i = 1,self.MapCount do
		local MapItemVM = _G.TreasureHuntMainVM:GetMapItemVM(i)
		self.AutoMap[string.format("Map%02d", i)].ViewModel = MapItemVM
	end
end

function TreasureHuntMainView:OnDestroy()

end

function TreasureHuntMainView:OnShow()
	self.TextMapReward:SetText(_G.LSTR(640039)) --奖励
	self.TextNoGet:SetText(_G.LSTR(640041))    --未拥有
	self.TextNotOpen:SetText(_G.LSTR(640042))  --尚未开放
	self.TextTitle:SetText(_G.LSTR(640037))    --寻宝
	self.TextVigour:SetText(_G.LSTR(640038))   -- 今日获取宝图：
	self.TextWay:SetText(_G.LSTR(640040))      -- 获取途径
	self.BtnReading:SetBtnName(_G.LSTR(640046)) -- 解读
	self.BtnGoFind:SetBtnName(_G.LSTR(640061)) -- 前往寻宝

	self.CurSelectIndex = self:FindDataIndex(self.Params and self.Params.UndecodeMapID)
	self:OnClickBtnSelected(self.CurSelectIndex)

	for i = 1,self.MapCount do 
		self.AutoMap[string.format("Map%02d", i)]:ShowMainPanel()
	end

	_G.TreasureHuntMainVM:UpdateStamina()
end

function TreasureHuntMainView:OnHide()

end

function TreasureHuntMainView:OnRegisterUIEvent()
	self.TipsBtn:SetCallback(self, self.OnTipsBtnClick)

	for i = 1,self.MapCount do
		local BtnSelect = self.AutoMap[string.format("Map%02d", i)].BtnSelect
		UIUtil.AddOnClickedEvent(self,BtnSelect, self.OnClickBtnSelected,i)
		local BtnGOMap = self.AutoMap[string.format("Map%02d", i)].BtnGOMap
		UIUtil.AddOnClickedEvent(self, BtnGOMap, self.OnClickBtnGOMap,i)
	end

	UIUtil.AddOnClickedEvent(self, self.BtnGoFind, self.OnClickedBtnGoFind)
	UIUtil.AddOnClickedEvent(self, self.BtnReading, self.OnClickedBtnReading)
	
	UIUtil.AddOnClickedEvent(self, self.BtnCount, self.OnClickedBtnCount)
	UIUtil.AddOnClickedEvent(self, self.BtnRecruit, self.OnClickedBtnRecruit)
	--self.BtnBack:AddBackClick(self, function(e) e:Hide() end)
end

function TreasureHuntMainView:OnRegisterGameEvent()

end

function TreasureHuntMainView:OnRegisterBinder()
	self.Binders = {
		{"PanelOrdinaryVisible", UIBinderSetIsVisible.New(self, self.PanelPaperOrdinary,false, true) },
		{"ImgTitleDecoOrdinary", UIBinderSetIsVisible.New(self, self.ImgTitleDecoOrdinary,false, true) },
		{"PanelAdvancedVisible", UIBinderSetIsVisible.New(self, self.PanelPaperAdvanced,false, true) },
		{"ImgTitleDecoAdvanced", UIBinderSetIsVisible.New(self, self.ImgTitleDecoAdvanced,false, true) },
		{"MapInfoPanelVisible", UIBinderSetIsVisible.New(self, self.MapInfoPanel,false, true) },
		{"PanelNotOpenVisible", UIBinderSetIsVisible.New(self, self.PanelNotOpen,false, true) },
		{"TableViewWidgetVisible", UIBinderSetIsVisible.New(self, self.TableViewWidget) },

		{"TextNumber", UIBinderSetText.New(self, self.TextNumber)}, 
		{"BtnReadingVisible", UIBinderSetIsVisible.New(self, self.BtnReading,false, true) },
		{"BtnGoFindVisible", UIBinderSetIsVisible.New(self, self.BtnGoFind,false, true) },
		{"PanelNoGetVisible", UIBinderSetIsVisible.New(self, self.PanelNoGet,false, true) },
		
		{ "TextMapName", UIBinderSetText.New(self, self.TextMapName)}, 
		{ "RichTextLevel", UIBinderSetText.New(self, self.RichTextLevel)}, 
		{ "RichTextCount", UIBinderSetText.New(self, self.RichTextCount)}, 

		{ "RewardList", UIBinderUpdateBindableList.New(self, self.RewardTableView) },
		{ "GetWayList", UIBinderUpdateBindableList.New(self, self.GetWayTableView) },
	}
	self:RegisterBinders(_G.TreasureHuntMainVM, self.Binders)
end

function TreasureHuntMainView:OnTipsBtnClick()
	--点击小图标时，在左上侧显示通用提示tips
	local tipsContent = RichTextUtil.GetText(_G.LSTR(640034), "D5D5D5").."\n"..RichTextUtil.GetText(_G.LSTR(640035), "D5D5D5")..RichTextUtil.GetText(string.format("%s", "00：00"), "D1BA8E")..RichTextUtil.GetText(_G.LSTR("640036"), "D5D5D5")
	TipsUtil.ShowInfoTips(tipsContent, self.TipsBtn, _G.UE.FVector2D(0, 60), _G.UE.FVector2D(0, 0))
end

function TreasureHuntMainView:OnClickedBtnRecruit()
	local TypeID = _G.TreasureHuntMgr:GetRecruitMethod()
	if TypeID and TypeID > 0 then
		local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
		TeamRecruitUtil.TryOpenTeamRecruitView(TypeID)
	else
		_G.FLOG_ERROR("TreasureHuntMainView Jump to Recruit faild TypeID = " .. tostring(TypeID))
	end
end

function TreasureHuntMainView:OnClickedRecuritMember()
	local TypeID = _G.TreasureHuntMgr:GetRecruitMethod()
	if TypeID and TypeID > 0 then
		local TeamRecruitUtil = require("Game/TeamRecruit/TeamRecruitUtil")
		TeamRecruitUtil.TryOpenTeamRecruitView(TypeID)
	else
		_G.FLOG_ERROR("TreasureHuntMainView Jump to Recruit faild TypeID = " .. tostring(TypeID))
	end
	_G.UIViewMgr:HideView(_G.UIViewID.CommJumpWayTipsView)
end

function TreasureHuntMainView:OnClickedBtnGoFind()
    if _G.TreasureHuntMgr:IsInDungeon() then return end
	self:Hide()

	local mapData = _G.TreasureHuntMainVM:GetMapInfo(self.CurSelectIndex)
	if mapData == nil then return end
	_G.TreasureHuntMgr:InterpretMapReq(mapData.ID)
end

function TreasureHuntMainView:OnClickedBtnReading()
	local mapData = _G.TreasureHuntMainVM:GetMapInfo(self.CurSelectIndex)
	if mapData == nil then return end

	_G.TreasureHuntMgr:DecodeTreasureMap(mapData.UnDecodeMapID)
end

function TreasureHuntMainView:OnClickedBtnCount()
	local function Callback()
	end

	local MsgContent = _G.LSTR(640033)  --事件统计预留入口，敬请期待..
	MsgBoxUtil.MessageBox(MsgContent, _G.LSTR(10002), _G.LSTR(10003), Callback)
end

function TreasureHuntMainView:OnClickBtnGOMap(mapIndex)
	self.CurSelectIndex = mapIndex
	_G.TreasureHuntMainVM:UpdateMapItemData(mapIndex)
	_G.ObjectMgr:CollectGarbage(false)
end

function TreasureHuntMainView:OnClickBtnSelected(mapIndex)
	self.CurSelectIndex = mapIndex
	_G.TreasureHuntMainVM:UpdateMapItemData(mapIndex)
	_G.ObjectMgr:CollectGarbage(false)
end

function TreasureHuntMainView:OnTableViewRewardsAdapterChange(Index, ItemData, ItemView)
	if ItemData and ItemData.ResID then
    	ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
	end
end

function TreasureHuntMainView:FindDataIndex(UndecodeMapID)
	if not UndecodeMapID then
		-- 已解读 > 未解读, 单人 > 多人, 等级低 > 等级高
		local SingleStartIndex = 1
		local MultiStartIndex = 2
		for Index = SingleStartIndex, self.MapCount, 2 do
			local MapData = _G.TreasureHuntMainVM:GetMapInfo(Index)
			if MapData then
				local Count = _G.TreasureHuntMainVM:GetMapCount(MapData.ID)
				if Count > 0 then
					return Index
				end
			end
		end

		for Index = MultiStartIndex, self.MapCount, 2 do
			local MapData = _G.TreasureHuntMainVM:GetMapInfo(Index)
			if MapData then
				local Count = _G.TreasureHuntMainVM:GetMapCount(MapData.ID)
				if Count > 0 then
					return Index
				end
			end
		end

		for Index = SingleStartIndex, self.MapCount, 2 do
			local MapData = _G.TreasureHuntMainVM:GetMapInfo(Index)
			if MapData then
				local Count = _G.TreasureHuntMainVM:GetMapCount(MapData.UnDecodeMapID)
				if Count > 0 then
					return Index
				end
			end
		end

		for Index = MultiStartIndex, self.MapCount, 2 do
			local MapData = _G.TreasureHuntMainVM:GetMapInfo(Index)
			if MapData then
				local Count = _G.TreasureHuntMainVM:GetMapCount(MapData.UnDecodeMapID)
				if Count > 0 then
					return Index
				end
			end
		end
	else
		for Index = 1, self.MapCount do 
			local MapData = _G.TreasureHuntMainVM:GetMapInfo(Index)
			if MapData and MapData.UnDecodeMapID == UndecodeMapID then 
				return Index
			end
		end 
	end

	return 1
end

return TreasureHuntMainView