local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIUtil = require("Utils/UIUtil")
local OpsNewbieStrategyDefine = require("Game/Ops/OpsNewbieStrategy/OpsNewbieStrategyDefine")
local DataReportUtil = require("Utils/DataReportUtil")
local JumpUtil = require("Utils/JumpUtil")


---@class OpsNewbieStrategyAetherLightListItemVM : UIViewModel
local OpsNewbieStrategyAetherLightListItemVM = LuaClass(UIViewModel)

local ListItemViewType = {
    TitleItem = 0,
    JumpItem = 1,
}

---Ctor
function OpsNewbieStrategyAetherLightListItemVM:Ctor()

end

function OpsNewbieStrategyAetherLightListItemVM:UpdateVM(Params)
    if Params then
        self.ItemViewType = Params.ItemViewType
        self.Key = Params.Key
        if self.ItemViewType == ListItemViewType.TitleItem then
            if Params.TitleTextUKey then
                self.TitleText = LSTR(Params.TitleTextUKey)
            end
        elseif self.ItemViewType == ListItemViewType.JumpItem then
            if Params.ContentTextUKey then
                self.ContentText = LSTR(Params.ContentTextUKey)
            end
            self.Icon = Params.Icon
            self.JumpData = Params.JumpData
            self.ActivityID = Params.ActivityID
        end
    end
end

function OpsNewbieStrategyAetherLightListItemVM:GetKey()
	return self.Key
end

function OpsNewbieStrategyAetherLightListItemVM:AdapterOnGetWidgetIndex()
	return self.ItemViewType
end

function OpsNewbieStrategyAetherLightListItemVM:Jump()
	if self.JumpData then
        local JumpType = tonumber(self.JumpData[1])
        local JumpParam = tonumber(self.JumpData[2])
        if JumpType then
            local IsCanJump = JumpUtil.IsCurJumpIDCanJump(tonumber(JumpParam))
            if IsCanJump then
                _G.OpsActivityMgr:Jump(JumpType, JumpParam)
            else
                _G.OpsNewbieStrategyMgr:JumpUnlockSys(tonumber(JumpParam))
            end
			if self.ActivityID then
				DataReportUtil.ReportActivityClickFlowData(self.ActivityID ,OpsNewbieStrategyDefine.OperationPageActionType.SecondWinJumpToBtnCkicked, JumpParam)
			end
        end
	end
end

function OpsNewbieStrategyAetherLightListItemVM:IsEqualVM(Value)
	return self.Key == Value.Key
end

return OpsNewbieStrategyAetherLightListItemVM