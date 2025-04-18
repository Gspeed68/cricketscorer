#!/usr/bin/env python3

class DartsCricket:
    """
    A class to handle scoring for a game of cricket darts.
    Cricket is played with numbers 15-20 and bullseye.
    Each number must be hit 3 times to be "closed".
    Points are scored on numbers that are closed by the player but not by opponents.
    """
    
    def __init__(self, num_players):
        """
        Initialize the game with the specified number of players.
        Each player starts with all numbers open and no points.
        """
        self.num_players = min(num_players, 10)  # Limit to 10 players
        self.targets = [15, 16, 17, 18, 19, 20, 25]  # 25 represents bullseye
        self.player_scores = {}
        self.player_hits = {}
        
        # Initialize scores and hits for each player
        for player in range(1, self.num_players + 1):
            self.player_scores[player] = 0
            self.player_hits[player] = {target: 0 for target in self.targets}
    
    def record_hit(self, player, target, hits=1):
        """
        Record a hit for a specific player on a specific target.
        Updates the player's score if appropriate.
        """
        if player not in self.player_hits or target not in self.targets:
            return False
        
        # Update hits for the player
        self.player_hits[player][target] += hits
        
        # If player has closed the number (3 or more hits)
        if self.player_hits[player][target] >= 3:
            # Check if other players haven't closed this number
            for other_player in range(1, self.num_players + 1):
                if other_player != player and self.player_hits[other_player][target] < 3:
                    # Add points for each hit beyond 3
                    points = (self.player_hits[player][target] - 2) * target
                    self.player_scores[player] += points
        
        return True
    
    def get_player_score(self, player):
        """Return the current score for a specific player."""
        return self.player_scores.get(player, 0)
    
    def get_player_hits(self, player):
        """Return the current hits for a specific player."""
        return self.player_hits.get(player, {})
    
    def is_number_closed(self, player, target):
        """Check if a player has closed a specific number."""
        return self.player_hits[player][target] >= 3
    
    def get_game_status(self):
        """Return the current status of the game for all players."""
        status = {}
        for player in range(1, self.num_players + 1):
            status[player] = {
                'score': self.player_scores[player],
                'hits': self.player_hits[player]
            }
        return status

def main():
    """
    Main function to run the darts cricket game.
    Handles player input and displays game status.
    """
    print("Welcome to Darts Cricket!")
    
    # Get number of players
    while True:
        try:
            num_players = int(input("Enter number of players (max 10): "))
            if 1 <= num_players <= 10:
                break
            print("Please enter a number between 1 and 10.")
        except ValueError:
            print("Please enter a valid number.")
    
    game = DartsCricket(num_players)
    
    # Game loop
    while True:
        print("\nCurrent Game Status:")
        for player in range(1, num_players + 1):
            print(f"\nPlayer {player}:")
            print(f"Score: {game.get_player_score(player)}")
            print("Hits:")
            for target in game.targets:
                hits = game.get_player_hits(player)[target]
                status = "Closed" if hits >= 3 else f"{hits}/3"
                print(f"{target}: {status}")
        
        # Get player input
        try:
            player = int(input("\nEnter player number (1-{0}) or 0 to quit: ".format(num_players)))
            if player == 0:
                break
            if not 1 <= player <= num_players:
                print("Invalid player number.")
                continue
            
            target = int(input("Enter target number (15-20, 25 for bullseye): "))
            if target not in game.targets:
                print("Invalid target number.")
                continue
            
            hits = int(input("Enter number of hits (1-3): "))
            if not 1 <= hits <= 3:
                print("Invalid number of hits.")
                continue
            
            game.record_hit(player, target, hits)
            
        except ValueError:
            print("Please enter valid numbers.")
            continue
    
    print("\nFinal Scores:")
    for player in range(1, num_players + 1):
        print(f"Player {player}: {game.get_player_score(player)}")

if __name__ == "__main__":
    main() 