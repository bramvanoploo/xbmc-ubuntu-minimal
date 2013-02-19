import System
from flask import Flask, render_template

app = Flask(__name__)

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
    System.database.set('installation_steps', 'prepare_system', 1)
    return render_template('prepare_system.html')

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/system_tools')
def system_tools():
    return ""

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
        test_var = System.database.get('installation_steps', 'prepare_system'))

if __name__ == '__main__':
    app.run(host=System.network.getLocalIpAddress(), port=80, debug=True)
