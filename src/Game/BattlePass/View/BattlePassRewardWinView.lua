---
--- Author: Administrator
--- DateTime: 2024-12-24 16:40
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local AudioUtil = require("Utils/AudioUtil")
local ItemVM = require("Game/Item/ItemVM")
local UIBindableList = require("UI/UIBindableList")
local ItemDefine = require("Game/Item/ItemDefine")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local SidePopUpDefine = require("Game/SidePopUp/SidePopUpDefine")
local SoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_Prize.Play_FM_Prize'"

---@class BattlePassRewardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnBuy CommBtnLView
---@field BtnClose CommBtnLView
---@field CommonPopUpBG CommonPopUpBGView
---@field FCanvasPanel_50 UFCanvasPanel
---@field FTextBlock_103 UFTextBlock
---@field PanelBtn UFCanvasPanel
---@field TableViewReward01 UTableView
---@field TableViewReward02 UTableView
---@field TextHint UFTextBlock
---@field TextReward UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BattlePassRewardWinView = LuaClass(UIView, true)

function BattlePassRewardWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnBuy = nil
	--self.BtnClose = nil
	--self.CommonPopUpBG = nil
	--self.FCanvasPanel_50 = nil
	--self.FTextBlock_103 = nil
	--self.PanelBtn = nil
	--self.TableViewReward01 = nil
	--self.TableViewReward02 = nil
	--self.TextHint = nil
	--self.TextReward = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BattlePassRewardWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnBuy)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BattlePassRewardWinView:OnInit()
	self.TableViewCommonRewardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward01, self.OnSelectChanged, true, false)
	self.TableViewBigRewardAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewReward02, self.OnSelectChanged, true, false)
	self.CommonRewardList =
        UIBindableList.New(
        ItemVM,
        {
            Source = ItemDefine.ItemSource.MatchReward,
            IsCanBeSelected = true,
            IsShowNum = true,
            IsDaily = false,
            IsShowSelectStatus = false
        }
    )

	self.BigRewardList =
        UIBindableList.New(
        ItemVM,
        {
            Source = ItemDefine.ItemSource.MatchReward,
            IsCanBeSelected = true,
            IsShowNum = true,
            IsDaily = false,
            IsShowSelectStatus = false
        }
    )
end

function BattlePassRewardWinView:OnDestroy()

end

function BattlePassRewardWinView:OnShow()
	_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.BattlePassReward, true)

	self:InitText()
    local Params = self.Params 
    if Params == nil then
        return
    end

	self.HideClickItem = Params.HideClickItem

	if Params.CommonRewardList then
        self:UpdateCommonRewardListView(Params.CommonRewardList)
    end

	if Params.CommonRewardVMList then
		self:TableUpdateAll(1, Params.CommonRewardVMList)
	end

	if Params.BigRewardList then
        self:UpdateBigRewardListView(Params.BigRewardList)
    end

	
	if Params.BigRewardVMList then
        self:TableUpdateAll(2, Params.BigRewardVMList)
    end

	if Params.Tips then
		self.FTextBlock_103:SetText(Params.Tips)
	end

	if Params.Title then
		self.TextReward:SetText(Params.Title)
	end

	if Params.BtnLeftText then
		self.BtnClose:SetButtonText(Params.BtnLeftText)
	end

	if Params.BtnRightText then
		self.BtnBuy:SetButtonText(Params.BtnLeftText)
	end


	if Params.PanelBtnVisible then
		UIUtil.SetIsVisible(self.PanelBtn, Params.PanelBtnVisible)
	end

	UIUtil.SetIsVisible(self.FCanvasPanel_50, Params.ShowTips == true)
    self.BtnRightCB = Params.BtnRightCB
    self.BtnLeftCB = Params.BtnLeftCB
    AudioUtil.LoadAndPlayUISound(SoundPath)

end

function BattlePassRewardWinView:OnHide()
	    --发送新手引导触发获得物品触发消息
		local EventParams = _G.EventMgr:GetEventParams()
		EventParams.Type = TutorialDefine.TutorialConditionType.GetItem --新手引导触发类型
		_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
	
		_G.LootMgr:SetDealyState(false)
		_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.BattlePassReward, false)
end

function BattlePassRewardWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClickLeftBtnOp)
	UIUtil.AddOnClickedEvent(self, self.BtnBuy, self.OnClickRightBtnOp)
end

function BattlePassRewardWinView:OnRegisterGameEvent()

end

function BattlePassRewardWinView:OnRegisterBinder()
end

function BattlePassRewardWinView:InitText()
	self.TextReward:SetText(_G.LSTR(850035))
	self.FTextBlock_103:SetText(_G.LSTR(850036))
	self.BtnClose:SetButtonText(_G.LSTR(850037))
	self.BtnBuy:SetButtonText(_G.LSTR(850038))
end

function BattlePassRewardWinView:OnSelectChanged(Index, ItemData, ItemView)
    if self.HideClickItem then 
        return
    end

    ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
end

function BattlePassRewardWinView:OnClickLeftBtnOp()
	if self.BtnLeftCB ~= nil then
		self.BtnLeftCB()
		return
	end 

	self:Hide()
end

function BattlePassRewardWinView:OnClickRightBtnOp()
	if self.BtnRightCB ~= nil then
		self.BtnRightCB()
	end 
end

---更新item列表
---@param ItemList table
function BattlePassRewardWinView:UpdateCommonRewardListView(ItemList)
    self.CommonRewardList:Clear()
    for _, V in ipairs(ItemList) do
        self.CommonRewardList:AddByValue({GID = 1, ResID = V.ResID, Num = V.Num}, nil, true)
    end
    self:TableUpdateAll(1, self.CommonRewardList)
end

function BattlePassRewardWinView:UpdateBigRewardListView(ItemList)
	self.BigRewardList:Clear()
    for _, V in ipairs(ItemList) do
        self.BigRewardList:AddByValue({GID = 1, ResID = V.ResID, Num = V.Num}, nil, true)
    end
    self:TableUpdateAll(2, self.BigRewardList)
end

function BattlePassRewardWinView:TableUpdateAll(Type, ItemVMList)
	local Widget = Type == 1 and self.TableViewCommonRewardAdapter or self.TableViewBigRewardAdapter
	Widget:UpdateAll(ItemVMList)
end

return BattlePassRewardWinView