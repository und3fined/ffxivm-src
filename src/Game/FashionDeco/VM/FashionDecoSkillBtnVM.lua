local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local FashionDecoMgr = require("Game/FashionDeco/FashionDecoMgr")
---@class FashionDecoSkillBtnVM : UIViewModel
local FashionDecoSkillBtnVM = LuaClass(UIViewModel)
local TimeUtil = _G.TimeUtil
function FashionDecoSkillBtnVM:Ctor()
    self.FunctionType = nil
    self.Init = false
    self.lastUsedTimeSeconds = 0
end

function FashionDecoSkillBtnVM:ActiveFunction()
    if self.Init then
        local time = TimeUtil.GetLocalTimeMS()
        local CurrentTime  = time
        time = time - self.lastUsedTimeSeconds
        if time > 2000 then
            if self.FunctionType == FashionDecoDefine.FashionActionBtnType.Switch then
                FashionDecoMgr:ReqChangeIdleAnim()
            end
            if self.FunctionType == FashionDecoDefine.FashionActionBtnType.Action1 or self.FunctionType == FashionDecoDefine.FashionActionBtnType.Action2 
            or self.FunctionType == FashionDecoDefine.FashionActionBtnType.Wing then
                FashionDecoMgr:PlaySkillAction(self.FashionDecorateID,self.ActionID)

            end
            if self.FunctionType == FashionDecoDefine.FashionActionBtnType.Wing then
                FashionDecoMgr:PlaySkillLocalAction(self.FashionDecorateID,self.ActionID)

            end
            self.lastUsedTimeSeconds = CurrentTime
        else
             _G.MsgTipsUtil.ShowTips(LSTR(1030020))
        end

    end
end

return FashionDecoSkillBtnVM