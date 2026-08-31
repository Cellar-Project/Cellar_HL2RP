# Decouple ixhl2rp from lost Cellar assets
## Problem statement
The schema relies on a large amount of server-specific content that is no longer available: custom UI textures and sounds, item/world models, ID card models, some custom weapon models, and a number of one-off custom meshes. Based on the audit, the surviving assets are mainly the playable character models under `models/cellar/characters/...` and related CCA/OTA/citizen variants. In its current state, the schema will load with missing-material errors, `models/error.mdl` placeholders, broken UI presentation, and a few unrelated Lua bugs that should be fixed at the same time.
The goal is to make `gamemodes/ixhl2rp` runnable and maintainable without the lost asset pack, while still allowing the original assets to be restored later without another refactor.
## Current state
The main dependency clusters are:
* Custom UI plugins: `plugins/!sc_cellargui`, `plugins/!sc_cellarhud`, and `plugins/!sc_citizenhud` use many `Material("cellar/...")` and `cellar/ui/...` sound references. Examples include `plugins/!sc_cellargui/gui/cl_cellarmenu.lua`, `plugins/!sc_cellargui/gui/cl_watermark.lua`, `plugins/!sc_cellargui/gui/cl_cellarinformation.lua`, `plugins/!sc_cellargui/gui/cl_cellarscoreboard.lua`, and the HUD files in `plugins/!sc_cellarhud/derma`.
* Chat and schema presentation: `schema/sh_hooks.lua` uses `cellar/chat/*.png` icons for several chat classes.
* Item models: many items in `plugins/items_clothing`, `plugins/items_mpf`, `plugins/zoutlands`, `plugins/!reagents`, `plugins/citizenids`, and `plugins/radio` point to lost models such as `models/cellar/items/...`, `models/cellar/weapons/...`, and `models/vintagethief/cellarproject/cid_card.mdl`.
* Holstered weapon display: `plugins/holsteredswep.lua` references lost Cellar weapon worldmodels where stock HL2 equivalents exist.
* Animation registration: `plugins/cellaranims.lua` binds many preserved player models correctly, but also contains many one-off bindings to custom/nonessential meshes and at least one malformed model path.
* Faction definitions: most faction model lists in `schema/factions/*.lua` point to preserved player-character models, but the code assumes those lists are always valid and does not degrade gracefully if a variant is missing.
* Zombie/apocalypse support: `plugins/apocalypse/sh_plugin.lua` maps player models to non-stock zombie models that are likely missing too.
## Proposed changes
### 1. Add a centralized asset fallback layer
Create a small schema-level asset helper, loaded early from `schema/sh_schema.lua`, that centralizes missing-asset handling for materials, sounds, and models.
It should expose helpers along the lines of:
* `Schema.assets.Material(path, fallbackPath)`
* `Schema.assets.Model(path, fallbackPath)`
* `Schema.assets.Sound(path, fallbackPath)`
* optionally a small font fallback registry for the custom UI fonts
The helper should cache lookup results so UI paint hooks do not repeatedly hit disk checks. This becomes the single place where the project decides what to do when a Cellar asset is gone.
Alongside it, add a manifest file that maps the lost Cellar asset paths to sane stock replacements. That keeps the rest of the code clean and makes it easy to restore the original assets later by editing one manifest instead of rewriting gameplay code again.
### 2. Refactor the Cellar UI to use fallbacks instead of hard failures
Update the custom UI plugins so they stop depending directly on `materials/cellar/*` and `sound/cellar/ui/*`.
Key files include:
* `plugins/!sc_cellargui/gui/cl_cellarmenu.lua`
* `plugins/!sc_cellargui/gui/cl_watermark.lua`
* `plugins/!sc_cellargui/gui/cl_cellarinformation.lua`
* `plugins/!sc_cellargui/gui/cl_cellarinventory.lua`
* `plugins/!sc_cellargui/gui/cl_cellarsettings.lua`
* `plugins/!sc_cellargui/gui/cl_cellarscoreboard.lua`
* `plugins/!sc_cellargui/gui/cl_cellarbutton.lua`
* `plugins/!sc_cellarhud/derma/cl_cellarbar.lua`
* `plugins/!sc_cellarhud/derma/cl_cellarneeds.lua`
* `plugins/!sc_citizenhud/cl_cellarcitizenhud.lua`
The refactor should:
* replace raw `Material("cellar/...")` construction with the asset helper
* replace raw `surface.PlaySound("cellar/ui/...")` and `EmitSound("cellar....")` usage with fallback-aware sound names
* replace fragile custom fonts (`Nagonia`, `Geometria`, some `Open Sans` variants) with guaranteed-safe fallbacks when the original font family is not available
This keeps the Cellar-styled layout code intact, but makes it render with vanilla-safe visuals instead of pink/black missing textures.
### 3. Introduce safe default replacements for item and card models
Replace direct `ITEM.model = "models/cellar/..."` style dependencies with fallback-aware model assignment in the item files that currently point to lost meshes.
The main groups are:
* `plugins/items_clothing/items/equipment/*`
* `plugins/items_clothing/items/gasmask/*`
* `plugins/items_mpf/items/outfitmpf/*`
* `plugins/items_mpf/items/base/*`
* `plugins/zoutlands/items/equipment/*`
* `plugins/zoutlands/items/outfitota/*`
* `plugins/!reagents/items/reagent_holder/*`
* `plugins/citizenids/items/cards/*`
* `plugins/citizenids/items/sh_ota_access.lua`
* `plugins/radio/items/base/sh_radios.lua`
Use stock HL2 props as temporary stand-ins where necessary, grouped by purpose rather than trying to match the original look exactly. For example, cards should share one small placeholder model, generic clothing and armor can share a consistent placeholder prop, and lost reagent containers can use a small stock bottle or jar model.
This is the highest-value gameplay change after the UI work, because it prevents inventory, loot, and ID systems from visually breaking everywhere.
### 4. Normalize faction model handling around the surviving player models
The existing faction files mostly point at preserved player-character models, but the schema still assumes every listed path exists and that every faction should keep its exact old model pool forever.
Audit and normalize the model lists in:
* `schema/factions/*.lua`
* `plugins/zz_dispatch/factions/*.lua`
The implementation should prune or replace missing entries at load time and ensure every faction has at least one valid model. For factions whose only listed model turns out to be unavailable, fall back to the nearest surviving faction-compatible model instead of allowing character creation or transfers to break.
This also gives the project a cleaner base for future faction cleanup and makes the character creation UI much more robust.
### 5. Swap obvious lost weapon/world models for stock HL2 ones
Some missing models already have stock replacements and do not need a generic placeholder.
The clearest example is `plugins/holsteredswep.lua`, which uses lost Cellar worldmodels for SMG/shotgun display even though stock HL2 models already exist. Replace those references with stock worldmodels directly or route them through the asset helper manifest.
This same pass should also catch any other direct `models/cellar/weapons/...` references where there is a one-to-one HL2 equivalent.
### 6. Make the apocalypse plugin independent from missing zombie packs
`plugins/apocalypse/sh_plugin.lua` currently maps living character models to a set of custom zombie/freshdead models that are also likely absent. That means the infection system is still coupled to another lost asset pack even after the player-model issue is solved.
Refactor the model conversion logic so it resolves through the asset helper and falls back to stock HL2 zombie models when the preferred replacements are missing. This preserves the gameplay mechanic without forcing installation of the original zombie content pack.
### 7. Replace chat icon dependencies with built-in materials
`schema/sh_hooks.lua` uses Cellar chat icons for IC/whisper/yell/dispatch/broadcast/roll messages. Those should be routed through the asset helper and mapped to either Helix-shipped UI materials or simple stock Source/GMod icon materials.
That preserves the custom chat classes while removing one more dependency on `materials/cellar/chat/*`.
## Bugs to fix during the same pass
These are worth folding into the same effort because they either directly affect stability or were exposed during the asset audit.
### 1. Broken `DoorKick` access logic
In `schema/sh_commands.lua`, the `DoorKick` access check denies the command unless the player is both Combine and marked with the zombie flag. The condition is inverted for the likely intended behavior. It should be rewritten after deciding whether the command is supposed to be available to Combine units, infected characters, or both.
### 2. Typo in apocalypse zombie model path
`plugins/apocalypse/sh_plugin.lua` contains `models/freshdead/freshdead_01.mdll` instead of `.mdl`. That is an actual broken path and should be corrected even if the wider zombie-model fallback work is deferred.
### 3. Undefined variable in Combine display timer
`schema/cl_hooks.lua` uses `client` inside `Schema:CharacterLoaded`'s timer callback even though no `client` exists in that scope. This should use `LocalPlayer()` or another properly-scoped player reference. As written, the random Combine display updates are unreliable/broken clientside.
### 4. Duplicate `Schema:InitializedChatClasses` definitions
`schema/sh_hooks.lua` defines `Schema:InitializedChatClasses` twice. The later definition overwrites the earlier one, which is fragile and confusing. Merge the chat registration and chat-language registration into one hook implementation.
### 5. Duplicate Metropolice faction source of truth
There are overlapping CCA/Metropolice definitions in `schema/factions/sh_metropolice.lua` and `plugins/zz_dispatch/factions/sh_metropolice.lua`. They both assign `FACTION_MPF`, which makes load order matter and creates unnecessary ambiguity. Consolidate them into one authoritative faction definition and move any dispatch-specific behavior onto that shared definition.
### 6. Missing scoreboard class for dispatch police variants
`plugins/zz_dispatch/factions/sh_overseer.lua` uses `scoreboardClass = "scMPF"`, but `schema/cl_schema.lua` only defines `scCityAdm`, `scCWU`, and `scOTA`. Either add `scMPF` explicitly or reuse a valid class name.
### 7. Broken animation binding path
`plugins/cellaranims.lua` contains a malformed path for `models/cellar/custom/valk_female` without a `.mdl` extension. Fix the path or remove the binding if that model no longer exists.
### 8. Dead class-button logic referencing undefined factions
`plugins/!sc_cellargui/gui/cl_cellarinformation.lua` checks `FACTION_ZOMBIE` and `FACTION_SYNTH`, but those factions are not defined in the audited schema/plugins. Either define them properly where intended or remove the dead UI path.
### 9. Damage-system chat should not hard-assume anonymous plugin behavior
`plugins/!damagesystem` calls `GetAnonID()` in chat output paths. It currently works only because `plugins/!!!anonymous` loads first. Add defensive checks so the damage system still works if that plugin is missing, renamed, or disabled.
### 10. Move fragile font creation out of early file scope
Several Cellar UI files create fonts immediately at file scope using screen-dependent sizing. This is brittle and should be centralized in a proper font-loading hook so fonts initialize predictably and can participate in the fallback system.
## Migration strategy
Implement the decoupling in layers so the schema becomes usable quickly:
1. Add the asset helper and manifest first.
2. Convert the Cellar UI plugins and chat icons to use it.
3. Convert item/card/world models.
4. Audit faction models and holstered weapon models.
5. Fix the identified bugs.
6. Do a final sweep for any remaining direct `models/cellar`, `materials/cellar`, `cellar/ui`, and `models/vintagethief/cellarproject` references in `gamemodes/ixhl2rp`.
This order gives the fastest improvement in playability while keeping the changes easy to review.
## Validation
After implementation, validate in three ways:
* Static asset audit: grep for remaining hard-coded lost asset roots such as `models/cellar/items`, `models/cellar/weapons`, `materials/cellar`, `cellar/ui`, and `models/vintagethief/cellarproject` inside `gamemodes/ixhl2rp`.
* Runtime smoke test in a local server: open the character menu, open the custom TAB menu, inventory, settings, scoreboard, help, and at least one Combine display path; confirm there are no missing-material panels or missing-sound errors.
* Gameplay smoke test: spawn as citizen/CCA/OTA/Admin/CWU, equip clothing and ID items, verify holstered weapons, chat icons, and apocalypse infection fallback models.
## Expected result
After this work, the schema will no longer be tied to the lost Cellar asset pack for basic functionality. The project will still support the original look and models if those assets are restored later, but in the meantime it will run cleanly with fallback visuals, usable UI, valid item models, preserved player-character models, and a cleaner codebase with several long-standing bugs removed.