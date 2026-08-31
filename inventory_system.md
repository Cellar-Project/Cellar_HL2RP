# Stop random item loss in the Cellar HL2RP inventory system
## Problem statement
Over weeks of busy play, items disappear from player inventories at random, with equipment items disproportionately affected. The losses are silent (no errors, no logs) and have resisted prior investigation. The goal is to eliminate the root causes while keeping every existing behavior intact: drag-drop moves, cross-inventory transfers, bags, the `item_flipping` plugin's flip semantics, and the custom `!sc_cellargui` UI must all continue to work.
## Current state
The item lifecycle is split across:
* Helix core: `gamemodes/helix/gamemode/core/meta/sh_inventory.lua` (the inventory metatable: `Add`, `Remove`, `CanItemFit`, `Sync`, `SendSlot`), `gamemodes/helix/gamemode/core/libs/sh_inventory.lua` (the original `ix.inventory.Restore`), `gamemodes/helix/gamemode/core/libs/sh_item.lua` (the original `net.Receive("ixInventoryMove")`, item instance creation, transfers).
* `gamemodes/ixhl2rp/plugins/!!inventoryenhances/meta/sh_inventory.lua` overrides `META:Add`, `META:CanItemFit`, and adds `META:GetItemAtSlot`, plus `ITEM:Transfer`. It declares `MAX_EQUIPMENT_SLOTS = 16`.
* `gamemodes/ixhl2rp/plugins/!!inventoryenhances/sv_hooks.lua` replaces the `ixInventoryMove` handler, adds split/combine flows, runs `CharacterLoaded` on respawn, and creates the equipment inventory.
* `gamemodes/ixhl2rp/plugins/item_flipping/sv_plugin.lua` replaces `ix.inventory.Restore` with a version that applies `RawFlip` based on `item.data.flip` before placement. It also adds `ITEM:Flip` and an `ixInventoryFlipItem` net handler. **Any restore-time fix MUST live in this override, not in Helix core, because the override fully replaces the original.**
* `gamemodes/ixhl2rp/plugins/item_flipping/cl_plugin.lua` also overrides the client-side `ixInventorySync` net handler and applies `FixFlip` per item.
The concrete defects that produce silent item loss:
1. `ix.inventory.Restore` (current implementation in `item_flipping/sv_plugin.lua:213-214`) silently skips any row where `x <= 0`, `y <= 0`, `x > inventory.w`, or `y > inventory.h`. The DB row is NOT deleted, but the item never reaches `ix.item.instances` after the restart/relog, so it is gone from the player's perspective.
2. The Move handler at `!!inventoryenhances/sv_hooks.lua:209-313` trusts client-supplied `oldX/oldY/x/y` (each a `UInt(6)`, range 0-63). The equipment branch at line 250-252 does `inventory.slots[1][oldY] = nil` then `inventory.slots[1][y] = item` without bounds-checking against `MAX_EQUIPMENT_SLOTS` or forcing `x=1`. A bad packet or stale UI state can save `x=0`, `y=0`, or `y>16` to the DB, then defect #1 erases the item on next restore.
3. The same equipment branch only clears `slots[1][oldY]`, not the full `slots[1][oldY .. oldY+item.height-1]`. Equipment outfits with `height>1` leak stale slot references that block legitimate placements and corrupt subsequent `Add`/`Remove` cycles.
4. `PLUGIN:OnPlayerRespawn` (`sv_hooks.lua:472-478`) re-runs `PLUGIN:CharacterLoaded` on every respawn. The `else` branch (line 432-440) calls `ix.inventory.New` whenever `character:GetEquipID()` returns `0`. Because `SetEquipID` is set inside an async DB callback, two respawn ticks within the creation window can produce two `ix_inventories` rows, leaving the original row orphaned together with every item in it.
5. The equipment inventory's `vars.isEquipment` flag is only set by `CharacterLoaded`, AFTER `ix.char.Restore` already loaded all items. In the gap between restore and CharacterLoaded, `Add` / `CanItemFit` / Move use the non-equipment branches against the equipment inventory and can write items into `slots[x>1][y]`. Defect #1 then erases them.
6. `META:Remove` only iterates `1..self.w`. On equipment, that's `x=1` only. Any item ever placed in `slots[x>=2]` cannot be cleaned out by Remove; it lingers in memory until the next reload.
7. `Add` for equipment in `!!inventoryenhances/meta/sh_inventory.lua` writes `targetInv.slots[1][y] = item` without verifying `1 <= y <= MAX_EQUIPMENT_SLOTS` and without crashing-safe init of `slots[1]` on the move handler path.
## Proposed changes
Deliver this as a layered patch that gets safer with every layer; each layer can be reasoned about independently and preserves prior behavior in the common case.
### 1. Repair-on-restore: stop silently dropping items
Replace the silent skip in `item_flipping/sv_plugin.lua`'s `ix.inventory.Restore` override with a coordinate-sanitization step:
* If `x` / `y` are missing, non-positive, or out of bounds, attempt to relocate the item via `FindEmptySlot(item.width, item.height, true)`.
* If that succeeds, persist the new coordinates back to `ix_items` so the repair is one-shot, and log the event.
* If the inventory is full, place at the canonical fallback `(1, 1)` (and skip the multi-cell overlap fill) so the item is at least visible and retrievable; log it.
* Add the same fallback path for items whose `inventory_id` references an inventory that was registered for restore but ends up with size `0` (defensive).
* Keep the existing flip behavior intact: the sanitization runs BEFORE the existing `RawFlip` decision so flipped items still resolve to the right dimensions.
This alone converts the catastrophic "item is gone forever" outcome into a recoverable "item shows up somewhere safe" outcome for any historical bad rows.
### 2. Harden the Move handler
In `!!inventoryenhances/sv_hooks.lua`, the `ixInventoryMove` net handler should validate input before writing:
* Reject the move entirely if `oldX`, `oldY`, `x`, or `y` is `0`, or if they exceed `inventory.w` / `inventory.h`. Send a corrective `ixInventoryMove` back to the client so the icon snaps to the real server position.
* For equipment, force `x = 1` and require `1 <= y <= MAX_EQUIPMENT_SLOTS`; otherwise reject.
* Replace the equipment slot-clear with a loop over `item.height` and guarantee `inventory.slots[1] = inventory.slots[1] or {}` before touching either cell.
* Same for the place-into-new-slot loop in the equipment branch.
This stops new items from ever being written with corrupt coordinates and stops the multi-cell ghost-reference leak.
### 3. Harden `META:Add` for equipment
In `!!inventoryenhances/meta/sh_inventory.lua`, both the `isnumber(uniqueID)` branch (existing item) and the new-item branch should:
* When `targetInv.vars.isEquipment` is true, force `x = 1` and clamp `y` into `[1, MAX_EQUIPMENT_SLOTS]`.
* Bail out cleanly with `false, "noFit"` if a clamp would change `y`, rather than silently writing to a wrong slot.
* Always pre-init `slots[1]`.
### 4. Generalize `META:Remove` to cover the full slot grid
Override `META:Remove` once in `!!inventoryenhances/meta/sh_inventory.lua` (or extend the helix metatable from there) so that the slot-clearing loop iterates the union of `1..self.w` AND any extra columns that have entries in `self.slots`. Practically: iterate every `x` key currently present in `self.slots`, not just `1..self.w`. This drains lingering ghosts and is a no-op when slots are well-formed.
### 5. Eliminate the equipment inventory race on respawn
In `!!inventoryenhances/sv_hooks.lua`:
* In `PLUGIN:CharacterLoaded`, when `index == 0`, wrap the `ix.inventory.New` call in a per-character guard (`character.ixCreatingEquip = true` until the callback fires). If a second `CharacterLoaded` call enters this branch while the flag is set, it should wait (run the equip work in a queued continuation) instead of triggering a second insert.
* `PLUGIN:OnPlayerRespawn` should NOT re-run `CharacterLoaded` from scratch. Respawn only needs to re-apply equipment effects and resync the inventory; it should not re-decide whether to create equipment storage. Replace the body with a lighter "resync + reapply" path.
### 6. Set `vars.isEquipment` during restore, not after
In `!!inventoryenhances/sv_hooks.lua`, hook into Helix's `ShouldRestoreInventory` (already called by `ix.char.Restore`) or extend the inventory `vars` immediately on the `ix.inventory.Restore` callback so that any inventory whose `inventory_type == "equipment"` has `vars.isEquipment = true` set BEFORE the first item is placed. This closes the window where `Add`/`Move`/`CanItemFit` use the non-equipment branches on the equipment inventory.
### 7. Diagnostic surface
* When the restore-time sanitizer relocates an item, `MsgC` a single line per event with `item_id`, original `(inventory_id, x, y)`, repaired `(inventory_id, x, y)`, and `uniqueID`. This makes it possible to confirm in production that the fix is hitting bad rows and that the bad rows stop appearing.
* Add a server console command `ix_inventory_audit` that runs three read-only queries: rows in `ix_items` with out-of-range `x`/`y` (per inventory size), `ix_items` with no matching `inventory_id` in `ix_inventories`, and `ix_inventories` rows of type `equipment` not referenced by any character's `equipID`. Output counts and a small sample.
## Compatibility notes
* The `item_flipping` plugin owns the canonical `ix.inventory.Restore`. All restore-side fixes live inside its override so the load order continues to work.
* The custom `!sc_cellargui` inventory UI never overrides the server handlers or `Add`/`Remove`/`Restore`; it only consumes the synced state. No UI changes are needed for the fixes to take effect.
* `ITEM:Flip` already validates that the post-flip footprint fits before mutating; that logic is preserved untouched.
* `MAX_EQUIPMENT_SLOTS = 16` and the `EQUIP_*` constants remain the source of truth.
## Validation
* Start the server, join with a test character, drag every equipment slot in and out, confirm no console errors and no visual loss across a manual respawn cycle.
* Run `ix_inventory_audit` before and after applying the patch on a database backup. Confirm: pre-existing out-of-range rows get repaired on the next restore; the live count of out-of-range rows trends to zero after running for a session.
* Targeted regression: a `1x2` torso equipment item moved between slot Y and slot Y+2 must show no ghost references in `slots[1]` afterwards (check via the existing `META:PrintAll` debug method).
* Flip regression: take a `2x1` item, flip it, restart the server, confirm it loads as `1x2` and at the same grid position.
## Expected result
New item loss stops at the source: bad coordinates can no longer be written, equipment is created exactly once per character, and the gap between restore and `CharacterLoaded` no longer treats equipment as a normal grid. Items that were already corrupted in the database get healed the next time their inventory is restored instead of being deleted from the player's view. The audit command provides ongoing visibility so future regressions are caught immediately.