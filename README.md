# Progressr - Flight progress for PilotEdge

Progressr is a service that provides information about the progress of flights on the [PilotEdge ATC network](http://pilotedge.net). Initially conceived as a backend for the progress overlay on my Twitch stream, I decided to release it in case it could be of use to others. 

## Usage

* Find your PilotEdge user id. This can be found on [PEAware](http://peaware.pilotedge.net).
* Retrieve the flight progress from Progressr: ```http://host/pe/status/[your_id]```

## Project Status

This is a very young spare time project. Although the code is mostly stable from my ad-hoc trials, I have not done any formal unit testing. It is provided here as-is. 

## Contributing

I welcome any contribution. Feel free to submit a pull request or issue report.

## Installing

Requirements for running: 

* Swift 3 (Currently available on macOS, and Ubuntu Linux)
* A copy of the FAA airport database ('NfdcFacilities'). [Download the Excel sheet from the FAA website](https://www.faa.gov/airports/airport_safety/airportdata_5010/), remove all columns except for ```LocationID```, ```ARPLatitude```, and ```ARPLongitude```, then save as a CSV. 

After cloning the repository, run the following in the project's root directory:
* ```swift build```
* ```.path/to/build/Progressr --nfdc.path=<path-to-nfdcfacilities-csv> --server.port=<tcp_port>```
