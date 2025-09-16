local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local ProtoRes = require("Protocol/ProtoRes")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ActivityNodeType = ProtoRes.Game.ActivityNodeType

---@class OpsShoppingPanelVM : UIViewModel
local OpsShoppingPanelVM = LuaClass(UIViewModel)
---Ctor
function OpsShoppingPanelVM:Ctor()
    self.TitleText = nil
    self.SubTitleText = nil
    self.RichHintText = nil
end

function OpsShoppingPanelVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    self.TitleText = Activity.Title
    self.SubTitleText = Activity.SubTitle
    self.RichHintText = Activity.Info

    local ClientShowNodes = ActivityData:GetNodesByNodeType(ActivityNodeType.ActivityNodeTypeClientShow)
    if #ClientShowNodes < 1 then
		return
	end
   
	local NodeID  = ClientShowNodes[1].Head.NodeID
	local ActivityNode = ActivityNodeCfg:FindCfgByKey(NodeID)
    if ActivityNode then
        self.ImgPoster = ActivityNode.StrParam
    end

end


return OpsShoppingPanelVM