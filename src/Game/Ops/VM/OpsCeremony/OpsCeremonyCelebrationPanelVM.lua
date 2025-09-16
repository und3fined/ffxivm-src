local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local UIBindableList = require("UI/UIBindableList")
local OpsActivityRewardItemVM = require("Game/Ops/VM/OpsActivityRewardItemVM")
local OpsCeremonyPartiesItemVM = require("Game/Ops/VM/OpsCeremony/OpsCeremonyPartiesItemVM")
local OpsCeremonyDefine = require("Game/Ops/View/OpsCeremony/OpsCeremonyDefine")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")
local ItemDefine = require("Game/Item/ItemDefine")
local LSTR = _G.LSTR
local NodeIDDefine = OpsCeremonyDefine.NodeIDDefine
---@class OpsCeremonyCelebrationPanelVM : UIViewModel
local OpsCeremonyCelebrationPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsCeremonyCelebrationPanelVM:Ctor()
    self.TaskTabSelected = nil
    self.TaskDescribeText = nil
    self.RewardText = nil
    self.RewardVMList =  UIBindableList.New(OpsActivityRewardItemVM, {ItemSlotType = ItemDefine.ItemSlotType.Item96Slot})

    self.PartiesTabSelected = nil
    self.PartiesDescribeText = nil
    self.PartiesTimeText = nil
    self.PartiesVMList =  UIBindableList.New(OpsCeremonyPartiesItemVM)

    self.ButtonText = nil

    self.TaskButtonText = nil

    self.PartiesButtonText = nil
    self.TaskIsFinished = false
    self.PartiesIsLock = true
    self.TimeText = nil
    self.RedDotName = nil
    self.RedDotStyle = nil
    self.Info = nil
end

--- 传入的活动节点是TaskNode:表示首环任务是否完成
function OpsCeremonyCelebrationPanelVM:Update(Params)
    self.ButtonText = LSTR(1580009) ---"前往"
    self.Info = Params.Info or ""
    --- 庆典任务需要检查两个活动节点的状态，分别是叙事任务完成情况和首环任务完成情况
    --- 叙事任务状态与任务页签的状态挂钩
    --- 首环任务与派对页签的状态挂钩
    local NodeID  = Params.Node.Head.NodeID
    self.RedDotName = _G.OpsSeasonActivityMgr:GetRedDotName(tostring(OpsCeremonyDefine.ActivityID).."/"..tostring(NodeID) .. "/".. tostring(NodeIDDefine.Celebration2))
    self.RedDotStyle = RedDotDefine.RedDotStyle.NormalStyle
    local Extra = Params.Node.Extra
    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    -- 设置默认选择
    if ActivityNode then
        self.TimeText = _G.OpsSeasonActivityMgr:GetActivityTime(OpsCeremonyDefine.CelebrationActivityID)
        self.TaskIsFinished = Extra.Progress.Value == 1 or Params.Node.Head.Finished
        self.PartiesIsLock = Params.PartiesNode.Extra.Progress.Value == 0
        if not self.PartiesIsLock then
            self:SetPartiesTabSelected()
        else
            self:SetTaskTabSelected()
        end

        self.TaskDescribeText = ActivityNode.NodeDesc
        local ItemList = {}
        for _, v in ipairs(ActivityNode.Rewards) do
            if v.ItemID and v.ItemID ~= 0 then
		        local Item = {
                    DropID = v.ItemID,
                    DropNum = v.Num,
                    IconReceivedVisible = self.TaskIsFinished
                }
		        table.insert(ItemList, Item)
            end
        end
        self.RewardVMList:UpdateByValues(ItemList)
        self.RewardText = LSTR(1580008) ---"报酬"
        --- 设置派对页签的内容
        local PartiesNode = ActivityNodeCfg:FindCfgByKey(OpsCeremonyDefine.NodeIDDefine.Celebration2)
        if PartiesNode then
            self.PartiesDescribeText = PartiesNode.NodeDesc
            if Params.ActivityEndStamp and Params.ActivityEndStamp - TimeUtil.GetServerLogicTime() <= 7199 then
                self.PartiesTimeText = ""
            else
                self.PartiesTimeText = string.format(LSTR(1580023), _G.OpsSeasonActivityMgr:GetNextActivityOpenTime(2, 1)) ---下一场派对%s开始
            end
            self.PartiesVMList:UpdateByValues(self.GetPartiesList())
        end
    end
end

function OpsCeremonyCelebrationPanelVM:SetTaskTabSelected()
    self.TaskTabSelected = true
    self.PartiesTabSelected = false
    if self.TaskIsFinished then
        self.ButtonText = LSTR(1580011) ---"已完成"
    else
        self.ButtonText = LSTR(1580009) ---"前往"
    end
end

function OpsCeremonyCelebrationPanelVM:SetPartiesTabSelected()
    self.TaskTabSelected = false
    self.PartiesTabSelected = true
    self.ButtonText = LSTR(1580025) ---"前往派对"
    _G.OpsSeasonActivityMgr:RecordRedDotClicked(OpsCeremonyDefine.NodeIDDefine.Celebration2)
end
function OpsCeremonyCelebrationPanelVM:GetPartiesList()
    local Params = {}
    local Params1 = {
        TitleText =  LSTR(1580016), ---"一起跳舞"
        DescribeText =  LSTR(1580019), ---"做和NPC相同的情感动作"
        Icon = "Texture2D'/Game/UI/Texture/Ops/OpsCeremony/UI_OpsCeremony_Img_Parties_Dance.UI_OpsCeremony_Img_Parties_Dance'"
    }
    table.insert(Params, Params1)
    local Params2 = {
        TitleText =  LSTR(1580017), ---"趣味拼图"
        DescribeText =  LSTR(1580020), ---"进行企鹅表情拼图"
        Icon = "Texture2D'/Game/UI/Texture/Ops/OpsCeremony/UI_OpsCeremony_Img_Parties_Puzzle.UI_OpsCeremony_Img_Parties_Puzzle'"
    }
    table.insert(Params, Params2)
    local Params3 = {
        TitleText =  LSTR(1580018), ---"抢企鹅币"
        DescribeText =  LSTR(1580021), ---"采集企鹅币攒回家路费"
        Icon = "Texture2D'/Game/UI/Texture/Ops/OpsCeremony/UI_OpsCeremony_Img_Parties_GrabCoins.UI_OpsCeremony_Img_Parties_GrabCoins'"
    }
    table.insert(Params, Params3)
    return Params
end
return OpsCeremonyCelebrationPanelVM