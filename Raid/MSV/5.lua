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
local FB = "MSV"
local bossIndex = 5
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
    -- 站位图
    do
        TJ.Once("map", 250106, function()
            wipe(TuanJian[FB][bossIndex].map)
        end)

        local tbl = {
            { point = "TOPLEFT", xy = { 156, -485 } },
            { point = "TOPLEFT", xy = { 100, -474 } },
            { point = "TOPLEFT", xy = { 83, -416 } },

            { point = "TOPLEFT", xy = { 56, -308 } },
            { point = "TOPLEFT", xy = { 97, -269 } },
            { point = "TOPLEFT", xy = { 56, -210 } },

            { point = "TOPLEFT", xy = { 82, -108 } },
            { point = "TOPLEFT", xy = { 91, -50 } },
            { point = "TOPLEFT", xy = { 155, -40 } },

            { point = "TOPLEFT", xy = { 452, -39 } },
            { point = "TOPLEFT", xy = { 511, -43 } },
            { point = "TOPLEFT", xy = { 520, -104 } },

            { point = "TOPLEFT", xy = { 547, -210 } },
            { point = "TOPLEFT", xy = { 517, -266 } },
            { point = "TOPLEFT", xy = { 544, -314 } },

            { point = "TOPLEFT", xy = { 523, -413 } },
            { point = "TOPLEFT", xy = { 523, -474 } },
            { point = "TOPLEFT", xy = { 459, -484 } },

            { point = "TOPLEFT", xy = { 447, -409 } },
            { point = "TOPLEFT", xy = { 158, -399 } },
            { point = "TOPLEFT", xy = { 161, -114 } },
            { point = "TOPLEFT", xy = { 442, -118 } },
            { point = "TOPLEFT", xy = { 303, -513 } },
            --[[
]]

            [100] = { xy = { 303, -279 }, isNPC = "b" .. bossIndex },
        }
        local xy = {
            { 626, -85 },  -- 星星
            { 626, -32 },  -- 大饼
            { 558, -269 }, -- 紫菱
            { 129, -94 },  -- 三角
            { 484, -439 },
            { 478, -88 },
            { 54, -266 },
            { 125, -438 },
        }
        for index = 1, 8 do
            local left = mod((index - 1) / 4, 1);
            local right = left + 0.25;
            local top = floor((index - 1) / 4) * 0.25;
            local bottom = top + 0.25;
            tbl[index + 90] = {
                xy = xy[index],
                isNPC = true,
                isNPC_help = true,
                isNPC_icon = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
                coord = { left, right, top, bottom },
                notMask = true,
            }
        end

        local function AutoFuc()
            local dpstbl = TJ.SortRaidRosterInfo(nil, "dps", true)
            local headertbl = TJ.SortRaidRosterInfo(nil, "healer", true)
            if TJ.Is10Man() then
                local nums = { 2, 5, 8, 11, 14, 17, 1, 4 }
                for i, num in ipairs(nums) do
                    for i, v in ipairs(dpstbl) do
                        TJ.SetMapIconPlayerFormNum(num, v)
                        tremove(dpstbl, i)
                        break
                    end
                end
                for i, v in ipairs(headertbl) do
                    TJ.SetMapIconPlayerFormNum(20, v)
                    tremove(headertbl, i)
                    break
                end
                for i, v in ipairs(headertbl) do
                    TJ.SetMapIconPlayerFormNum(22, v)
                    tremove(headertbl, i)
                    break
                end
            else
                for i, v in ipairs(dpstbl) do
                    TJ.SetMapIconPlayer(v, { min = 1, max = 18 })
                end
                for i, v in ipairs(headertbl) do
                    TJ.SetMapIconPlayer(v, { min = 19, max = 23 })
                end
            end
        end
        local text = { L["安排DPS在1-18号位置。"], L["安排治疗在19-23号位置。"] }
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local map = TJ.CreateMap(FB, bossIndex, tbl, 600, 560)
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["主坦克"])
        TJ.CreateEdit(FB, bossIndex, L["副坦克"])
    end
    -- 横扫千军
    do
        local function AutoFuc(title)
            -- local tbl = CopyTable(TJ.SortRaidRosterInfo({ "PALADIN", "DRUID", "PRIEST" }, "dps", true))
            local tbl = CopyTable(TJ.SortRaidRosterInfo({ "HUNTER", "ROGUE", "PRIEST" }, "dps", true))
            for i, v in ipairs(tbl) do
                if v.class == "HUNTER" then
                    tbl[i].index = 2
                elseif v.class == "ROGUE" then
                    tbl[i].index = 3
                elseif v.class == "PRIEST" then
                    tbl[i].index = 4
                end
            end
            local tank = CopyTable(TJ.SortRaidRosterInfo(TJ.tankClass, "tank", true))[2]
            if tank then
                tank.index = 1
                tinsert(tbl, tank)
            end
            sort(tbl, function(a, b)
                if a.index and b.index then
                    return a.index < b.index
                end
                return false
            end)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            117914,
                        },
                        colorNum = 1
                    },
                },
            },
        }
        local text = L["第1轮：副坦+两个猎人，第2轮：剩余的猎人+盗贼/暗牧"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, 135735, L["横扫千军"],
            text, nil, nil, info, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["第1轮"])
        TJ.CreateEdit(FB, bossIndex, L["第1轮"])
        TJ.CreateEdit(FB, bossIndex, L["第1轮"])
        TJ.CreateEdit(FB, bossIndex, L["第2轮"])
        TJ.CreateEdit(FB, bossIndex, L["第2轮"])
        TJ.CreateEdit(FB, bossIndex, L["第2轮"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 转火星界保护者
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    60793,
                },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_arcane_arcane01", L["转火星界保护者"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火电荷
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    60913,
                },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 136116, L["转火电荷"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火焦镜
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    60776,
                },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 135753, L["转火焦镜"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end



    TJ.frame[FB][bossIndex].BOSS_SAY = function(msg)
        if msg:match("抽取备用能量") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
        if msg:match("能量涡流缓降") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P3",
            })
            return
        end
        if msg:match("过来！感受泰坦的力量") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P1",
            })
            return
        end
    end
end
