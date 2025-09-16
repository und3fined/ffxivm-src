---
--- Author: Leo
--- DateTime: 2024-2-19 11:16:34
--- Description:
---

local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ItemCfg = require("TableCfg/ItemCfg")
local UIBindableList = require("UI/UIBindableList")
local GoldSaucerCuffGameResultItemVM = require("Game/GoldSaucerGame/View/Cuff/ItemVM/GoldSaucerCuffGameResultItemVM")

local GoldSaucerMiniGameDefine = require("Game/GoldSaucerMiniGame/GoldSaucerMiniGameDefine")
local LSTR = _G.LSTR
---@class MiniGameMonsterTossResultVM : UIViewModel

local MiniGameMonsterTossResultVM = LuaClass(UIViewModel)

---Ctor
function MiniGameMonsterTossResultVM:Ctor()
    self.bSuccess = false
    self.bFail = false
    -- self.ResultText = ""
    self.bIconGoldVisible = true
    self.TryAgainTip = "1"
    self.ResultVMList = UIBindableList.New(GoldSaucerCuffGameResultItemVM)
    self.RewardGot = "0"
    self.AwardIconPath = ""
    self.TryAgainTipColor = "#FFFFFF"
    self.BtnText = LSTR(250001) -- 再 战
    -- {"BtnText", UIBinderSetText.New(self, self.Btn2.TextContent)}, 

	-- 	{"", UIBinderSetBrushFromAssetPath.New(self, self.Award.CommBackpackSlot_UIBP.FImg_Icon)},
    
end

function MiniGameMonsterTossResultVM:IsEqualVM(Value)
    return true
end

function MiniGameMonsterTossResultVM:UpdateVM(Value)
    if Value == nil then
        return
    end
    self.bSuccess = Value.bSuccess
    self.bFail = Value.bFail
    -- self.ResultText = Value.ResultText
    self.bIconGoldVisible = Value.bIconGoldVisible
    self.TryAgainTip = Value.TryAgainTip
    if Value.ResultListData ~= nil then
        self:UpdateList(self.ResultVMList, Value.ResultListData)
    end
    self.RewardGot = tonumber(Value.RewardGot)
    self.AwardIconPath = Value.AwardIconPath
    self.TryAgainTipColor = Value.TryAgainTipColor
    self.BtnText = Value.BtnText
end

--- @type 加载tableviews
function MiniGameMonsterTossResultVM:UpdateList(List, Data)
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

function MiniGameMonsterTossResultVM:Reset()
    self.bSuccess = false
    self.bFail = false
    -- self.ResultText = ""
    self.bIconGoldVisible = true
    self.TryAgainTip = "1"
    -- self.ResultVMList = UIBindableList.New(GoldSaucerCuffGameResultItemVM)
    self.RewardGot = "0"
    self.AwardIconPath = ""
    self.TryAgainTipColor = "#FFFFFF"
    self.BtnText = LSTR(250001) -- 再 战
    -- {"BtnText", UIBinderSetText.New(self, self.Btn2.TextContent)}, 

	-- 	{"", UIBinderSetBrushFromAssetPath.New(self, self.Award.CommBackpackSlot_UIBP.FImg_Icon)},
end



return MiniGameMonsterTossResultVM   