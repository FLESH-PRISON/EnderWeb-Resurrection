from flask import Flask

MAIN_PAGE = """<?xml version="1.0" charset="UTF-8" ?>
<page>
<body>
<drawing align="center">bbb.............d+b.b.eee.444.bb..d+bbb.e.e..44.b.b.d+b...ee..4.4.b...d+b...eee.444.b...d</drawing>
<div align="center" color="gray">Find out more at</div>
<div align="center" color="black">https://github.com/MineRobber9000/enderweb-phoenix</div>
</body>
</page>
"""

app = Flask(__name__)

@app.route("/getPage/000000")
def index():
	return MAIN_PAGE
