
local SideBarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local CommSideBarUtil = {}
local EasyToUseLastSelectType

-- local Params = {
--     ShowTabType = ShowTabType,                        @页签Type      SideBarDefine.EasyToUseTabType or other
--     PageParams = PageParams,                          @首选子页签的   self.Params
--     PanelType = SideBarDefine.PanelType.EasyToUse,    @集合主界面类型 SideBarDefine.PanelType.EasyToUse or other
-- }

---快捷使用侧边栏
---@param ShowTabType number    @页签Type      SideBarDefine.EasyToUseTabType or other
---@param PageParams table      @首选子页签的   self.Params
function CommSideBarUtil.ShowEasyToUseSideBarByType(ShowTabType, PageParams)
    local Params = {
        ShowTabType = ShowTabType,
        PageParams = PageParams,
        PanelType = SideBarDefine.PanelType.EasyToUse,
    }

    --【【烟花】【快捷释放】从主界面打开快捷栏时记录上一次关闭的页面】 https://tapd.tencent.com/tapd_fe/20420083/story/detail/1020420083122746574
    if ShowTabType == SideBarDefine.EasyToUseTabType.Emoji and EasyToUseLastSelectType and EasyToUseLastSelectType ~= SideBarDefine.EasyToUseTabType.Emoji then
        Params.ShowTabType = EasyToUseLastSelectType
        Params.PageParams = nil
        UIViewMgr:ShowView(UIViewID.CommEasytoUseView, Params)
        CommSideBarUtil.ClearCurEasyUseLastType()
    else
        UIViewMgr:ShowView(UIViewID.CommEasytoUseView, Params)
    end
end

---地图设置侧边栏
function CommSideBarUtil.ShowMapSettingSideBarByType(ShowTabType, PageParams)
    local Params = {
        ShowTabType = ShowTabType,
        PageParams = PageParams,
        PanelType = SideBarDefine.PanelType.MapSetting,
    }

    UIViewMgr:ShowView(UIViewID.CommEasytoUseView, Params)
end

function CommSideBarUtil.ClearCurEasyUseLastType()
    EasyToUseLastSelectType = nil
end

function CommSideBarUtil.SetCurEasyUseLastType(Type)
    EasyToUseLastSelectType = Type
end

function CommSideBarUtil.OnSideBarHide(CurPanelType, CurSelectType)
    if CurPanelType == SideBarDefine.PanelType.EasyToUse then
        CommSideBarUtil.SetCurEasyUseLastType(CurSelectType)
    end
end

return CommSideBarUtil