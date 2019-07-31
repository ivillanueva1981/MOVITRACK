<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InformeViajes.aspx.cs" Inherits="Track_Web.InformeViajes" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
AltoTrack Platform
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8" type="text/javascript"></script>
  <script src="Scripts/MapFunctions.js" type="text/javascript"></script>
  <script src="Scripts/TopMenu.js" type="text/javascript"></script>
  <script src="Scripts/LabelMarker.js" type="text/javascript"></script>

  <style type="text/css">
      .textColorGreen
      { color:Green; font-weight:bold; }
      .textColorYellow
      { color:Yellow; font-weight:bold; }
      .textColorRed
      { color:Red; font-weight:bold; }
      .textColorBlack
      { color:Black; font-weight:bold; }  
  </style>

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

      var chkNroTransporte = new Ext.form.Checkbox({
          id: 'chkNroTransporte',
          labelSeparator: '',
          hideLabel: true,
          checked: true,
          style: {
              marginTop: '7px',
              marginLeft: '10px'
          },
          listeners: {
              change: function (cb, checked) {
                  if (checked == true) {
                      Ext.getCmp("textNroTransporte").setDisabled(false);
                      Ext.getCmp("textFiltroOrdenServicio").setDisabled(true);
                      
                      Ext.getCmp("dateDesde").setDisabled(true);
                      Ext.getCmp("dateHasta").setDisabled(true);
                      Ext.getCmp("comboFiltroTransportista").setDisabled(true);
                      Ext.getCmp("comboFiltroPatente").setDisabled(true);
                      Ext.getCmp("comboFiltroTipoEtis").setDisabled(true);
                  }
                  else {
                      Ext.getCmp("textNroTransporte").setDisabled(true);
                      Ext.getCmp("textFiltroOrdenServicio").setDisabled(false);
                      Ext.getCmp("dateDesde").setDisabled(false);
                      Ext.getCmp("dateHasta").setDisabled(false);
                      Ext.getCmp("comboFiltroTransportista").setDisabled(false);
                      Ext.getCmp("comboFiltroPatente").setDisabled(false);
                      Ext.getCmp('textNroTransporte').reset();
                      Ext.getCmp("comboFiltroTipoEtis").setDisabled(false);
                  }
              }
          }
      });

      var textNroTransporte = new Ext.form.TextField({
          id: 'textNroTransporte',
          labelWidth: 80,
          fieldLabel: 'Guía Despacho',
          allowBlank: true,
          anchor: '99%',
          maxLength: 20,
          style: {
              marginTop: '5px',
              marginLeft: '5px'
          }
      });

      var textFiltroOrdenServicio = new Ext.form.TextField({
          id: 'textFiltroOrdenServicio',
          labelWidth: 80,
          fieldLabel: 'OS',
          allowBlank: true,
          anchor: '99%',
          maxLength: 20,
          style: {
              marginTop: '5px',
              marginLeft: '5px'
          },
          disabled: true
      });

      var dateDesde = new Ext.form.DateField({
        id: 'dateDesde',
        fieldLabel: 'Desde',
        labelWidth: 100,
        allowBlank: false,
        anchor: '99%',
        format: 'd-m-Y',
        editable: false,
        value: new Date(),
        maxValue: new Date(),
        style: {
          marginLeft: '5px'
        },
          disabled: true
      });

      dateDesde.on('change', function () {
        var _desde = Ext.getCmp('dateDesde');
        var _hasta = Ext.getCmp('dateHasta');

        //_hasta.setValue(_desde.getValue());
        _hasta.setMinValue(_desde.getValue());
        _hasta.setMaxValue(Ext.Date.add(_desde.getValue(), Ext.Date.DAY, 60));
        _hasta.validate();
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
        },
          disabled: true
      });

      var storeFiltroTipoEtis = new Ext.data.JsonStore({
          autoLoad: true,
          fields: ['ETIS'],
          proxy: new Ext.data.HttpProxy({
              url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetTipoEtis&Todos=True',
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });

      var comboFiltroTipoEtis = new Ext.form.field.ComboBox({
          id: 'comboFiltroTipoEtis',
          fieldLabel: 'ETIS',
          labelWidth: 100,
          forceSelection: true,
          store: storeFiltroTipoEtis,
          valueField: 'ETIS',
          displayField: 'ETIS',
          queryMode: 'local',
          anchor: '99%',
          emptyText: 'Seleccione...',
          enableKeyEvents: true,
          editable: false,
          forceSelection: true,
          style: {
              marginTop: '5px',
              marginLeft: '5px'
          },
          disabled: true
      });

      storeFiltroTipoEtis.load({
          callback: function (r, options, success) {
              if (success) {
                  comboFiltroTipoEtis.setValue('Todas');
              }
          }
      })

      var storeFiltroTransportista = new Ext.data.JsonStore({
        autoLoad: true,
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
        labelWidth: 100,
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
          }
        },
          disabled: true
      });

      var storeFiltroPatente = new Ext.data.JsonStore({
        autoLoad: true,
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
        forceSelection: true,
        store: storeFiltroPatente,
        valueField: 'Patente',
        displayField: 'Patente',
        queryMode: 'local',
        anchor: '99%',
        emptyText: 'Seleccione...',
        enableKeyEvents: true,
        editable: true,
        forceSelection: true,
        style: {
          marginTop: '5px',
          marginLeft: '5px'
        },
          disabled: true
      });

      storeFiltroTransportista.load({
          callback: function (r, options, success) {
              if (success) {
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

      var toolbarViajes = Ext.create('Ext.toolbar.Toolbar', {
        id: 'toolbarViajes',
        height: 120,
        layout: 'column',
        items: [{
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 0.05,
            items: [chkNroTransporte]
        }, {
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 0.45,
            items: [textNroTransporte]
        }, {
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 0.5,
            items: [textFiltroOrdenServicio]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.5,
          items: [dateDesde, comboFiltroTransportista, comboFiltroTipoEtis]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.5,
          items: [dateHasta, comboFiltroPatente]
        }]
      });

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
        disabled: true,
        style: {
          marginBottom: '10px'
        },
        handler: function () {
          Exportar();
        }
      };

      var storeViajes = new Ext.data.JsonStore({
        autoLoad: false,
        fields: [ 'NroTransporte',
                  'NumeroOrdenServicio',
                  'NombreCliente',
                  'NumeroContenedor',
                  { name: 'FechaHoraPresentacion', type: 'date', dateFormat: 'c' },
                  'NombreChofer',
                  'PatenteTrailer',
                  'PatenteTracto',
                  'Transportista',
                  'CodigoOrigen',
                  'NombreOrigen',
                  { name: 'FHSalidaOrigen', type: 'date', dateFormat: 'c' },
                  'NombreConductor',
                  'Destinos',
                  'MontoReclamado',
                  'RutConductor',
                  'Score',
                  'NombreTerminalGestionServicio'
                  ],
        proxy: new Ext.data.HttpProxy({
          url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetInformeViajes',
          reader: { type: 'json', root: 'Zonas' },
          headers: {
            'Content-type': 'application/json'
          }
        })
      });

      var gridPanelViajes = Ext.create('Ext.grid.Panel', {
        id: 'gridPanelViajes',
        title: 'Viajes',
        store: storeViajes,
        tbar: toolbarViajes,
        anchor: '100% 100%',
        columnLines: true,
        scroll: false,
        buttons: [btnExportar, btnBuscar],
        viewConfig: {
          style: { overflow: 'auto', overflowX: 'hidden' }
        },
        columns: [
                    { text: 'Guía', sortable: true, width: 70, dataIndex: 'NroTransporte' },
                    { text: 'Tracto', sortable: true, width: 60, dataIndex: 'PatenteTracto' },
                    { text: 'Rampla', sortable: true, width: 60, dataIndex: 'PatenteTrailer' },
                    { text: 'Transportista', sortable: true, flex: 1, dataIndex: 'Transportista' },
                    { text: 'Conductor', sortable: true, flex: 1, dataIndex: 'NombreChofer' },
                    { text: 'Nombre Origen', sortable: true, flex: 1, dataIndex: 'NombreOrigen' }
            ],
        listeners: {
          select: function (sm, row, rec) {
            var size = Ext.getCmp('panelMap').getWidth().toString() + 'x' + Ext.getCmp('panelMap').getHeight();

            Ext.getCmp('txtNroTransporte').setDisabled(false);
            Ext.getCmp('textFiltroOrdenServicio').setDisabled(false);
            

            Ext.getCmp('txtTransportista').setDisabled(false);
            Ext.getCmp('txtConductor').setDisabled(false);
            Ext.getCmp('txtRutConductor').setDisabled(false);
            Ext.getCmp('txtScore').setDisabled(false);
            Ext.getCmp('txtNombreOrigen').setDisabled(false);
            Ext.getCmp('txtTracto').setDisabled(false);
            Ext.getCmp('txtTrailer').setDisabled(false);
            Ext.getCmp('txtNroContenedor').setDisabled(false);
            Ext.getCmp('txtDestinos').setDisabled(false);
            Ext.getCmp('txtNombreCliente').setDisabled(false);
            Ext.getCmp('gridPanelDetalleTrayecto').setDisabled(false);
            Ext.getCmp('gridPanelAlertasInformeViaje').setDisabled(false);
            Ext.getCmp('btnExportar').setDisabled(false);

            Ext.getCmp('textAreaObservaciones').setDisabled(true);
            Ext.getCmp('mapImage').setDisabled(true);

            Ext.getCmp('numberIdAlerta').reset();
            Ext.getCmp('txtNroTransporte').reset();
            Ext.getCmp('textFiltroOrdenServicio').reset();
            
            Ext.getCmp('txtTransportista').reset();
            Ext.getCmp('txtConductor').reset();
            Ext.getCmp('txtRutConductor').reset();
            Ext.getCmp('txtScore').reset();
            Ext.getCmp('txtNombreOrigen').reset();
            Ext.getCmp('txtTracto').reset();
            Ext.getCmp('txtTrailer').reset();
            Ext.getCmp('txtNroContenedor').reset();
            Ext.getCmp('txtDestinos').reset();
            Ext.getCmp('txtNombreCliente').reset();
            Ext.getCmp('gridPanelDetalleTrayecto').store.removeAll();
            Ext.getCmp('textAreaObservaciones').reset();
            Ext.getCmp('gridPanelAlertasInformeViaje').store.removeAll();
            Ext.getCmp('mapImage').setSrc('https://maps.googleapis.com/maps/api/staticmap?center=-33.453172,-70.858681&zoom=9&size=' + size + '&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8');

            Ext.getCmp('txtNroTransporte').setValue(row.data.NroTransporte);
            Ext.getCmp('textFiltroOrdenServicio').setValue(row.data.NroTransporte);
            
            Ext.getCmp('txtTransportista').setValue(row.data.Transportista);
            Ext.getCmp('txtConductor').setValue(row.data.NombreConductor);
            Ext.getCmp('txtRutConductor').setValue(row.data.RutConductor);

            Ext.getCmp('txtScore').setValue(row.data.Score);
            /*
            if (row.data.Score == 'Rojo') {

              Ext.getCmp('txtScore').addCls('textColorRed');
            }
            else {

              Ext.getCmp('txtScore').addCls('textColorGreen');
            
            }
            */
            Ext.getCmp('txtNombreOrigen').setValue(row.data.NombreOrigen);
            Ext.getCmp('txtTracto').setValue(row.data.PatenteTracto);
            Ext.getCmp('txtTrailer').setValue(row.data.PatenteTrailer);
            Ext.getCmp('txtNroContenedor').setValue(row.data.NumeroContenedor);
            Ext.getCmp('txtDestinos').setValue(row.data.Destinos);
            Ext.getCmp('txtNombreCliente').setValue(row.data.NombreCliente);

            GetAlertasInformeViaje(row.data.NroTransporte);
            GetDetalleTrayecto(row.data.NroTransporte);

            Ext.getCmp("gridPanelViajes").getSelectionModel().deselectAll(); 
          }
        }
      });

      var viewWidth = Ext.getBody().getViewSize().width;
      var viewHeight = Ext.getBody().getViewSize().height;

      var leftPanel = new Ext.FormPanel({
        id: 'leftPanel',
        region: 'west',
        margins: '0 0 3 3',
        border: true,
        width: 500,
        minWidth: 400,
        maxWidth: viewWidth / 2,
        layout: 'anchor',
        split: true,
        collapsible: true,
        hideCollapseTool: true,
        items: [gridPanelViajes]

      });

      var txtNroTransporte = new Ext.form.TextField({
        id: 'txtNroTransporte',
        fieldLabel: 'Guía',
        labelWidth: 100,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var txtTransportista = new Ext.form.TextField({
        id: 'txtTransportista',
        fieldLabel: 'Transportista',
        labelWidth: 100,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var txtConductor = new Ext.form.TextField({
        id: 'txtConductor',
        fieldLabel: 'Conductor',
        labelWidth: 110,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var txtRutConductor = new Ext.form.TextField({
        id: 'txtRutConductor',
        fieldLabel: 'Rut Conductor',
        labelWidth: 110,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var txtScore = new Ext.form.TextField({
        id: 'txtScore',
        fieldLabel: 'Score',
        labelWidth: 110,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var txtNombreOrigen = new Ext.form.TextField({
        id: 'txtNombreOrigen',
        fieldLabel: 'Origen',
        labelWidth: 100,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var txtTracto = new Ext.form.TextField({
        id: 'txtTracto',
        fieldLabel: 'Tracto',
        labelWidth: 110,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var txtTrailer = new Ext.form.TextField({
          id: 'txtTrailer',
          fieldLabel: 'Rampla',
          labelWidth: 100,
          readOnly: true,
          anchor: '99%',
          disabled: true
      });

      var txtNroContenedor = new Ext.form.TextField({
          id: 'txtNroContenedor',
        fieldLabel: 'Contenedor',
        labelWidth: 110,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var txtDestinos = new Ext.form.TextField({
        id: 'txtDestinos',
        fieldLabel: 'Destino/s',
        labelWidth: 100,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var txtNombreCliente = new Ext.form.TextField({
          id: 'txtNombreCliente',
        fieldLabel: 'Cliente',
        labelWidth: 100,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var storeDetalleTrayecto = new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['Fecha',
                  'Detalle'
                ],
        proxy: new Ext.data.HttpProxy({
          url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetDetalleTrayecto',
          reader: { type: 'json', root: 'Zonas' },
          headers: {
            'Content-type': 'application/json'
          }
        })
      });

      var gridPanelDetalleTrayecto = Ext.create('Ext.grid.Panel', {
        id: 'gridPanelDetalleTrayecto',
        store: storeDetalleTrayecto,
        anchor: '100% 85%',
        columnLines: true,
        disabled: true,
        scroll: false,
        disableSelection: true,
        /*
        style: {
        marginLeft: '5px'
        },
        */
        viewConfig: {
          style: { overflow: 'auto', overflowX: 'hidden' }
        },  
        columns: [
                    { text: 'Fecha', sortable: true, width: 240, dataIndex: 'Fecha' },
                    { text: 'Detalle', sortable: true, flex: 1, dataIndex: 'Detalle' }
            ]
      });

      var numberIdAlerta = new Ext.form.NumberField({
        id: 'numberIdAlerta'
      });

      var textAreaObservaciones = new Ext.form.field.TextArea({
        id: 'textAreaObservaciones',
        //fieldLabel: 'Observaciones',
        disabled: true,
        anchor: '100% 90%',
        maxLength: 500
      });

      var btnGuardar = {
        id: 'btnGuardar',
        xtype: 'button',
        iconAlign: 'left',
        icon: 'Images/save_black_20x20.png',
        text: 'Guardar',
        width: 90,
        height: 30,
        style: {
          marginLeft: '5px',
          marginRight: '5px'
        },
        disabled: true,
        handler: function () {
          UpdateObservaciones();
        }
      };

      var storeAlertasInformeViaje = new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['Id',
                { name: 'FechaInicioAlerta', type: 'date', dateFormat: 'c' },
                { name: 'FechaHoraCreacion', type: 'date', dateFormat: 'c' },
                'LocalDestino',
                'TextFechaCreacion',
                'PatenteTracto',
                'PatenteTrailer',
                'Velocidad',
                'Latitud',
                'Longitud',
                'DescripcionAlerta',
                'Ocurrencia',
                'Puerta1',
                'Temp1',
                'Observaciones',
                'ZoneLocation'],
        proxy: new Ext.data.HttpProxy({
          url: 'AjaxPages/AjaxAlertas.aspx?Metodo=GetAlertasInformeViaje',
          reader: { type: 'json', root: 'Zonas' },
          headers: {
            'Content-type': 'application/json'
          }
        })
      });

      var gridPanelAlertasInformeViaje = Ext.create('Ext.grid.Panel', {
        id: 'gridPanelAlertasInformeViaje',
        store: storeAlertasInformeViaje,
        anchor: '100% 91%',
        columnLines: true,
        scroll: false,
        disabled: true,
        viewConfig: {
          style: { overflow: 'auto', overflowX: 'hidden' }
        },
        columns: [
                    { text: 'Fecha Inicio', sortable: true, width: 105, dataIndex: 'FechaInicioAlerta', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                    { text: 'Fecha Envío', sortable: true, width: 105, dataIndex: 'FechaHoraCreacion', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                    { text: 'Local', sortable: true, width: 40, dataIndex: 'LocalDestino' },
                    { text: 'TextFechaCreacion', sortable: true, dataIndex: 'TextFechaCreacion', hidden: true },
                    { text: 'Tracto', sortable: true, dataIndex: 'PatenteTracto', hidden: true },
                    { text: 'Rampla', sortable: true, dataIndex: 'PatenteTrailer', hidden: true },
                    { text: 'Velocidad', sortable: true, dataIndex: 'Velocidad', hidden: true },
                    { text: 'Latitud', sortable: true, width: 60, dataIndex: 'Latitud', hidden: true },
                    { text: 'Longitud', sortable: true, flex: 1, dataIndex: 'Longitud', hidden: true },
                    { text: 'Descripción', sortable: true, flex: 1, dataIndex: 'DescripcionAlerta' },
                    { text: 'Puerta', sortable: true, flex: 1, dataIndex: 'Puerta1', hidden: true },
                    { text: 'Temperatura', sortable: true, flex: 1, dataIndex: 'Temp1', hidden: true }
              ],
        listeners: {
          select: function (sm, row, rec) {

            SelectDrawAlert(row);

            Ext.getCmp("gridPanelAlertasInformeViaje").getSelectionModel().deselectAll(); 
          }
        }
      });

      var panelEncabezado = new Ext.FormPanel({
        id: 'panelEncabezado',
        title: 'Informe de Viaje',
        anchor: '100%',
        layout: 'column',
        border: false,
        bodyStyle: 'padding: 5px;',
        items: [{ xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.49,
          style: {
            paddingRight: '20px'
          },
          items: [txtNroTransporte, txtTrailer, txtNombreCliente, txtNombreOrigen, txtDestinos, txtTransportista]
        },
                { xtype: 'container',
                  layout: 'anchor',
                  columnWidth: 0.51,
                  items: [txtTracto, txtNroContenedor, txtConductor, txtRutConductor, txtScore]
                }
                ]
      });

      var panelObservaciones = new Ext.FormPanel({
        id: 'panelObservaciones',
        anchor: '100%',
        layout: 'column',
        hideCollapseTool: true,
        border: false,
        bodyStyle: 'padding: 5px;',
        items: [{ xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.85,
          items: [textAreaObservaciones]
        }, { xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.15,
          items: [btnGuardar]
        }
              ]
      });

      var mapImage = Ext.create('Ext.Img', {
        id: 'mapImage',
        src: 'https://maps.googleapis.com/maps/api/staticmap?center=-33.453172,-70.858681&zoom=9&size=500x300&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8',
        renderTo: Ext.getBody(),
        disabled: true
      });

      var panelMap = new Ext.FormPanel({
        layout: 'anchor',
        id: 'panelMap',
        anchor: '100% 91%',
        hideCollapseTool: true,
        border: true,
        items: [mapImage]
      });

      var panelAlertasMap = new Ext.FormPanel({
        id: 'panelAlertasMap',
        //title: 'Alertas',
        anchor: '100% 37%',
        border: false,
        layout: {
          type: 'hbox',
          align: 'stretch'
        },
        items: [{
          xtype: 'fieldset',
          title: 'Alertas',
          style: {
            marginLeft: '5px',
            marginRight: '2px'
          },
          flex: 1,
          anchor: '100% -1',
          items: [gridPanelAlertasInformeViaje]
        }, {
          xtype: 'fieldset',
          title: 'Mapa',
          style: {
            marginLeft: '2px',
            marginRight: '5px'
          },
          anchor: '100% -1',
          flex: 1,
          items: [panelMap]
        }]

      });

      var centerPanel = new Ext.FormPanel({
        id: 'centerPanel',
        region: 'center',
        border: true,
        margins: '0 3 3 0',
        anchor: '100% 100%',
        //bodyStyle: 'padding: 5px',
        items: [panelEncabezado,
                  {
                    xtype: 'fieldset',
                    title: 'Detalle de Trayecto',
                    style: {
                      marginLeft: '5px',
                      marginRight: '5px'
                    },
                    anchor: '100% 25%',
                    items: [gridPanelDetalleTrayecto]
                  },
        //gridPanelDetalleTrayecto,
                  panelAlertasMap,
                  {
                    xtype: 'fieldset',
                    title: 'Observaciones',
                    style: {
                      marginLeft: '5px',
                      marginRight: '5px'
                    },
                    anchor: '100% 12%',
                    items: [panelObservaciones]
                  }


              ]
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

        var nroTransporte = Ext.getCmp('textNroTransporte').getValue();
        var nroOS = Ext.getCmp('textFiltroOrdenServicio').getValue();
        

        if (Ext.getCmp("chkNroTransporte").getValue() == true && nroTransporte == "") {
            return;
        }

      var size = Ext.getCmp('panelMap').getWidth().toString() + 'x' + Ext.getCmp('panelMap').getHeight();

      Ext.getCmp('numberIdAlerta').reset();
      Ext.getCmp('txtNroTransporte').reset();

     
      Ext.getCmp('txtTransportista').reset();
      Ext.getCmp('txtConductor').reset();
      Ext.getCmp('txtRutConductor').reset();
      Ext.getCmp('txtScore').reset();
      Ext.getCmp('txtNombreOrigen').reset();
      Ext.getCmp('txtTracto').reset();
      Ext.getCmp('txtTrailer').reset();
      Ext.getCmp('txtNroContenedor').reset();
      Ext.getCmp('txtDestinos').reset();
      Ext.getCmp('txtNombreCliente').reset();
      Ext.getCmp('gridPanelDetalleTrayecto').store.removeAll();
      Ext.getCmp('textAreaObservaciones').reset();
      Ext.getCmp('gridPanelAlertasInformeViaje').store.removeAll();
      Ext.getCmp('mapImage').setSrc('https://maps.googleapis.com/maps/api/staticmap?center=-33.453172,-70.858681&zoom=9&size=' + size + '&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8');
      
      Ext.getCmp('txtNroTransporte').setDisabled(true);

      Ext.getCmp('txtTransportista').setDisabled(true);
      Ext.getCmp('txtConductor').setDisabled(true);
      Ext.getCmp('txtRutConductor').setDisabled(true);
      Ext.getCmp('txtScore').setDisabled(true);
      Ext.getCmp('txtNombreOrigen').setDisabled(true);
      Ext.getCmp('txtTracto').setDisabled(true);
      Ext.getCmp('txtTrailer').setDisabled(true);
      Ext.getCmp('txtNroContenedor').setDisabled(true);
      Ext.getCmp('txtDestinos').setDisabled(true);
      Ext.getCmp('txtNombreCliente').setDisabled(true);
      Ext.getCmp('gridPanelDetalleTrayecto').setDisabled(true);
      Ext.getCmp('textAreaObservaciones').setDisabled(true);
      Ext.getCmp('gridPanelAlertasInformeViaje').setDisabled(true);
      Ext.getCmp('btnExportar').setDisabled(true);
      Ext.getCmp('mapImage').setDisabled(true);
      Ext.getCmp('btnGuardar').setDisabled(true);

      if (!Ext.getCmp('leftPanel').getForm().isValid()) {
        return;
      }

      var desde = Ext.getCmp('dateDesde').getValue();
      var hasta = Ext.getCmp('dateHasta').getValue();
      var patente = Ext.getCmp('comboFiltroPatente').getValue();
      var transportista = Ext.getCmp('comboFiltroTransportista').getValue();
      var tipoEtis = Ext.getCmp('comboFiltroTipoEtis').getValue();

      var store = Ext.getCmp('gridPanelViajes').store;
      store.load({
        params: {
          desde: desde,
          hasta: hasta,
          nroTransporte: nroTransporte,
            nroOS: nroOS,
          patente: patente,
          transportista: transportista,
          tipoEtis: tipoEtis
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

    function GetAlertasInformeViaje(nroTransporte) {

      var store = Ext.getCmp('gridPanelAlertasInformeViaje').store;
      store.load({
        params: {
          nroTransporte: nroTransporte
        },
        failure: function (msg) {
          alert('Se ha producido un error.');
        }
      });
    }

    function GetDetalleTrayecto(nroTransporte) { 
    
      var store = Ext.getCmp('gridPanelDetalleTrayecto').store;
      store.load({
        params: {
          nroTransporte: nroTransporte
        },
        failure: function (msg) {
          alert('Se ha producido un error.');
        }
      });
    }

    function Exportar() {

        var nroTransporte = Ext.getCmp('txtNroTransporte').getRawValue();
        var nroOS = Ext.getCmp('textFiltroOrdenServicio').getRawValue();
        
      var transportista = Ext.getCmp('txtTransportista').getRawValue();
      var nombreOrigen = Ext.getCmp('txtNombreOrigen').getRawValue();
      var destinos = Ext.getCmp('txtDestinos').getRawValue();
      var tracto = Ext.getCmp('txtTracto').getRawValue();
      var trailer = Ext.getCmp('txtTrailer').getRawValue();
      var nroContenedor =  Ext.getCmp('txtNroContenedor').getRawValue();
      var conductor = Ext.getCmp('txtConductor').getRawValue();
      var rutConductor = Ext.getCmp('txtRutConductor').getRawValue();
      var score = Ext.getCmp('txtScore').getRawValue();
      var nombreCliente = Ext.getCmp('txtNombreCliente').getRawValue();

      var mapForm = document.createElement("form");
      mapForm.target = "ToExcel";
      mapForm.method = "POST"; // or "post" if appropriate
      mapForm.action = 'InformeViajes.aspx?Metodo=ExportPDF';

      //
      var _nroTransporte = document.createElement("input");
      _nroTransporte.type = "text";
      _nroTransporte.name = "nroTransporte";
      _nroTransporte.value = nroTransporte;
      mapForm.appendChild(_nroTransporte);

      var _nroOS = document.createElement("input");
      _nroOS.type = "text";
      _nroOS.name = "nroOS";
      _nroOS.value = nroOS;
      mapForm.appendChild(_nroOS);

      var _transportista = document.createElement("input");
      _transportista.type = "text";
      _transportista.name = "transportista";
      _transportista.value = transportista;
      mapForm.appendChild(_transportista);

      var _nombreOrigen = document.createElement("input");
      _nombreOrigen.type = "text";
      _nombreOrigen.name = "nombreOrigen";
      _nombreOrigen.value = nombreOrigen;
      mapForm.appendChild(_nombreOrigen);

      var _destinos = document.createElement("input");
      _destinos.type = "text";
      _destinos.name = "destinos";
      _destinos.value = destinos;
      mapForm.appendChild(_destinos);

      var _tracto = document.createElement("input");
      _tracto.type = "text";
      _tracto.name = "tracto";
      _tracto.value = tracto;
      mapForm.appendChild(_tracto);

      var _trailer = document.createElement("input");
      _trailer.type = "text";
      _trailer.name = "trailer";
      _trailer.value = trailer;
      mapForm.appendChild(_trailer);

      var _nroContenedor = document.createElement("input");
      _nroContenedor.type = "text";
      _nroContenedor.name = "nroContenedor";
      _nroContenedor.value = nroContenedor;
      mapForm.appendChild(_nroContenedor);

      var _conductor = document.createElement("input");
      _conductor.type = "text";
      _conductor.name = "conductor";
      _conductor.value = conductor;
      mapForm.appendChild(_conductor);

      var _rutConductor = document.createElement("input");
      _rutConductor.type = "text";
      _rutConductor.name = "rutConductor";
      _rutConductor.value = rutConductor;
      mapForm.appendChild(_rutConductor);

      var _score = document.createElement("input");
      _score.type = "text";
      _score.name = "score";
      _score.value = score;
      mapForm.appendChild(_score);

      var _nombreCliente = document.createElement("input");
      _nombreCliente.type = "text";
      _nombreCliente.name = "nombreCliente";
      _nombreCliente.value = nombreCliente;
      mapForm.appendChild(_nombreCliente);

      document.body.appendChild(mapForm);
      mapForm.submit();

    }

    function UpdateObservaciones() {

      var idAlerta = Ext.getCmp('numberIdAlerta').getValue();
      var nroTransporte = Ext.getCmp('txtNroTransporte').getRawValue();
      var observaciones = Ext.getCmp('textAreaObservaciones').getValue();

      Ext.Ajax.request({
        url: 'AjaxPages/AjaxAlertas.aspx?Metodo=UpdateObservacionesInformeViaje',
        params: {
          'idAlerta': idAlerta,
          'nroTransporte': nroTransporte,
          'observaciones': observaciones
        },
        success: function (msg, success) {
          GetAlertasInformeViaje(nroTransporte);
        },
        failure: function (msg) {
          alert('Se ha producido un error.');
        }
      });

    }

    function SelectDrawAlert(row) {

      Ext.getCmp('textAreaObservaciones').reset();
      Ext.getCmp('textAreaObservaciones').setDisabled(false);
      Ext.getCmp('mapImage').setDisabled(false);
      Ext.getCmp('btnGuardar').setDisabled(false);

      Ext.getCmp('numberIdAlerta').setValue(row.data.Id);
      Ext.getCmp('textAreaObservaciones').setValue(row.data.Observaciones);

      var polygon;
      var center = row.data.Latitud + ',' + row.data.Longitud;
      var size = Ext.getCmp('panelMap').getWidth().toString() + 'x' + Ext.getCmp('panelMap').getHeight();
      
      if (row.data.ZoneLocation != -1) {  
        polygon = '&path=color:0x000000%7Cweight:2%7Cfillcolor:0x9966FF%7C';

        Ext.Ajax.request({
          url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetAllVerticesZona',
          params: {
            IdZona: row.data.ZoneLocation
          },
          success: function (data, success) {
            if (data != null) {
              data = Ext.decode(data.responseText);
              for (var i = 0; i < data.Vertices.length; i++) {
                polygon = polygon + data.Vertices[i].Latitud.toString() + ',' + data.Vertices[i].Longitud.toString();

                if (i < data.Vertices.length - 1) {
                  polygon = polygon + '%7C';
                }
              }

              var stringUrlMap = 'https://maps.googleapis.com/maps/api/staticmap?zoom=13&maptype=roadmap&size=' + size + '&markers=color:red%7C' + center + '&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8' + polygon;
              Ext.getCmp('mapImage').setSrc(stringUrlMap);
            }
          }
        });

      }
      else {
        polygon = '';
      }
      
      var stringUrlMap = 'https://maps.googleapis.com/maps/api/staticmap?zoom=13&maptype=roadmap&center=' + center + '&size=' + size + '&markers=color:red%7C' + center + '&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8';

      Ext.getCmp('mapImage').setSrc(stringUrlMap);
    
    }

  </script>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
  <div id="dvMap"></div>
</asp:Content>
