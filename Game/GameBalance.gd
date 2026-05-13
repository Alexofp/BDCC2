extends RefCounted
class_name GameBalance

## Contains all of the 'balancing' numbers.
##
## To access this object, use GM.main.GB or GM.GB.

# SOCIAL STUFF

## How quickly should the annoyance fade. 0.01 = 1% per second
var socialAnnoyanceFadeRate:float = 0.01
## How quickly should the cooldowns of social interactions go down
var socialCooldownDecayRate:float = 0.01

## How many seconds before social exhaustion begins to recover
var socialExhaustionRecoverStartAfter:float = 50.0
var socialExhaustionRecoverRate:float = 0.01 ## 0.01 = 1% per second

## Each of the mood stats are multiplied by this number every 10 seconds or so
var moodDecayRate:float = 0.9

# COMBAT STUFF

## How many seconds before we're allowed to get up after getting defeated in a fight
var defeatedRecoverTime:float = 7.0

## How much pain (per second) should be recovered by characters normally.
var painRecoverPassive:float = 0.01
## How much pain (per second) should be recovered by characters if they're sitting anywhere.
var painRecoverSitting:float = 0.1

## How many seconds before exhaustion can begin to recover
var combatExhaustionRecoverTime:float = 1.5
## If we're running, the exhaustion recovery will be multiplied by this number
var combatExhaustionRecoverRunMod:float = 0.2
## If we're blocking, the exhaustion recovery will be multiplied by this number
var combatExhaustionRecoverBlockMod:float = 0.5

## If we're blocking and we're at 100% strain, the damage will affect exhaustion with this mult
var combatBlockOverstrainedExhaustionMult:float = 2.0
## Base blocked damage mult. 0.1 = 90% of the damage is blocked
var combatBlockDamageBaseMult:float = 0.1
## If the block is fully strained, how much more damage are we receiving. At 100% strain, 0.1+0.6 = 70% damage
var combatBlockDamageStrainedMult:float = 0.6
## When does block strain begins to have effect on the received damage
var combatBlockStrainStartsAt:float = 0.5
