# Dialogue System

A complete dialogue and chat area system for your Godot game.

## Components

### 1. `dialogue_line.gd`
Represents a single line of dialogue with:
- **speaker**: Name of the NPC or character speaking
- **text**: The dialogue text

### 2. `dialogue.gd`
Manages a sequence of dialogue lines:
- `start()` - Reset to the beginning
- `get_current_line()` - Get the current dialogue line
- `advance()` - Move to the next line (returns false if finished)
- `is_finished()` - Check if dialogue is complete
- `reset()` - Reset dialogue to start

### 3. `dialogue_manager.gd`
Global dialogue manager that handles:
- Starting and ending dialogue
- Managing input during dialogue
- Communicating with the UI overlay
- Signals: `dialogue_started`, `dialogue_ended`, `line_displayed`

### 4. `chat_area.gd`
Extended Area2D for NPC interaction:
- **@export npc_name**: Name to display for dialogue
- **@export dialogue_lines**: Array of strings for dialogue (optional)
- Handles player collision detection
- Triggers dialogue on player interaction

### 5. Updated `overlay_screen.gd`
New methods for dialogue display:
- `update_dialogue_bubble(speaker: String, text: String)` - Display dialogue
- `hide_dialogue_bubble()` - Hide dialogue with fade animation

## Usage

### Setup in Scene

1. Add a chat_area node to your scene with a CollisionShape2D
2. Set the exported properties:
   - **npc_name**: "Merchant"
   - **dialogue_lines**: ["Hello there!", "How can I help you?", "Come back soon!"]
3. The dialogue system handles the rest automatically

### Interaction Flow

1. Player enters chat_area → Interact prompt appears
2. Player presses Interact → Dialogue starts
3. Each press of Interact advances to next line
4. When dialogue ends → Chat area returns to normal

### Creating Custom Dialogues Programmatically

```gdscript
var line1 = dialogue_line.new("Merchant", "Welcome to my shop!")
var line2 = dialogue_line.new("Merchant", "What would you like?")
var dialogue = dialogue.new("Merchant", [line1, line2])

var dialogue_manager = get_tree().get_first_node_in_group("DialogueManager")
dialogue_manager.start_dialogue(dialogue)
```

## Features

- Smooth fade in/out animations
- Player movement is locked during dialogue
- Click-to-advance dialogue system
- Speaker name display
- Integrates with existing overlay UI system
- Signals for dialogue lifecycle events

## Notes

- The dialogue manager is automatically created in the game.gd _ready() function
- Pressing "Interact" advances through dialogue lines
- Dialogue can only proceed one conversation at a time
- The system respects the existing OverlayScreen group for UI updates
