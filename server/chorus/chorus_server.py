from flask import Flask, render_template_string, Response
import os
from pathlib import Path

class EnderWebServer:
    def __init__(self, pages_directory="example_files"):
        self.app = Flask(__name__)
        self.pages_directory = pages_directory
        self.setup_routes()
        
        # Enable hot reloading in development
        self.app.config['TEMPLATES_AUTO_RELOAD'] = True
        
        # Ensure pages directory exists
        Path(pages_directory).mkdir(parents=True, exist_ok=True)
        
    def setup_routes(self):
        # Main EnderWeb API route
        self.app.route("/getPage/<id>")(self.serve_page)
        
        # Status verification page
        self.app.route("/")(self.serve_status_page)
        
        # Serve the default page at root as well
        self.app.route("/getPage/")(self.serve_default_page)
        
    def serve_default_page(self):
        """Serve the default page (000000) when no ID is provided"""
        return self.serve_page('000000')
        
    def serve_status_page(self):
        """Serve a simple status page for chorus.enderweb.com"""
        status_html = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>Chorus Server Status</title>
            <style>
                body {
                    font-family: monospace;
                    background-color: #1a1a1a;
                    color: #33ff33;
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    height: 100vh;
                    margin: 0;
                }
                .status-container {
                    text-align: center;
                    padding: 20px;
                    border: 2px solid #33ff33;
                    border-radius: 10px;
                }
                .status {
                    font-size: 24px;
                    margin: 20px 0;
                }
                .info {
                    font-size: 16px;
                    color: #cccccc;
                }
            </style>
        </head>
        <body>
            <div class="status-container">
                <h1>EnderWeb Chorus Server</h1>
                <div class="status">Status: ONLINE</div>
                <div class="info">
                    Access pages at: /getPage/[page_id]<br>
                    Example: <a href="/getPage/000000" style="color: #33ff33;">/getPage/000000</a>
                </div>
            </div>
        </body>
        </html>
        """
        return render_template_string(status_html)
        
    def serve_page(self, id):
        # Convert to 6-digit format
        page_id = str(id).zfill(6)
        
        try:
            page_content = self.get_page(page_id)
            # Return XML with proper content type
            return Response(page_content, mimetype='application/xml')
        except Exception as e:
            print(f"Error serving page {page_id}: {str(e)}")
            return self.get_page('000404')
            
    def get_page(self, page_id):
        """Get page content from file system"""
        file_path = os.path.join(self.pages_directory, f"{page_id}.xml")
        
        try:
            with open(file_path, 'r') as f:
                return f.read()
        except FileNotFoundError:
            if page_id != '000404':  # Prevent infinite recursion
                return self.get_page('000404')
            else:
                # Basic 404 page if 000404.xml is missing
                return """<?xml version="1.0" charset="UTF-8" ?>
                        <page>
                        <body>
                        <div align="center" color="gray">Page not found</div>
                        </body>
                        </page>"""
                        
    def run(self, host='0.0.0.0', port=5000, debug=False):
        self.app.run(host=host, port=port, debug=debug)

if __name__ == "__main__":
    server = EnderWebServer()
    # Enable debug mode when running directly
    server.run(debug=True)