# Factorio Realtime Map API

![A screenshot of a web browser displaying the kFacts map view with multiple player icons](/api_server/static/readme_banner.png)
This API provides an interface to process and serve real-time game data from the popular game Factorio. It utilizes a custom mod that saves game data to storage. The API is designed to be used by a custom mapping webpage, enabling a map view for the player's second monitor.

## Getting Started: Running the Mod
- Start the server with npm start
- Navigate to the web service's (commonly http://localhost:3000/)
- Click on the link to download the Factorio mod
- Save the mod to your Factorio mods directory
    - On Windows, this is usually C:\Users\<your user name>\appdata\Roaming\Factorio\mods
    - On MacOS, this is usually ~/Library/Application Support/factorio/mods
    - On Linux, this is usually ~/.factorio/mods
- Access the map view from the web service's page

These instructions will help you set up the project on your local machine for development and testing purposes.

## API Endpoints

The API has one main endpoint:

- `/api/data`: Returns the latest game data (player information, train information, and turret information) in JSON format.

### Prerequisites

- Node.js (v14.x.x or higher)
- Npm (v6.x.x or higher)

### Installation

1. Clone the repository to your local machine:
```
git clone https://github.com/KK4TEE/kFacts.git
```

2. Change to the project directory:
```
cd kFacts
cd kFacts
```

3. Install the required dependencies:
```
npm install
```


## Running the API Server

To start the API server, run the following command in the project directory:
```
npm start
```

The server will start and listen on port 3000 by default. You can access the API at http://localhost:3000.

## Building from source
1. Ensure Node.js is installed on your system. If not, download it from https://nodejs.org/.

2. Navigate to the `api_server` directory, where the `build.js` script is located:
```
cd api_server
```

3. Install the required dependencies:
```
npm install
```

4. Run the `build.js` script to create the zip file:
```
node build.js
```

The script will generate a zip file named `<name>-<version>.zip` (e.g., `kFacts-0.3.0.zip`) in the parent directory.
`<name>` and `<version>` are taken from the `info.json` file.
The zip file will contain the contents of the parent directory, excluding the files and directories specified in the `.gitignore` file and the generated zip file itself.

## Testing

The project uses the Mocha and Chai testing frameworks for unit testing. To run the tests, use the following command:
```
npm test
```

This will execute the tests in the `test` directory and display the results in the console.

## Built With

- [Node.js](https://nodejs.org/) - JavaScript runtime
- [Express](https://expressjs.com/) - Web application framework
- [Mocha](https://mochajs.org/) - JavaScript test framework
- [Chai](https://www.chaijs.com/) - Assertion library

## Contributing

Please read [CONTRIBUTING.md](https://github.com/KK4TEE/kFact/blob/main/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/KK4TEE/kFact/blob/main/LICENSE.md) file for details.
