import subprocess

def run(cmd):
    p = subprocess.Popen(cmd,
        shell=True, 
        stdin=subprocess.PIPE, 
        stdout=subprocess.PIPE, 
        stderr=subprocess.PIPE, 
        close_fds=True)
    result = p.stdout.readlines()
    #s = result[0].split()[2]
    return result[0]
