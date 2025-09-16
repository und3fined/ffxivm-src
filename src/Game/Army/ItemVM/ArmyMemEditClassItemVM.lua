--@author daniel
--@date 2023-03-16

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ArmyDefine = require("Game/Army/ArmyDefine")
local DefineCategorys = ArmyDefine.DefineCategorys
local GlobalCfgType = ArmyDefine.GlobalCfgType
local GroupGlobalCfg = require(("TableCfg/GroupGlobalCfg"))
local GroupMemberCategoryCfg = require("TableCfg/GroupMemberCategoryCfg")
local ProtoCommon = require("Protocol/ProtoCommon")

---@class ArmyMemEditClassItemVM : UIViewModel
---@field Name string @Name
---@field Num string @ShowIndex
---@field Icon string @Icon path
---@field bIcon boolean @是否显示Icon
---@field bBtnPreview boolean @是否显示预览按钮
---@field bBtnEdit boolean @修改
---@field bBtnSetting boolean @是否显示设置
---@field bBtnDelete boolean @是否显示删除按钮
---@field bBtnUp boolean @是否显示上移按钮
---@field bBtnDown boolean @是否显示下移按钮
---@field bBtnClose boolean @是否隐藏按钮
---@field bEmpty boolean @是否是空的
local ArmyMemEditClassItemVM = LuaClass(UIViewModel)

function ArmyMemEditClassItemVM:Ctor()
    self.Name = nil
    self.Num = nil
    self.Icon = nil
    self.bIcon = nil
    self.bBtnPreview = nil
    self.bBtnEdit = nil
    self.bBtnSetting = nil
    self.bBtnDelete = false
    self.bBtnUp = nil
    self.bBtnDown = nil
    self.bBtnClose = nil
    self.bEmpty = nil
end

function ArmyMemEditClassItemVM:OnInit()
    self.ID = -1
    self.ShowIndex = -1
end

function ArmyMemEditClassItemVM:OnBegin()
end

function ArmyMemEditClassItemVM:OnEnd()
end

function ArmyMemEditClassItemVM:OnShutdown()
    self.ID = nil
    self.ShowIndex = nil
end

function ArmyMemEditClassItemVM:IsEqualVM(Value)
    return nil ~= Value and Value.ID == self.ID
end

---UpdateVM
---@param Value table
function ArmyMemEditClassItemVM:RefreshVM(CategoryData, Length)
    local One = ArmyDefine.One
    local Zero = ArmyDefine.Zero
    self.bShow = false
    local ID = CategoryData.ID
	self.ID = ID
    local ShoIndex = CategoryData.ShowIndex or 0
    self.ShowIndex = ShoIndex
    self.Num = ShoIndex + 1
    self.Name = CategoryData.Name
    if string.isnilorempty(self.Name) then
        local CfgCategoryName
        if self.ID == ArmyDefine.LeaderCID then
            CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMajorCategoryName)
            self.Name = CfgCategoryName or DefineCategorys.LeaderName
        else
            CfgCategoryName = GroupGlobalCfg:GetStrValueByType(GlobalCfgType.DefaultMinorCategoryName)
            self.Name = CfgCategoryName or DefineCategorys.MemName
        end
    end
    self:SetIconID(CategoryData.IconID)
    local bNotEmpty = ID >= 0
    self.bEmpty = not bNotEmpty
    if bNotEmpty then
        self.bBtnEdit = true
        self.bBtnPreview = true
        self.bBtnSetting = true
        if ID == One or ID == ProtoCommon.group_category_type.GROUP_CATEGORY_TYPE_MEMBER then
            self.bBtnDelete = false
        else
            self.bBtnDelete = Length > ArmyDefine.CEditIdx and ID ~= One
        end
        self.bBtnUp = ShoIndex ~= One and ShoIndex ~= Zero
        ---最后一级不能下调
        self.bBtnDown = ShoIndex < Length - 1 and ShoIndex ~= Zero
    else
        self.bBtnPreview = false
        self.bBtnEdit = false
        self.bBtnSetting = false
        self.bBtnDelete = false
        self.bBtnUp = false
        self.bBtnDown = false
        self.bBtnClose = false
    end
end

function ArmyMemEditClassItemVM:SetIconID(IconID)
    self.IconID = IconID
    if IconID ~= nil and IconID > 0 then
        self.bIcon = true
        self.Icon = GroupMemberCategoryCfg:GetCategoryIconByID(IconID)
    else
        self.bIcon = false
    end
end

return ArmyMemEditClassItemVM