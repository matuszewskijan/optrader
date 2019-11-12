// assets/js/Root.tsx

import * as React from 'react'
import { BrowserRouter, Route, Switch } from 'react-router-dom'

import Header from './components/Header'
import Counter from './pages/Counter'
import HomePage from './pages'
import FearAndGreed from './pages/FearAndGreed'

export default class Root extends React.Component {
  public render(): JSX.Element {
    return (
      <>
        <Header />
        <BrowserRouter>
          <Switch>
            <Route exact path="/" component={HomePage} />
            <Route path="/counter" component={ Counter } />
            <Route path="/fear_and_greed" component={ FearAndGreed } />
          </Switch>
        </BrowserRouter>
      </>
    )
  }
}
