import subprocess, logging

def run(command):
    p = subprocess.Popen(command,
        shell=True,
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        close_fds=True)
    result, error = p.communicate()

    #s = result[0].split()[2]
    return result
