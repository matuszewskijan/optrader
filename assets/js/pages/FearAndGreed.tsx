// pages/fetch-data.tsx

import * as React from 'react';
import { Link } from 'react-router-dom';

import Main from '../components/Main';

// The interface for our API response
interface ApiResponse {
  data: FearAndGreed[];
}

// The interface for our FearAndGreed model.
interface FearAndGreed {
  id: integer,
  value_classification: string;
  value: integer;
  date: datetime;
}

interface FetchFearAndGreedIndex {
  indexes: FearAndGreed[];
  loading: boolean;
}

export default class FearAndGreed extends React.Component<
  {},
  FetchFearAndGreedIndex
> {
  constructor(props: {}) {
    super(props);
    this.state = { fear_and_greed: [], loading: true };

    // Get the data from our API.
    fetch('/api/fear_and_greed')
      .then(response => response.json() as Promise<ApiResponse>)
      .then(data => {
        this.setState({ indexes: data.data, loading: false });
      });
  }

  private static renderFearAndGreedIndex(indexes: FearAndGreed[]) {
    return (
      <table>
        <thead>
          <tr>
            <th>Value Classification</th>
            <th>Value</th>
            <th>Date</th>
          </tr>
        </thead>
        <tbody>
          {indexes.map(index => (
            <tr key={index.id}>
              <td>{index.value_classification}</td>
              <td>{index.value}</td>
              <td>{index.date}</td>
            </tr>
          ))}
        </tbody>
      </table>
    );
  }

  public render(): JSX.Element {
    const content = this.state.loading ? (
      <p>
        <em>Loading...</em>
      </p>
    ) : (
      FearAndGreed.renderFearAndGreedIndex(this.state.indexes)
    );

    return (
      <Main>
        <h1>Fetch Data</h1>
        <p>
          This component demonstrates fetching data from the Phoenix API
          endpoint.
        </p>
        {content}
        <br />
        <br />
        <p>
          <Link to="/">Back to home</Link>
        </p>
      </Main>
    );
  }
}
