local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local ProtoCommon = require("Protocol/ProtoCommon")
--local MajorUtil = require("Utils/MajorUtil")

local LoginCreateRoleItemVM = require("Game/LoginCreate/LoginCreateRoleItemVM")
local LoginAvatarMgr = nil

---@class LoginCreateAvatarVM : UIViewModel
local LoginCreateAvatarVM = LuaClass(UIViewModel)


function LoginCreateAvatarVM:Ctor()
    LoginAvatarMgr = _G.LoginAvatarMgr
    self.ListRoleTableVM = nil
    self.bCreateNew = false
    self.RoleTableIndex = 1
end
-- 部分数据初始化
function LoginCreateAvatarVM:InitViewData()
   LoginAvatarMgr:SetSystemType(LoginAvatarMgr.FaceSystemType.Login)
   LoginAvatarMgr:ResetParam("PresetList", true)
   LoginAvatarMgr:ResetParam("PropertyCacheList", true)
   LoginAvatarMgr:ResetParam("CurFocusType", false)
    self.RoleTableIndex =LoginAvatarMgr:GetRoleListIndex() --上次选中列表
    --self.bCreateNew =LoginAvatarMgr:GetSelfCustomize() -- 是否包含自定义
    local AvatarFace = LoginAvatarMgr:GetPlayerAvatarFace()
    if table.size(AvatarFace) == 0 then
        self.bCreateNew = false
    else
        self.bCreateNew = true
    end
    self:SetRoleList()
end

-- 预设数据列表
function LoginCreateAvatarVM:SetRoleList()
    --local TotalNum = 6
    self.RoleTableIndex =LoginAvatarMgr:GetRoleListIndex() --上次选中列表
    local PresetList =LoginAvatarMgr:GetPresetIDList()
    local PresetIconList =LoginAvatarMgr:GetPresetIconList()
    if PresetList == nil or PresetIconList == nil then return end
    local ListSlotVMp = {}
    for Index, Value in ipairs(PresetList) do
        local RoleItemVM = LoginCreateRoleItemVM.New()
        local ItemData = {bCreate = false, DataIndex = Index, DataValue = Value, PresetIcon = PresetIconList[Index]}
        RoleItemVM:UpdateData(ItemData)
        ListSlotVMp[#ListSlotVMp + 1] = RoleItemVM
    end
    if self.bCreateNew == true then
        local RoleItemVM = LoginCreateRoleItemVM.New()
        local CreateData = {bCreate = true, DataIndex = #ListSlotVMp + 1, DataValue = 0}
        RoleItemVM:UpdateData(CreateData)
        ListSlotVMp[#ListSlotVMp + 1] = RoleItemVM
        if self.RoleTableIndex == 0 then
            self.RoleTableIndex = #ListSlotVMp
        end
    end
    self.ListRoleTableVM = ListSlotVMp
end

function LoginCreateAvatarVM:AddRoleList()
    self.RoleTableIndex =LoginAvatarMgr:GetRoleListIndex()
    local PresetList =LoginAvatarMgr:GetPresetIDList()
    if self.ListRoleTableVM == nil then 
        FLOG_WARNING("ListRoleTableVM is nil")
        return
    end
    local ListSlotVMp = table.clone(self.ListRoleTableVM)
    if ListSlotVMp ~= nil and PresetList ~= nil and table.size(ListSlotVMp) == table.size(PresetList) then
        local RoleItemVM = LoginCreateRoleItemVM.New()
        local CreateData = {bCreate = true, DataIndex = #ListSlotVMp + 1, DataValue = 0}
        RoleItemVM:UpdateData(CreateData)
        ListSlotVMp[#ListSlotVMp + 1] = RoleItemVM
        if self.RoleTableIndex == 0 then
            self.RoleTableIndex = #ListSlotVMp
        end
        self.ListRoleTableVM = ListSlotVMp
    elseif ListSlotVMp ~= nil then
        self.RoleTableIndex = #ListSlotVMp
    end
end

function LoginCreateAvatarVM:UpdateRoleTableSelected(Index)
    local ItemVM = self.ListRoleTableVM[Index]
    local PresetValue = ItemVM.DataValue
    local RoleIndex =LoginAvatarMgr:GetRoleListIndex()
    if PresetValue == 0 then
        -- 设置玩家自定义的捏脸数据
       LoginAvatarMgr:SetPlayerAvatarFace()
       LoginAvatarMgr:SetUseSelfCustomize(true)
    elseif RoleIndex ~= Index then
       LoginAvatarMgr:SetPresetByID(PresetValue)
       LoginAvatarMgr:SetUseSelfCustomize(false)
    end
    self.RoleTableIndex = Index
   LoginAvatarMgr:SetRoleListIndex(Index)
end

function LoginCreateAvatarVM:SetPlayerCreate(bNew)
    self.bCreateNew = bNew
end
return LoginCreateAvatarVM