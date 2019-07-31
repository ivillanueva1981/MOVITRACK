<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EstadoPatente.aspx.cs" Inherits="Track_Web.EstadoPatente" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
  AltoTrack Platform 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <script src="Scripts/TopMenu.js" type="text/javascript"></script>
  <script src="Scripts/Utilidades.js"></script>
  <script type="text/javascript">

    Ext.onReady(function () {

      Ext.QuickTips.init();
      Ext.Ajax.timeout = 600000;
      Ext.override(Ext.form.Basic, { timeout: Ext.Ajax.timeout / 1000 });
      Ext.override(Ext.data.proxy.Server, { timeout: Ext.Ajax.timeout });
      Ext.override(Ext.data.Connection, { timeout: Ext.Ajax.timeout });

      var textPatente = new Ext.form.TextField({
        id: 'textPatente',
        labelWidth: 100,
        fieldLabel: 'Patente',
        allowBlank: true,
        anchor: '99%',
        maxLength: 10,
        style: {
          marginTop: '5px',
          marginLeft: '20px'

        }
      });

      var btnBuscar = {
        id: 'btnBuscar',
        xtype: 'button',
        iconAlign: 'left',
        icon: 'Images/searchreport_black_20x20.png',
        text: 'Buscar',
        width: 100,
        height: 26,
        handler: function () {
          Buscar();
        },
        style: {
          marginTop: '3px',
          marginLeft: '80px'
        }
      };

      var imageStatus = Ext.create('Ext.Img', {
        id:  'imageStatus', 
        src: 'Images/empty_truck.PNG',
        renderTo: Ext.getBody()
      });

      var toolbar = Ext.create('Ext.toolbar.Toolbar', {
        id: 'toolbar',
        height: 40,
        layout: 'column',
        items: [{
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.5,
          items:[textPatente]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.5,
          align: 'right',
          items: [btnBuscar]
        }]
      });

      var imagePanel = new Ext.FormPanel({
        id: 'imagePanel',
        layout: 'anchor',
        border: true,
        items: [imageStatus]
      });

      var displayEstado = new Ext.form.field.Display({
        id: 'displayEstado',
        fieldLabel: 'Estado GPS',
        labelWidth: 150,
        width: 300,
        style: {
          marginTop: '4px',
          marginLeft: '5px'
        }
      });

      var displayUltimoReporte = new Ext.form.field.Display({
        id: 'displayUltimoReporte',
        fieldLabel: 'Último reporte',
        labelWidth: 150,
        width: 300,
        style: {
          marginTop: '3px',
          marginLeft: '5px'
        }
      });

      var displayTransportista = new Ext.form.field.Display({
        id: 'displayTransportista',
        fieldLabel: 'Transportista',
        labelWidth: 150,
        width: 500,
        style: {
          marginTop: '3px',
          marginLeft: '5px'
        }
      });

      var displayProveedorGPS = new Ext.form.field.Display({
        id: 'displayProveedorGPS',
        fieldLabel: 'Proveedor GPS',
        labelWidth: 150,
        width: 500,
        style: {
          marginTop: '3px',
          marginLeft: '5px'
        }
      });

      var statusPanel = new Ext.FormPanel({
        id: 'statusPanel',
        layout: 'anchor',
        border: true,
        items: [displayEstado, displayUltimoReporte, displayTransportista, displayProveedorGPS]
      });

      var panelEstado = new Ext.FormPanel({
        id: 'panelEstado',
        title: 'Estado de la Patente',
        tbar: toolbar,
        width: 800,
        height: 500,
        items:[imagePanel, statusPanel]
      });

      var textRutPOD = new Ext.form.TextField({
        id: 'textRutPOD',
        labelWidth: 100,
        fieldLabel: 'Rut',
        allowBlank: true,
        anchor: '99%',
        maxLength: 10,
        style: {
          marginTop: '5px',
          marginLeft: '20px'

        }
      });

      var btnBuscarPOD = {
        id: 'btnBuscarPOD',
        xtype: 'button',
        iconAlign: 'left',
        icon: 'Images/searchreport_black_20x20.png',
        text: 'Buscar',
        width: 100,
        height: 26,
        handler: function () {
          BuscarEstadoPod();
        },
        style: {
          marginTop: '3px',
          marginLeft: '80px'
        }
      };

      var toolbar2 = Ext.create('Ext.toolbar.Toolbar', {
        id: 'toolbar2',
        height: 40,
        layout: 'column',
        items: [{
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.5,
          items: [textRutPOD]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 0.5,
          align: 'right',
          items: [btnBuscarPOD]
        }]
      });
           
      var storePod = new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['Terminal', 'NroGuia', 'RutCliente', 'NombreCliente', 'Patente', 'RutConductor', 'NombreConductor', 'NombreTransportista', 'FechaPresentacion', 'TienePOD'],
        proxy: new Ext.data.HttpProxy({
          url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetEstadoPodDetalle',
          headers: {
            'Content-type': 'application/json'
          }
        })
      });

      var displayEstadoPod = new Ext.form.field.Display({
        id: 'displayEstadoPod',
        fieldLabel: 'Estado POD',
        labelWidth: 80,
        width: 200,
        height: 30,
        style: {
          marginTop: '4px',
          marginLeft: '5px'
        }
      });

      var gridPod = Ext.create('Ext.grid.Panel', {
        id: 'gridPod',
        store: storePod,
        //tbar: toolbarPosiciones,
        columnLines: true,
        anchor: '100% 50%',
        //features: [groupingFeature],
        //buttons: [chkMostrarTrafico, btnExportar, btnActualizar],
        viewConfig: {
          style: { overflow: 'auto', overflowX: 'hidden' }
        },
        columns: [
                      { text: 'Terminal', flex: 1, dataIndex: 'Terminal' },
                      { text: 'Nro. Guia', width: 60, dataIndex: 'NroGuia' },
                      { text: 'Rut Cliente', width: 75, dataIndex: 'RutCliente' },
                      { text: 'Nombre Cliente', width: 200,dataIndex: 'NombreCliente' },
                      { text: 'Patente', width: 60, dataIndex: 'Patente' },
                      { text: 'Nombre Transportista', width: 200, dataIndex: 'NombreTransportista' },
                      { text: 'Fecha Presentación', width: 110, dataIndex: 'FechaPresentacion' },
        ]
      });      

      var statusPanelPod = new Ext.FormPanel({
        id: 'statusPanelPod',
        layout: 'anchor',
        border: true,
        items: [displayEstadoPod]

      });

      var imageStatusPod = Ext.create('Ext.Img', {
        id: 'imageStatusPod',
        src: 'Images/document_empty.png',
        height: 200,
        width: 200
      });

      var imagePanelPod = new Ext.FormPanel({
        id: 'imagePanelPod',
        border: true,
        height: 210,
        items: [imageStatusPod],
        layout: {
          type: 'vbox',
          align: 'center'
        }
      });

      var panelEstadoPOD = new Ext.FormPanel({
        id: 'panelEstadoPOD',
        title: 'Estado POD',
        width: 800,
        height: 500,
        tbar: toolbar2,
        items: [imagePanelPod, statusPanelPod, gridPod]
      });

      var tabPanel = new Ext.TabPanel({
        items: [panelEstado, panelEstadoPOD]
      });

      var centerPanel = new Ext.FormPanel({
        id: 'centerPanel',
        region: 'center',
        border: true,
        margins: '0 3 3 0',
        layout: {
          type: 'vbox',
          align: 'center',
          pack: 'center'
        },
        items: [tabPanel]
      });

      var viewport = Ext.create('Ext.container.Viewport', {
        layout: 'border',
        items: [topMenu, centerPanel]
      });
    });

  </script>


  <script type="text/javascript">
    
    function Buscar() {
      //Ext.getCmp('imageStatus').setSrc('Images/red_truck.PNG');

      var patente = Ext.getCmp("textPatente").getValue();

      if (patente == "") {
        return;
      }

      Ext.Ajax.request({
        url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetEstadoPatente',
        params: {
          patente: patente
        },
        success: function (data, success) {
          if (data != null) {
            data = Ext.decode(data.responseText);

            Ext.getCmp('displayEstado').setValue(data[0].Estado);
            Ext.getCmp('displayUltimoReporte').setValue(data[0].Fecha);
            Ext.getCmp('displayTransportista').setValue(data[0].Transportista);
            Ext.getCmp('displayProveedorGPS').setValue(data[0].ProveedorGPS);

            switch (data[0].Estado) {
              case "Online":
                Ext.getCmp('imageStatus').setSrc('Images/green_truck.PNG');
                Ext.getCmp('displayEstado').setFieldStyle('color: #19c663');
                break;
              case "Offline":
                Ext.getCmp('imageStatus').setSrc('Images/red_truck.PNG');
                Ext.getCmp('displayEstado').setFieldStyle('color: #d63b3b');
                break;
              default:
                Ext.getCmp('imageStatus').setSrc('Images/gray_truck.PNG');
                Ext.getCmp('displayEstado').setFieldStyle('color: Black');
            }

          }
        }
      })

    }

    function BuscarEstadoPod() {
      var rut = Ext.getCmp("textRutPOD").getValue();
      if (!ValidarRut(rut)) {
        alert("Debe ingresar un RUT válido.");
        return;
      }

      Ext.Ajax.request({
        url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetEstadoPod',
        params: {
          rut: rut
        },
        success: function (data, success) {
          if (data != null) {
            var estado = data.responseText;

            switch (estado) {
              case "Pendiente":
                Ext.getCmp('displayEstadoPod').setValue(estado);
                Ext.getCmp('imageStatusPod').setSrc('Images/document_cancel.png');
                Ext.getCmp('displayEstadoPod').setFieldStyle('color: #d63b3b');
                BuscarEstadoPodDetalle();
                break;
              case "Al día":
                Ext.getCmp('displayEstadoPod').setValue(estado);
                Ext.getCmp('imageStatusPod').setSrc('Images/document_accept.png');
                Ext.getCmp('displayEstadoPod').setFieldStyle('color: #19c663');
                break;
              case "Por Vencer":
                Ext.getCmp('displayEstadoPod').setValue(estado);
                Ext.getCmp('imageStatusPod').setSrc('Images/document_expiration.png');
                Ext.getCmp('displayEstadoPod').setFieldStyle('color: #f4c810');
                BuscarEstadoPodDetalle();
                break;
              default:
                Ext.getCmp('displayEstadoPod').setValue('');
                Ext.getCmp('imageStatusPod').setSrc('Images/document_empty.png');
                Ext.getCmp('displayEstadoPod').setFieldStyle('color: #000000');
                break;
            }
          }
        }
      })

    }

    function BuscarEstadoPodDetalle() {
      var rut = Ext.getCmp("textRutPOD").getValue();

      if (rut == "") {
        return;
      }

      var store = Ext.getCmp('gridPod').store;
      store.load({
        params: {
          rut: rut
        }
      });
    }


  </script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
  <div id="dvMap"></div>
</asp:Content>
