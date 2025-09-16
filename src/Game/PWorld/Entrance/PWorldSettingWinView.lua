---
--- Author: v_hggzhang
--- DateTime: 2023-09-20 11:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PWorldSettingWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BG Comm2FrameMView
---@field BtnCancel CommBtnLView
---@field BtnInfor CommInforBtnView
---@field BtnOK CommBtnLView
---@field HorizontalBtn UFHorizontalBox
---@field SceneModeSlot2 CommSceneModeSlotView
---@field SceneModeSlot3 CommSceneModeSlotView
---@field SceneModeSlot4 CommSceneModeSlotView
---@field TextAll1 UFTextBlock
---@field TextAll2 UFTextBlock
---@field TextAll3 UFTextBlock
---@field TextAllFilter1 UFTextBlock
---@field TextAllFilter2 UFTextBlock
---@field TextAllFilter3 UFTextBlock
---@field TextAllLock UFTextBlock
---@field TextChallenge1 UFTextBlock
---@field TextChallenge2 UFTextBlock
---@field TextChallenge3 UFTextBlock
---@field TextChallengeFilter1 UFTextBlock
---@field TextChallengeFilter2 UFTextBlock
---@field TextChallengeFilter3 UFTextBlock
---@field TextChallengeLock UFTextBlock
---@field TextRemove1 UFTextBlock
---@field TextRemove2 UFTextBlock
---@field TextRemove3 UFTextBlock
---@field TextRemoveFilter1 UFTextBlock
---@field TextRemoveFilter2 UFTextBlock
---@field TextRemoveFilter3 UFTextBlock
---@field TextRemoveLock UFTextBlock
---@field TextRoom1 UFTextBlock
---@field TextRoom2 UFTextBlock
---@field TextRoom3 UFTextBlock
---@field TextRoomFilter1 UFTextBlock
---@field TextRoomFilter2 UFTextBlock
---@field TextRoomFilter3 UFTextBlock
---@field TextRoomLock UFTextBlock
---@field ToggleBtnAll UToggleButton
---@field ToggleBtnChallenge UToggleButton
---@field ToggleBtnRemove UToggleButton
---@field ToggleBtnRoom UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldSettingWinView = LuaClass(UIView, true)

function PWorldSettingWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BG = nil
	--self.BtnCancel = nil
	--self.BtnInfor = nil
	--self.BtnOK = nil
	--self.HorizontalBtn = nil
	--self.SceneModeSlot2 = nil
	--self.SceneModeSlot3 = nil
	--self.SceneModeSlot4 = nil
	--self.TextAll1 = nil
	--self.TextAll2 = nil
	--self.TextAll3 = nil
	--self.TextAllFilter1 = nil
	--self.TextAllFilter2 = nil
	--self.TextAllFilter3 = nil
	--self.TextAllLock = nil
	--self.TextChallenge1 = nil
	--self.TextChallenge2 = nil
	--self.TextChallenge3 = nil
	--self.TextChallengeFilter1 = nil
	--self.TextChallengeFilter2 = nil
	--self.TextChallengeFilter3 = nil
	--self.TextChallengeLock = nil
	--self.TextRemove1 = nil
	--self.TextRemove2 = nil
	--self.TextRemove3 = nil
	--self.TextRemoveFilter1 = nil
	--self.TextRemoveFilter2 = nil
	--self.TextRemoveFilter3 = nil
	--self.TextRemoveLock = nil
	--self.TextRoom1 = nil
	--self.TextRoom2 = nil
	--self.TextRoom3 = nil
	--self.TextRoomFilter1 = nil
	--self.TextRoomFilter2 = nil
	--self.TextRoomFilter3 = nil
	--self.TextRoomLock = nil
	--self.ToggleBtnAll = nil
	--self.ToggleBtnChallenge = nil
	--self.ToggleBtnRemove = nil
	--self.ToggleBtnRoom = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldSettingWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BG)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnInfor)
	self:AddSubView(self.BtnOK)
	self:AddSubView(self.SceneModeSlot2)
	self:AddSubView(self.SceneModeSlot3)
	self:AddSubView(self.SceneModeSlot4)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldSettingWinView:OnInit()
	-- 
	UIUtil.SetIsVisible(self.BG.ButtonClose, false)
end

function PWorldSettingWinView:OnDestroy()

end

function PWorldSettingWinView:OnShow()

end

function PWorldSettingWinView:OnHide()

end

function PWorldSettingWinView:OnRegisterUIEvent()

end

function PWorldSettingWinView:OnRegisterGameEvent()

end

function PWorldSettingWinView:OnRegisterBinder()

end

return PWorldSettingWinView