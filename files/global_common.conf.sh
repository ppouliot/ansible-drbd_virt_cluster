#!/usr/bin/env bash
cat << EOF > /etc/drbd.d/global_common.conf
global {
	usage-count no;
}

common {
        protocol C;

	handlers {
		pri-on-incon-degr "/usr/lib/drbd/notify-pri-on-incon-degr.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
		pri-lost-after-sb "/usr/lib/drbd/notify-pri-lost-after-sb.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
		local-io-error "/usr/lib/drbd/notify-io-error.sh; /usr/lib/drbd/notify-emergency-shutdown.sh; echo o > /proc/sysrq-trigger ; halt -f";
	}

	startup {
		wfc-timeout 1;
                degr-wfc-timeout 1;
                become-primary-on both;
	}

	options {
	}

	disk {
		on-io-error	detach;
        	no-disk-flushes;
        	no-disk-barrier;
                c-plan-ahead    15;
		c-fill-target 24M;
                c-max-rate   720M;
                c-min-rate     80M;
	}

	net {
	        # max-epoch-size          20000;
	        max-buffers             36k;
	        sndbuf-size            1024k ;
	        rcvbuf-size            2048k;
		allow-two-primaries ;
                after-sb-0pri discard-zero-changes;
		after-sb-1pri discard-secondary;
                after-sb-2pri disconnect;
	}
        syncer {
        }
}
EOF
