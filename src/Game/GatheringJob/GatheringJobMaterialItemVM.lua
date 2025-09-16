--[[
Author: v_vvxinchen v_vvxinchen@tencent.com
Date: 2023-12-08 09:26:58
LastEditors: v_vvxinchen v_vvxinchen@tencent.com
LastEditTime: 2023-12-18 12:24:27
FilePath: \Client\Source\Script\Game\GatheringJob\GatheringJobMaterialItemVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local GatherNoteCfg = require("TableCfg/GatherNoteCfg")
local ColorUtil = require("Utils/ColorUtil")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIViewID = require("Define/UIViewID")
local MajorUtil = require("Utils/MajorUtil")
local UIUtil = require("Utils/UIUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local CommonUtil = require("Utils/CommonUtil")

---@class GatheringJobMaterialItemVM : UIViewModel

local GatheringJobMaterialItemVM = LuaClass(UIViewModel)

function GatheringJobMaterialItemVM:Ctor()
    self.bShowImgCollection = false
    self.GatherItemIconPath = ""
    self.SetItemColor = nil

    self.bShowIconNQUpRate = false
    self.bShowIconHQUpRate = false

    self.TextNQ = "-"
    self.TextHQ = "-"

    self.TextItemName = ""
    self.TextItemLevel = ""
    self.TextNumber = ""

	self.bShowTextNumber = true

    self.BeginSimpleGather = false
    self.EndSimpleGather = false
    self.BreakSimpleGather = false
	self.IsCollection = false

	self.bSkillRsp = false
end

function GatheringJobMaterialItemVM:OnInit()
    local BindProperty = self:FindBindableProperty("BreakSimpleGather")
    if BindProperty then
        BindProperty:SetNoCheckValueChange(true)
    end

	self:SetNoCheckValueChange("bSkillRsp", true)
end

function GatheringJobMaterialItemVM:OnBegin()
end

function GatheringJobMaterialItemVM:OnEnd()
end

function GatheringJobMaterialItemVM:OnShutdown()
end

function GatheringJobMaterialItemVM:UpdateVM( FunctionItem )
    self.FunctionItem = FunctionItem
	local ItemNoteInfo = FunctionItem.FuncParams.ItemNoteInfo

	if ItemNoteInfo.ItemNum and ItemNoteInfo.ItemNum ~= 0 then
		self.TextNumber = ItemNoteInfo.ItemNum
	else
		self.TextNumber = 1
	end

	self.IsTreasure = false

	local NoteCfg = GatherNoteCfg:FindCfgByItemID(FunctionItem.ResID)
	local GatherItemCfg = ItemCfg:FindCfgByKey(FunctionItem.ResID)
	if NoteCfg and GatherItemCfg then
        self.SetItemColor = GatherItemCfg.ItemColor
		self.bShowTextNumber = true

        if NoteCfg.IsCollection == 1 then
			local HQRichText = RichTextUtil.GetTexture(_G.CollectionMgr.CollectionIconPath, 30, 30, -6)
			local str= string.format('%s%s', ItemCfg:GetItemName(FunctionItem.ResID),HQRichText)
			self.TextItemName =  str 
		else
		end
		self.TextItemName = CommonUtil.GetTextFromStringWithSpecialCharacter(GatherItemCfg.ItemName)
        self.TextItemLevel = string.format(_G.LSTR(160049), NoteCfg.GatheringGrade) --160049"等级%d"
        
		local CurAcquisitionAttr = _G.UE.UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_gathering)
		local CurInsightAttr = _G.UE.UMajorUtil.GetAttrValue(ProtoCommon.attr_type.attr_perception)
		if CurAcquisitionAttr >= NoteCfg.MinAcquisition and CurInsightAttr >= NoteCfg.MinInsight then
			if NoteCfg.IsCollection == 1 then
				self.TextNQ = "100%"
			elseif ItemNoteInfo.CommonGatherRate > 0 then
				self.TextNQ = string.format("%d%%", math.floor(ItemNoteInfo.CommonGatherRate / 100))
			else
				self.TextNQ = "-%"
			end

			if ItemNoteInfo.HQGatherRate > 0 and  NoteCfg.IsCollection == 0  then
				self.TextHQ = string.format("%d%%", math.floor(ItemNoteInfo.HQGatherRate / 100))
			else
				self.TextHQ = "-%"
			end
		else
			self.TextNQ = "-%"
			self.TextHQ = "-%"
		end
        
		self.bShowImgCollection = ItemNoteInfo.FirstGather
        self.bShowIconNQUpRate = ItemNoteInfo.CommonSkillUp and NoteCfg.IsCollection == 0
		self.bShowIconHQUpRate = ItemNoteInfo.HQSkillUp and NoteCfg.IsCollection == 0
        self.GatherItemIconPath = UIUtil.GetIconPath(GatherItemCfg.IconID)
		self.IsCollection = NoteCfg.IsCollection == 1
	else	--寻宝图产出
		if GatherItemCfg then
			self.bShowTextNumber = false
			self.SetItemColor = GatherItemCfg.ItemColor
	
			self.TextItemName = CommonUtil.GetTextFromStringWithSpecialCharacter(GatherItemCfg.ItemName)
			self.TextItemLevel = string.format(_G.LSTR(160049), GatherItemCfg.ItemLevel) --160049"等级%d"
			
			self.TextNQ = string.format("%d%%", math.floor(ItemNoteInfo.CommonGatherRate / 100))
			self.TextHQ = "-%"
			
			self.bShowImgCollection = ItemNoteInfo.FirstGather
			self.bShowIconNQUpRate = ItemNoteInfo.CommonSkillUp
			self.bShowIconHQUpRate = ItemNoteInfo.HQSkillUp
			self.GatherItemIconPath = UIUtil.GetIconPath(GatherItemCfg.IconID)
			self.IsCollection = false
			
			self.IsTreasure = true
		end
    end
end

return GatheringJobMaterialItemVM