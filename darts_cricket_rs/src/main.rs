use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use actix_cors::Cors;
use serde::{Deserialize, Serialize};
use std::sync::Mutex;
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

        let player = &mut self.players[player_idx];
        let current_hits = player.get_hits(target);
        player.record_hit(target, hits);

        if current_hits + hits >= 3 {
            let other_players_closed = self.players.iter()
                .enumerate()
                .filter(|&(idx, _)| idx != player_idx)
                .all(|(_, p)| p.is_number_closed(target));
            
            if !other_players_closed {
                let points = (current_hits + hits - 2) * target;
                self.players[player_idx].score += points;
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

    fn get_game_status(&self) -> GameStatus {
        let players = (0..self.players.len()).collect();
        let scores = self.players.iter().map(|p| p.score).collect();
        let hits = self.players.iter()
            .map(|p| TARGETS.iter().map(|&t| p.get_hits(t)).collect())
            .collect();
        
        GameStatus { players, scores, hits }
    }
}

#[derive(Serialize, Deserialize)]
struct GameStatus {
    players: Vec<usize>,
    scores: Vec<u32>,
    hits: Vec<Vec<u32>>,
}

#[derive(Deserialize)]
struct HitRequest {
    player_idx: usize,
    target: u32,
    hits: u32,
}

struct AppState {
    game: Mutex<DartsCricket>,
}

async fn record_hit(
    data: web::Data<AppState>,
    hit: web::Json<HitRequest>,
) -> impl Responder {
    let mut game = data.game.lock().unwrap();
    let success = game.record_hit(hit.player_idx, hit.target, hit.hits);
    HttpResponse::Ok().json(serde_json::json!({ "success": success }))
}

async fn get_status(data: web::Data<AppState>) -> impl Responder {
    let game = data.game.lock().unwrap();
    let status = game.get_game_status();
    HttpResponse::Ok().json(status)
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

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let game = DartsCricket::new(2);
    let app_state = web::Data::new(AppState {
        game: Mutex::new(game),
    });

    println!("Starting server at http://localhost:8080");

    HttpServer::new(move || {
        let cors = Cors::default()
            .allow_any_origin()
            .allow_any_method()
            .allow_any_header()
            .max_age(3600);

        App::new()
            .wrap(cors)
            .app_data(app_state.clone())
            .route("/status", web::get().to(get_status))
            .route("/hit", web::post().to(record_hit))
    })
    .bind("127.0.0.1:8080")?
    .run()
    .await
}
