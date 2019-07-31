<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Rpt_GuiasDespacho.aspx.cs" Inherits="Track_Web.Rpt_GuiasDespacho" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
AltoTrack Platform 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

  <script src="Scripts/TopMenu.js" type="text/javascript"></script>
  <script src="Scripts/RowExpander.js" type="text/javascript"></script>

<script type="text/javascript">

    Ext.onReady(function () {

        Ext.QuickTips.init();
        Ext.Ajax.timeout = 600000;
        Ext.override(Ext.form.Basic, { timeout: Ext.Ajax.timeout / 1000 });
        Ext.override(Ext.data.proxy.Server, { timeout: Ext.Ajax.timeout });
        Ext.override(Ext.data.Connection, { timeout: Ext.Ajax.timeout });

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
            labelWidth: 70,
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
            labelWidth: 70,
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

        var textFiltroNroTransporte = new Ext.form.TextField({
            id: 'textFiltroNroTransporte',
            fieldLabel: 'Guía Desp.',
            labelWidth: 70,
            allowBlank: true,
            anchor: '99%',
            maxLength: 20,
            style: {
                marginLeft: '5px'
            }
        });

        var textFiltroOrdenServicio = new Ext.form.TextField({
            id: 'textFiltroOrdenServicio',
            fieldLabel: 'OS',
            labelWidth: 70,
            allowBlank: true,
            anchor: '99%',
            maxLength: 20,
            style: {
                marginLeft: '5px'
            }
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
            listeners: {
                click: {
                    element: 'el',
                    fn: function () {

                        var desde = Ext.getCmp('dateDesde').getRawValue();
                        var hasta = Ext.getCmp('dateHasta').getRawValue();
                        var nroTransporte = Ext.getCmp('textFiltroNroTransporte').getRawValue();
                        var nroOS = Ext.getCmp('textFiltroOrdenServicio').getRawValue();
                      
                        var mapForm = document.createElement("form");
                        mapForm.target = "ToExcel";
                        mapForm.method = "POST"; // or "post" if appropriate
                        mapForm.action = 'Rpt_GuiasDespacho.aspx?Metodo=ExportExcel';

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
                items: [textFiltroNroTransporte]
            }, {
                xtype: 'container',
                layout: 'anchor',
                columnWidth: 1,
                items: [textFiltroOrdenServicio]
            }],
            buttons: [btnExportar, btnBuscar]
        });

        var storeGuiasDespacho = new Ext.data.JsonStore({
            autoLoad: false,
            fields: ['IdGuia',
                      'NumeroGuiaDespacho',
                      'NumeroOrdenServicio',
                      'NumeroLineaMO',
                      'VersionMO',
                      'Patente',
                      { name: 'FechaHoraPresentacion', type: 'date', dateFormat: 'c' },
                      { name: 'FechaCreacion', type: 'date', dateFormat: 'c' },
                      'UsuarioGuia',
                      'UsuarioMO',
                      'ETIS',
                      'TipoMO',
                      'EstadoRuta',
                      'EstadoMO',
                      'EstadoMovil',
                      'EstadoViaje'

            ],
            proxy: new Ext.data.HttpProxy({
                url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetRpt_GuiasDespacho',
                reader: { type: 'json', root: 'Zonas' },
                headers: {
                    'Content-type': 'application/json'
                }
            })
        });
        /*
        var storeDetalleMO = new Ext.data.JsonStore({
            autoLoad: false,
            fields: ['Id',
                      'NumeroGuiaDespacho',
            ],
            proxy: new Ext.data.HttpProxy({
                url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetRpt_DetalleMO',
                reader: { type: 'json', root: 'Zonas' },
                headers: {
                    'Content-type': 'application/json'
                }
            })
        });

        var gridPanelDetalleMO = Ext.create('Ext.grid.Panel', {
            id: 'gridPanelDetalleMO',
            title: 'Detalle MO',
            store: storeDetalleMO,
            anchor: '100% 100%',
            columnLines: true,
            scroll: false,
            viewConfig: {
                style: { overflow: 'auto', overflowX: 'hidden' }
            },
            columns: [
                        { text: 'Test', sortable: true, width: 90, dataIndex: 'test' },
            ]

        });
        */
        var gridPanelGuiasDespacho = Ext.create('Ext.grid.Panel', {
            id: 'gridPanelGuiasDespacho',
            title: 'Guías de Despacho (ETIS - EPORTIS)',
            store: storeGuiasDespacho,
            anchor: '100% 100%',
            columnLines: true,
            scroll: false,
            viewConfig: {
                style: { overflow: 'auto', overflowX: 'hidden' }
            },
            columns: [
                        { text: 'GD', sortable: true, width: 60, dataIndex: 'NumeroGuiaDespacho' },
                        { text: 'Nro. OS', sortable: true, width: 60, dataIndex: 'NumeroOrdenServicio' },
                        { text: 'Línea', sortable: true, width: 45, dataIndex: 'NumeroLineaMO' },
                        { text: 'Vers.', sortable: true, width: 40, dataIndex: 'VersionMO' },
                        { text: 'Patente', sortable: true, width: 60, dataIndex: 'Patente' },
                        { text: 'Fecha Presentacion', sortable: true, width: 110, dataIndex: 'FechaHoraPresentacion', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                        { text: 'Fecha Creación', sortable: true, width: 110, dataIndex: 'FechaCreacion', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                        { text: 'Usuario Guia', sortable: true, flex: 1, dataIndex: 'UsuarioGuia' },
                        { text: 'Usuario MO', sortable: true, flex: 1, dataIndex: 'UsuarioMO' },
                        { text: 'ETIS', sortable: true, flex: 1, dataIndex: 'ETIS' },
                        { text: 'Tipo MO', sortable: true, width: 55, dataIndex: 'TipoMO' },
                        { text: 'Estado Ruta', sortable: true, width: 95, dataIndex: 'EstadoRuta', renderer: renderEstado },
                        { text: 'Estado MO', sortable: true, width: 95, dataIndex: 'EstadoMO', renderer: renderEstado },
                        { text: 'Estado Movil', sortable: true, width: 95, dataIndex: 'EstadoMovil', renderer: renderEstado },
                        { text: 'Estado Viaje', sortable: true, width: 95, dataIndex: 'EstadoViaje', renderer: renderEstado }
            ]

        });

        var leftPanel = new Ext.FormPanel({
            id: 'leftPanel',
            region: 'west',
            border: true,
            margins: '0 0 3 3',
            width: 200,
            minWidth: 200,
            maxWidth: 300,
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
            items: [gridPanelGuiasDespacho]
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

    var desde = Ext.getCmp('dateDesde').getValue();
    var hasta = Ext.getCmp('dateHasta').getValue();
    var nroTransporte = Ext.getCmp('textFiltroNroTransporte').getValue();
    var nroOS = Ext.getCmp('textFiltroOrdenServicio').getValue();
    

    var store = Ext.getCmp('gridPanelGuiasDespacho').store;
      store.load({
        params: {
          desde: desde,
          hasta: hasta,
          nroTransporte: nroTransporte,
            nroOS: nroOS
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

  var renderEstado = function (value, meta) {

      switch (value) {
          case "Integrado":
              meta.tdCls = 'green-cell';
              return value;
              break;
          case "MO recibido":
              meta.tdCls = 'green-cell';
              return value;
              break;
          case "Ruta OK":
              meta.tdCls = 'green-cell';
              return value;
              break;
          default:
              meta.tdCls = 'red-cell';
              return value;
              break;
      }

  };

</script>


</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
  <div id="dvMap"></div>
</asp:Content>
