<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ConfigRutas.aspx.cs" Inherits="Track_Web.ConfigRutas" %>
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

  var arrayPrueba = [{}];

  var _edit = 0;

  Ext.onReady(function () {

    Ext.QuickTips.init();
    Ext.Ajax.timeout = 600000;
    Ext.override(Ext.form.Basic, { timeout: Ext.Ajax.timeout / 1000 });
    Ext.override(Ext.data.proxy.Server, { timeout: Ext.Ajax.timeout });
    Ext.override(Ext.data.Connection, { timeout: Ext.Ajax.timeout });

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
      labelWidth: 100,
      emptyText: 'Seleccione...',
      listConfig: {
        loadingText: 'Buscando...',
        getInnerTpl: function () {
          return '<a class="search-item">' +
                            '<span>Id Zona: {IdZona}</span><br />' +
                            '<span>Nombre: {NombreZona}</span>' +
                        '</a>';
        }
      },
      listeners: {
        select: function (field, newVal) {
          if (newVal != null && Ext.getCmp('comboZonaDestino').getValue() != null && newVal != Ext.getCmp('comboZonaDestino').getValue()) {
            GenerarRuta();

          }
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
      labelWidth: 100,
      emptyText: 'Seleccione...',
      listConfig: {
        loadingText: 'Buscando...',
        getInnerTpl: function () {
          return '<a class="search-item">' +
                            '<span>Id Zona: {IdZona}</span><br />' +
                            '<span>Nombre: {NombreZona}</span>' +
                        '</a>';
        }
      },
      listeners: {
        select: function (field, newVal) {
          if (newVal != null && Ext.getCmp('comboZonaOrigen').getValue() != null && newVal != Ext.getCmp('comboZonaOrigen').getValue()) {
            GenerarRuta();

            Ext.Ajax.request({
              url: 'AjaxPages/AjaxRutas.aspx?Metodo=ValidarRuta',
              params: {
                'idOrigen': Ext.getCmp('comboZonaOrigen').getValue(),
                'idDestino': Ext.getCmp('comboZonaDestino').getValue()
              },
              success: function (data, success) {

                if (data != null) {
                  if (data.responseText.toLowerCase() == 'true') {
                    _exists = true;
                  }
                  else {
                    _exists = false;
                  }
                }
                else {
                  _exists = false;
                }

              }

            });

          }
        }
      }
    });

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
      labelWidth: 100,
      editable: false,
      enableKeyEvents: true,
      forceSelection: true,
      listeners: {
        change: function (field, newVal) {
          if (newVal != null && Ext.getCmp('comboZonaDestino').getValue() != null && Ext.getCmp('comboZonaOrigen').getValue() != Ext.getCmp('comboZonaDestino').getValue()) {
            GenerarRuta();

          }
        }
      }
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

    var storeRutasGeneradas = new Ext.data.JsonStore({
      autoLoad: false,
      fields: ['IdRuta', 'NombreRuta', 'ResumenRuta', 'ZonasRiesgo', 'Distancia', 'DistanciaText', 'RutaOptima'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxRutas.aspx?Metodo=RutaOptima',
        reader: { type: 'json', root: 'Rutas' },
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var gridPanelRutasGeneradas = Ext.create('Ext.grid.Panel', {
      id: 'gridPanelRutasGeneradas',
      store: storeRutasGeneradas,
      anchor: '100% -20',
      columnLines: true,
      scroll: false,
      viewConfig: {
        getRowClass: function (record, rowIndex, rowParams, store) {
          return record.get("RutaOptima") ? "blue-grid" : "red-grid";
        }
      },
      columns: [
                    { text: 'Ruta', width: 50, sortable: true, dataIndex: 'NombreRuta' },
                    { text: 'Resumen de Ruta', flex: 1, sortable: true, dataIndex: 'ResumenRuta' },
                    { text: 'Riesgo', width: 60, sortable: true, dataIndex: 'ZonasRiesgo' },
                    { text: 'Distancia', width: 60, sortable: true, dataIndex: 'DistanciaText' }
                    ],
      listeners: {
        select: function (sm, row, rec) {
          //Función para el evento select de la grilla
          DrawRoute(row.data.IdRuta);
          Ext.getCmp("btnGuardar").setDisabled(false);
          Ext.getCmp("btnEditar").setDisabled(false);
        }
      }
    });

    var btnGuardar = {
      id: 'btnGuardar',
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/save_black_20x20.png',
      text: 'Guardar',
      width: 80,
      height: 26,
      disabled: true,
      handler: function () {

        if (_edit == 1) {
          GuardarRutaEditada();
        }
        else { 
            GuardarNuevaRuta();
        }
      }
    };

    var btnEditar = {
      id: 'btnEditar',
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/edit_black_20x20.png',
      text: 'Editar',
      width: 80,
      height: 26,
      disabled: true,
      handler: function () {
        poly.setEditable(true);
        poly.addListener('click', function (mev) {
          if (mev.vertex != null && this.getPath().getLength() > 3) {
            this.getPath().removeAt(mev.vertex);
          }
        });

        Ext.getCmp("btnGuardar").setDisabled(false);
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
      buttons: [btnGuardar, btnEditar],
      layout: 'anchor',
      items: [{
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 0.2,
        items: [comboZonaOrigen]
      }, {
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 0.2,
        items: [comboZonaDestino]
      }, {
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 0.2,
        items: [comboFiltroCriterio]
      }, {
        xtype: 'fieldset',
        anchor: '100% 63%',
        layout: 'anchor',
        title: 'Rutas generadas',
        items: [gridPanelRutasGeneradas]
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
    /*
    var btnGenerarTodas = {
      id: 'btnGenerarTodas',
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/allroutes_24x24.png',
      width: 110,
      height: 26,
      text: 'Generar Todas',
      handler: function () {
        GenerarTodas();
      }
    };
    */
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
      title: 'Rutas guardadas',
      //hideCollapseTool: true,
      store: storeRutas,
      anchor: '100% 60%',
      columnLines: true,
      buttons: [btnCancelar],
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

          _edit = 1;

          Ext.getCmp("comboZonaOrigen").setDisabled(true);
          Ext.getCmp("comboZonaDestino").setDisabled(true);
          Ext.getCmp("comboFiltroCriterio").setDisabled(true);
          Ext.getCmp('gridPanelRutasGeneradas').setDisabled(true);
          Ext.getCmp("btnGuardar").setDisabled(true);
          Ext.getCmp("btnEditar").setDisabled(false);

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
      width: 450,
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
    //google.maps.event.addListener(map, 'click', CreateMarkerPolyLine);
  });

  function GenerarRuta() {
    ClearMap();

    Ext.getCmp('comboRutaGenerada1').store.removeAll();
    Ext.getCmp('comboRutaGenerada2').store.removeAll();
    Ext.getCmp('comboRutaGenerada3').store.removeAll();
    Ext.getCmp('comboRutaGenerada4').store.removeAll();
    Ext.getCmp('comboRutaGenerada5').store.removeAll();
    Ext.getCmp('gridPanelRutasGeneradas').store.removeAll();
    //Ext.getCmp('gridPanelRutasGeneradas').reset()

    if (!Ext.getCmp('panelProperties').getForm().isValid()) {
      return;
    }

    var recordOrigen = Ext.getCmp('comboZonaOrigen').getValue();
    var recordDestino = Ext.getCmp('comboZonaDestino').getValue();

    DrawZone(recordOrigen, 1);
    DrawZone(recordDestino, 2);

    var latOrigen = Ext.getCmp('comboZonaOrigen').findRecordByValue(recordOrigen).data.Latitud;
    var lonOrigen = Ext.getCmp('comboZonaOrigen').findRecordByValue(recordOrigen).data.Longitud;
    var latDestino = Ext.getCmp('comboZonaDestino').findRecordByValue(recordDestino).data.Latitud;
    var lonDestino = Ext.getCmp('comboZonaDestino').findRecordByValue(recordDestino).data.Longitud;

    var latlonOrigen = new google.maps.LatLng(latOrigen, lonOrigen);
    var latlonDestino = new google.maps.LatLng(latDestino, lonDestino);

    if (directionsDisplay) {
      directionsDisplay.setMap(null);
    }

    directionsDisplay.setMap(map);
    directionsDisplay.setPanel(document.getElementById("dvMap"));

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


          //este add no va a ir, lo devuelvo despues de optimizar la ruta en la BD

          /*
          storeGeneradas.add({
          Id: id,
          NombreRuta: 'Ruta ' + id.toString(),
          ResumenRuta: result.routes[i].summary
          });
          */



          for (var x = 0; x < result.routes[0].overview_path.length; x ++)
          {
              var lat = result.routes[0].overview_path[x].lat();
              var lng = result.routes[0].overview_path[x].lng();

              var point = [lat, lng];

              arrayPrueba.push(point);
          }

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

        Ext.Msg.wait('Espere por favor...', 'Calculando ruta óptima.');

        var a = "off";


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
                          
                            Ext.getCmp('gridPanelRutasGeneradas').store.load({
                              params: {
                                criterioOptimizacion: Ext.getCmp('comboFiltroCriterio').getValue(),
                                stringRuta1: "",
                                stringRuta2: "",
                                stringRuta3: "",
                                stringRuta4: "",
                                stringRuta5: ""
                              },
                              callback: function (r, options, success) {
                                Ext.Msg.hide();
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

        /*
        Ext.getCmp('gridPanelRutasGeneradas').store.load({
        params: {
        criterioOptimizacion: Ext.getCmp('comboFiltroCriterio').getValue(),
        stringRuta1: string1,
        stringRuta2: string2,
        stringRuta3: string3,
        stringRuta4: string4,
        stringRuta5: string5
        },
        callback: function (r, options, success) {
        Ext.Msg.hide();
        }
        });
        */

        //akiiiii
        //pasar las 5 variables a la BD, estas variables no las voy a devolver hacia la APP porque ya estan los puntos guardados en los stores ;-)
        //EL SP me va a devolver los campos (ver libreta) y si es óptima o no, más las zonas de riesgo que cruza
        //insertar datos en: var storeGeneradas = Ext.getCmp('gridPanelRutasGeneradas').store;
        //voila!!! creo

      }
    });

  }

  function DrawRoute(idRoute) {

    ClearMap();
    var storeRouteToDraw;

    switch (idRoute) {
      case 1:
        storeRouteToDraw = Ext.getCmp('comboRutaGenerada1').store;
        break;
      case 2:
        storeRouteToDraw = Ext.getCmp('comboRutaGenerada2').store;
        break;
      case 3:
        storeRouteToDraw = Ext.getCmp('comboRutaGenerada3').store;
        break;
      case 4:
        storeRouteToDraw = Ext.getCmp('comboRutaGenerada4').store;
        break;
      case 5:
        storeRouteToDraw = Ext.getCmp('comboRutaGenerada5').store;
        break;
      default:
        storeRouteToDraw = Ext.getCmp('comboRutaGenerada1').store;
    }

    var lineMode = false;

    if (poly) { poly.setMap(null); }
    points.length = 0;

    var startPoint = new google.maps.LatLng(storeRouteToDraw.data.getAt(0).data.Latitud, storeRouteToDraw.data.getAt(0).data.Longitud);
    var endPoint = new google.maps.LatLng(storeRouteToDraw.data.getAt(storeRouteToDraw.count() - 1).data.Latitud, storeRouteToDraw.data.getAt(storeRouteToDraw.count() - 1).data.Longitud);

    for (i = 0; i < storeRouteToDraw.count(); i++) {
      lat = storeRouteToDraw.data.getAt(i).data.Latitud;
      lon = storeRouteToDraw.data.getAt(i).data.Longitud;
      point = new google.maps.LatLng(lat, lon);
      points.push(point);

    }

    poly = new google.maps.Polyline({ path: points, strokeColor: "#2492C9", strokeWeight: 7, strokeOpacity: 0.7});
    poly.setMap(map);

    map.setCenter(startPoint);

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

  function GuardarNuevaRuta() {
    if (!Ext.getCmp('panelProperties').getForm().isValid() || Ext.getCmp('comboZonaOrigen').getValue() == Ext.getCmp('comboZonaDestino').getValue()) {
      return;
    }

    if (Ext.getCmp('gridPanelRutasGeneradas').getSelectionModel().getSelection() == "" || Ext.getCmp('gridPanelRutasGeneradas').getSelectionModel().getSelection() == null) {
      alert("Debe seleccionar una ruta para guardar.");
      return;
    }
    /*
    var id = Ext.getCmp('gridPanelRutasGeneradas').getSelectionModel().getSelection()[0].data.IdRuta;

    switch (id) {
      case 1:
        var store = Ext.getCmp('comboRutaGenerada1').store;
        break;
      case 2:
        var store = Ext.getCmp('comboRutaGenerada2').store;
        break;
      case 3:
        var store = Ext.getCmp('comboRutaGenerada3').store;
        break;
      case 4:
        var store = Ext.getCmp('comboRutaGenerada4').store;
        break;
      case 5:
        var store = Ext.getCmp('comboRutaGenerada5').store;
        break;
      default:
        break;
    }
    */
    var _verticesRuta = new Array();

    var coordinates = [];
    poly.getPath().forEach(function (latLng) {
      _verticesRuta.push(latLng.lat() + ';' + latLng.lng());
      //coordinates.push(latLng);
    });
    /*
    for (var i = 0; i < coordinates.lenght; i++) {
      _verticesRuta.push(coordinates[i].lat + ';' + coordinates[i].lng);
    }*/
    /*
    for (var i = 0; i < store.count(); i++) {
      _verticesRuta.push(store.data.getAt(i).data.Latitud + ';' + store.data.getAt(i).data.Longitud);
    }
    */
    Ext.Ajax.request({
      url: 'AjaxPages/AjaxRutas.aspx?Metodo=ValidarRuta',
      params: {
        'idOrigen': Ext.getCmp('comboZonaOrigen').getValue(),
        'idDestino': Ext.getCmp('comboZonaDestino').getValue()
      },
      success: function (data, success) {
        if (data != null) {
          if (data.responseText.toLowerCase() == 'true') {

            if (confirm("Existe una ruta creada desde el Origen al Destino selecccionado, si continúa se actualizará la ruta. ¿Desea continuar?")) {

              Ext.Ajax.request({
                url: 'AjaxPages/AjaxRutas.aspx?Metodo=NuevaRuta',
                params: {
                  'idOrigen': Ext.getCmp('comboZonaOrigen').getValue(),
                  'idDestino': Ext.getCmp('comboZonaDestino').getValue(),
                  'resumenRuta': Ext.getCmp('gridPanelRutasGeneradas').getSelectionModel().getSelection()[0].data.ResumenRuta,
                  'verticesRuta': _verticesRuta
                },
                success: function (msg, success) {
                  alert(msg.responseText);
                  Ext.getCmp('gridPanelRutas').store.load()

                  Ext.getCmp("comboZonaOrigen").reset();
                  Ext.getCmp("comboZonaDestino").reset();

                  ClearMap();

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
                  Ext.getCmp('gridPanelRutasGeneradas').store.removeAll();

                  Ext.getCmp("btnGuardar").setDisabled(true);
                  Ext.getCmp("btnEditar").setDisabled(true);

                },
                failure: function (msg) {
                  alert('Se ha producido un error.');
                }
              });

            }

          }
          else {

            Ext.Ajax.request({
              url: 'AjaxPages/AjaxRutas.aspx?Metodo=NuevaRuta',
              params: {
                'idOrigen': Ext.getCmp('comboZonaOrigen').getValue(),
                'idDestino': Ext.getCmp('comboZonaDestino').getValue(),
                'resumenRuta': Ext.getCmp('gridPanelRutasGeneradas').getSelectionModel().getSelection()[0].data.ResumenRuta,
                'verticesRuta': _verticesRuta
              },
              success: function (msg, success) {
                alert(msg.responseText);
                Ext.getCmp('gridPanelRutas').store.load()

                Ext.getCmp("comboZonaOrigen").reset();
                Ext.getCmp("comboZonaDestino").reset();

                ClearMap();

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
                Ext.getCmp('gridPanelRutasGeneradas').store.removeAll();

                Ext.getCmp("btnGuardar").setDisabled(true);
                Ext.getCmp("btnEditar").setDisabled(true);

              },
              failure: function (msg) {
                alert('Se ha producido un error.');
              }
            });

          }
        }
      }

    });
  }

  function GuardarRutaEditada() {

    var _verticesRuta = new Array();

    var coordinates = [];
    poly.getPath().forEach(function (latLng) {
      _verticesRuta.push(latLng.lat() + ';' + latLng.lng());
    });

    Ext.Ajax.request({
      url: 'AjaxPages/AjaxRutas.aspx?Metodo=NuevaRuta',
      params: {
        'idOrigen': Ext.getCmp('gridPanelRutas').getSelectionModel().getSelection()[0].data.IdOrigen,
        'idDestino': Ext.getCmp('gridPanelRutas').getSelectionModel().getSelection()[0].data.IdDestino,
        'resumenRuta': Ext.getCmp('gridPanelRutas').getSelectionModel().getSelection()[0].data.ResumenRuta,
        'verticesRuta': _verticesRuta
      },
      success: function (msg, success) {
        alert(msg.responseText);
        Ext.getCmp('gridPanelRutas').store.load();

        ClearMap();

        for (var i = 0; i < geoLayer.length; i++) {
          geoLayer[i].layer.setMap(null);
          geoLayer[i].label.setMap(null);
          geoLayer.splice(i, 1);
        }

        Ext.getCmp("btnGuardar").setDisabled(true);
        Ext.getCmp("btnEditar").setDisabled(true);

      },
      failure: function (msg) {
        alert('Se ha producido un error.');
      }
    });

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
            Cancelar();
            Ext.getCmp('gridPanelRutas').store.load()
          }
        },
        failure: function (msg) {
          alert('Se ha producido un error.');
        }
      });
    }
  }

  function Cancelar() {

    _edit = 0;

    Ext.getCmp("comboZonaOrigen").setDisabled(false);
    Ext.getCmp("comboZonaDestino").setDisabled(false);
    Ext.getCmp("comboFiltroCriterio").setDisabled(false);
    Ext.getCmp('gridPanelRutasGeneradas').setDisabled(false);
    Ext.getCmp("btnGuardar").setDisabled(true);
    Ext.getCmp("btnEditar").setDisabled(true);

    Ext.getCmp("comboZonaOrigen").reset();
    Ext.getCmp("comboZonaDestino").reset();

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
    Ext.getCmp('gridPanelRutasGeneradas').store.removeAll();
    //Ext.getCmp('gridPanelRutasGeneradas').reset()

    if (directionsDisplay) {
      directionsDisplay.setMap(null);
    }

  }

  function GenerarTodas() {
    if (confirm("Advertencia. Se generarán todas las rutas óptimas entre el origen seleccionado y los locales existentes. Esta operación puede demorar. ¿Desea continuar? ")) {

    }

  }

</script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
  <div id="dvMap"></div>
</asp:Content>
