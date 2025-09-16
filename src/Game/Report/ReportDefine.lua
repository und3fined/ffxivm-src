local LSTR = _G.LSTR

local ReportReasons = {
    [1] = {Text = LSTR(780004), ReasonID = 101 },   -- "侮辱谩骂"
    [2] = {Text = LSTR(780009), ReasonID = 102 },   -- "引流广告"
    [3] = {Text = LSTR(780022), ReasonID = 103 },   -- "色情低俗"
    [4] = {Text = LSTR(780007), ReasonID = 104 },   -- "内容涉政"
    [5] = {Text = LSTR(780012), ReasonID = 105 },   -- "拉人骚扰"
    [6] = {Text = LSTR(780018), ReasonID = 106 },   -- "暴力血腥"
    [7] = {Text = LSTR(780019), ReasonID = 108 },   -- "欺诈信息"
    [8] = {Text = LSTR(780017), ReasonID = 901 },   -- "昵称违规"
    [9] = {Text = LSTR(780006), ReasonID = 199 },   --"其他"
    [10] = {Text = LSTR(780020), ReasonID = 904 },  --"签名违规"
    [11] = {Text = LSTR(780016), ReasonID = 906 },  --"搭档名称违规"
    [12] = {Text = LSTR(780008), ReasonID = 801 },  -- "名称违规"
    [13] = {Text = LSTR(780021), ReasonID = 805 },  --"简称违规"
    [14] = {Text = LSTR(780005), ReasonID = 803 },  --"公告违规"
    [15] = {Text = LSTR(780014), ReasonID = 802 },  --"招募标语违规"
    [16] = {Text = LSTR(780013), ReasonID = 802 },  --"招募宣言违规"
    [17] = {Text = LSTR(780015), ReasonID = 802 },  --"招募留言违规"
    [18] = {Text = LSTR(780006), ReasonID = 899 },   --"其他"
    [19] = {Text = LSTR(780006), ReasonID = 999 },   --"其他"
    [20] = {Text = LSTR(780031), ReasonID = 213 },   --"自动脚本"
}

-- ReportScene 组成
local ReportScene = {
    Speech =            {SceneID = 1, Entrance = nil, Reasons = {1, 2, 3, 4, 5, 6, 7, 8, 9}}, --会话发言
    PersonalInfo =      {SceneID = 2, Entrance = nil, Reasons = {8, 10, 11, 20, 19}}, --个人资料
    ArmyList =          {SceneID = 7, Entrance = 1, Reasons =  {12, 13, 15, 18}}, --部队列表
    ArmyInfo =          {SceneID = 7, Entrance = 1, Reasons =  {12, 13, 14, 18}}, --部队信息
    LinkShell =         {SceneID = 7, Entrance = 2, Reasons =  {12, 14, 16, 18}}, --通讯贝
    FriendRequest =     {SceneID = 8, Entrance = 1, Reasons =  {1, 2, 3, 4, 5, 6, 7, 8, 9}}, --好友申情
    ArmyRequest =           {SceneID = 8, Entrance = 2, Reasons =  {1, 2, 3, 4, 5, 6, 7, 8, 9}}, --部队申情消息
    LinkShellInvitation =   {SceneID = 8, Entrance = 3, Reasons =  {1, 2, 3, 4, 5, 6, 7, 8, 9}}, --通讯贝邀请消息
    TeamRecruitment =       {SceneID = 8, Entrance = 4, Reasons = {17}} -- 队伍招募信息
}

local ReportDefine = {
    ReportReasons = ReportReasons,
    ReportScene = ReportScene
}

return ReportDefine


--[[       举报多语言id 内容注释
    780001,    --举  报
    780002,    --举报成功
    780003,    --举报玩家：
    780004,    --侮辱谩骂 
    780005,    --公告违规
    780006,    --其他
    780007,    --内容涉政
    780008,    --名称违规
    780009,    --引流广告
    780010,    --必须选择一项举报理由
    780011,    --感谢您的举报，我们将在48小时内确认问题并进行处理。
    780012,    --拉人骚扰
    780013,    --招募宣言违规
    780014,    --招募标语违规
    780015,    --招募留言违规
    780016,    --搭档名称违规
	780017,    --昵称违规
    780018,    --暴力血腥
    780019,    --欺诈信息
    780020,    --签名违规
	780021,    --简称违规
	780022,    --色情低俗
	780023,    --请点击输入
	780024,    --马上举报
	780025,    --我再看看
]]--
