local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoCS = require("Protocol/ProtoCS")
local EToggleButtonState = _G.UE.EToggleButtonState
local LSTR = _G.LSTR
local UIBinderSetTextFormatForMoney = require("Binder/UIBinderSetTextFormatForMoney")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsDesertFirePanelVM : UIViewModel
local OpsDesertFirePanelVM = LuaClass(UIViewModel)
---Ctor
function OpsDesertFirePanelVM:Ctor()
    self.TitleText = nil
    self.SubTitleText = nil
    self.PlayState = nil
    self.SoundState = nil
    self.ShareOrStrategyText = nil
    self.ShareOrStrategyIcon = nil
    self.VideoPlayerPath = nil
    self.BuyActionVisible = nil
    self.DiscountMoneyVisible = nil
    self.BuyText = nil
    self.DiscountedText = nil
	self.BuyTagText = nil
    self.BuyTagVisible = nil
    self.BuyPriceVisible = nil
    self.ShareBuyNodeCfg = nil
end

function OpsDesertFirePanelVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    self.TitleText = Activity.Title
    self.SubTitleText = Activity.SubTitle
    self.PlayState = EToggleButtonState.Unchecked
	self.SoundState = EToggleButtonState.Unchecked

    local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeShareBuy)
    if NodeList and #NodeList > 0 then
        local NodeID  = NodeList[1].Head.NodeID
        local Extra = NodeList[1].Extra
        local ShareBuyNodeCfg = ActivityNodeCfg:FindCfgByKey(NodeID)
        if Extra and ShareBuyNodeCfg then
            self.ShareBuyNodeCfg =  ShareBuyNodeCfg
            self.ShareBuyData = Extra.ShareBuy or {}
            if self.ShareBuyData.Status == ProtoCS.Game.Activity.enStatus.None then
                --初始状态
                self.BuyActionVisible = true
                self.ShareOrStrategyText = LSTR(1470009)
                self.ShareOrStrategyIcon = "PaperSprite'/Game/UI/Atlas/Ops/OpsComm/Frames/UI_OpsComm_Icon_Strategy_png.UI_OpsComm_Icon_Strategy_png'"
                self.BuyText = LSTR(1470010)
                self.BuyTagText = LSTR(1470014)
                self.BuyTagVisible = true
                self.BuyPriceText = UIBinderSetTextFormatForMoney:GetText(ShareBuyNodeCfg.Params[1])
                self.DiscountMoneyVisible = true
                self.BuyPriceVisible = true
            elseif self.ShareBuyData.Status == ProtoCS.Game.Activity.enStatus.OriginalPayed then
                --已购买-原价
                self.BuyActionVisible = true
                self.ShareOrStrategyText = LSTR(1470012)
                self.ShareOrStrategyIcon = "PaperSprite'/Game/UI/Atlas/Ops/OpsComm/Frames/UI_OpsComm_Icon_Share_png.UI_OpsComm_Icon_Share_png'"
                self.BuyText = string.format("%s(%d/%d)", LSTR(1470011), self:GetCashBackProgress(ActivityData))
                self.BuyTagVisible = false
                self.BuyPriceText = LSTR(1470016)
                self.BuyPriceVisible = false
                self.DiscountMoneyVisible = false
                
            elseif self.ShareBuyData.Status == ProtoCS.Game.Activity.enStatus.CodeInputed then
                --未购买-优惠
                self.BuyActionVisible = true
                self.ShareOrStrategyText = LSTR(1470013)
                self.ShareOrStrategyIcon = "PaperSprite'/Game/UI/Atlas/Ops/OpsComm/Frames/UI_OpsComm_Icon_Strategy_png.UI_OpsComm_Icon_Strategy_png'"
                self.BuyText = LSTR(1470010)
                self.BuyTagVisible = false
                self.BuyPriceText = UIBinderSetTextFormatForMoney:GetText(ShareBuyNodeCfg.Params[2])
                self.BuyPriceVisible = true
                self.DiscountMoneyVisible = false
            elseif self.ShareBuyData.Status == ProtoCS.Game.Activity.enStatus.DiscountPayed then
                --已购买-优惠
                self.BuyActionVisible = false
            end

            self.VideoPlayerPath = ShareBuyNodeCfg.StrParam
            self.DiscountedText = ShareBuyNodeCfg.Params[2]
        end

    end
 
end

function OpsDesertFirePanelVM:GetShareBuyStatus()
    if self.ShareBuyData then
        return self.ShareBuyData.Status
    end

    return ProtoCS.Game.Activity.enStatus.None
end

function OpsDesertFirePanelVM:GetCashBackProgress(ActivityData)
    local TotalNum = 0
    local FinishNum = 0
    local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode)
    if NodeList then
        for _, Node in ipairs(NodeList) do
            local NodeID  = Node.Head.NodeID
            local Extra = Node.Extra
            local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode and TotalNum < ActivityNode.Target then
                TotalNum = ActivityNode.Target or 0
                if Extra and Extra.Progress then
					FinishNum = Extra.Progress.Value or 0
				end
            end
        end
    end

    return FinishNum, TotalNum

end

function OpsDesertFirePanelVM:UpdatePlayState()
	if self:BPlayChecked() then
		self.PlayState = EToggleButtonState.Unchecked
	else
		self.PlayState = EToggleButtonState.Checked
	end
end

function OpsDesertFirePanelVM:BPlayChecked()
	return self.PlayState == EToggleButtonState.Checked
end

function OpsDesertFirePanelVM:UpdateSoundState()
	if self:BSoundChecked() then
		self.SoundState = EToggleButtonState.Unchecked
	else
		self.SoundState = EToggleButtonState.Checked
	end
end

function OpsDesertFirePanelVM:BSoundChecked()
	return self.SoundState == EToggleButtonState.Checked
end


return OpsDesertFirePanelVM