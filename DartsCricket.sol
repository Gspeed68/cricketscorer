// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DartsCricket {
    // Constants
    uint8 constant MAX_PLAYERS = 10;
    uint8[7] constant TARGETS = [15, 16, 17, 18, 19, 20, 25]; // 25 represents bullseye
    
    // Game state
    address[] public players;
    mapping(address => uint256) public scores;
    mapping(address => mapping(uint8 => uint8)) public hits; // player => target => hits
    
    // Events
    event GameStarted(address[] players);
    event HitRecorded(address player, uint8 target, uint8 hits);
    event ScoreUpdated(address player, uint256 newScore);
    
    // Modifiers
    modifier validPlayer() {
        require(isPlayer(msg.sender), "Not a valid player");
        _;
    }
    
    modifier validTarget(uint8 target) {
        require(isValidTarget(target), "Invalid target number");
        _;
    }
    
    // Constructor
    constructor(address[] memory _players) {
        require(_players.length <= MAX_PLAYERS, "Too many players");
        players = _players;
        emit GameStarted(_players);
    }
    
    // Helper functions
    function isPlayer(address _player) public view returns (bool) {
        for (uint i = 0; i < players.length; i++) {
            if (players[i] == _player) {
                return true;
            }
        }
        return false;
    }
    
    function isValidTarget(uint8 target) public pure returns (bool) {
        for (uint i = 0; i < TARGETS.length; i++) {
            if (TARGETS[i] == target) {
                return true;
            }
        }
        return false;
    }
    
    function isNumberClosed(address player, uint8 target) public view returns (bool) {
        return hits[player][target] >= 3;
    }
    
    // Main game functions
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
    function getPlayerScore(address player) external view returns (uint256) {
        return scores[player];
    }
    
    function getPlayerHits(address player, uint8 target) external view returns (uint8) {
        return hits[player][target];
    }
    
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