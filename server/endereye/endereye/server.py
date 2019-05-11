from flask import Flask

class Server:
	def __init__(self,backend):
		self.backend = backend
		self.app = Flask(__name__)
		self.app.route("/getPage/<id>")(self.servePage)
	def servePage(self,id):
		try:
			return self.backend.getPage(id)
		except:
			return self.backend.on404()
	def start(self,*args,**kwargs):
		self.app.run(*args,**kwargs)
