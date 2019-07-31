<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Track_Web.Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
AltoTrack Platform 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <script src="Scripts/TopMenu.js" type="text/javascript"></script>

<script type="text/javascript">

Ext.onReady(function () {

    Ext.QuickTips.init();
    Ext.Ajax.timeout = 600000;
    Ext.override(Ext.form.Basic, { timeout: Ext.Ajax.timeout / 1000 });
    Ext.override(Ext.data.proxy.Server, { timeout: Ext.Ajax.timeout });
    Ext.override(Ext.data.Connection, { timeout: Ext.Ajax.timeout });

    var storeGraphViajes = new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['EstadoIntegracion', 'Cantidad'],
        proxy: new Ext.data.HttpProxy({
            url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetIntegracionDashboard',
            reader: { type: 'json', root: 'Zonas' },
            headers: {
                'Content-type': 'application/json'
            }
        })
    });

    var graphViajes = new Ext.chart.Chart({
        id: 'graphViajes',
        animate: true,
        shadow: true,
        store: storeGraphViajes,
        queryMode: 'local',
        legend: {
            position: 'right'
        },

        insetPadding: 40,
        theme: 'Base:gradients',
        series: [{
            type: 'pie',
            field: 'Cantidad',
            showInLegend: true,
            donut: 40,
            tips: {
                trackMouse: true,
                width: 150,
                height: 30,
                renderer: function (storeItem, item) {
                    //calculate percentage.
                    var total = 0;
                    storeGraphViajes.each(function (rec) {
                        total += rec.get('Cantidad');
                    });
                    this.setTitle(storeItem.get('EstadoIntegracion') + ': ' + storeItem.get('Cantidad') + ' (' + Math.round(storeItem.get('Cantidad') / total * 100) + '%)');
                }
            },
            highlight: {
                segment: {
                    margin: 10
                }
            },
            label: {
                field: 'EstadoIntegracion',
                //display: 'Cantidad',
                contrast: true,
                font: '10px Arial'
            }
            /*renderer: function (sprite, record, attr, index, store) {
                var motivo = (record.get('EstadoIntegracion'));
                var value = 0;
                switch (motivo) {
                    case "No integrados":
                        value = 0;
                        break;
                    case "Integrados":
                        value = 1;
                        break;
                    default:
                        value = 0;
                }

                var color = ["#dbdbdb", "#009bff"][value];
                return Ext.apply(attr, {
                    fill: color
                });
            }*/
        }]
    });

    var panGraphViajes = new Ext.FormPanel({
        id: 'panGraphViajes',
        anchor: '100% 100%',
        title: 'Viajes recibidos (ETIS - EPORTIS): ',
        //renderTo: Ext.getBody()
        layout: 'fit',
        flex: 1,
        items: [graphViajes]
    });

    storeGraphViajes.load({
        callback: function (r, options, success) {
            if (success) {
                var total = 0;
                storeGraphViajes.each(function (rec) {
                    total += rec.get('Cantidad');
                });

                panGraphViajes.setTitle("Viajes recibidos (ETIS - EPORTIS): " + total);

            }
        }
    })

    var storeGraphAlertas = new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['TipoAlerta', 'Cantidad'],
        proxy: new Ext.data.HttpProxy({
            url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetAlertasDashboard',
            reader: { type: 'json', root: 'Zonas' },
            headers: {
                'Content-type': 'application/json'
            }
        })
    });

    var graphAlertas = new Ext.chart.Chart({
        id: 'graphAlertas',
        animate: true,
        shadow: true,
        store: storeGraphAlertas,
        queryMode: 'local',
        legend: {
            position: 'right'
        },

        insetPadding: 40,
        theme: 'Base:gradients',
        series: [{
            type: 'pie',
            field: 'Cantidad',
            showInLegend: true,
            donut: 40,
            tips: {
                trackMouse: true,
                width: 150,
                height: 30,
                renderer: function (storeItem, item) {
                    //calculate percentage.
                    var total = 0;
                    storeGraphAlertas.each(function (rec) {
                        total += rec.get('Cantidad');
                    });
                    this.setTitle(storeItem.get('TipoAlerta') + ': ' + storeItem.get('Cantidad') + ' (' + Math.round(storeItem.get('Cantidad') / total * 100) + '%)');
                }
            },
            highlight: {
                segment: {
                    margin: 10
                }
            },
            label: {
                field: 'TipoAlerta',
                //display: 'Cantidad',
                contrast: true,
                font: '10px Arial'
            }
        }]
    });

    var panGraphAlertas = new Ext.FormPanel({
        id: 'panGraphAlertas',
        anchor: '100% 100%',
        title: 'Alertas generadas:',
        //renderTo: Ext.getBody()
        layout: 'fit',
        flex: 1,
        items: [graphAlertas]
    });

    storeGraphAlertas.load({
        callback: function (r, options, success) {
            if (success) {
                var total = 0;
                storeGraphAlertas.each(function (rec) {
                    total += rec.get('Cantidad');
                });

                panGraphAlertas.setTitle("Alertas generadas: " + total);

            }
        }
    })

    var storeGraphMotivosNoIntegracion = new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['MotivoNoIntegracion', 'Cantidad'],
        proxy: new Ext.data.HttpProxy({
            url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetMotivosDashboard',
            reader: { type: 'json', root: 'Zonas' },
            headers: {
                'Content-type': 'application/json'
            }
        })
    });

    var graphMotivosNoIntegracion = new Ext.chart.Chart({
        id: 'graphMotivosNoIntegracion',
        animate: true,
        shadow: true,
        store: storeGraphMotivosNoIntegracion,
        queryMode: 'local',
        legend: {
            position: 'right'
        },

        insetPadding: 35,
        theme: 'Base:gradients',
        series: [{
            type: 'pie',
            field: 'Cantidad',
            showInLegend: true,
            donut: 40,
            tips: {
                trackMouse: true,
                width: 190,
                height: 30,
                renderer: function (storeItem, item) {
                    //calculate percentage.
                    var total = 0;
                    storeGraphMotivosNoIntegracion.each(function (rec) {
                        total += rec.get('Cantidad');
                    });
                    this.setTitle(storeItem.get('MotivoNoIntegracion') + ': ' + storeItem.get('Cantidad') + ' (' + Math.round(storeItem.get('Cantidad') / total * 100) + '%)');
                }
            },
            highlight: {
                segment: {
                    margin: 10
                }
            },
            label: {
                field: 'MotivoNoIntegracion',
                //display: 'Cantidad',
                contrast: true,
                font: '10px Arial'
            }
        }]
    });

    var panGraphMotivoNoIntegracion = new Ext.FormPanel({
        id: 'panGraphMotivoNoIntegracion',
        anchor: '100% 100%',
        title: 'Motivos de no integración',
        layout: 'fit',
        flex: 1,
        items: [graphMotivosNoIntegracion]
    });

    storeGraphMotivosNoIntegracion.load({
        callback: function (r, options, success) {
            if (success) {
                var total = 0;
                storeGraphMotivosNoIntegracion.each(function (rec) {
                    total += rec.get('Cantidad');
                });

            }
        }
    })

    var storeGraphTendenciaIntegracion = new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['Fecha',
                'ViajesRecibidos',
                'ViajesIntegrados',
                'PorcientoIntegracion'],
            proxy: new Ext.data.HttpProxy({
            url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetTendenciaIntegracionDashboard',
            reader: { type: 'json', root: 'Zonas' },
            headers: {
                'Content-type': 'application/json'
            }
        })
    });

    var graphTendenciaIntegracion = new Ext.chart.Chart({
        id: 'graphTendenciaIntegracion',
        animate: true,
        shadow: true,
        store: storeGraphTendenciaIntegracion,
        /*legend: {
            position: 'right'
        },*/
        gradients: [{
            angle: 90,
            id: 'bar-gradient',
            stops: {
                0: {
                    color: '#99BBE8'
                },
                70: {
                    color: '#77AECE'
                },
                100: {
                    color: '#77AECE'
                }
            }
        }],
        axes: [{
            type: 'Numeric',
            minimum: 0,
            //maximum: 100,
            position: 'left',
            fields: ['ViajesRecibidos'],
            title: true,
            grid: true,
            label: {
                renderer: Ext.util.Format.numberRenderer('0,0'),
                font: '9px Arial',

            },
            roundToDecimal: false
        }, {
            type: 'Category',
            position: 'bottom',
            fields: ['Fecha'],
            title: ['ViajesRecibidos'],
            grid: true
            /*label: {
                font: '9px Arial',
                renderer: function (name) {
                    return name.substr(0, 3);
                }
            }*/
        }],
        series: [{
            type: 'column',
            axis: 'left',
            //highlight: true,
            xField: 'Fecha',
            yField: ['ViajesRecibidos'],
            style: {
                fill: 'url(#bar-gradient)',
                'stroke-width': 3
            },
            markerConfig: {
                type: 'circle',
                size: 4,
                radius: 4,
                'stroke-width': 0,
                fill: '#38B8BF',
                stroke: '#38B8BF'
            },
            tips: {
                trackMouse: true,
                width: 160,
                height: 30,
                renderer: function (storeItem, item) {
                    this.setTitle('Viajes recibidos: ' + storeItem.get('ViajesRecibidos'));
                }
            },
        }, {
            type: 'line',
            axis: 'left',
            xField: 'Fecha',
            yField: 'ViajesIntegrados',
            tips: {
                trackMouse: true,
                width: 160,
                height: 30,
                renderer: function (storeItem, item) {
                    this.setTitle('Viajes integrados: ' + storeItem.get('ViajesIntegrados') + ' (' + +storeItem.get('PorcientoIntegracion') + '%)');
                }
            },
            style: {
                fill: '#18428E',
                stroke: '#18428E',
                'stroke-width': 3
            },
            markerConfig: {
                type: 'circle',
                size: 4,
                radius: 4,
                'stroke-width': 0,
                fill: '#18428E',
                stroke: '#18428E'
            }


        }]
    });

    var panGraphTendenciaIntegracion = new Ext.FormPanel({
        id: 'panGraphTendenciaIntegracion',
        anchor: '100% 100%',
        title: 'Integración últimos 10 días.',
        //renderTo: Ext.getBody(),
        layout: 'fit',
        flex: 1,
        items: [graphTendenciaIntegracion]
    });

    storeGraphTendenciaIntegracion.load({
        callback: function (r, options, success) {
        }
    })

    var storeGraphTendenciaAlertas = new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['Fecha',
                'Detencion',
                'PerdidaSeñal',
                'Total'],
        proxy: new Ext.data.HttpProxy({
            url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetTendenciaAlertasDashboard',
            reader: { type: 'json', root: 'Zonas' },
            headers: {
                'Content-type': 'application/json'
            }
        })
    });

    var graphTendenciaAlertas = new Ext.chart.Chart({
        id: 'graphTendenciaAlertas',
        animate: true,
        shadow: true,
        store: storeGraphTendenciaAlertas,
        legend: {
            position: 'right'
        },
        axes: [{
            type: 'Numeric',
            minimum: 0,
            //maximum: 100,
            position: 'left',
            fields: ['Detencion', 'PerdidaSeñal'],
            title: true,
            grid: true,
            label: {
                renderer: Ext.util.Format.numberRenderer('0,0'),
                font: '9px Arial',

            },
            roundToDecimal: false
        }, {
            type: 'Category',
            position: 'bottom',
            fields: ['Fecha'],
            //title: ['Detención', 'Pérdida señal'],
            grid: true
            /*label: {
                font: '9px Arial',
                renderer: function (name) {
                    return name.substr(0, 3);
                }
            }*/
        }],
        series: [{
            type: 'line',
            axis: 'left',
            //smooth: true,
            highlight: true,
            xField: 'Fecha',
            yField: ['PerdidaSeñal'],
            markerConfig: {
                type: 'circle',
                size: 4,
                radius: 4,
                'stroke-width': 0
            },
            tips: {
                trackMouse: true,
                width: 35,
                height: 30,
                renderer: function (storeItem, item) {
                    this.setTitle(storeItem.get('PerdidaSeñal'));
                }
            },
        },{
            type: 'line',
            axis: 'left',
            //smooth: true,
            highlight: true,
            xField: 'Fecha',
            yField: ['Detencion'],
            markerConfig: {
                type: 'circle',
                size: 4,
                radius: 4,
                'stroke-width': 0
            },
            tips: {
                trackMouse: true,
                width: 35,
                height: 30,
                renderer: function (storeItem, item) {
                    this.setTitle(storeItem.get('Detencion'));
                }
            },
        }

        ]
    });

    var panGraphTendenciaAlertas = new Ext.FormPanel({
        id: 'panGraphTendenciaAlertas',
        anchor: '100% 100%',
        title: 'Alertas últimos 10 días.',
        //renderTo: Ext.getBody(),
        layout: 'fit',
        flex: 1,
        items: [graphTendenciaAlertas]
    });

    storeGraphTendenciaAlertas.load({
        callback: function (r, options, success) {
        }
    })

    var topPanel = new Ext.FormPanel({
        anchor: '100% 45%',
        //title: 'Bottom Panel',
        layout: {
            type: 'hbox',
            pack: 'start',
            align: 'stretch'
        },
        items: [{
            xtype: 'fieldset',
            flex: 1,
            items: [panGraphViajes]
        }, {
            xtype: 'fieldset',
            flex: 1,
            items: [panGraphAlertas]
        }, {
            xtype: 'fieldset',
            flex: 1,
            items: [panGraphMotivoNoIntegracion]
        }
        ]
    });

    var bottomPanel = new Ext.FormPanel({
        anchor: '100% 56%',
        //title: 'Bottom Panel',
        layout: {
            type: 'hbox',
            pack: 'start',
            align: 'stretch'
        },
        items: [{
            xtype: 'fieldset',
            flex: 1,
            items: [panGraphTendenciaIntegracion]
        }, {
            xtype: 'fieldset',
            flex: 1,
            items: [panGraphTendenciaAlertas]
        }
        ]

    });

    var centerPanel = new Ext.FormPanel({
        id: 'centerPanel',
        region: 'center',
        border: true,
        margins: '0 3 3 0',
        //anchor: '100% 60%',
        layout: 'anchor',
        items: [topPanel, bottomPanel]
    });

    var viewport = Ext.create('Ext.container.Viewport', {
        layout: 'border',
        items: [topMenu, centerPanel]
    });
});

</script>




<script type="text/javascript">
    
</script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
  <div id="dvMap"></div>
</asp:Content>