local function initTraits()
    TraitFactory.addTrait(
        "NotAPickyEater",
        getText("UI_trait_NotAPickyEater"),
        1,
        getText("UI_trait_NotAPickyEaterdesc"),
        false,
        false
    )
    TraitFactory.addTrait(
        "RefinedPalate",
        getText("UI_trait_RefinedPalate"),
        -2,
        getText("UI_trait_RefinedPalatedesc"),
        false,
        false
    )
    TraitFactory.setMutualExclusive("NotAPickyEater", "RefinedPalate")
end

Events.OnGameBoot.Add(initTraits)
