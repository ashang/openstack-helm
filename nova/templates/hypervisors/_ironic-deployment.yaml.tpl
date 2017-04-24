{{- define "ironic_hypervisor" }}
{{- $hypervisor := index . 1 }}
{{- with index . 0 }}
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: nova-compute-ironic
  labels:
    system: openstack
    type: backend
    component: nova
spec:
  replicas: 1
  revisionHistoryLimit: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 3
  selector:
    matchLabels:
        name: nova-compute-ironic
  template:
    metadata:
      labels:
        name: nova-compute-ironic
      annotations:
        pod.beta.kubernetes.io/hostname: nova-compute-ironic
    spec:
      containers:
        - name: nova-compute-ironic
          image: {{.Values.global.image_repository}}/{{.Values.global.image_namespace}}/ubuntu-source-nova-compute-m3:{{.Values.image_version_nova_compute_m3}}
          imagePullPolicy: IfNotPresent
          securityContext:
            privileged: true
          command:
            - /container.init/nova-compute-start
          env:
            - name: DEBUG_CONTAINER
              value: "false"
            - name: SENTRY_DSN
              value: {{.Values.sentry_dsn | quote}}
          volumeMounts:
            - mountPath: /hypervisor-config
              name: hypervisor-config
            - mountPath: /nova-etc
              name: nova-etc
            - mountPath: /nova-patches
              name: nova-patches
            - mountPath: /container.init
              name: container-init
      volumes:
        - name: nova-etc
          configMap:
            name: nova-etc
        - name: nova-patches
          configMap:
            name: nova-patches
        - name: hypervisor-config
          configMap:
            name:  hypervisor-{{$hypervisor.name}}
        - name: container-init
          configMap:
            name: nova-bin
            defaultMode: 0755
{{- end }}
{{- end }}