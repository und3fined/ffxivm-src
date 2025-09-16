local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ItemUtil = require("Utils/ItemUtil")
local UIBindableList = require("UI/UIBindableList")
local OpsActivityRewardItemVM = require("Game/Ops/VM/OpsActivityRewardItemVM")
local OpsCeremonyDefine = require("Game/Ops/View/OpsCeremony/OpsCeremonyDefine")
local ItemDefine = require("Game/Item/ItemDefine")
local LSTR = _G.LSTR

---@class OpsCeremonyMysteriousVisitorPanelVM : UIViewModel
local OpsCeremonyMysteriousVisitorPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsCeremonyMysteriousVisitorPanelVM:Ctor()
    self.TaskTitleText = nil
    self.TaskDescText = nil
    self.ButtonText = nil
    self.PenguinIconVisiable = nil
    self.TaskIcon = "PaperSprite'/Game/UI/Atlas/Ops/OpsCeremony/Frames/UI_OpsCeremony_Img_Penguin1_png.UI_OpsCeremony_Img_Penguin1_png'"
    self.RewardVMList = UIBindableList.New(OpsActivityRewardItemVM, {ItemSlotType = ItemDefine.ItemSlotType.Item74Slot})
    self.CompletedText = ""
    self.Info = nil
end

function OpsCeremonyMysteriousVisitorPanelVM:Update(Params)
    self.Info = Params.Info or ""
    local NodeID  = Params.Node.Head.NodeID
    local Extra = Params.Node.Extra
    local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    if ActivityNode then
        self.TaskTitleText = ActivityNode.NodeTitle
        self.TaskDescText = _G.OpsSeasonActivityMgr:GetTaskDesc(OpsCeremonyDefine.TaskIDDefine.MysteriousVisitorTask)
        self.TaskIsFinished = Extra.Progress.Value == 1 or Params.Node.Head.Finished
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

        self.GoToText = ActivityNode.JumpButton
        if self.TaskIsFinished then
            self.TaskIcon = "PaperSprite'/Game/UI/Atlas/Ops/OpsCeremony/Frames/UI_OpsCeremony_Img_Penguin2_png.UI_OpsCeremony_Img_Penguin2_png'"
            self.PenguinIconVisiable = true
            self.ButtonText = LSTR(1580010) --"点点试骑我"
             self.CompletedText = LSTR(1580011)
        else
            self.PenguinIconVisiable = false
            self.ButtonText = LSTR(1580009) --"前往"
             self.CompletedText = ""
        end
    end
end

return OpsCeremonyMysteriousVisitorPanelVM