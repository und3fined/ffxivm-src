local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local TimeUtil = require("Utils/TimeUtil")
local UIBindableList = require("UI/UIBindableList")
local NightGiftRecordListItemVM = require("Game/StarlightCelebration/VM/NightGift/NightGiftRecordListItemVM")

local LSTR = _G.LSTR
---@class NightGiftReceiveRecordVM : UIViewModel
local NightGiftReceiveRecordVM = LuaClass(UIViewModel)

---Ctor
function NightGiftReceiveRecordVM:Ctor()
	self.GiftTreeList = UIBindableList.New( NightGiftRecordListItemVM )
    self.EmptyVisible = nil
end

function NightGiftReceiveRecordVM:UpdateGiftRecordInfo(Value)
    if self.GiftTreeList then
        self.GiftTreeList:UpdateByValues(Value)
    end
    self.EmptyVisible = #Value == 0
end

--要返回当前类
return NightGiftReceiveRecordVM