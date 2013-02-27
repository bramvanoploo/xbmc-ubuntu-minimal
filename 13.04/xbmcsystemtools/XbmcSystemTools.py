import System, json, types, urllib
from inspect import stack
from os import path
from flask import Flask, render_template, request, Response, redirect
from werkzeug import secure_filename

app = Flask(__name__)
db = System.Database.Database(System.config.installation_database)

def methodExists(methodName):
    try:
        ret = type(eval(methodName))
        return ret in (types.FunctionType, types.BuiltinFunctionType)
    except AttributeError:
        return False

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/xbmc_backups')
def xbmc_backups():
    return render_template('xbmc_backups.html',
        xbmc_dir_size = System.helper.getReadableSize(System.fileSystem.getDirectorySize(System.config.xbmc_home_dir)),
        backups = System.xbmc.getExistingBackupUrlPaths())

@app.route('/addon_repositories')
def addon_repositories():
    return render_template('addon_repositories.html',
        repositories = System.xbmc.getInstallableRepositories())

@app.route('/system_info')
def system():
    return render_template('system_info.html',
        os                  = System.ubuntu.getVersion(),
        kernel              = System.ubuntu.getKernelVersion(),
        gpu_manufacturer    = System.hardware.getGpuManufacturer(),
        gpu_type            = System.hardware.getGpuType(),
        resolution          = System.hardware.getCurrentResolution(),
        max_resolution      = System.hardware.getMaximumResolution(),
        cpu_type            = System.hardware.getCpuType(),
        cpu_core_count      = System.hardware.getCpuCoreCount(),
        cpu_load            = System.hardware.getCpuLoad(),
        total_ram           = System.hardware.getTotalRam(),
        ram_in_use          = System.hardware.getRamInUse())

@app.route('/prepare_system')
def prepare_system():
    db.set('installation_steps', 'prepare_system', 1)
    return render_template('prepare_system.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/system_tools')
def system_tools():
    return render_template('system_tools.html',)

@app.route('/upload_backup',  methods=['POST'])
def upload_backup():
    backupFile = request.files['backup_file']
    backupFileName = secure_filename(backupFile.filename)
    backupFile.save(path.join(System.config.xbmc_backups_dir, backupFileName))
    return redirect('/xbmc_backups', 301)

@app.route('/api')
def api():
    result = {
        'success' : False,
        'message' : 'Request not executed'
    }

    if 'method' in request.args and methodExists('System.'+request.args['method']):
        fullRequest = None
        if 'params' in request.args and request.args['params'] != '':
            fullRequest = 'System.'+urllib.unquote(request.args['method'])+'(' +urllib.unquote(request.args['params'])+ ')'
        else:
            fullRequest = 'System.'+urllib.unquote(request.args['method'])+'()'

        System.log.debug('request:' +fullRequest, stack()[0][3])

        try:
            data = eval(fullRequest)

            if isinstance(data, bool):
                if not data:
                    result = {
                        'success' : False,
                        'message' : 'An unknown error occurred'
                    }
                else:
                    result = {
                        'success' : True,
                        'result' : True
                    }
            else:
                result = {
                    'success' : True,
                    'result' : data
                }
        except AttributeError as e1:
            System.log.error(str(e1), stack()[0][3])
            result = {
                'success' : False,
                'message' : 'Illegal request: Attribute error (' +str(e1)+ ')'
            }
        except TypeError as e2:
            System.log.error(str(e2), stack()[0][3])
            result = {
                'success' : False,
                'message' : 'Illegal request: Type error (' +str(e2)+ ')'
            }
        except NameError as e3:
            System.log.error(str(e3), stack()[0][3])
            result = {
                'success' : False,
                'message' : 'Illegal Request: Name error (' +str(e3)+ ')'
            }
        except:
            System.log.error('An unknown error occurred', stack()[0][3])
            result = {
                'success' : False,
                'message' : 'An unknown error occurred'
            }

    jsonResult = json.dumps(result)

    System.log.debug('result:' +jsonResult, stack()[0][3])

    response = Response(jsonResult, status=200, mimetype='application/json')
    return response

if __name__ == '__main__':
    app.run(host=System.network.getLocalIpAddress(), port=80, debug=True)
