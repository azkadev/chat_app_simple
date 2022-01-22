const server = require('http').createServer();
const socketIO = require('socket.io')(server);

socketIO.on('connection', function (client) {
  console.log('connect:', client["id"]);
  console.log(client);
  client.on('message', function name(data) {
    console.log(data);
    socketIO.emit('message', data);
  })

  client.on('disconnect', function () {
    console.log('Disconnected...', client.id);
  })

  client.on('error', function (err) {
    console.log('Error detected', client.id);
    console.log(err);
  })
})

var port = process.env.PORT || 3000;

server.listen(port, function (err) {
  if (err) console.log(err);
  console.log('Listening on port', port);
});