LinkLuaModifier("modifier_morphling_attribute_mastery_custom", "abilities/morphling_attribute_mastery_custom", LUA_MODIFIER_MOTION_NONE)

morphling_attribute_mastery_custom = class({})

-- TRAVA DE NÍVEL (6/12/18)
function morphling_attribute_mastery_custom:GetHeroLevelRequiredToUpgrade()
    local level = self:GetLevel()
    if level == 0 then return 6 end
    if level == 1 then return 12 end
    if level == 2 then return 18 end
    return 99
end

function morphling_attribute_mastery_custom:OnUpgrade()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local nLevel = self:GetLevel()
    local heroLevel = caster:GetLevel()
    
    -- Se o nível do herói for menor que o necessário, devolve o ponto
    local requiredLevel = (nLevel == 1 and 6) or (nLevel == 2 and 12) or (nLevel == 3 and 18) or 0
    if heroLevel < requiredLevel then
        self:SetLevel(nLevel - 1)
        caster:SetAbilityPoints(caster:GetAbilityPoints() + 1)
    end
end

function morphling_attribute_mastery_custom:GetIntrinsicModifierName()
    return "modifier_morphling_attribute_mastery_custom"
end

--------------------------------------------------------------------------------
-- MODIFICADOR DOS ATRIBUTOS
--------------------------------------------------------------------------------
modifier_morphling_attribute_mastery_custom = class({})

function modifier_morphling_attribute_mastery_custom:IsHidden() return true end
function modifier_morphling_attribute_mastery_custom:IsPurgable() return false end
function modifier_morphling_attribute_mastery_custom:RemoveOnDeath() return false end

function modifier_morphling_attribute_mastery_custom:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
end

function modifier_morphling_attribute_mastery_custom:GetModifierBonusStats_Strength()
    local ability = self:GetAbility()
    if ability and not ability:IsNull() then
        local level = ability:GetLevel()
        if level > 0 then
            return level * 30 -- 1: 30, 2: 60, 3: 90
        end
    end
    return 0
end

function modifier_morphling_attribute_mastery_custom:GetModifierBonusStats_Agility()
    local ability = self:GetAbility()
    if ability and not ability:IsNull() then
        local level = ability:GetLevel()
        if level > 0 then
            return level * 30
        end
    end
    return 0
end