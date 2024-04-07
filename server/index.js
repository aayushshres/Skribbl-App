require('dotenv').config();
const express = require("express");
var http = require("http");
const app = express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
const mongoose = require("mongoose");

var socket = require("socket.io");
var io = socket(server);

// middleware
app.use(express.json());

// connect to database
const DB = process.env.MONGODB_URL;

mongoose.connect(DB).then(() => {
    console.log("Connection Successful!");
}).catch((e) => {
    console.log(e);
})

server.listen(port, "0.0.0.0", () => {
    console.log("Server started and running on port " + port);
})