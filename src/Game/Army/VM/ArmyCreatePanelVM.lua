---
--- Author: daniel
--- DateTime: 2023-03-09 16:15
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MajorUtil = require("Utils/MajorUtil")

local ArmyDefine = require("Game/Army/ArmyDefine")
local ConditionIconPath = ArmyDefine.ConditionIconPath

---@class ArmyCreatePanelVM : UIViewModel
---@field bSelectMain boolean @是否显示选择界面
---@field bEditInfo boolean @显示部队信息编辑界面
---@field Condition1Icon string @条件1Icon
---@field IsOutArmyTimeEnough string @退出公会时间条件
---@field bResetEidtInfo boolean @是否重置编辑信息
---@field RecruitSlogan string @招募标语
local ArmyCreatePanelVM = LuaClass(UIViewModel)

---Ctor
function ArmyCreatePanelVM:Ctor()
    self.bSelectMain = true
    self.bEditInfo = false
    self.Condition1Icon = nil
    self.IsOutArmyTimeEnough = nil
    self.bResetEidtInfo = false
    self.RecruitSlogan = nil
    self.CreateSucceed = nil
    self.IsGivePeition = false
    self.PetitionData = nil
end

function ArmyCreatePanelVM:OnInit()
    self.GrandID = nil
    self.CreateSucceed = false
end

function ArmyCreatePanelVM:OnReset()
    self.bSelectMain = true
    self.bEditInfo = false
    self.bResetEidtInfo = true
end

function ArmyCreatePanelVM:OnBegin()
end

function ArmyCreatePanelVM:OnEnd()
end

function ArmyCreatePanelVM:OnShutdown()
    self.GrandID = nil
end

--- 设置数据
---@param VM ViewModel @ArmySelectMainArmyPageVM
---@param ArmyID number @部队ID
---@param LastQuitTime number @离开时间
function ArmyCreatePanelVM:SetData(ArmyID, LastQuitTime)
    local NeedQuitTime = _G.ArmyMgr:GetArmyQuitCreateCD()
    local QuitTime = _G.TimeUtil.GetServerTime() - LastQuitTime - NeedQuitTime
    local bHavArmy = ArmyID > ArmyDefine.Zero
    local bOutArmyTime
    if LastQuitTime == ArmyDefine.Zero then
        bOutArmyTime = true
    else
        bOutArmyTime = QuitTime >= 0
    end
    self.bCreate = not bHavArmy and bOutArmyTime
    self:ShowCondition(bHavArmy, bOutArmyTime)
end

--- 显示条件
function ArmyCreatePanelVM:ShowCondition(IsHavArmy, IsOutArmyTime)
    if IsHavArmy then
        self.Condition1Icon = ConditionIconPath.FalseIcon
    else
        self.Condition1Icon = ConditionIconPath.TrueIcon
    end
    if not IsOutArmyTime then
        self.IsOutArmyTimeEnough = false
    else
        self.IsOutArmyTimeEnough = true
    end
end

function ArmyCreatePanelVM:GetIsOutArmyTimeEnough()
    return self.IsOutArmyTimeEnough
end

--- 选择部队大国防联军
function ArmyCreatePanelVM:SelectedUnionID(ID)
    if self.GrandID ~= ID then
        self.GrandID = ID
    end
    self:SetIsOpenEdit(true)
end


--- 获取缓存的部队大国防联军ID
function ArmyCreatePanelVM:GetSelectedUnionID()
    return self.GrandID
end

function ArmyCreatePanelVM:SendGroupPeitionEdit(Name, ShortName, BadgeData, GrandID)
    local GroupPetition =
    {
        GrandCompanyType = GrandID or self.GrandID,
        Name = Name or self.Name,
        Alias = ShortName or self.Alias,
        Emblem = BadgeData or self.Emblem,
    }
    _G.ArmyMgr:SendGroupPeitionEdit(GroupPetition)
end

function ArmyCreatePanelVM:SetIsOpenEdit(IsOpen)
    self.bSelectMain = not IsOpen
    self.bEditInfo = IsOpen
end

function ArmyCreatePanelVM:SetRecruitSlogan(Text)
    self.RecruitSlogan = Text
end

function ArmyCreatePanelVM:ClaerRecruitSlogan()
    self.RecruitSlogan = nil
end

function ArmyCreatePanelVM:GetbSelectMain()
    return self.bSelectMain
end

function ArmyCreatePanelVM:GetbEditInfo()
    return self.bEditInfo
end

function ArmyCreatePanelVM:ArmyCreateAnimPlay(CallBack)
    self.CreateCallBack = CallBack
    self.CreateSucceed = true
end

function ArmyCreatePanelVM:GetCreateCallBack()
    return self.CreateCallBack
end

function ArmyCreatePanelVM:ArmySetCreateSucceed(CreateSucceed)
    self.CreateSucceed = CreateSucceed
end

function ArmyCreatePanelVM:GetIsGivePeition()
    return self.IsGivePeition
end

function ArmyCreatePanelVM:GetPetitionData()
    return self.PetitionData
end

function ArmyCreatePanelVM:UpdataPeitionData(PetitionData)
    if PetitionData and PetitionData.GroupPetition then
        self.GroupPetition = PetitionData.GroupPetition
        self.IsGivePeition = true
        if self.GroupPetition then
            self:SelectedUnionID(self.GroupPetition.GrandCompanyType)
            self.Name = self.GroupPetition.Name
            self.Alias = self.GroupPetition.Alias
            self.Emblem = self.GroupPetition.Emblem
        end
        if PetitionData.Signs then
            self.PetitionData = PetitionData 
        else
            if self.PetitionData == nil then
                self.PetitionData = {
                    Signs = {},
                }
            end
            ---处理非全量数据
            self.PetitionData.GroupPetition = PetitionData.GroupPetition
        end
    else
        self.IsGivePeition = false
        self.PetitionData = nil
    end
end

function ArmyCreatePanelVM:SetBadgeData(BadgeData)
    self.Emblem = table.clone(BadgeData)
end

return ArmyCreatePanelVM
