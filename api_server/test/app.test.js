const chai = require('chai');
const {readFileReverse} = require('../app');
const fs = require('fs');
const path = require('path');

const expect = chai.expect;

describe('readFileReverse', () => {
  const testFilePath = path.join(__dirname, 'testFile.txt');

  beforeEach(async () => {
    await fs.promises.writeFile(
      testFilePath,
      'line1\nline2\nline3\nline4\nline5\n',
      'utf8'
    );
  });

  afterEach(async () => {
    await fs.promises.unlink(testFilePath);
  });

  it('should process lines in reverse order', async () => {
    const lines = [];

    await readFileReverse(testFilePath, line => {
      lines.push(line);
      return true;
    });

    expect(lines).to.deep.equal(['line5', 'line4', 'line3', 'line2', 'line1']);
  });

  it('should stop processing lines when processLine returns false', async () => {
    const lines = [];

    await readFileReverse(testFilePath, line => {
      lines.push(line);
      return line !== 'line3';
    });

    expect(lines).to.deep.equal(['line5', 'line4', 'line3']);
  });

  it('should not hang when there is an error in one of the lines', async () => {
    await fs.promises.writeFile(
      testFilePath,
      'line1\nline2\n{"invalidJson":\nline4\nline5\n',
      'utf8'
    );

    const lines = [];

    await readFileReverse(testFilePath, line => {
      lines.push(line);
      return line !== 'line4';
    });

    expect(lines).to.deep.equal(['line5', 'line4']);
  });
});
