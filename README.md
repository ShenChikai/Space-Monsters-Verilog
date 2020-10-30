# Space-Monsters-Verilog

The game is inspired by the classic arcade game "Space Invaders." The game involves a shooter which can only move at the bottom of the screen, and monsters emerging from the top of the screen. Both monsters and the player continuously fire bullets. For simplicity the monsters are also at a fixed position at the beginning. If time allows, we can add more features including moving monsters and different levels of the game.

# Timeline
1. Implement button control on "tanks", VGA display of the tank and monsters, state machine design - 11/2 (Mon)
2. Test the state machine design with simplified displays and 5 monsters. Tank fires bullets continuously. Main goal: monsters disappear after being shot, correct state change of the tank is hit. - 11/4 (Thu)
3. Make sure simplest game design works - 11/5 (Fri)
4. Add additional features

# Possible additional features
- Bullet mode - press to fire, or press once to fire, another press to hold fire
- Score in SSD
- Pause - Allow users to pause with a button press, another press to resume
- Different levels - 2+ levels with increasing difficulty (# of monsters and frequency of monster bullets)
- Moving monsters

# State Machine
![state machine v0](/assets/state_machine_v0.png)
