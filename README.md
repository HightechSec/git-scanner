# Git Scanner Framework
![License](https://img.shields.io/badge/License-GPL-blue.svg?style=flat)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/HightechSec/git-scanner)
![GitHub repo size](https://img.shields.io/github/repo-size/HightechSec/git-scanner)
![GitHub last commit](https://img.shields.io/github/last-commit/HightechSec/git-scanner)
![GitHub stars](https://img.shields.io/github/stars/HightechSec/git-scanner)
![GitHub pull requests](https://img.shields.io/github/issues-pr/HightechSec/git-scanner)
![GitHub forks](https://img.shields.io/github/forks/HightechSec/git-scanner)
![GitHub issues](https://img.shields.io/github/issues/HightechSec/git-scanner)
![GitHub watchers](https://img.shields.io/github/watchers/HightechSec/git-scanner)

This tool can scan websites with open ```.git``` repositories for `Bug Hunting`/ `Pentesting` and can dump the content of the ```.git``` repositories from webservers that found from the scanning method. This tool works with the provided Single or Mass Target

<img src="https://raw.githubusercontent.com/HightechSec/git-scanner/master/img/1-gitscanner.PNG" width="30%"></img> <img src="https://raw.githubusercontent.com/HightechSec/git-scanner/master/img/2-gitscanner.PNG" width="30%"></img> <img src="https://raw.githubusercontent.com/HightechSec/git-scanner/master/img/3-gitscanner.PNG" width="30%"></img> 
## Installation
```
- git clone https://github.com/HightechSec/git-scanner
- cd git-scanner
- bash gitscanner.sh
``` 
or you can install in your system like this
```
- git clone https://github.com/HightechSec/git-scanner
- cd git-scanner
- sudo cp gitscanner.sh /usr/bin/gitscanner && sudo chmod +x /usr/bin/gitscanner
- $ gitscanner
```
## Usage
- Menu `1` is for scanning and dumping git repositories from a provided file that contains the list of url target
- Menu `2` is for scanning and dumping git repositories from a provided single url target
- Menu `3` is for scanning only the git repositories from a provided file that contains the list of url target 
- Menu `4` is for scanning only the git repositories from a provided single url target

## Requirements
* curl
* bash
* git
* sed

## Todo
- Creating a `Docker Images` if it's possible
- Adding Extractor on the next Version

# Credits
Thanks to:
- [GitTools](https://github.com/internetwache/GitTools) by [internetwache](https://github.com/internetwache/)
- [Mass Git Scanner](https://github.com/Adelittle/Mass_Git_Scanner/) by [Ade Little](https://github.com/Adelittle/)
