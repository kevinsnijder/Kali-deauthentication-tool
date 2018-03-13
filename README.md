# Kali-deauthentication-tool
An easy way to kick people off a network

This is a short script to deauthenticate people from a specific Access Point.
You can target the entire network and optionally you can target a specific device on that network.

This tool is meant to be used with the following command running in a different window:
airodump-ng -c (CHANNEL FROM AP) -w (OUTPUT-FILENAME) --bssid (MAC FROM AP) (MONITORING DEVICE)

This tool is meant for educational purposes only, only use this on your own network or a network where you have explicit permission to do so.
