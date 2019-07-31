<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GeneracionRutas.aspx.cs" Inherits="Track_Web.GeneracionRutas" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
AltoTrack Platform 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

  <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8" type="text/javascript"></script>
  <script src="Scripts/MapFunctions.js" type="text/javascript"></script>
  <script src="Scripts/TopMenu.js" type="text/javascript"></script>
  <script src="Scripts/LabelMarker.js" type="text/javascript"></script>

<script type="text/javascript">

  var directionsService = new google.maps.DirectionsService();
  /*
  var directionsDisplay = new google.maps.DirectionsRenderer({
  draggable: true
  });
  */
  var directionsDisplay = new google.maps.DirectionsRenderer();

  var geoLayer = new Array();
  var geoLayerRiesgo = new Array();

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

    Ext.apply(Ext.form.field.VTypes, {
      fileExcel: function (val, field) {
        var fileName = /^.*\.(xlsx|xls|xlsb)$/i;
        return fileName.test(val);
      },
      fileExcelText: "Tipo de archivo no válido.",
      fileExcelfileMask: /[a-z_\.]/i
    });

    var storeRutaGenerada1 = new Ext.data.JsonStore({
      fields: ['Id', 'Latitud', 'Longitud']
    });

    var comboRutaGenerada1 = new Ext.form.field.ComboBox({
      id: 'comboRutaGenerada1',
      store: storeRutaGenerada1,
      valueField: 'Id',
      displayField: 'Id',
      queryMode: 'local'
    });

    var storeRutaGenerada2 = new Ext.data.JsonStore({
      fields: ['NombreRuta', 'Latitud', 'Longitud']
    });

    var comboRutaGenerada2 = new Ext.form.field.ComboBox({
      id: 'comboRutaGenerada2',
      store: storeRutaGenerada2,
      valueField: 'Id',
      displayField: 'Id',
      queryMode: 'local'
    });

    var storeRutaGenerada3 = new Ext.data.JsonStore({
      fields: ['NombreRuta', 'Latitud', 'Longitud']
    });

    var comboRutaGenerada3 = new Ext.form.field.ComboBox({
      id: 'comboRutaGenerada3',
      store: storeRutaGenerada3,
      valueField: 'Id',
      displayField: 'Id',
      queryMode: 'local'
    });

    var storeRutaGenerada4 = new Ext.data.JsonStore({
      fields: ['NombreRuta', 'Latitud', 'Longitud']
    });

    var comboRutaGenerada4 = new Ext.form.field.ComboBox({
      id: 'comboRutaGenerada4',
      store: storeRutaGenerada4,
      valueField: 'Id',
      displayField: 'Id',
      queryMode: 'local'
    });

    var storeRutaGenerada5 = new Ext.data.JsonStore({
      fields: ['NombreRuta', 'Latitud', 'Longitud']
    });

    var comboRutaGenerada5 = new Ext.form.field.ComboBox({
      id: 'comboRutaGenerada5',
      store: storeRutaGenerada5,
      valueField: 'Id',
      displayField: 'Id',
      queryMode: 'local'
    });

    var fFieldExcel = new Ext.form.field.File({
      xtype: 'filefield',
      id: 'fFieldExcel',
      labelWidth: 100,
      anchor: '99%',
      allowBlank: false,
      vtype: 'fileExcel',
      emptyText: 'Seleccione archivo excel...',
      fieldLabel: 'Cargar archivo',
      buttonText: '...',
      listeners: {
        'change': function (fb, v) {
          loadExcel();
          Ext.getCmp("comboFiltroCriterio").setDisabled(false);
        }
      }
    });
    /*
    var btnPreview = {
    xtype: 'button',
    id: 'btnPreview',
    text: 'Visualizar',
    //icon: 'Images/magnifier.png',
    width: 70,
    height: 22,
    listeners: {
    click: {
    fn: function () {
    loadExcel();
    }
    }
    }
    }
    */
    var storeFiltroCriterioOptimizacion = new Ext.data.JsonStore({
      fields: ['IdCriterio', 'NombreCriterio'],
      data: [{ IdCriterio: '1', NombreCriterio: 'Ruta segura' },
              { IdCriterio: '2', NombreCriterio: 'Menor distancia' }
            ]
    });

    var comboFiltroCriterio = new Ext.form.field.ComboBox({
      id: 'comboFiltroCriterio',
      fieldLabel: 'Optimizar por',
      store: storeFiltroCriterioOptimizacion,
      valueField: 'IdCriterio',
      displayField: 'NombreCriterio',
      queryMode: 'local',
      anchor: '99%',
      labelWidth: 110,
      width: 325,
      editable: false,
      enableKeyEvents: true,
      forceSelection: true
    });

    Ext.getCmp('comboFiltroCriterio').setValue('1');

    var storeZonasRiesgo = new Ext.data.JsonStore({
      id: 'storeZonasRiesgo',
      autoLoad: false,
      fields: ['IdZona'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonas',
        reader: { type: 'json', root: 'Zonas' },
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var storeRutasRiesgo = new Ext.data.JsonStore({
      id: 'storeRutasRiesgo',
      autoLoad: false,
      fields: ['IdZona'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonas',
        reader: { type: 'json', root: 'Rutas' },
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var gridZonasRiesgo = Ext.create('Ext.grid.Panel', {
      id: 'gridZonasRiesgo',
      store: storeZonasRiesgo,
      columns: [
                { text: 'IdZona', flex: 1, dataIndex: 'IdZona' }
             ]

    });

    var gridRutasRiesgo = Ext.create('Ext.grid.Panel', {
      id: 'gridRutasRiesgo',
      store: storeRutasRiesgo,
      columns: [
                { text: 'IdZona', flex: 1, dataIndex: 'IdZona' }
             ]

    });

    storeZonasRiesgo.load({
      params: {
        idTipoZona: 3,
        nombreZona: ''
      },
      callback: function (r, options, success) {
        if (success) {
          var storeZonasR = Ext.getCmp('gridZonasRiesgo').getStore();
          for (var i = 0; i < storeZonasR.count(); i++) {
            DrawZoneRiesgo(storeZonasR.getAt(i).data.IdZona);
          }

        }
      }

    });

    storeRutasRiesgo.load({
      params: {
        idTipoZona: 11,
        nombreZona: ''
      },
      callback: function (r, options, success) {
        if (success) {
          var storeRutasR = Ext.getCmp('gridRutasRiesgo').getStore();
          for (var i = 0; i < storeRutasR.count(); i++) {
            DrawZoneRiesgo(storeRutasR.getAt(i).data.IdZona);
          }

        }
      }

    });

    var gridRutasRiesgo = Ext.create('Ext.grid.Panel', {
      id: 'gridRutasRiesgo',
      store: storeRutasRiesgo,
      columns: [
                { text: 'IdZona', flex: 1, dataIndex: 'IdZona' }
             ]

    });

    var storePuntosOrigenDestino = new Ext.data.JsonStore({
      fields: [
                { name: 'Id' },
                { name: 'LatOrigen', type: 'double' },
                { name: 'LonOrigen', type: 'double' },
                { name: 'LatDestino', type: 'double' },
                { name: 'LonDestino', type: 'double' }
                ]
    });

    var gridPanelPuntosOrigenDestino = Ext.create('Ext.grid.Panel', {
      id: 'gridPanelPuntosOrigenDestino',
      store: storePuntosOrigenDestino,
      anchor: '100% -20',
      columnLines: true,
      scroll: false,
      viewConfig: {
        style: { overflow: 'auto', overflowX: 'hidden' }
      },
      columns: [
                    { text: 'Id', width: 35, sortable: false, dataIndex: 'Id' },
                    { text: 'Lat. Origen', flex: 1, sortable: false, dataIndex: 'LatOrigen' },
                    { text: 'Lon. Origen', flex: 1, sortable: false, dataIndex: 'LonOrigen' },
                    { text: 'Lat. Destino', flex: 1, sortable: false, dataIndex: 'LatDestino' },
                    { text: 'Lon. Destino', flex: 1, sortable: false, dataIndex: 'LonDestino' }
                    ]
    });

    var btnGenerarRutas = {
      id: 'btnGenerarRutas',
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/generate_gray_20x20.png',
      text: 'Generar',
      width: 80,
      height: 25,
      style: {
        marginLeft: '10px'
      },
      disabled: true,
      handler: function () {
        GenerarRutas();
      }
    };

    var panelProperties = new Ext.FormPanel({
      id: 'panelProperties',
      title: 'Generación de Rutas',
      anchor: '100% 40%',
      collapsible: false,
      titleCollapsed: true,
      bodyStyle: 'padding: 5px;',
      hideCollapseTool: true,
      //buttons: [comboFiltroCriterio, btnGenerarRutas],
      layout: 'anchor',
      items: [{
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 0.2,
        items: [fFieldExcel]
      }, {
        xtype: 'fieldset',
        anchor: '99% 75%',
        layout: 'anchor',
        title: 'Datos de archivo',
        items: [gridPanelPuntosOrigenDestino]
      }, {
        xtype: 'container',
        layout: 'column',
        columnWidth: 0.5,
        items: [comboFiltroCriterio, btnGenerarRutas]
      }]
    });

    var storeRutas = new Ext.data.JsonStore({
      autoLoad: true,
      fields: ['IdRuta', 'IdOrigen', 'NombreZonaOrigen', 'IdDestino', 'NombreZonaDestino', 'ResumenRuta'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxRutas.aspx?Metodo=GetRutas',
        reader: { type: 'json', root: 'Rutas' },
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var btnFormatoEjemplo = {
      id: 'btnFormatoEjemplo',
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/export_black_20x20.png',
      text: 'Formato ejemplo',
      width: 120,
      height: 26,
      style: {
        marginLeft: '20px'
      },
      listeners: {
        click: {
          element: 'el',
          fn: function () {

            var mapForm = document.createElement("form");
            mapForm.target = "ToExcel";
            mapForm.method = "POST"; // or "post" if appropriate
            mapForm.action = 'GeneracionRutas.aspx?Metodo=ExportFormatoEjemplo';

            document.body.appendChild(mapForm);
            mapForm.submit();

          }
        }
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
        ClearMap();
        Cancelar();

      }
    };

    var gridPanelRutas = Ext.create('Ext.grid.Panel', {
      id: 'gridPanelRutas',
      title: 'Rutas generadas',
      //hideCollapseTool: true,
      store: storeRutas,
      anchor: '100% 60%',
      columnLines: true,
      buttons: [btnFormatoEjemplo, btnCancelar],
      //tbar: toolbarZona,
      //buttons: [btnGuardar, btnCancelar],
      //buttons: [btnExportarZonas, btnMostrarTodas],
      scroll: false,
      viewConfig: {
        style: { overflow: 'auto', overflowX: 'hidden' }
      },
      columns: [{ text: 'Origen', sortable: true, width: 110, dataIndex: 'NombreZonaOrigen' },
                    { text: 'Destino', sortable: true, flex: 1, dataIndex: 'NombreZonaDestino' },
                    { text: 'Ruta', sortable: true, flex: 1, dataIndex: 'ResumenRuta' },
                    {
                      xtype: 'actioncolumn',
                      width: 20,
                      items: [
                        {
                          icon: 'Images/delete.png',
                          tooltip: 'Eliminar ruta',
                          handler: function (grid, rowIndex, colIndex) {
                            var row = grid.getStore().getAt(rowIndex);
                            DeleteRuta(row.data.IdRuta);

                            //Ext.getCmp("numberIdZona").reset();
                            //Ext.getCmp("textNombre").reset();
                            //Ext.getCmp("comboTipoZona").reset()
                            //propertieStore.removeAll();
                          }
                        }]
                    }

              ],
      listeners: {
        select: function (sm, row, rec) {

          viewIdRuta = row.data.IdRuta;
          GetRouteFromDB(viewIdRuta);
        }
      }
    });

    var viewWidth = Ext.getBody().getViewSize().width;

    var leftPanel = new Ext.FormPanel({
      id: 'leftPanel',
      region: 'west',
      margins: '0 0 3 3',
      border: true,
      width: 435,
      minWidth: 300,
      maxWidth: viewWidth / 2,
      layout: 'anchor',
      split: true,
      items: [panelProperties, gridPanelRutas]
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
    });

  });

</script>




<script type="text/javascript">

  Ext.onReady(function () {
    GeneraMapa("dvMap", true);
  });

  function GenerarRutas() {
    ClearMap();

    Ext.getCmp('comboRutaGenerada1').store.removeAll();
    Ext.getCmp('comboRutaGenerada2').store.removeAll();
    Ext.getCmp('comboRutaGenerada3').store.removeAll();
    Ext.getCmp('comboRutaGenerada4').store.removeAll();
    Ext.getCmp('comboRutaGenerada5').store.removeAll();
    //Ext.getCmp('gridPanelRutasGeneradas').reset()

    if (!Ext.getCmp('panelProperties').getForm().isValid()) {
      return;
    }

    var storePoints = Ext.getCmp('gridPanelPuntosOrigenDestino').store;

    for (var k = 0; k < storePoints.count(); k++) {

      var latOrigen = storePoints.getAt(k).data.LatOrigen;
      var lonOrigen = storePoints.getAt(k).data.LonOrigen;
      var latDestino = storePoints.getAt(k).data.LatDestino;
      var lonDestino = storePoints.getAt(k).data.LonDestino;

      var latlonOrigen = new google.maps.LatLng(latOrigen, lonOrigen);
      var latlonDestino = new google.maps.LatLng(latDestino, lonDestino);

      var request = {
        origin: latlonOrigen,
        destination: latlonDestino,
        travelMode: google.maps.TravelMode.DRIVING,
        unitSystem: google.maps.UnitSystem.METRIC,
        provideRouteAlternatives: true,
        region: 'CL'
      };

      directionsService.route(request, function (result, status) {
        if (status == google.maps.DirectionsStatus.OK) {
          //directionsDisplay.setDirections(result);

          var store1 = Ext.getCmp('comboRutaGenerada1').store;
          var store2 = Ext.getCmp('comboRutaGenerada2').store;
          var store3 = Ext.getCmp('comboRutaGenerada3').store;
          var store4 = Ext.getCmp('comboRutaGenerada4').store;
          var store5 = Ext.getCmp('comboRutaGenerada5').store;

          //var storeGeneradas = Ext.getCmp('gridPanelRutasGeneradas').store;

          var string1 = "";
          var string2 = "";
          var string3 = "";
          var string4 = "";
          var string5 = "";

          var resumenRuta1 = "";
          var resumenRuta2 = "";
          var resumenRuta3 = "";
          var resumenRuta4 = "";
          var resumenRuta5 = "";

          var distanceRuta1 = "";
          var distanceRuta2 = "";
          var distanceRuta3 = "";
          var distanceRuta4 = "";
          var distanceRuta5 = "";

          for (i = 0; i < result.routes.length; i++) {

            id = i + 1;

            var overview_path = result.routes[i].overview_path;

            for (j = 0; j < overview_path.length; j++) {

              var lat = overview_path[j].lat();
              var lon = overview_path[j].lng();

              switch (i) {
                case 0:

                  if (resumenRuta1 == "") {
                    resumenRuta1 = result.routes[i].summary;
                  }

                  if (distanceRuta1 == "") {
                    distanceRuta1 = result.routes[i].legs[0].distance.value;
                  }

                  string1 = string1 + lat.toString() + "," + lon.toString();
                  if (j < overview_path.length - 1) {
                    string1 = string1 + ";";
                  }

                  store1.add({
                    Id: 1,
                    Latitud: lat,
                    Longitud: lon
                  });
                  break;
                case 1:

                  if (resumenRuta2 == "") {
                    resumenRuta2 = result.routes[i].summary;
                  }

                  if (distanceRuta2 == "") {
                    distanceRuta2 = result.routes[i].legs[0].distance.value;
                  }

                  string2 = string2 + lat.toString() + "," + lon.toString();
                  if (j < overview_path.length - 1) {
                    string2 = string2 + ";";
                  }

                  store2.add({
                    Id: 2,
                    Latitud: lat,
                    Longitud: lon
                  });
                  break;
                case 2:

                  if (resumenRuta3 == "") {
                    resumenRuta3 = result.routes[i].summary;
                  }

                  if (distanceRuta3 == "") {
                    distanceRuta3 = result.routes[i].legs[0].distance.value;
                  }

                  string3 = string3 + lat.toString() + "," + lon.toString();
                  if (j < overview_path.length - 1) {
                    string3 = string3 + ";";
                  }

                  store3.add({
                    Id: 3,
                    Latitud: lat,
                    Longitud: lon
                  });
                  break;
                case 3:

                  if (resumenRuta4 == "") {
                    resumenRuta4 = result.routes[i].summary;
                  }

                  if (distanceRuta4 == "") {
                    distanceRuta4 = result.routes[i].legs[0].distance.value;
                  }

                  string4 = string4 + lat.toString() + "," + lon.toString();
                  if (j < overview_path.length - 1) {
                    string4 = string4 + ";";
                  }

                  store4.add({
                    Id: 4,
                    Latitud: lat,
                    Longitud: lon
                  });
                  break;
                case 4:

                  if (resumenRuta5 == "") {
                    resumenRuta5 = result.routes[i].summary;
                  }

                  if (distanceRuta5 == "") {
                    distanceRuta5 = result.routes[i].legs[0].distance.value;
                  }

                  string5 = string5 + lat.toString() + "," + lon.toString();
                  if (j < overview_path.length - 1) {
                    string5 = string5 + ";";
                  }

                  store5.add({
                    Id: 5,
                    Latitud: lat,
                    Longitud: lon
                  });
                  break;
                default:
                  break;
              }
            }
          }

          if (string1 != "") {
            string1 = string1 + "/" + resumenRuta1 + "|" + distanceRuta1;
          }
          if (string2 != "") {
            string2 = string2 + "/" + resumenRuta2 + "|" + distanceRuta2;
          }
          if (string3 != "") {
            string3 = string3 + "/" + resumenRuta3 + "|" + distanceRuta3;
          }
          if (string4 != "") {
            string4 = string4 + "/" + resumenRuta4 + "|" + distanceRuta4;
          }
          if (string5 != "") {
            string5 = string5 + "/" + resumenRuta5 + "|" + distanceRuta5;
          }

          var lat1 = result.request.origin.lat();
          var lon1 = result.request.origin.lng();
          var lat2 = result.request.destination.lat();
          var lon2 = result.request.destination.lng();

          Ext.Msg.wait('Espere por favor...', 'Generando rutas.');

          //Workaround para no enviar todas las rutas en 1 solo string, "URL too long".
          Ext.Ajax.request({
            url: 'AjaxPages/AjaxRutas.aspx?Metodo=GuardaRutaTmp',
            params: {
              'idRuta': 1,
              'stringRuta': string1
            },
            success: function (data, success) {
              Ext.Ajax.request({
                url: 'AjaxPages/AjaxRutas.aspx?Metodo=GuardaRutaTmp',
                params: {
                  'idRuta': 2,
                  'stringRuta': string2
                },
                success: function (data, success) {
                  Ext.Ajax.request({
                    url: 'AjaxPages/AjaxRutas.aspx?Metodo=GuardaRutaTmp',
                    params: {
                      'idRuta': 3,
                      'stringRuta': string3
                    },
                    success: function (data, success) {
                      Ext.Ajax.request({
                        url: 'AjaxPages/AjaxRutas.aspx?Metodo=GuardaRutaTmp',
                        params: {
                          'idRuta': 4,
                          'stringRuta': string4
                        },
                        success: function (data, success) {
                          Ext.Ajax.request({
                            url: 'AjaxPages/AjaxRutas.aspx?Metodo=GuardaRutaTmp',
                            params: {
                              'idRuta': 5,
                              'stringRuta': string5
                            },
                            success: function (data, success) {
                              Ext.Ajax.request({
                                url: 'AjaxPages/AjaxRutas.aspx?Metodo=GeneraRutaOptima',
                                params: {
                                  criterioOptimizacion: Ext.getCmp('comboFiltroCriterio').getValue(),
                                  latOrigen: lat1,
                                  lonOrigen: lon1,
                                  latDestino: lat2,
                                  lonDestino: lon2,
                                  stringRuta1: "",
                                  stringRuta2: "",
                                  stringRuta3: "",
                                  stringRuta4: "",
                                  stringRuta5: ""
                                },
                                callback: function (r, options, success) {

                                }
                              });

                            }
                          });
                        }
                      });
                    }
                  });
                }
              });
            }
          });

          var stop = "stop";

        }
      });

    }

    Ext.Ajax.request({
      url: 'AjaxPages/AjaxFunctions.aspx?Metodo=ProgressBarCall',
      success: function (response, opts) {                                                                                                                                                                                                                                                                                           

        var task = new Ext.util.DelayedTask(function () {
          Ext.getCmp('gridPanelRutas').getStore().load();
          Ext.Msg.hide();
        });

        task.delay(1000);

      },
      failure: function (response, opts) {
        Ext.Msg.hide();
      }
    });

  }

  function GetRouteFromDB(IdRuta) {

    Ext.Ajax.request({
      url: 'AjaxPages/AjaxRutas.aspx?Metodo=GetPuntosRuta',
      params: {
        IdRuta: IdRuta
      },
      success: function (data, success) {
        if (data != null) {
          data = Ext.decode(data.responseText);
          DrawRouteFromDB(data);
        }
      },
      failure: function (msg) {
        alert('Se ha producido un error.');
      }
    });
  }

  function DrawRouteFromDB(data) {

    ClearMap();
    var storeRouteToDraw;

    var lineMode = false;

    if (poly) { poly.setMap(null); }
    points.length = 0;

    var startPoint = new google.maps.LatLng(data.Puntos[0].Latitud, data.Puntos[0].Longitud);
    var endPoint = new google.maps.LatLng(data.Puntos[data.Puntos.length - 1].Latitud, data.Puntos[data.Puntos.length - 1].Longitud);

    for (i = 0; i < data.Puntos.length; i++) {
      lat = data.Puntos[i].Latitud;
      lon = data.Puntos[i].Longitud;
      point = new google.maps.LatLng(lat, lon);
      points.push(point);

    }

    poly = new google.maps.Polyline({ path: points, strokeColor: "#2492C9", strokeWeight: 7, strokeOpacity: 0.7 });
    poly.setMap(map);

    map.setCenter(startPoint);

    DrawZone(data.IdOrigen, 1);
    DrawZone(data.IdDestino, 2);

    // Marcador Inicio Ruta
    var startMarker = new google.maps.Marker({
      position: startPoint,
      map: map,
      icon: new google.maps.MarkerImage("Images/marker_green_32x32.png"),
      animation: google.maps.Animation.DROP
    });
    markers.push(startMarker);

    // Marcador Fin Ruta
    var endMarker = new google.maps.Marker({
      position: endPoint,
      map: map,
      icon: new google.maps.MarkerImage("Images/marker_blue_32x32.png"),
      animation: google.maps.Animation.DROP
    });
    markers.push(endMarker);

  }

  function DrawZone(idZona, idTipoZona) {

    for (var i = 0; i < geoLayer.length; i++) {
      geoLayer[i].layer.setMap(null);
      geoLayer[i].label.setMap(null);
      geoLayer.splice(i, 1);
    }

    if (idTipoZona == 3) {
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
            polygonGrid.label = new Label({
              position: new google.maps.LatLng(data.Latitud, data.Longitud),
              map: map
            });
            polygonGrid.label.bindTo('text', polygonGrid.layer, 'labelText');
            polygonGrid.layer.setMap(map);
            geoLayer.push(polygonGrid);
          }
          else
            if (data.Vertices.length = 1) { //Point
              var Point = new Object();
              Point.IdZona = data.IdZona;

              var image = new google.maps.MarkerImage("Images/greymarker_32x32.png");

              Point.layer = new google.maps.Marker({
                position: new google.maps.LatLng(data.Latitud, data.Longitud),
                icon: image,
                labelText: data.NombreZona,
                map: map
              });

              Point.label = new Label({
                position: new google.maps.LatLng(data.Latitud, data.Longitud),
                map: map
              });

              Point.label.bindTo('text', Point.layer, 'labelText');
              Point.layer.setMap(map);
              geoLayer.push(Point);
            }

        }
      },
      failure: function (msg) {
        alert('Se ha producido un error.');
      }
    });
  }

  function DrawZoneRiesgo(idZona) {
    /*
    for (var i = 0; i < geoLayer.length; i++) {
    geoLayerRiesgo[i].layer.setMap(null);
    geoLayerRiesgo[i].label.setMap(null);
    geoLayerRiesgo.splice(i, 1);
    }
    */

    var colorZone = "#FF0000";

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
            polygonGrid.label = new Label({
              position: new google.maps.LatLng(data.Latitud, data.Longitud),
              map: map
            });
            polygonGrid.label.bindTo('text', polygonGrid.layer, 'labelText');
            polygonGrid.layer.setMap(map);
            geoLayerRiesgo.push(polygonGrid);
          }
          else
            if (data.Vertices.length = 1) { //Point
              var Point = new Object();
              Point.IdZona = data.IdZona;

              var image = new google.maps.MarkerImage("Images/greymarker_32x32.png");

              Point.layer = new google.maps.Marker({
                position: new google.maps.LatLng(data.Latitud, data.Longitud),
                icon: image,
                labelText: data.NombreZona,
                map: map
              });

              Point.label = new Label({
                position: new google.maps.LatLng(data.Latitud, data.Longitud),
                map: map
              });

              Point.label.bindTo('text', Point.layer, 'labelText');
              Point.layer.setMap(map);
              geoLayerRiesgo.push(Point);
            }

        }
      },
      failure: function (msg) {
        alert('Se ha producido un error.');
      }
    });
  }

  function DeleteRuta(idRuta) {
    if (confirm("La ruta se eliminará permanentemente.¿Desea continuar?")) {

      var _storeRutas = Ext.getCmp('gridPanelRutas').getStore();

      Ext.Ajax.request({
        url: 'AjaxPages/AjaxRutas.aspx?Metodo=EliminaRuta',
        params: {
          'IdRuta': idRuta
        },
        success: function (data, success) {
          if (data != null) {
            ClearMap();
            //Cancelar();
            Ext.getCmp('gridPanelRutas').store.load();
          }
        },
        failure: function (msg) {
          alert('Se ha producido un error.');
        }
      });
    }
  }

  function Cancelar() {

    Ext.getCmp("comboFiltroCriterio").setDisabled(false);
    Ext.getCmp('gridPanelPuntosOrigenDestino').setDisabled(false);
    Ext.getCmp("btnGenerarRutas").setDisabled(true);
    //Ext.getCmp("btnEditar").setDisabled(true);

    for (var i = 0; i < geoLayer.length; i++) {
      geoLayer[i].layer.setMap(null);
      geoLayer[i].label.setMap(null);
      geoLayer.splice(i, 1);
    }

    Ext.getCmp('comboRutaGenerada1').store.removeAll();
    Ext.getCmp('comboRutaGenerada2').store.removeAll();
    Ext.getCmp('comboRutaGenerada3').store.removeAll();
    Ext.getCmp('comboRutaGenerada4').store.removeAll();
    Ext.getCmp('comboRutaGenerada5').store.removeAll();

    Ext.getCmp('gridPanelPuntosOrigenDestino').store.removeAll();
    //Ext.getCmp('gridPanelRutasGeneradas').reset()

    if (directionsDisplay) {
      directionsDisplay.setMap(null);
    }

  }

  function loadExcel() {
    Ext.getCmp('gridPanelPuntosOrigenDestino').store.removeAll();

    Ext.getCmp('leftPanel').getForm().submit({
      url: 'AjaxPages/AjaxRutas.aspx?Metodo=CargaExcelPuntosOrigenDestino',
      waitMsg: 'Cargando archivo...',
      success: function (data, success) {
        if (success.result.result) {
            for (var i = 0; i < success.result.Data[0].length; i++) {
              success.result.Data[0][i]
              var data = {
                Id: i + 1,
                LatOrigen: success.result.Data[0][i].LatOrigen,
                LonOrigen: success.result.Data[0][i].LonOrigen,
                LatDestino: success.result.Data[0][i].LatDestino,
                LonDestino: success.result.Data[0][i].LonDestino
              };
              Ext.getCmp('gridPanelPuntosOrigenDestino').store.add(data);
              if (success.result.Data[0].length > 0) {
                Ext.getCmp("btnGenerarRutas").setDisabled(false);
              }
          }
        }
        else {
          Ext.MessageBox.show({
            title: 'Error',
            msg: 'Se ha producido un error. Verifique el formato del archivo.',
            buttons: Ext.MessageBox.OK
          });
        }
      }
    })

  }

</script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
  <div id="dvMap"></div>
</asp:Content>
