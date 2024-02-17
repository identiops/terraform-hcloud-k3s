#!/usr/bin/env nu
# Auto-generated file: don't modify!
# Dynamically retrieve servers with the control-plane label.
# Copyright 2024, identinet GmbH. All rights reserved.
# SPDX-License-Identifier: MIT

let API = "https://api.hetzner.cloud/v1/servers"
let CFG = "/etc/haproxy/haproxy.d/k8s.cfg"
let TOKEN = "${token}"
let HOST = "${host}"
let PORT = "${port}"

http get --headers ["Authorization" $"Bearer ($TOKEN)"] $API | $in.servers |
  each {|server|
    # Documentation: http://docs.haproxy.org/
    if ($server.labels | default "false" "control-plane" | get control-plane) == "true" {
        $"option ssl-hello-chk\n  server ($server.name) ($server.private_net.0.ip):6443 maxconn 64 check inter 2000 rise 2 fall 5"
    }
  } | str join "\n  " | $"listen k8s\n  mode tcp\n  bind ($HOST):($PORT)\n  ($in)\n" | save -f $CFG

systemctl reload haproxy
