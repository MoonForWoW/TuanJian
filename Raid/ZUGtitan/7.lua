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
local bossIndex = 7
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

    local instanceID = TJ.FBinfo[FB].ID
    TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
    TJ.autoRaidTargetInfo[instanceID][14509] = {
        [8] = true,
        np = true,
    }
    TJ.autoRaidTargetInfo[instanceID][11348] = {
        [7] = true,
        np = true,
    }
    TJ.autoRaidTargetInfo[instanceID][11347] = {
        [6] = true,
        np = true,
    }

    -- 坦克
    do
        local function AutoFuc(title)
            local dk = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "tank", true)
            for i, v in ipairs(dk) do
                TJ.SetEditTextFormNum(v, title, 3)
                tremove(dk, i)
                break
            end
            local fq = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
            for i, v in ipairs(fq) do
                TJ.SetEditTextFormNum(v, title, 1)
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
        TJ.CreateEdit(FB, bossIndex, L["洛卡恩(萨满)"])
        TJ.CreateEdit(FB, bossIndex, L["扎斯(盗贼)"])
    end

    -- 打断
    do
        local function AutoFuc(title)
            local tbl = CopyTable(TJ.SortRaidRosterInfo({ "DEATHKNIGHT", "ROGUE", "WARRIOR", "SHAMAN" }, "dps1", true))
            for i, v in ipairs(tbl) do
                if v.class == "DEATHKNIGHT" then
                    tbl[i].index = 1
                elseif v.class == "ROGUE" then
                    tbl[i].index = 2
                elseif v.class == "WARRIOR" then
                    tbl[i].index = 3
                elseif v.class == "SHAMAN" then
                    tbl[i].index = 4
                end
            end
            sort(tbl, function(a, b)
                if a.index and b.index then
                    return a.index < b.index
                end
                return false
            end)
            local done = {}
            for _, v in ipairs(tbl) do
                for _, i in ipairs({ 1, 3, 2, 4, }) do
                    if not done[i] then
                        TJ.SetEditTextFormNum(v, title, i)
                        done[i] = true
                        break
                    end
                end
            end
        end
        local text = L["优先安排DK/盗贼/战士/增强萨。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_holy_heal", L["打断治疗术"],
            text, nil, nil, nil, nil,
            true, 2)
        TJ.CreateEdit(FB, bossIndex, L["打断BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["打断BOSS"])
        TJ.CreateEdit(FB, bossIndex, L["打断洛卡恩"])
        TJ.CreateEdit(FB, bossIndex, L["打断洛卡恩"])
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 打断
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 24208 },
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
                            spellID = { 24208 },
                        },
                    },
                },
                title = { name = L["成功打断"] }
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_heal", L["打断治疗术"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 冲锋
    do
        local info = {
            {
                castSuccess = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                24193,
                            },
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = L["点名"],
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_warrior_charge", L["冲锋"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    TJ.AddDispelInfo(22666, 1, FB, bossIndex) -- 22666/沉默

    mainFrame.BOSS_SAY = function(msg)
        if msg:match("让我感受你的愤怒吧") then
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P2",
            })
            return
        end
    end
end
