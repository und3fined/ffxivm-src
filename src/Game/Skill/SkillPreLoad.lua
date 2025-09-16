
local ObjectGCType = require("Define/ObjectGCType")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local UIViewID = require("Define/UIViewID")

local SkillPreLoad = {
}

function SkillPreLoad.PreLoadOnEnterGame()
    --必须要hold住
    local _GCType = ObjectGCType.Hold

    local UIViewMgr = _G.UIViewMgr
    --pre load skill main panel
    do
        UIViewMgr:PreLoadWidgetByViewName(SkillCommonDefine.NewMainSkillBPName)
    end

    --pre load multi select panel
    do
        --加载3套
        local View = UIViewMgr:CreateViewByName(SkillCommonDefine.MultiChoicePanelBPName, _GCType)
        local View1 = UIViewMgr:CreateViewByName(SkillCommonDefine.MultiChoicePanelBPName, _GCType)
        local View2 = UIViewMgr:CreateViewByName(SkillCommonDefine.MultiChoicePanelBPName, _GCType)
        UIViewMgr:RecycleView(View)
        UIViewMgr:RecycleView(View1)
        UIViewMgr:RecycleView(View2)
    end

    --pre load skill cancel panel
    do
        UIViewMgr:PreLoadWidgetByViewID(UIViewID.SkillCancelJoyStick)
    end
end

function SkillPreLoad.PreLoadOnEnterLevel()

end

return SkillPreLoad