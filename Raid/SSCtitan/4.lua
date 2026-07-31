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
local FB = "SSCtitan"
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
                TJ.SetEditTextFormNum(v, title, 3)
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
        local text = TJ.IsTBC and L["萨满+猎人怪优先安排防骑，其余任意坦克。"] or L["BOSS优先安排DKT，萨满+猎人怪优先安排防骑，牧师怪任意坦克。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Deathknight_BloodPresence", L["坦克"],
            text, TJ.tankClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["牧师怪"])
        TJ.CreateEdit(FB, bossIndex, L["萨满+猎人怪"])
    end
    -- 治疗
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
            local done = {}
            for i, v in ipairs(tbl) do
                if not done[1] then
                    TJ.SetEditTextFormNum(v, title, 1)
                    done[1] = true
                elseif not done[3] then
                    TJ.SetEditTextFormNum(v, title, 3)
                    done[3] = true
                else
                    TJ.SetEditText(v, title)
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "SHAMAN", "DRUID" }, "healer", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["安排治疗。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "Spell_Holy_HolyBolt", L["治疗"],
            text, TJ.healerClass, nil, nil, nil,
            true)
        TJ.CreateEdit(FB, bossIndex, L["BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["牧师怪"])
        TJ.CreateEdit(FB, bossIndex, L["萨满+猎人怪"])
        TJ.CreateEdit(FB, bossIndex, L["萨满+猎人怪"])
        TJ.CreateEdit(FB, bossIndex, L["萨满+猎人怪"])
    end
    -- 打断小怪
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo({ "ROGUE", "DEATHKNIGHT", "WARRIOR", "SHAMAN" }, "dps1", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 38330 },
                        },
                    },
                },
                title = { name = L["漏打断"], color = { 1, 0, 0 } },
                canSend = "count",
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                38330
                            },
                        },
                    },
                },
                title = { name = L["成功打断"] }
            },
        }
        local text = L["安排近战DPS。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_magicimmunity", L["打断牧师怪加血"],
            text, nil, nil, info, nil,
            nil, 2)
        TJ.CreateEdit(FB, bossIndex, L["打断牧师怪加血"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 转火溅火图腾
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = {
                        22091
                    },
                },
                canSend = "dps",
                title = { name = L["转火溅火图腾"] }
            },
            {
                beDamage = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                38296,
                            },
                            colorNum = 1,
                        }
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { name = L["被灼烧"] }
            }
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_fire_searingtotem", L["溅火图腾"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 所有图腾
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    22091, 22487, 22486
                },
            },
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_strengthofearthtotem02", L["转火所有图腾"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 飓风
    do
        local info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            39261
                        },
                        colorNum = 1,
                    }
                },
                destNpcType = { "Player" },
            },
            notShowDead = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_nature_cyclone", L["飓风"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    mainFrame.SPELL_CAST_SUCCESS = function(...)
        local tbl = { ... }
        local spell = tbl[12]
        if spell == 38451 then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "MS死",
            })
        elseif spell == 38455 then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "LR死",
            })
        elseif spell == 38452 then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "SM死",
            })
        end
    end
end
