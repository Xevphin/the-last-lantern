extends SceneTree
var failures=0
func ck(v,label):
 if not v:failures+=1;push_error(label)
func _initialize():call_deferred("run")
func run():
 change_scene_to_file("res://tests/combat/wanderer_test.tscn")
 await scene_changed
 for i in range(5):await physics_frame
 var p=current_scene.get_node("Player")
 var e=current_scene.get_node("ShadowWanderer/CharacterBody2D")
 e.set_physics_process(false)
 e.global_position=p.global_position+Vector2(100,0)
 var energy=p.get_node("LanternSystem")
 var burst=p.get_node("LanternBurst")
 var key=InputEventKey.new()
 key.physical_keycode=KEY_K
 key.pressed=true
 Input.parse_input_event(key)
 Input.flush_buffered_events()
 for i in range(4):
  await process_frame
  await physics_frame
 key=InputEventKey.new()
 key.physical_keycode=KEY_K
 Input.parse_input_event(key)
 Input.flush_buffered_events()
 ck(energy.energy==75,"cost")
 ck(not burst.try_burst() and energy.energy==75,"cooldown rejects duplicate")
 for i in range(4):await physics_frame
 ck(e.health==4 and e.stun_left>0,"damage and stun")
 await create_timer(2.1).timeout
 var button=p.get_node("MobileControls/BurstButton")
 var touch=InputEventScreenTouch.new()
 touch.index=0
 touch.position=button.get_global_transform_with_canvas().origin
 touch.pressed=true
 root.push_input(touch,true)
 for i in range(4):
  await process_frame
  await physics_frame
 touch=InputEventScreenTouch.new()
 touch.index=0
 touch.position=button.get_global_transform_with_canvas().origin
 touch.pressed=false
 root.push_input(touch,true)
 ck(energy.energy==50,"touch button uses same ability after cooldown")
 for i in range(4):await physics_frame
 ck(e.health==3 and energy.energy==50,"second burst")
 e.take_damage(3,p.global_position)
 for i in range(4):await physics_frame
 var drops=get_nodes_in_group("energy_pickups")
 ck(drops.size()==1,"one death pickup")
 p.global_position=drops[0].global_position
 for i in range(6):await physics_frame
 ck(energy.energy==65,"pickup restores 15")
 ck(get_nodes_in_group("energy_pickups").is_empty(),"pickup consumed once")
 energy.spend_energy(65)
 await create_timer(2.1).timeout
 ck(not burst.try_burst() and energy.energy==0,"insufficient energy")
 energy.restore_energy(200)
 ck(energy.energy==100,"energy cap")
 ck(p.get_node("GameHUD")._display_energy==100,"HUD follows energy")
 burst.cooldown_left=1.0
 paused=true
 await create_timer(0.2,true).timeout
 ck(is_equal_approx(burst.cooldown_left,1.0),"pause freezes cooldown")
 paused=false
 var wall=current_scene.get_node("Wall")
 var blocker=load("res://scenes/enemies/divesh/ShadowWanderer.tscn").instantiate()
 current_scene.add_child(blocker)
 var guarded=blocker.get_node("CharacterBody2D")
 guarded.set_physics_process(false)
 guarded.global_position=p.global_position+Vector2(100,0)
 wall.global_position=p.global_position+Vector2(50,0)
 for i in range(3):await physics_frame
 burst.cooldown_left=0
 burst.try_burst()
 for i in range(3):await physics_frame
 ck(guarded.health==5,"wall blocks burst damage")
 print("BURST CHECKS failures=",failures)
 quit(failures)
