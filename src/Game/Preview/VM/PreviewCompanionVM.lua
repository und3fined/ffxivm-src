local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local CompanionCfg = require ("TableCfg/CompanionCfg")
local CompanionMgr = require("Game/Companion/CompanionMgr")

---@class PreviewCompanionVM : UIViewModel
local PreviewCompanionVM = LuaClass(UIViewModel)

function PreviewCompanionVM:Ctor()
    self.SelectedCompanionID = nil
    self.MergeCompanionIndex = nil
    self.CompanionList = {}  --有多个宠物的组数据(比如光之战偶)
    self.CompanionMoveType = nil

    self.CompanionName = ""
    self.CompanionExpository = ""
    self.HasShow = false
    self.CanBattle = false
    -- self.IsShowCompanionCry = false --是否显示点击模型时弹的cry面板tips(策划预览不需要此功能)

    self.IsShowing = false
    self.IsAttacking = false
    self.IsMoving = false
    self.IsMergeCompanion = false
    self.AutoPlayInteract = false
end

function PreviewCompanionVM:ClearData()
    self:Ctor()
end

function PreviewCompanionVM:UpdateCompanionInfo(CompanionId)
    local Cfg = CompanionCfg:FindCfgByKey(CompanionId)
    self.IsMergeCompanion = Cfg.MergeGroupID and Cfg.MergeGroupID ~= 0 or false
    self.SelectedCompanionID = CompanionId
    self.CompanionName = Cfg.Name

    if self.IsMergeCompanion then
        local MergeGroupCfg = CompanionMgr:GetCompanionExternalCfg(CompanionId)
        self.MergeCompanionIndex = math.random(#MergeGroupCfg.CompanionID)
        self.SelectedCompanionID = MergeGroupCfg.CompanionID[self.MergeCompanionIndex]
        self.CompanionList = MergeGroupCfg.CompanionID
        self.CompanionName = MergeGroupCfg.Name --名字得用组的宠物名字
    end

    if self.SelectedCompanionID ~= nil then
        self:ShowCompanionInfo(self.SelectedCompanionID)
    end
end

function PreviewCompanionVM:ShowCompanionInfo(CompanionId)
    local Cfg = CompanionCfg:FindCfgByKey(CompanionId)
    if Cfg == nil then
        return
    end

    self.CompanionMoveType = Cfg.MoveType
    self.CanBattle = Cfg.CanBattle

    --说明文本显示(Expository + Cry)
    self.CompanionExpository = Cfg.Expository
    if self.CompanionExpository == nil or #self.CompanionExpository < 36 then
        self.CompanionExpository = "                                          "
    end
    local CompanionCry =  Cfg.Cry
    if CompanionCry ~= nil and string.find(CompanionCry, "<br>") then
        CompanionCry = string.gsub(CompanionCry, "<br>", "\n")
    end
    self.CompanionExpository = table.concat({self.CompanionExpository, CompanionCry},"\n\n")
end

function PreviewCompanionVM:ResetAnimaionState()
    self:SetShowState(false)
    self:SetAttackState(false)
    self:SetMoveState(false)
    self:SetAutoPlayInteract(false)
end

function PreviewCompanionVM:SetShowState(State)
    self.IsShowing = State
end

function PreviewCompanionVM:GetShowState()
    return self.IsShowing
end

function PreviewCompanionVM:SetAttackState(State)
    self.IsAttacking = State
end

function PreviewCompanionVM:GetAttackState()
    return self.IsAttacking
end

function PreviewCompanionVM:SetMoveState(State)
    self.IsMoving = State
end

function PreviewCompanionVM:GetMoveState()
    return self.IsMoving
end

function PreviewCompanionVM:SetAutoPlayInteract(State)
    self.AutoPlayInteract = State
end

function PreviewCompanionVM:GetAutoPlayInteract()
    return self.AutoPlayInteract
end

return PreviewCompanionVM