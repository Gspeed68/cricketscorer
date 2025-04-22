# Darts Cricket Game

A full-stack application for playing the game of Cricket in darts, featuring a Rust backend and React frontend with Chakra UI.

## Overview

Darts Cricket is a popular darts game where players aim to "close" numbers 15 through 20 and the bullseye (25) by hitting them three times each. Players can score points on numbers they've closed while their opponent hasn't.

## Architecture

The application consists of two main components:

1. **Backend (Rust)**: A RESTful API server built with Actix-web
2. **Frontend (React)**: A modern web interface built with React, TypeScript, and Chakra UI

## Backend (Rust)

Located in `darts_cricket_rs/`, the backend provides the game logic and API endpoints.

### Game Rules Implementation

- Players must hit each number (15-20 and bullseye) three times to "close" it
- Once a player closes a number, they can score points on it if their opponent hasn't closed it
- Points are calculated as: (hits - 2) * number value
- The game continues until all numbers are closed

### API Endpoints

1. `GET /status`
   - Returns the current game state including:
     - Player scores
     - Hits for each number
     - Current player turn

2. `POST /hit`
   - Records a hit for a player
   - Parameters:
     - `player_idx`: Player index (0 or 1)
     - `target`: Target number (15-20 or 25)
     - `hits`: Number of hits (1-3)

### Data Structures

```rust
struct Player {
    score: u32,
    hits: HashMap<u32, u32>,
}

struct DartsCricket {
    players: Vec<Player>,
}

struct GameStatus {
    players: Vec<usize>,
    scores: Vec<u32>,
    hits: Vec<Vec<u32>>,
}
```

## Frontend (React)

Located in `darts-cricket-frontend/`, the frontend provides a user-friendly interface for playing the game.

### Components

1. **DartsGame**
   - Main game component
   - Displays scoreboard and hit recording interface
   - Handles player turns and game state

### Features

- Real-time score updates
- Visual representation of hits and closed numbers
- Player turn management
- Toast notifications for game events

### UI Elements

- Score display for each player
- Target buttons (15-20 and bullseye)
- Hit recording interface
- Current player indicator

## Getting Started

### Prerequisites

- Rust (for backend)
- Node.js and npm (for frontend)

### Backend Setup

```bash
cd darts_cricket_rs
cargo run
```

The backend server will start on http://localhost:8080

### Frontend Setup

```bash
cd darts-cricket-frontend
npm install
npm run dev
```

The frontend will start on http://localhost:5173

## Game Flow

1. The game starts with two players
2. Players take turns throwing darts
3. Each hit is recorded through the interface
4. Scores are automatically calculated based on:
   - Number of hits
   - Whether numbers are closed
   - Opponent's progress
5. The game continues until all numbers are closed

## Technical Details

### Backend Dependencies

- actix-web: Web framework
- serde: Serialization/deserialization
- actix-cors: CORS middleware

### Frontend Dependencies

- React: UI framework
- TypeScript: Type safety
- Chakra UI: Component library
- Axios: HTTP client

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.
