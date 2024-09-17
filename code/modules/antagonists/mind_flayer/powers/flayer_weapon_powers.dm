/datum/spell/flayer/self/weapon
	name = "Create weapon"
	desc = "This really shouldn't be here"
	power_type = FLAYER_UNOBTAINABLE_POWER
	action_icon = 'icons/mob/robot_items.dmi'
	action_icon_state = "lollipop"
	base_cooldown = 1 SECONDS //This just handles retracting and deploying the weapon, weapon charge will be fully separate
	///Typepath of the weapon
	var/weapon_type
	///Reference to the weapon itself
	var/obj/item/weapon_ref
	///The object that stores a retracted weapon
	var/obj/weapon_holder

/datum/spell/flayer/self/weapon/Destroy(force, ...)
	. = ..()
	weapon_ref = null
	weapon_holder = null

/datum/spell/flayer/self/weapon/cast(list/targets, mob/user)
	if(istype(user.l_hand, weapon_type) || istype(user.r_hand, weapon_type))
		retract(user, TRUE)
		return
	if(!user.drop_item())
		to_chat(user, "[user.get_active_hand()] is stuck to your hand!")
		return FALSE
	if(!weapon_ref)
		weapon_ref = new weapon_type(user, src)
	SEND_SIGNAL(user, COMSIG_MOB_WEAPON_APPEARS)
	user.put_in_hands(weapon_ref)
	weapon_ref.flags |= NODROP
	playsound(get_turf(user), 'sound/mecha/mechmove03.ogg', 50, TRUE)
	RegisterSignal(user, COMSIG_MOB_WILLINGLY_DROP, PROC_REF(retract), user)
	RegisterSignal(user, COMSIG_MOB_WEAPON_APPEARS, PROC_REF(retract), user)
	return weapon_ref

/datum/spell/flayer/self/weapon/proc/retract(mob/owner, any_hand = TRUE)
	SIGNAL_HANDLER // COMSIG_MOB_WILLINGLY_DROP + COMSIG_MOB_WEAPON_APPEARS
	if(!any_hand && !istype(owner.get_active_hand(), weapon_type))
		return
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, unEquip), weapon_ref, TRUE)
	INVOKE_ASYNC(weapon_ref, TYPE_PROC_REF(/atom/movable, forceMove), weapon_holder)
	owner.update_inv_l_hand()
	owner.update_inv_r_hand()
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)
	UnregisterSignal(owner, COMSIG_MOB_WILLINGLY_DROP)
	UnregisterSignal(owner, COMSIG_MOB_WEAPON_APPEARS)

/**
	START OF INDIVIDUAL WEAPONS
*/

/datum/spell/flayer/self/weapon/swarmprod
	name = "Swarmprod"
	desc = "We shape our arm into an extended mass of sparking nanites."
	action_icon_state = "elecarm"
	max_level = 3
	base_cost = 60
	upgrade_info = "Increase the rate at which this recharges."
	power_type = FLAYER_INNATE_POWER
	weapon_type = /obj/item/melee/baton/flayerprod

/datum/spell/flayer/self/weapon/swarmprod/on_purchase_upgrade()
	if(!weapon_ref)
		weapon_ref = new weapon_type(flayer.owner.current, src)
	var/obj/item/melee/baton/flayerprod/prod = weapon_ref
	var/obj/item/stock_parts/cell/flayerprod/cell = prod.cell
	cell.chargerate += 200

/datum/spell/flayer/self/weapon/laser
	name = "Laser Arm Augementation"
	desc = "Our hand melts away, replaced with the barrel of a laser gun."
	action_icon = 'icons/obj/guns/energy.dmi'
	action_icon_state = "laser"
	power_type = FLAYER_PURCHASABLE_POWER
	weapon_type = /obj/item/gun/energy/laser/mounted
	category = FLAYER_CATEGORY_DESTROYER
	base_cost = 100
	max_level = 3
	upgrade_info = "The internal power cell recharges faster."

/datum/spell/flayer/self/weapon/laser/on_purchase_upgrade()
	if(!weapon_ref)
		weapon_ref = new weapon_type(flayer.owner.current, src)
	var/obj/item/gun/energy/laser/mounted/laser = weapon_ref
	laser.charge_delay -= 1

/datum/spell/flayer/self/weapon/flak_gun //Addressing the lack of FTL references in this game
	name = "Pneumatic Flak Gun"
	desc = "Our hand melts away, replaced with a makeshift cannon that automatically loads with shrapnel."
	action_icon = 'icons/obj/pneumaticCannon.dmi'
	action_icon_state = "pneumaticCannon"
	power_type = FLAYER_PURCHASABLE_POWER
	weapon_type = /obj/item/pneumatic_cannon/flayer
	category = FLAYER_CATEGORY_DESTROYER
	base_cost = 75
	max_level = 3
	upgrade_info = "Reduces the time needed for us to recycle scrap into ammo."

/datum/spell/flayer/self/weapon/flak_gun/on_purchase_upgrade()
	if(!weapon_ref)
		weapon_ref = new weapon_type(flayer.owner.current, src)
	var/obj/item/pneumatic_cannon/flayer/cannon = weapon_ref
	cannon.charge_time -= 2 SECONDS

