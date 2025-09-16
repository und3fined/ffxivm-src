--
-- Author: ZhengJianChuan
-- Date: 2024-03-07 15:21
-- Description:
--


local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local WardrobeDefine = require("Game/Wardrobe/WardrobeDefine")
local WardrobeMgr = require("Game/Wardrobe/WardrobeMgr")
local WardrobeUtil = require("Game/Wardrobe/WardrobeUtil")
local MajorUtil = require("Utils/MajorUtil")
local ItemUtil = require("Utils/ItemUtil")
local UIUtil = require("Utils/UIUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local ProfMgr = require("Game/Profession/ProfMgr")
local ProtoRes = require("Protocol/ProtoRes")
local GlobalCfg = require("TableCfg/GlobalCfg")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local ClosetCharismCfg = require("TableCfg/ClosetCharismCfg")
local ClosetGlobalCfg = require("TableCfg/ClosetGlobalCfg")
local UIBindableList = require("UI/UIBindableList")
local WardrobeCollectItemVM = require("Game/Wardrobe/VM/Item/WardrobeCollectItemVM")
local BagSlotVM = require("Game/NewBag/VM/BagSlotVM")
local ItemVM = require("Game/Item/ItemVM")
local LSTR

---@class WardrobeAppearancePanelVM : UIViewModel
local WardrobeAppearancePanelVM = LuaClass(UIViewModel)

---Ctor
function WardrobeAppearancePanelVM:Ctor()
    self.BoxList = UIBindableList.New(WardrobeCollectItemVM)
    self.RewardList = UIBindableList.New(BagSlotVM)
	self.CurCharismNum = ""
	self.TotalCharismNum = ""
	self.CharismPercent = 0
    self.TipsPanelVisible = false
    self.ProgressBarEff = false
    self.TreasureEff = false
end

function WardrobeAppearancePanelVM:OnInit()
end

function WardrobeAppearancePanelVM:OnBegin()
	LSTR = _G.LSTR
end

function WardrobeAppearancePanelVM:OnEnd()
end

function WardrobeAppearancePanelVM:OnShutdown()
end

function WardrobeAppearancePanelVM:UpdateBoxList()
    
    local ProfList = {}
    local List =  WardrobeDefine.ProfInfo
    local RealProfIDList = {}
    local NoneConverProfIDList = {}

    for key, value in pairs(List) do
        local Cfg = RoleInitCfg:FindCfgByKey(key)
        if Cfg ~= nil and  Cfg.IsVersionOpen == 1 then
            local ProfID = Cfg.AdvancedProf ~= 0 and Cfg.AdvancedProf or key
            local ProfLevel = MajorUtil.GetMajorLevelByProf(Cfg.AdvancedProf)
            if ProfLevel == nil then
                ProfID = key
            end

            if Cfg.AdvancedProf ~= 0 and MajorUtil.GetMajorLevelByProf(Cfg.AdvancedProf) == nil then
                table.insert(NoneConverProfIDList, Cfg.AdvancedProf)
            end

            if not table.contain(RealProfIDList, ProfID) and not table.contain(NoneConverProfIDList, ProfID) then
                table.insert(RealProfIDList, ProfID)
            end
        end
    end

    local ProfHighValueCfg = ClosetGlobalCfg:FindCfgByKey(ProtoRes.ClosetParamCfgID.ClosetAppearanceHighLightNum)
    local ProfHighPercentage = ProfHighValueCfg.Value[1] or 0

    for index, v in ipairs(RealProfIDList) do
        if v > ProtoCommon.prof_type.PROF_TYPE_NULL then
            local ProfVM = {}
            local Cfg = RoleInitCfg:FindCfgByKey(v)
            local ProfLevel = MajorUtil.GetMajorLevelByProf(v)
            local IsUnlock = ProfLevel ~= nil
            local Num
            local TotalNum
            if not IsUnlock then
                Num = 0
                TotalNum = 1
            else
               Num = WardrobeMgr:GetUnlockAppearanceCollectNum(v, index == 1)
               TotalNum = WardrobeMgr:GetAppearanceCollectTotalNum(v)
            end
            local ProfHighValue = math.floor(ProfHighPercentage * TotalNum)
            ProfVM.IsNormal = true
            ProfVM.IsLight = false
            ProfVM.ProfID = v
            ProfVM.JobIcon = WardrobeUtil.GetCollectIconByProfID(v)
            ProfVM.SmallJobIcon = ProfUtil.Prof2Icon(v)
            ProfVM.JobName = Cfg.ProfName
            ProfVM.IsUnlock = IsUnlock
            ProfVM.TotalNum = IsUnlock and string.format("%d/%d", Num, TotalNum) or _G.LSTR(1080058)
            if IsUnlock then
                ProfVM.ActiveVisible = Num >= ProfHighValue 
            else
                ProfVM.ActiveVisible = false
            end
            ProfVM.Num = Num
            table.insert(ProfList, ProfVM)
        end
    end

    table.sort(ProfList, function (a, b)
        if a.IsUnlock ~= b.IsUnlock then
            return a.IsUnlock
        end

        if a.Num ~= b.Num then
            return a.Num > b.Num 
        end

        return a.ProfID < b.ProfID 
    end)
    

    self.BoxList:UpdateByValues(ProfList)
end

function WardrobeAppearancePanelVM:UpdateBaseInfo()
    self.CurCharismNum = WardrobeMgr:GetCharismNum()
    if not WardrobeMgr:IsExceedCfgLevel() then
        self.TotalCharismNum = string.format("/%d", WardrobeMgr:GetCharismTotalNum())
        self.CharismPercent = self.CurCharismNum / WardrobeMgr:GetCharismTotalNum()
    else
        self.TotalCharismNum = ""
        self.CharismPercent = 1.0
    end
end


-- 更新奖励
function WardrobeAppearancePanelVM:UpdateRewardList(RewardID)
    local Cfg = ClosetCharismCfg:FindCfgByKey(RewardID)

    if Cfg == nil then
        return 
    end

    local DataList = {}
    for _, v in ipairs(Cfg.Rewards) do
        local ItemID = ItemUtil.GetItemIcon(v.ResID)
        if ItemID ~= 0 then
            local Data = ItemVM.New()
            Data.ResID = v.ResID
            local Item = ItemUtil.CreateItem(v.ResID, v.Num)
            Data:UpdateVM(Item, {HideItemLevel = true})
            table.insert(DataList, Data)
        end
    end

    self.RewardList:Update(DataList)

end

function WardrobeAppearancePanelVM:UpdateReward()
    self.ProgressBarEff = WardrobeMgr:GetCharismNum() >= WardrobeMgr:GetCharismTotalNum()
    if not WardrobeMgr:IsExceedCfgLevel() then
        self.TreasureEff = WardrobeMgr:GetCharismNum() >= WardrobeMgr:GetCharismTotalNum()
    else
        self.TreasureEff = false
    end
end

--要返回当前类
return WardrobeAppearancePanelVM