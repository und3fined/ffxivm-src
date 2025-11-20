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
    self.OldProgress = 0
    self.NewProgress = 0
    self.MaxProgress = 0
    self.IsFold = false
end

function ExclusiveBattleQuestInfoVM:UpdateVM(Data)
    self.QuestName = Data.QuestName
    self.MaxProgress = Data.MaxProgress
    self.OldProgress = self.NewProgress
    self.NewProgress = Data.Progress
end

function ExclusiveBattleQuestInfoVM:SetIsFold(IsFold)
    self.IsFold = IsFold
end

function ExclusiveBattleQuestInfoVM:GetIsFold()
    return self.IsFold
end

function ExclusiveBattleQuestInfoVM:GetOldProgress()
    return self.OldProgress
end

function ExclusiveBattleQuestInfoVM:GetNewProgress()
    return self.NewProgress
end

function ExclusiveBattleQuestInfoVM:GetMaxProgress()
    return self.MaxProgress
end

return ExclusiveBattleQuestInfoVM