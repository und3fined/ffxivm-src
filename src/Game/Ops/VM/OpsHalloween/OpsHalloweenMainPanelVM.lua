local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")

local LSTR = _G.LSTR
local OpsSeasonActivityMgr = _G.OpsSeasonActivityMgr
local RedDotMgr = _G.RedDotMgr

local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local VideoShowID = 2501220199

---@class OpsHalloweenMainPanelVM : UIViewModel
local OpsHalloweenMainPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsHalloweenMainPanelVM:Ctor()
    self.TitleText = nil
    self.SubTitleText = nil

    self.WonderfulBallText = nil
	self.MakeupBallText = nil
	self.HauntedManorText = nil
    self.SeasonShopText = nil

    self.WonderfulBallFinish = nil
    self.MakeupBallFinish = nil
    self.LockHauntedManor = nil
    self.LockMakeupBall = nil
    self.EFF1Visible = nil
    self.PanelFootprintVisible = nil
end

function OpsHalloweenMainPanelVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    self.TitleText = Activity.Title
    self.SubTitleText = Activity.SubTitle

    self.WonderfulBallText = LSTR(1560001)
	self.MakeupBallText = LSTR(1560004)
	self.HauntedManorText = LSTR(1560003)
    self.SeasonShopText = LSTR(1560002)
    
    self.WonderfulBallFinish = false
    self.MakeupBallFinish = false
    self.LockHauntedManor = true
    self.LockMakeupBall = true

    local NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeStatistic)
    if NodeList then
        for _, Node in ipairs(NodeList) do
            local NodeID  = Node.Head.NodeID
            local Finished = Node.Head.Finished
		    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                if ActivityNode.NodeTitle == self.WonderfulBallText then
                    self.WonderfulBallNode = Node
                    self.WonderfulBallFinish = Finished
                    self.LockMakeupBall = self.WonderfulBallFinish == false
                elseif ActivityNode.NodeTitle == self.MakeupBallText then
                    self.MakeupBallNode = Node
                    --self.MakeupBallFinish = Finished
                    if Finished then
                        self.MakeupBallText = LSTR(1560006)
                    end
                elseif ActivityNode.NodeTitle == self.HauntedManorText then
                    self.HauntedManorNode = Node
                    self.LockHauntedManor = not (Finished)
                end
            end
	    end
    end

    NodeList = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
    if NodeList then
        for _, Node in ipairs(NodeList) do
            local NodeID  = Node.Head.NodeID
		    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                if ActivityNode.NodeTitle == self.MakeupBallText then
                    self.MakeupBallNode = Node
                elseif ActivityNode.NodeTitle == self.SeasonShopText then
                    self.SeasonShopNode = Node
                elseif NodeID == VideoShowID then
                    self.VideoShowNodeInfo = ActivityNode
                end
            end
	    end
    end

    self.EFF1Visible = self.LockHauntedManor == true or self.LockMakeupBall == true
    self.PanelFootprintVisible = not self.EFF1Visible
end

function OpsHalloweenMainPanelVM:GetSeasonShopInfo()
    if self.SeasonShopNode then
		local NodeID = self.SeasonShopNode.Head.NodeID
		local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
        if ActivityNode then
            return {JumpType = ActivityNode.JumpType,  JumpParam = ActivityNode.JumpParam}
        end
	end
end


function OpsHalloweenMainPanelVM:ClickHauntedManorNode()
    if self.HauntedManorNode then
        OpsSeasonActivityMgr:RecordRedDotClicked(self.HauntedManorNode.Head.NodeID)
    end

end

function OpsHalloweenMainPanelVM:ClickMakeupBallNode()
    if self.MakeupBallNode then
        OpsSeasonActivityMgr:RecordRedDotClicked(self.MakeupBallNode.Head.NodeID)
    end

end

function OpsHalloweenMainPanelVM:ClickWonderfulBallNode()
    if self.WonderfulBallNode then
        OpsSeasonActivityMgr:RecordRedDotClicked(self.WonderfulBallNode.Head.NodeID)
    end

end

function OpsHalloweenMainPanelVM:GetBtnRedName(RedName)
    return OpsSeasonActivityMgr:GetRedDotName(RedName)

end


return OpsHalloweenMainPanelVM