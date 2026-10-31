extends Node
## Energy storage shared by pickups and the future Lantern Burst ability.
signal energy_changed(current: int, maximum: int)
const MAX_ENERGY: int = 100
var energy: int = MAX_ENERGY

func restore_energy(amount: int) -> int:
	if amount <= 0:
		return 0
	var restored := mini(amount, MAX_ENERGY - energy)
	if restored > 0:
		energy += restored
		energy_changed.emit(energy, MAX_ENERGY)
	return restored

func spend_energy(amount: int) -> bool:
	if amount <= 0 or energy < amount:
		return false
	energy -= amount
	energy_changed.emit(energy, MAX_ENERGY)
	return true
