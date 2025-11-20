--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2025-06-30 10:06:42
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2025-06-30 11:03:43
FilePath: \Client\Source\Script\Game\Ops\VM\OpsSkiPanelVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local StoreCfg = require("TableCfg/StoreCfg")
local ItemCfg = require("TableCfg/ItemCfg")
local EToggleButtonState = _G.UE.EToggleButtonState
local SaveKey = require("Define/SaveKey")
local SaveMgr = _G.UE.USaveMgr
local LSTR = _G.LSTR
local GoodsStateDf = {UnSelected = 1, Selected = 2, IsBuy = 3}

---@class OpsSkiPanelVM : UIViewModel
local OpsSkiPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsSkiPanelVM:Ctor()
    self.TitleText = nil
    self.SubTitleText = nil
    self.SelectedText = nil
    self.ArrowText = nil
    self.BtnText = nil
    self.bDiscountTipVisible = false
    self.bSuitChooseVisible = false
    self.bImgTextChooseBGVisible = false
    self.bSetBtnVisible = false

    self.SuitData = {}
    self.IsBuy = false
    self.IsSelected = false
    self.SelectedSuitGoodsID = 0
    self.GoodsStateDf = GoodsStateDf
    self.GoodsState = nil
end

function OpsSkiPanelVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    local NodeList = ActivityData.NodeList
    self.TitleText = Activity.Title
    self.SubTitleText = Activity.SubTitle

    --客户端纯显示节点
    local ClientShowNodes = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
    if #ClientShowNodes < 1 then
        return
    end
    local NodeID  = ClientShowNodes[1].Head.NodeID
    local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
    if NodeCfg then
        local SplitList = string.split(NodeCfg.StrParam, "|")
        self.SuitData = {
            [1] = {NodeID = 2507020104, ColorUkey = 100124, JumpID = NodeCfg.Params[1]},
            [2] = {NodeID = 2507020105, ColorUkey = 100125, JumpID = NodeCfg.Params[2], Color = SplitList[1]},
            [3] = {NodeID = 2507020106, ColorUkey = 100126, JumpID = NodeCfg.Params[3], Color = SplitList[2]}
        }
        self.MoviePath = SplitList[3]
    end

    --完成商城购买节点
    self.IsBuy = false
    for _, v in ipairs(NodeList) do
        if not v.Head.EmergencyShutDown then
            NodeID = v.Head.NodeID
            NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID) or {}
            if NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeMallPurchased then
                local GoodsID = NodeCfg.Params and NodeCfg.Params[1]
                local Name = NodeCfg.NodeDesc
                local IsBuy = v.Extra.Progress.Value > 0
                if IsBuy then
                    self.IsBuy = true
                end
                self:SetSuitDataByNodeID(NodeID, GoodsID, IsBuy, Name)
            end
        end
    end
    local SelectedSuitGoodsID = self:GetSavedSelectedSuitID()
    self.IsSelected = SelectedSuitGoodsID ~= 0
    self:SetActGoodsPurchaseState()
end

function OpsSkiPanelVM:SetSuitDataByNodeID(NodeID, GoodsID, IsBuy, Name)
    for _, value in ipairs(self.SuitData) do
        if value.NodeID == NodeID then
            value.GoodsID = GoodsID
            value.IsBuy = IsBuy
            value.Name = Name
            break
        end
    end
end

---@type 设置套装购买状态的显示
function OpsSkiPanelVM:SetActGoodsPurchaseState()
    if not self.IsBuy then
        if not self.IsSelected then
            --未选择
            self.bDiscountTipVisible = true
            self.bSuitChooseVisible = true
            self.bImgTextChooseBGVisible = false
            self.bSetBtnVisible = false
            self.ArrowText = LSTR(100131) --"享8~9折！"
            self.BtnText = LSTR(100130) --套装自选
            self.GoodsState = GoodsStateDf.UnSelected
        else
            --已选择(打开过自选套餐界面)，但未购买
            self.bDiscountTipVisible = false
            self.bSuitChooseVisible = true
            self.bImgTextChooseBGVisible = true
            self.bSetBtnVisible = true
            local SelectSuit = self:GetSelectedSuitGoodsData()
            self.SelectedText = string.format(LSTR(100129), LSTR(SelectSuit.ColorUkey)) --已选：%s套装
            self.BtnText = LSTR(100040) --立即购买
            self.BuyPriceText = ""
            self.DiscountMoneyVisible = true
            self.BuyPriceVisible = true
            self.GoodsState = GoodsStateDf.Selected
        end
    else
        --已购买
        self.bDiscountTipVisible = false
        self.bSuitChooseVisible = false
        self.bImgTextChooseBGVisible = false
        self.bSetBtnVisible = false
        self.BtnText = LSTR(1290003) --已购买
        self.GoodsState = GoodsStateDf.IsBuy
    end
end

---@type 保存选中套装到本地
function OpsSkiPanelVM:SaveSelectedSuit()
    local GoodsID = self.SelectedSuitGoodsID or 0
    local SaveKeyParam = SaveKey.OpsSkiSelected
    SaveMgr.SetInt(SaveKeyParam, GoodsID, true)
end

---@type 获取保存的选中套装ID
function OpsSkiPanelVM:GetSavedSelectedSuitID()
    local SaveKeyParam = SaveKey.OpsSkiSelected
    local SelectedSuitGoodsID = SaveMgr.GetInt(SaveKeyParam, 0, true)
    self.SelectedSuitGoodsID = SelectedSuitGoodsID
    return SelectedSuitGoodsID
end

---@type 获取选中套装Data
function OpsSkiPanelVM:GetSelectedSuitGoodsData()
    local SelectedSuitGoodsID = self.SelectedSuitGoodsID
    for _, value in ipairs(self.SuitData) do
        if value.GoodsID == SelectedSuitGoodsID then
            return value
        end
    end
    return self.SuitData[1]
end

---@type 选中套装时
function OpsSkiPanelVM:OnSelectedSuit(SelectedSuitGoodsID)
    self.SelectedSuitGoodsID = SelectedSuitGoodsID
    if self.IsSelected == false then
        self.IsSelected = true
        self:SetActGoodsPurchaseState()
    end
    local SelectSuit = self:GetSelectedSuitGoodsData()
    self.SelectedText = string.format(LSTR(100129), LSTR(SelectSuit.ColorUkey)) --已选：%s套装
    _G.EventMgr:SendEvent(_G.EventID.OpsSkiSelectSuit, SelectedSuitGoodsID)
end

---@type 立即购买
function OpsSkiPanelVM:BuyNow()
    local GoodsCfgData = StoreCfg:FindCfgByKey(self.SelectedSuitGoodsID)
    if GoodsCfgData then
        local BuyPriceVM = _G.StoreMgr:GetBuyPriceVM()
        if nil ~= BuyPriceVM then
            BuyPriceVM:UpdatePriceData(GoodsCfgData, false, false, 1)
        end
        _G.StoreMgr:CheckPurchasePreconditions(GoodsCfgData)
    end
end

---@type 购买后回调界面刷新
function OpsSkiPanelVM:AfterBuy(Msg)
    local GoodsID = Msg.Good.GoodID
    for _, value in ipairs(self.SuitData) do
        if value.GoodsID == GoodsID then
            value.IsBuy = true
            self.IsBuy = true
            self:SetActGoodsPurchaseState()
            break
        end
    end
end

--region Video设置
function OpsSkiPanelVM:UpdatePlayState()
	if self:BPlayChecked() then
		self.PlayState = EToggleButtonState.Unchecked
	else
		self.PlayState = EToggleButtonState.Checked
	end
end

function OpsSkiPanelVM:BPlayChecked()
	return self.PlayState == EToggleButtonState.Checked
end

function OpsSkiPanelVM:UpdateSoundState()
	if self:BSoundChecked() then
		self.SoundState = EToggleButtonState.Unchecked
	else
		self.SoundState = EToggleButtonState.Checked
	end
end

function OpsSkiPanelVM:BSoundChecked()
	return self.SoundState == EToggleButtonState.Checked
end
--endregion

return OpsSkiPanelVM