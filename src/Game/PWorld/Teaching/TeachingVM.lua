local LuaClass = require("Core/LuaClass")
local MajorUtil = require("Utils/MajorUtil")
local UIViewModel = require("UI/UIViewModel")
local ProfMgr = require("Game/Profession/ProfMgr")
local UIBindableList = require("UI/UIBindableList")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local PWorldTeachingCatalogItemViewVM = require("Game/Pworld/Teaching/Item/PWorldTeachingCatalogItemViewVM")

local LSTR = _G.LSTR
local TeachingMgr = _G.TeachingMgr

local TeachingVM = LuaClass(UIViewModel)

function TeachingVM:Ctor()
    self.ProfID = 0
	self.Level = 0
    self.JobType = ""
    self.IconPath = ""
    self.TableViewCatalogVMList = UIBindableList.New(PWorldTeachingCatalogItemViewVM)
    self.ShowBtnQuit = _G.UE.ESlateVisibility.Hidden

    self.MaxLevel = 0
end

function TeachingVM:OnBegin()

end

function TeachingVM:UpdateMajorInfo()
    local MajorProfID = MajorUtil.GetMajorAttributeComponent().ProfID
    self.ProfID = MajorProfID
    self.Level = MajorUtil.GetTrueMajorLevel()
end

function TeachingVM:UpdateCatalogItems(Index)
    -- 玩家职业信息
	local MajorProfID = MajorUtil.GetMajorAttributeComponent().ProfID
	local MajorClass = RoleInitCfg:FindProfClass(MajorProfID)

    -- 玩家职业种类
    local JobTypeInfo = TeachingMgr:GetJobTypeInfoFromProfClass(MajorClass)
    if JobTypeInfo then
        self.JobType = JobTypeInfo.Name
        self.IconPath = JobTypeInfo.Icon
    end

    -- 玩家职业类型和等级
    self.ProfID = MajorProfID
    self.Level = MajorUtil.GetTrueMajorLevel()

    -- 玩家所有战斗职业中最大等级
	self.MaxLevel = TeachingMgr:GetMaxLevelCombat()

    -- 找当前职业的教学配置
	local TeachTable = TeachingMgr:GetTableByProfAndDiff(MajorClass, Index)
    if TeachTable == nil then
        return
    end

    -- 创建CatalogList
    self.TableViewCatalogVMList:Clear()
    for _,Item in ipairs(TeachTable) do
        Item.MaxLevel = self.MaxLevel
        Item.ProfLevel = self.Level
    end
    self.TableViewCatalogVMList:UpdateByValues(TeachTable)

    self.ShowBtnQuit = TeachingMgr.IsTeachScene and _G.UE.ESlateVisibility.Visible or _G.UE.ESlateVisibility.Hidden
end

return TeachingVM