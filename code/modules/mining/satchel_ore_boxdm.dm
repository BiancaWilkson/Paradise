
/**********************Ore box**************************/

/obj/structure/ore_box
	icon = 'icons/obj/mining.dmi'
	icon_state = "orebox"
	name = "ore box"
	desc = "A heavy wooden box, which can be filled with a lot of ores."
	density = TRUE
	pressure_resistance = 5 * ONE_ATMOSPHERE

/obj/structure/ore_box/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/ore))
		if(!user.drop_item())
			return
		W.forceMove(src)
	else if(isstorage(W))
		var/obj/item/storage/S = W
		S.hide_from(usr)
		for(var/obj/item/stack/ore/O in S.contents)
			S.remove_from_storage(O, src) //This will move the item to this item's contents
			CHECK_TICK
		to_chat(user, "<span class='notice'>You empty the satchel into the box.</span>")
	else if(istype(W, /obj/item/crowbar))
		playsound(src, W.usesound, 50, 1)
		var/obj/item/crowbar/C = W
		if(do_after(user, 50 * C.toolspeed, target = src))
			user.visible_message("<span class='notice'>[user] pries [src] apart.</span>", "<span class='notice'>You pry apart [src].</span>", "<span class='italics'>You hear splitting wood.</span>")
			deconstruct(TRUE, user)
	else
		return ..()

/obj/structure/ore_box/attack_hand(mob/user)
	if(Adjacent(user))
		show_contents(user)

/obj/structure/ore_box/attack_robot(mob/user)
	if(Adjacent(user))
		show_contents(user)


/obj/structure/ore_box/ui_state(mob/user)
	return GLOB.default_state

/obj/structure/ore_box/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()


/obj/structure/ore_box/ui_data(mob/user)
	var/list/data = list()
	for(var/obj/item/stack/ore/O in src)
		data += list("ore" = O.type, quantity = O.amount)
	return data

/obj/structure/ore_box/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OreBox", name)
		ui.open()

/obj/structure/ore_box/deconstruct(disassembled = TRUE, mob/user)
	var/obj/item/stack/sheet/wood/W = new (loc, 4)
	if(user)
		W.add_fingerprint(user)
	dump_box_contents()
	qdel(src)

/obj/structure/ore_box/proc/dump_box_contents()
	for(var/obj/item/stack/ore/O in src)
		if(QDELETED(O))
			continue
		if(QDELETED(src))
			break
		O.forceMove(loc)
		CHECK_TICK

/obj/structure/ore_box/examine(mob/user)
	. = ..()
	if(Adjacent(user))
		. += "<span class='notice'>You can <b>Alt-Shift-Click</b> to empty the ore box.</span>"

/obj/structure/ore_box/onTransitZ()
	return

/obj/structure/ore_box/AltShiftClick(mob/user)
	if(!Adjacent(user) || !ishuman(user) || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, "You cannot interact with the ore box.")
		return

	add_fingerprint(user)

	if(length(contents) < 1)
		to_chat(user, "<span class='warning'>The ore box is empty.</span>")
		return

	dump_box_contents()
	to_chat(user, "<span class='notice'>You empty the ore box.</span>")
