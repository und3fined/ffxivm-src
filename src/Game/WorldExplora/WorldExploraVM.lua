---
--- Author: Leo
--- DateTime: 2023-03-29 11:18:17
--- Description: 世界探索VM
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local WorldExploraPlaceItemVM = require("Game/WorldExplora/ItemVM/WorldExploraPlaceItemVM")


local WorldExploraVM = LuaClass(UIViewModel)

---Ctor
function WorldExploraVM:Ctor()
    self.THRemainCount = ""                 -- 寻宝
    self.bTHLockImgVisible = true
    self.TreasureNum = ""

    self.FTRemainCount = ""                 -- 友好部族
    self.bFTLockImgVisible = true
    self.RecommRace = ""
    self.RaceLevel = ""
    self.RaceIconPath = ""

    self.MonsterRemainCount = ""            -- 怪物狩猎
    self.bMonsterLockVisible = true

    -- Win 
    self.BGImgPath = ""

    self.bPanelBtnVisible = true
    self.BookName = ""

    self.GameName = ""
    self.Describe = ""

    self.bPanelRewardVisible = true

    self.bPanelFunctionVisible = false
    self.FuncIconPath = ""
    self.FuncName = ""

    self.bProgressVisible = false
    self.NumText = ""
    self.CurNum = ""  -- 根据系统而论
    self.TipDesc = ""
    self.CurProgress = 0 -- 根据系统而论

    self.bRecomMapVisible = false
    self.RecommMapText = ""
    self.HasFinishTipText = ""
    self.bFinishTipVisible = false
    self.RecommPlaceList = UIBindableList.New(WorldExploraPlaceItemVM)
    self.bPlaceListVisible = false
    self.bDownTextVisible = false
    self.bTipDescVisible = false

    self.bGoPanelVisible = false
    self.GoReasonText = ""

    self.RewardChangeCallBackNum = 0
end

function WorldExploraVM:OnInit()
  
end

function WorldExploraVM:OnBegin()

end

function WorldExploraVM:UpdateVM(Value)

end

function WorldExploraVM:OnShutdown()

end

function WorldExploraVM:OnEnd()

end

--- @type 更新列表
--- @param
function WorldExploraVM:UpdateList(List, Data)
    if List == nil then
        return
    end

    if Data[1] == nil then
        List:Clear()
        return
    end

    if nil ~= List and List:Length() > 0 then
        List:Clear()
    end

    List:UpdateByValues(Data)
end

return WorldExploraVM