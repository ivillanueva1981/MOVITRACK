<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Track_Web.Login" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Track Platform</title>
<%--    <link rel="shortcut icon" href="Images/ShortIcon.PNG" />--%>
    <link rel="shortcut icon" href="Images/Iconos/ShortIcon.ico" />
    <link href="~/Styles/Site.css" rel="stylesheet" type="text/css" />
    <link href="Scripts/ext-4.0.1/resources/css/ext-all-gray.css" rel="stylesheet" type="text/css" />
    <script src="Scripts/ext-4.0.1/bootstrap.js" type="text/javascript"></script>
    <script src="Scripts/ext-4.0.1/locale/ext-lang-es.js" type="text/javascript"></script>

    <style type="text/css">
      .background .x-panel-body
      {
          background-image:url('Images/Background/background_color_1_1366x768.jpg') !important;
          background-size: cover; 
      }
      
      .background2 .x-panel-body
      {
          background-image:url('') !important;
      }
    </style>


</head>
<body>
    <form id="form1" runat="server">

    <div>

    <script type="text/javascript">

      Ext.onReady(function () {

        /////Definición global para permitir seleccionar texto de las grillas
        Ext.define('xxx.grid.SelectFeature', {
          extend: 'Ext.grid.feature.Feature',
          alias: 'feature.selectable',

          mutateMetaRowTpl: function (metaRowTpl) {
            var i,
        ln = metaRowTpl.length;

            for (i = 0; i < ln; i++) {
              tpl = metaRowTpl[i];
              tpl = tpl.replace(/x-grid-row/, 'x-grid-row x-selectable');
              tpl = tpl.replace(/x-grid-cell-inner x-unselectable/g, 'x-grid-cell-inner');
              tpl = tpl.replace(/unselectable="on"/g, '');
              metaRowTpl[i] = tpl;
            }
          }
        });

        Ext.override(Ext.view.Table, {
          afterRender: function () {
            var me = this;

            me.callParent();
            me.mon(me.el, {
              scroll: me.fireBodyScroll,
              scope: me
            });
            if (!me.featuresMC &&
            (me.featuresMC.findIndex('ftype', 'unselectable') >= 0)) {
              me.el.unselectable();
            }

            me.attachEventsForFeatures();
          }
        });
        ///////

        var displayVersion = new Ext.form.field.Display({
            id: 'displayVersion',
            fieldLabel: 'V.',
            labelWidth: 20
        });

        var textUsuario = new Ext.form.TextField({
          fieldLabel: 'Usuario',
          id: 'textUsuario',
          allowBlank: false,
          labelWidth: 80,
          anchor: '99%',
          regex: /^[-''&.,_\w\sáéíóúüñÑ\(\)]+$/i,
          regexText: 'Caracteres no válidos.',
          minLength: 1,
          maxLength: 20,
          enableKeyEvents: true
        });

        var textPassword = new Ext.form.TextField({
          fieldLabel: 'Contraseña',
          id: 'textPassword',
          allowBlank: false,
          labelWidth: 80,
          anchor: '99%',
          inputType: 'password',
          regex: /^[-''&.,_\w\sáéíóúüñÑ\(\)]+$/i,
          regexText: 'Caracteres no válidos.',
          minLength: 1,
          maxLength: 10,
          enableKeyEvents: true
        });

        var btnIngresar = {
          id: 'btnIngresar',
          xtype: 'button',
          iconAlign: 'left',
          height: 25,
          width: 75,
          text: 'Ingresar',
          formBind: true,
          textAlign: 'right',
          handler: function () {
            Ingresar();
          }
        };

        var btnCancelar = {
          id: 'btnCancelar',
          xtype: 'button',
          iconAlign: 'left',
          height: 25,
          width: 75,
          text: 'Cancelar',
          textAlign: 'right',
          handler: function () {
            Cancelar();
          }
        };

        var toolbarLogin = Ext.create('Ext.toolbar.Toolbar', {
          id: 'toolbarLogin',
          height: 40
        });

        var loginPanel = new Ext.FormPanel({
          id: 'loginPanel',
          frame: true,
          title: 'Ingrese sus credenciales',
          width: 300,
          height: 130,
          defaultType: 'textfield',
          labelAlign: 'top',
          layout: 'column',
          cls: 'background2',
          //tbar: toolbarLogin,
          items: [{
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 0.99,
            style: {
              paddingTop: '5px',
              paddingLeft: '5px'
            },
            items: [textUsuario, textPassword]
          }],
          buttons: [btnIngresar, btnCancelar]
        });

        var fullPanel = new Ext.FormPanel({
          id: 'fullPanel',
          frame: true,
          anchor: '100% 100%',
          renderTo: Ext.getBody(),
          cls: 'background',
          style: {
            backgroundImage: 'url(\'Images/background_color_1366x768.jpg\') !important',
            border: '0px'
          },
          layout: {
          type: 'vbox',
          align: 'center',
          pack: 'center'
          },
          items: [displayVersion, loginPanel]
        });

        var centerPanel = new Ext.FormPanel({
          id: 'centerPanel',
          region: 'center',
          border: true,
          //bodyStyle: 'padding: 10px;',
          /*layout: {
          type: 'vbox',
          align: 'center',
          pack: 'center'
          },*/
          items: fullPanel
        });

        var viewport = Ext.create('Ext.container.Viewport', {
          layout: 'border',
          renderTo: Ext.getBody(),
          defaults: {
            collapsible: true,
            split: true
          },
          items: [centerPanel]
        });

        viewport.on('resize', function () {
            GetVersion();
        });

        GetVersion();

      });

    function Ingresar() {

      var usuario = Ext.getCmp("textUsuario").getValue();
      var password = Ext.getCmp("textPassword").getValue();
      
      Ext.Ajax.request({
        url: 'AjaxPages/AjaxLogin.aspx?Metodo=ValidarUsuario',
        params: {
          'Usuario': usuario,
          'Password': password
        },
        success: function (data, success) {

          if (data.responseText == "Ok") {
            //window.location = "InformeViajes.aspx";
            window.location = "ControlPanel.aspx";

          }
          else {
            alert(data.responseText);
          }
        },
        failure: function (msg) {
          alert('Se ha producido un error.');
        }
      });

    }

    function Cancelar() {
        Ext.getCmp("loginPanel").getForm().reset();
        GetVersion();
    }


    function GetVersion() {
        Ext.getCmp('displayVersion').setPosition(Ext.getCmp('displayVersion').getPosition()[0] + 100, Ext.getCmp('displayVersion').getPosition()[1] + 150);

        Ext.Ajax.request({
            url: 'AjaxPages/AjaxLogin.aspx?Metodo=GetVersion',
            success: function (data, success) {
                Ext.getCmp('displayVersion').setValue(data.responseText);
            }
        });

    }

</script>
       

    </div>
    </form>
</body>
</html>
