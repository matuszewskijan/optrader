import * as React from 'react';

export default class IntervalButton extends React.Component<{}> {
  constructor(props: {}) {
    super(props);
  }

  public render(): JSX.Element {
    return (
      <button className={`interval ${this.props.clicked ? 'active': ''}`}
           onClick={this.props.onClick}>
      {this.props.index}H
      </button>
    );
  }
}
