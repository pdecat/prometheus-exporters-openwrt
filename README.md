# init.d files for prometheus exporters on openwrt

Install:

    # rsync -av --progress --exclude=.git --exclude=README.md --chown=root:root ./ openwrt-host:/

Enable:

    # ssh openwrt-host /etc/init.d/prometheus_blackbox_exporter enable
    # ssh openwrt-host /etc/init.d/prometheus_node_exporter enable

For reference:

- https://openwrt.org/docs/techref/initscripts

Note: /var is a symlink to /tmp on target devices