--
-- Author: MichaelYang_LightPaw
-- Date: 2023-12-20 14:50
-- Description:
--
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoCommon = require("Protocol/ProtoCommon")
local Log = require("Game/MagicCard/Module/Log")
local LocalDef = require("Game/MagicCard/MagicCardLocalDef")
local EventID = require("Define/EventID")
local ProfType = ProtoCommon.prof_type
local RoleGender = ProtoCommon.role_gender
local CardTypeEnum = LocalDef.CardItemType

---@class CardsRewardSingleCardVM : UIViewModel
local CardsRewardSingleCardVM = LuaClass(UIViewModel)

---Ctor ParentVM需要自行注意，目前可能是 CardsGroupCardVM 或者 CardsEditDecksPanelVM
function CardsRewardSingleCardVM:Ctor()
    self.CardId = 0 -- 卡片的ID
end

function CardsRewardSingleCardVM:SetCardId(TargetValue)
    self.CardId = TargetValue
    --lua _G.UIViewMgr:ShowView(2209)
end

function CardsRewardSingleCardVM:GetCardId()
    return self.CardId
end

-- 要返回当前类
return CardsRewardSingleCardVM
