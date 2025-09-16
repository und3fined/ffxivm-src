--Author:Easy
--DateTime: 2023/1/10

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ChocoboUiIconCfg = require("TableCfg/ChocoboUiIconCfg")
local UIBindableList = require("UI/UIBindableList")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")
local ChocoboRentCfg  = require("TableCfg/ChocoboRentCfg")
local ChocoboBreedInfoItemVM = require("Game/Chocobo/Mating/VM/ChocoboBreedInfoItemVM")

local ChocoboMgr = nil

local ChocoboBreedPanelVM = LuaClass(UIViewModel)
function ChocoboBreedPanelVM:Ctor()
	ChocoboMgr = _G.ChocoboMgr
	self.ChildLevel = nil
	self.ChildColor1Name = nil
	self.ChildColor2Name = nil
	self.ChildColor1 = ChocoboDefine.DEFAULT_HEAD_COLOR
	self.ChildColor2 = ChocoboDefine.DEFAULT_HEAD_COLOR
	self.TextPrice = ""
	
	self.ForbidLevel = nil
	self.ForbidLevelVisible = false
	self.ReasonVisible = false
	self.BtnBreedEnabled = false
	self.ForbidVisible = false
	self.PriceVisible = false
	self.TextReason = ''
	self.TextReason1 = ''
	self.TextReason2 = ''

	self.ChildDetailList = UIBindableList.New(ChocoboBreedInfoItemVM)
	self.AttrIconPathCfg = {
		[ProtoCommon.ChocoboAttrType.AttrTypeMaxSpeed] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.ATTR_MAX_SPEED),
		[ProtoCommon.ChocoboAttrType.AttrTypeSprintSpeed] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.ATTR_SPRINT_SPEED),
		[ProtoCommon.ChocoboAttrType.AttrTypeSkillStrenth] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.ATTR_SKILL_STRENGTH),
		[ProtoCommon.ChocoboAttrType.AttrTypeAcceleration] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.ATTR_ACCELERATION),
		[ProtoCommon.ChocoboAttrType.AttrTypeStamina] = ChocoboUiIconCfg:FindPathByKey(ProtoRes.CHOCOBO_UI_ICON_TYPE.ATTR_STAMINA),
	}
end

function ChocoboBreedPanelVM:OnInit()
end

function ChocoboBreedPanelVM:OnBegin()
end

function ChocoboBreedPanelVM:Clear()
end

function ChocoboBreedPanelVM:OnEnd()
end

function ChocoboBreedPanelVM:OnShutdown()

end

function ChocoboBreedPanelVM:UpdatePanel(FemaleData,MaleData)
	if FemaleData == nil or MaleData == nil then return end

	-- 子鸟的血统等级 = 双亲种血统等级低的 + 1
	local BaseGeneration = math.min(FemaleData.Generation, MaleData.Generation)
	self.Generation = math.min(BaseGeneration + 1, ChocoboDefine.GENERATION_MAX)
	self.ChildLevel = tostring(self.Generation)

	local CoupleCost = 0
	local RentData = ChocoboRentCfg:FindCfgByKey(self.Generation)
    if RentData ~= nil then
		self.TextPrice = tostring(RentData.CoupleCost)
		CoupleCost = RentData.CoupleCost
	end
	
	self.ChildColor1Name = FemaleData.ColorName
	self.ChildColor1 = FemaleData.Color

	self.ChildColor2Name = MaleData.ColorName
	self.ChildColor2 = MaleData.Color

	local AttrList = {}
	local function CalculateGeneStats(ParentGene, Index)
		local GeneData = ParentGene.Gene or {}
		local RedVal = GeneData.GeneRed and GeneData.GeneRed[Index] or 0
		local BlueVal = GeneData.GeneBlue and GeneData.GeneBlue[Index] or 0

		return {
			Min = math.min(RedVal, BlueVal),
			Max = math.min(math.max(RedVal, BlueVal), ChocoboMgr.GeneMaxStarNum)
		}
	end

	for i = 1, 5 do
		local TempData = {
			AttrIconPath = self.AttrIconPathCfg[i],
			GeneRed = CalculateGeneStats(FemaleData, i),
			GeneBlue = CalculateGeneStats(MaleData, i)
		}
		table.insert(AttrList, TempData)
	end
	self.ChildDetailList:UpdateByValues(AttrList)

	local JdCoinCount = _G.ScoreMgr:GetScoreValueByID(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE)
	local ForbidLevelCount = _G.ChocoboMainVM:GetChocoboCount(self.Generation)

	self.PriceVisible = false
	self.BtnBreedEnabled = false
	self.ReasonVisible = false
	self.ForbidVisible = false

	-- 条件判断优化（按优先级排序）
	if _G.ChocoboMainVM:IsMatingStatus() then
		self.ReasonVisible = true
		self.TextReason = _G.LSTR(420148) -- 配种进行中优先判断
	elseif JdCoinCount < CoupleCost then
		self.ReasonVisible = true
		self.TextReason = _G.LSTR(420146) -- 金币不足
	elseif ForbidLevelCount >= _G.ChocoboMgr.GenerationLimit then
		self.ForbidVisible = true
		self.ForbidLevelVisible = true
		self.ForbidLevel = tostring(self.Generation)
		self.TextReason1 = _G.LSTR(420038) --血统代数
		self.TextReason2 = _G.LSTR(420046) -- 已满
	else
		self.PriceVisible = true
		self.BtnBreedEnabled = true
	end
end

return ChocoboBreedPanelVM
