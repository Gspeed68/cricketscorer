import React, { useState, useEffect } from 'react';
import axios from 'axios';
import {
  Box,
  Button,
  Container,
  Grid,
  Heading,
  Text,
  VStack,
  HStack,
  useToast,
  Card,
  CardBody,
  SimpleGrid,
} from '@chakra-ui/react';

const TARGETS = [15, 16, 17, 18, 19, 20, 25];
const API_URL = 'http://localhost:8080';

interface GameStatus {
  players: number[];
  scores: number[];
  hits: number[][];
}

const DartsGame: React.FC = () => {
  const [gameStatus, setGameStatus] = useState<GameStatus | null>(null);
  const [loading, setLoading] = useState(false);
  const [currentPlayer, setCurrentPlayer] = useState(0);
  const toast = useToast();

  useEffect(() => {
    fetchGameStatus();
  }, []);

  const fetchGameStatus = async () => {
    try {
      const response = await axios.get(`${API_URL}/status`);
      setGameStatus(response.data);
    } catch (error) {
      console.error('Error fetching game status:', error);
      toast({
        title: 'Error',
        description: 'Failed to fetch game status',
        status: 'error',
        duration: 5000,
        isClosable: true,
      });
    }
  };

  const recordHit = async (target: number, hits: number) => {
    setLoading(true);
    try {
      await axios.post(`${API_URL}/hit`, {
        player_idx: currentPlayer,
        target,
        hits,
      });
      await fetchGameStatus();
      toast({
        title: 'Success',
        description: `Recorded ${hits} hit(s) on target ${target}`,
        status: 'success',
        duration: 3000,
        isClosable: true,
      });
    } catch (error) {
      console.error('Error recording hit:', error);
      toast({
        title: 'Error',
        description: 'Failed to record hit',
        status: 'error',
        duration: 5000,
        isClosable: true,
      });
    } finally {
      setLoading(false);
    }
  };

  return (
    <Container maxW="container.xl" py={8}>
      <VStack spacing={8}>
        <Heading>Darts Cricket Game</Heading>

        <Card w="full">
          <CardBody>
            <VStack spacing={4}>
              <Heading size="md">Current Player</Heading>
              <HStack>
                {[0, 1].map((player) => (
                  <Button
                    key={player}
                    onClick={() => setCurrentPlayer(player)}
                    colorScheme={currentPlayer === player ? 'blue' : 'gray'}
                  >
                    Player {player + 1}
                  </Button>
                ))}
              </HStack>
            </VStack>
          </CardBody>
        </Card>

        <SimpleGrid columns={{ base: 1, md: 2 }} spacing={8} w="full">
          <Card>
            <CardBody>
              <VStack spacing={4}>
                <Heading size="md">Record Hit</Heading>
                <Grid templateColumns="repeat(3, 1fr)" gap={4}>
                  {TARGETS.map((target) => (
                    <Box key={target} p={4} borderWidth={1} borderRadius="md">
                      <VStack spacing={2}>
                        <Text fontWeight="bold">Target: {target}</Text>
                        <HStack>
                          {[1, 2, 3].map((hitCount) => (
                            <Button
                              key={hitCount}
                              onClick={() => recordHit(target, hitCount)}
                              isLoading={loading}
                              colorScheme="blue"
                              size="sm"
                            >
                              {hitCount}
                            </Button>
                          ))}
                        </HStack>
                      </VStack>
                    </Box>
                  ))}
                </Grid>
              </VStack>
            </CardBody>
          </Card>

          <Card>
            <CardBody>
              <VStack spacing={4}>
                <Heading size="md">Game Status</Heading>
                {gameStatus && (
                  <VStack spacing={4} w="full">
                    {gameStatus.players.map((player, index) => (
                      <Box key={player} w="full" p={4} borderWidth={1} borderRadius="md">
                        <VStack align="start" spacing={2}>
                          <Text fontWeight="bold">Player {index + 1}</Text>
                          <Text>Score: {gameStatus.scores[index]}</Text>
                          <SimpleGrid columns={2} spacing={2} w="full">
                            {TARGETS.map((target, targetIndex) => (
                              <Text key={target}>
                                {target}: {gameStatus.hits[index][targetIndex]}/3
                              </Text>
                            ))}
                          </SimpleGrid>
                        </VStack>
                      </Box>
                    ))}
                  </VStack>
                )}
              </VStack>
            </CardBody>
          </Card>
        </SimpleGrid>
      </VStack>
    </Container>
  );
};

export default DartsGame; 