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
local FB = "TES"
local bossIndex = 2
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
            { point = "TOPLEFT", xy = { 246, -454 } },
            { point = "TOPLEFT", xy = { 183, -430 } },
            { point = "TOPLEFT", xy = { 117, -357 } },
            { point = "TOPLEFT", xy = { 96, -304 } },
            { point = "TOPLEFT", xy = { 97, -190 } },
            { point = "TOPLEFT", xy = { 126, -138 } },
            { point = "TOPLEFT", xy = { 182, -83 } },
            { point = "TOPLEFT", xy = { 236, -56 } },
            { point = "TOPLEFT", xy = { 354, -59 } },
            { point = "TOPLEFT", xy = { 406, -82 } },
            { point = "TOPLEFT", xy = { 481, -147 } },
            { point = "TOPLEFT", xy = { 501, -197 } },
            { point = "TOPLEFT", xy = { 505, -314 } },
            { point = "TOPLEFT", xy = { 480, -366 } },
            { point = "TOPLEFT", xy = { 411, -429 } },
            { point = "TOPLEFT", xy = { 361, -456 } },
            { point = "TOPLEFT", xy = { 462, -252 } },
            { point = "TOPLEFT", xy = { 133, -252 } },

            --[[

]]

            [100] = { xy = { 299, -252 }, isNPC = "b" .. bossIndex },
        }
        local xy = {
            { 303, -463 }, -- 星星
            { 145, -404 }, -- 大饼
            { 86, -248 },  -- 紫菱
            { 151, -112 }, -- 三角
            { 295, -52 },
            { 450, -108 },
            { 510, -248 },
            { 453, -402 },
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
            if TJ.Is10Man() then
                local nums = { 2, 18, 7, 10, 18, 15, }
                for i, num in ipairs(nums) do
                    for i, v in ipairs(dpstbl) do
                        TJ.SetMapIconPlayerFormNum(num, v)
                        tremove(dpstbl, i)
                        break
                    end
                end
            else
                for i, v in ipairs(dpstbl) do
                    TJ.SetMapIconPlayer(v)
                end
            end
        end
        local text = L["安排DPS在1-18号位置。"] 
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["站位"],
            text)
        local map = TJ.CreateMap(FB, bossIndex, tbl, 600, 506)
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 30, "OUTLINE")
        t:SetPoint("TOPLEFT", 20, -20)
        t:SetText(L["P2站位"])
        local t = map:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 25, "OUTLINE")
        t:SetPoint("BOTTOM", 0, 5)
        t:SetText(L["入口"])
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
            text, TJ.tankClass, nil, nil, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["主坦克"])
        TJ.CreateEdit(FB, bossIndex, L["副坦克"])
    end

    -- 灼日圣光
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
                return
            end
        end
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = { 123716 },
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            canSend = "count",
        }
        local text = L["安排一个治疗。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, 571554, L["灼日圣光"],
            text, TJ.healerClass, nil, info, nil,
            nil)
        TJ.CreateEdit(FB, bossIndex, L["灼日圣光"])
        TJ.CreateEdit(FB, bossIndex, L["灼日圣光"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)
    
    -- 暗影吐息
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            122752,
                        },
                        colorNum = 2
                    },
                },
                destNpcType = { "Player" },
            },
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            122752,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warlock_shadowflame", L["暗影吐息"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 梦魇
    do
        local info = {
            beDamage = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            122777,
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
            },
            canSend = "count",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_soulleech_3", L["梦魇"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 暗影恐怖
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                123011, 123012,
                            },
                            colorNum = 1
                        }
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["暗影恐怖"], icon = 123011 },
                notShowDead = true,
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                123012,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散烛龙的暗影恐怖"], icon = 123011 },
                notShowDead = true,
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                123011,
                            },
                            colorNum = 1
                        }
                    },
                    sourceNpcType = { "Player" },
                },
                title = { name = L["驱散玩家的暗影恐怖"], icon = 123011 },
                notShowDead = true,
            },

            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warlock_everlastingaffliction", L["暗影恐怖"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 无常箭
    do
        local info = {
            interrupt = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            122881,
                        },
                        colorNum = 1
                    },
                },
            },
            notShowDead = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_painspike", L["打断无常箭"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 治疗烛龙
    do
        local info = {
            {
                hps = {
                    type = "s",
                    destNPCID = {
                        62442,
                    },
                },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 123716 },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["灼日圣光"], icon = 123716 }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_wrathv2", L["治疗烛龙"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火煞魔
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        62919,
                    },
                },
                showRaidMember = true,
                canSend = "dps",
                title = { name = L["转火不稳定的煞魔"], icon = "sha_ability_rogue_envelopingshadows" },
            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        62969,
                    },
                },
                showRaidMember = true,
                canSend = "dps",
                title = { name = L["转火恐惧实体"], icon = "sha_ability_rogue_envelopingshadows" },

            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        62977,
                    },
                },
                showRaidMember = true,
                canSend = "dps",
                title = { name = L["转火惊恐的产物"], icon = "sha_ability_rogue_envelopingshadows" },

            },
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        63346,
                    },
                },
                showRaidMember = true,
                canSend = "dps",
                title = { name = L["转火夜之黑暗"], icon = "sha_ability_rogue_envelopingshadows" },

            },
            isMany = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "sha_ability_rogue_envelopingshadows", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end
    -- 转火
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    62919, 62969, 62977,
                },
            },
            showRaidMember = true,
            canSend = "dps",
            title = { name = L["转火（P2所有小怪合计）"], icon = "sha_ability_rogue_envelopingshadows" },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "sha_ability_rogue_envelopingshadows", L["转火(P2)"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.UNIT_SPELLCAST_SUCCEEDED = function(_, spellID)
        if spellID == 123252 and not TJ.SetCD(mainFrame, 2, spellID) then -- Dread Shadows Cancel
            local t = TJ.GetDurTime()
            for i, v in ipairs(TJ.GetNewCombatLog().otherTime) do
                if v.name == L["白昼"] and t - v.time <= 118 then
                    return
                end
            end
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = t,
                name = L["白昼"],
            })
        elseif spellID == 122767 and not TJ.SetCD(mainFrame, 2, spellID) then -- 恐惧之影
            local t = TJ.GetDurTime()
            for i, v in ipairs(TJ.GetNewCombatLog().otherTime) do
                if v.name == L["黑夜"] and t - v.time <= 118 then
                    return
                end
            end
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = t,
                name = L["黑夜"],
            })
        end
    end
end
