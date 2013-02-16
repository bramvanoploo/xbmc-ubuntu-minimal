from bottle import route, static_file, run
from jinja2 import Template
import system

@route('/')
def index():
    return '''
        <html>
            <head>
                <title>
                    XBMC Minimal installation script version 3.0.0
                </title>
                <script type="text/javascript" src="/javascript/jquery-1.9.1.min.js"></script>
                <script type="text/javascript" src="/javascript/application.js"></script>
                <link rel="stylesheet" type="text/css" href="/css/main.css" />
            </head>
            <body>
                <div id="main_container">
                    tester
                </div>
            </body>
        </html>
    '''

@route('/repositories')
def repositories():
    return "Install repositories"
    
@route('/video_drivers/<name>')
def videoDrivers(name):
    return "Install " +name+ " drivers"
    
@route('/javascript/<filename:path>')
def send_javascript(filename):
    return static_file(filename, root='web/javascript')
    
@route('/images/<filename:re:.*\.png>>')
def send_png(filename):
    return static_file(filename, root='web/images', mimetype='image/png')
    
@route('/images/<filename:re:.*\.jpg>>')
def send_jpeg(filename):
    return static_file(filename, root='web/images', mimetype='image/jpeg')
    
@route('/images/<filename:re:.*\.gif>>')
def send_gif(filename):
    return static_file(filename, root='web/images', mimetype='image/gif')
    
@route('/css/<filename:path>')
def send_css(filename):
    return static_file(filename, root='web/css')

run(host=system.getIpAddress(), port=80, reloader=True)
