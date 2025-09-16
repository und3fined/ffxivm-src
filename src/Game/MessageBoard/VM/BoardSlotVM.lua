local LuaClass = require("Core/LuaClass")
--local ItemVM = require("Game/Item/ItemVM")
local UIViewModel = require("UI/UIViewModel")
--local ProtoCS = require("Protocol/ProtoCS")
--local BoardVM = require("Game/MessageBoard/VM/BoardVM")
local MajorUtil = require("Utils/MajorUtil")
local LikeIconPath = "PaperSprite'/Game/UI/Atlas/Mount/Frames/UI_Mount_Btn_%s_png.UI_Mount_Btn_%s_png'"
--"PaperSprite'/Game/UI/Atlas/Button/Frames/UI_Comm_Btn_Picked_png.UI_Comm_Btn_Picked_png'"
local LoginMgr = require("Game/Login/LoginMgr")

---@class BoardSlotVM : UIViewModel
local BoardSlotVM = LuaClass(UIViewModel)

function BoardSlotVM:Ctor()
    --self.ObjectID = nil  -- 图鉴物品ID
    self.PlayerID = nil -- 用户ID
    self.PlayerName = nil -- 用户昵称
    self.PlayerIcon = nil -- 用户头像
    self.ServerID = nil -- 服务器ID
    self.ServerName = nil -- 服务器名称
    self.PlayerInf = nil -- 用户信息
    self.BoardContent = nil -- 评论内容
    self.IsAnonymou = false -- 是否匿名
    self.LikeNum = 0 -- 点赞数
    self.IsSelfLike = false -- 是否为玩家自己的点赞
    self.IsSelfCreate = false -- 是否为玩家自己发表的评论
    self.IsCanDelete = false -- 是否可以删除
    self.IsCanReport = false -- 是否可以举报
    self.LikeIcon = nil -- 点赞图标
    self.RoleVM = nil
end

-- 更新每条留言数据
function BoardSlotVM:UpdateData(Board, bPlayerUpdate)
    if Board == nil then return end
    -- 服务器获取的原始数据start --
    local Other = Board.Other
    if Other ~= nil then
        self.ServerID = Other.ZoneID
    end
    self.PlayerID = Board.PostID
    self.BoardContent = Board.Content
    self.LikeNum = Board.Likes
    self.IsAnoymour = Board.IsAnoymour
    self.IsSelfLike = Board.SelfLike
    -- 服务器获取的原始数据end --

    local MajorRoleID = MajorUtil.GetMajorRoleID()
    self.IsSelfCreate = MajorRoleID ==  self.PlayerID

    self.IsCanDelete = self.IsSelfCreate
    self.IsCanReport = not self.IsSelfCreate

    self:UpdateLikeIcon()

    if bPlayerUpdate ~= true then return end
    -- 根据服务器ID取得服务器名字
    --self.ServerName = ServerDirCfg:FindValue(self.ServerID, "Name")
    self.ServerName = LoginMgr:GetMapleNodeName(self.ServerID)
    -- 根据用户ID获取用户名
    --local RoleVM = _G.RoleInfoMgr:FindRoleVM(self.PlayerID)
    --self.PlayerName = RoleVM.Name
    local function Callback(_, RoleVM)
        self.RoleVM = RoleVM
		self.PlayerName = RoleVM.Name
        if self.IsAnoymour == true then
            self.PlayerInf = "匿名用户"
        else
            self.PlayerInf = string.format("%s——%s", self.PlayerName, self.ServerName)
        end
	end
	_G.RoleInfoMgr:QueryRoleSimple(self.PlayerID, Callback, self, false)
end

--更新点赞图标状态
function BoardSlotVM:UpdateLikeIcon()
    local IconName = "NoPick"
    if self.IsSelfLike then
        IconName = "Pick"
    end
    if self.IsSelfCreate then
        IconName = "PickGrey"
    end
    self.LikeIcon = string.format(LikeIconPath, IconName, IconName)
end

function BoardSlotVM:OnSelectedChange(IsSelected)
    self.IsSelect = IsSelected
end

return BoardSlotVM