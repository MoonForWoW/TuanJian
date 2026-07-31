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
local FB = "TOT"
local bossIndex = 8
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
    local mainFrame = TJ.frame[FB][bossIndex]

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 213, -40 } },
            { point = "TOPLEFT", xy = { 110, -113 } },
            { point = "TOPLEFT", xy = { 88, -232 } },
            { point = "TOPLEFT", xy = { 105, -359 } },
            { point = "TOPLEFT", xy = { 200, -436 } },
            { point = "TOPLEFT", xy = { 449, -436 } },
            { point = "TOPLEFT", xy = { 536, -347 } },
            { point = "TOPLEFT", xy = { 563, -234 } },
            { point = "TOPLEFT", xy = { 533, -115 } },
            { point = "TOPLEFT", xy = { 441, -39 } },
            { point = "TOPLEFT", xy = { 241, -96 } },
            { point = "TOPLEFT", xy = { 166, -143 } },
            { point = "TOPLEFT", xy = { 160, -234 } },
            { point = "TOPLEFT", xy = { 163, -325 } },
            { point = "TOPLEFT", xy = { 239, -384 } },
            { point = "TOPLEFT", xy = { 411, -379 } },
            { point = "TOPLEFT", xy = { 481, -318 } },
            { point = "TOPLEFT", xy = { 503, -236 } },
            { point = "TOPLEFT", xy = { 472, -146 } },
            { point = "TOPLEFT", xy = { 415, -92 } },

            [100] = { xy = { 326, -235 }, isNPC = "b" .. bossIndex },
        }

        --[[

]]
        local xy = {
            { 239, -150 }, -- 星星
            { 208, -200 }, -- 大饼
            { 211, -268 }, -- 紫菱
            { 247, -324 }, -- 三角
            { 411, -322 },
            { 442, -266 },
            { 438, -200 },
            { 412, -143 },
        }
        for index = 1, 8 do
            local left = mod((index - 1) / 4, 1);
            local right = left + 0.25;
            local top = floor((index - 1) / 4) * 0.25;
            local bottom = top + 0.25;
            tbl[index + 80] = {
                xy = xy[index],
                isNPC = true,
                isNPC_help = true,
                isNPC_icon = [[Interface\TargetingFrame\UI-RaidTargetingIcons]],
                coord = { left, right, top, bottom },
                notMask = true,
            }
        end

        local function AutoFuc()
            if TJ.Is10Man() then
                local dpstbl = TJ.SortRaidRosterInfo(nil, "dps", true)
                for i, num in ipairs({ 2, 3, 4, 7, 8, 9, }) do
                    for i, v in ipairs(dpstbl) do
                        TJ.SetMapIconPlayerFormNum(num, v)
                        tremove(dpstbl, i)
                        break
                    end
                end
            else
                local dpstbl = TJ.SortRaidRosterInfo(nil, "dps2", true)
                for i, v in ipairs(dpstbl) do
                    TJ.SetMapIconPlayer(v)
                end
                local dpstbl = TJ.SortRaidRosterInfo(nil, "dps1", true)
                for i, v in ipairs(dpstbl) do
                    TJ.SetMapIconPlayer(v)
                end
            end
        end
        local text = {
            L["安排远程DPS在1-10号位置。"],
            L["安排近战DPS在11-20号位置。"],
        }

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local width = 650
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1075 * 783)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["打小软"])
    end

    -- 坦克
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for _, i in ipairs({ 1, 3, 2 }) do
                for ii, v in ipairs(tbl) do
                    TJ.SetEditTextFormNum(v, title, i)
                    tremove(tbl, ii)
                    break
                end
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["BOSS1坦"])
        TJ.CreateEdit(FB, bossIndex, L["BOSS2坦"])
        TJ.CreateEdit(FB, bossIndex, L["小怪坦"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 换嘲
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136050, },
                            colorNum = 2,
                        },
                    },
                    destNpcType = { "Player" },
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
                    notShowCount = true,
                },
                title = { name = L["畸形之血"], icon = 136050 }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 137000, },
                            colorNum = 2,
                        },
                    },
                    destNpcType = { "Player" },
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
                    notShowCount = true,
                },
                title = { name = L["黑血"], icon = 137000 }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_reincarnation", L["换嘲"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 原生打击
    do
        local info = {
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                136037
                            },
                            colorNum = 1
                        },
                    },
                    destNpcType = { "Player" },
                },
                canSend = "count",
                title = { name = L["受到%s伤害"]:format(L["原生打击"]) }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_hand_1h_bwdraid_d_01", L["原生打击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 进化
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136209, },
                            colorNum = 1,
                        },
                    },
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 136210, },
                            colorNum = 1,
                        },
                        {
                            spellID = { 136215, },
                            colorNum = 1,
                        },
                        {
                            spellID = { 136218, },
                            colorNum = 1,
                        },
                        {
                            spellID = { 136225, },
                            colorNum = 1,
                        },
                        {
                            spellID = { 136245, },
                            colorNum = 1,
                        },
                        {
                            spellID = { 136246, },
                            colorNum = 1,
                        },
                    },
                    showIcon = true
                },
                title = { name = L["特殊技能"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_deathwing_bloodcorruption_death", L["进化"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 完全变异
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 140546, },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "achievement_boss_primordius", L["完全变异"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小软
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    69069
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_bloodnova", L["转火小软"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火大软
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    69070
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_yorsahj_bloodboil_black", L["转火大软"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
