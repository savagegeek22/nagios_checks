#!/usr/bin/python

# Copyright (c) 2023 JD Henderson <jdh@savagegeek.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

import argparse
import urllib.request

# This change for -> import urllib.request is due to python3 and not using urllib2 any longer
# import urllib2
import json

VERSION = "0.0.1"

CONFIG = {
    "avatar": "https://raw.githubusercontent.com/andrefreitas/rocketchat-nagios/master/images/nagios_128.png", #noqa
    "alias": "Nagios",
    "colors": {
        "OK": "#36a64f",
        "CRITICAL": "#d00000",
        "WARNING": "#daa038",
        "UNKNOWN": "#e3e4e6",
        "DOWN": "#d00000",
        "UP": "#40b207",
        "UNKNOWN": "#e3e4e6",
        "UNREACHABLE": "#e3e4e6"
    }
}

TEMPLATE_SERVICE = "{hostalias} {servicedesc} is {servicestate}:\n{serviceoutput}" #noqa
TEMPLATE_HOST = "Host {hostalias} is {hoststate}:\n{hostoutput}"  #noqa

def parse():
    parser = argparse.ArgumentParser(description='Sends Rocket.Chat webhooks')
    parser.add_argument('--url', help='Webhook URL', required=True)
    parser.add_argument('--proxy', help='http(s) proxy')
    parser.add_argument('--channel', help='Rocket.Chat channel')
    parser.add_argument('--hostalias', help='Host Alias', required=True)
    parser.add_argument('--nagiosurl', help='Nagios URL. Eg : https://nagios.example.com:8888')
    parser.add_argument('--hoststate', help='Host State')
    parser.add_argument('--hostoutput', help='Host Output')
    parser.add_argument('--servicedesc', help='Service Description')
    parser.add_argument('--servicestate', help='Service State')
    parser.add_argument('--serviceoutput', help='Service Output')
    parser.add_argument('--version', action='version',
                        version='%(prog)s {version}'.format(version=VERSION))
    args = parser.parse_args()
    return args


def encode_special_characters(text):
    text = text.replace("%", "%25")
    text = text.replace("&", "%26")
    return text


def render_template(template, args):
    text = template.format(**vars(args))
    return encode_special_characters(text)


def create_data(args, config):
    text = render_template(
        TEMPLATE_SERVICE if args.servicestate else TEMPLATE_HOST,
        args
    )
    state = args.servicestate if args.servicestate else args.hoststate
##    color = config["colors"][state]
    color = config["colors"]


    payload = {
        "alias": config["alias"],
        "avatar": config["avatar"],
        "text": text.split('\n')[0],
        "attachments": [
            {
                "text": text.split("\n",1)[1],
                "color": color
            }
        ]
    }
    if args.channel:
        payload["channel"] = args.channel

# Trying this out

    data = json.dumps
#   data = "payload=" + json.dumps
#   data = "payload=" + json.dumps(payload)
#   data = "payload=" json.dumps(payload)

#    return data  json.dumps(payload)
    return data(payload)

# Trying this out


def request(url, data, args):
    if args.proxy:

        proxy = urllib.request.ProxyHandler({'http': args.proxy, 'https': args.proxy})
        opener = urllib.request.build_opener(proxy)
        urllib.request.install_opener(opener)
    req = urllib.request.Request(url, data.encode('utf-8'))  # encode the data to bytes
    response = urllib.request.urlopen(req)



    return response.read().decode('utf-8') # Decode the response to string


if __name__ == "__main__":
    args = parse()
    if args.nagiosurl:
        if args.servicestate:
            TEMPLATE_SERVICE += "\nSee {nagiosurl}/nagios/cgi-bin/extinfo.cgi?type=2&host={hostalias}&service={servicedesc}"
#         elif args.hoststate:
            TEMPLATE_HOST += "\nSee {nagiosurl}/nagios/cgi-bin/extinfo.cgi?type=1&host={hostalias}"

    data = create_data(args, CONFIG)
    response = request(args.url, data, args)
#    print(response)

#   ------
#   Trying out what Martin Friedrich helped me out with
    json_data = json.dumps(data)
#    json_loads = json.loads(json_data)
#    json_loads = json.loads(json_data.replace("\"", "'"))
#    print(json_loads)
    print(response)
    print(json_data)

   # json_data = json.dumps(data)
   # print(json_data)



