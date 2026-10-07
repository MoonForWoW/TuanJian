local AddonName, ns = ...

ns.Interface =  "Interface\\AddOns\\" .. AddonName .. "\\"

local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
ns.ver = "v" .. GetAddOnMetadata(AddonName, "Version")

local L = setmetatable({}, {
    __index = function(table, key)
        return tostring(key)
    end
})
ns.L = L

local c1 = "|cff" .. "ffff66"
ns.c1 = c1

do --简体说明书
    ns.instructionsText = {
        "|cff00BFFF< 说明书 >（本插件支持MOP/CTM/WLK/时光服）",
        " ",
        "|cffFFFFFF-作者：|r苍穹之霜",
        "|cffFFFFFF-打开命令：|r/TuanJian或/TJ，或游戏设置里绑定按键。小地图图标：" .. "|T" .. ns.Interface .. "Media\\icon\\icon.png:0|t",
        "|cffFFFFFF-快捷操作：|r右键输入框可以清除内容",
        " ",
        -- "|cff00FF00" ..[[]] ,
        -- [[]] ,
        -- [[]] ,
        -- [[]] ,
        -- " " ,
    }
    ns.updateText_now = {
    }
    ns.updateText_before = {
        "|cff00FF00" ..[[10月7日更新v2.2.2]] ,
        [[-<时光>奥杜尔：增加托里姆和尤格萨隆的站位图]] ,
        " " ,
        "|cff00FF00" ..[[9月28日更新v2.2.1]] ,
        [[-站位图和减伤链已支持BiaoGeX插件]] ,
        [[-插件图标改成蓝色星星]],
        [[-<MOP>奥格1号：增加煞能迸发减伤链]],
        [[-<MOP>奥格6号：优化地震冲击减伤链时间轴]],
        [[-<MOP>奥格11号：增加多个战斗分析]],
        [[-<时光服>修复了关键词自动提醒补BUFF功能无法禁用的问题]],
        [[-<时光服>修复了死亡战斗分析中，无法显示QS大牺牲分担伤害的问题]],
        " " ,
        "|cff00FF00" ..[[8月18日更新v2.2.0]] ,
        [[-<MOP>奥格：增加1-9号BOSS的战斗分析和减伤链;地狱咆哮增加青龙寺站位图]] ,
        [[-<MOP>增加常驻BUFF监控（默认不开启，入口在设置页右上角）]] ,
        [[-<MOP>团减：最大轮数增加至7轮]],
        [[-<时光服>双子：增加燃烧滚出人群全屏提醒（当点名是你时）]],
        [[-<时光服>基尔加丹/妖术领主：增加自动标记小怪]],
    }
end

local l = GetLocale()
if (l == "zhTW" or l == "enUS") then return end

local L = {}

do
    L["显示悬浮框"] = true
    L["悬浮框缩放"] = true
    L["调整悬浮框UI的大小。"] = true
    L["悬浮框层级"] = true
    L["左键：打开/关闭主界面"] = true
    L["右键：打开设置"] = true
    L["左键拖动：移动悬浮框"] = true
end
