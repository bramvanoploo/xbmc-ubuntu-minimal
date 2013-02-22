import subprocess, logging, datetime

def run(command, returnBool = False):
    shellErrorLog = open("shell_error.log", "a")
    shellLog = open("shell_output.log", "a")
    now = datetime.datetime.now()
    process = subprocess.Popen(command,
                shell=True,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                close_fds=True)
    output, error = process.communicate()

    if error:
        errorOutput = now.strftime("%Y-%m-%d %H:%M:%S")+ ' COMMAND: "' +command+ '"\n' +now.strftime("%Y-%m-%d %H:%M:%S")+ ' ERROR: ' +error+ '\n\n'
        shellErrorLog.write(errorOutput)
        shellErrorLog.close()
        if returnBool:
            return False
        else:
            return error

    #    successOutput = now.strftime("%Y-%m-%d %H:%M:%S")+ ' COMMAND: "' +command+ '"\n' +now.strftime("%Y-%m-%d %H:%M:%S")+ ' RESULT: ' +output+ '\n\n'
    #    shellLog.write(successOutput)
    #    shellLog.close()

    if returnBool:
        return True
    else:
        return output


