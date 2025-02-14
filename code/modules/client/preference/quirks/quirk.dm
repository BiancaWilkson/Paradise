GLOBAL_LIST_EMPTY(quirk_datums)
/datum/quirk
	/// Name of the quirk. It's important that the basetypes don't have a name, and that any quirks you want people to see to have one.
	var/name
	/// The (somewhat) IC explanation of what this quirk does, to be shown in the TGUI menu.
	var/desc = "Uh oh sisters! No description!"
	/// A positive or negative number, good quirks should be 1 to 4, bad quirks should be -1 to -4
	var/cost = 0
	/// The mob that this quirk gets applied to.
	var/mob/living/carbon/human/owner
	/// If only organic characters can have it
	var/organic_only = FALSE
	/// If only IPC characters can have it
	var/machine_only = FALSE
	/// If having this bars you from rolling sec/command
	var/blacklisted = FALSE
	/// If this quirk needs to do something every life cycle
	var/processes = FALSE
	/// If this quirk applies a trait, what trait should be applied.
	var/trait_to_apply
	/// If this quirk lets the mob spawn with an item
	var/item_to_give
	/// If there's an item to give, what slot should it be equipped to roundstart?
	var/item_slot = ITEM_SLOT_IN_BACKPACK
	/// The path of the organ the quirk should give.
	var/organ_to_give
	/// What organ should be removed (if any). Must be the string name of the organ as found in the has_organ var from the species datum.
	var/organ_slot_to_remove

/datum/quirk/Destroy(force, ...)
	remove_quirk_effects()
	owner = null
	..()

/*
* The proc for actually applying a quirk to a mob, most often during spawning.
*/
/datum/quirk/proc/apply_quirk_effects(mob/living/carbon/human/quirky)
	SHOULD_CALL_PARENT(TRUE)
	if(!quirky)
		log_debug("[src] did not find a mob to apply its effects to.")
		return FALSE
	owner = quirky
	owner.quirks += src
	if(processes)
		START_PROCESSING(SSobj, src)
	if(trait_to_apply)
		ADD_TRAIT(owner, trait_to_apply, "quirk")
	if(organ_slot_to_remove)
		RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(remove_organ))
	if(organ_to_give)
		RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(give_organ))

/datum/quirk/proc/remove_organ()
	SIGNAL_HANDLER //COMSIG_GLOB_JOB_AFTER_SPAWN
	var/obj/item/organ/to_remove = owner.get_organ_slot(organ_slot_to_remove)
	INVOKE_ASYNC(to_remove, TYPE_PROC_REF(/obj/item/organ/internal, remove), owner, TRUE)

/datum/quirk/proc/give_organ()
	SIGNAL_HANDLER //COMSIG_GLOB_JOB_AFTER_SPAWN
	var/obj/item/organ/internal/cybernetic = new organ_to_give
	INVOKE_ASYNC(cybernetic, TYPE_PROC_REF(/obj/item/organ/internal, insert), owner, TRUE)

/// For any behavior that needs to happen before a quirk is destroyed
/datum/quirk/proc/remove_quirk_effects()
	SHOULD_CALL_PARENT(TRUE)
	if(trait_to_apply)
		REMOVE_TRAIT(owner, trait_to_apply, "quirk")
	if(processes)
		STOP_PROCESSING(SSprocessing, src)

/********************************************************************
*   Mob Procs, mostly for many mob/new_player in the lobby screen 	*
 ********************************************************************/
/mob/proc/add_quirk_to_save(datum/quirk/to_add)
	var/datum/character_save/active_character = src.client?.prefs?.active_character
	if(!active_character)
		return FALSE
	if(to_add.organic_only && (active_character.species == "Machine"))
		to_chat(src, "<span class='warning'>You can't put that quirk on a robotic character.</span>")
		return FALSE
	if(to_add.machine_only && (active_character.species != "Machine"))
		to_chat(src, "<span class='warning'>You can't put that quirk on an organic character.</span>")
		return FALSE
	active_character.quirks += to_add
	return TRUE

/// Returns true if a quirk was removed, false otherwise
/mob/proc/remove_quirk_from_save(datum/quirk/to_remove)
	var/datum/character_save/active_character = src.client?.prefs?.active_character
	if(!active_character)
		return FALSE
	for(var/datum/quirk/quirk in active_character.quirks)
		if(quirk.name == to_remove.name)
			active_character.quirks.Remove(quirk)
			return TRUE
	return FALSE

/// An admin-only proc for adding quirks directly to a mob. This won't do anything for quirks that give items/organs though since those are effects on spawn
/mob/living/carbon/human/proc/force_add_quirk()
	var/quirk_name = tgui_input_list(src, "What quirk do you want to add to [src]?", "Quirk to add", GLOB.quirk_datums)
	if(!quirk_name)
		return
	var/datum/quirk/to_add = GLOB.quirk_datums[quirk_name]
	to_add.apply_quirk_effects(src)

/// An admin only proc for removing quirks directly from mobs
/mob/living/carbon/human/proc/force_remove_quirk()
	var/datum/quirk/to_remove = tgui_input_list(src, "What quirk do you want to remove from [src]?", "Quirk to remove", src.quirks)
	if(!to_remove)
		return
	qdel(to_remove)

