local AddonName, ns = ...

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
        "|cffFFFFFF-打开命令：|r/TuanJian或/TJ，或游戏设置里绑定按键。小地图图标： " .. "|TInterface\\AddOns\\TuanJian\\Media\\icon\\icon.tga:0|t",
        "|cffFFFFFF-快捷操作：|r右键输入框可以清除内容",
        " ",
    }
    ns.updateText_now = {
        "|cff00FF00" .. "8月9日更新v2.1.3",
        [[-<时光服>BUFF监控：常驻BUFF增加DKT冰脸检测；增加暗抗BUFF检测]],
        [[-<时光服>穆鲁：增加自动标记"影刃怒火法师"]],
        [[-<时光服>基尔加丹：增加站位图"入口站位"，以满足不同团队的站位习惯]],
        [[-<时光服>妖术领主：增加"灵魂之箭减伤链"]],
        [[-<时光服>妖术领主：增加"灵魂虹吸点名团队提醒"（当点名骑士/战士时，会RW提醒注意奉献/旋风斩）]],
        [[-<MOP>更新奥格1、9号BOSS站位图，使地图入口在6点钟方向]],
        " ",
    }
    ns.updateText_before = {
        "|cff00FF00" .. "8月4日更新v2.1.2",
        [[-<时光服>BUFF监控：右键菜单中增加"监控宠物"（默认勾选）]],
        [[-<时光服>增伤覆盖：增加显示"30%疾病易伤"]],
        [[-<MOP>增加奥格1、4、9、13号BOSS站位图]],
        -- " ",
    }
end

local l = GetLocale()
if (l == "zhTW" or l == "enUS") then return end

local L = {}

do
end
