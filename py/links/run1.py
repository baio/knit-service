__author__ = 'baio'

#! /usr/bin/env python

from os import fork, chdir, setsid, umask
from sys import exit
import os
import sys
import time
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from server.server import run
lines = [x.strip() for x in open(".env")]

""""
print "run server with config"
for line in lines:
    spt=line.split("=")
    print spt
    os.environ[spt[0]] = spt[1]

max_attempts = 3
for i in xrange(max_attempts):
    try:
        run()
    except:
        time.sleep(10)
"""""


def main():
  while 1:
    #main daemon process loop    
    print "run server with config"
    for line in lines:
      spt=line.split("=")
      print spt
      os.environ[spt[0]] = spt[1]
    run()

# Dual fork hack to make process run as a daemon
if __name__ == "__main__":
  try:
    pid = fork()
    if pid > 0:
      exit(0)
  except OSError, e:
    exit(1)

  chdir("/")
  setsid()
  umask(0)

  try:
    pid = fork()
    if pid > 0:
      exit(0)
  except OSError, e:
    exit(1)

  main()
