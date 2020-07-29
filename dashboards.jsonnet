local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local singlestat = grafana.statPanel;
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
      singlestat.new(
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
      singlestat.new(
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
      singlestat.new(
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
        "h": 8
      },
    )
    .addPanel(
      singlestat.new(
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
        "y": 0,
        "w": 6,
        "h": 8
      },
    )
  }
}