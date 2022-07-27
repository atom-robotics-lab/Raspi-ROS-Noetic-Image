from ipaddress import ip_address
import psutil
 
 
ip_address = psutil.net_if_addrs()
print('The IP Address is:', ip_address['wlp2s0'][0][1])

print('The CPU usage is: ', psutil.cpu_percent(4))
print('RAM memory % used:', psutil.virtual_memory()[2])
print('The Cpu Frequency is: ',psutil.cpu_freq()[0])
temp=psutil.sensors_temperatures()
print('The CPU Temperature is:',temp['pch_cannonlake'][0][1])
