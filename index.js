(function() {
  var sys = require('sys'),
    fs = require('fs'),
    gsock = '',
    osc = require('node-osc'),
    lodash = require('lodash');

  oscServer = new osc.Server(1337, '0.0.0.0');

  oscServer.on("message", function(msg, rinfo) {
    console.log(msg)
  });
}).call(this);
