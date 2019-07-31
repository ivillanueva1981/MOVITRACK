  <%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Rpt_Alertas.aspx.cs" Inherits="Track_Web.Rpt_Alertas" %>
  <asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
  AltoTrack Platform 
  </asp:Content>

  <asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&libraries=visualization&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8" type="text/javascript"></script>
    <script src="Scripts/MapFunctions.js" type="text/javascript"></script>
    <script src="Scripts/markerclusterer.js" type="text/javascript"></script>
    <script src="Scripts/TopMenu.js" type="text/javascript"></script>
    <script src="Scripts/LabelMarker.js" type="text/javascript"></script>
    <script src="Scripts/OverlappingMarkerSpiderfier.min.js" type="text/javascript"></script>

  <script type="text/javascript">

    var heatMapData = new Array();
    var heatMap;
    var markerCluster;
    var oms;
    var geoLayer = new Array();
    var arrayAlerts = new Array();
    var infowindow = new google.maps.InfoWindow();
    var markersVertices = new Array();

    //var loadingStore = 0;

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

      var storeZonas = new Ext.data.JsonStore({
          id: 'storeZonas',
          autoLoad: true,
          fields: ['IdZona', 'NombreZona', 'IdTipoZona', 'NombreTipoZona', 'Latitud', 'Longitud'],
          proxy: new Ext.data.HttpProxy({
              url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonas',
              reader: { type: 'json', root: 'Zonas' },
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });

      var comboZonas = new Ext.form.field.ComboBox({
          id: 'comboZonas',
          store: storeZonas
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
        }
      });

      var hourDesde = {
          xtype: 'timefield',
          id: 'hourDesde',
          allowBlank: false,
          format: 'H:i',
          minValue: '00:00',
          maxValue: '23:59',
          increment: 10,
          anchor: '100%',
          editable: true,
          value: '00:00'
      };

      var dateHasta = new Ext.form.DateField({
        id: 'dateHasta',
        fieldLabel: 'Hasta',
        labelWidth: 100,
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

      var hourHasta = {
          xtype: 'timefield',
          id: 'hourHasta',
          allowBlank: false,
          format: 'H:i',
          minValue: '00:00',
          maxValue: '23:59',
          increment: 10,
          anchor: '100%',
          editable: true,
          value: new Date()
      };

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
        multiSelect: true,
        style: {
          marginLeft: '5px'
        },
        listeners: {
          change: function (field, newVal) {
            if (newVal != null) {
                FiltrarPatentes();
                FiltrarProveedoresGPS();
            }
            Ext.getCmp("comboFiltroPatente").setValue("Todas");

            Ext.getCmp("comboFiltroProveedorGPS").setValue("Todos");
          }
        }
      });
        
      var storeFiltroProveedorGPS = new Ext.data.JsonStore({
          fields: ['ProveedorGPS'],
          proxy: new Ext.data.HttpProxy({
              url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetProveedoresGPS&Todos=True',
              headers: {
                  'Content-type': 'application/json'
              }
          }),
          autoLoad: false
      });
      
      var comboFiltroProveedorGPS = new Ext.form.field.ComboBox({
          id: 'comboFiltroProveedorGPS',
          fieldLabel: 'Proveedor GPS',
          forceSelection: true,
          store: storeFiltroProveedorGPS,
          valueField: 'ProveedorGPS',
          displayField: 'ProveedorGPS',
          queryMode: 'local',
          anchor: '99%',
          labelWidth: 100,
          style: {
              marginLeft: '5px'
          },
          emptyText: 'Seleccione...',
          enableKeyEvents: true,
          editable: true,
          multiSelect: true

      });
        
      storeFiltroProveedorGPS.load({
          params: {
              Transportista: "Todos"
          },
          callback: function (r, options, success) {
              if (success) {
                  Ext.getCmp("comboFiltroProveedorGPS").setValue("Todos");
              }
          }
      })
      
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
        labelWidth: 100,
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
                  Ext.getCmp("comboFiltroTransportista").setValue("Todos");

                  //var firstTransportista = Ext.getCmp("comboFiltroTransportista").store.getAt(0).get("Transportista");
                  //Ext.getCmp("comboFiltroTransportista").setValue(firstTransportista);
                  

                  storeFiltroPatente.load({
                      callback: function (r, options, success) {
                          if (success) {
                              Ext.getCmp("comboFiltroPatente").setValue("Todas");
                          }
                      }
                  });

                  /*
                  storeFiltroProveedorGPS.load({
                      params: {
                          Transportista: 'Todos'
                      },
                      callback: function (r, options, success) {
                          if (success) {
                              Ext.getCmp("comboFiltroProveedorGPS").setValue("Todos");
                          }
                      }
                  })*/
              }
        }
      })
        
      var storeFiltroScoreConductor = new Ext.data.JsonStore({
          fields: ['Score'],
          data: [{ Score: 'Todos' },
                   { Score: 'Blanco' },
                   { Score: 'Verde' },
                   { Score: 'Amarillo' },
                   { Score: 'Rojo' }
          ]
      });

      var comboFiltroScoreConductor = new Ext.form.field.ComboBox({
          id: 'comboFiltroScoreConductor',
          fieldLabel: 'Score conductor',
          store: storeFiltroScoreConductor,
          valueField: 'Score',
          displayField: 'Score',
          emptyText: 'Seleccione...',
          queryMode: 'local',
          anchor: '99%',
          labelWidth: 100,
          editable: false,
          style: {
              marginLeft: '5px'
          },
          emptyText: 'Seleccione...',
          enableKeyEvents: true,
          forceSelection: true,
      });

      Ext.getCmp('comboFiltroScoreConductor').setValue('Todos');
      
      var storeFiltroConductores = new Ext.data.JsonStore({
        autoLoad: false,
        fields: ['RutConductor', 'NombreConductor'],
        proxy: new Ext.data.HttpProxy({
          url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetConductores&Todos=True',
          reader: { type: 'json', root: 'Zonas' },
          headers: {
            'Content-type': 'application/json'
          }
        })
      });

      var comboFiltroConductores = new Ext.form.field.ComboBox({
        id: 'comboFiltroConductores',
        fieldLabel: 'Conductor',
        allowBlank: false,
        store: storeFiltroConductores,
        valueField: 'RutConductor',
        displayField: 'NombreConductor',
        queryMode: 'local',
        anchor: '99%',
        forceSelection: true,
        enableKeyEvents: true,
        editable: true,
        labelWidth: 100,
        style: {
          marginLeft: '5px'
        },
        emptyText: 'Seleccione...',
        listConfig: {
          loadingText: 'Buscando...',
          getInnerTpl: function () {
            return '<a class="search-item">' +
                            '<span>Rut: {RutConductor}</span><br />' +
                            '<span>Nombre: {NombreConductor}</span>' +
                        '</a>';
          }
        }
      });

      storeFiltroConductores.load({
        callback: function (r, options, success) {
          if (success) {
            Ext.getCmp("comboFiltroConductores").setValue("Todos");
          }
        }
      });

      var storeFiltroAlertas = new Ext.data.JsonStore({
        autoLoad: true,
        fields: ['NombreTipoAlerta'],
        proxy: new Ext.data.HttpProxy({
          url: 'AjaxPages/AjaxAlertas.aspx?Metodo=GetNombreTipoAlertas',
          headers: {
            'Content-type': 'application/json'
          }
        })
      });

      var comboFiltroAlertas = new Ext.form.field.ComboBox({
        id: 'comboFiltroAlertas',
        fieldLabel: 'Tipo alerta',
        store: storeFiltroAlertas,
        valueField: 'NombreTipoAlerta',
        displayField: 'NombreTipoAlerta',
        queryMode: 'local',
        anchor: '99%',
        labelWidth: 100,
        editable: false,
        multiSelect: true,
        allowBlank: false,
        style: {
          marginLeft: '5px'
        },
        emptyText: 'Seleccione...',
        enableKeyEvents: true,
        forceSelection: true,
        listeners: {
          select: function () {
            //FiltrarFlota();
          }
        }
      });

      storeFiltroAlertas.load({
        callback: function (r, options, success) {
          if (success) {
            Ext.getCmp("comboFiltroAlertas").setValue("DETENCION");
          }
        }
      });

      var storeFiltroFormatos = new Ext.data.JsonStore({
          autoLoad: false,
          fields: ['Id', 'Nombre'],
          proxy: new Ext.data.HttpProxy({
              url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetFormatos&Todos=True',
              reader: { type: 'json', root: 'Zonas' },
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });

      var comboFiltroFormatos = new Ext.form.field.ComboBox({
          id: 'comboFiltroFormatos',
          fieldLabel: 'Formato',
          allowBlank: false,
          store: storeFiltroFormatos,
          valueField: 'Id',
          displayField: 'Nombre',
          queryMode: 'local',
          anchor: '99%',
          forceSelection: true,
          enableKeyEvents: true,
          editable: true,
          labelWidth: 100,
          style: {
              marginLeft: '5px'
          },
          emptyText: 'Seleccione...',
          listeners: {
              change: function (field, newVal) {
                  if (newVal != null) {
                      FiltrarLocales();
                  }
              }
          }
      });

      storeFiltroFormatos.load({
          callback: function (r, options, success) {
              if (success) {
                  Ext.getCmp("comboFiltroFormatos").setValue(0);
              }
          }
      });

      var storeFiltroLocales = new Ext.data.JsonStore({
          autoLoad: true,
          fields: ['CodigoInterno', 'IdFormato', 'NumeroLocal'],
          proxy: new Ext.data.HttpProxy({
              url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetLocales',
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });

      var comboFiltroLocales = new Ext.form.field.ComboBox({
          id: 'comboFiltroLocales',
          fieldLabel: 'Local',
          store: storeFiltroLocales,
          valueField: 'CodigoInterno',
          displayField: 'NumeroLocal',
          queryMode: 'local',
          anchor: '99%',
          labelWidth: 100,
          allowBlank: false,
          editable: true,
          style: {
              marginLeft: '5px'
          },
          emptyText: 'Seleccione...',
          enableKeyEvents: true,
          forceSelection: true,
          listeners: {
              select: function () {
                  //FiltrarFlota();
              }
          }
      });

      storeFiltroLocales.load({
          callback: function (r, options, success) {
              if (success) {
                  Ext.getCmp("comboFiltroLocales").setValue(0);
              }
          }
      });

      var storeFiltroPermiso = new Ext.data.JsonStore({
          fields: ['Permiso'],
          data: [{ Permiso: 'Todas' },
                   { Permiso: 'AUTORIZADA' },
                   { Permiso: 'NO AUTORIZADA' }
          ]
      });

      var comboFiltroPermiso = new Ext.form.field.ComboBox({
          id: 'comboFiltroPermiso',
          fieldLabel: 'Permiso',
          store: storeFiltroPermiso,
          valueField: 'Permiso',
          displayField: 'Permiso',
          emptyText: 'Seleccione...',
          queryMode: 'local',
          anchor: '99%',
          labelWidth: 100,
          editable: false,
          style: {
              marginLeft: '5px'
          },
          emptyText: 'Seleccione...',
          enableKeyEvents: true,
          forceSelection: true,
      });

      Ext.getCmp('comboFiltroPermiso').setValue('Todas');

      var storeFiltroEstadoViaje = new Ext.data.JsonStore({
          fields: ['EstadoViaje', 'NombreEstadoViaje'],
          data: [ { EstadoViaje: 'Todos', NombreEstadoViaje: 'Todos', },
                  { EstadoViaje: 'EnLocal-P', NombreEstadoViaje: 'Finalizado' },
                  { EstadoViaje: 'Cerrado por Sistema', NombreEstadoViaje: 'Cerrado por Sistema' }
          ]
      });

      var comboFiltroEstadoViaje = new Ext.form.field.ComboBox({
          id: 'comboFiltroEstadoViaje',
          fieldLabel: 'Estado viaje',
          store: storeFiltroEstadoViaje,
          valueField: 'EstadoViaje',
          displayField: 'NombreEstadoViaje',
          queryMode: 'local',
          anchor: '99%',
          labelWidth: 100,
          editable: false,
          style: {
              marginLeft: '5px'
          },
          emptyText: 'Seleccione...',
          enableKeyEvents: true,
          forceSelection: true
      });

      Ext.getCmp('comboFiltroEstadoViaje').setValue('Todos');

      var radioGroupViewMapType = new Ext.form.RadioGroup({
          id: 'radioGroupViewMapType',
          fieldLabel: 'Tipo de mapa',
          labelWidth: 100,
          // Arrange radio buttons into three columns, distributed vertically
          columns: 1,
          style: {
              marginLeft: '5px'
          },
          vertical: true,
          items: [
              { boxLabel: 'Mapa de calor', name: 'mt', inputValue: '1', checked: true },
              { boxLabel: 'Concentración', name: 'mt', inputValue: '2'}
          ]
      });

      var chkMostrarZonas = new Ext.form.Checkbox({
          id: 'chkMostrarZonas',
          fieldLabel: 'Mostrar Zonas',
          labelWidth: 100,
          style: {
              marginLeft: '5px'
          },
          listeners: {
              change: function (cb, checked) {
                  if (checked == true) {
                      MostrarZonas();
                  }
                  else {
                      eraseAllZones();
                  }
              }
          }
      });

      var chkMostrarLabels = new Ext.form.Checkbox({
          id: 'chkMostrarLabels',
          fieldLabel: 'Mostrar Etiquetas',
          labelWidth: 100,
          style: {
              marginLeft: '5px'
          },
          listeners: {
              change: function (cb, checked) {
                  if (checked == true) {
                      for (var i = 0; i < zoneLabels.length; i++) {
                          zoneLabels[i].setMap(map);
                      }
                  }
                  else {
                      for (var i = 0; i < zoneLabels.length; i++) {
                          zoneLabels[i].setMap(null);
                      }
                  }
              }
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

      var panelFilters = new Ext.FormPanel({
        id: 'panelFilters',
        title: 'Filtros',
        anchor: '100% 100%',
        bodyStyle: 'padding: 5px;',
        layout: 'column',
        items: [{
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 0.75,
            items: [dateDesde, dateHasta]
        }, {
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 0.24,
            items: [hourDesde, hourHasta]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 1,
          items: [comboFiltroTransportista]
        }, {
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 1,
            items: [comboFiltroProveedorGPS]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 1,
          items: [comboFiltroPatente]
        }, {
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 1,
            items: [comboFiltroScoreConductor]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 1,
          items: [comboFiltroConductores]
        }, {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 1,
          items: [comboFiltroAlertas]
        }, {
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 1,
            items: [comboFiltroEstadoViaje]
        },
            {
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 1,
            items: [comboFiltroPermiso]
        },
        
        {
          xtype: 'container',
          layout: 'anchor',
          columnWidth: 1,
          items: [radioGroupViewMapType]
        }, {
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 1,
            items: [chkMostrarZonas]
        }, {
            xtype: 'container',
            layout: 'anchor',
            columnWidth: 1,
            items: [chkMostrarLabels]
        }],
        buttons: [btnBuscar]
      });

      var storeAlertas = new Ext.data.JsonStore({
        autoLoad: false,
        fields: [{ name: 'FechaInicioAlerta', type: 'date', dateFormat: 'c' },
                    { name: 'FechaHoraCreacion', type: 'date', dateFormat: 'c' },
                    'TextFechaCreacion',
                    'NroTransporte',
                    'CodigoDestino',
                    'NombreDestino',
                    'TipoAlerta',
                    'DescripcionAlerta',
                    'PatenteTracto',
                    'PatenteTrailer',
                    'Transportista',
                    'Velocidad',
                    'Latitud',
                    'Longitud',
                    'Ocurrencia',
                    'Temp1',
                    'Permiso',
                    'Formato',
                    'EstadoViaje',
                    'NombreConductor',
                    'ScoreConductor',
                    'Discrepancia',
                    'DistanciaCliente'
                    ],
        proxy: new Ext.data.HttpProxy({
          url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetRpt_Alertas',
          reader: { type: 'json', root: 'Zonas' },
          headers: {
            'Content-type': 'application/json'
          }
        })
      });

      var gridPanelAlertas = Ext.create('Ext.grid.Panel', {
        id: 'gridPanelAlertas',
        title: 'Alertas',
        //hideCollapseTool: true,
        store: storeAlertas,
        anchor: '100% 100%',
        columnLines: true,
        scroll: false,
        viewConfig: {
          style: { overflow: 'auto', overflowX: 'hidden' }
        },
        columns: [
                  { text: 'Fecha Inicio', sortable: true, width: 110, dataIndex: 'FechaInicioAlerta', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                  { text: 'Fecha Envío', sortable: true, width: 110, dataIndex: 'FechaHoraCreacion', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                  { text: 'Nro. Transporte', sortable: true, dataIndex: 'PatenteTracto' },
                  { text: 'Destino', sortable: true, dataIndex: 'NombreDestino' },
                  { text: 'Tracto', sortable: true, dataIndex: 'PatenteTracto' },
                  { text: 'Trailer', sortable: true, dataIndex: 'PatenteTrailer' },
                  { text: 'Velocidad', sortable: true, dataIndex: 'Velocidad' },
                  { text: 'Descripción', sortable: true, flex: 1, dataIndex: 'DescripcionAlerta' }
                ]
      });
        
      var storeAreaSeleccionada = new Ext.data.JsonStore({
          autoLoad: false,
          fields: [   'Nombre',
                      'Cantidad',
                      'Entidad'
          ],
          proxy: new Ext.data.HttpProxy({
              url: 'AjaxPages/AjaxReportes.aspx?Metodo=GetRpt_Alertas_DetalleArea',
              reader: { type: 'json', root: 'Zonas' },
              headers: {
                  'Content-type': 'application/json'
              }
          })
      });
        
      var gridPanelDetalleAreaSeleccionada = Ext.create('Ext.grid.Panel', {
          id: 'gridPanelAreaSeleccionada',
          store: storeAreaSeleccionada,
          anchor: '100% 100%',
          columnLines: true,
          scroll: false,
          columns: [
                    { text: 'Nombre', dataIndex: 'Nombre' },
                    { text: 'Cantidad', dataIndex: 'Cantidad' },
                    { text: 'Entidad', dataIndex: 'Entidad' }
          ]
      });
      
      var viewWidth = Ext.getBody().getViewSize().width;
      var viewHeight = Ext.getBody().getViewSize().height;
        
      var textCantAlertas = new Ext.form.TextField({
          id: 'textCantAlertas',
          fieldLabel: 'Cantidad de alertas',
          labelWidth: 120,
          anchor: '99%',
          readOnly: true
      });

      var textCantViajes = new Ext.form.TextField({
          id: 'textCantViajes',
          fieldLabel: 'Cantidad de viajes',
          labelWidth: 120,
          anchor: '99%',
          readOnly: true
      });

      var storeDetallePorTransportista = new Ext.data.JsonStore({
          fields: ['Transportista', 'Cantidad']
      });

      var gridPanelPorTransportista = Ext.create('Ext.grid.Panel', {
          id: 'gridPanelPorTransportista',
          //hideCollapseTool: true,
          store: storeDetallePorTransportista,
          width: 160,
          height: 100,
          columnLines: true,
          scroll: false,
          viewConfig: {
              style: { overflow: 'auto', overflowX: 'hidden' }
          },
          columns: [
                    { text: 'Transportista', sortable: true, dataIndex: 'Transportista' },
                    { text: 'Cantidad', sortable: true, dataIndex: 'Cantidad' }
          ]
      });

      var storeDetallePorProveedor = new Ext.data.JsonStore({
          fields: ['ProveedorGPS', 'Cantidad']
      });

      var gridPanelPorProveedor = Ext.create('Ext.grid.Panel', {
          id: 'gridPanelPorProveedor',
          //hideCollapseTool: true,
          store: storeDetallePorProveedor,
          width: 160,
          height: 100,
          columnLines: true,
          scroll: false,
          viewConfig: {
              style: { overflow: 'auto', overflowX: 'hidden' }
          },
          columns: [
                    { text: 'Proveedor', sortable: true, dataIndex: 'ProveedorGPS' },
                    { text: 'Cantidad', sortable: true, dataIndex: 'Cantidad' }
          ]
      });

      var btnLimpiarArea = {
          id: 'btnLimpiarArea',
          xtype: 'button',
          iconAlign: 'left',
          icon: 'Images/eraser_20x20.png',
          text: 'Borrar área',
          width: 100,
          height: 26,
          handler: function () {
              BorrarArea();
          }
      };

      var winAreaSeleccionada = new Ext.Window({
          id: 'winAreaSeleccionada',
          title: 'Área seleccionada',
          width: 100,
          height: 392,
          closable: true,
          closeAction: 'hide',
          modal: false,
          initCenter: false,
          x: viewWidth - 210,
          y: 45,
          items: [{
              xtype: 'container',
              layout: 'anchor',
              style: 'padding-top:3px;padding-left:5px;',
              items: [textCantAlertas]
          }, {
              xtype: 'container',
              layout: 'anchor',
              style: 'padding-left:5px;',
              items: [textCantViajes]
          }, {
              xtype: 'fieldset',
              title: 'Alertas por Transportista',
              style: {
                  marginLeft: '2px',
                  marginRight: '2px'
                  },

              items: [gridPanelPorTransportista]
          }, {
              xtype: 'fieldset',
              title: 'Alertas por Proveedor',
              style: {
                  marginLeft: '2px',
                  marginRight: '2px'
              },

              items: [gridPanelPorProveedor]
          }
          ],
          resizable: false,
          border: true,
          draggable: false,
          buttons: [btnLimpiarArea]
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

      leftPanel.on('collapse', function () {
        google.maps.event.trigger(map, "resize");
      });

      leftPanel.on('expand', function () {
        google.maps.event.trigger(map, "resize");
      });

      var centerPanel = new Ext.FormPanel({
        id: 'centerPanel',
        region: 'center',
        border: true,
        margins: '0 3 3 0',
        anchor: '100% 100%',
        contentEl: 'dvMap'
      });

      var viewport = Ext.create('Ext.container.Viewport', {
        layout: 'border',
        items: [topMenu, leftPanel, centerPanel]
      });

      viewport.on('resize', function () {
          google.maps.event.trigger(map, "resize");
          Ext.getCmp('winAreaSeleccionada').setPosition(Ext.getBody().getViewSize().width - 210, 50, true)
      });

    }); 

  </script>


  <script type="text/javascript">

    var zoneLabels = new Array();

    Ext.onReady(function () {
        GeneraMapa("dvMap", true);
        //google.maps.event.addListener(map, 'click', CreateMarkerPolyLine);

        heatMap = new google.maps.visualization.HeatmapLayer({
        data: heatMapData
      });
      //heatMap.setMap(map);

    });

    function FiltrarPatentes() {
      var transportista = Ext.getCmp('comboFiltroTransportista').getValue();

      var store = Ext.getCmp('comboFiltroPatente').store;
      store.load({
        params: {
          transportista: transportista
        }
      });
    }

    function FiltrarProveedoresGPS() {
        var transportista = Ext.getCmp('comboFiltroTransportista').getValue();

        var store = Ext.getCmp('comboFiltroProveedorGPS').store;
        store.load({
            params: {
                Transportista: transportista
            }
        });
    }

    function Buscar() {

        if (!Ext.getCmp('leftPanel').getForm().isValid()) {
            return;
        }

        oms = new OverlappingMarkerSpiderfier(map, { markersWontMove: true, markersWontHide: true, keepSpiderfied: true });
        oms.addListener('click', function (marker, event) {

            infowindow.setContent(marker.labelText);
            infowindow.open(map, marker);

        });

      ClearMap();
      arrayAlerts.splice(0, arrayAlerts.length);

      BorrarArea();

      Ext.Msg.wait('Espere por favor...', 'Generando');

      heatMapData = [];
      heatMap.setMap(null);

      for (var i = 0; i < markers.length; i++) {
        markers[i].setMap(null)
      }
      markers = [];

      if (markerCluster != null) {
        markerCluster.clearMarkers();
      }

      //var desde = Ext.getCmp('dateDesde').getValue();
      //var hasta = Ext.getCmp('dateHasta').getValue();
      var desde = Ext.getCmp('dateDesde').getRawValue() + " " + Ext.getCmp('hourDesde').getRawValue();
      var hasta = Ext.getCmp('dateHasta').getRawValue() + " " + Ext.getCmp('hourHasta').getRawValue();
      var transportista = Ext.getCmp('comboFiltroTransportista').getValue();
      var proveedorGPS = Ext.getCmp('comboFiltroProveedorGPS').getValue();
      var patente = Ext.getCmp('comboFiltroPatente').getValue();
      var rutConductor = Ext.getCmp('comboFiltroConductores').getValue();
      var tipoAlerta = Ext.getCmp('comboFiltroAlertas').getValue();
      var idFormato = Ext.getCmp('comboFiltroFormatos').getValue();
      var codigoLocal = Ext.getCmp('comboFiltroLocales').getValue();
      var permiso = Ext.getCmp('comboFiltroPermiso').getValue();
      var estadoViaje = Ext.getCmp('comboFiltroEstadoViaje').getValue();
      var scoreConductor = Ext.getCmp('comboFiltroScoreConductor').getValue();

      var store = Ext.getCmp('gridPanelAlertas').store;
      store.load({
        params: {
          desde: desde,
          hasta: hasta,
          transportista: transportista,
          proveedorGPS: proveedorGPS,
          patente: patente,
          scoreConductor: scoreConductor,
          rutConductor: rutConductor,
          tipoAlerta: tipoAlerta,
          idFormato: idFormato,
          codigoLocal: codigoLocal,
          permiso: permiso,
          estadoViaje: estadoViaje
         },
        callback: function (r, options, success) {
          if (!success) {
            Ext.MessageBox.show({
              title: 'Error',
              msg: 'Se ha producido un error.',
              buttons: Ext.MessageBox.OK
            });
          }
          else {

              for (var i = 0; i < store.count() ; i++) {
              var lat = store.data.items[i].raw.Latitud;
              var lon = store.data.items[i].raw.Longitud;
              var latLng = new google.maps.LatLng(store.getAt(i).data.Latitud, store.getAt(i).data.Longitud);
              heatMapData.push(latLng);
              
              var nroTransporte = store.data.items[i].raw.NroTransporte.toString();  
              var fecha = store.data.items[i].raw.FechaHoraCreacion.toString();
              var textFechaCreacion = store.data.items[i].raw.TextFechaCreacion;
              var transportista = store.data.items[i].raw.Transportista;
              var proveedorGPS = store.data.items[i].raw.ProveedorGPS;
              var velocidad = store.data.items[i].raw.Velocidad;
              var temperatura = store.data.items[i].raw.Temp1;
              var descripcion = store.data.items[i].raw.DescripcionAlerta;
              var permiso = store.data.items[i].raw.Permiso;
              var formato = store.data.items[i].raw.Formato;
              var codigoLocal = store.data.items[i].raw.CodigoDestino;
              var estadoViaje = store.data.items[i].raw.EstadoViaje;
              var tipoAlerta = store.data.items[i].raw.TipoAlerta;
              var nombreConductor = store.data.items[i].raw.NombreConductor;
              var scoreConductor = store.data.items[i].raw.ScoreConductor;
              var discrepancia = store.data.items[i].raw.Discrepancia;
              var distanciaCliente = store.data.items[i].raw.DistanciaCliente;

              if (estadoViaje == "EnLocal-P")
              {
                 estadoViaje = "Finalizado"   
              }

              arrayAlerts.push({
                  NroTransporte: nroTransporte,
                  Fecha: fecha,
                  TextFechaCreacion: textFechaCreacion,
                  Transportista: transportista,
                  ProveedorGPS: proveedorGPS,
                  Velocidad: velocidad,
                  Latitud: lat,
                  Longitud: lon,
                  LatLng: latLng,
                  //Puerta: puerta,
                  Temperatura: temperatura,
                  Descripcion: descripcion,
                  Permiso: permiso,
                  Formato: formato,
                  CodigoLocal: codigoLocal,
                  EstadoViaje: estadoViaje,
                  NombreConductor: nombreConductor,
                  ScoreConductor: scoreConductor,
                  Discrepancia: discrepancia,
              });

              var contentString =
                                    '<br>' +
                                        '<table>' +
                                        '<tr>' +
                                            '       <td><b>Nro. Transporte</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '       <td>' + nroTransporte + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '       <td><b>Fecha</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '       <td>' + textFechaCreacion + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Transportista:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + transportista + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Proveedor GPS:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + proveedorGPS + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Formato:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + formato + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Local:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + codigoLocal + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Descripción:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + descripcion + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Permiso:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + permiso + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Estado viaje:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + estadoViaje + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Conductor:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + nombreConductor + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Score conductor:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + scoreConductor + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Coordenadas:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + lat + ',' + lon + '</td>' +
                                        '</tr>' +

                                        '</table>' +
                                    '<br>';
                  /*
              switch(tipoAlerta)
              {
                  case "TEMPERATURA":
                      marker = new google.maps.Marker({
                          position: latLng,
                          icon: 'Images/Alertas/snow_blue_23x23.png',
                          //map: map,
                          labelText: contentString
                      });
                      break;

                  case "PERDIDA SEÑAL":
                      marker = new google.maps.Marker({
                          position: latLng,
                          icon: 'Images/Alertas/signal_purple_23x23.png',
                          //map: map,
                          labelText: contentString
                      });
                      break;

                  case "APERTURA PUERTA":
                      marker = new google.maps.Marker({
                          position: latLng,
                          icon: 'Images/Alertas/unlock_blue_23x23.png',
                          //map: map,
                          labelText: contentString
                      });
                      break;

                  case "DETENCION":
                      marker = new google.maps.Marker({
                          position: latLng,
                          icon: 'Images/Alertas/dot_stop_red_23x23.png',
                          //map: map,
                          labelText: contentString
                      });
                      break;

                  default:
                      marker = new google.maps.Marker({
                          position: latLng,
                          icon: 'Images/Alertas/alert_orange_22x22.png',
                          //map: map,
                          labelText: contentString
                      });

              }
              */

              if (distanciaCliente < 200)
              {
                  marker = new google.maps.Marker({
                      position: latLng,
                      icon: 'Images/Alertas/alert_blue_26x26.png',
                      labelText: contentString
                  });
              }
              else
              {
                  marker = new google.maps.Marker({
                      position: latLng,
                      icon: 'Images/Alertas/alert_orange_26x26.png',
                      //map: map,
                      labelText: contentString
                  });
              }

              markers.push(marker);
              oms.addMarker(marker);

            }

            var viewMapType = Ext.getCmp("radioGroupViewMapType").getValue().mt;

            if (viewMapType == '1') {
              heatMap = new google.maps.visualization.HeatmapLayer({
                data: heatMapData,
                radius: 30,
                opacity: 0.75,
                dissipating: true,
                map: map
              });
            }
            else if (viewMapType == '2')
            {
                markerCluster = new MarkerClusterer(map, markers);
                markerCluster.setMaxZoom(16);
            }

            Ext.Msg.hide();
          }

        }
      });
    }

    function MostrarZonas() {

        Ext.Msg.wait('Espere por favor...', 'Generando zonas');

        var countZonas = Ext.getCmp('comboZonas').store.count()

        for (i = 0; i < countZonas; i++) {
            var idZona = Ext.getCmp("comboZonas").store.data.getAt(i).data.IdZona;
            var idTipoZona = Ext.getCmp("comboZonas").store.data.getAt(i).data.IdTipoZona;

            DrawZone(idZona, idTipoZona);
        }

        Ext.Ajax.request({
            url: 'AjaxPages/AjaxFunctions.aspx?Metodo=ProgressBarCall',
            success: function (response, opts) {

                var task = new Ext.util.DelayedTask(function () {
                    Ext.Msg.hide();
                });

                task.delay(1500);

            },
            failure: function (response, opts) {
                Ext.Msg.hide();
            }
        });
    }

    function DrawZone(idZona, idTipoZona) {

        if (containsZone(geoLayer, idZona) == true) {
            return;
        }

        if (idTipoZona == 3 || idTipoZona == 11) {
            var colorZone = "#FF0000";
        }
        else {
            var colorZone = "#7f7fff";
        }

        Ext.Ajax.request({
            url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetVerticesZona',
            params: {
                IdZona: idZona
            },
            success: function (data, success) {
                if (data != null) {
                    data = Ext.decode(data.responseText);
                    if (data.Vertices.length > 1) { //Polygon
                        var polygonGrid = new Object();
                        polygonGrid.IdZona = data.IdZona;

                        var arr = new Array();
                        for (var i = 0; i < data.Vertices.length; i++) {
                            arr.push(new google.maps.LatLng(data.Vertices[i].Latitud, data.Vertices[i].Longitud));
                        }
                        polygonGrid.layer = new google.maps.Polygon({
                            paths: arr,
                            strokeColor: "#000000",
                            strokeWeight: 1,
                            strokeOpacity: 0.9,
                            fillColor: colorZone,
                            fillOpacity: 0.3,
                            labelText: data.NombreZona
                        });

                        var viewLabel = Ext.getCmp('chkMostrarLabels').getValue();
                        polygonGrid.label = new Label({
                            text: idZona,
                            position: new google.maps.LatLng(data.Latitud, data.Longitud),
                            map: viewLabel ? map : null
                        });

                        polygonGrid.label.bindTo('text', polygonGrid.layer, 'labelText');
                        polygonGrid.layer.setMap(map);
                        geoLayer.push(polygonGrid);

                        if (containsLabel(zoneLabels, idZona) == false) {
                            zoneLabels.push(polygonGrid.label);
                        }
                    }

                }
            },
            failure: function (msg) {
                alert('Se ha producido un error.');
            }
        });
    }

    function containsZone(a, obj) {
        var i = a.length;
        while (i--) {
            if (a[i].IdZona === obj) {
                return true;
            }
        }
        return false;
    }

    function containsLabel(a, obj) {
        var i = a.length;
        while (i--) {GetDetalleAreaSeleccionada
            if (a[i].text === obj) {
                return true;
            }
        }
        return false;
    }

    function eraseAllZones() {
        var countZonas = Ext.getCmp('comboZonas').store.count()

        for (i = 0; i < countZonas; i++) {
            var idZona = Ext.getCmp("comboZonas").store.data.getAt(i).data.IdZona;
            EraseZone(idZona);
        }

    zoneLabels = [];
    }

    function EraseZone(idZona) {
        for (var i = 0; i < geoLayer.length; i++) {
            if (idZona == geoLayer[i].IdZona) {
                geoLayer[i].layer.setMap(null);
                geoLayer[i].label.setMap(null);
                geoLayer.splice(i, 1);
            }
        }

        for (var i = 0; i < zoneLabels.length; i++) {
            if (zoneLabels[i].text == idZona) {
                zoneLabels[i].setMap(null);
                zoneLabels.splice(i, 1);

            }
        }

    }

    function FiltrarLocales() {
        var idFormato = Ext.getCmp('comboFiltroFormatos').getValue();

        var store = Ext.getCmp('comboFiltroLocales').store;
        store.load({
            params: {
                IdFormato: idFormato,
            },
            callback: function (r, options, success) {
                if (!success) {
                    Ext.MessageBox.show({
                        title: 'Error',
                        msg: 'Se ha producido un error.',
                        buttons: Ext.MessageBox.OK
                    });
                }
                else {
                    Ext.getCmp("comboFiltroLocales").setValue(0);
                }

            }
        });
    }

    function CreateMarkerPolyLine(point, overlay) {
        counter = counter == null ? 1 : counter + 1;
        var image = new google.maps.MarkerImage("Images/greymarker_32x32.png");
        var marker = new google.maps.Marker({
            position: point.latLng,
            icon: image,
            animation: google.maps.Animation.DROP,
            draggable: true,
            bouncy: false,
            dragCrossMove: true,

            map: map
        });
        markersVertices.push(marker);

        if (markersVertices.length > 2) {
            GetDetalleAreaSeleccionada();
        }

        google.maps.event.addListener(marker, "drag", function () {
            DrawPolyLine();
        });

        google.maps.event.addListener(marker, "dragend", function () {
            if (markersVertices.length > 2) {
                GetDetalleAreaSeleccionada();
            }
        });

        google.maps.event.addListener(marker, "click", function () {
            for (var n = 0; n < markersVertices.length; n++) {
                if (markersVertices[n] == marker) {
                    markersVertices[n].setMap(null);
                    break;
                }
            }
            markersVertices.splice(n, 1);
            if (markersVertices.length == 0) {
                count = 0;
                counter = 0;
            }
            else {
                count = markersVertices[markersVertices.length - 1].content;
                DrawPolyLine();
            }

            if (markersVertices.length > 2) {
                GetDetalleAreaSeleccionada();
            }

        });
        DrawPolyLine();

    }

    function DrawPolyLine() {
        var lineMode = false;
        var colorZone = " #4cabf6";

        if (poly) { poly.setMap(null); }
        points.length = 0;
        for (i = 0; i < markersVertices.length; i++) {
            points.push(markersVertices[i].getPosition());
            lineMode = i < 2 ? true : false;
        }
        if (lineMode) {
            poly = new google.maps.Polyline({ path: points, strokeColor: "#000000", strokeWeight: 1, strokeOpacity: 0.9 });
        }
        else {
            points.push(markersVertices[0].getPosition());
            poly = new google.maps.Polygon({ paths: points, strokeColor: "#000000", strokeWeight: 1, strokeOpacity: 0.9, fillColor: colorZone, fillOpacity: 0.3 });
        }
        poly.setMap(map);

        if (markersVertices.length > 2) {
            //GetDetalleAreaSeleccionada();
        }
        else {
            //Ext.getCmp('winAreaSeleccionada').hide();
            Ext.getCmp('textCantAlertas').reset();
            Ext.getCmp('textCantViajes').reset();
            Ext.getCmp('gridPanelAreaSeleccionada').store.removeAll();
            Ext.getCmp('gridPanelPorTransportista').store.removeAll();
            Ext.getCmp('gridPanelPorProveedor').store.removeAll();


        }
    }

    function BorrarArea() {

        //Ext.getCmp('winAreaSeleccionada').hide();
        Ext.getCmp('textCantAlertas').reset();
        Ext.getCmp('textCantViajes').reset();
        Ext.getCmp('gridPanelAreaSeleccionada').store.removeAll();
        Ext.getCmp('gridPanelPorTransportista').store.removeAll();
        Ext.getCmp('gridPanelPorProveedor').store.removeAll();

        for (var i = 0; i < markersVertices.length; i++) {
            if (markersVertices[i] != null) {
                markersVertices[i].setMap(null);
            }
        }
        markersVertices.length = 0;
        if (poly != null) {
            poly.setMap(null);
        }
    }

    function GetDetalleAreaSeleccionada() {

        if (!Ext.getCmp('leftPanel').getForm().isValid() /*|| loadingStore == 1*/) {
            
            return;
        }

        //loadingStore = 1;

        var storePanelAreaSeleccionada = Ext.getCmp('gridPanelAreaSeleccionada').store;
        var storePanelPorTransportista = Ext.getCmp('gridPanelPorTransportista').store;
        var storePanelPorProveedor = Ext.getCmp('gridPanelPorProveedor').store;

        Ext.getCmp('textCantAlertas').reset();
        Ext.getCmp('textCantViajes').reset();
        storePanelAreaSeleccionada.removeAll();
        storePanelPorTransportista.removeAll();
        storePanelPorProveedor.removeAll();

        var desde = Ext.getCmp('dateDesde').getRawValue() + " " + Ext.getCmp('hourDesde').getRawValue();
        var hasta = Ext.getCmp('dateHasta').getRawValue() + " " + Ext.getCmp('hourHasta').getRawValue();
        var transportista = Ext.getCmp('comboFiltroTransportista').getValue();
        var proveedorGPS = Ext.getCmp('comboFiltroProveedorGPS').getValue();
        var patente = Ext.getCmp('comboFiltroPatente').getValue();
        var rutConductor = Ext.getCmp('comboFiltroConductores').getValue();
        var tipoAlerta = Ext.getCmp('comboFiltroAlertas').getValue();
        var idFormato = Ext.getCmp('comboFiltroFormatos').getValue();
        var codigoLocal = Ext.getCmp('comboFiltroLocales').getValue();
        var permiso = Ext.getCmp('comboFiltroPermiso').getValue();
        var estadoViaje = Ext.getCmp('comboFiltroEstadoViaje').getValue();
        var scoreConductor = Ext.getCmp('comboFiltroScoreConductor').getValue();

        var _vertices = "";

        for (var j = 0; j < markersVertices.length; j++) {
            var lat = markersVertices[j].position.lat();
            var lng = markersVertices[j].position.lng();
            _vertices = _vertices + lat + ',' + lng + ';';

            if (j == markersVertices.length - 1) {
                _vertices = _vertices + markersVertices[0].position.lat() + ',' + markersVertices[0].position.lng()
            }

        }

        storePanelAreaSeleccionada.load({
            params: {
                desde: desde,
                hasta: hasta,
                transportista: transportista,
                proveedorGPS: proveedorGPS,
                patente: patente,
                scoreConductor: scoreConductor,
                rutConductor: rutConductor,
                tipoAlerta: tipoAlerta,
                idFormato: idFormato,
                codigoLocal: codigoLocal,
                permiso: permiso,
                estadoViaje: estadoViaje,
                vertices: _vertices
            },
            callback: function (r, options, success) {
                if (!success) {
                    Ext.MessageBox.show({
                        title: 'Error',
                        msg: 'Se ha producido un error.',
                        buttons: Ext.MessageBox.OK
                    });
                }
                else {

                    Ext.getCmp('textCantAlertas').reset();
                    Ext.getCmp('textCantViajes').reset();
                    storePanelPorTransportista.removeAll();
                    storePanelPorProveedor.removeAll();

                    var cantAlertas = storePanelAreaSeleccionada.data.items[0].raw.Cantidad;
                    var cantViajes = storePanelAreaSeleccionada.data.items[1].raw.Cantidad;

                    Ext.getCmp('textCantAlertas').setValue(cantAlertas);
                    Ext.getCmp('textCantViajes').setValue(cantViajes);
                    
                    for (var i = 2; i < storePanelAreaSeleccionada.count() ; i++) {
             
                        if (storePanelAreaSeleccionada.data.items[i].raw.Entidad == "PorTransportista")
                        {
                            storePanelPorTransportista.add({ Transportista: storePanelAreaSeleccionada.data.items[i].raw.Nombre.toString(), Cantidad: storePanelAreaSeleccionada.data.items[i].raw.Cantidad.toString() })
                        }
                        if (storePanelAreaSeleccionada.data.items[i].raw.Entidad == "PorProveedorGPS") {
                            storePanelPorProveedor.add({ ProveedorGPS: storePanelAreaSeleccionada.data.items[i].raw.Nombre.toString(), Cantidad: storePanelAreaSeleccionada.data.items[i].raw.Cantidad.toString() })
                        }

                    }

                    //loadingStore = 0;
                }
            }
        })

        Ext.getCmp('winAreaSeleccionada').show();
    }

  </script>

  </asp:Content>
  <asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
    <div id="dvMap"></div>
  </asp:Content>
