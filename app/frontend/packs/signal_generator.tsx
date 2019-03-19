import * as React from 'react';
import * as ReactDOM from 'react-dom';

import {Button, ButtonToolbar, Container} from 'react-bootstrap';

import { Gaussian } from 'ts-gaussian';

const timerInterval = 100; // milli seconds
const ndist = new Gaussian(0, 0.03);

interface SignalGeneratorState {
  isIntervalRunning: boolean,
};

export class SignalGenerator extends React.Component<{}, SignalGeneratorState> {
  intervalId: number | null = null;

  public state: SignalGeneratorState = {
    isIntervalRunning: false
  };

  componentDidMount() {
    console.log("SignalGenerator did mount.");
  }

  startInterval() {
    if (this.intervalId !== null) return;

    this.intervalId = window.setInterval(() => {
      this.generateSignal()
    }, timerInterval);
    this.setState({ isIntervalRunning: true });
  }

  stopInterval() {
    if (this.intervalId === null) return;
    window.clearInterval(this.intervalId);
    this.intervalId = null;
    this.setState({ isIntervalRunning: false });
  }

  generateSignal() {
    const x = 20*Math.random() - 10;    // A random number in [-10, 10)
    const d = ndist.ppf(Math.random()); // gaussian noise
    const y = Math.sin(x) + d;          // The output
    window.fetch('./signals', {
      method: 'POST',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.getCSRFToken(),
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({x: x, y: y})
    }).then((response) => {
      return response.json();
    }).then((body) => {
      console.log('Success: ', body);
    }).catch((error) => {
      console.error('Error: ', error);
    });
  }

  getCSRFToken() {
    var el = document.querySelector('meta[name="csrf-token"]');
    if (el) {
      return el.getAttribute('content');
    }
    return '';
  }

  render() {
    const { isIntervalRunning } = this.state;
    const clickCallback = () => {
      if (isIntervalRunning) {
        this.stopInterval();
      } else {
        this.startInterval();
      }
    };

    return (<div>
      <ButtonToolbar>
        <Button id="start-stop-button"
                variant={ isIntervalRunning ? "danger" : "success" }
                onClick={ clickCallback }>
          { isIntervalRunning ? 'Stop' : 'Start' } signal
        </Button>
      </ButtonToolbar>
    </div>);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <SignalGenerator />,
    document.body.appendChild(document.createElement('div')),
  )
})
