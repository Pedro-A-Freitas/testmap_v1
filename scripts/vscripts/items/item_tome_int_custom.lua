item_tome_int_custom = class({})

function item_tome_int_custom:OnSpellStart()
    if not IsServer() then return end
    local caster = self:GetCaster()
    local item = self

    if caster and caster:IsRealHero() then
        caster:ModifyIntellect(5)
        caster:CalculateStatBonus(true)
        caster:EmitSound("Item.TomeOfKnowledge.Consume")

        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("destroy_item"), function()
            if not item:IsNull() then
                item:Destroy()
            end
            return nil
        end, 0.1)
    end
end