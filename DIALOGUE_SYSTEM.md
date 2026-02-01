# Dialogue System (Oasis Dialogue)

A complete dialogue and chat area system using the Oasis Dialogue plugin for your Godot game.

## Components

### 1. `oasis_dialogue_manager.gd`
Custom OasisManager implementation that handles:
- Loading dialogue from JSON files
- Starting and ending dialogue
- Managing input during dialogue
- Communicating with the UI overlay
- Signals: `dialogue_started`, `dialogue_ended`
- Autoloaded as `DialogueManager` in project.godot

### 2. `chat_area.gd`
Extended Area2D for NPC interaction:
- **@export npc_name**: Name of the NPC character (must match character name in JSON)
- **@export area_name**: Optional area name to display
- Creates an OasisCharacter node for the NPC
- Handles player collision detection
- Triggers dialogue on player interaction via `interact()` method

### 3. `overlay_screen.gd`
Displays dialogue with methods:
- `update_dialogue_bubble(speaker: String, text: String)` - Display dialogue
- `hide_dialogue_bubble()` - Hide dialogue with fade animation

## File Structure

```
assets/dialogue/
  dialogue.json         # Contains all dialogue data in Oasis format
scripts/
  oasis_dialogue_manager.gd  # Custom OasisManager implementation
  chat_area.gd               # NPC interaction areas
```

## Dialogue JSON Format

Dialogue is stored in `assets/dialogue/dialogue.json` using Oasis Dialogue format:

```json
{
  "npc_name": {
    "0": {
      "prompts": [
        "First line of dialogue",
        "Second line of dialogue",
        "Final line"
      ],
      "responses": [],
      "actions": [],
      "next_branch": -1
    }
  }
}
```

Example for "Shirm" NPC:
```json
{
  "shirm": {
    "0": {
      "prompts": [
        "Hey...",
        "You good?",
        "Okay.."
      ],
      "responses": [],
      "actions": [],
      "next_branch": -1
    }
  }
}
```

## Usage

### Setup in Scene

1. Add a chat_area node to your scene with a CollisionShape2D
2. Set the exported property:
   - **npc_name**: "Shirm" (must match the key in dialogue.json, case-insensitive)
3. The dialogue system automatically creates an OasisCharacter node and loads the dialogue

### Interaction Flow

1. Player enters chat_area → Interact prompt appears
2. Player presses Interact (E key) → Dialogue starts
3. Press any key or click to advance to next line
4. When dialogue ends → Chat area returns to normal

### Adding New NPCs

1. Add the NPC's dialogue to `assets/dialogue/dialogue.json`:
```json
{
  "merchant": {
    "0": {
      "prompts": [
        "Welcome to my shop!",
        "What would you like to buy?"
      ],
      "responses": [],
      "actions": [],
      "next_branch": -1
    }
  }
}
```

2. In your scene, create a chat_area with:
   - **npc_name**: "Merchant"

### Advanced: Multiple Branches

You can create branching dialogue with conditions and actions:

```json
{
  "merchant": {
    "0": {
      "prompts": ["Welcome!"],
      "responses": [
        "I'd like to buy something",
        "Just looking"
      ],
      "actions": [
        {"branch": 1},
        {"branch": 2}
      ],
      "next_branch": -1
    },
    "1": {
      "prompts": ["Here's what I have for sale..."],
      "responses": [],
      "actions": [],
      "next_branch": -1
    },
    "2": {
      "prompts": ["Feel free to browse!"],
      "responses": [],
      "actions": [],
      "next_branch": -1
    }
  }
}
```

## Features

- Smooth fade in/out animations
- Player movement is locked during dialogue
- Click or press any key to advance dialogue
- Speaker name display
- JSON-based dialogue system (easy to edit and version control)
- Support for branching dialogue with conditions and actions
- Integrates with existing overlay UI system
- Signals for dialogue lifecycle events

## Migration from Old System

The old bespoke dialogue system has been replaced with Oasis Dialogue:
- **Removed**: `dialogue_manager.gd`, `dialogue.gd`, `dialogue_line.gd`
- **Added**: `oasis_dialogue_manager.gd` (extends OasisManager)
- **Changed**: `chat_area.gd` now uses OasisCharacter instead of custom dialogue classes
- **Data**: Dialogue is now stored in JSON format instead of exported arrays

## Notes

- The dialogue manager is autoloaded as `DialogueManager` in project.godot
- Pressing any key or clicking advances through dialogue
- Dialogue can only proceed one conversation at a time
- The system respects the existing OverlayScreen group for UI updates
- NPC names in `chat_area` must match character names in `dialogue.json` (case-insensitive)
