from endereye.backends import Backend
from os.path import join as joinPath
from os.path import exists

class FileBackend(Backend):
	def __init__(self,base):
		self.basedir = base
	def getPage(self,id):
		try:
			with open(joinPath(self.basedir,str(id).zfill(6)+".xml")) as f:
				return f.read()
		except FileNotFoundError:
			return self.getPage(404)
	def hasPage(self,id):
		return exists(joinPath(self.basedir,str(id)+".xml"))
