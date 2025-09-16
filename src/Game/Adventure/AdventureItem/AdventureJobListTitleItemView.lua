---
--- Author: Administrator
--- DateTime: 2025-03-07 20:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local LevelExpCfg = require("TableCfg/LevelExpCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local FUNCTION_TYPE = ProtoCommon.function_type
local AdventureCareerMgr = require("Game/Adventure/AdventureCareerMgr")
local AdventureProfCareerItemVM = require("Game/Adventure/ItemVM/AdventureProfCareerItemVM")
local ProtoCS = require("Protocol/ProtoCS")
local QUEST_STATUS =  ProtoCS.CS_QUEST_STATUS

---@class AdventureJobListTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgTaskIcon UFImage
---@field PanelListItem UFCanvasPanel
---@field TextLv UFTextBlock
---@field TextName UFTextBlock
---@field TextTips UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AdventureJobListTitleItemView = LuaClass(UIView, true)

local ProfFunctionIcon = {
	[FUNCTION_TYPE.FUNCTION_TYPE_GUARD] = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_Job_Img_TitleBgBlue.UI_Adventure_Job_Img_TitleBgBlue'",
	[FUNCTION_TYPE.FUNCTION_TYPE_ATTACK] = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_Job_Img_TitleBgRed.UI_Adventure_Job_Img_TitleBgRed'",
	[FUNCTION_TYPE.FUNCTION_TYPE_RECOVER] = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_Job_Img_TitleBgGreen.UI_Adventure_Job_Img_TitleBgGreen'",
	[FUNCTION_TYPE.FUNCTION_TYPE_GATHER] = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_Job_Img_TitleBgYellow.UI_Adventure_Job_Img_TitleBgYellow'",
	[FUNCTION_TYPE.FUNCTION_TYPE_PRODUCTION] = "Texture2D'/Game/UI/Texture/Adventure/UI_Adventure_Job_Img_TitleBgYellow.UI_Adventure_Job_Img_TitleBgYellow'",
}

function AdventureJobListTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgTaskIcon = nil
	--self.PanelListItem = nil
	--self.TextLv = nil
	--self.TextName = nil
	--self.TextTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AdventureJobListTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureJobListTitleItemView:OnInit()

end

function AdventureJobListTitleItemView:OnDestroy()

end

function AdventureJobListTitleItemView:OnShow()

end

function AdventureJobListTitleItemView:UpdateProfData(Data)
	local MaxLevel = LevelExpCfg:GetMaxLevel()
	self.TextName:SetText(Data.Name or "")
	self.TextLv:SetText(string.format(_G.LSTR(520002), Data.ProfLevel or 1))
	local AdvProf = RoleInitCfg:FindProfAdvanceProf(Data.Prof) or 0	
	UIUtil.ImageSetBrushFromAssetPath(self.ImgBG, ProfFunctionIcon[Data.ProfFunType])
	
	local ProfIcon = string.format("Texture2D'/Game/UI/Texture/InfoTips/Job/UI_InfoTips_Icon_JobUnlock_%s.UI_InfoTips_Icon_JobUnlock_%s'", Data.ProfAssetAbbr, Data.ProfAssetAbbr)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgTaskIcon, ProfIcon)
	self.TextTips:SetVisibility(_G.UE.ESlateVisibility.HitTestInvisible)
	if Data.IsBaseProf and AdvProf ~= 0 then
		self.TextTips:SetText(string.format(_G.LSTR(520016), RoleInitCfg:FindRoleInitProfName(AdvProf)))
	else
		local TaskList = AdventureCareerMgr:GetAdventureCareerTaskDataByProf(Data)
		local IsAllDone = true

		for i, v in ipairs(TaskList) do
			local CurTaskDetail = AdventureCareerMgr:GetTaskDetailData(v.ChapterID)
			if CurTaskDetail.Status ~= QUEST_STATUS.CS_QUEST_STATUS_FINISHED then
				IsAllDone = false
				break
			end
		end

		if IsAllDone then
			self.TextTips:SetText(_G.LSTR(520068))
		else
			self.TextTips:SetText(_G.LSTR(520028))
		end
	end
end

return AdventureJobListTitleItemView