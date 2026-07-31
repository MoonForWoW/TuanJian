local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = "ICC"
local bossIndex = 4
--[[
"DEATHKNIGHT"
"PALADIN"
"WARRIOR"
"SHAMAN"
"HUNTER"
"DRUID"
"ROGUE"
"MAGE"
"WARLOCK"
"PRIEST"
 ]]

TJ.Load[FB .. bossIndex] = function()
    -- 站位
    do
        local tbl = {
            { xy = { 326, -146 } },
            { xy = { 327, -220 } },
            { xy = { 327, -292 } },
            { xy = { 240, -151 } },
            { xy = { 411, -153 } }, -- 5
            { xy = { 196, -222 } },
            { xy = { 447, -225 } },
            { xy = { 235, -294 } },
            { xy = { 417, -293 } },
            { xy = { 194, -86 } }, -- 10
            { xy = { 453, -90 } },
            { xy = { 121, -116 } },
            { xy = { 526, -114 } },
            { xy = { 121, -190 } },
            { xy = { 533, -185 } },
            [100] = { xy = { 322, -48 }, size = nil, isNPC = "b" .. bossIndex },
            [101] = { xy = { 289, -22 }, size = 25, isNPC = "b" .. bossIndex .. "-1", index = 1 },
            [102] = { xy = { 349, -21 }, size = 25, isNPC = "b" .. bossIndex .. "-1", index = 2 },
            [103] = { xy = { 280, -61 }, size = 25, isNPC = "b" .. bossIndex .. "-1", index = 3 },
            [105] = { xy = { 361, -61 }, size = 25, isNPC = "b" .. bossIndex .. "-1", index = 4 },
            [104] = { xy = { 324, -88 }, size = 25, isNPC = "b" .. bossIndex .. "-1", index = 5 },
        }
        local function AutoFuc()
            -- N
            do
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "DRUID", "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if v.class == "PRIEST" then
                        TJ.SetMapIconPlayerFormNum(8, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "PRIEST" then
                        TJ.SetMapIconPlayerFormNum(9, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    TJ.SetMapIconPlayerFormNum(3, v)
                    tremove(tbl, i)
                    break
                end
            end
            -- DPS
            do
                local tbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
                for i, v in ipairs(tbl) do
                    if v.class == "HUNTER" then
                        TJ.SetMapIconPlayerFormNum(10, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "HUNTER" then
                        TJ.SetMapIconPlayerFormNum(11, v)
                        tremove(tbl, i)
                        break
                    end
                end

                for i, v in ipairs(tbl) do
                    if v.class == "DRUID" then
                        TJ.SetMapIconPlayerFormNum(2, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "DRUID" or v.class == "SHAMAN" then
                        TJ.SetMapIconPlayerFormNum(1, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "DRUID" or v.class == "SHAMAN" then
                        TJ.SetMapIconPlayerFormNum(4, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "DRUID" or v.class == "SHAMAN" then
                        TJ.SetMapIconPlayerFormNum(5, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "MAGE" then
                        TJ.SetMapIconPlayerFormNum(14, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "MAGE" then
                        TJ.SetMapIconPlayerFormNum(15, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "WARLOCK" then
                        TJ.SetMapIconPlayerFormNum(12, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "WARLOCK" then
                        TJ.SetMapIconPlayerFormNum(13, v)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    TJ.SetMapIconPlayer(v)
                end
            end
        end
        local text = {
            L["3奶德/奶萨，8/9奶牧（奶骑是近战位）。"],
            L["1/4/5鸟德/元素萨，2鸟德。"],
            L["10/11猎人。"],
            L["12/13术士。"],
            L["14/15法师。"],
            L["6/7安排剩下的远程DPS。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        TJ.CreateMap(FB, bossIndex, tbl, 650, 415)
    end

    -- 阵亡勇士的印记
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetEditTextFormNum(v, title, 1)
                    TJ.SetEditTextFormNum(v, title, 4)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if v.class == "PALADIN" then
                    TJ.SetEditTextFormNum(v, title, 2)
                    TJ.SetEditTextFormNum(v, title, 3)
                    tremove(tbl, i)
                    break
                end
            end
            if #tbl >= 3 then
                for i, v in ipairs(tbl) do
                    if v.class == "PALADIN" then
                        TJ.SetEditTextFormNum(v, title, 5)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    if v.class == "SHAMAN" or v.class == "DRUID" then
                        TJ.SetEditTextFormNum(v, title, 5)
                        tremove(tbl, i)
                        break
                    end
                end
                for i, v in ipairs(tbl) do
                    TJ.SetEditTextFormNum(v, title, 5)
                    tremove(tbl, i)
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
            for i, v in ipairs(tbl) do
                if TJ.Isdps(v) then
                    TJ.SetEditTextFormNum(v, title, 5)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if TJ.Isdps(v) then
                    TJ.SetEditTextFormNum(v, title, 6)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if TJ.Istank(v) then
                    TJ.SetEditTextFormNum(v, title, 5)
                    tremove(tbl, i)
                    break
                end
            end
            for i, v in ipairs(tbl) do
                if TJ.Istank(v) then
                    TJ.SetEditTextFormNum(v, title, 6)
                    tremove(tbl, i)
                    break
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72293, -- 阵亡勇士的印记
                        },
                        colorNum = 2
                    },
                    {
                        spellID = ns.sp["道标"],
                        colorNum = 1
                    },
                    {
                        spellID = ns.sp["干涉"],
                        colorNum = 4
                    },
                },
            }
        }

        local text = L["1/4印记：1号奶骑，2/3印记：2号奶骑，5印记：如果5奶阵容则安排一个治疗，否则安排惩戒骑/防骑干涉，6印记：惩戒骑/防骑干涉"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_deathknight_bladedarmor", L["阵亡勇士的印记"],
            text, TJ.healerClass, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["1印记"])
        TJ.CreateEdit(FB, bossIndex, L["2印记"])
        TJ.CreateEdit(FB, bossIndex, L["3印记"])
        TJ.CreateEdit(FB, bossIndex, L["4印记"])
        TJ.CreateEdit(FB, bossIndex, L["5印记"])
        TJ.CreateEdit(FB, bossIndex, L["6印记"])
    end
    -- 冰霜陷阱
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditTextFormNum(v, title, 1)
                tremove(tbl, i)
                break
            end
            for i, v in ipairs(tbl) do
                TJ.SetEditTextFormNum(v, title, 2)
                tremove(tbl, i)
                break
            end
        end
        local info = {
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = ns.sp["冰霜陷阱"],
                        colorNum = 1,
                        frameLevel = 1,
                    },
                },
            }
        }
        local text = L["安排两个猎人，一个左一个右。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_frost_freezingbreath", L["冰霜陷阱"],
            text, { "HUNTER" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["左陷阱"])
        TJ.CreateEdit(FB, bossIndex, L["右陷阱"])
        TJ.CreateEdit(FB, bossIndex, L["中陷阱"])
    end

    -- 吹风
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps2", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = ns.sp["吹风"],
                        colorNum = 1,
                        frameLevel = 1,
                    },
                },
            }
        }
        local text = L["安排鸟德。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_druid_typhoon", L["吹风"],
            text, { "DRUID" }, nil, info)
        TJ.CreateEdit(FB, bossIndex, L["1吹"])
        TJ.CreateEdit(FB, bossIndex, L["2吹"])
        TJ.CreateEdit(FB, bossIndex, L["3吹"])
    end

    -- 灵魂石
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local function updateFuc(index)
            local count = 0
            for i, v in ipairs(TJ.raidRosterInfo) do
                if count >= 3 then break end
                if v.role ~= "MAINASSIST" and v.class == "WARLOCK" then
                    count = count + 1
                    local name = "|c" .. select(4, GetClassColor(v.class)) .. TJ.GetIconAndName(v) .. "|r"
                    TJ.CreateEdit(FB, bossIndex, name, index)
                end
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = ns.sp["灵魂石"],
                    },
                },
            }
        }
        local text = L["绑定坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_shadow_soulgem", L["灵魂石"],
            text, nil, updateFuc, info)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 鲜血新星
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72380,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
                notMiss = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 237513, L["鲜血新星"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 沸腾之血
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72385, -- 被点名
                        },
                        colorNum = 2
                    },
                    {
                        spellID = ns.sp["保护"],
                        colorNum = 1
                    },
                },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 237513, L["沸腾之血"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 符文之血
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            72410,
                        },
                        colorNum = 2,
                        frameLevel = 1,
                    },
                },
            },
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = ns.sp["单嘲+群嘲"],
                        colorNum = 1,
                        frameLevel = 2,
                        combatRole = { "Istank" },
                    },
                },
                destNPCID = { 37813 },
                notShowCount = true,
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135772, L["符文之血"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火血兽
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    38508,
                },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 134260, L["转火血兽"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
end
