local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local TimeUtil = require("Utils/TimeUtil")
local LSTR = _G.LSTR
local OpsActivityMgr = _G.OpsActivityMgr

local EToggleButtonState = _G.UE.EToggleButtonState
---@class OpsHalloweenGamePanelVM : UIViewModel
local OpsHalloweenGamePanelVM = LuaClass(UIViewModel)
---Ctor
function OpsHalloweenGamePanelVM:Ctor()
    self.PumpkinHeadText = nil
    self.TreasuryText = nil
    self.LittleDevilText = nil
    self.JackText = nil
    self.MagicCircleText = nil
    self.MagicBoxText = nil
    self.FindCookiesText = nil

    self.PumpkinHeadCompleteVisible = nil
	self.TreasuryCompleteVisible = nil
	self.LittleDevilCompleteVisible = nil
	self.JackCompleteVisible = nil
	self.MagicCircleCompleteVisible = nil

	self.MagicBoxLockText = nil
	self.MagicBoxCompleteVisible = nil

	self.FindCookiesLockText = nil
	self.FindCookiesCompleteVisible = nil

    self.MagicBoxBtnState = nil
    self.FindCookiesBtnState = nil
end

function OpsHalloweenGamePanelVM:Update(Params)
    self.PumpkinHeadText = LSTR(1560016)
    self.TreasuryText = LSTR(1560017)
    self.LittleDevilText = LSTR(1560018)
    self.JackText = LSTR(1560019)
    self.MagicCircleText = LSTR(1560020)
    self.MagicBoxText = LSTR(1560021)
    self.FindCookiesText = LSTR(1560022)

    local ChildrenActivitys = Params.ChildrenActivitys or {}
    for _, ChildrenActivity in ipairs(ChildrenActivitys) do
        local Detail = OpsActivityMgr.ActivityNodeMap[ChildrenActivity.ActivityID] or {}
        local NodeList = Detail.NodeList or {}
        local StartTime = OpsActivityMgr:GetActivityStartTime(ChildrenActivity)
        local Lock = StartTime > TimeUtil.GetServerLogicTime()
        for _, Node in ipairs(NodeList) do
            local NodeID  = Node.Head.NodeID
            local Finished = Node.Head.Finished
            local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
            if ActivityNode then
                if ActivityNode.NodeTitle == self.PumpkinHeadText then
                    self.PumpkinHeadNodeCfg = ActivityNode
                    self.PumpkinHeadCompleteVisible = Finished
                elseif ActivityNode.NodeTitle == self.TreasuryText then
                    self.TreasuryNodeCfg = ActivityNode
                    self.TreasuryCompleteVisible = Finished
                elseif ActivityNode.NodeTitle == self.LittleDevilText then
                    self.LittleDevilNodeCfg = ActivityNode
                    self.LittleDevilCompleteVisible = Finished
                elseif ActivityNode.NodeTitle == self.JackText then
                    self.JackNodeCfg = ActivityNode
                    self.JackCompleteVisible = Finished
                elseif ActivityNode.NodeTitle == self.MagicCircleText then
                    self.MagicCircleNodeCfg = ActivityNode
                    self.MagicCircleCompleteVisible = Finished
                elseif ActivityNode.NodeTitle == self.MagicBoxText then
                    self.MagicBoxNodeCfg = ActivityNode
                    if Lock == true then
                        self.MagicBoxLockText = self:GetActivityStartTimeText(ChildrenActivity)
                        self.MagicBoxBtnState = EToggleButtonState.Unchecked
                    else
                        self.FindCookiesLockText = ""
                        self.MagicBoxBtnState = EToggleButtonState.Checked
                    end
                    self.MagicBoxCompleteVisible = Finished
                elseif ActivityNode.NodeTitle == self.FindCookiesText then
                    self.FindCookiesNodeCfg = ActivityNode
                    if Lock == true then
                        self.FindCookiesLockText = self:GetActivityStartTimeText(ChildrenActivity)
                        self.FindCookiesBtnState = EToggleButtonState.Unchecked
                    else
                        self.FindCookiesLockText = ""
                        self.FindCookiesBtnState = EToggleButtonState.Checked
                    end
                    self.FindCookiesCompleteVisible = Finished
                end
            end
        end
    end

    self:UpdateHalloweenGameRedDot()

end

function OpsHalloweenGamePanelVM:GetActivityStartTimeText(Activity)
    local ActivityTime = Activity.ChinaActivityTime
	if ActivityTime == nil then
		return 0
	end
    local StartTime = ActivityTime.StartTime
	local year, month, day, hour, min, sec = StartTime:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	
	local TimeTable = {year = year, month = month, day = day, hour = hour, min = min, sec = sec}
    return string.format(LSTR(1560023), os.date("%Y/%m/%d", os.time(TimeTable)))
end

function OpsHalloweenGamePanelVM:UpdateHalloweenGameRedDot()
    
end


return OpsHalloweenGamePanelVM