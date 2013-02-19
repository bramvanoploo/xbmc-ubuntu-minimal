import System, json, types
from flask import Flask, render_template, request, Response

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

@app.route('/system')
def system():
    return render_template('system.ajax.html',
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
    return render_template('system_tools.html')

@app.route('/footer')
def footer():
    return render_template('footer.ajax.html',
        os          = System.ubuntu.getVersion(),
        cpu_load    = System.hardware.getCpuLoad(),
        total_ram   = System.hardware.getTotalRam(),
        ram_in_use  = System.hardware.getRamInUse())

@app.route('/system_console')
def system_console():
    return render_template('console.ajax.html',
        test_var = db.get('installation_steps', 'prepare_system'))

@app.route('/api')
def api():
    result = {
        'success' : False,
        'message' : 'Illegal request'
    }

    if 'method' in request.args and methodExists('System.'+request.args['method']):
        fullRequest = None
        if 'params' in request.args and request.args['params'] != '{}':
            fullRequest = 'System.'+request.args['method']+'(' +request.args['params']+ ')'
        else:
            fullRequest = 'System.'+request.args['method']+'()'

        try:
            data = eval(fullRequest)
            result = {
                'success'   : True,
                'result'    : str(data)
            }
        except AttributeError:
            result = {
                'success' : False,
                'message' : 'Illegal request: Attribute error'
            }
        except TypeError as e:
            result = {
                'success' : False,
                'message' : 'Illegal request: Type error'
            }

    jsonResult = json.dumps(result)
    response = Response(jsonResult, status=200, mimetype='application/json')
    return response

if __name__ == '__main__':
    app.run(host=System.network.getLocalIpAddress(), port=80, debug=True)
