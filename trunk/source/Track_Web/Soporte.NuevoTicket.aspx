<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Soporte.NuevoTicket.aspx.cs" Inherits="Track_Web.Soporte_NuevoTicket" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
  AltoTrack Platform
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8" type="text/javascript"></script>
  <script src="Scripts/MapFunctions.js" type="text/javascript"></script>
  <script src="Scripts/TopMenu.js" type="text/javascript"></script>
  <script src="Scripts/LabelMarker.js" type="text/javascript"></script>
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

      var txtNombre = new Ext.form.TextField({
        id: 'txtNombre',
        fieldLabel: 'Nombre',
        labelWidth: 60,
        readOnly: true,
        anchor: '99%',
        disabled: false,
        style: {
          marginLeft: '20px'
        }
      });

      var txtFono = new Ext.form.TextField({
        id: 'txtFono',
        fieldLabel: 'Teléfono',
        labelWidth: 60,
        readOnly: true,
        anchor: '99%',
        disabled: false,
        style: {
          marginLeft: '20px'
        }
      });

      var txtMail = new Ext.form.TextField({
        id: 'txtMail',
        fieldLabel: 'Email',
        labelWidth: 60,
        readOnly: true,
        anchor: '99%',
        disabled: false,
        style: {
          marginLeft: '20px'
        }
      });

      var storeFiltroAplicacion = new Ext.data.JsonStore({
        fields: ['Texto', 'Valor'],
        data: []
      });

      var comboFiltroAplicacion = new Ext.form.field.ComboBox({
        id: 'comboFiltroAplicacion',
        fieldLabel: 'Aplicación',
        store: storeFiltroAplicacion,
        valueField: 'Valor',
        displayField: 'Texto',
        queryMode: 'local',
        anchor: '99%',
        labelWidth: 120,
        editable: false,
        style: {
          marginLeft: '5px'
        },
        emptyText: 'Seleccione...',
        enableKeyEvents: true,
        forceSelection: true,
        allowBlank: false,
        listeners: {
          change: function (field, newVal) {
            if (newVal != null) {
              if (newVal == 'Otro') {
                Ext.getCmp('TxtOtraAplicacion').setVisible(true);
              }
              else {
                Ext.getCmp('TxtOtraAplicacion').setVisible(false);
              }
            }
          }
        }
      });

      var storeFiltroModulo = new Ext.data.JsonStore({
        fields: ['Texto', 'Valor'],
        data: []
      });

      var TxtOtraAplicacion = new Ext.form.TextField({
        id: 'TxtOtraAplicacion',
        fieldLabel: 'Otra Aplicación',
        hidden: true,
        labelWidth: 120,
        anchor: '99%',
        disabled: false,
        style: {
          marginLeft: '5px'
        }
      });

      var comboFiltroModulo = new Ext.form.field.ComboBox({
        id: 'comboFiltroModulo',
        fieldLabel: 'Módulo',
        store: storeFiltroModulo,
        valueField: 'Valor',
        displayField: 'Texto',
        queryMode: 'local',
        anchor: '99%',
        labelWidth: 120,
        editable: false,
        style: {
          marginLeft: '5px'
        },
        emptyText: 'Seleccione...',
        enableKeyEvents: true,
        forceSelection: true,
        allowBlank: false,
        listeners: {
          change: function (field, newVal) {
            if (newVal != null) {
              if (newVal == 'Otro') {
                Ext.getCmp('TxtOtroModulo').setVisible(true);
              }
              else {
                Ext.getCmp('TxtOtroModulo').setVisible(false);
              }
            }
          }
        }
      });

      var TxtOtroModulo = new Ext.form.TextField({
        id: 'TxtOtroModulo',
        fieldLabel: 'Otro Módulo',
        hidden: true,
        labelWidth: 120,
        anchor: '99%',
        disabled: false,
        style: {
          marginLeft: '5px'
        }
      });

      var storeFiltrMotivo = new Ext.data.JsonStore({
        fields: ['Texto', 'Valor'],
        data: []
      });

      var comboFiltroMotivo = new Ext.form.field.ComboBox({
        id: 'comboFiltroMotivo',
        fieldLabel: 'Motivo',
        store: storeFiltrMotivo,
        valueField: 'Valor',
        displayField: 'Texto',
        queryMode: 'local',
        anchor: '99%',
        labelWidth: 120,
        editable: false,
        style: {
          marginLeft: '5px'
        },
        emptyText: 'Seleccione...',
        enableKeyEvents: true,
        forceSelection: true,
        allowBlank: false,
        listeners: {
          change: function (field, newVal) {
            if (newVal != null) {
              if (newVal == 'Otro') {
                Ext.getCmp('TxtOtroMotivo').setVisible(true);
              }
              else {
                Ext.getCmp('TxtOtroMotivo').setVisible(false);
              }
            }
          }
        }
      });

      var TxtOtroMotivo = new Ext.form.TextField({
        id: 'TxtOtroMotivo',
        fieldLabel: 'Otro Motivo',
        hidden: true,
        labelWidth: 120,
        anchor: '99%',
        disabled: false,
        style: {
          marginLeft: '5px'
        }
      });

      var displayObs = new Ext.form.field.Display({
        id: 'displayObs',
        fieldLabel: 'Observaciones',
        labelWidth: 150,
        width: 300,
        style: {
          marginTop: '4px',
          marginLeft: '5px'
        }
      });

      var textAreaObservaciones = new Ext.form.field.TextArea({
        id: 'textAreaObservaciones',
        disabled: false,
        anchor: '100%',
        height: 100,
        maxLength: 500,
        allowBlank: false
      });

      var btnGrabar = {
        id: 'btnGrabar',
        xtype: 'button',
        iconAlign: 'left',
        icon: 'Images/save_black_20x20.png',
        text: 'Grabar',
        width: 100,
        height: 26,
        formBind: true,
        handler: function () {
          grabarNuevoTicket();
        },
        style: {
          marginTop: '3px',
          marginLeft: '80px'
        }
      };

      var panelEncabezado = new Ext.FormPanel({
        id: 'panelEncabezado',
        anchor: '100%',
        height: 120,
        border: false,
        bodyStyle: 'padding: 5px;',
        layout: 'anchor',
        items: [{
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [txtNombre]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [txtFono]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [txtMail]
        }]
      });

      var panelAplicacion = new Ext.FormPanel({
        id: 'panelAplicacion',
        anchor: '100%',
        border: false,
        bodyStyle: 'padding: 5px;',
        layout: 'anchor',
        height: 350,
        items: [{
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [comboFiltroAplicacion]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [TxtOtraAplicacion]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [comboFiltroModulo]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [TxtOtroModulo]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [comboFiltroMotivo]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [TxtOtroMotivo]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [displayObs]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.3,
          items: [textAreaObservaciones]
        }],
        buttons: [btnGrabar]
      });

      var panelTicket = new Ext.FormPanel({
        id: 'panelTicket',
        title: 'Enviar Ticket',
        cls: 'background2',
        width: 600,
        height: 550,
        items: [{
          xtype: 'fieldset',
          title: 'Datos Personales',
          style: {
            marginLeft: '2px',
            marginRight: '5px'
          },
          anchor: '100%',
          flex: 1,
          items: [panelEncabezado]
        }, {
          xtype: 'fieldset',
          title: 'Datos del Ticket',
          style: {
            marginLeft: '2px',
            marginRight: '5px'
          },
          anchor: '100%',
          flex: 1,
          items: [panelAplicacion]
        }]
      });

      var fullPanel = new Ext.FormPanel({
        id: 'fullPanel',
        frame: true,
        anchor: '100% 100%',
        renderTo: Ext.getBody(),        
        cls: 'background',
        style: {
          //backgroundImage: 'url(\'Images/background_color_1366x768.jpg\') !important',
          backgroundImage: 'url(\'Images/background_transparent_1366x768.png\') !important',
          border: '0px'
        },
        layout: {
          type: 'vbox',
          align: 'center',
          pack: 'center'
        },
        items: [panelTicket]
      });

      var centerPanel = new Ext.FormPanel({
        id: 'centerPanel',
        region: 'center',
        border: true,
      //  margins: '0 3 3 0',
        margins: '0 5 0 0',
        anchor: '100% 100%',        
        items: [fullPanel]
      });

      var viewport = Ext.create('Ext.container.Viewport', {
        layout: 'border',
        items: [topMenu, centerPanel]
      });

    });

  </script>

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

            Ext.getCmp('txtNombre').setValue(nombre);
            Ext.getCmp('txtMail').setValue(Correo);
            Ext.getCmp('txtFono').setValue(fono);

            dataJSON = {
              oParametros: {
                LlaveFormato: data.LlaveFormato,
                LlavePerfil: data.LlavePerfil,
                MostrarOtro: true
              }
            };

            var Url = data.UrlTicket;
            var json = JSON.stringify(dataJSON);

            Ext.Ajax.request({
              url: Url + "/ObtenerMotivosTicket",
              type: "post",
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              jsonData: json,
              success: function (data, success) {
                if (data != null) {
                  data = Ext.decode(data.responseText);
                  cargaCombo(data.d.ListadoMotivoTicket, 'comboFiltroMotivo')
                }

                Ext.Ajax.request({
                  url: Url + "/ObtenerAplicaciones",
                  type: "post",
                  contentType: "application/json; charset=utf-8",
                  dataType: "json",
                  jsonData: json,
                  success: function (data, success) {
                    if (data != null) {
                      data = Ext.decode(data.responseText);
                      cargaCombo(data.d.ListadoAplicaciones, 'comboFiltroAplicacion')
                    }
                    Ext.Ajax.request({
                      url: Url + "/ObtenerModulos",
                      type: "post",
                      contentType: "application/json; charset=utf-8",
                      dataType: "json",
                      jsonData: json,
                      success: function (data, success) {
                        if (data != null) {
                          data = Ext.decode(data.responseText);
                          cargaCombo(data.d.ListadoModulos, 'comboFiltroModulo')
                        }
                      }
                    });
                  }
                });
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
    }

    function grabarNuevoTicket() {
      Ext.Ajax.request({
        url: 'AjaxPages/Ajaxlogin.aspx?Metodo=getInfoUsuario',
        success: function (data, success) {
          if (data != null) {
            data = Ext.decode(data.responseText);
            var Url = data.UrlTicket;

            dataJSON = {
              oNuevoTicket: {
                LlaveFormato: data.LlaveFormato,
                EnviadoDesde: data.EnviadoDesde,
                Fecha: "",
                Hora: "",
                NombreLocal: "",
                CodigoLocal: "-1",
                NombrePersona: Ext.getCmp('txtNombre').getValue(),
                Cargo: "Genérico",
                Telefono: Ext.getCmp('txtFono').getValue(),
                Email: Ext.getCmp('txtMail').getValue(),
                OrigenTicket: data.OrigenTicket,
                MotivoTicket: Ext.getCmp('comboFiltroMotivo').getValue(),
                Aplicacion: Ext.getCmp('comboFiltroAplicacion').getValue(),
                Modulo: Ext.getCmp('comboFiltroModulo').getValue(),
                Observacion: Ext.getCmp('textAreaObservaciones').getValue(),
                MotivoTicketOtro: Ext.getCmp('TxtOtroMotivo').getValue(),
                AplicacionOtro: Ext.getCmp('TxtOtraAplicacion').getValue(),
                ModuloOtro: Ext.getCmp('TxtOtroModulo').getValue(),
                IdUsuarioGestionTicket: -1,
                IdUsuarioTicket: data.IdAltoTrack
              }
            };
            var json = JSON.stringify(dataJSON);

            Ext.Ajax.request({
              url: Url + "/GrabarNuevoTicket",
              type: "post",
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              jsonData: json,
              success: function (data, success) {
                if (data != null) {
                  data = Ext.decode(data.responseText);
                  limpiarFormulario();
                  var msg = data.d.Respuesta.Descripcion;
                  Ext.MessageBox.alert('Status', msg);                  
                }
              }
            });
          }
        }
      });
    }

    function limpiarFormulario() {
      Ext.getCmp('comboFiltroMotivo').reset();
      Ext.getCmp('comboFiltroAplicacion').reset();
      Ext.getCmp('comboFiltroModulo').reset();
      Ext.getCmp('textAreaObservaciones').reset();
      Ext.getCmp('TxtOtroMotivo').reset();
      Ext.getCmp('TxtOtroMotivo').setVisible(false);
      Ext.getCmp('TxtOtraAplicacion').reset();
      Ext.getCmp('TxtOtraAplicacion').setVisible(false)
      Ext.getCmp('TxtOtroModulo').reset();
      Ext.getCmp('TxtOtroModulo').setVisible(false)
    }

    function showResult(btn) {
      Ext.example.msg('Button Click', 'You clicked the {0} button', btn);
    }

    function showResultText(btn, text) {
      Ext.example.msg('Button Click', 'You clicked the {0} button and entered the text "{1}".', btn, text);
    }
  </script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
</asp:Content>
