# Clone of File.io/WeTransfer

[ TODO badge:deploy ][ TODO badge:#microservices ][ TODO badge:storyscript-lines ]

This example application is a basic clone of [File.io](https://file.io) / [WeTransfer](https://wetransfer.com).

## Goals
1. Upload a file
1. Store the file in S3
1. Schedule the file to delete after 1 day
1. Return a link to the file location
1. Delete the file after viewing once

## Deploy
Click here to deploy your own copy of this app now: [ TODO badge:deploy ]

```sh
asyncy apps create template=fileio
asyncy deploy
```
