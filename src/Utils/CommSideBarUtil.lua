
local SideBarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local CommSideBarUtil = {}

---@param PanelType number      @集合主界面类型 SideBarDefine.PanelType.EasyToUse or other
---@param ShowTabType number    @页签Type      SideBarDefine.EasyToUseTabType or other
---@param PageParams table      @首选子页签的   self.Params
function CommSideBarUtil.ShowSideBarByType(PanelType, ShowTabType, PageParams)
    local Params = {
        ShowTabType = ShowTabType,
        PageParams = PageParams,
        PanelType = PanelType,
    }

    UIViewMgr:ShowView(UIViewID.CommEasytoUseView, Params)
end

return CommSideBarUtil