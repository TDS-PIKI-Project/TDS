extends BaseLevel

func setup_level():
	enemy_scene = preload(Globals.ENEMY_PATH)
	var tower_manager = TowerManager.new()
	tower_manager.build_tower(self, 3)
	add_child(tower_manager)
