
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local FishNotesBaitVM = require("Game/FishNotes/ItemVM/FishNotesBaitVM")
local FishNotesBaitISlotVM = require("Game/FishNotes/ItemVM/FishNotesBaitISlotVM")
local FishSlotItemVM = require("Game/FishNotes/ItemVM/FishSlotItemVM")
local FishNotesDefine = require("Game/FishNotes/FishNotesDefine")

---@class FishIngholeBaitsVM: UIViewModel
---@field BaitSlotVM1 FishNotesSlotItemView @鱼类详情-鱼饵1
---@field BaitSlotVM1 FishNotesSlotItemView @鱼类详情-鱼自己
---@field FishDetailBaitList table @鱼类详情-鱼饵列表

local FishIngholeBaitsVM = LuaClass(UIViewModel)

function FishIngholeBaitsVM:Ctor()
    self.BaitSlotVM1 = FishNotesBaitISlotVM.New()
    self.BaitSlotVM5 = FishSlotItemVM.New()
    self.FishDetailBaitList = UIBindableList.New(FishNotesBaitVM)
    self.PointIcon = FishNotesDefine.FishBaitPointIcon[1]
    self.SkillIcon = FishNotesDefine.FishBaitSkillIcon[1]
end

function FishIngholeBaitsVM:IsEqualVM(Value)
    return Value ~= nil
end

---@type 刷新选中的鱼类对应的鱼饵信息Fish
---@param FishData table 鱼类数据
function FishIngholeBaitsVM:UpdateVM(BaitList, FishData, LocationID)
    --钓饵1
    local SingleBait = BaitList[1]
    self.BaitSlotVM1:UpdateVM(SingleBait)
    --钓饵链
    local FishList = {}
    if not table.is_nil_empty(BaitList) then
        if #BaitList >= 2 then
            for i = 2, #BaitList do
                FishList[#FishList + 1] = BaitList[i]
            end
        end
    end
    self.FishDetailBaitList:UpdateByValues(FishList, nil)
    --终端鱼
    if FishData then
        local Data = {
            ID = FishData.ID,
            LocationID = LocationID,
            IsLocationFish = false,
            bCommonSelectShow = FishData.bCommonSelectShow,
        }
        self.BaitSlotVM5:UpdateVM(Data)

        self.PointIcon = FishNotesDefine.FishBaitPointIcon[FishData.RodType]
        self.SkillIcon = FishNotesDefine.FishBaitSkillIcon[FishData.SpecialLift]
    end
end

return FishIngholeBaitsVM