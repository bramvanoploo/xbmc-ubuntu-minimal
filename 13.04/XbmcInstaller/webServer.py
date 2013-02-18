from bottle import route, static_file, run
from jinja2 import Template, Environment, PackageLoader
import system

env = Environment(loader=PackageLoader('XbmcInstaller', 'templates'))

@route('/')
@route('/index')
def index():
    template = env.get_template('index.html')
    print template.render()

@route('/repositories')
def repositories():
    return "Install repositories"
    
@route('/video_drivers/<name>')
def videoDrivers(name):
    return "Install " +name+ " drivers"
    
@route('/<filename:path>')
def send_webroot(filename):
    return static_file(filename, root='web')
    
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
