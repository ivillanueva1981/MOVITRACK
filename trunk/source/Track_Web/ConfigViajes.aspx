<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ConfigViajes.aspx.cs" Inherits="Track_Web.ConfigViajes" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
AltoTrack Platform 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

  <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8" type="text/javascript"></script>
  <script src="Scripts/MapFunctions.js" type="text/javascript"></script>
  <script src="Scripts/TopMenu.js" type="text/javascript"></script>
  <script src="Scripts/LabelMarker.js" type="text/javascript"></script>
      
<script type="text/javascript">

  var _editing = false;

  Ext.onReady(function () {

      Ext.QuickTips.init();
      Ext.Ajax.timeout = 600000;
      Ext.override(Ext.form.Basic, { timeout: Ext.Ajax.timeout / 1000 });
      Ext.override(Ext.data.proxy.Server, { timeout: Ext.Ajax.timeout });
      Ext.override(Ext.data.Connection, { timeout: Ext.Ajax.timeout });

      Ext.apply(Ext.form.field.VTypes, {
          fileExcel: function (val, field) {
              var fileName = /^.*\.(xlsx|xls|xlsb)$/i;
              return fileName.test(val);
          },
          fileExcelText: "Tipo de archivo no válido.",
          fileExcelfileMask: /[a-z_\.]/i
      });

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

      /*
      var rowEditing = Ext.create('Ext.grid.plugin.RowEditing', {
      clicksToMoveEditor: 1,
      autoCancel: false
      });
      */
      var storeFiltroTransportista = new Ext.data.JsonStore({
          fields: ['Transportista'],
          proxy: new Ext.data.HttpProxy({
              //url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetTransportistasRuta&Todos=True',
              url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetAllTransportistas&Todos=False',
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });

      var numberNroTransporte = new Ext.form.NumberField({
          fieldLabel: 'Nro. Transporte',
          id: 'numberNroTransporte',
          allowBlank: false,
          labelWidth: 120,
          anchor: '99%',
          minValue: 1,
          maxValue: 9999999999,
          enableKeyEvents: true,
          listeners: {
              'blur': function (_field) {
                  ValidarNroTransporte();
              }
          }
      });

      var comboFiltroTransportista = new Ext.form.field.ComboBox({
          id: 'comboFiltroTransportista',
          fieldLabel: 'Transportista',
          forceSelection: true,
          store: storeFiltroTransportista,
          valueField: 'Transportista',
          displayField: 'Transportista',
          queryMode: 'local',
          anchor: '99%',
          labelWidth: 120,
          emptyText: 'Seleccione...',
          enableKeyEvents: true,
          editable: false,
          forceSelection: true,
          listeners: {
              select: function () {
                  FiltrarPatentes();
                  Ext.getCmp("comboFiltroPatenteTracto").setDisabled(false);
                  Ext.getCmp("comboFiltroPatenteTrailer").setDisabled(false);
              }
          }
      });

      var storeFiltroPatente = new Ext.data.JsonStore({
          fields: ['Patente'],
          proxy: new Ext.data.HttpProxy({
              url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetAllPatentes&Todas=False',
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });

      var comboFiltroPatenteTracto = new Ext.form.field.ComboBox({
          id: 'comboFiltroPatenteTracto',
          fieldLabel: 'Patente Tracto',
          forceSelection: true,
          store: storeFiltroPatente,
          valueField: 'Patente',
          displayField: 'Patente',
          queryMode: 'local',
          anchor: '99%',
          labelWidth: 120,
          emptyText: 'Seleccione...',
          enableKeyEvents: true,
          editable: true,
          forceSelection: true,
          disabled: true,
          /*listeners: {
            'blur': function (_field) {
              ValidarTractoCD();
            }
          }*/
      });

      var comboFiltroPatenteTrailer = new Ext.form.field.ComboBox({
          id: 'comboFiltroPatenteTrailer',
          fieldLabel: 'Patente Trailer',
          forceSelection: true,
          store: storeFiltroPatente,
          valueField: 'Patente',
          displayField: 'Patente',
          queryMode: 'local',
          anchor: '99%',
          labelWidth: 120,
          emptyText: 'Seleccione...',
          enableKeyEvents: true,
          editable: true,
          forceSelection: true,
          disabled: true,
          /*listeners: {
            'blur': function (_field) {
              ValidarTrailerCD();
            }
          }*/
      });

      storeFiltroTransportista.load({
          callback: function (r, options, success) {
              if (success) {
                  storeFiltroPatente.load();
              }
          }
      });


      var storeZonasOrigen = new Ext.data.JsonStore({
          autoLoad: false,
          fields: ['IdZona', 'NombreZona', 'IdTipoZona', 'NombreTipoZona', 'Latitud', 'Longitud'],
          proxy: new Ext.data.HttpProxy({
              url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonas',
              reader: { type: 'json', root: 'Zonas' },
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });

      var comboZonaOrigen = new Ext.form.field.ComboBox({
          id: 'comboZonaOrigen',
          fieldLabel: 'Origen',
          allowBlank: false,
          store: storeZonasOrigen,
          valueField: 'IdZona',
          displayField: 'NombreZona',
          queryMode: 'local',
          anchor: '99%',
          forceSelection: true,
          enableKeyEvents: true,
          editable: true,
          labelWidth: 120,
          emptyText: 'Seleccione...',
          listConfig: {
              loadingText: 'Buscando...',
              getInnerTpl: function () {
                  return '<a class="search-item">' +
                                    '<span>Id Zona: {IdZona}</span><br />' +
                                    '<span>Nombre: {NombreZona}</span>' +
                                '</a>';
              }
          }
      });

      var storeZonasDestino = new Ext.data.JsonStore({
          autoLoad: false,
          fields: ['IdZona', 'NombreZona', 'IdTipoZona', 'NombreTipoZona', 'Latitud', 'Longitud'],
          proxy: new Ext.data.HttpProxy({
              url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonas',
              reader: { type: 'json', root: 'Zonas' },
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });

      var comboZonaDestino = new Ext.form.field.ComboBox({
          id: 'comboZonaDestino',
          fieldLabel: 'Destino',
          allowBlank: false,
          store: storeZonasDestino,
          valueField: 'IdZona',
          displayField: 'NombreZona',
          queryMode: 'local',
          anchor: '99%',
          forceSelection: true,
          enableKeyEvents: true,
          editable: true,
          labelWidth: 120,
          emptyText: 'Seleccione...',
          listConfig: {
              loadingText: 'Buscando...',
              getInnerTpl: function () {
                  return '<a class="search-item">' +
                                    '<span>Id Zona: {IdZona}</span><br />' +
                                    '<span>Nombre: {NombreZona}</span>' +
                                '</a>';
              }
          }

      });

      var storeRutasGeneradas = new Ext.data.JsonStore({
          autoLoad: false,
          fields: ['IdRuta',
                    'NombreRuta',
                    'DetalleRuta'
          ],
          proxy: new Ext.data.HttpProxy({
              url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetRutasGeneradas',
              reader: { type: 'json', root: 'Zonas' },
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });

      var comboRuta = new Ext.form.field.ComboBox({
          id: 'comboRuta',
          fieldLabel: 'Ruta',
          allowBlank: false,
          store: storeRutasGeneradas,
          valueField: 'IdRuta',
          displayField: 'NombreRuta',
          queryMode: 'local',
          anchor: '99%',
          forceSelection: true,
          enableKeyEvents: true,
          editable: true,
          labelWidth: 120,
          emptyText: 'Seleccione...'
          /*listConfig: {
              loadingText: 'Buscando...',
              getInnerTpl: function () {
                  return '<a class="search-item">' +
                                    '<span>Nombre: {NombreRuta}</span><br />' +
                                    '<span>Detalle: {DetalleRuta}</span>' +
                                '</a>';
              }
          }*/

      });

      var textRutConductor = new Ext.form.TextField({
          fieldLabel: 'Rut Conductor',
          id: 'textRutConductor',
          allowBlank: true,
          anchor: '99%',
          labelWidth: 120,
          regex: /^[-''&.,\w\sáéíóúüñÑ]+$/i,
          regexText: 'Caracteres inválidos.',
          maxLength: 10,
          enableKeyEvents: true
      });

      var textNombreConductor = new Ext.form.TextField({
          fieldLabel: 'Nombre Conductor',
          id: 'textNombreConductor',
          allowBlank: true,
          anchor: '99%',
          labelWidth: 120,
          regex: /^[-''&.,\w\sáéíóúüñÑ]+$/i,
          regexText: 'Caracteres inválidos.',
          maxLength: 50,
          enableKeyEvents: true
      });

      var storeFiltroTipoViaje = new Ext.data.JsonStore({
          fields: ['TipoViaje'],
          data: [{ TipoViaje: 'CD SECO' },
                  { TipoViaje: 'CD FFVV' }
          ]
      });

      var comboFiltroTipoViaje = new Ext.form.field.ComboBox({
          id: 'comboFiltroTipoViaje',
          fieldLabel: 'Tipo Viaje',
          store: storeFiltroTipoViaje,
          valueField: 'TipoViaje',
          displayField: 'TipoViaje',
          queryMode: 'local',
          anchor: '98%',
          labelWidth: 100,
          editable: false,
          enableKeyEvents: true,
          forceSelection: true
      });

      Ext.getCmp('comboFiltroTipoViaje').setValue('CD SECO');

      var btnCrearViaje = {
          id: 'btnCrearViaje',
          xtype: 'button',
          iconAlign: 'left',
          icon: 'Images/add_blue_20x19.png',
          text: 'Nuevo viaje',
          width: 100,
          height: 27,
          handler: function () {
              //rowEditing.cancelEdit();
              winCrearViaje.show();

              Ext.getCmp("comboZonaOrigen").setDisabled(false);

              Ext.getCmp("comboZonaDestino").setDisabled(true);
              Ext.getCmp("comboZonaDestino").hide();

              Ext.getCmp("comboRuta").setDisabled(false);
              Ext.getCmp("comboRuta").show();

          }
      };

      var btnConfigurarRutas = {
          id: 'btnConfigurarRutas',
          xtype: 'button',
          iconAlign: 'left',
          icon: 'Images/editroute_blue_20x19.png',
          text: 'Configurar rutas',
          width: 120,
          height: 27,
          handler: function () {
              //rowEditing.cancelEdit();
              winConfigurarRutas.show();
          }
      };

      var btnUploadExcel = {
          id: 'btnUploadExcel',
          xtype: 'button',
          iconAlign: 'left',
          icon: 'Images/upload_excel_20x20.png',
          text: 'Cargar Excel',
          width: 100,
          height: 27,
          handler: function () {
              winUploadExcel.show();
          }
      };

      var storeViajesAsignados = new Ext.data.JsonStore({
          fields: ['NroTransporte',
                                'RutConductor',
                                'NombreConductor',
                                'PatenteTracto',
                                'PatenteTrailer',
                                'RutTransportista',
                                'NombreTransportista',
                                'CodigoOrigen',
                                'NombreOrigen',
                                'CodigoDestino',
                                'NombreDestino',
                                { name: 'FechaAsignacion', type: 'date', dateFormat: 'c' }
          ],
          proxy: new Ext.data.HttpProxy({
              url: 'Ajaxpages/AjaxViajes.aspx?Metodo=GetViajesAsignados',
              reader: { type: 'json', root: 'd' },
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });

      var gridViajesAsignados = Ext.create('Ext.grid.Panel', {
          id: 'gridViajesAsignados',
          title: 'Viajes asignados',
          hideCollapseTool: true,
          anchor: '100% 99%',
          //tbar: toolbar,
          buttons: [btnCrearViaje, btnConfigurarRutas, btnUploadExcel],
          store: storeViajesAsignados,
          scroll: false,
          viewConfig: {
              style: { overflow: 'auto', overflowX: 'hidden' }
          },
          columnLines: true,
          columns: [{ text: 'NroTransporte', width: 85, sortable: true, dataIndex: 'NroTransporte' },
                      { text: 'Transportista', width: 100, sortable: true, dataIndex: 'NombreTransportista' },
                      { text: 'Origen', flex: 1, sortable: true, dataIndex: 'NombreOrigen' },
                      { text: 'Destino', flex: 1, sortable: true, dataIndex: 'NombreDestino' },
                      { text: 'Trailer', sortable: true, width: 80, dataIndex: 'PatenteTrailer' },
                      { text: 'Tracto', sortable: true, width: 80, dataIndex: 'PatenteTracto' },
                      { text: 'Rut Conductor', width: 85, sortable: true, dataIndex: 'RutConductor' },
                      { text: 'Nombre Conductor', flex: 1, sortable: true, dataIndex: 'NombreConductor' },
                      { text: 'Fecha asignación', width: 110, sortable: true, dataIndex: 'FechaAsignacion', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                      {
                          xtype: 'actioncolumn',
                          width: 60,
                          editor: false,
                          header: 'Acciones',
                          items: [{
                              icon: 'Images/edit.png',
                              tooltip: 'Editar Viaje',
                              handler: function (grid, rowIndex, colIndex) {
                                  var row = grid.getStore().getAt(rowIndex);

                                  Ext.getCmp("numberNroTransporte").setDisabled(true);
                                  Ext.getCmp("comboFiltroPatenteTracto").setDisabled(false);
                                  Ext.getCmp("comboFiltroPatenteTrailer").setDisabled(false);

                                  Ext.getCmp("comboZonaOrigen").setDisabled(true    );
                                  Ext.getCmp("comboZonaDestino").setDisabled(true);
                                  Ext.getCmp("comboZonaDestino").show();
                                  Ext.getCmp("comboRuta").setDisabled(true);
                                  Ext.getCmp("comboRuta").hide();

                                  Ext.getCmp("numberNroTransporte").setValue(row.data.NroTransporte);
                                  Ext.getCmp("comboFiltroTransportista").setValue(row.data.NombreTransportista);
                                  Ext.getCmp("comboFiltroPatenteTracto").setValue(row.data.PatenteTracto);
                                  Ext.getCmp("comboFiltroPatenteTrailer").setValue(row.data.PatenteTrailer);
                                  Ext.getCmp("comboZonaOrigen").setValue(row.data.CodigoOrigen);
                                  Ext.getCmp("comboZonaDestino").setValue(row.data.CodigoDestino);
                                  Ext.getCmp("textRutConductor").setValue(row.data.RutConductor);
                                  Ext.getCmp("textNombreConductor").setValue(row.data.NombreConductor);

                                  _editing = true;
                                  winCrearViaje.show();
                              }
                          },
                        {
                            icon: 'Images/delete.png',
                            tooltip: 'Eliminar Viaje',
                            handler: function (grid, rowIndex, colIndex) {
                                var row = grid.getStore().getAt(rowIndex);

                                if (!confirm("El viaje será eliminado permanentemente. ¿Desea continuar?")) {
                                    return;
                                }

                                Ext.Ajax.request({
                                    url: 'Ajaxpages/AjaxViajes.aspx?Metodo=EliminarViaje',
                                    params: {
                                        NroTransporte: row.data.NroTransporte,
                                        codLocal: row.data.CodigoDestino
                                    },
                                    success: function (data, success) {
                                        if (data != null) {
                                            Ext.getCmp('gridViajesAsignados').getStore().load();
                                        }
                                    },
                                    failure: function (msg) {
                                        alert('Se ha producido un error.');
                                    }
                                });
                            }
                        }]
                      }]
      });

      var store = Ext.getCmp('gridViajesAsignados').getStore();
      Ext.getCmp('gridViajesAsignados').expand();

      store.load({
          params: {},
          callback: function (r, options, success) {
              if (success) {
                  //nroRegistros = store.getCount();
                  //GridSetValue();
              }
          }
      });

      storeZonasOrigen.load({
          params: {
              idTipoZona: 1,
              nombreZona: ''
          }
      });

      storeZonasDestino.load({
          params: {
              idTipoZona: 2,
              nombreZona: ''
          }
      });

      var formCrearViaje = new Ext.FormPanel({
          id: 'formCrearViaje',
          border: false,
          frame: true,
          items: [numberNroTransporte, comboFiltroTransportista, comboFiltroPatenteTrailer, comboFiltroPatenteTracto, comboZonaOrigen, comboRuta, comboZonaDestino, textRutConductor, textNombreConductor]
      });

      var textNombreNuevaRuta = new Ext.form.TextField({
          id: 'textNombreNuevaRuta',
          labelWidth: 120,
          width: 320,
          fieldLabel: 'Nombre de ruta',
          allowBlank: true,
          anchor: '99%',
          maxLength: 255,
          listeners: {
              'render': function (c) {
                  c.getEl().on('keyup', function () {
                      if (c.value != "") {
                          Ext.getCmp("btnNuevaRuta").setDisabled(false);
                      }
                      else {
                          Ext.getCmp("btnNuevaRuta").setDisabled(true);
                      }
                  }, c);
              }
          }
      });

      var storeZonaDestino = new Ext.data.JsonStore({
          autoLoad: false,
          fields: ['IdZona', 'NombreZona', 'IdTipoZona', 'NombreTipoZona', 'Latitud', 'Longitud'],
          proxy: new Ext.data.HttpProxy({
              url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonas',
              reader: { type: 'json', root: 'Zonas' },
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });

      var comboAgregarZonaDestino = new Ext.form.field.ComboBox({
          id: 'comboAgregarZonaDestino',
          //fieldLabel: 'Destino',
          store: storeZonaDestino,
          valueField: 'IdZona',
          displayField: 'NombreZona',
          queryMode: 'local',
          anchor: '100%',
          enableKeyEvents: true,
          editable: true,
          //labelWidth: 80,
          width: 300,
          emptyText: 'Seleccione...',
          listConfig: {
              loadingText: 'Buscando...',
              getInnerTpl: function () {
                  return '<a class="search-item">' +
                                    '<span>Id Zona: {IdZona}</span><br />' +
                                    '<span>Nombre: {NombreZona}</span>' +
                                '</a>';
              }
          }

      });

      storeZonaDestino.load({
          params: {
              idTipoZona: 2,
              nombreZona: ''
          }
      });

      var btnNuevaRuta = {
          id: 'btnNuevaRuta',
          xtype: 'button',
          width: 100,
          height: 25,
          iconAlign: 'left',
          icon: 'Images/add_blue_20x19.png',
          text: 'Agregar ruta',
          disabled: true,
          handler: function () {
              Ext.Ajax.request({
                  url: 'AjaxPages/AjaxViajes.aspx?Metodo=AgregarRutaGenerada',
                  params: {
                      'nombreRuta': Ext.getCmp("textNombreNuevaRuta").getValue()
                  },
                  success: function (data, success) {
                      if (data != null) {
                          Ext.getCmp("gridPanelRutasGeneradas").store.load({
                              params: {
                                  IdRuta: -1
                              }
                          });

                          Ext.getCmp("gridPanelDetalleRuta").store.removeAll();
                          Ext.getCmp("gridPanelDetalleRuta").setDisabled(true);
                          Ext.getCmp("textNombreNuevaRuta").reset();  
                          Ext.getCmp("btnNuevaRuta").setDisabled(true);
                      }
                  },
                  failure: function (msg) {
                      alert('Se ha producido un error.');
                  }
              });
          }
      };

      var btnAgregarDestino = {
          id: 'btnAgregarDestino',
          xtype: 'button',
          width: 120,
          height: 25,
          iconAlign: 'left',
          icon: 'Images/add_blue_20x19.png',
          text: 'Agregar destino',
          handler: function () {
              AgregarDestinoRuta();
          }
      };

      var gridPanelRutasGeneradas = Ext.create('Ext.grid.Panel', {
          id: 'gridPanelRutasGeneradas',
          store: storeRutasGeneradas,
          anchor: '100% 55%',
          columnLines: true,
          title: 'Rutas creadas',
          buttons: [textNombreNuevaRuta, btnNuevaRuta],
          scroll: false,
          viewConfig: {
              style: { overflow: 'auto', overflowX: 'hidden' }
          },
          columns: [
                      { text: 'Nombre', sortable: true, flex: 1, dataIndex: 'NombreRuta' },
                      //{ text: 'Detalle', sortable: true, flex: 1, dataIndex: 'DetalleRuta' },
                      {
                          xtype: 'actioncolumn',
                          width: 23,
                          editor: false,
                          items: [
                            {icon: 'Images/delete.png',
                                tooltip: 'Eliminar ruta',
                                handler: function (grid, rowIndex, colIndex) {
                                    var row = grid.getStore().getAt(rowIndex);

                                    if (confirm("La ruta seleccionada se eliminará permanentemente.¿Desea continuar?")) {

                                        Ext.Ajax.request({
                                            url: 'AjaxPages/AjaxViajes.aspx?Metodo=EliminarRutaGenerada',
                                            params: {
                                                'IdRuta': row.data.IdRuta
                                            },
                                            success: function (data, success) {
                                                if (data != null) {
                                                    Ext.getCmp("gridPanelRutasGeneradas").store.load({
                                                        params: {
                                                            IdRuta: -1
                                                        }
                                                    });

                                                    Ext.getCmp("gridPanelDetalleRuta").store.removeAll();
                                                    Ext.getCmp("gridPanelDetalleRuta").setDisabled(true);
                                                }
                                            },
                                            failure: function (msg) {
                                                alert('Se ha producido un error.');
                                            }
                                        });
                                    }
                                }
                            }]
                      }
          ],
          listeners: {
              select: function (sm, row, rec) {

                  Ext.getCmp("gridPanelDetalleRuta").setDisabled(false);

                  storeDetalleRuta.load({
                      params: {
                          IdRuta: row.data.IdRuta
                      }
                  });
              }
          }
    });

    storeRutasGeneradas.load({
        params: {
            IdRuta: -1
        }
    });

    var storeDetalleRuta = new Ext.data.JsonStore({
        autoLoad: false,
        fields: [ 'IdRuta',
                  'NombreRuta',  
                  'IdZona',
                  'NombreZona',
                  'Orden'
        ],
        proxy: new Ext.data.HttpProxy({
            url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetDetalleRuta',
            reader: { type: 'json', root: 'Zonas' },
            headers: {
                'Content-type': 'application/json'
            }
        })
    });
      /*
    var toolbarDetalleRuta = Ext.create('Ext.toolbar.Toolbar', {
        id: 'toolbarDetalleRuta',
        height: 25,
        layout: 'column'

    });
    */
    var gridPanelDetalleRuta = Ext.create('Ext.grid.Panel', {
        id: 'gridPanelDetalleRuta',
        store: storeDetalleRuta,
        anchor: '100% 45%',
        columnLines: true,
        disabled: true,
        title: 'Detalle de ruta',
        buttons:[comboAgregarZonaDestino, btnAgregarDestino],
        scroll: false,
        style: {
            marginTop: '5px'
        },
        viewConfig: {
            style: { overflow: 'auto', overflowX: 'hidden' }
        },
        columns: [
                    { text: 'IdRuta', sortable: true, width: 30, hidden: true, dataIndex: 'IdRuta' },
                    { text: 'Id Destino', sortable: true, width: 65, dataIndex: 'IdZona' },
                    { text: 'Nombre Destino', sortable: true, flex: 1, dataIndex: 'NombreZona' },
                    {
                        xtype: 'actioncolumn',
                        width: 23,
                        editor: false,
                        items: [
                          {
                              icon: 'Images/delete.png',
                              tooltip: 'Eliminar destino',
                              handler: function (grid, rowIndex, colIndex) {
                                  var row = grid.getStore().getAt(rowIndex);

                                      Ext.Ajax.request({
                                          url: 'AjaxPages/AjaxViajes.aspx?Metodo=EliminarDestinoRuta',
                                          params: {
                                              'IdZona': row.data.IdZona
                                          },
                                          success: function (data, success) {
                                              if (data != null) {
                                                  Ext.getCmp("gridPanelDetalleRuta").store.load({
                                                      params: {
                                                          IdRuta: row.data.IdRuta
                                                      }
                                                  });

                                              }
                                          },
                                          failure: function (msg) {
                                              alert('Se ha producido un error.');
                                          }
                                      });
                              }
                          }]
                    }
        ]
    });

    var formConfigurarRutas = new Ext.FormPanel({
        id: 'formConfigurarRutas',
        width: 440,
        height: 385,
        border: false,
        frame: true,
        items: [gridPanelRutasGeneradas, gridPanelDetalleRuta]
    });

    var btnSalir = {
        id: 'btnSalir',
        xtype: 'button',
        width: 80,
        height: 26,
        iconAlign: 'left',
        icon: 'Images/back_black_20x20.png',
        text: 'Salir',
        handler: function () {
            Salir();
            
        }
    };
 
    var btnGuardar = {
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/save_black_20x20.png',
      text: 'Guardar',
      width: 90,
      height: 26,
      handler: function () {
        GuardarViaje();
      }
    };

    var btnCancelar = {
      id: 'btnCancelar',
      xtype: 'button',
      width: 90,
      height: 26,
      iconAlign: 'left',
      icon: 'Images/back_black_20x20.png',
      text: 'Cancelar',
      handler: function () {
        Cancelar();
      }
    };

    var winCrearViaje = new Ext.Window({
      id: 'winCrearViaje',
      title: 'Datos del viaje',
      width: 400,
      closeAction: 'hide',
      modal: true,
      items: formCrearViaje,
      resizable: false,
      border: false,
      constrain: true,
      buttons: [btnGuardar, btnCancelar]
    });

    var winConfigurarRutas = new Ext.Window({
        id: 'winConfigurarRutas',
        title: 'Configurar rutas',
        width: 450,
        height: 450,
        closeAction: 'hide',
        modal: true,
        items: formConfigurarRutas,
        resizable: false,
        border: false,
        constrain: true,
        buttons: [btnSalir]
    });

    var fFieldExcel = new Ext.form.field.File({
        xtype: 'filefield',
        id: 'fFieldExcel',
        labelWidth: 100,
        width: 350,
        allowBlank: false,
        vtype: 'fileExcel',
        emptyText: 'Seleccione archivo...',
        //fieldLabel: 'Cargar archivo',
        buttonText: '...',
        listeners: {
            'change': function (fb, v) {
                Ext.getCmp("btnLoadExcel").setDisabled(false);
            }
        }
    });

    var btnLoadExcel = {
        id: 'btnLoadExcel',
        xtype: 'button',
        width: 80,
        height: 23,
        disabled: true,
        iconAlign: 'left',
        icon: 'Images/upload_20x20.png',
        text: 'Cargar',
        style: {
            marginLeft: '5px'
        },
        handler: function () {
            loadExcel();
        }
    };

    var formUploadExcel = new Ext.FormPanel({
        id: 'formUploadExcel',
        border: false,
        frame: true,
        layout: 'column',
        items: [fFieldExcel, btnLoadExcel]
    });

    var winUploadExcel = new Ext.Window({
        id: 'winUploadExcel',
        title: 'Cargar planilla Excel',
        width: 455,
        closeAction: 'hide',
        modal: true,
        items: formUploadExcel,
        resizable: false,
        border: false,
        constrain: true

    });

    var centerPanel = new Ext.FormPanel({
      id: 'centerPanel',
      region: 'center',
      border: true,
      margins: '0 3 3 0',
      anchor: '100% 100%',
      items: [gridViajesAsignados]

    });

    var viewport = Ext.create('Ext.container.Viewport', {
      layout: 'border',
      items: [topMenu, centerPanel]
    });

  });

</script>

<script type="text/javascript">

  function Cancelar() {

    Ext.getCmp("winCrearViaje").hide();

    Ext.getCmp("numberNroTransporte").setDisabled(false);
    Ext.getCmp("comboFiltroPatenteTracto").setDisabled(true);
    Ext.getCmp("comboFiltroPatenteTrailer").setDisabled(true);
    Ext.getCmp("comboZonaDestino").setDisabled(false); ;

    Ext.getCmp("numberNroTransporte").reset();
    Ext.getCmp("comboFiltroTransportista").reset();
    Ext.getCmp("comboFiltroPatenteTracto").reset();
    Ext.getCmp("comboFiltroPatenteTrailer").reset();
    Ext.getCmp("comboZonaOrigen").reset();
    Ext.getCmp("comboZonaDestino").reset();
    Ext.getCmp("textRutConductor").reset();
    Ext.getCmp("textNombreConductor").reset();

    _editing = false;

  }

  function FiltrarPatentes() {
    var transportista = Ext.getCmp('comboFiltroTransportista').getValue();

    var storeTracto = Ext.getCmp('comboFiltroPatenteTracto').store;
    storeTracto.load({
      params: {
        transportista: transportista
      }
    });

    var storeTrailer = Ext.getCmp('comboFiltroPatenteTrailer').store;
    storeTrailer .load({
        params: {
            transportista: transportista
        }
    });
  }
    /*
  function ValidarTractoCD() {
    var tracto = Ext.getCmp("comboFiltroPatenteTracto").getValue();

    Ext.Ajax.request({
      url: 'AjaxPages/AjaxViajes.aspx?Metodo=ValidarMovilCD',
      params: {
        patente: tracto
      },
      success: function (data, success) {
        if (data != null) {
          if (data.responseText == 1) {
            Ext.getCmp('comboFiltroPatenteTracto').clearInvalid();
          }
          else {
            Ext.getCmp('comboFiltroPatenteTracto').markInvalid("El móvil seleccionado se encuentra fuera del CD");
          }
        }
      },
      failure: function (msg) {
        alert('Se ha producido un error.');
      }
    });
  }
  
  function ValidarTrailerCD() {
    var trailer = Ext.getCmp("comboFiltroPatenteTrailer").getValue();

    Ext.Ajax.request({
      url: 'AjaxPages/AjaxViajes.aspx?Metodo=ValidarMovilCD',
      params: {
        patente: trailer
      },
      success: function (data, success) {
        if (data != null) { 
          if (data.responseText == 1) {
            Ext.getCmp('comboFiltroPatenteTrailer').clearInvalid();
          } 
          else {
            Ext.getCmp('comboFiltroPatenteTrailer').markInvalid("El móvil seleccionado se encuentra fuera del CD");
          }
        }
      },
      failure: function (msg) {
        alert('Se ha producido un error.');
      }
    });
  }
  */
  function ValidarNroTransporte() {
    Ext.Ajax.request({
      url: 'AjaxPages/AjaxViajes.aspx?Metodo=ValidarNroTransporte',
      params: {
        nroTransporte: Ext.getCmp('numberNroTransporte').getValue()
      },
      success: function (data, success) {
        if (data != null) {
          data = (data.responseText.toLowerCase() == 'true');
          if (!data) {
            Ext.getCmp('numberNroTransporte').markInvalid("El Nro. de transporte se encuentra repetido.");
          }
          else {
            Ext.getCmp('numberNroTransporte').clearInvalid();
          }
        }
      },
      failure: function (msg) {
        alert('Se ha producido un error.');
      }
    });
  }


  function GuardarViaje() {
    var flag = true;
    var message = '';
    var _vertices = new Array();

    if (Ext.getCmp('numberNroTransporte').hasActiveError()) {
      return;
    }
    if (Ext.getCmp('comboFiltroPatenteTracto').hasActiveError()) {
      return;
    }
    if (Ext.getCmp('comboFiltroPatenteTrailer').hasActiveError()) {
      return;
    }
    if (Ext.getCmp('comboZonaOrigen').hasActiveError()) {
      return;
    }
    if (Ext.getCmp('comboZonaDestino').hasActiveError()) {
      return;
    }

    if (!Ext.getCmp('formCrearViaje').getForm().isValid() || !Ext.getCmp("numberNroTransporte").getValue > 0) {
      return;
    }

    if (!_editing) {
      //Nuevo Viaje
      Ext.Ajax.request({
        url: 'AjaxPages/AjaxViajes.aspx?Metodo=NuevoViaje',
        params: {
          'nroTransporte': Ext.getCmp('numberNroTransporte').getValue(),
          'transportista': Ext.getCmp('comboFiltroTransportista').getValue(),
          'trailer': Ext.getCmp('comboFiltroPatenteTrailer').getValue(),
          'tracto': Ext.getCmp('comboFiltroPatenteTracto').getValue(),
          'codOrigen': Ext.getCmp('comboZonaOrigen').getValue(),
          'codRuta': Ext.getCmp("comboRuta").getValue(),
          'rutConductor': Ext.getCmp('textRutConductor').getValue(),
          'nombreConductor': Ext.getCmp('textNombreConductor').getValue()
        },
        success: function (msg, success) {
          //alert(msg.responseText);

          Cancelar();

          Ext.getCmp('gridViajesAsignados').getStore().load();
          _editing = false;

        },
        failure: function (msg) {
          alert('Se ha producido un error.');
        }
      });
    }
    else {
      //Editar Viaje

      Ext.Ajax.request({
        url: 'AjaxPages/AjaxViajes.aspx?Metodo=EditarViaje',
        params: {
          'nroTransporte': Ext.getCmp('numberNroTransporte').getValue(),
          'transportista': Ext.getCmp('comboFiltroTransportista').getValue(),
          'trailer': Ext.getCmp('comboFiltroPatenteTrailer').getValue(),
          'tracto': Ext.getCmp('comboFiltroPatenteTracto').getValue(),
          'codOrigen': Ext.getCmp('comboZonaOrigen').getValue(),
          'codDestino': Ext.getCmp('comboZonaDestino').getValue(),
          'rutConductor': Ext.getCmp('textRutConductor').getValue(),
          'nombreConductor': Ext.getCmp('textNombreConductor').getValue()
        },
        success: function (msg, success) {

          alert(msg.responseText);

          Cancelar();

          Ext.getCmp('gridViajesAsignados').getStore().load();
          _editing = false;

        },
        failure: function (msg) {
          alert('Se ha producido un error.');
        }

      });
    }
  }

  function Salir()  {
      Ext.getCmp("winConfigurarRutas").hide();

      Ext.getCmp("gridPanelRutasGeneradas").getSelectionModel().deselectAll();

      Ext.getCmp("gridPanelDetalleRuta").store.removeAll();
      Ext.getCmp("gridPanelDetalleRuta").setDisabled(true);

      Ext.getCmp("btnNuevaRuta").setDisabled(true);
      Ext.getCmp("textNombreNuevaRuta").reset();
  }

  function AgregarDestinoRuta() {

      var idRuta = Ext.getCmp("gridPanelRutasGeneradas").getView().getSelectionModel().getLastSelected().data.IdRuta;
      var idZona = Ext.getCmp("comboAgregarZonaDestino").getValue();

      if (idZona == null)
      {
          return;
      }

      Ext.Ajax.request({
          url: 'AjaxPages/AjaxViajes.aspx?Metodo=AgregarDestinoRuta',
          params: {
              'idRuta': idRuta,
              'idZona': idZona,
          },
          success: function (data, success) {
              if (data != null) {
                  Ext.getCmp("gridPanelDetalleRuta").store.load({
                      params: {
                          IdRuta: idRuta
                      }
                  });

                  Ext.getCmp("comboAgregarZonaDestino").reset();
              }
          },
          failure: function (msg) {
              alert('Se ha producido un error.');
          }
      });

  }

  function loadExcel() {

      Ext.Msg.wait('Espere por favor...', 'Cargando archivo');

      Ext.getCmp('formUploadExcel').getForm().submit({
          url: 'AjaxPages/AjaxViajes.aspx?Metodo=CargaViajesExcel',
          waitMsg: 'Cargando archivo...',
          success: function (data, success) {
              Ext.Msg.hide();
              Ext.getCmp("gridViajesAsignados").getStore().load();
              Ext.getCmp("winUploadExcel").hide();

          }
      })
      
  }


</script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
  <div id="dvMap"></div>
</asp:Content>
  