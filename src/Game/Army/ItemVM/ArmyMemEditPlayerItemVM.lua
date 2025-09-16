---
--- Author: daniel
--- DateTime: 2023-03-15 16:22
--- Description:TreeView ChildItem
---
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local ArmyDefine = require("Game/Army/ArmyDefine")
local ProtoCommon = require("Protocol/ProtoCommon")

---@class ArmyMemEditPlayerItemVM : UIViewModel
---@field ImgPlayerIcon1 string @Icon
---@field Player1Name string @成员1名称
---@field ImgPlayerIcon2 string @Icon2
---@field Player2Name sting @成员2名称
---@field bPlayer2Item boolean @成员2是否显示
---@field MemberData any @成员数据
---@field Type number @类型
local ArmyMemEditPlayerItemVM = LuaClass(UIViewModel)

function ArmyMemEditPlayerItemVM:Ctor()
    self.ImgPlayerIcon1 = nil
    self.Player1Name = nil
    self.ImgPlayerIcon2 = nil
    self.Player2Name = nil
    self.bPlayer2Item = nil
    self.bSetting1 = nil
    self.bSetting2 = nil
    self.MemberData = nil
    -- self.Player1Opacity = 1
    -- self.Player2Opacity = 1
    self.Type = ArmyDefine.One
end

function ArmyMemEditPlayerItemVM:RefreshChildVM(Data, bLeader, Length)
    self.MemberData = Data
    local RoleIDs = {}
    for _, Member in ipairs(Data) do
        table.insert(RoleIDs, Member.RoleID)
    end
    RoleInfoMgr:QueryRoleSimples(RoleIDs, function()
        for i, RoleID in ipairs(RoleIDs) do
            local Role = RoleInfoMgr:FindRoleVM(RoleID, true)
            self[string.format("Player%dName", i)] = Role.Name
            self[string.format("ImgPlayerIcon%d", i)] = Role.OnlineStatusIcon
            -- local Opacity = Role.IsOnline and 1 or 0.5
            -- self[string.format("Player%dOpacity", i)] = Opacity
        end
    end, nil, false)
    self.bSetting1 = not bLeader
    self.bSetting2 = not bLeader
    self.bPlayer2Item = Length == ArmyDefine.PartCount
end



function ArmyMemEditPlayerItemVM:AdapterOnGetCanBeSelected()
    return false
end

function ArmyMemEditPlayerItemVM:AdapterOnGetWidgetIndex()
    return 1
end

return ArmyMemEditPlayerItemVM