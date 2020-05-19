# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)

## [1.0.1#beta] - 2020-05-17
- ```Initial commit```
  - ```Codename Nezuko Released```
## [1.0.2#beta] - 2020-05-20
- ```Fixing```
  - Mass Dumper :  Added Queue, So when mass dumper loops, the dump process will not stop on the second task.
  - Dump Function : Change the dump process to a function so it will be much simpler and not wasting of spaces.
- ```Update```
  - Menu are changed, choosing not so many colors.
  - Added File Checking, it will thrown error if the file doesn't exist your didn't provide any filename.
  - Added Validity Checking for URL, All url that will be inputed must start with ```https://``` or ```http://``` (it will not gonna work when using with `www.example.com` as the format), it will thrown error if the url didn't follow the format or you didn't provide any url.
  - Added Extractor (`Experimental`).
  - Added Dump Only option, this option created for the `Maybe Vuln` scan results or a target that had `Directory Listing` disabled or etc.
  - On every end of the dump process, it will run ```git checkout .``` automatically on the destination folder. This will feature is on whether mass target or single target selected.
