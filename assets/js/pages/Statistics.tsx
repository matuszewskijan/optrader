// pages/fetch-data.tsx

import * as React from 'react';
import { Link } from 'react-router-dom';

import Main from '../components/Main';

import IntervalButton from './statistics/IntervalButton'
import Chart from './statistics/Chart';
import { DateRangePicker, DayPickerRangeController } from 'react-dates';

export default class Statistics extends React.Component<{}>
{
  constructor(props: {}) {
    super(props);
    this.state = { clickedIndex: 24, startDate: null, endDate: null, eDate: null, sDate: null };

    this.apiCalls = [
      { 'path': '/api/fear_and_greed', 'label':'Fear and Greed', 'borderColor':'rgba(226,57,6,0.6)' },
      { 'path': '/api/trends', 'label':'Trends', 'borderColor':'rgb(6, 129, 222,0.6)' }
    ];

    this.intervals = [24, 1];
  }

  intervalHandler(index) {
    this.setState({clickedIndex: index});
  }

  dateHandler(startDate, endDate) {
    this.setState({ startDate, endDate })

    if (startDate && endDate) {
      this.setState(
        { sDate: startDate.startOf('day').format('X'), eDate: endDate.endOf('day').format('X') }
      );
    }
  }

  public render(): JSX.Element {
    return (
      <Main>
        <div>
          Select interval:
          {
            this.intervals.map(
              (i) => <IntervalButton key={i}
                                     clicked={i === this.state.clickedIndex}
                                     onClick={() => this.intervalHandler(i)}
                                     index={i}
                     />
            )
          }
        </div>
        <div>
          <DateRangePicker
            startDate={this.state.startDate} // momentPropTypes.momentObj or null,
            startDateId="your_unique_start_date_id" // PropTypes.string.isRequired,
            endDate={this.state.endDate} // momentPropTypes.momentObj or null,
            endDateId="your_unique_end_date_id" // PropTypes.string.isRequired,
            onDatesChange={({ startDate, endDate }) => this.dateHandler(startDate, endDate)} // PropTypes.func.isRequired,
            focusedInput={this.state.focusedInput} // PropTypes.oneOf([START_DATE, END_DATE]) or null,
            onFocusChange={focusedInput => this.setState({ focusedInput })} // PropTypes.func.isRequired,
            isOutsideRange={() => false}
          />
        </div>
        <Chart key={this.state.eDate + this.state.clickedIndex}
               apiCalls={this.apiCalls} interval={this.state.clickedIndex}
               startDate={this.state.sDate} endDate={this.state.eDate}/>
      </Main>
    );
  }
}
