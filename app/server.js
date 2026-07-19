const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from the secure CI/CD pipeline!',
    timestamp: new Date().toISOString(),
  });
});

// Used by the Docker HEALTHCHECK instruction
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy!' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
