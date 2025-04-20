import React from 'react';
import { render } from '@testing-library/react';
import DartsGame from './DartsGame';

describe('DartsGame', () => {
  it('renders without crashing', () => {
    render(<DartsGame />);
  });
}); 