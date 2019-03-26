#!/usr/bin/python
# -*- coding: iso-8859-15 -*-

from flask import Flask, jsonify, abort, make_response, request
import subprocess

app = Flask(__name__)

@app.route('/')
def index():
  txt = "VirtualBox Manager WebService\n"
  txt += "-----------------------------------------\n"
  txt += "curl -i http://localhost:5000/\n"
  txt += "curl -i http://localhost:5000/vms/ostypes\n"
  txt += "curl -i http://localhost:5000/vms/ostypes/families\n"
  txt += "curl -i http://localhost:5000/vms/ostypes/families/<name>\n"
  txt += "curl -i http://localhost:5000/vms\n"
  txt += "curl -i http://localhost:5000/vms/running\n"
  txt += "curl -i http://localhost:5000/info/<name>\n"
  txt += "curl -i -X POST -H 'Content-Type: application/json' -d '{name:<str>, ostype:<str>"
  txt += ", space:<int>, ram:<int>, cpus:<int>}' http://localhost:5000/vms/create\n"
  txt += "curl -i -X PUT -H 'Content-Type: application/json' -d "
  txt += "'[{number:<int>, type:<str>}]' http://localhost:5000/vms/NICs/<name>\n"
  txt += "curl -i -X DELETE http://localhost:5000/vms/delete/<name>\n"
  txt += "curl -i -X PUT http://localhost:5000/vms/star/<name>\n"
  txt += "curl -i -X PUT http://localhost:5000/vms/stop/<name>\n"
  return txt


@app.route('/nodo/<name>', methods = ['GET'])
def ostypes_familie(name):
  
  
  names = _prcsshell("grep 'ID:' | cut -d ':' -f2 | sed 's/^[[:space:]]*//'", cmd_1).split("\n")
  descriptions = _prcsshell("grep 'tion:' | cut -d ':' -f2 | sed 's/^[[:space:]]*//'", cmd_2).split("\n")
  oslist = []
  for i in range(0,len(names)-1):
    oslist.append({'Name':names[i], 'Description':descriptions[i]})
  return jsonify({'ostypes':oslist})


@app.errorhandler(404)
def not_found(error):
  return make_response(jsonify({'error': 'Not found'}), 404)

@app.errorhandler(400)
def not_found(error):
  return make_response(jsonify({'error': 'Bad Request'}), 400)

def prcsshell(cmd):
  return subprocess.check_output(cmd, shell=True)
def _prcsshell(cmd, std):
  return subprocess.check_output(cmd, stdin=std.stdout, shell=True)
def prcspopen(cmd):
  return subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True)

if __name__ == '__main__':
  app.run(debug = True, host='0.0.0.0')
