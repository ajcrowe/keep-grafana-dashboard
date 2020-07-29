local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local statPanel = grafana.statPanel;
local gaugePanel = grafana.gaugePanel;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;

{
  grafanaDashboards:: {
    keep_dashboard: dashboard.new(
      'KEEP Node Dashboard',
      tags=['keep', 'blockchain'],
    )
    .addTemplate(
      grafana.template.datasource(
        'PROMETHEUS_DS',
        'prometheus',
        'Prometheus',
        hide='label',
      )
    )
    .addTemplate(
      template.new(
        'node',
        '$PROMETHEUS_DS',
        'label_values(connected_peers_count, job)',
        label='Node',
        refresh='time',
      )
    )
    .addPanel(
      graphPanel.new(
        'Connected Peers',
        decimals='0',
      ).addTarget(
        prometheus.target(
          'connected_peers_count{job="$node"}',
          legendFormat='peers'
        )
      ), gridPos={
        "x": 0,
        "y": 0,
        "h": 8,
        "w": 12
      },
    )
    .addPanel(
      graphPanel.new(
        'Network Activity',
        format='decbytes',
      )
      .addTarget(
        prometheus.target(
          'rate(container_network_receive_bytes_total{pod=~\"$node.*\"}[5m])',
          legendFormat='rx',
        )
      )
      .addTarget(
        prometheus.target(
          'rate(container_network_transmit_bytes_total{pod=~\"$node.*\"}[5m])',
          legendFormat='tx',
        )
      ), gridPos={
        "x": 0,
        "y": 8,
        "h": 8,
        "w": 12
      },
    )
    .addPanel(
      gaugePanel.new(
        'CPU Usage',
        thresholdsMode='percentage',
      )
      .addTarget(
        prometheus.target(
          'rate(container_cpu_usage_seconds_total{container="$node"}[2m])*100',
        )
      )
      .addThresholds([
        {
          color: 'green',
          value: 0,
        },
        {
          color: 'yellow',
          value: 60,
        },
        {
          color: 'red',
          value: 80,
        },
      ]), gridPos={
        "h": 8,
        "w": 6,
        "x": 12,
        "y": 8
      },
    )
    .addPanel(
      statPanel.new(
        'Ethereum Connectivity',
        datasource='Prometheus',
        graphMode='none',
      )
      .addTarget(
        prometheus.target(
          'eth_connectivity{job="$node"}',
        )
      )
      .addMappings([
        {
          type: 1,
          text: 'Up',
          value: '1'
        },
        {
          type: 1,
          text: 'Down',
          value: '0'
        }
      ]), gridPos={
        "x": 12,
        "y": 0,
        "w": 6,
        "h": 4
      },
    )
    .addPanel(
      statPanel.new(
        'Container Status',
        datasource='Prometheus',
        graphMode='none',
      )
      .addTarget(
        prometheus.target(
          'kube_pod_container_status_ready{container="$node"}',
        )
      )
      .addMappings([
        {
          type: 1,
          text: 'Up',
          value: '1'
        },
        {
          type: 1,
          text: 'Down',
          value: '0'
        }
      ]), gridPos={
        "x": 12,
        "y": 4,
        "w": 6,
        "h": 4
      },
    )
    .addPanel(
      statPanel.new(
        'Bootstrap Peers',
        datasource='Prometheus',
        graphMode='none',
      )
      .addTarget(
        prometheus.target(
          'connected_bootstrap_count{job="$node"}',
        )
      )
      .addMappings([
        {
          type: 1,
          text: 'Up',
          value: '1'
        },
        {
          type: 1,
          text: 'Down',
          value: '0'
        }
      ]), gridPos={
        "x": 18,
        "y": 0,
        "w": 6,
        "h": 4
      },
    )
    .addPanel(
      statPanel.new(
        'Uptime',
        datasource='Prometheus',
        graphMode='none',
        unit='s',
      )
      .addTarget(
        prometheus.target(
          'time() - container_start_time_seconds{container="$node"}'
        )
      ), gridPos={
        "x": 18,
        "y": 4,
        "w": 6,
        "h": 4
      },
    )
    .addPanel(
      statPanel.new(
        'Memory Use',
        datasource='Prometheus',
        unit='decbytes',
      )
      .addTarget(
        prometheus.target(
          'container_memory_rss{container="$node"}',
        )
      ), gridPos={
        "x": 18,
        "y": 8,
        "w": 6,
        "h": 8
      },
    )
  }
}