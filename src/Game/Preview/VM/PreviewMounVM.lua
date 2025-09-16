local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local RideCfg = require("TableCfg/RideCfg")
local RideTextCfg = require("TableCfg/RideTextCfg")

---@class PreviewMounVM : UIViewModel
local PreviewMounVM = LuaClass(UIViewModel)

function PreviewMounVM:Ctor()
    self.AllMountMp = {}
    self.IsShowPlayer = false  --是否显示坐骑背上的玩家

    self.TextShowName = ""
    self.TextShowMember = ""
    self.TextShowExpository = ""

    --技能图标相关
    self.ActionTableList = nil
    self.IsShowSkillItem = false
    self.SkillTagList = nil
    self.IsShowSkillTips = false

    --记录选中的
    self.SelectedMountID = nil
    
    -- 剧情保护展示的问号
    self.IsShowNameImg = false

    -- 音效控制
    self.IsShowBGM = true

end

function PreviewMounVM:ClearData()
    self:Ctor()
end

function PreviewMounVM:UpdateShowText(Mount)
    if Mount == nil then return end

    self.TextShowName = Mount.Name
    self.IsShowNameImg = false
    self.TextShowMember = string.format("%d%s", Mount.SeatCount, _G.LSTR(1090074))

    --说明文本显示
    self.TextShowExpository = Mount.MountExpository
    if self.TextShowExpository == nil or #self.TextShowExpository < 36 then
        self.TextShowExpository = "                                          "
    end
    local TextMountCry =  Mount.MountCry
    if Mount.MountCry ~= nil and string.find(Mount.MountCry, "<br>") then
        TextMountCry = string.gsub(Mount.MountCry, "<br>", "\n")
    end
    self.TextShowExpository = table.concat({self.TextShowExpository, TextMountCry},"\n\n")
end

function PreviewMounVM:GetMountById(MountId)
    if self.AllMountMp[MountId] ~= nil then
        return self.AllMountMp[MountId]
    end

    --local AllRideTable = RideCfg:FindAllCfg()
    local AllRideTable = RideCfg:GetPackageCfg()
    local Mount = nil
    for _,v in ipairs(AllRideTable) do
        if (v.ID ~= nil) then
            if v.ID == MountId then
                 --local mount = {Flag = 0, ResID = v.ID, LikeTime = 0}
                local MountText = ""
                local MountTextCry = ""
                local c_RideText_Cfg = RideTextCfg:FindCfgByKey(v.ID)
                if  c_RideText_Cfg ~= nil then
                    MountText = c_RideText_Cfg.Expository
                    MountTextCry = c_RideText_Cfg.Cry
                end
                Mount = {Flag = 0, LikeTime = 0, ResID = v.ID, Name = v.Name, SeatCount = v.SeatCount + 1,
                SkeletonId = v.SkeletonId, PatternId = v.PatternId, ImeChanId = v.ImeChanId, IsStoryProtect = v.IsStoryProtect,
                MountExpository = MountText, MountCry = MountTextCry, GetwayList = v.GetWay, ModelScaling = v.ModelScaling, MountTrack = v.MountTrack,
                RotationX = v.RotationX or 0, RotationY = v.RotationY or 0, RotationZ = v.RotationZ or 0, LocationX = v.LocationX or 0, LocationY = v.LocationY or 0, LocationZ = v.LocationZ or 0, BgmID = v.MountBgm}
                self.AllMountMp[Mount.ResID] = Mount
                break
            end
        end
    end
    return Mount
end

return PreviewMounVM