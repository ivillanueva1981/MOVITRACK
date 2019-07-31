<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Rpt_KmsRecorridos.aspx.cs" Inherits="Track_Web.Rpt_KmsRecorridos" %>
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

    var dateDesde = new Ext.form.DateField({
      id: 'dateDesde',
      fieldLabel: 'Desde',
      labelWidth: 80,
      allowBlank: false,
      anchor: '99%',
      format: 'd-m-Y',
      editable: false,
      value: new Date(),
      maxValue: new Date(),
      style: {
        marginLeft: '5px'
      }
    });

    var dateHasta = new Ext.form.DateField({
      id: 'dateHasta',
      fieldLabel: 'Hasta',
      labelWidth: 80,
      allowBlank: false,
      anchor: '99%',
      format: 'd-m-Y',
      editable: false,
      value: new Date(),
      minValue: Ext.getCmp('dateDesde').getValue(),
      maxValue: new Date(),
      style: {
        marginLeft: '5px'
      }
    });

    dateDesde.on('change', function () {
      var _desde = Ext.getCmp('dateDesde');
      var _hasta = Ext.getCmp('dateHasta');

      _hasta.setMinValue(_desde.getValue());
      _hasta.setMaxValue(Ext.Date.add(_desde.getValue(), Ext.Date.DAY, 60));
      _hasta.validate();
    });

    dateHasta.on('change', function () {
      var _desde = Ext.getCmp('dateDesde');
      var _hasta = Ext.getCmp('dateHasta');

      _desde.setMinValue(Ext.Date.add(_hasta.getValue(), Ext.Date.DAY, -60));
      //_desde.setMaxValue(_hasta.getValue());
      _desde.validate();
    });

    Ext.getCmp('dateDesde').setMinValue(Ext.Date.add(Ext.getCmp('dateHasta').getValue(), Ext.Date.DAY, -60));
    Ext.getCmp('dateHasta').setMaxValue(Ext.Date.add(Ext.getCmp('dateDesde').getValue(), Ext.Date.DAY, 60));

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
      forceSelection: true,
      style: {
        marginLeft: '5px'
      },
      listeners: {
        change: function (field, newVal) {
          if (newVal != null) {
            FiltrarPatentes();
          }
          Ext.getCmp('comboFiltroPatente').reset();
        }
      }
    });

    var storeFiltroPatente = new Ext.data.JsonStore({
      autoLoad: false,
      fields: ['Patente'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetAllPatentes&Todas=True',
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var comboFiltroPatente = new Ext.form.field.ComboBox({
      id: 'comboFiltroPatente',
      fieldLabel: 'Patente',
      labelWidth: 80,
      store: storeFiltroPatente,
      valueField: 'Patente',
      displayField: 'Patente',
      queryMode: 'local',
      anchor: '99%',
      emptyText: 'Seleccione...',
      enableKeyEvents: true,
      editable: true,
      forceSelection: true,
      allowBlank: false,
      style: {
        marginLeft: '5px'
      }
    });

    storeFiltroTransportista.load({
      callback: function (r, options, success) {
        if (success) {
          //Ext.getCmp("comboFiltroTransportista").store.insert(0, { Transportista: "Todos" });
            //Ext.getCmp("comboFiltroTransportista").setValue("Todos");

            var firstTransportista = Ext.getCmp("comboFiltroTransportista").store.getAt(0).get("Transportista");
            Ext.getCmp("comboFiltroTransportista").setValue(firstTransportista);

          storeFiltroPatente.load({
            callback: function (r, options, success) {
              if (success) {
                //Ext.getCmp("comboFiltroPatente").store.insert(0, { Patente: "Todas" });
                  Ext.getCmp("comboFiltroPatente").setValue("Todas");
                  FiltrarPatentes();

              }
            }
          })
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

    var btnExportar = {
      id: 'btnExportar',
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/export_black_20x20.png',
      text: 'Exportar',
      width: 90,
      height: 26,
      listeners: {
        click: {
          element: 'el',
          fn: function () {

            var desde = Ext.getCmp('dateDesde').getRawValue();
            var hasta = Ext.getCmp('dateHasta').getRawValue();
            var transportista = Ext.getCmp('comboFiltroTransportista').getValue();
            var patente = Ext.getCmp('comboFiltroPatente').getValue();

            var mapForm = document.createElement("form");
            mapForm.target = "ToExcel";
            mapForm.method = "POST"; // or "post" if appropriate
            mapForm.action = 'Rpt_KmsRecorridos.aspx?Metodo=ExportExcel';

            //
            var _desde = document.createElement("input");
            _desde.type = "text";
            _desde.name = "desde";
            _desde.value = desde;
            mapForm.appendChild(_desde);

            var _hasta = document.createElement("input");
            _hasta.type = "text";
            _hasta.name = "hasta";
            _hasta.value = hasta;
            mapForm.appendChild(_hasta);

            var _transportista = document.createElement("input");
            _transportista.type = "text";
            _transportista.name = "transportista";
            _transportista.value = transportista;
            mapForm.appendChild(_transportista);

            var _patente = document.createElement("input");
            _patente.type = "text";
            _patente.name = "patente";
            _patente.value = patente;
            mapForm.appendChild(_patente);

            document.body.appendChild(mapForm);
            mapForm.submit();

          }
        }
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
        items: [dateDesde]
      }, {
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 1,
        items: [dateHasta]
      }, {
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 1,
        items: [comboFiltroTransportista]
      }, {
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 1,
        items: [comboFiltroPatente]
      }],
      buttons: [btnExportar, btnBuscar]
    });

    var storeReporte = new Ext.data.JsonStore({
      autoLoad: false,
      fields: [ 'NroTransporte',
                'NumeroOrdenServicio',
                'NumeroContenedor',
                'PatenteTrailer',
                'PatenteTracto',
                'Transportista',
                'IdOrigen',
                'NombreOrigen',
                { name: 'FHSalidaOrigen', type: 'date', dateFormat: 'c' },
                'NombreConductor',
                'RutConductor',
                'Destinos',
                { name: 'FHLlegadaUltDestino', type: 'date', dateFormat: 'c' },
                'KmRecorridos'],
      groupField: 'Transportista',
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetRpt_KmsRecorridos',
        reader: { type: 'json', root: 'Zonas' },
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var gridPanelReporte = Ext.create('Ext.grid.Panel', {
      id: 'gridPanelReporte',
      title: 'Reporte Kms Recorridos',
      store: storeReporte,
      anchor: '100% 100%',
      columnLines: true,
      scroll: false,
      viewConfig: {
        style: { overflow: 'auto', overflowX: 'hidden' }
      },
      features: [{
        //id: 'group',
        ftype: 'groupingsummary',
        groupHeaderTpl: '{name}'
        //hideGroupedHeader: true,
        //enableGroupingMenu: false
      }],
      columns: [
                  { text: 'Transportista', sortable: true, flex: 1, dataIndex: 'Transportista',
                    summaryType: 'count',
                    summaryRenderer: function (value, summaryData, dataIndex) {
                      return ((value === 0 || value > 1) ? 'Total: ' + value + ' Viajes' : 'Total: 1 Viaje');
                    }
                  },
                  { text: 'Fecha', sortable: true, width: 80, dataIndex: 'FHSalidaOrigen', renderer: Ext.util.Format.dateRenderer('d-m-Y') },
                  { text: 'Guía', sortable: true, width: 65, dataIndex: 'NroTransporte' },
                  { text: 'Orden Servicio', sortable: true, width: 80, dataIndex: 'NumeroOrdenServicio' },
                  { text: 'Contenedor', sortable: true, width: 80, dataIndex: 'NumeroContenedor' },
                  { text: 'Tracto', sortable: true, width: 60, dataIndex: 'PatenteTracto' },
                  { text: 'Rampla', sortable: true, width: 60, dataIndex: 'PatenteTrailer' },
                  { text: 'Origen', sortable: true, width: 100, dataIndex: 'NombreOrigen' },
                  { text: 'Destino/s', sortable: true, flex: 1, dataIndex: 'Destinos' },
                  {text: 'Conductor', sortable: true, dataIndex: 'NombreConductor' },
                  { text: 'Rut', sortable: true, width: 75, dataIndex: 'RutConductor' },
                  { text: 'Kms', sortable: true, width: 100, dataIndex: 'KmRecorridos',
                    summaryType: 'sum',
                    renderer: function (value, metaData, record, rowIdx, colIdx, store, view) {
                      value = value.toFixed(1);
                      return value + ' Kms';
                    },
                    summaryRenderer: function (value, summaryData, dataIndex) {
                      value = value.toFixed(1);
                      return value + ' Kms';
                    },
                    field: {
                      xtype: 'numberfield',
                      decimalPrecision: 1
                    }
                  }
                ]

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
      items: [gridPanelReporte]
    });

    var viewport = Ext.create('Ext.container.Viewport', {
      layout: 'border',
      items: [topMenu, leftPanel, centerPanel]
    });
  });

</script>


<script type="text/javascript">

  function FiltrarPatentes() {
    var transportista = Ext.getCmp('comboFiltroTransportista').getValue();

    var store = Ext.getCmp('comboFiltroPatente').store;
    store.load({
      params: {
        transportista: transportista
      }
    });
  }

  function Buscar() {
    if (!Ext.getCmp('leftPanel').getForm().isValid()) {
      return;
    }

    var desde = Ext.getCmp('dateDesde').getValue();
    var hasta = Ext.getCmp('dateHasta').getValue();
    var transportista = Ext.getCmp('comboFiltroTransportista').getValue();
    var patente = Ext.getCmp('comboFiltroPatente').getValue();

    var store = Ext.getCmp('gridPanelReporte').store;
      store.load({
        params: {
          desde: desde,
          hasta: hasta,
          transportista: transportista,
          patente: patente
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
