use std::collections::HashMap;
use std::io::{self, Write};

const MAX_PLAYERS: usize = 10;
const TARGETS: [u32; 7] = [15, 16, 17, 18, 19, 20, 25]; // 25 represents bullseye

#[derive(Clone)]
struct Player {
    score: u32,
    hits: HashMap<u32, u32>,
}

impl Player {
    fn new() -> Self {
        let mut hits = HashMap::new();
        for &target in TARGETS.iter() {
            hits.insert(target, 0);
        }
        Player { score: 0, hits }
    }

    fn record_hit(&mut self, target: u32, hits: u32) {
        if let Some(current_hits) = self.hits.get_mut(&target) {
            *current_hits += hits;
        }
    }

    fn get_hits(&self, target: u32) -> u32 {
        *self.hits.get(&target).unwrap_or(&0)
    }

    fn is_number_closed(&self, target: u32) -> bool {
        self.get_hits(target) >= 3
    }
}

struct DartsCricket {
    players: Vec<Player>,
}

impl DartsCricket {
    fn new(num_players: usize) -> Self {
        let num_players = num_players.min(MAX_PLAYERS);
        let players = (0..num_players).map(|_| Player::new()).collect();
        DartsCricket { players }
    }

    fn record_hit(&mut self, player_idx: usize, target: u32, hits: u32) -> bool {
        if player_idx >= self.players.len() || !TARGETS.contains(&target) {
            return false;
        }

        // Get the current state of all players
        let players_state: Vec<Player> = self.players.clone();
        
        // Update the current player's hits
        let player = &mut self.players[player_idx];
        let current_hits = player.get_hits(target);
        player.record_hit(target, hits);

        // If player has closed the number (3 or more hits)
        if current_hits + hits >= 3 {
            // Check if other players haven't closed this number
            let other_players_closed = players_state.iter()
                .enumerate()
                .filter(|&(idx, _)| idx != player_idx)
                .all(|(_, p)| p.is_number_closed(target));
            
            if !other_players_closed {
                let points = (current_hits + hits - 2) * target;
                player.score += points;
            }
        }

        true
    }

    fn get_player_score(&self, player_idx: usize) -> u32 {
        self.players.get(player_idx).map_or(0, |p| p.score)
    }

    fn get_player_hits(&self, player_idx: usize, target: u32) -> u32 {
        self.players.get(player_idx).map_or(0, |p| p.get_hits(target))
    }

    fn display_status(&self) {
        println!("\nCurrent Game Status:");
        for (idx, player) in self.players.iter().enumerate() {
            println!("\nPlayer {}:", idx + 1);
            println!("Score: {}", player.score);
            println!("Hits:");
            for &target in TARGETS.iter() {
                let hits = player.get_hits(target);
                let status = if hits >= 3 {
                    "Closed".to_string()
                } else {
                    format!("{}/3", hits)
                };
                println!("{}: {}", target, status);
            }
        }
    }
}

fn get_input<T: std::str::FromStr>(prompt: &str) -> T {
    loop {
        print!("{}", prompt);
        io::stdout().flush().unwrap();
        let mut input = String::new();
        io::stdin().read_line(&mut input).unwrap();
        match input.trim().parse() {
            Ok(value) => return value,
            Err(_) => println!("Please enter a valid number."),
        }
    }
}

fn main() {
    println!("Welcome to Darts Cricket!");

    // Get number of players
    let num_players: usize = loop {
        let input: usize = get_input("Enter number of players (max 10): ");
        if (1..=10).contains(&input) {
            break input;
        }
        println!("Please enter a number between 1 and 10.");
    };

    let mut game = DartsCricket::new(num_players);

    // Game loop
    loop {
        game.display_status();

        let player: usize = get_input(&format!("\nEnter player number (1-{}) or 0 to quit: ", num_players));
        if player == 0 {
            break;
        }
        if !(1..=num_players).contains(&player) {
            println!("Invalid player number.");
            continue;
        }

        let target: u32 = get_input("Enter target number (15-20, 25 for bullseye): ");
        if !TARGETS.contains(&target) {
            println!("Invalid target number.");
            continue;
        }

        let hits: u32 = get_input("Enter number of hits (1-3): ");
        if !(1..=3).contains(&hits) {
            println!("Invalid number of hits.");
            continue;
        }

        game.record_hit(player - 1, target, hits);
    }

    println!("\nFinal Scores:");
    for (idx, player) in game.players.iter().enumerate() {
        println!("Player {}: {}", idx + 1, player.score);
    }
}
