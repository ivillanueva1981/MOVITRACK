<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="KPI_Dashboard.aspx.cs" Inherits="Track_Web.KPI_Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
AltoTrack Platform 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8" type="text/javascript"></script>
  <script src="Scripts/MapFunctions.js" type="text/javascript"></script>
  <script src="Scripts/TopMenu.js" type="text/javascript"></script>
  <script src="Scripts/LabelMarker.js" type="text/javascript"></script>

<script type="text/javascript">

  Ext.onReady(function () {

    Ext.QuickTips.init();
    Ext.Ajax.timeout = 600000;
    Ext.override(Ext.form.Basic, { timeout: Ext.Ajax.timeout / 1000 });
    Ext.override(Ext.data.proxy.Server, { timeout: Ext.Ajax.timeout });
    Ext.override(Ext.data.Connection, { timeout: Ext.Ajax.timeout });
    //Ext.form.Field.prototype.msgTarget = 'side';
    //if (Ext.isIE) { Ext.enableGarbageCollector = false; }

    Ext.Ajax.request({
        url: 'AjaxPages/Ajaxlogin.aspx?Metodo=GetPerfilSession',
        success: function (data, success) {
            if (data != null) {
                data = Ext.decode(data.responseText);
                if (data == "3") {
                    //menuReportes.disable();
                    //menuConfiguracion.disable();
                    btnMenuReportes.disable();
                    btnMenuConfig.disable();
                }

            }
        }
    });

    var date = new Date();
    var currentYear = date.getFullYear();
    var currentMonth = date.getMonth();
    var arrayYears = [];
    var i = currentYear - 1;
    while (i <= currentYear) {
      arrayYears.push([i]);
      i++;
    }

    var storeYears = new Ext.data.SimpleStore({
      fields: ['year'],
      data: arrayYears
    });

    var comboFiltroYears = new Ext.form.field.ComboBox({
      id: 'comboFiltroYears',
      fieldLabel: 'Año',
      allowBlank: false,
      store: storeYears,
      labelWidth: 80,
      valueField: 'year',
      displayField: 'year',
      queryMode: 'local',
      anchor: '99%',
      forceSelection: true,
      emptyText: 'Seleccione...',
      enableKeyEvents: true,
      editable: true
    });

    comboFiltroYears.setValue(currentYear);

    var storeMeses = new Ext.data.JsonStore({
      fields: ['IdMes', 'NombreMes'],
      data: [{ IdMes: 0, NombreMes: 'Enero' },
               { IdMes: 1, NombreMes: 'Febrero' },
               { IdMes: 2, NombreMes: 'Marzo' },
               { IdMes: 3, NombreMes: 'Abril' },
               { IdMes: 4, NombreMes: 'Mayo' },
               { IdMes: 5, NombreMes: 'Junio' },
               { IdMes: 6, NombreMes: 'Julio' },
               { IdMes: 7, NombreMes: 'Agosto' },
               { IdMes: 8, NombreMes: 'Septiembre' },
               { IdMes: 9, NombreMes: 'Octubre' },
               { IdMes: 10, NombreMes: 'Noviembre' },
               { IdMes: 11, NombreMes: 'Diciembre' }
            ]
    });

    var comboFiltroMeses = new Ext.form.field.ComboBox({
      id: 'comboFiltroMeses',
      fieldLabel: 'Mes',
      allowBlank: false,
      store: storeMeses,
      labelWidth: 80,
      queryMode: 'local',
      valueField: 'IdMes',
      displayField: 'NombreMes',
      anchor: '99%',
      forceSelection: true,
      emptyText: 'Seleccione...',
      enableKeyEvents: true,
      editable: true
    });

    comboFiltroMeses.setValue(currentMonth);

    var storeFiltroTransportista = new Ext.data.JsonStore({
      autoLoad: false,
      fields: ['Transportista'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetAllTransportistas&Todos=True',
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var comboFiltroTransportista = new Ext.form.field.ComboBox({
      id: 'comboFiltroTransportista',
      fieldLabel: 'Transportista',
      labelWidth: 80,
      forceSelection: true,
      store: storeFiltroTransportista,
      valueField: 'Transportista',
      displayField: 'Transportista',
      queryMode: 'local',
      anchor: '99%',
      emptyText: 'Seleccione...',
      enableKeyEvents: true,
      editable: true,
      forceSelection: true
    });

    storeFiltroTransportista.load({
      callback: function (r, options, success) {
        if (success) {
            //Ext.getCmp("comboFiltroTransportista").setValue("Todos");
            var firstTransportista = Ext.getCmp("comboFiltroTransportista").store.getAt(0).get("Transportista");
            Ext.getCmp("comboFiltroTransportista").setValue(firstTransportista);
          Buscar();
        }
      }
    })

    var btnBuscar = {
      id: 'btnBuscar',
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/searchreport_black_20x20.png',
      text: 'Buscar',
      width: 90,
      height: 26,
      handler: function () {
        Buscar();
      }
    };

    var panelFilters = new Ext.FormPanel({
      id: 'panelFilters',
      title: 'Filtros Reporte',
      anchor: '100% 100%',
      bodyStyle: 'padding: 5px;',
      layout: 'anchor',
      items: [{
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 1,
        items: [comboFiltroYears]
      }, {
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 1,
        items: [comboFiltroMeses]
      }, {
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 1,
        items: [comboFiltroTransportista]
      }],
      buttons: [btnBuscar]
    });
    
    var storeDashboard = new Ext.data.JsonStore({
    autoLoad: false,
        fields: ['Transportista',
        'CantAperturaPuerta',
        'CantDetencion',
        'CantPerdidaSenal',
        'CantRuta',
        'CantVelocidad',
        'CantTemperatura',
        'CantFinalizado',
        'CantCerradoSistema'],
      proxy: new Ext.data.HttpProxy({
      url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetDashboard',
      reader: { type: 'json', root: 'Zonas' },
        headers: {
        'Content-type': 'application/json'
        }
      })
    });

    var gridPanelDashboard = Ext.create('Ext.grid.Panel', {
      id: 'gridPanelDashboard',
      title: 'Dashboard',
      store: storeDashboard,
      anchor: '100% 50%',
      columnLines: true,
      scroll: false,
      viewConfig: {
        style: { overflow: 'auto', overflowX: 'hidden' }
      },
      features: [{
        ftype: 'summary'
      }],
      columns: [
                  { text: 'Transportista', sortable: true, flex: 1, dataIndex: 'Transportista',
                    summaryRenderer: function (value, summaryData, dataIndex) {
                      return Ext.String.format('Total'); s
                    }
                  },
                  { text: 'Apertura puerta', sortable: true, width: 100, dataIndex: 'CantAperturaPuerta', summaryType: 'sum' },
                  { text: 'Detención', sortable: true, width: 80, dataIndex: 'CantDetencion', summaryType: 'sum' },
                  { text: 'Pérdida Señal', sortable: true, width: 100, dataIndex: 'CantPerdidaSenal', summaryType: 'sum' },
                  //{ text: 'Ruta', sortable: true, width: 80, dataIndex: 'CantRuta', summaryType: 'sum' },
                  {text: 'Velocidad', sortable: true, width: 80, dataIndex: 'CantVelocidad', summaryType: 'sum' },
                  { text: 'Temperatura', sortable: true, width: 80, dataIndex: 'CantTemperatura', summaryType: 'sum' }
                ],
      listeners: {
        select: function (sm, row, rec) {
          storeGraphViajes.removeAll();
          storeGraphAlertas.removeAll();

          var transportista = row.data.Transportista;
          var cantRuta = row.data.CantRuta;
          var cantPerdidaSenal = row.data.CantPerdidaSenal;
          var cantDetencion = row.data.CantDetencion;
          var cantVelocidad = row.data.CantVelocidad;
          var cantTemperatura = row.data.CantTemperatura;
          var cantAperturaPuerta = row.data.CantAperturaPuerta;
          var cantFinalizado = row.data.CantFinalizado;
          var cantCerradoSistema = row.data.CantCerradoSistema;

          storeGraphViajes.add(
          { Estado: 'Finalizado', Cantidad: cantFinalizado },
          { Estado: 'Cerrado por Sist.', Cantidad: cantCerradoSistema });

          Ext.getCmp('panGraphViajes').setTitle('Viajes - ' + transportista);

          storeGraphAlertas.add(
          //{ TipoAlerta: 'Ruta', Cantidad: cantRuta },
          {TipoAlerta: 'Temp.', Cantidad: cantTemperatura },
          { TipoAlerta: 'Perdida Señal', Cantidad: cantPerdidaSenal },
          { TipoAlerta: 'Detención', Cantidad: cantDetencion },
          { TipoAlerta: 'Velocidad', Cantidad: cantVelocidad },
          { TipoAlerta: 'Apertura Puerta', Cantidad: cantAperturaPuerta });

          Ext.getCmp('panGraphAlertas').setTitle('Alertas - ' + transportista);

        }
      }
    });

    var graphTop = new Ext.chart.Chart({
      id: 'graphTop',
      animate: true,
      shadow: true,
      store: storeDashboard,
      legend: {
        position: 'right'
      },
      axes: [{
        type: 'Category',
        position: 'bottom',
        fields: ['Transportista'],
        title: true,
        grid: true,
        label: {
          /*renderer: function(v) {
          return Ext.String.ellipsis(v, 15, false);
          },*/
          font: '9px Arial',
          rotate: {
            degrees: 270
          }
        },
        roundToDecimal: false
      }, {
        type: 'Numeric',
        position: 'left',
        fields: ['CantAperturaPuerta', 'CantDetencion', 'CantPerdidaSenal', 'CantTemperatura', 'CantVelocidad'],
        title: ['Apertura puerta', 'Detención', 'Pérdida señal', 'Temperatura', 'Velocidad']
      }],
      series: [{
        type: 'column',
        axis: 'left',
        highlight: true,
        xField: 'Transportista',
        yField: ['CantAperturaPuerta', 'CantDetencion', 'CantPerdidaSenal', 'CantTemperatura', 'CantVelocidad'],
        title: ['Apertura puerta', 'Detención', 'Pérdida señal', 'Temperatura', 'Velocidad'],
        stacked: true,
        tips: {
          trackMouse: true,
          width: 65,
          height: 28,
          renderer: function (storeItem, item) {
            this.setTitle(String(item.value[1]));
          }
        }
      }]
    });

    var storeGraphViajes = new Ext.data.JsonStore({
      fields: ['Estado', 'Cantidad'],
      data: [{ Estado: 'Finalizado', Cantidad: 0 },
               { Estado: 'Cerrado por Sist.', Cantidad: 0 }
            ]
    });

    var graphViajes = new Ext.chart.Chart({
      id: 'graphViajes',
      animate: true,
      shadow: true,
      store: storeGraphViajes,
      queryMode: 'local',
      legend: {
        position: 'bottom'
      },

      insetPadding: 40,
      theme: 'Base:gradients',
      series: [{
        type: 'pie',
        field: 'Cantidad',
        showInLegend: true,
        donut: 30,
        tips: {
          trackMouse: true,
          width: 100,
          height: 50,
          renderer: function (storeItem, item) {
            //calculate percentage.
            var total = 0;
            storeGraphViajes.each(function (rec) {
              total += rec.get('Cantidad');
            });
            this.setTitle(storeItem.get('Estado') + ': ' + storeItem.get('Cantidad') + ' (' + Math.round(storeItem.get('Cantidad') / total * 100) + '%)');
          }
        },
        highlight: {
          segment: {
            margin: 10
          }
        },
        label: {
          field: 'Estado',
          //display: 'Cantidad',
          contrast: true,
          font: '8px Arial'
        }
      }]
    });

    var storeGraphAlertas = new Ext.data.JsonStore({
      fields: ['TipoAlerta', 'Cantidad'],
      data: [{ TipoAlerta: 'Temp.', Cantidad: 0 },
             { TipoAlerta: 'Perdida Señal', Cantidad: 0 },
             { TipoAlerta: 'Detención', Cantidad: 0 },
             { TipoAlerta: 'Velocidad', Cantidad: 0 },
             { TipoAlerta: 'Apertura Puerta', Cantidad: 0 },
            ]
    });

    var graphAlertas = new Ext.chart.Chart({
      id: 'graphAlertas',
      animate: true,
      shadow: true,
      store: storeGraphAlertas,
      theme: 'Blue',
      margin: '0 0 0 0',
      insetPadding: 50,
      flex: 1,
      axes: [{
        steps: 4,
        type: 'Radial',
        position: 'radial'
        //maximum: 100
      }],
      series: [{
        type: 'radar',
        xField: 'TipoAlerta',
        yField: 'Cantidad',
        showInLegend: false,
        showMarkers: true,
        markerConfig: {
          radius: 3,
          size: 3,
          fill: 'rgb(69,109,159)'
        },
        style: {
          fill: 'rgb(194,214,240)',
          opacity: 0.5,
          'stroke-width': 0.5
        }
      }]

    });

    var panTopGraph = new Ext.FormPanel({
      id: 'panTopGraph',
      anchor: '100% 50%',
      title: 'Alertas por Transportista',
      //renderTo: Ext.getBody(),
      layout: 'fit',
      flex: 1,
      items: [graphTop]
    });

    var panGraphViajes = new Ext.FormPanel({
      id: 'panGraphViajes',
      anchor: '100% 50%',
      title: 'Viajes',
      //renderTo: Ext.getBody()
      layout: 'fit',
      flex: 1,
      items: [graphViajes]
    });

    var comboGraphViajes = new Ext.form.field.ComboBox({
      id: 'comboGraphViajes',
      store: storeGraphViajes,
      queryMode: 'local'
    });

    var panGraphAlertas = new Ext.FormPanel({
      id: 'panGraphAlertas',
      anchor: '100% 50%',
      title: 'Alertas',
      //renderTo: Ext.getBody()
      layout: 'fit',
      flex: 1,
      items: [graphAlertas]
    });

    var comboGraphAlertas = new Ext.form.field.ComboBox({
      id: 'comboGraphAlertas',
      store: storeGraphAlertas,
      queryMode: 'local'
    });

    var bottomPanel = new Ext.FormPanel({
      anchor: '100% 100%',
      //title: 'Bottom Panel',
      layout: {
        type: 'hbox',
        pack: 'start',
        align: 'stretch'
      },
      items: [{
        xtype: 'fieldset',
        //title: 'Geocercas',
        flex: 1,
        //anchor: '70% 100%',
        items: [gridPanelDashboard]
      }, {
        xtype: 'fieldset',
        //anchor: '30 100%',
        //title: 'Moviles',
        width: 250,
        items: [panGraphViajes]
      }, {
        xtype: 'fieldset',
        //anchor: '30 100%',
        //title: 'Moviles',
        width: 300,
        items: [panGraphAlertas]
      }]
    });

    var leftPanel = new Ext.FormPanel({
      id: 'leftPanel',
      region: 'west',
      border: true,
      margins: '0 0 3 3',
      width: 300,
      minWidth: 200,
      maxWidth: 400,
      layout: 'anchor',
      collapsible: true,
      collapsed: true,
      titleCollapsed: false,
      split: true,
      items: [panelFilters]
    });

    var centerPanel = new Ext.FormPanel({
      id: 'centerPanel',
      region: 'center',
      border: true,
      margins: '0 3 3 0',
      anchor: '100% 100%',
      layout: 'anchor',
      items: [panTopGraph, bottomPanel]
    });

    var viewport = Ext.create('Ext.container.Viewport', {
      layout: 'border',
      items: [topMenu, leftPanel, centerPanel]
    });
  });

</script>

<script type="text/javascript">

  function Buscar() {
    if (!Ext.getCmp('leftPanel').getForm().isValid()) {
      return;
    }

    var year = Ext.getCmp('comboFiltroYears').getValue();
    var month = Ext.getCmp('comboFiltroMeses').getValue();
    var transportista = Ext.getCmp('comboFiltroTransportista').getValue();

    var title = 'Alertas por Transportista. ' + Ext.getCmp('comboFiltroMeses').getRawValue() + ' ' + year;

    Ext.getCmp('panTopGraph').setTitle(title);
    
    var store = Ext.getCmp('gridPanelDashboard').store;
    store.load({
    params: {
    year: year,
    month: month + 1,
    transportista: transportista
    },
    callback: function (r, options, success) {
        if (!success) {
          Ext.MessageBox.show({
          title: 'Error',
          msg: 'Se ha producido un error.',
          buttons: Ext.MessageBox.OK
          });
        }
      }
    });
  }
  
</script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
  <div id="dvMap"></div>
</asp:Content>
