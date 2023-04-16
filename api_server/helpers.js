const fs = require('fs');
const { promisify } = require('util');
const stat = promisify(fs.stat);
const sharp = require('sharp');

async function readFileReverse(filePath, processLine) {
    return new Promise((resolve, reject) => {
      let remainder = '';
      let shouldContinue = true;
  
      const readStream = fs.createReadStream(filePath, { encoding: 'utf8' });
  
      readStream
        .on('error', (error) => {
          reject(error);
        })
        .on('data', (chunk) => {
          if (!shouldContinue) {
            return;
          }
  
          const chunkString = chunk.toString();
          let lines = chunkString.split('\n');
          lines[0] = remainder + lines[0];
          remainder = lines.pop();
  
          for (let i = lines.length - 1; i >= 0; i--) {
            const line = lines[i];
            if (line && line.trim() !== '') {
              try {
                shouldContinue = processLine(line, readStream); // Pass the readStream to the processLine function
                if (!shouldContinue) {
                  readStream.close(); // Close the readStream if processLine returns false
                  break;
                }
              } catch (error) {
                console.error(`Error processing line: ${line}`);
              }
            }
          }
        })
        .on('end', () => {
          if (!shouldContinue) {
            return;
          }
  
          if (remainder && remainder.trim() !== '') {
            try {
              processLine(remainder, readStream);
            } catch (error) {
              console.error(`Error processing line: ${remainder}`);
            }
          }
          resolve();
        })
        .on('close', () => {
          resolve();
        });
    });
  }


async function readJsonFile(filePath) {
  let jsonData = {
    player_information: { timestamp: null, data: [] },
    train_information: { timestamp: null, data: [] },
    turret_information: { timestamp: null, data: [] },
    map_information: { timestamp: null, data: [] },
  };

  await readFileReverse(filePath, line => {
    if (line.trim() !== '') {
      try {
        const parsedLine = JSON.parse(line);

        if (parsedLine.player_information) {
          if (
            jsonData.player_information.timestamp === null ||
            parsedLine.player_information.timestamp > jsonData.player_information.timestamp
          ) {
            jsonData.player_information = parsedLine.player_information;
          }
        }

        if (parsedLine.train_information) {
          if (
            jsonData.train_information.timestamp === null ||
            parsedLine.train_information.timestamp > jsonData.train_information.timestamp
          ) {
            jsonData.train_information = parsedLine.train_information;
          }
        }

        if (parsedLine.turret_information) {
          if (
            jsonData.turret_information.timestamp === null ||
            parsedLine.turret_information.timestamp > jsonData.turret_information.timestamp
          ) {
            jsonData.turret_information = parsedLine.turret_information;
          }
        }

        if (parsedLine.map_information) {
            if (
              jsonData.map_information.timestamp === null ||
              parsedLine.map_information.timestamp > jsonData.map_information.timestamp
            ) {
              jsonData.map_information = parsedLine.map_information;
            }
          }
      } catch (error) {
        //console.error(`Invalid JSON line: ${line}`);
      }
    }
    return true; // Continue reading the file
  });

  return jsonData;
}


function initMapInformation() {
    return {
      data: {
        resolution: [0, 0],
        numTiles: 0,
        size: 0,
        lastCheckedSize: 0,
        lastCheckedTime: 0,
        unixTimestamp: 0,
        ready: false,
      },
      timestamp: 0,
    };
  }
  
 // TODO: The ready flag returns true even while the sizes are changing. Instead of returning the image from disk, let's cache the image to memory. This also sets us up to tile, resize, or even lower the quality setting to save space
 async function processMinimapFile(AppConfig, mapInformation) {
    try {
      const minimapPath = AppConfig.minimapPath;
      const { mtime, size } = await stat(minimapPath);
      const now = Date.now();
      const fileModifiedTimestamp = mtime.getTime();
  
      mapInformation = mapInformation || initMapInformation();
  
      const {
        data: {
          unixTimestamp,
          resolution: resolution,
          numTiles,
          size: cachedSize,
          lastCheckedSize,
          lastCheckedTime,
        },
        timestamp,
      } = mapInformation;
  
      if (fileModifiedTimestamp > unixTimestamp || size !== cachedSize) {
        if (size !== lastCheckedSize || now - lastCheckedTime > 500) {
          try {
            // Read the image resolution using sharp
            const imageMetadata = await sharp(minimapPath).metadata();
            const resolution = [imageMetadata.width, imageMetadata.height];
            mapInformation.data.unixTimestamp = fileModifiedTimestamp;
            mapInformation.data.size = size;
            mapInformation.data.resolution = resolution; // Set the resolution
            mapInformation.data.ready = true;
          } catch (error) {
            console.error(`Error reading image resolution: ${error.message}`);
            mapInformation.data.ready = false;
          }
        } else {
          mapInformation.data.ready = false;
        }
        mapInformation.data.lastCheckedSize = size;
        mapInformation.data.lastCheckedTime = now;
  
        // Use the numTiles and timestamp values from the passed mapInformation object
        mapInformation.data.numTiles = numTiles;
        mapInformation.timestamp = timestamp;
      } else {
        mapInformation.data.ready = true;
      }
  
      return mapInformation;
    } catch (error) {
      console.error(`Error processing minimap file: ${error.message}`);
      throw error;
    }
  }

  
  async function updateCache(AppConfig, cache) {
    const kFactsPath = AppConfig.kFactsPath;
  
    try {
      const kFacts = await readJsonFile(kFactsPath);
  
      cache = cache || { data: {} }; 
      const currentData = cache.data;
  
      currentData.player_information = currentData.player_information || { timestamp: 0, data: [] };
      currentData.train_information = currentData.train_information || { timestamp: 0, data: [] };
      currentData.turret_information = currentData.turret_information || { timestamp: 0, data: [] };
      currentData.map_information = currentData.map_information || initMapInformation();
  
      const { player_information, train_information, turret_information, map_information } = kFacts;
  
      if (player_information) {
        if (
          !currentData.player_information.timestamp ||
          player_information.timestamp > currentData.player_information.timestamp
        ) {
          currentData.player_information = player_information;
        }
      }
  
      if (train_information) {
        if (
          !currentData.train_information.timestamp ||
          train_information.timestamp > currentData.train_information.timestamp
        ) {
          currentData.train_information = train_information;
        }
      }
  
      if (turret_information) {
        if (
          !currentData.turret_information.timestamp ||
          turret_information.timestamp > currentData.turret_information.timestamp
        ) {
          currentData.turret_information = turret_information;
        }
      }

      if (map_information) {
        if (
          !currentData.map_information.timestamp ||
          map_information.timestamp > currentData.map_information.timestamp
        ) {
          currentData.map_information = map_information;
        }
      }
      
      // Assign the result of processMinimapFile back to currentData.map_information
      currentData.map_information = await processMinimapFile(AppConfig, currentData.map_information);
  
      //console.log(`Cache Update.`);
      return { data: currentData, timestamp: Date.now() }; // Return the data and the timestamp
    } catch (error) {
      console.error(`Error updating cache: ${error.message}`);
      throw error; // Reject with error
    }
  }

module.exports = {
  readFileReverse,
  updateCache,
};
