import React, { useState } from 'react';

function App() {
  const [name, setName] = useState('');

  const fetchRandomName = async () => {
    const response = await fetch('http://my-go-api-service/random-name');
    const data = await response.json();
    setName(data.name);
  };

  return (
    <div className="App">
      <header className="App-header">
        <button onClick={fetchRandomName}>Get Random Name</button>
        {name && <p>Random Name: {name}</p>}
      </header>
    </div>
  );
}

export default App;