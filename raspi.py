import subprocess
s,r = subprocess.getstatusoutput(f'cat /sys/class/thermal/thermal_zone*/type')
x=r.split("\n")
d,t=subprocess.getstatusoutput(f'cat /sys/class/thermal/thermal_zone*/temp')
y=t.split("\n")
dic={}
for i in range(0,len(x)):
    dic[x[i]] = y[i]

print(f'The Cpu temperature is: {int(dic["x86_pkg_temp"])/1000}' + "°C")


# print("{}".format(str(t)))
a,b=subprocess.getstatusoutput("hostname -I | awk '{print $1}'")
f,g=subprocess.getstatusoutput("cat /proc/cpuinfo | grep MHz")
z,y=subprocess.getstatusoutput("free")
print("Memory Usage",y)
print("The IP Address is:", b)
print("Cpu Frequency\n", g)
# print(subprocess.getstatusoutput(f'cat /sys/class/thermal/thermal_zone*/type'))
# print(r.length())
