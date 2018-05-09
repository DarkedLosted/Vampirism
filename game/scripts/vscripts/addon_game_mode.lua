---------------------------------------------------------------------------
if vampirism == nil then
	_G.vampirism = class({})
end

require('vampirism')
require('utilities')
require('upgrades')
require('mechanics')
require('orders')
require('builder')
require('buildinghelper')
require('peasant')

require('events')
require('shop')
require('research_events')

require('gold')
require('FilterExperience')
require('FilterDamage')

require('libraries/timers')
require('libraries/popups')
require('libraries/notifications')
require('libraries/Physics')
require('libraries/playertables')
--require('Bots/AI')
function Precache( context )

	-- Model ghost and grid particles
 PrecacheResource("soundfile", "soundevents/game_sounds_ui.vsndevts", context)
 PrecacheResource("particle_folder", "particles/buildinghelper", context)
 PrecacheResource("particle_folder", "particles/econ/items/earthshaker/earthshaker_gravelmaw/", context)
 PrecacheResource("particle_folder", "particles/units/heroes/hero_invoker/", context)
 PrecacheResource("particle_folder", "particles/units/heroes/hero_oracle/", context)
 PrecacheResource("particle_folder", "particles/units/heroes/hero_keeper_of_the_light/", context)
 PrecacheResource("particle_folder", "particles/units/heroes/hero_chen/", context)
 PrecacheResource("particle_folder", "particles/units/heroes/hero_stormspirit/", context)
 PrecacheResource("particle_folder", "particles/units/heroes/hero_furion/", context)
 PrecacheResource("particle_folder", "particles/units/heroes/hero_phoenix/", context)
 PrecacheResource("particle_folder", "particles/units/heroes/hero_jakiro/", context)
 PrecacheResource("particle_folder", "particles/units/heroes/hero_shadowshaman/", context)
 PrecacheResource("particle_folder", "particles/units/heroes/hero_night_stalker", context)
 PrecacheResource("particle", "particles/items2_fx/teleport_end_tube.vpcf", context)
 PrecacheResource("particle", "particles/units/heroes/hero_furion/furion_teleport_e.vpcf", context)
 PrecacheResource("particle", "particles/generic_gameplay/screen_death_indicator.vpcf", context)
 PrecacheResource("particle", "particles/units/heroes/hero_warlock/warlock_death_swirl.vpcf", context)
 PrecacheResource("particle", "particles/econ/items/lina/lina_ti6/lina_ti6_ambient_ground_dust.vpcf", context)
 PrecacheResource("particle", "particles/units/heroes/hero_arc_warden/arc_warden_wraith_prj_burst.vpcf", context)
 PrecacheResource("particle", "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf", context)
 PrecacheResource("particle", "particles/units/heroes/hero_doom_bringer/doom_bringer_doom_ring.vpcf", context)
 PrecacheResource("particle", "particles/econ/items/bane/slumbering_terror/bane_slumber_blob.vpcf", context)
 PrecacheResource("particle", "particles/econ/items/bounty_hunter/bounty_hunter_hunters_hoard/bounty_hunter_hoard_track_trail_circle.vpcf", context)
 PrecacheResource("particle", "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_phantom_strike_start.vpcf", context)
 PrecacheResource("particle", "particles/econ/items/phantom_assassin/phantom_assassin_arcana_elder_smith/pa_arcana_phantom_strike_end.vpcf", context)
 
 --PrecacheResource( "soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context )
	-- Resources used
	PrecacheUnitByNameSync("peasant", context)
	PrecacheUnitByNameSync("furbolg_harvester", context)
	PrecacheUnitByNameSync("fang_harvester", context)
	PrecacheUnitByNameSync("fire_spawn_deforester", context)
	PrecacheUnitByNameSync("satyr_harvester", context)
	PrecacheUnitByNameSync("tower_builder", context)
	PrecacheUnitByNameSync("super_tower_builder", context)
	PrecacheUnitByNameSync("goblin_tower_builder", context)
	PrecacheUnitByNameSync("slayer_tracker", context)
	PrecacheUnitByNameSync("engineer", context)

	PrecacheUnitByNameSync("build_house", context)
	PrecacheUnitByNameSync("lumber_house", context)
	PrecacheUnitByNameSync("deforestation_house", context)
	PrecacheUnitByNameSync("tent_1", context)
	PrecacheUnitByNameSync("tent_2", context)
	PrecacheUnitByNameSync("wall_of_health", context)
	PrecacheUnitByNameSync("slayer_tavern", context)
	PrecacheUnitByNameSync("human_surplus", context)
	PrecacheUnitByNameSync("research_center", context)
	PrecacheUnitByNameSync("slayers_vault", context)
	PrecacheUnitByNameSync("gold_mine", context)
	PrecacheUnitByNameSync("citadel_of_faith", context)
	PrecacheUnitByNameSync("command_center", context)
	PrecacheUnitByNameSync("base_of_operations", context)
	PrecacheUnitByNameSync("ultra_research_center", context)
	PrecacheUnitByNameSync("feeding_block", context)
	PrecacheUnitByNameSync("blood_box", context)


	PrecacheUnitByNameSync("tower_pearl", context)
	PrecacheUnitByNameSync("shiny_Pearl", context)
	PrecacheUnitByNameSync("Tower_Of_Pearls", context)
	 PrecacheUnitByNameSync("Tower_Of_Lesser_Mana_Energy", context)
	 PrecacheUnitByNameSync("Tower_Of_Mana_Energy", context)
	 PrecacheUnitByNameSync("Tower_Of_Opal_Spire", context)
	 PrecacheUnitByNameSync("Tower_Of_Pink_Diamond", context)
	 PrecacheUnitByNameSync("Tower_Of_Calcite_Outl", context)
	 PrecacheUnitByNameSync("Tower_Of_Flame", context)
	 PrecacheUnitByNameSync("Tower_Of_Frost", context)
	 PrecacheUnitByNameSync("Tower_Of_Blood", context)
	 PrecacheUnitByNameSync("holy_blood_tower", context)
	 PrecacheUnitByNameSync("Tower_Of_Orange_Calcite", context)
	 PrecacheUnitByNameSync("Tower_Of_Super_Flame", context)
	 PrecacheUnitByNameSync("Tower_Of_Ultimate_Flame", context)
	 PrecacheUnitByNameSync("wall_tower", context)
	 PrecacheUnitByNameSync("super_wall_tower", context)
	 PrecacheUnitByNameSync("lightning_oracle", context)
	 PrecacheUnitByNameSync("ultra_lightning_oracle", context)
	 PrecacheUnitByNameSync("vampire_spire", context)
	 PrecacheUnitByNameSync("ultra_vampire_spire", context)
	 PrecacheUnitByNameSync("armageddon_tower", context)
	 PrecacheUnitByNameSync("comet_tower", context)
	 PrecacheUnitByNameSync("meteor_tower", context)
	 
	 PrecacheUnitByNameSync("Carnelian_wall", context)
	 PrecacheUnitByNameSync("Wall_Of_Topaz", context)
	 PrecacheUnitByNameSync("Wall_Of_Amethyst", context)
	 PrecacheUnitByNameSync("Wall_Of_Sapphire", context)
	 PrecacheUnitByNameSync("Wall_Of_Emerald", context)
	 PrecacheUnitByNameSync("Wall_Of_Chrysoprase", context)
	 PrecacheUnitByNameSync("Wall_Of_Garnet", context)
	 PrecacheUnitByNameSync("Wall_Of_Ruby", context)
	 PrecacheUnitByNameSync("Wall_Of_Diamond", context)
	 PrecacheUnitByNameSync("Wall_Of_Onyx", context)

	 PrecacheUnitByNameSync("npc_dota_hero_kunkka", context)
	 PrecacheUnitByNameSync("npc_dota_hero_night_stalker", context)
	 PrecacheUnitByNameSync("npc_dota_hero_wisp", context)
	 PrecacheUnitByNameSync("npc_dota_hero_invoker", context)
	 --units
	 PrecacheUnitByNameSync("Shade", context)
	 PrecacheUnitByNameSync("Abomination", context)
	 PrecacheUnitByNameSync("Fel_Beast", context)
	 PrecacheUnitByNameSync("Assasin", context)
	 PrecacheUnitByNameSync("French_Man", context)
	 PrecacheUnitByNameSync("Infernal", context)
	 PrecacheUnitByNameSync("Doom_Guard", context)
	 PrecacheUnitByNameSync("Meat_Carrier", context)

	 --other
	 PrecacheUnitByNameSync("ring_hell_ghost", context)
	 

	PrecacheItemByNameSync("item_apply_modifiers", context)
	

	--Sounds
	PrecacheResource("soundfile", "sounds/ui/portal_disappear.vsnd", context)
	PrecacheResource("soundfile", "sounds/music/valve_ti4/music/smoke.vsnd", context)
	PrecacheResource("soundfile", "sounds/items/dust_of_appearance.vsnd", context)
	PrecacheResource("soundfile", "sounds/weapons/hero/earth_spirit/stone_remnant_destroy.vsnd", context)
	PrecacheResource("soundfile", "valve_ti4.music.smoke", context)
	
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_keeper_of_the_light.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_razor.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_furion.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_phoenix.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_jakiro.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_shadowshaman.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_nevermore.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_lion.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_visage.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_oracle.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_venomancer.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_terrorblade.vsndevts", context)
	PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_puck.vsndevts", context)
	--PrecacheResource("model","models/items/warlock/warlock_fourleg_demon.vmdl",contex)

end

-- Create our game mode and initialize it
function Activate()
	vampirism:InitGameMode()
end

---------------------------------------------------------------------------




--[[
	OUT OF VECTOR IS CAUSING ISSUES? CNetworkOriginCellCoordQuantizedVector m_cellZ cell 155 is outside of cell bounds (0->128) @(-15714.285156 -15714.285156 23405.712891)
	NEED TO ADD ABILITY_BUILDING AND QUEUE MANUALLY, NECESSARY?
	COLLISION SIZE?
]]--