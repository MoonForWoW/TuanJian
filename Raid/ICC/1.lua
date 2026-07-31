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
local bossIndex = 1
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
    -- 沙包
    do
        local function AutoFuc(title)
            local function Set(tbl)
                if not tbl then return end
                for i, v in ipairs(tbl) do
                    if TJ.SetEditTextFormNum(v, title, 5) then
                        tremove(tbl, i)
                    end
                    break
                end
                for i, v in ipairs(tbl) do
                    if TJ.SetEditTextFormNum(v, title, 9) then
                        tremove(tbl, i)
                    end
                    break
                end
                for i, v in ipairs(tbl) do
                    if TJ.SetEditTextFormNum(v, title, 6) then
                        tremove(tbl, i)
                    end
                    break
                end
                for i, v in ipairs(tbl) do
                    if TJ.SetEditTextFormNum(v, title, 10) then
                        tremove(tbl, i)
                    end
                    break
                end
            end
            local tbl = TJ.SortRaidRosterInfo({ "HUNTER" }, "dps", true)
            Set(tbl)
            local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
            Set(tbl)
        end
        local text = L["安排猎人/暗牧在6/9点。"]
        TJ.CreateTitle(FB, bossIndex, AutoFuc, "ability_druid_cyclone", L["沙包"],
            text, nil, nil, nil, nil,
            nil, 2)
        TJ.CreateEdit(FB, bossIndex, L["3点沙包"])
        TJ.CreateEdit(FB, bossIndex, L["3点沙包"])
        TJ.CreateEdit(FB, bossIndex, L["4点沙包"])
        TJ.CreateEdit(FB, bossIndex, L["4点沙包"])
        TJ.CreateEdit(FB, bossIndex, L["6点沙包"])
        TJ.CreateEdit(FB, bossIndex, L["6点沙包"])
        TJ.CreateEdit(FB, bossIndex, L["8点沙包"])
        TJ.CreateEdit(FB, bossIndex, L["8点沙包"])
        TJ.CreateEdit(FB, bossIndex, L["9点沙包"])
        TJ.CreateEdit(FB, bossIndex, L["9点沙包"])
        TJ.CreateEdit(FB, bossIndex, L["12点沙包"])
        TJ.CreateEdit(FB, bossIndex, L["12点沙包"])
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

    -- 转火骨针
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = {
                    36619, 
                },
            },
            showRaidMember = true,
            canSend = "dps",
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "inv_misc_bone_03", L["转火骨针"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    local function func(...)
        local arg = { ... }
        local destGUID = arg[8]
        if destGUID == 36612 then
            local spellID = arg[12]
            if spellID == 69076 then
                local event = arg[2]
                tinsert(TJ.GetNewCombatLog().otherTime, {
                    time = TJ.GetDurTime(),
                    name = event == "SPELL_AURA_APPLIED" and "P2" or "P1",
                })
            end
        end
    end
    TJ.frame[FB][bossIndex].SPELL_AURA_APPLIED = func
    TJ.frame[FB][bossIndex].SPELL_AURA_REMOVED = func
end