#/usr/bin/python3

from random import *
import time

list = ["~/OneDrive/", "2345", "rrshtjdtoliu", "134265375475865"]
random.seed(50)
while True:
    print(str(random.choise(list))*random.int(1,11))
    time.sleep(1)
