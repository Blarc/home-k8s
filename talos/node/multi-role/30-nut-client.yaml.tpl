# https://github.com/siderolabs/extensions/tree/main/power/nut-client
apiVersion: v1alpha1
kind: ExtensionServiceConfig
name: nut-client
configFiles:
  - content: |-
      MONITOR {{ .Data.upsmonHost }} 1 {{ .Data.upsmonUser }} {{ .Data.upsmonPass }} secondary
      SHUTDOWNCMD "/sbin/poweroff"
      MINSUPPLIES 1
      HOSTSYNC 15
      DEADTIME 15
      FINALDELAY 0
    mountPath: /usr/local/etc/nut/upsmon.conf
