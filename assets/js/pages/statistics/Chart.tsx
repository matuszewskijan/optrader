import * as React from 'react';
import { Link } from 'react-router-dom';
import { Line } from 'react-chartjs-2';

export default class Chart extends React.Component<{}> {
  constructor(props: {}) {
    super(props);
    this.state = { data: [], loading: true };
  }

  componentDidMount() {
    var apiCalls = this.props.apiCalls
    var params = {
      interval: this.props.interval,
      startDate: this.props.startDate,
      endDate: this.props.endDate,
    }



    return Promise.all(
      apiCalls.map(
      dataObj => {
        console.log(location.host)
          var url = new URL('http://' + location.host + dataObj.path)
          Object.keys(params).forEach(key => url.searchParams.append(key, params[key]))
          return fetch(url)
        // dataObj => fetch(dataObj.path, { params: params })
      })
    )
    .then(results => Promise.all(results.map(res => res.json())))
    .then(results => this.setState({
        data: {
            'labels': results[0].data.map(data => data.date),
            'datasets': results.map(function (result, index) {
              return {
                  label: apiCalls[index].label,
                  data: result.data.map(data => data.value),
                  labels: result.data.map(data => data.label),
                  borderColor: apiCalls[index].borderColor
              }
            })
            //     {
            //         'label': 'Test',
            //         'data': [1,2, 3], //results.reduce((prev, next) => prev.concat(next), []),
            //         'backgroundColor': apiCalls.map(dataObj => dataObj.bgColor)
            //     }
            // ]
        },
        loading: false
    }));
  }

  renderChart() {
    return (
      <Line data={this.state.data} />
    );
  }

  public render(): JSX.Element {
    const content = this.state.loading ? (
      <p>
        <em>Loading...</em>
      </p>
    ) : (
      this.renderChart()
    );

    return (
      <div>
        {content}
        <p>
          <Link to="/">Back to home</Link>
        </p>
      </div>
    );
  }
}
