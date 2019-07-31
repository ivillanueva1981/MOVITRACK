<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Soporte.MisTicket.aspx.cs" Inherits="Track_Web.Soporte_MisTicket" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
  AltoTrack Platform
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <script src="Scripts/TopMenu.js" type="text/javascript"></script>
  <style type="text/css">
    .background .x-panel-body {
      background-image: url('Images/background_transparent_1366x768.png') !important;
      background-size: 100% 100%;
      width: 100%;
      height: 100%;
    }

    .back .x-panel-body {
      background-color: white;
      background-size: cover;
    }

    .background2 .x-panel-body {
      background-image: url('') !important;
    }
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

      //Ext.Ajax.request({
      //  url: 'AjaxPages/Ajaxlogin.aspx?Metodo=getTopMenu',
      //  success: function (data, success) {
      //    if (data != null) {
      //      data = Ext.decode(data.responseText);
      //      var i;
      //      for (i = 0; i < data.length; i++) {
      //        if (data[i].MenuPadre == 0) {
      //          toolbarMenu.items.get(data[i].IdJavaScript).show();
      //          toolbarMenu.items.get(data[i].IdPipeLine).show();
      //        }
      //        else {
      //          var listmenu = Ext.getCmp(data[i].JsPadre).menu;
      //          listmenu.items.get(data[i].IdJavaScript).show();
      //        }
      //      }
      //    }
      //  }
      //});

      var viewWidth = Ext.getBody().getViewSize().width;
      var viewHeight = Ext.getBody().getViewSize().height;


      var storeFiltroAplicacion = new Ext.data.JsonStore({
        fields: ['Texto', 'Valor'],
        data: []
      });

      var comboFiltroEstado = new Ext.form.field.ComboBox({
        id: 'comboFiltroEstado',
        fieldLabel: 'Estado',
        store: storeFiltroAplicacion,
        valueField: 'Valor',
        displayField: 'Texto',
        queryMode: 'local',
        anchor: '99%',
        labelWidth: 60,
        editable: false,
        style: {
          marginTop: '5px',
          marginLeft: '10px'
        },
        emptyText: 'Seleccione...',
        enableKeyEvents: true,
        forceSelection: true,
        allowBlank: false
      });

      var textNroTicket = new Ext.form.TextField({
        id: 'textNroTicket',
        fieldLabel: 'Nro. Ticket',
        anchor: '99%',
        readOnly: true,
        labelWidth: 60,
        maxLength: 100,
        style: {
          marginTop: '7px',
          marginLeft: '100px'
        }
      });

      var textBusqueda = new Ext.form.TextField({
        id: 'textBusqueda',
        fieldLabel: 'Texto de búsqueda',
        anchor: '99%',
        readOnly: true,
        labelWidth: 120,
        maxLength: 100,
        style: {
          marginTop: '7px',
          marginLeft: '100px'
        }
      });

      var btnBuscar = {
        id: 'btnBuscar',
        xtype: 'button',
        iconAlign: 'left',
        //icon: 'Images/save_black_20x20.png',
        text: 'Buscar',
        width: 80,
        height: 26,
        handler: function () {
          bucarTickets();
        },
        style: {
          marginTop: '5px',
          marginLeft: '10px'
        }
      };


      var toolbarPanel = Ext.create('Ext.toolbar.Toolbar', {
        id: 'toolbarPanel',
        height: 40,
        layout: 'column',
        items: [{
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.2,
          items: [textNroTicket]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [textBusqueda]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.2,
          items: [comboFiltroEstado]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [btnBuscar]
        }]
      });

      var storeViajesControlPanel = new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['IdTicket',
                'FechaHoraTicket',
                'OrigenTicket',
                'MotivoTicket',
                'Aplicacion',
                'Modulo',
                'Observacion',
                'Estado',
                'FechaHoraCreacion',
                "ResultadoGestion",
                "FechaHoraTicketOrden"
        ]
      });

      var gridPanelViajesControlPanel = Ext.create('Ext.grid.Panel', {
        id: 'gridPanelViajesControlPanel',
        title: 'Listado Mis tickets',
        store: storeViajesControlPanel,
        tbar: toolbarPanel,
        anchor: '100% 100%',
        columnLines: true,
        scroll: false,
        viewConfig: {
          style: { overflow: 'auto', overflowX: 'hidden' },
          enableTextSelection: true
        },
        columns: [
                    { text: "Nro. Ticket", dataIndex: 'IdTicket', sortable: true, width: 120, align: 'center', },
                    { text: 'Fecha Ticket', sortable: true, width: 250, dataIndex: 'FechaHoraTicket' },
                    { text: 'Origen Ticket', sortable: true, width: 150, dataIndex: 'OrigenTicket' },
                    { text: 'Aplicacion', sortable: true, flex: 1, dataIndex: 'Aplicacion' },
                    { text: 'Modulo', sortable: true, flex: 1, dataIndex: 'Modulo' },
                    { text: 'Motivo', sortable: true, flex: 1, dataIndex: 'MotivoTicket' },
                    { text: 'Estado', sortable: true, flex: 1, dataIndex: 'Estado' },
  {
    xtype: 'actioncolumn',
    width: 24,
    items: [{
      icon: 'Images/edit_black_20x20.png',
      tooltip: 'Editar.',
      handler: function (grid, rowIndex, colIndex) {
        var row = grid.getStore().getAt(rowIndex);

        editar(row);

      }
    }]
  }
        ]

      });

      var centerPanel = new Ext.FormPanel({
        id: 'centerPanel',
        region: 'center',
        border: true,
        anchor: '100% 100%',
        items: [gridPanelViajesControlPanel]
      });

      var viewport = Ext.create('Ext.container.Viewport', {
        layout: 'border',
        items: [topMenu, centerPanel]
      });

    });

  </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">

  <script type="text/javascript">

    Ext.onReady(function () {
      Ext.Ajax.request({
        url: 'AjaxPages/Ajaxlogin.aspx?Metodo=getInfoUsuario',
        success: function (data, success) {
          if (data != null) {
            data = Ext.decode(data.responseText);
            var nombre = data.Nombre;
            var Correo = data.Correo;
            var fono = data.Fono;
            var idUsuarioAlto = data.IdAltoTrack

            dataJSON = {
              oParametros: {
                Filtro: -1
              }
            };

            var Url = data.UrlTicket;

            var json = JSON.stringify(dataJSON);

            Ext.Ajax.request({
              url: Url + "/ObtenerEstados",
              type: "post",
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              jsonData: json,
              success: function (data, success) {
                if (data != null) {
                  data = Ext.decode(data.responseText);
                  cargaCombo(data.d.ListadoEstados, 'comboFiltroEstado')

                }
              }
            });

          }
        }
      });
    });

    function cargaCombo(lista, control) {
      var i = 0;
      var _store = Ext.getCmp(control).store;
      for (i = 0; i < lista.length; i++) {
        var valor = lista[i].Valor;
        var texto = lista[i].Texto;
        _store.insert(i, { Texto: texto, Valor: valor });
      }
      _store.insert(0, { Texto: "Todos", Valor: -1 });
      Ext.getCmp(control).setValue(-1);
    }

    function bucarTickets() {
      Ext.Ajax.request({
        url: 'AjaxPages/Ajaxlogin.aspx?Metodo=getInfoUsuario',
        success: function (data, success) {
          if (data != null) {
            data = Ext.decode(data.responseText);
            var nombre = data.Nombre;
            var Correo = data.Correo;
            var fono = data.Fono;
            var idUsuarioAlto = data.IdAltoTrack

            dataJSON = {
              oParametros: {
                LlaveFormato: data.LlaveFormato,
                LlavePerfil: data.LlavePerfil,
                IdUsuario: idUsuarioAlto,
                IdTicket: -1,
                Texto: -1,
                Estado: -1
              }
            };

            var Url = data.UrlTicket;
            var json = JSON.stringify(dataJSON);

            Ext.Ajax.request({
              url: Url + "/ObtenerMisTicket",
              type: "post",
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              jsonData: json,
              success: function (data, success) {
                if (data != null) {
                  data = Ext.decode(data.responseText);
                  cargaGrilla(data.d.ListadoMisTicket)
                }
              }
            });

          }
        }
      });
    }

    function cargaGrilla(lista) {
      var i = 0;

      if (lista != null) {
        var _store = Ext.getCmp('gridPanelViajesControlPanel').store;
        for (i = 0; i < lista.length; i++) {

          var IdTicket = lista[i].IdTicket;
          var FechaHoraTicket = lista[i].FechaHoraTicket;
          var OrigenTicket = lista[i].OrigenTicket;
          var MotivoTicket = lista[i].MotivoTicket;
          var Aplicacion = lista[i].Aplicacion;
          var Modulo = lista[i].Modulo;
          var Observacion = lista[i].Observacion;
          var Estado = lista[i].Estado;
          var FechaHoraCreacion = lista[i].FechaHoraCreacion;
          var ResultadoGestion = lista[i].ResultadoGestion;
          var FechaHoraTicketOrden = lista[i].FechaHoraTicketOrden;

          _store.insert(i, { IdTicket: IdTicket, FechaHoraTicket: FechaHoraTicket, OrigenTicket: OrigenTicket, MotivoTicket: MotivoTicket, Aplicacion: Aplicacion, Modulo: Modulo, Observacion: Observacion, Estado: Estado, FechaHoraCreacion: FechaHoraCreacion, ResultadoGestion: ResultadoGestion, FechaHoraTicketOrden: FechaHoraTicketOrden });
        }
      }

    }
  </script>
</asp:Content>
