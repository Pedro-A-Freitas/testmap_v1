LinkLuaModifier("modifier_bounty_hunter_track_custom", "abilities/bounty_hunter_track_custom", LUA_MODIFIER_MOTION_NONE)

bounty_hunter_track_custom = class({})

-- Trava de Nível (6/12/18)
function bounty_hunter_track_custom:GetHeroLevelRequiredToUpgrade()
    local level = self:GetLevel()
    if level == 0 then return 6 end
    if level == 1 then return 12 end
    if level == 2 then return 18 end
    return 99
end

function bounty_hunter_track_custom:OnUpgrade()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local nLevel = self:GetLevel()
    if caster:GetLevel() < (({6, 12, 18})[nLevel] or 0) then
        self:SetLevel(nLevel - 1)
        caster:SetAbilityPoints(caster:GetAbilityPoints() + 1)
    end
end

function bounty_hunter_track_custom:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = 10.0

    -- Cooldown de 30 segundos forçado
    self:StartCooldown(30)

    -- Som e Partícula de conjuração
    caster:EmitSound("Hero_BountyHunter.Track")
    
    -- Aplica o Modificador no alvo
    target:AddNewModifier(caster, self, "modifier_bounty_hunter_track_custom", {duration = duration})
end

--------------------------------------------------------------------------------
-- MODIFICADOR DO DEBUFF (TRACK)
--------------------------------------------------------------------------------
modifier_bounty_hunter_track_custom = class({})

function modifier_bounty_hunter_track_custom:IsPurgable() return true end

function modifier_bounty_hunter_track_custom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, -- Amplificação de dano
        MODIFIER_EVENT_ON_DEATH, -- Morte para dar o gold
    }
end

-- AMPLIFICAÇÃO DE DANO (8% 12% 16%)
function modifier_bounty_hunter_track_custom:GetModifierIncomingDamage_Percentage()
    local level = self:GetAbility():GetLevel()
    local amp = {8, 12, 16}
    return amp[level] or 0
end

-- LÓGICA DO GOLD NA MORTE
function modifier_bounty_hunter_track_custom:OnDeath(params)
    if not IsServer() then return end

    if params.unit == self:GetParent() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        local level = ability:GetLevel()

        -- Tabelas de Gold
        local gold_self = {100, 200, 300}
        local gold_ally = {50, 100, 150}

        local self_bonus = gold_self[level]
        local ally_bonus = gold_ally[level]

        -- Partícula de dinheiro no alvo que morreu
        local gold_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_reward.vpcf", PATTACH_ABSORIGIN, params.unit)
        ParticleManager:ReleaseParticleIndex(gold_pfx)

        -- Gold para o Bounty Hunter
        caster:ModifyGold(self_bonus, true, DOTA_ModifyGold_Unspecified)
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, self_bonus, nil)

        -- Gold para Aliados próximos (900 de raio)
        local allies = FindUnitsInRadius(caster:GetTeamNumber(), params.unit:GetAbsOrigin(), nil, 900, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
        
        for _, ally in pairs(allies) do
            if ally ~= caster then
                ally:ModifyGold(ally_bonus, true, DOTA_ModifyGold_Unspecified)
                SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, ally, ally_bonus, nil)
            end
        end
    end
end

-- Efeito visual do Track (o ícone em cima da cabeça)
function modifier_bounty_hunter_track_custom:GetEffectName()
    return "particles/units/heroes/hero_bounty_hunter/bounty_hunter_track_shield.vpcf"
end

function modifier_bounty_hunter_track_custom:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end