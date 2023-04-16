const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();
const cors = require('cors');
const factorioModInfo = require('../info.json');
const settings = require('./settings.json');
const { readFileReverse, updateCache } = require('./helpers');

let cachedData = null;

class AppConfig {
  static get port() {
    return settings.port;
  }

  static get cacheExpirationTime() {
    return settings.cacheExpirationTime;
  }

  static get minimapPath() {
    return path.join(__dirname, settings.minimapPath);
  }

  static get kFactsPath() {
    return path.join(__dirname, settings.kFactsPath);
  }

  static get modZipPath(){
    return path.join(__dirname, `../../${factorioModInfo.name}_${factorioModInfo.version}.zip`);
  }
}


// Web Endpoints
app.use(cors());

app.get('', (req, res) => {
  const p = path.join(__dirname, './static/index.html');
  res.sendFile(p);
});

// Serve static files from the 'static' folder
app.use('/static', express.static('./static'));

app.get('/minimap', (req, res) => {
  res.sendFile(AppConfig.minimapPath);
});

const modCurrentVersion = `${factorioModInfo.name}_${factorioModInfo.version}.zip`;
app.get(`/download/${modCurrentVersion}`, (req, res) => {
  res.sendFile(AppConfig.modZipPath);
});

app.get('/readme', (req, res) => {
  const p = path.join(__dirname, '../README.md');
  fs.readFile(p, 'utf8', (err, data) => {
    if (err) {
      res.status(500).send('Error reading README.md file');
    } else {
      res.setHeader('Content-Type', 'text/plain');
      res.send(data);
    }
  });
});

app.get('/api/mod-info', (req, res) => {
  res.json(factorioModInfo);
});

app.get('/api/data', async (req, res) => {
  try {
    res.json(cachedData.data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(AppConfig.port, () => {
  (async () => {
    try {
      cachedData = await updateCache(AppConfig, null);
      setInterval(async () => {
        cachedData = await updateCache(AppConfig, cachedData);
      }, AppConfig.cacheExpirationTime);
    } catch (error) {
      console.error(`Error updating cache: ${error.message}`);
    }
  })();

  console.log(
    `Server is running at http://localhost:${AppConfig.port}. Detected mod version is ${factorioModInfo.version} kFactsPath is ${AppConfig.kFactsPath}`
  );
});
