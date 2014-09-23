
var express = require('express.io')
var open = require('open')
var watch = require('watch')

var app = express()
app.http().io()

// app.use("/export", express.static(__dirname + 'export'));

// Setup the ready route.
app.io.route('ready', function(req) {
    req.io.respond({
        success: 'here is your acknowledegment for the ready event'
    })
})

app.io.route('setting', function(req) {
	open("lightroom://com.hazanjon.lightroom.remotecontrol/?op=setting&set="+req.data.set+"&val="+req.data.val+"");
    req.io.respond({
        success: 'loading'
    })
})

app.get('/', function(req, res) {
    res.sendfile(__dirname + '/client.html');
})

app.get('/lightroom', function(req, res) {
    console.log(req.query);
    req.io.broadcast('upimage')
})


watch.createMonitor('export', function (monitor) {
monitor.files['export/export.jpg']
monitor.on("created", function (f, stat) {
  // Handle new files
})
monitor.on("changed", function (f, curr, prev) {
  	// Handle file changes
  	console.log('changed');
	app.io.broadcast('upimage')
})
monitor.on("removed", function (f, stat) {
  // Handle removed files
})
})

app.use(express.static(__dirname + '/'));

app.listen(7076)
