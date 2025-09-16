local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ProtoRes = require("Protocol/ProtoRes")
local OpsVersionNoticeItemVM = require("Game/Ops/VM/OpsVersionNoticeItemVM")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType


---@class OpsVersionNoticeContentPanelVM : UIViewModel
local OpsVersionNoticeContentPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsVersionNoticeContentPanelVM:Ctor()
    self.TextTaskTitle = nil
    self.TextTaskDescribe = nil
    self.TextBtnGoto = nil
    self.BtnGotoVisiable = nil
    self.JumpType = nil
    self.JumpParam = nil
    self.JumpButton = nil
    self.ImgPoster = nil
    self.NoticeItemVMList = UIBindableList.New(OpsVersionNoticeItemVM)
end

function OpsVersionNoticeContentPanelVM:Update(Params)
    local Data = {}
    local NodeList = Params:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
    for _, Node in ipairs(NodeList) do
        local NodeCfg = ActivityNodeCfg:FindCfgByKey(Node.Head.NodeID)
        if NodeCfg then
            local ItemData = {NodeID = NodeCfg.NodeID, TextTaskTitle = NodeCfg.NodeTitle, TextTaskDescribe = NodeCfg.NodeDesc, JumpButton = NodeCfg.JumpButton,
                            JumpType = NodeCfg.JumpType, JumpParam = NodeCfg.JumpParam, ImgPoster = NodeCfg.StrParam}
            table.insert(Data, ItemData)
        end
    end
    self.NoticeItemVMList:UpdateByValues(Data)
end

function OpsVersionNoticeContentPanelVM:SetItemChecked(Index)
    local ItemData = self.NoticeItemVMList:Get(Index)
    if ItemData then
        self.TextTaskTitle = ItemData.TextTaskTitle
        self.TextTaskDescribe = ItemData.TextTaskDescribe
        self.ImgPoster = ItemData.ImgPoster
        self.JumpType = ItemData.JumpType
        self.JumpParam = ItemData.JumpParam
        self.JumpButton = ItemData.JumpButton
        self.NodeID = ItemData.NodeID

        if ItemData.JumpButton and ItemData.JumpButton ~= "" then
            self.BtnGotoVisiable = true
        else
            self.BtnGotoVisiable = false
        end
    end
end


return OpsVersionNoticeContentPanelVM