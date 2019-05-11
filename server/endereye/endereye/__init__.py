import importlib, pkgutil, endereye.backends

from endereye.server import Server

def iter_namespace(ns_pkg):
	return pkgutil.iter_modules(ns_pkg.__path__,ns_pkg.__name__+".")

backends = {
	name[len(endereye.backends.__name__+"."):]: importlib.import_module(name)
	for finder, name, ispkg
	in iter_namespace(endereye.backends)
}

for k in backends:
	backends[k]=getattr(backends[k],k.title()+"Backend")
