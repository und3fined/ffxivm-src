---
--- Author: alex
--- DateTime: 2024-09-10 20:38
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local AdventureItemItemVM = require("Game/Adventure/ItemVM/AdventureItemItemVM")
local UIBindableList = require("UI/UIBindableList")

---@see AdventureCompletionItem02View

---@class GoldSauserChallengeNoteItemVM : UIViewModel
---@field ID number
---@field ContentText string
---@field DescriptionText string
---@field IsDescriptionVisible bool
---@field MainIconPath string
---@field IsUnFinishVisible boolean
---@field UnFinishText string
---@field OnClickGet function
---@field OnClickGo function
local GoldSauserChallengeNoteItemVM = LuaClass(UIViewModel)

function GoldSauserChallengeNoteItemVM:Ctor()
    self.ID = nil
    self.ContentText = nil
    self.DescriptionText = nil
    --self.IsDescriptionVisible = nil
    self.MainIconPath = nil
    self.ToggleBtnState = nil
    self.DisabledText = nil
    self.OnClickGet = nil
    self.OnClickGo = nil
    self.RewardList = UIBindableList.New(AdventureItemItemVM)
end

function GoldSauserChallengeNoteItemVM:IsEqualVM(_)
	return false
end

function GoldSauserChallengeNoteItemVM:UpdateVM(tParams)
    self.ID = tParams.ID
    self.ToggleBtnState = tParams.ToggleBtnState
    self.DisabledText = tParams.DisabledText or ""
    self.ContentText = tParams.ContentText or ""
    self.DescriptionText = tParams.DescriptionText or ""
    --self.IsDescriptionVisible = tParams.IsDescriptionVisible
    self.MainIconPath = tParams.MainIconPath or ""
    self.OnClickGet = tParams.OnClickGet
    self.OnClickGo = tParams.OnClickGo
    --self.IsNewRedVisible = tParams.IsNew
    self:SetRewardData(tParams.RewardList)
end

function GoldSauserChallengeNoteItemVM:SetRewardData(RewardList)
    self.RewardList:UpdateByValues(RewardList)
end

return GoldSauserChallengeNoteItemVM


