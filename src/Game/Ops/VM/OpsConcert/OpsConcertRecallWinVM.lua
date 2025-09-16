local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local UIBindableList = require("UI/UIBindableList")
local OpsConcertPlayerItemVM = require("Game/Ops/VM/OpsConcert/OpsConcertPlayerItemVM")
local LSTR = _G.LSTR
---@class OpsConcertRecallWinVM : UIViewModel
local OpsConcertRecallWinVM = LuaClass(UIViewModel)
---Ctor
function OpsConcertRecallWinVM:Ctor()
    -- 绑定玩家列表
    self.BindPlayerVMList = UIBindableList.New(OpsConcertPlayerItemVM)
    self.ListIsEmpty = nil
    self.ListIsNotEmpty = nil
    self.BindPlayerListParams = nil
    self.ActivityID = nil
    self.GetInviteListNodeID = nil
end

function OpsConcertRecallWinVM:Update(Params)
    if not Params or not Params.BindPlayerList or #Params.BindPlayerList < 1 then
        self.ListIsEmpty = true
        self.ListIsNotEmpty = false
        return
    end
    self.ActivityID = Params.ActivityID
    self.GetInviteListNodeID = Params.GetInviteListNodeID
    self.ListIsEmpty = false
    self.ListIsNotEmpty = true
    self.BindPlayerListParams = self:GetBindPlayerListParams(Params.BindPlayerList)
    self.BindPlayerVMList:UpdateByValues(self.BindPlayerListParams)
end

function OpsConcertRecallWinVM:BindPlayerVMListWithText(Text)
    if not Text or #Text < 1 then
        return
    end
    local FilterParams = {}
    for _, v in ipairs(self.BindPlayerListParams) do
        local RoleVM = _G.RoleInfoMgr:FindRoleVM(v.RoleID, true)
        if RoleVM and string.find(RoleVM.Name, Text) then
            table.insert(FilterParams, v)
        end
    end
    self.BindPlayerVMList:UpdateByValues(FilterParams)
end

function OpsConcertRecallWinVM:ShowAllPlayer()
    self.BindPlayerVMList:UpdateByValues(self.BindPlayerListParams)
end

function OpsConcertRecallWinVM:UpdateBindPlayerVMList(RoleData)
    self.BindPlayerListParams = self:GetBindPlayerListParams(RoleData)
    self.BindPlayerVMList:UpdateByValues(self.BindPlayerListParams)
end

function OpsConcertRecallWinVM:GetBindPlayerListParams(RoleData)
    local BindPlayerListParams = {}
    if not RoleData or #RoleData < 1 then
        return BindPlayerListParams
    end
    for i = #RoleData, 1, -1 do
        local v = RoleData[i]
        local Param = {RoleID = v.RoleID, ProfID = v.ProfID, Level = v.Level}
        local RoleVM = _G.RoleInfoMgr:FindRoleVM(v.RoleID, true)
        if RoleVM and RoleVM.IsOnline then
            Param.Priority = i
        else
            Param.Priority = 0
        end
        table.insert(BindPlayerListParams, Param)
    end
    table.sort(BindPlayerListParams, function(Param1,Param2)
        return Param1.Priority > Param2.Priority
        end)
    return BindPlayerListParams
end

return OpsConcertRecallWinVM