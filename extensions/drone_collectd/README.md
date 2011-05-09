## What is this

It is an output interface to collectd for Drone.<br/>
You can find more about Drone [here](https://github.com/schmurfy/drone)

# Supported Runtimes

- MRI 1.8.7+
- Rubinius 1.2.2+


# How to use

First you obviously need a collectd server (or any server able to receive collectd network packets),
after that you need to add those lines to your types.db config file if you use collectd:

    meter         mean:GAUGE:U:U, rate1:GAUGE:U:U, rate5:GAUGE:U:U, rate15:GAUGE:U:U
    timer         min:GAUGE:0:U,  max:GAUGE:0:U,  mean:GAUGE:0:U, stddev:GAUGE:U:U, median:GAUGE:0:U, p75:GAUGE:0:U, p95:GAUGE:0:U

They are required to be able to understand timers and meters sent from Drone, you can update the timer
as you wish to add/remove pecentiles (check examples/collectd to see how to configure the interface for that).



