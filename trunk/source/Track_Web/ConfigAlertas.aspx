<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ConfigAlertas.aspx.cs" Inherits="Track_Web.ConfigAlertas" %>
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

      var storeTipoAlertas = new Ext.data.JsonStore({
        autoLoad: true,
        fields: ['IdTipoAlerta',
                'NombreTipoAlerta',
                'AlertaActiva',
                'DescripcionAlerta',
                'Control1',
                'Control2',
                'Control3',
                'Control4',
                'Valor1',
                'InfoAlerta'],
        proxy: new Ext.data.HttpProxy({
          url: 'AjaxPages/AjaxAlertas.aspx?Metodo=GetTipoAlertas',
          reader: { type: 'json', root: 'Zonas' },
          headers: {
            'Content-type': 'application/json'
          }
        })
      });

      var gridPanelTipoAlertas = Ext.create('Ext.grid.Panel', {
        id: 'gridPanelTipoAlertas',
        store: storeTipoAlertas,
        anchor: '100% 75%',
        columnLines: true,
        scroll: false,
        viewConfig: {
          style: { overflow: 'auto', overflowX: 'hidden' }
        },
        columns: [
                    { text: 'Id', width: 55, sortable: true, dataIndex: 'IdTipoAlerta', hidden: true },
                    { text: 'Tipo Alerta', width: 170, sortable: true, dataIndex: 'NombreTipoAlerta' },
                    { text: 'AlertaActiva', flex: 1, sortable: true, dataIndex: 'AlertaActiva', hidden: true },
                    { text: 'Nombre', flex: 1, sortable: true, dataIndex: 'DescripcionAlerta' },
                    { text: 'Control 1', flex: 1, sortable: true, dataIndex: 'Control1', hidden: true },
                    { text: 'Control 2', flex: 1, sortable: true, dataIndex: 'Control2', hidden: true },
                    { text: 'Control 3', flex: 1, sortable: true, dataIndex: 'Control3', hidden: true },
                    { text: 'Control 4', flex: 1, sortable: true, dataIndex: 'Control4', hidden: true }
                ],
        listeners: {
          select: function (sm, row, rec) {

            txtIdAlerta.setDisabled(false);
            txtNombreTipoAlerta.setDisabled(false);
            txtNombreAlerta.setDisabled(false);
            numberControl1.setDisabled(false);
            numberControl2.setDisabled(false);
            numberControl3.setDisabled(false);
            numberControl4.setDisabled(false);
            chkAlertaActiva.setDisabled(false);
            Ext.getCmp('btnGuardar').setDisabled(false);
            //btnGuardar.setDisabled(false);

            if (row.data.IdTipoAlerta == 20) {
              Ext.getCmp('numberVelocidad').setDisabled(false);
              Ext.getCmp('numberVelocidad').show();
            }
            else {
              Ext.getCmp('numberVelocidad').setDisabled(true);
              Ext.getCmp('numberVelocidad').hide();
            }

            var control1 = row.data.Control1;
            var control2 = row.data.Control2;
            var control3 = row.data.Control3;
            var control4 = row.data.Control4;
            var velocidad = row.data.Valor1;

            
            Ext.getCmp('textAreaDescripcion').setValue(row.data.InfoAlerta)
            Ext.getCmp('txtIdAlerta').setValue(row.data.IdTipoAlerta);
            Ext.getCmp('txtNombreTipoAlerta').setValue(row.data.NombreTipoAlerta);
            Ext.getCmp('txtNombreAlerta').setValue(row.data.DescripcionAlerta);
            Ext.getCmp('numberControl1').setValue(control1);
            Ext.getCmp('numberControl2').setValue(control1 + control2);
            Ext.getCmp('numberControl3').setValue(control1 + control2 + control3);
            Ext.getCmp('numberControl4').setValue(control4);
            Ext.getCmp('numberVelocidad').setValue(velocidad);
            Ext.getCmp('chkAlertaActiva').setValue(row.data.AlertaActiva);
            

            if (control1 == 0) {
              Ext.getCmp('numberControl1').setDisabled(true)
            }

            if (control2 == 0) {
              Ext.getCmp('numberControl2').setDisabled(true)
            }

            if (control3 == 0) {
              Ext.getCmp('numberControl3').setDisabled(true)
            }

            if (control4 == 0) {
              Ext.getCmp('numberControl4').setDisabled(true)
            }

          }
        }
      });

      
      var textAreaDescripcion = new Ext.form.field.TextArea({
        id: 'textAreaDescripcion',
        anchor: '100% 100%',
        readOnly: true
      });
      
      var panelInfoAlerta = new Ext.FormPanel({
        id: 'panelInfoAlerta',
        title: 'Descripción',
        anchor: '100% 25%',
        layout: 'anchor',
        border: false,
        bodyStyle: 'padding: 5px;',
        items: textAreaDescripcion
      });

      var txtIdAlerta = new Ext.form.TextField({
        id: 'txtIdAlerta',
        fieldLabel: 'Id Alerta',
        labelWidth: 120,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var txtNombreTipoAlerta = new Ext.form.TextField({
        id: 'txtNombreTipoAlerta',
        fieldLabel: 'Tipo Alerta',
        labelWidth: 120,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var txtNombreAlerta = new Ext.form.TextField({
        id: 'txtNombreAlerta',
        fieldLabel: 'Nombre Alerta',
        labelWidth: 120,
        readOnly: true,
        anchor: '99%',
        disabled: true
      });

      var numberControl1 = new Ext.form.NumberField({
        fieldLabel: 'Control 1',
        id: 'numberControl1',
        allowBlank: false,
        labelWidth: 120,
        anchor: '99%',
        minValue: 0,
        maxValue: 360,
        enableKeyEvents: true,
        disabled: true
      });


      numberControl1.on('change', function () {
        var _cont1 = Ext.getCmp('numberControl1');
        var _cont2 = Ext.getCmp('numberControl2');

        _cont2.setMinValue(_cont1.getValue());
        _cont2.validate();
      });


      var numberControl2 = new Ext.form.NumberField({
        fieldLabel: 'Control 2',
        id: 'numberControl2',
        allowBlank: false,
        labelWidth: 120,
        anchor: '99%',
        minValue: 0,
        maxValue: 360,
        enableKeyEvents: true,
        disabled: true
      });

      numberControl2.on('change', function () {
        var _cont2 = Ext.getCmp('numberControl2');
        var _cont3 = Ext.getCmp('numberControl3');

        _cont3.setMinValue(_cont2.getValue());
        _cont3.validate();
      });

      var numberControl3 = new Ext.form.NumberField({
        fieldLabel: 'Control 3',
        id: 'numberControl3',
        allowBlank: false,
        labelWidth: 120,
        anchor: '99%',
        minValue: 0,
        maxValue: 360,
        enableKeyEvents: true,
        disabled: true
      });

      var numberControl4 = new Ext.form.NumberField({
        fieldLabel: 'Control 4',
        id: 'numberControl4',
        allowBlank: false,
        labelWidth: 120,
        anchor: '99%',
        minValue: 0,
        maxValue: 360,
        enableKeyEvents: true,
        disabled: true
      });

      var chkAlertaActiva = new Ext.form.field.Checkbox({
        id: 'chkAlertaActiva',
        fieldLabel: 'Alerta Activa',
        labelWidth: 120,
        disabled: true
      });

      var numberVelocidad = new Ext.form.NumberField({
        fieldLabel: 'Velocidad límite',
        id: 'numberVelocidad',
        allowBlank: false,
        labelWidth: 120,
        anchor: '99%',
        minValue: 1,
        maxValue: 150,
        enableKeyEvents: true,
        disabled: true,
        hidden: true
      });

      var btnGuardar = {
        id: 'btnGuardar',
        xtype: 'button',
        iconAlign: 'left',
        icon: 'Images/save_black_20x20.png',
        text: 'Guardar',
        width: 100,
        height: 27,
        disabled: true,

        handler: function () {
          GuardarAlerta();
        }
      };

      var btnCancelar = {
        id: 'btnCancelar',
        xtype: 'button',
        width: 100,
        height: 27,
        iconAlign: 'left',
        icon: 'Images/back_black_20x20.png',
        text: 'Cancelar',

        style: {
          marginLeft: '5px',
          marginBottom: '10px'
        },

        handler: function () {
          Cancelar();
        }
      };

      var panelConfiguracion = new Ext.FormPanel({
        id: 'panelConfiguracion',
        title: 'Configuración de Alerta',
        anchor: '100% 100%',
        layout: 'column',
        border: false,
        bodyStyle: 'padding: 5px;',
        items: [{
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.49,
          style: {
            paddingRight: '20px'
          },
          items: [txtNombreTipoAlerta, numberControl1, numberControl3, chkAlertaActiva]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.51,
          items: [txtNombreAlerta, numberControl2, numberControl4, numberVelocidad]
        }/*,
            {
              xtype: 'container',
              layout: 'anchor',
              columnWidth: 1,
              items: [chkAlertaActiva]
            }*/],
        buttons: [btnGuardar, btnCancelar]
      });

      var viewWidth = Ext.getBody().getViewSize().width;

      var leftPanel = new Ext.FormPanel({
        id: 'leftPanel',
        title: 'Alertas',
        border: false,
        margins: '1 0 3 3',
        region: 'west',
        layout: 'anchor',
        width: viewWidth / 2.5,
        minWidth: viewWidth / 4,
        maxWidth: viewWidth / 1.5,
        split: true,
        items: [gridPanelTipoAlertas, panelInfoAlerta]
      });

      var centerPanel = new Ext.FormPanel({
        id: 'centerPanel',
        region: 'center',
        border: true,
        margins: '0 3 3 0',
        anchor: '100% 100%',
        items: [panelConfiguracion]

      });

      var viewport = Ext.create('Ext.container.Viewport', {
        layout: 'border',
        items: [topMenu, leftPanel, centerPanel]
      });

    });

  function GuardarAlerta() {

    if (!Ext.getCmp('panelConfiguracion').getForm().isValid() ) {
      return;
    }

    var idTipoAlerta = Ext.getCmp('txtIdAlerta').getValue();
    var control1 = Ext.getCmp('numberControl1').getValue();
    var control2 = Ext.getCmp('numberControl2').getValue() - Ext.getCmp('numberControl1').getValue();
    var control3 = Ext.getCmp('numberControl3').getValue() - Ext.getCmp('numberControl2').getValue();
    var control4 = Ext.getCmp('numberControl4').getValue();

    if (Ext.getCmp('numberVelocidad').isHidden() == true) {
      var velocidad = 0;
    }
    else {
      var velocidad = Ext.getCmp('numberVelocidad').getValue();
    }
    var alertaActiva = Ext.getCmp('chkAlertaActiva').getValue();

      Ext.Ajax.request({
        url: 'AjaxPages/AjaxAlertas.aspx?Metodo=GuardarCongifAlerta',
        params: {
          'IdTipoAlerta': idTipoAlerta,
          'Control1': control1,
          'Control2': control2,
          'Control3': control3,
          'Control4': control4,
          'Velocidad': velocidad,
          'AlertaActiva': alertaActiva
        },
        success: function (msg, success) {
          alert(msg.responseText);

          Ext.getCmp("gridPanelTipoAlertas").getStore().load();
          Cancelar();

        },
        failure: function (msg) {
          alert('Se ha producido un error.');
        }
      });

    }


    function Cancelar() {

      Ext.getCmp('txtIdAlerta').reset();
      Ext.getCmp('txtNombreTipoAlerta').reset();
      Ext.getCmp('txtNombreAlerta').reset();
      Ext.getCmp('numberControl1').reset();
      Ext.getCmp('numberControl2').reset();
      Ext.getCmp('numberControl3').reset();
      Ext.getCmp('numberControl4').reset();
      Ext.getCmp('chkAlertaActiva').reset();
      Ext.getCmp('numberVelocidad').reset();
      
      Ext.getCmp("textAreaDescripcion").reset();

      Ext.getCmp('txtIdAlerta').setDisabled(true);
      Ext.getCmp('txtNombreTipoAlerta').setDisabled(true);
      Ext.getCmp('txtNombreAlerta').setDisabled(true);
      Ext.getCmp('numberControl1').setDisabled(true);
      Ext.getCmp('numberControl2').setDisabled(true);
      Ext.getCmp('numberControl3').setDisabled(true);
      Ext.getCmp('numberControl4').setDisabled(true);
      Ext.getCmp('numberVelocidad').setDisabled(true);
      Ext.getCmp('numberVelocidad').hide();
      Ext.getCmp('chkAlertaActiva').setDisabled(true);
      Ext.getCmp('btnGuardar').setDisabled(true);

      Ext.getCmp('gridPanelTipoAlertas').getSelectionModel().deselectAll();

      Ext.getCmp('numberControl2').setMinValue(0);
      Ext.getCmp('numberControl3').setMinValue(0);
      Ext.getCmp('numberControl4').setMinValue(0);

    }

</script>

</asp:Content>