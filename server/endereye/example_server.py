import endereye

server = endereye.Server(endereye.backends["file"]("example_files"))
server.start(port=5000)
