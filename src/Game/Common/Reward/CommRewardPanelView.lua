---
--- Author: sammrli
--- DateTime: 2023-05-17 22:40
--- Description:公共获取奖励界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local LootMappingCfg = require("TableCfg/LootMappingCfg")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ItemVM = require("Game/Item/ItemVM")
local UIBindableList = require("UI/UIBindableList")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local AudioUtil = require("Utils/AudioUtil")
local ItemDefine = require("Game/Item/ItemDefine")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local SaveKey = require("Define/SaveKey")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local DataReportUtil = require("Utils/DataReportUtil")
local SidePopUpDefine = require("Game/SidePopUp/SidePopUpDefine")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local SoundPath = "AkAudioEvent'/Game/WwiseAudio/Events/UI/UI_SYS/New/Play_FM_Prize.Play_FM_Prize'"
local ItemDelayTime = 0.16
local OneRowDelayTime = 1.5

---@class CommRewardPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field BtnCheck CommBtnLView
---@field BtnClose CommBtnLView
---@field CommCheckBox CommCheckBoxView
---@field CommonPopUpBG CommonPopUpBGView
---@field HorizontalCurrent1 UFHorizontalBox
---@field IconGold UFImage
---@field IconGoldSizeBox USizeBox
---@field IconShareSizeBox USizeBox
---@field ImgBG UFImage
---@field ImgMoney1 UFImage
---@field PanelBtn UFCanvasPanel
---@field PanelGoldSauserDeco UFCanvasPanel
---@field PanelMoney UFCanvasPanel
---@field Panshare UFCanvasPanel
---@field RichText URichTextBox
---@field TableViewRewardList UTableView
---@field TableViewRewardList2 UTableView
---@field TableViewRewardList3 UTableView
---@field TextCloseTips UFTextBlock
---@field TextCurrentPrice1 UFTextBlock
---@field TextHint UFTextBlock
---@field TextReward UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommRewardPanelView = LuaClass(UIView, true)

local USaveMgr = _G.UE.USaveMgr
local LSTR = _G.LSTR

function CommRewardPanelView:Ctor()
    --AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.BtnCheck = nil
	--self.BtnClose = nil
	--self.CommCheckBox = nil
	--self.CommonPopUpBG = nil
	--self.HorizontalCurrent1 = nil
	--self.IconGold = nil
	--self.IconGoldSizeBox = nil
	--self.IconShareSizeBox = nil
	--self.ImgBG = nil
	--self.ImgMoney1 = nil
	--self.PanelBtn = nil
	--self.PanelGoldSauserDeco = nil
	--self.PanelMoney = nil
	--self.Panshare = nil
	--self.RichText = nil
	--self.TableViewRewardList = nil
	--self.TableViewRewardList2 = nil
	--self.TableViewRewardList3 = nil
	--self.TextCloseTips = nil
	--self.TextCurrentPrice1 = nil
	--self.TextHint = nil
	--self.TextReward = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommRewardPanelView:OnRegisterSubView()
    --AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCheck)
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.CommCheckBox)
	self:AddSubView(self.CommonPopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommRewardPanelView:OnInit()
    self.ItemList =
        UIBindableList.New(
        ItemVM,
        {
            Source = ItemDefine.ItemSource.MatchReward,
            IsCanBeSelected = true,
            IsShowNum = true,
            IsDaily = false,
            IsShowSelectStatus = false,
        }
    )
    self.TableViewAdapter =
        UIAdapterTableView.CreateAdapter(self, self.TableViewRewardList, self.OnSelectChanged, true, false)
    self.TableViewAdapter2 =
        UIAdapterTableView.CreateAdapter(self, self.TableViewRewardList2, self.OnSelectChanged, true, false)
    self.TableViewAdapter3 =
        UIAdapterTableView.CreateAdapter(self, self.TableViewRewardList3, self.OnSelectChanged, true, false)

    self.CommonPopUpBG:SetHideOnClick(true)
    self.BtnLeft = self.BtnClose
	self.BtnRight = self.BtnCheck
end

function CommRewardPanelView:OnDestroy()
end

function CommRewardPanelView:OnShow()
    self.TextHint:SetText(LSTR(100032))
    self.TextReward:SetText(LSTR(100033))
    self.TextCloseTips:SetText(LSTR(100034))
    self.CommCheckBox:SetText(LSTR(100014))
    self:ClearDraw()
    _G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.CommRewardPanel, true)
    local Params = self.Params 
    if Params == nil then
        return
    end
    self.CloseCallback = Params.CloseCallback
    self.HideClickItem = Params.HideClickItem
    if (Params.Title or "") ~= "" then
        self.TextReward:SetText(Params.Title)
    end

    if Params.LootID then
        local ItemList = self:GetLootItems(Params.LootID)
        self:UpdateListView(ItemList)
    end
    -- 建议用下方的 ItemVMList 来传入Item信息  
    -- ItemList 和 LootID 会用的默认ItemVM  ItemVM 是道具改版前留下的VM没有维护里面变量和逻辑过多 只可以临时使用 
    -- 有特殊显示需求最好传入自己的ItemVM
    if Params.ItemList then
        self:UpdateListView(Params.ItemList)
    end

    if Params.ItemVMList then
        self:UpdateListViewFromVmList(Params.ItemVMList)
    end

    -- 抽奖奖励
    if Params.LotteryAwards then
        self:UpdateLotteryAwardView(Params)
    end

    UIUtil.SetIsVisible(self.PanelBtn, Params.ShowBtn == true )
    UIUtil.SetIsVisible(self.BtnLeft, Params.ShowBtnLeft == true )
    UIUtil.SetIsVisible(self.BtnRight, Params.ShowBtnRight == true )
    UIUtil.SetIsVisible(self.PanelGoldSauserDeco, Params.ShowPanelGoldSauser == true )
    self.BtnLeft:SetText(Params.BtnLeftText or "")
    self.BtnRight:SetText(Params.BtnRightText or "")
    self.BtnRightCB = Params.BtnRightCB
    self.BtnLeftCB = Params.BtnLeftCB
    AudioUtil.LoadAndPlayUISound(SoundPath)
end

function CommRewardPanelView:OnHide()
    if self.Params and self.Params.LotteryAwards then
        self:ClearDraw()
    end

    if self.Params and self.Params.IsOnDirectUpState then
        _G.UpgradeMgr:PlayLevelUpdateEffect()
    end

    _G.LootMgr:SetDealyState(false)

    --发送新手引导触发获得物品触发消息
    local EventParams = _G.EventMgr:GetEventParams()
    EventParams.Type = TutorialDefine.TutorialConditionType.GetItem --新手引导触发类型
    _G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)

    _G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.CommRewardPanel, false)

	if self.Params and self.Params.IsByMasterBoxReset then
    	self.CommonPopUpBG:SetHideOnClick(true)
    end

    if self.Params and self.Params.LotteryAwards then
		_G.SidePopUpMgr:Pause(SidePopUpDefine.Pause_Type.OpsActivityTreasureChest, false)
    end
	
    if (self.CloseCallback ~= nil) then
        self.CloseCallback()
        self.CloseCallback = nil
    end
end

function CommRewardPanelView:OnRegisterUIEvent()
    UIUtil.AddOnClickedEvent(self, self.BtnLeft, self.OnClickLeftBtnOp)
	UIUtil.AddOnClickedEvent(self, self.BtnRight, self.OnClickRightBtnOp)
    UIUtil.AddOnClickedEvent(self, self.Btn, self.OnClickBtnShare)
    UIUtil.AddOnStateChangedEvent(self, self.CommCheckBox.ToggleButton, self.OnCheckBoxClick)
end

function CommRewardPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ShareOpsActivitySuccess, self.OnShareOpsActivitySuccess)
end

function CommRewardPanelView:OnRegisterBinder()
end

function CommRewardPanelView:OnSelectChanged(Index, ItemData, ItemView)
    if self.HideClickItem then 
        return
    end

    ItemTipsUtil.ShowTipsByResID(ItemData.ResID, ItemView)
end

function CommRewardPanelView:OnClickLeftBtnOp()
	if self.BtnLeftCB ~= nil then
		self.BtnLeftCB()
	end 
end

function CommRewardPanelView:OnClickRightBtnOp()
	if self.BtnRightCB ~= nil then
		self.BtnRightCB()
	end 
end

function CommRewardPanelView:OnClickBtnShare()
    if self.Params == nil then
       return
    end
    if self.Params.ShareNodeCfg and self.Params.ShareNodeCfg.Params then
        local ActivityID = self.Params.ShareNodeCfg.ActivityID
        local ShareID = self.Params.ShareNodeCfg.Params[1]
		_G.ShareMgr:OpenShareActivityUI(ActivityID, ShareID)
        --珍品宝箱活动埋点(点击分享)
	    DataReportUtil.ReportActivityClickFlowData(ActivityID, "1")
	end
end

function CommRewardPanelView:TableUpdateAll(ItemVMList)
    local ItemNum = ItemVMList:Length() or 0
    UIUtil.SetIsVisible(self.TableViewRewardList, false)
    UIUtil.SetIsVisible(self.TableViewRewardList2, false)
    UIUtil.SetIsVisible(self.TableViewRewardList3, false)
    for i = 1, ItemNum do
        local ItemVM = ItemVMList:Get(i)
        ItemVM.RewardItemPlayAnimIn = false
    end
    if ItemNum > 12  then
        self.TableViewAdapter3:UpdateAll(ItemVMList)
        UIUtil.SetIsVisible(self.TableViewRewardList3, true, true)
        self:AutoScrollDown(ItemVMList)
    elseif ItemNum > 6 then 
        self.TableViewAdapter2:UpdateAll(ItemVMList)
        UIUtil.SetIsVisible(self.TableViewRewardList2, true, true)
        self:AutoPlayItemIn(2, ItemVMList)
    else
        self.TableViewAdapter:UpdateAll(ItemVMList)
        UIUtil.SetIsVisible(self.TableViewRewardList, true, true)
        self:AutoPlayItemIn(1, ItemVMList)
    end
end

function CommRewardPanelView:AutoScrollDown(ItemVMList)
    local ItemNum = self.TableViewAdapter3:GetNum()
    if ItemNum <= 0 then return end
    self.PlayedAnimFirstIn = true
    self.TableViewRewardList3:SetScrollEnabled(false)
    self.TableViewAdapter3:ScrollToBottom()
    local ScrollLength = self.TableViewRewardList3:GetScrollOffset()
    self.TableViewAdapter3:ScrollToTop()
    local LoopNum = math.ceil(ItemNum/6)
    local UnitOffset = (1 / LoopNum) * ScrollLength
    local SetOffset = 0
    local CutNum = 0
    local TimeCount = 0.0
    self.List3Timer = self:RegisterTimer(function()
        TimeCount = TimeCount + ItemDelayTime
        if CutNum ~= 0 and CutNum % 6 == 0 and TimeCount <= OneRowDelayTime then
            if TimeCount >= OneRowDelayTime then
                TimeCount = 0.0
            else
                return
            end
        end
        CutNum = CutNum + 1
      
        local ChildVM = ItemVMList:Get(CutNum)
        if ChildVM ~= nil then
            ChildVM.RewardItemPlayAnimIn = true
        end
        if CutNum % 6 == 1 and CutNum >= 12 then
            SetOffset = SetOffset + UnitOffset
            self.TableViewRewardList3:SetScrollOffset(SetOffset)
        end
        if CutNum == ItemNum then
            self.TableViewRewardList3:ScrollToBottom()
            self.TableViewRewardList3:SetScrollEnabled(true)
            self.PlayedAnimFirstIn = nil
            self:UnRegisterTimer(self.List3Timer)
            self.List3Timer = nil
        end
    end, 0.05, ItemDelayTime, 0)
end

-- 
function CommRewardPanelView:AutoPlayItemIn(AdapterIndex, ItemVMList)
    local ItemNum = ItemVMList:Length()
    if ItemNum <= 0 then return end
    local CurTableViewRewardList
    local CurTableViewAdapter
    if AdapterIndex == 1 then
        CurTableViewAdapter = self.TableViewAdapter
        CurTableViewRewardList = self.TableViewRewardList
    else
        CurTableViewAdapter = self.TableViewAdapter2
        CurTableViewRewardList = self.TableViewRewardList2
    end

    CurTableViewRewardList:SetScrollEnabled(false)
    local CutNum = 0 
    self.PlayedAnimFirstIn = true 
    
    self:RegisterTimer(function()
        CutNum = CutNum + 1
        local ChildVM = ItemVMList:Get(CutNum)
        if ChildVM ~= nil then
            ChildVM.RewardItemPlayAnimIn = true
        end
        if CutNum == ItemNum then
            CurTableViewRewardList:SetScrollEnabled(true)
            self.PlayedAnimFirstIn = nil
        end
    end, 0.05, ItemDelayTime, ItemNum)
end

--------------------------------

-- 根据自己传入的ItemVMList 列表更新数据
---@param ItemVMList  UIBindableList
function CommRewardPanelView:UpdateListViewFromVmList(ItemVMList)
    self:TableUpdateAll(ItemVMList)
end

---更新item列表
---@param ItemList table
function CommRewardPanelView:UpdateListView(ItemList)
    self.ItemList:Clear()
    for _, V in ipairs(ItemList) do
        self.ItemList:AddByValue({GID = 1, ResID = V.ResID, Num = V.Num, ShowReceived = V.ShowReceived}, nil, true)
    end
    self:TableUpdateAll(self.ItemList)
end

function CommRewardPanelView:GetLootItems(LootID)
    if LootID == nil then
        return nil
    end
    local LootCfg = LootMappingCfg:FindCfg(string.format("ID=%d", LootID))
    if LootCfg then
        --默认只采取第一个方案，如果有多个方案，要和策划沟通客户端怎么显示
        if LootCfg.Programs and LootCfg.Programs[1] then
            return ItemUtil.GetLootItems(LootCfg.Programs[1].ID)
        end
    end
    return nil
end


--抽奖奖励展示
function CommRewardPanelView:UpdateLotteryAwardView(Params)
    -- 抽到的是否是大奖
    if Params.IsFinalAward then
        UIUtil.SetIsVisible(self.Panshare, true)
        self:UpdateShareTips(Params)
    else
        UIUtil.SetIsVisible(self.Panshare, false) 
    end

    if Params.IsFinishLottery then
        UIUtil.SetIsVisible(self.TextHint,true)
        UIUtil.SetIsVisible(self.TextCloseTips,true)
        UIUtil.SetIsVisible(self.CommCheckBox,false)
        UIUtil.SetIsVisible(self.PanelMoney,false)
        self.CommonPopUpBG:SetHideOnClick(true)
    else
        UIUtil.SetIsVisible(self.PanelMoney,true)
        UIUtil.SetIsVisible(self.TextCloseTips,false)
        self.TextCurrentPrice1:SetText(Params.ConsumePropNum)
        local LotteryPropNum = _G.BagMgr:GetItemNum(Params.PropItemID)
        if LotteryPropNum ~= nil and Params.ConsumePropNum ~= nil then
            if LotteryPropNum < Params.ConsumePropNum then
                UIUtil.SetColorAndOpacityHex(self.TextCurrentPrice1, "DC5868FF")
            else
                UIUtil.SetColorAndOpacityHex(self.TextCurrentPrice1, "FFEEBBFF")
            end
        end
        UIUtil.ImageSetBrushFromAssetPath(self.ImgMoney1, UIUtil.GetIconPath(ItemUtil.GetItemIcon(Params.PropItemID)))
        UIUtil.SetIsVisible(self.CommCheckBox,true)
        self.CommCheckBox:SetChecked(USaveMgr.GetInt(SaveKey.OpsSkipAnimation, 0, true) == Params.ActivityID)
        self.CommonPopUpBG:SetHideOnClick(false)
    end
end

function CommRewardPanelView:UpdateShareTips(Params)
    if Params == nil then
       return
    end
    local ShareNode = Params.ShareNode
    local ShareNodeCfg = Params.ShareNodeCfg
    self.ShareNodeCfg = ShareNodeCfg
    if ShareNode and  ShareNodeCfg then
		if ShareNode.Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusDone then
			self.RichText:SetText(_G.LSTR(970008))
			UIUtil.SetIsVisible(self.IconGold, false)
		else
			self.RichText:SetText(ShareNodeCfg.NodeDesc)
			if ShareNodeCfg.Rewards[1] and ShareNodeCfg.Rewards[1].ItemID and ShareNodeCfg.Rewards[1].ItemID > 0 then
				local IconPath = UIUtil.GetIconPath(ItemUtil.GetItemIcon(ShareNodeCfg.Rewards[1].ItemID))
				UIUtil.ImageSetBrushFromAssetPath( self.IconGold, IconPath) 
				UIUtil.SetIsVisible(self.IconGold, true)
			else
				UIUtil.SetIsVisible(self.IconGold, false)
			end
		end
	end
end

function CommRewardPanelView:OnShareOpsActivitySuccess(Param)
	if Param == nil or self.Params == nil then
		return
	end
	if self.Params and self.Params.ActivityID == Param.ActivityID then
        local ShareNodeCfg = self.Params.ShareNodeCfg
		if ShareNodeCfg then
			_G.OpsActivityMgr:SendActivityEventReport(ActivityNodeType.ActivityNodeTypePictureShare, ShareNodeCfg.Params)
            self.RichText:SetText(_G.LSTR(970008))
			UIUtil.SetIsVisible(self.IconGold, false)
		end
	end
end

function CommRewardPanelView:OnCheckBoxClick(_, ButtonState)
    _G.EventMgr:SendEvent(_G.EventID.OpsTreasureChestSkipAnimation, ButtonState)
end


-- 抽奖奖励展示后重置CommRewardPanel面板
function CommRewardPanelView:ClearDraw()
    UIUtil.SetIsVisible(self.TextCloseTips,true)
    UIUtil.SetIsVisible(self.TextHint,false)
    UIUtil.SetIsVisible(self.CommCheckBox,false)
    UIUtil.SetIsVisible(self.PanelMoney,false)
    UIUtil.SetIsVisible(self.Panshare,false)
    self.CommonPopUpBG:SetHideOnClick(true)
end

return CommRewardPanelView
