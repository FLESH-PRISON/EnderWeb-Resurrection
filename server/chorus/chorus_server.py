from flask import Flask, request, jsonify, abort
import os
from pathlib import Path

class EnderWebServer:
    def __init__(self):
        self.app = Flask(__name__)
        self.setup_routes()
        
    def setup_routes(self):
        # Main page routes
        self.app.route('/getPage/<page_id>')(self.serve_page)
        
    def serve_page(self, page_id):
        # Convert to 6-digit format
        page_id = str(page_id).zfill(6)
        
        # Check for special system pages
        if page_id in ['000000', '000002', '000003', '000004']:
            return self.serve_system_page(page_id)
            
        # Check for error pages
        if page_id in ['000403', '000404', '000503']:
            return self.serve_error_page(page_id)
            
        try:
            # For now, serve from filesystem - will be replaced with DB
            page_path = Path(f'pages/{page_id}.xml')
            if not page_path.exists():
                return self.serve_error_page('000404')
                
            with open(page_path) as f:
                return f.read()
        except Exception as e:
            print(f"Error serving page {page_id}: {e}")
            return self.serve_error_page('000503')
            
    def serve_system_page(self, page_id):
        pages = {
            '000000': self.generate_home_page,
            '000002': self.generate_info_page,
            '000003': self.generate_admin_page,
            '000004': self.generate_directory_page
        }
        return pages[page_id]()
        
    def serve_error_page(self, error_code):
        error_pages = {
            '000403': """<?xml version="1.0" charset="UTF-8" ?>
                        <page><body><div align="center" color="red">Access Forbidden</div></body></page>""",
            '000404': """<?xml version="1.0" charset="UTF-8" ?>
                        <page><body><div align="center" color="gray">Page Not Found</div></body></page>""",
            '000503': """<?xml version="1.0" charset="UTF-8" ?>
                        <page><body><div align="center" color="yellow">Page Claimed But Empty</div></body></page>"""
        }
        return error_pages.get(error_code, error_pages['000404'])
        
    def generate_home_page(self):
        return """<?xml version="1.0" charset="UTF-8" ?>
                <page>
                <body>
                <div align="center" color="white" fill="true"></div>
                <drawing align="center"><image>bbb.............d</image></drawing>
                <div align="center" color="gray">Welcome to EnderWeb</div>
                </body>
                </page>"""
                
    def generate_info_page(self):
        return """<?xml version="1.0" charset="UTF-8" ?>
                <page>
                <body>
                <div align="center" color="white">About EnderWeb</div>
                <div align="center" color="gray">A web platform for ComputerCraft</div>
                </body>
                </page>"""
                
    def generate_admin_page(self):
        return """<?xml version="1.0" charset="UTF-8" ?>
                <page>
                <body>
                <div align="center" color="white">Admin Page</div>
                </body>
                </page>"""
                
    def generate_directory_page(self):
        # This will be replaced with dynamic content from DB
        return """<?xml version="1.0" charset="UTF-8" ?>
                <page>
                <body>
                <div align="center" color="white">Site Directory</div>
                <div align="center" color="gray">List of active sites</div>
                </body>
                </page>"""
    
    def run(self, host='0.0.0.0', port=5000):
        self.app.run(host=host, port=port)

if __name__ == '__main__':
    server = EnderWebServer()
    server.run()
