const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const audioRoutes = require('./routes/audioRoutes');
const weatherRoutes = require('./routes/weatherRoutes');
require('dotenv').config();

app.get('/', (req, res) => {
  res.send('Hello World!');
});
app.use('/audio', express.json(), audioRoutes);
app.use('/weather', weatherRoutes);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
