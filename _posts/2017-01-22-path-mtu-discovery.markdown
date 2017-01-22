---
layout: page
title:  "Path MTU Discovery, or How you broke the Internet."
date:   2017-01-22 13:26:38 -0500
categories: networking problems
---

TL;DR: Don't blindly block all ICMP messages... its more than just ping
guys.

So this might be a bit esoteric, but it's something I've personally been
caught by at least 3 times in a 20+ year career on the Internet. The
symptoms are easy to blame on any number of other things, so it tends
to be the last thing anyone suspects. Let me describe a recent example.

At my day job we built some software to fetch files from a customer via
SFTP and process them. This software happily worked fine in our local test
environments, but when deployed to a live integration testing environment
it failed to complete the file transfer step a small but significant
percentage of the time. Examining network traces of the tcp traffic on
port 22 suggested that the customer's SFTP server had stopped sending
packets in the middle of the session for no good reason. It turns out there
was in fact a perfectly good reason the packets were stopping, and that's
called path MTU discovery, or rather, the failure of path MTU discovery.

For the uninitiated here are a couple of definitions:

    MTU = Maximum Transmission Unit. This is the largest packet that will
    be sent by a specific network interface.

    Path MTU = The MTU for the complete path between any two network interaces.
    The Path MTU is bounded by the smallest MTU of all of the network interfaces
    a packet traverses between its source and destination.

Path MTU discovery is actually a pretty elegant implementation. What happens
in a properly functioning world is this: The sending device starts sending packets
as dictated by the application in use, the maximum size of those packets determined
by the local network interface's MTU. These packets are sent with the don't
fragment (DF) bit set. If any interface in the path has a smaller MTU it would need
to fragment the packet in order to send it further, but since the DF bit is set
it cannot do so, so it replies with the ICMP message Type 3, Code 4: Destination
Unreachable, Fragmentation Needed and Don't Fragment was Set, containing its MTU.
This instructs the sending host to reduce the size of packets it is sending to
accommodate the smaller MTU. The elegance here is that in the vast majority of
cases the MTU doesn't need to be adjusted, so no extra messages are required to
establish the path MTU.

Lesson learned: Don't break the internet by blocking ICMP type 3 messages.


