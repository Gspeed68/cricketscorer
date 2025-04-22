// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title DartsCricket
 * @author Your Name
 * @notice A smart contract implementation of the Darts Cricket game on the Ethereum blockchain
 * @dev This contract implements the rules of Cricket darts game, allowing players to record hits and track scores
 * 
 * Game Rules:
 * - Players aim to "close" numbers 15 through 20 and the bullseye (25) by hitting them three times
 * - Once a player closes a number, they can score points on it if their opponent hasn't closed it
 * - Points are calculated as: (hits - 2) * number value
 * - The game continues until all numbers are closed
 */
contract DartsCricket {
    // Constants
    /// @notice Maximum number of players allowed in a game
    uint8 constant MAX_PLAYERS = 10;
    
    /// @notice Array of valid target numbers in the game (15-20 and bullseye)
    uint8[7] constant TARGETS = [15, 16, 17, 18, 19, 20, 25]; // 25 represents bullseye
    
    // Game state
    /// @notice Array of player addresses participating in the game
    address[] public players;
    
    /// @notice Mapping of player addresses to their current scores
    mapping(address => uint256) public scores;
    
    /// @notice Mapping of player addresses to their hits on each target
    /// @dev Structure: player => target => number of hits
    mapping(address => mapping(uint8 => uint8)) public hits;
    
    // Events
    /// @notice Emitted when a new game is started
    /// @param players Array of addresses of players participating in the game
    event GameStarted(address[] players);
    
    /// @notice Emitted when a player records a hit
    /// @param player Address of the player who made the hit
    /// @param target The target number that was hit
    /// @param hits Number of hits recorded
    event HitRecorded(address player, uint8 target, uint8 hits);
    
    /// @notice Emitted when a player's score is updated
    /// @param player Address of the player whose score was updated
    /// @param newScore The player's new score
    event ScoreUpdated(address player, uint256 newScore);
    
    // Modifiers
    /// @notice Ensures the caller is a valid player in the game
    modifier validPlayer() {
        require(isPlayer(msg.sender), "Not a valid player");
        _;
    }
    
    /// @notice Ensures the target number is valid
    /// @param target The target number to validate
    modifier validTarget(uint8 target) {
        require(isValidTarget(target), "Invalid target number");
        _;
    }
    
    /**
     * @notice Initializes a new game with the specified players
     * @param _players Array of addresses of players participating in the game
     * @dev The number of players cannot exceed MAX_PLAYERS
     */
    constructor(address[] memory _players) {
        require(_players.length <= MAX_PLAYERS, "Too many players");
        players = _players;
        emit GameStarted(_players);
    }
    
    // Helper functions
    /**
     * @notice Checks if an address is a valid player in the game
     * @param _player The address to check
     * @return bool True if the address is a player, false otherwise
     */
    function isPlayer(address _player) public view returns (bool) {
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == _player) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @notice Checks if a target number is valid in the game
     * @param target The target number to check
     * @return bool True if the target is valid, false otherwise
     */
    function isValidTarget(uint8 target) public pure returns (bool) {
        for (uint i = 0; i < TARGETS.length; i++) {
            if (TARGETS[i] == target) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @notice Checks if a player has closed a specific number
     * @param player The address of the player to check
     * @param target The target number to check
     * @return bool True if the player has closed the number, false otherwise
     */
    function isNumberClosed(address player, uint8 target) public view returns (bool) {
        return hits[player][target] >= 3;
    }
    
    // Main game functions
    /**
     * @notice Records a hit for the calling player
     * @param target The target number that was hit
     * @param numHits The number of hits to record (1-3)
     * @dev This function:
     * - Validates the player and target
     * - Records the hits
     * - Updates scores if the number is closed
     * - Emits appropriate events
     */
    function recordHit(uint8 target, uint8 numHits) external validPlayer validTarget(target) {
        require(numHits > 0 && numHits <= 3, "Invalid number of hits");
        
        // Record the hit
        hits[msg.sender][target] += numHits;
        emit HitRecorded(msg.sender, target, numHits);
        
        // Check if number is closed
        if (hits[msg.sender][target] >= 3) {
            // Check if other players haven't closed this number
            bool otherPlayersClosed = true;
            for (uint i = 0; i < players.length; i++) {
                if (players[i] != msg.sender && !isNumberClosed(players[i], target)) {
                    otherPlayersClosed = false;
                    break;
                }
            }
            
            if (!otherPlayersClosed) {
                // Calculate points
                uint256 points = (hits[msg.sender][target] - 2) * target;
                scores[msg.sender] += points;
                emit ScoreUpdated(msg.sender, scores[msg.sender]);
            }
        }
    }
    
    // View functions
    /**
     * @notice Gets the current score of a player
     * @param player The address of the player
     * @return uint256 The player's current score
     */
    function getPlayerScore(address player) external view returns (uint256) {
        return scores[player];
    }
    
    /**
     * @notice Gets the number of hits a player has on a specific target
     * @param player The address of the player
     * @param target The target number
     * @return uint8 The number of hits the player has on the target
     */
    function getPlayerHits(address player, uint8 target) external view returns (uint8) {
        return hits[player][target];
    }
    
    /**
     * @notice Gets the current status of the game
     * @return _players Array of player addresses
     * @return _scores Array of player scores
     * @return _hits 2D array of hits for each player on each target
     */
    function getGameStatus() external view returns (
        address[] memory _players,
        uint256[] memory _scores,
        uint8[][] memory _hits
    ) {
        _players = players;
        _scores = new uint256[](players.length);
        _hits = new uint8[][](players.length);
        
        for (uint i = 0; i < players.length; i++) {
            _scores[i] = scores[players[i]];
            _hits[i] = new uint8[](TARGETS.length);
            for (uint j = 0; j < TARGETS.length; j++) {
                _hits[i][j] = hits[players[i]][TARGETS[j]];
            }
        }
        
        return (_players, _scores, _hits);
    }
} 