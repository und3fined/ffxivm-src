local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")


---@class ArmyMemberClassInfoEditItemVM : UIViewModel
local ArmyMemberClassInfoEditItemVM = LuaClass(UIViewModel)
---Ctor
function ArmyMemberClassInfoEditItemVM:Ctor()
    self.PermssionData = nil
    self.Icon = nil
    self.Type = nil
    self.Desc = nil
    self.bChecked = nil
    self.bCanEdit = true
end

function ArmyMemberClassInfoEditItemVM:UpdateVM(Value)
    --local PermisstionDataTemp = {Icon = PermisstionData.Icon, Desc = PermisstionData.Desc, Type = PermisstionData.Type, Class = PermisstionData.Class, Important = PermisstionData.Important}
    self.Type = Value.Type
    self.Icon = Value.Icon
    self.bChecked = Value.bChecked
    self.PermssionData = Value.PermssionData
    local PmsText = self.PermssionData.Desc
    ---重要权限现在不需要加*号强调了
    --local Punctuation
    -- if self.PermssionData.Important == ArmyDefine.One then
    --     Punctuation = "*"
    -- else
    --     Punctuation = ""
    -- end
    self.Desc = PmsText

end

function ArmyMemberClassInfoEditItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.Type == self.Type
end


--要返回当前类
return ArmyMemberClassInfoEditItemVM