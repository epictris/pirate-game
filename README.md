# Pirate Boat Game
currently just a 3D sailboat controller

## Controls
- 3d swim: up, down, left, right arrows
- 2d movement: left, right arrows & space to jump
- take control of ship: press E in front of 2d wheel
- steer ship: left and right arrow keys
- increase and decrease rope slack: up and down arrow keys
- exit ship control mode: press ESC

## Mechanics
- collide with ships while swimming to board
- jump off the side of ships to disembark

## To Do
- [x] create player animation manager component to remove animation handling from movement state code
- add new states:
    - [ ] hanging from ledge
    - [ ] climbing up ledge
    - [x] sliding/rolling
    - [ ] wall running
    - [ ] vaulting
- add proper rollback state management to new abilities/states
- [x] create resource for passing initialization info between movement states
- clearly distinguish between public and private player functions
- disallow use of abilities while in specific states

## Ideas
- separate files based on rollback-compatibility
- add pattern matching linters to help prevent accidental implementation of rollback-incompatible code
