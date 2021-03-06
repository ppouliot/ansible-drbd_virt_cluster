#!/usr/bin/env bash
cat << EOF > /etc/drbd.d/global_common.conf
# DRBD is the result of over a decade of development by LINBIT.
# In case you need professional services for DRBD or have
# feature requests visit http://www.linbit.com

global {
        usage-count yes;

        # Decide what kind of udev symlinks you want for "implicit" volumes
        # (those without explicit volume <vnr> {} block, implied vnr=0):
        # /dev/drbd/by-resource/<resource>/<vnr>   (explicit volumes)
        # /dev/drbd/by-resource/<resource>         (default for implict)
        udev-always-use-vnr; # treat implicit the same as explicit volumes

        # minor-count dialog-refresh disable-ip-verification
        # cmd-timeout-short 5; cmd-timeout-medium 121; cmd-timeout-long 600;
}
common {
        disk {
                # size
		on-io-error detach ;
		disk-barrier no;
		disk-flushes no;
                # disk-drain
		# md-flushes
		resync-rate 33M;
		#resync-after 
		al-extents 6007;
                c-plan-ahead 15;
		# c-delay-target
		c-fill-target 24M;
		c-max-rate 1000M;
                c-min-rate 10M;
		# disk-timeout
        }

        handlers {
                # These are EXAMPLE handlers only.
                # They may have severe implications,
                # like hard resetting the node under certain circumstances.
                # Be careful when choosing your poison.

                pri-on-incon-degr "/usr/lib/drbd/notify-pri-on-incon-degr.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
                pri-lost-after-sb "/usr/lib/drbd/notify-pri-lost-after-sb.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
                local-io-error "/usr/lib/drbd/notify-io-error.sh; /usr/lib/drbd/notify-emergency-shutdown.sh; echo o > /proc/sysrq-trigger ; halt -f";
                fence-peer "/usr/lib/drbd/crm-fence-peer.sh";
                # split-brain "/usr/lib/drbd/notify-split-brain.sh root";
                # out-of-sync "/usr/lib/drbd/notify-out-of-sync.sh root";
                # before-resync-target "/usr/lib/drbd/snapshot-resync-target-lvm.sh -p 15 -- -c 16k";
                after-resync-target /usr/lib/drbd/unsnapshot-resync-target-lvm.sh;
                # quorum-lost "/usr/lib/drbd/notify-quorum-lost.sh root";
        }

	net {
		fencing resource-and-stonith;
		protocol C;
		#timeout
		max-epoch-size 8000;
		max-buffers 8000;
		# connect-int
		# ping-int
		sndbuf-size 0;
		# rcvbuf-size
		# ko-count
		allow-two-primaries yes;
		# cram-hmac-alg
		# shared-secret
		after-sb-0pri discard-zero-changes;
		after-sb-1pri discard-secondary;
		after-sb-2pri disconnect;
		# always-asbp rr-conflict
		# ping-timeout data-integrity-alg tcp-cork on-congestion
		# congestion-fill congestion-extents csums-alg
		# verify-alg crc32c;
		# use-rle
	}

        options {
                # cpu-mask on-no-data-accessible
		auto-promote yes;
                # RECOMMENDED for three or more storage nodes with DRBD 9:
                # quorum majority;
                # on-no-quorum suspend-io | io-error;
        }

        startup {
                # wfc-timeout degr-wfc-timeout outdated-wfc-timeout wait-after-sb
                become-primary-on both;
        }
}
EOF
