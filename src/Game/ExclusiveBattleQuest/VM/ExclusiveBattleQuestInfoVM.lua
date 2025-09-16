local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local UIBindableList = require("UI/UIBindableList")

local LSTR = _G.LSTR

---@class ExclusiveBattleQuestInfoVM : UIViewModel
local ExclusiveBattleQuestInfoVM = LuaClass(UIViewModel)

---Ctor
function ExclusiveBattleQuestInfoVM:Ctor()
	self.QuestName = nil
    self.Progress = 0
    self.MaxProgress = 0
    self.SliderPercent = 0
    self.IsFold = false
end

function ExclusiveBattleQuestInfoVM:UpdateVM(Data)
    self.QuestName = Data.QuestName
    self.Progress = Data.Progress
    self.MaxProgress = Data.MaxProgress
    if Data.MaxProgress ~= 0 then
        self.SliderPercent = Data.Progress / Data.MaxProgress
    end
end

function ExclusiveBattleQuestInfoVM:SetIsFold(IsFold)
    self.IsFold = IsFold
end

function ExclusiveBattleQuestInfoVM:GetIsFold()
    return self.IsFold
end

function ExclusiveBattleQuestInfoVM:GetMaxProgress()
    return self.MaxProgress
end

return ExclusiveBattleQuestInfoVM