import * as React from 'react';
import * as ReactDOM from 'react-dom';

const timerInterval = 1000; // milli seconds

export class SignalGenerator extends React.Component {
  intervalId: number | null = null;
  intervalCount: number = 0;

  componentDidMount() {
    console.log("SignalGenerator did mount.");
    this.initInterval();
  }

  initInterval() {
    console.log(this.intervalId);
    if (this.intervalId !== null) return;

    this.intervalId = window.setInterval(() => {
      this.generateSignal()
      this.intervalCount += 1;
      if (this.intervalCount >= 3) {
        window.clearInterval(this.intervalId);
        this.intervalId = null;
      }
    }, timerInterval);
  }

  generateSignal() {
    window.fetch('./signals', {
      method: 'POST',
      headers: {
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.getCSRFToken(),
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: '"ahi"'
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
    return <div></div>;
  }
}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <SignalGenerator />,
    document.body.appendChild(document.createElement('div')),
  )
})
