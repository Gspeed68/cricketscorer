import React from 'react';
import { ChakraProvider, theme } from '@chakra-ui/react';
import DartsGame from './components/DartsGame';

function App() {
  return (
    <ChakraProvider theme={theme}>
      <DartsGame />
    </ChakraProvider>
  );
}

export default App;
