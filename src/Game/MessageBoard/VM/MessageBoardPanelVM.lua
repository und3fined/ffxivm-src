local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
--local ProtoCS = require("Protocol/ProtoCS")
--local ProtoRes = require("Protocol/ProtoRes")

local BoardVM = require("Game/MessageBoard/VM/BoardVM")
local BoardSlotVM = require("Game/MessageBoard/VM/BoardSlotVM")

---@class MessageBoardPanelVM : UIViewModel
local MessageBoardPanelVM = LuaClass(UIViewModel)

function MessageBoardPanelVM:Ctor()
    self.BoardListSlotVM = nil
    self.ExistListSlotVM = nil
end

function MessageBoardPanelVM:UpdateData()
    --self:UpdateMountList()
end

function MessageBoardPanelVM:UnInitData()
    self.BoardListSlotVM = nil
    self.ExistListSlotVM = nil
end
-- 刷新留言板列表
function MessageBoardPanelVM:UpdateBoardList(bPlayerUpdate)
    local BoardList = BoardVM.BoardList
    if (BoardList == nil) then return end
    if bPlayerUpdate == true or self.BoardListSlotVM == nil then
        local ListSlotVMp = {}
        for _, Board in ipairs(BoardList) do
            local BoardSlotVM = BoardSlotVM.New()
            BoardSlotVM:UpdateData(Board, bPlayerUpdate)
            ListSlotVMp[#ListSlotVMp + 1] = BoardSlotVM
        end
        self.BoardListSlotVM = ListSlotVMp
    else
        for Index, Board in ipairs(BoardList) do
            self.BoardListSlotVM[Index]:UpdateData(Board, bPlayerUpdate)
        end
    end
    self.ExistListSlotVM = self.BoardListSlotVM
end

function MessageBoardPanelVM:GetExistSlotVM()
    -- 临时加的，对服务器的数据做判断，存了很多废数据;
    -- 但是这个判断需要放在玩家信息查询的回调里执行，导致有明显延迟，因此暂时先存储变更
    local ExistSlotVMp = {}
    for _, BoardSlot in ipairs(self.BoardListSlotVM) do
        if BoardSlot.PlayerName ~= nil and string.len(BoardSlot.PlayerName) > 0 then
            ExistSlotVMp[#ExistSlotVMp + 1] = BoardSlot
        end
    end
    self.ExistListSlotVM = ExistSlotVMp
end

return MessageBoardPanelVM