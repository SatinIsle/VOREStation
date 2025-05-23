import type { BooleanLike } from 'tgui-core/react';

export type Data = {
  unsaved_changes: BooleanLike;
  show_pictures: BooleanLike;
  icon_overflow: BooleanLike;
  inside: insideData;
  host_mobtype: hostMob;
  our_bellies: bellyData[];
  selected: selectedData | null;
  prefs: prefData;
  soulcatcher: soulcatcherData | null;
  abilities: abilities;
  vore_words: Record<string, string[]>;
};

export type abilities = {
  nutrition: number;
  current_size: number;
  minimum_size: number;
  maximum_size: number;
  resize_cost: number;
};

export type hostMob = {
  is_cyborg: BooleanLike;
  is_vore_simple_mob: BooleanLike;
};

export type insideData = {
  absorbed: BooleanLike;
  belly_name?: string;
  belly_mode?: string;
  desc?: string;
  pred?: string;
  ref?: string;
  liq_lvl?: number;
  liq_reagent_type?: string;
  liuq_name?: string;
  contents?: contentData[];
};

export type contentData = {
  name: string;
  absorbed: BooleanLike;
  stat: number;
  ref: string;
  outside: BooleanLike;
  icon: string;
};

export type bellyData = {
  selected: BooleanLike;
  name: string;
  ref: string;
  digest_mode: string;
  contents: number;
  prevent_saving: BooleanLike;
};

export type selectedData = {
  belly_name: string;
  message_mode: BooleanLike;
  is_wet: BooleanLike;
  wet_loop: BooleanLike;
  mode: string;
  item_mode: string;
  verb: string;
  release_verb: string;
  desc: string;
  absorbed_desc: string;
  fancy: BooleanLike;
  sound: string;
  release_sound: string;
  can_taste: BooleanLike;
  is_feedable: BooleanLike;
  egg_type: string;
  egg_name: string;
  egg_size: number;
  recycling: BooleanLike;
  storing_nutrition: BooleanLike;
  entrance_logs: BooleanLike;
  nutrition_percent: number;
  digest_brute: number;
  digest_burn: number;
  digest_oxy: number;
  digest_tox: number;
  digest_clone: number;
  bulge_size: number;
  save_digest_mode: BooleanLike;
  display_absorbed_examine: BooleanLike;
  shrink_grow_size: number;
  emote_time: number;
  emote_active: BooleanLike;
  selective_preference: string;
  nutrition_ex: BooleanLike;
  weight_ex: BooleanLike;
  belly_fullscreen: string;
  eating_privacy_local: string;
  silicon_belly_overlay_preference: string;
  belly_mob_mult: number;
  belly_item_mult: number;
  belly_overall_mult: number;
  drainmode: string;
  belly_fullscreen_color: string;
  belly_fullscreen_color2: string;
  belly_fullscreen_color3: string;
  belly_fullscreen_color4: string;
  belly_fullscreen_alpha: number;
  colorization_enabled: BooleanLike;
  custom_reagentcolor: string;
  custom_reagentalpha: number;
  liquid_overlay: BooleanLike;
  max_liquid_level: number;
  reagent_touches: BooleanLike;
  mush_overlay: BooleanLike;
  mush_color: string;
  mush_alpha: number;
  max_mush: number;
  min_mush: number;
  item_mush_val: number;
  metabolism_overlay: BooleanLike;
  metabolism_mush_ratio: number;
  max_ingested: number;
  custom_ingested_color: string;
  custom_ingested_alpha: number;
  vorespawn_blacklist: BooleanLike;
  vorespawn_whitelist: string[];
  vorespawn_absorbed: number;
  sound_volume: number;
  affects_voresprite: BooleanLike;
  absorbed_voresprite: BooleanLike;
  absorbed_multiplier: number;
  liquid_voresprite: BooleanLike;
  liquid_multiplier: number;
  item_voresprite: BooleanLike;
  item_multiplier: number;
  health_voresprite: number;
  resist_animation: BooleanLike;
  voresprite_size_factor: number;
  belly_sprite_to_affect: string;
  undergarment_chosen: string;
  undergarment_if_none: string;
  undergarment_color: string;
  belly_sprite_option_shown: BooleanLike;
  tail_option_shown: BooleanLike;
  tail_to_change_to: BooleanLike | string;
  tail_colouration: BooleanLike;
  tail_extra_overlay: BooleanLike;
  tail_extra_overlay2: BooleanLike;
  noise_freq: number;
  item_digest_logs: BooleanLike;
  private_struggle: BooleanLike;
  addons: string[];
  vore_sprite_flags: string[];
  contaminates: BooleanLike;
  contaminate_flavor: string | null;
  contaminate_color: string | null;
  escapable: BooleanLike;
  interacts: interactData;
  autotransfer_enabled: BooleanLike;
  autotransfer: autotransferData;
  disable_hud: BooleanLike;
  possible_fullscreens: string[];
  contents: contentData[];
  show_liq: BooleanLike;
  liq_interacts: liqInteractData;
  show_liq_fullness: BooleanLike;
  liq_messages: liqMessageData;
};

export type interactData = {
  escapechance: number;
  escapechance_absorbed: number;
  escapetime: number;
  transferchance: number;
  transferlocation: string;
  transferchance_secondary: number;
  transferlocation_secondary: string;
  absorbchance: number;
  digestchance: number;
  belchchance: number;
};

export type autotransferData = {
  autotransferchance: number;
  autotransferwait: number;
  autotransferlocation: string;
  autotransferextralocation: string[];
  autotransferchance_secondary: number;
  autotransferlocation_secondary: string;
  autotransferextralocation_secondary: string[];
  autotransfer_min_amount: number;
  autotransfer_max_amount: number;
  autotransfer_whitelist: string[];
  autotransfer_blacklist: string[];
  autotransfer_whitelist_items: string[];
  autotransfer_blacklist_items: string[];
  autotransfer_secondary_whitelist: string[];
  autotransfer_secondary_blacklist: string[];
  autotransfer_secondary_whitelist_items: string[];
  autotransfer_secondary_blacklist_items: string[];
};

type liqInteractData = {
  liq_reagent_gen: BooleanLike;
  liq_reagent_type: string;
  liq_reagent_name: string;
  liq_reagent_transfer_verb: string;
  liq_reagent_nutri_rate: number;
  liq_reagent_capacity: number;
  liq_sloshing: BooleanLike;
  liq_reagent_addons: string[];
  custom_reagentcolor: string;
  custom_reagentalpha: number | string;
  liquid_overlay: BooleanLike;
  max_liquid_level: number;
  reagent_touches: BooleanLike;
  mush_overlay: BooleanLike;
  mush_color: string;
  mush_alpha: number;
  max_mush: number;
  min_mush: number;
  item_mush_val: number;
  metabolism_overlay: BooleanLike;
  metabolism_mush_ratio: number;
  max_ingested: number;
  custom_ingested_color: string;
  custom_ingested_alpha: number;
};

type liqMessageData = {
  liq_msg_toggle1: BooleanLike;
  liq_msg_toggle2: BooleanLike;
  liq_msg_toggle3: BooleanLike;
  liq_msg_toggle4: BooleanLike;
  liq_msg_toggle5: BooleanLike;
  liq_msg1: BooleanLike;
  liq_msg2: BooleanLike;
  liq_msg3: BooleanLike;
  liq_msg4: BooleanLike;
  liq_msg5: BooleanLike;
};

export type prefData = {
  digestable: BooleanLike;
  devourable: BooleanLike;
  resizable: BooleanLike;
  feeding: BooleanLike;
  absorbable: BooleanLike;
  digest_leave_remains: BooleanLike;
  allowmobvore: BooleanLike;
  permit_healbelly: BooleanLike;
  show_vore_fx: BooleanLike;
  can_be_drop_prey: BooleanLike;
  can_be_drop_pred: BooleanLike;
  latejoin_vore: BooleanLike;
  latejoin_prey: BooleanLike;
  no_spawnpred_warning: BooleanLike;
  no_spawnprey_warning: BooleanLike;
  no_spawnpred_warning_time: number;
  no_spawnprey_warning_time: number;
  no_spawnpred_warning_save: BooleanLike;
  no_spawnprey_warning_save: BooleanLike;
  allow_spontaneous_tf: BooleanLike;
  step_mechanics_active: BooleanLike;
  pickup_mechanics_active: BooleanLike;
  strip_mechanics_active: BooleanLike;
  noisy: BooleanLike;
  liq_rec: BooleanLike;
  liq_giv: BooleanLike;
  liq_apply: BooleanLike;
  consume_liquid_belly: BooleanLike;
  autotransferable: BooleanLike;
  noisy_full: BooleanLike;
  selective_active: string;
  allow_mind_transfer: BooleanLike;
  drop_vore: BooleanLike;
  slip_vore: BooleanLike;
  stumble_vore: BooleanLike;
  throw_vore: BooleanLike;
  phase_vore: BooleanLike;
  food_vore: BooleanLike;
  digest_pain: BooleanLike;
  nutrition_message_visible: BooleanLike;
  nutrition_messages: string[];
  weight_message_visible: BooleanLike;
  weight_messages: string[];
  eating_privacy_global: BooleanLike;
  allow_mimicry: BooleanLike;
  belly_rub_target: string | null;
  vore_sprite_color: { stomach: string; 'taur belly': string };
  vore_sprite_multiply: { stomach: BooleanLike; 'taur belly': BooleanLike };
  soulcatcher_allow_capture: BooleanLike;
  soulcatcher_allow_transfer: BooleanLike;
  soulcatcher_allow_deletion: BooleanLike;
  soulcatcher_allow_takeover: BooleanLike;
};

export type soulcatcherData = {
  active: BooleanLike;
  name: string;
  caught_souls: DropdownEntry[];
  selected_sfx: string;
  selected_soul: string;
  interior_design: string;
  catch_self: BooleanLike;
  taken_over: BooleanLike;
  catch_prey: BooleanLike;
  catch_drain: BooleanLike;
  catch_ghost: BooleanLike;
  ext_hearing: BooleanLike;
  ext_vision: BooleanLike;
  mind_backups: BooleanLike;
  sr_projecting: BooleanLike;
  show_vore_sfx: BooleanLike;
  see_sr_projecting: BooleanLike;
};

export type DropdownEntry = {
  displayText: string;
  value: string;
};

export type localPrefs = {
  digestion: preferenceData;
  absorbable: preferenceData;
  devour: preferenceData;
  mobvore: preferenceData;
  feed: preferenceData;
  healbelly: preferenceData;
  dropnom_prey: preferenceData;
  dropnom_pred: preferenceData;
  toggle_drop_vore: preferenceData;
  toggle_slip_vore: preferenceData;
  toggle_stumble_vore: preferenceData;
  toggle_throw_vore: preferenceData;
  toggle_phase_vore: preferenceData;
  toggle_food_vore: preferenceData;
  toggle_digest_pain: preferenceData;
  spawnbelly: preferenceData;
  spawnprey: preferenceData;
  noisy: preferenceData;
  noisy_full: preferenceData;
  resize: preferenceData;
  steppref: preferenceData;
  vore_fx: preferenceData;
  remains: preferenceData;
  pickuppref: preferenceData;
  spontaneous_tf: preferenceData;
  mind_transfer: preferenceData;
  examine_nutrition: preferenceData;
  examine_weight: preferenceData;
  strippref: preferenceData;
  eating_privacy_global: preferenceData;
  allow_mimicry: preferenceData;
  autotransferable: preferenceData;
  liquid_receive: preferenceData;
  liquid_give: preferenceData;
  liquid_apply: preferenceData;
  toggle_consume_liquid_belly: preferenceData;
  no_spawnpred_warning: preferenceData;
  no_spawnprey_warning: preferenceData;
  soulcatcher: preferenceData;
  soulcatcher_transfer: preferenceData;
  soulcatcher_takeover: preferenceData;
  soulcatcher_delete: preferenceData;
};

export type preferenceData = {
  action: string;
  test: BooleanLike;
  tooltip: { main: string; enable: string; disable: string };
  content: { enabled: string; disabled: string };
  fluid?: boolean;
  back_color?: { enabled: string; disabled: string };
};
