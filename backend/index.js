const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const audioRoutes = require('./routes/audioRoutes');
const weatherRoutes = require('./routes/weatherRoutes');
const assetsRoutes = require('./routes/assetRoutes');
require('dotenv').config();
const ASSET_LENDING_ADDRESS = "0x20dd56804752f7815b1131205c6e3d9cbe71ec9a";
const RPC_URL = "https://your-rpc-endpoint";
const privateKey = process.env.PRIVATE_KEY;

app.get('/', (req, res) => {
  res.send('Hello World!');
});
app.use('/audio', express.json(), audioRoutes);
app.use('/weather', weatherRoutes);
app.use('/assets', express.json(), assetsRoutes);

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
