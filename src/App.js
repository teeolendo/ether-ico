import './App.css'
import React, { useState, useEffect } from 'react';
import SpaceICO from './artifacts/contracts/SpaceICO.sol/SpaceICO.json'
import { ethers } from 'ethers'
require("dotenv").config();

function App() {
  const spaceICOAddress = '0x5FbDB2315678afecb367f032d93F642f64180aa3'
  const [phase, setPhase] = useState('');
  
  async function requestAccount() {
    await window.ethereum.request({ method: 'eth_requestAccounts' });
  }

  useEffect(() => {
    async function fetchPhase() {
      if (typeof window.ethereum !== 'undefined') {
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        const contract = new ethers.Contract(spaceICOAddress, SpaceICO.abi, provider)
        try {
          const data = await contract.icoPhase()
          const currentPhase = data === 0 ? 'Seed' : data === 1 ? 'General' : 'Open'
          setPhase(currentPhase)
        } catch (err) {
          console.log("Error: ", err)
        }
      }
    }
    fetchPhase();
  });

  return (
    <main>
      <div id="container">
      
        <form action="">
          <h1 className="welcome-text">Welcome to Space Coin</h1>
          <img alt="Space Coin Logo" src="https://image.freepik.com/free-vector/colorful-space-rocket-composition-with-flat-design_23-2147912638.jpg"/><br/>
          <h2 className="phase-text">The ICO is in the {phase} Phase</h2>
          <h3 className="phase-text">Enter a figure in Ether below to invest</h3>
          <input type="number" placeholder="O Ether"/><br/>
          <button onClick={requestAccount}>INVEST</button><br/>
        </form>
      </div>
    </main>
  );
}

export default App;
