const fs = require('fs');
const path = require('path');
const { createWriteStream, promises: fsPromises } = fs;
const archiver = require('archiver');

async function createZipFile(inputPath, zipFilePath) {
    try {
      const infoJson = JSON.parse(await fsPromises.readFile(path.join(inputPath, 'info.json'), 'utf8'));
      const { name, version } = infoJson;
  
      const outputPath = path.join(zipFilePath, `${name}_${version}.zip`);
      const output = createWriteStream(outputPath);
      const archive = archiver('zip', {
        zlib: { level: 9 }, // Sets the compression level.
      });
  
      const excludePaths = [
        path.join(inputPath, 'build.js'),
        outputPath, // Exclude the newly created zip file.
        // Add more paths to exclude as needed
      ];
  
      const customFileFilter = (entry) => {
        return !excludePaths.includes(entry.name);
      };
  
      output.on('close', () => {
        console.log(`Zip file created: ${outputPath}`);
      });
  
      // Add this event listener to exit the script when the archive is complete
      output.on('finish', () => {
        process.exit();
      });
  
      archive.on('warning', (err) => {
        if (err.code === 'ENOENT') {
          console.warn('Warning:', err);
        } else {
          throw err;
        }
      });
  
      archive.on('error', (err) => {
        throw err;
      });
  
      archive.pipe(output);
      archive.glob('**/*', { cwd: inputPath, ignore: excludePaths.map(p => path.relative(inputPath, p)), dot: true }, { filter: customFileFilter });
      archive.finalize();
    } catch (error) {
      console.error('Error creating zip file:', error);
    }
  }
  
  // TODO: Exclude .git folder
  
  if (!module.parent) {
    const inputPath = '../';
    const zipFilePath = path.join(inputPath, '../')
    createZipFile(inputPath, zipFilePath);
  }
  
