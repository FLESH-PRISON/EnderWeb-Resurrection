class NotImplementedError(Exception):
	def __init__(self,method):
		super(NotImplementedError,self).__init__("Subclass fails to implement "+method)

class Backend:
	def __init__(self):
		pass
	def getPage(self,id):
		raise NotImplementedError("Backend.getPage")
	def on404(self):
		try:
			return getPage(self,404) # automatic behavior
		except NotImplementedError: # rename
			raise NotImplementedError("Backend.on404")
	def hasPage(self,id):
		raise NotImplementedError("Backend.hasPage")
