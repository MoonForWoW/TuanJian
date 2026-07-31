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
local FB = "ZUGtitan"
local bossIndex = 3
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

    -- 坦克
    do
        local function AutoFuc(title)
            local dk = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "tank", true)
            for i, v in ipairs(dk) do
                TJ.SetEditTextFormNum(v, title, 1)
                tremove(dk, i)
                break
            end
            local fq = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
            for i, v in ipairs(fq) do
                TJ.SetEditTextFormNum(v, title, 2)
                tremove(fq, i)
                break
            end
            local tbl = TJ.SortRaidRosterInfo({ "WARRIOR", "DRUID" }, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            for i, v in ipairs(dk) do
                TJ.SetEditText(v, title)
            end
            for i, v in ipairs(fq) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["小怪"])
    end

    -- 净化图腾
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排萨满。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_diseasecleansingtotem", L["净化图腾"],
            text, { "SHAMAN" }, nil, nil)
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
        TJ.CreateEdit(FB, bossIndex, L["插净化图腾"])
    end


    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 腐蚀之毒
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                               24111
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                }
            },
            {
                dispel = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                               24111,
                            },
                            colorNum = 1
                        }
                    },
                },
                title = { name = L["驱散腐蚀之毒"] },
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_corrosivebreath", L["腐蚀之毒"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 包围之网
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                6615,
                            },
                            colorNum = 6,
                        },
                        {
                            spellID = {
                                24110,
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                6615,
                            },
                            colorNum = 6,
                        },
                    },
                    showCount = true,
                },
                canSend = "count",
                title = { name = L["自由行动药水"], icon = 6615 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_earthbind", L["包围之网"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 自由行动药水
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            6615,
                        },
                        colorNum = 6,
                    },
                },
                showCount = true,
            },
            canSend = "count",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_potion_04", L["自由行动"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火小怪
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    15041, 11388
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_hunter_pet_spider", L["转火小怪"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.AddDispelInfo(19448, 4, FB, bossIndex) -- 19448/毒药
    TJ.AddDispelInfo(24099, 4, FB, bossIndex) -- 24099/毒箭之雨
    TJ.AddDispelInfo(24111, 4, FB, bossIndex) -- 24111/腐蚀之毒

    
    mainFrame.BOSS_SAY = function(msg)
        if msg:match("") then
            return
        end
    end
end
