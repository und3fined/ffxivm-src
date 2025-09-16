--[[
Author: luojiewen_ds luojiewen@dasheng.tv
Date: 2024-08-05 04:41:22
LastEditors: luojiewen_ds luojiewen@dasheng.tv
LastEditTime: 2024-08-08 19:28:57
FilePath: \Script\Game\Adventure\AdventureDetailVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local USaveMgr = _G.UE.USaveMgr

local ProtoCommon = require("Protocol/ProtoCommon")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")

local ProfModelCfg = require("TableCfg/ProfModelCfg")
local QuestHelper = require("Game/Quest/QuestHelper")
local ProfUtil = require("Game/Profession/ProfUtil")
local ProtoCS = require("Protocol/ProtoCS")

---@class NpcDialogPlayVM : UIViewModel
local AdventureDetailVM = LuaClass(UIViewModel)

---Ctor
function AdventureDetailVM:Ctor()
    self.JobName = ""
    self.DetailText = ""
    self.AdventureJobText1 = ""
    self.AdventureJobText2 = ""
    self.LogoPath = ""
    self.NowJobIcon = ""
    self.NextJobIcon = ""
    self.PreviewText = ""
    self.bIsShowNowJobIcon = true
    self.bIsShowNextJobIcon = true
    self.bIsArrowShow = true
    self.bIsPreviewTextShow = true
    self.ButtonText = ""
    self.RoleImagePath = ""
    self.AdventureJobBg1 = ""
    self.AdventureJobBg2 = ""
    self.Specialization = nil
end

--两个系统都在用，所以只能传ProfID或者从外部组
function AdventureDetailVM:OnSelectJobChange(Prof)
    if Prof == nil then return end
    self.Prof = Prof	
	local Cfg = RoleInitCfg:FindCfgByKey(Prof)
    local PicCfg = ProfModelCfg:FindCfgByKey(Prof)
	if nil == Cfg or nil == PicCfg then return end
	if Cfg.IsVersionOpen == 0 then return end
    --职业名称
    self.JobName = Cfg.ProfName or ""
    --职业简介
    self.DetailText = Cfg.ProfDesc or ""
    --职业类型1
    local ProfPVETag = Cfg.ProfPVETag
    self.AdventureJobText1 = Cfg.ProfPVETag[2] or ""
    self.AdventureJobText2 = Cfg.ProfPVETag[1] or ""
    --创角图标
    self.LogoPath = RoleInitCfg:FindRoleInitProfIconSimple5nd(Prof) or ""
    self.RoleImagePath = PicCfg.RoleIconPath or ""
    --显示本职业icon
    self.NowJobIcon = Cfg.ProfIcon
    --判断是否有特职
    if Cfg.AdvancedProf and Cfg.AdvancedProf ~= 0 then
        self.bIsArrowShow = true
        self.bIsShowNextJobIcon = true        
	    local AdvancedCfg = RoleInitCfg:FindCfgByKey(Cfg.AdvancedProf)
        if AdvancedCfg and next(AdvancedCfg) then
            self.NextJobIcon = AdvancedCfg.ProfIcon
        end
    else
        self.bIsArrowShow = false
        self.bIsShowNextJobIcon = false
    end

    local Class = RoleInitCfg:FindProfClass(Prof)
    if Class == ProtoCommon.class_type.CLASS_TYPE_TANK then
        self.AdventureJobBg1 = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_JoB_Img_BtnBlue.UI_Adventure_JoB_Img_BtnBlue'"
        self.AdventureJobBg2 = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_JoB_Img_BtnBlue.UI_Adventure_JoB_Img_BtnBlue'"
    elseif Class == ProtoCommon.class_type.CLASS_TYPE_CARPENTER or Class == ProtoCommon.class_type.CLASS_TYPE_EARTHMESSENGER then
        self.AdventureJobBg1 = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_JoB_Img_BtnYellow.UI_Adventure_JoB_Img_BtnYellow'"
        self.AdventureJobBg2 = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_JoB_Img_BtnYellow.UI_Adventure_JoB_Img_BtnYellow'"
    elseif Class == ProtoCommon.class_type.CLASS_TYPE_HEALTH then
        self.AdventureJobBg1 = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_JoB_Img_BtnGreen.UI_Adventure_JoB_Img_BtnGreen'"
        self.AdventureJobBg2 = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_JoB_Img_BtnGreen.UI_Adventure_JoB_Img_BtnGreen'"
    else
        self.AdventureJobBg1 = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_JoB_Img_BtnRed.UI_Adventure_JoB_Img_BtnRed'"
        self.AdventureJobBg2 = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_JoB_Img_BtnRed.UI_Adventure_JoB_Img_BtnRed'"
    end
    
    --生活职业
    local Specialization = Cfg.Specialization
    self.Specialization = Specialization
    if Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_PRODUCTION then
        self.ButtonText = LSTR(520027)
    elseif Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
        self.ButtonText = LSTR(520004)
    end

    local StartQuestCfg = _G.AdventureCareerMgr:GetCurProfChangeProfData(self.Prof, Cfg.AdvancedProf and Cfg.AdvancedProf ~= 0)
    local BaseQuestCfg = _G.AdventureCareerMgr:GetCurProfChangeProfData(self.Prof)
    if StartQuestCfg and next(StartQuestCfg) and StartQuestCfg.Level then
        self.bIsPreviewTextShow = true
        self.PreviewText = string.format(LSTR(1050229),tostring(StartQuestCfg.Level))
    else
        self.bIsPreviewTextShow = false
    end
    local IsCombat = ProfUtil.IsCombatProf(self.Prof)
    if BaseQuestCfg then
        local QuestState = QuestMgr:GetQuestStatus(BaseQuestCfg.StartQuestID)
        if (not QuestHelper.CheckCanActivate(BaseQuestCfg.StartQuestID) and QuestState == ProtoCS.CS_QUEST_STATUS.CS_QUEST_STATUS_NOT_STARTED) then
            if self.Specialization == ProtoCommon.specialization_type.SPECIALIZATION_TYPE_COMBAT then
                self.PreviewText = LSTR(1050227)
            else
                self.PreviewText = LSTR(1050228)
            end
        end
    else
        if not IsCombat then
            self.bIsPreviewTextShow = false
        end
    end
end

return AdventureDetailVM