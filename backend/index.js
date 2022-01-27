var PORT = process.env.PORT || 3000 || 8000;
var HOST = process.env.HOST || '0.0.0.0';
var app = require('fastify').fastify({ logger: false, ignoreTrailingSlash: true, trustProxy: true });
var socket_io = require("fastify-socket.io");
app.register(require('fastify-cors'), {
    origin: '*'
});

app.register(socket_io);
app.get('/', (req, reply) => {
    reply.send("server run normal @azkadev || @hexaminate");
})

app.ready().then(async function () {
    console.log(app.printRoutes({ commonPrefix: false }));
    app.io.on("connection", async function (socket) {
        console.log(socket.id);
        var users = [];
        for (var [id, socket] of app.io.of("/").sockets) {
            users.push({
                "socket_id": id,
                "username": socket.handshake.auth.username ??"",
                "connected": true
            });
        }
        socket.on("message", async function (update) {
            console.log(JSON.stringify(users, null, 2));
            console.log(update);
            for (var index = 0; index < users.length; index++) {
                var loop_data = users[index];
                if (loop_data["socket_id"] != socket.id){
                    app.io.to(loop_data["socket_id"]).emit("message", update);
                }
            }
            return app.io.to(socket.id).emit("message", update);
        }); 
        socket.on("update", async function (update) {
            console.log(JSON.stringify(users, null, 2));
            console.log(update);
            for (var index = 0; index < users.length; index++) {
                var loop_data = users[index];
                if (loop_data["socket_id"] != socket.id){
                    app.io.to(loop_data["socket_id"]).emit("update", update);
                }
            }
            return app.io.to(socket.id).emit("update", update);
        }); 
        socket.on("connect", () => {
            users.forEach((user) => {
                user["connected"] = true;
            });
            console.log(JSON.stringify(users, null, 2));
        });

        socket.on("disconnect", () => {
            users.forEach((user) => {
                user["connected"] = false;
            });
            console.log(JSON.stringify(users, null, 2));
        });
    });
});

app.listen({ port: PORT, host: HOST, backlog: 511 }, async function (err, addres) {
    if (err) throw err;
    console.log(`server run ${addres}`);
});