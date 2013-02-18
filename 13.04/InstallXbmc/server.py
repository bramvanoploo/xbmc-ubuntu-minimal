import systemHelper
from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')
    
@app.route('/system')
def system():
    return render_template('system.ajax.html', 
        os=systemHelper.getUbuntuVersion(), 
        kernel=systemHelper.getKernelVersion(),
        gpu_manufacturer=systemHelper.getGpuManufacturer(),
        gpu_type=systemHelper.getGpuType(),
        resolution=systemHelper.getCurrentResolution(), 
        max_resolution=systemHelper.getMaximumResolution(),
        cpu_type=systemHelper.getCpuType(),
        cpu_core_count=systemHelper.getCpuCoreCount(),
        total_ram=systemHelper.getTotalRam(),
        free_ram=systemHelper.getFreeRam())
    
@app.route('/about')
def about():
    return render_template('about.html')
    
@app.route('/update')
def update():
    
    return 0
    
@app.route('/system_console')
def system_console():
    return render_template('console.ajax.html')

if __name__ == '__main__':
    app.run(host=systemHelper.getLocalIpAddress(), port=80, debug=True)
