import * as React from 'react';
import { BrowserRouter, Route, Switch } from 'react-router-dom';

import Header from './components/Header';
import HomePage from './pages';
import Statistics from './pages/Statistics';

const Root: React.FC = () => (
  <>
    <Header />
    <BrowserRouter>
      <Switch>
        <Route exact path="/" component={HomePage} />
        <Route path="/statistics" component={Statistics} />
      </Switch>
    </BrowserRouter>
  </>
);

export default Root;
