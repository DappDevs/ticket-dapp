import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import web3 from './web3';
import ticketbooth from './ticketbooth';

class App extends Component {

  // 
  state = {
    master: '',
    token: '',
    details_url: '',
    cost: '',
    tickets_left: '',
    balance: '',
  };

  async componentDidMount() {
    // Sync state variables with contract

    // Let's check that web3 is loading correctly first...
    //console.log(web3.version);
    //console.log(web3.eth.getAccounts().then(console.log));

    // Accessor methods
    const master = await ticketbooth.methods.ticketMaster().call();
    const token = await ticketbooth.methods.token().call();
    const details_url = await ticketbooth.methods.eventDetailsURL().call();
    const cost = await ticketbooth.methods.eventCost().call();
    const tickets_left = await ticketbooth.methods.ticketsLeft().call();

    // Contract state
    const balance = await web3.eth.getBalance(ticketbooth.options.address);

    this.setState({ 
        master, token, details_url, cost, tickets_left, balance
    });
  }

  buyTicket = async () => {
    const accounts = await web3.eth.getAccounts();

    this.setState({ message: 'Waiting on purchase transaction success...'});

    await ticketbooth.methods.buyTicket().send({
      from: accounts['0'],
      value: web3.utils.toWei(this.state.cost, 'ether')
    });

    console.log('Transaction sent, now pending',this.state);

    this.setState({ message: 'Your ticket has been purchased!' });
  }

  render() {
    return (
      <div>
          <div>
            <h2>My Ticket Booth</h2>
              <p>Ticket master: {this.state.master}</p>

              <p><a href={this.state.details_url}>Click for event details</a>

              </p>

              <p>See token on <a href={"https://etherscan.io/address/"+this.state.token}>Etherscan</a></p>
          </div>

          <div>
            <h4>Buy a ticket</h4>

            <button onClick={this.buyTicket} >Purchase ticket for {web3.utils.fromWei(this.state.cost,'ether')} Ether</button>

            Only {this.state.tickets_left} tickets left!
          </div>
      </div>

    );
  }
}

export default App;
