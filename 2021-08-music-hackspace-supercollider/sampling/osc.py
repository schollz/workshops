import time

# pip install python-osc
from pythonosc import udp_client

client = udp_client.SimpleUDPClient("127.0.0.1", 57120)
client.send_message("/hello",3.5)
time.sleep(1)
client.send_message("/hello",0)
