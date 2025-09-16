---
--- Author: loiafeng
--- DateTime: 2025-01-17 15:29
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MsgTipsID = require("Define/MsgTipsID")
local MainPanelConfig = require("Game/Main/MainPanelConfig")
local EntranceType = MainPanelConfig.LifeProfEntranceType

local UIViewMgr = _G.UIViewMgr ---@type UIViewMgr
local UIViewID = _G.UIViewID

---@class SkillEntranceBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnEntrance UFButton
---@field ImgIcon UFImage
---@field ImgSlot UFImage
---@field Panel UFCanvasPanel
---@field ButtonIndex int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local SkillEntranceBtnView = LuaClass(UIView, true)

function SkillEntranceBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnEntrance = nil
	--self.ImgIcon = nil
	--self.ImgSlot = nil
	--self.Panel = nil
	--self.ButtonIndex = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function SkillEntranceBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

local EntranceConfig = {
	[EntranceType.CraftingLog] = {
		Icon = "PaperSprite'/Game/UI/Atlas/Main2nd/Frames/UI_Main2nd_Btn_CraftingLog_png.UI_Main2nd_Btn_CraftingLog_png'",
		OnPressed = function()
			UIViewMgr:ShowView(UIViewID.CraftingLog)
		end,
	},
	[EntranceType.GatheringLog] = {
		Icon = "PaperSprite'/Game/UI/Atlas/Main2nd/Frames/UI_Main2nd_Btn_GatheringLog_png.UI_Main2nd_Btn_GatheringLog_png'",
		OnPressed = function()
			UIViewMgr:ShowView(UIViewID.GatheringLogMainPanelView)
		end,
	},
	[EntranceType.FishNotes] = {
		Icon = "PaperSprite'/Game/UI/Atlas/Main2nd/Frames/UI_Main2nd_Btn_Fishing_png.UI_Main2nd_Btn_Fishing_png'",
		OnPressed = function()
			UIViewMgr:ShowView(UIViewID.FishInghole)
		end,
	},
	[EntranceType.LeveQuest] = {
		Icon = "PaperSprite'/Game/UI/Atlas/Main2nd/Frames/UI_Main2nd_Btn_LeveQuest_png.UI_Main2nd_Btn_LeveQuest_png'",
		OnPressed = function()
			UIViewMgr:ShowView(UIViewID.LeveQuestMainPanel)
		end,
	},
	[EntranceType.Collection] = {
		Icon = "PaperSprite'/Game/UI/Atlas/Main2nd/Frames/UI_Main2nd_Btn_Collectables_png.UI_Main2nd_Btn_Collectables_png'",
		OnPressed = function()
			UIViewMgr:ShowView(UIViewID.CollectablesMainPanelView)
		end,
	},
}

function SkillEntranceBtnView:OnInit()
	self.EntranceType = nil
end

function SkillEntranceBtnView:OnDestroy()

end

function SkillEntranceBtnView:OnShow()
	local ItemData = (self.Params or {}).Data
	if nil == ItemData then
		_G.FLOG_ERROR("SkillEntranceBtnView:OnShow(): ItemData is nil")
		return
	end

	local Type = ItemData.Type
	if nil == Type or nil == EntranceConfig[Type] then
		_G.FLOG_ERROR("SkillEntranceBtnView:OnShow(): Invalid entrance type " .. tostring(Type))
		return
	end

	self.EntranceType = Type
	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, EntranceConfig[self.EntranceType].Icon)
	UIUtil.SetIsVisible(self.ImgIcon, true)
end

function SkillEntranceBtnView:OnHide()

end

function SkillEntranceBtnView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnEntrance, self.OnClicked)
end

function SkillEntranceBtnView:OnRegisterGameEvent()

end

function SkillEntranceBtnView:OnRegisterBinder()

end

function SkillEntranceBtnView:OnClicked()
	if _G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith() then
        MsgTipsUtil.ShowTipsByID(MsgTipsID.CannotFightSkillPanel)
        return 
    end
	local Cfg = EntranceConfig[self.EntranceType]
	if Cfg and Cfg.OnPressed then
		Cfg.OnPressed()
	else
		_G.FLOG_ERROR("SkillEntranceBtnView:OnClicked(): Invalid entrance type " .. tostring(self.EntranceType))
	end
end

return SkillEntranceBtnView