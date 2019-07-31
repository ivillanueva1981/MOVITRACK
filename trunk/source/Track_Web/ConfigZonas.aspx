<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ConfigZonas.aspx.cs" Inherits="Track_Web.ConfigZonas" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
AltoTrack Platform 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

  <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8" type="text/javascript"></script>
  <script src="Scripts/MapFunctions.js" type="text/javascript"></script>
  <script src="Scripts/TopMenu.js" type="text/javascript"></script>
  <script src="Scripts/LabelMarker.js" type="text/javascript"></script>

<script type="text/javascript">

  var checkedZones = new Array();
  var _editing = false;
  var geoLayer = new Array();
  var viewIdZona = '';
  var viewIdTipoZona = '';
  var stackedZones = 0;

  var markerUbicacion = new Object();
  markerUbicacion.marker = null;
  markerUbicacion.label = null;

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

    var numberIdZona = new Ext.form.NumberField({
      fieldLabel: 'Id Zona',
      id: 'numberIdZona',
      allowBlank: false,
      labelWidth: 60,
      anchor: '99%',
      minValue: 1,
      maxValue: 99999999,
      enableKeyEvents: true,
      listeners: {
        'blur': function (_field) {
          ValidarIdZona();
        }
      }
    });

    var textNombre = new Ext.form.TextField({
      fieldLabel: 'Nombre',
      id: 'textNombre',
      allowBlank: false,
      labelWidth: 60,
      anchor: '99%',
      regex: /^[-''&.,_\w\sáéíóúüñÑ\(\)]+$/i,
      regexText: 'Caracteres no válidos.',
      maxLength: 100,
      enableKeyEvents: true
    });

    var storeTipoZona = new Ext.data.JsonStore({
      autoLoad: true,
      fields: ['IdTipoZona', 'NombreTipoZona'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetTipoZonas&Todos=False',
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var comboTipoZona = new Ext.form.field.ComboBox({
      id: 'comboTipoZona',
      fieldLabel: 'Tipo',
      labelWidth: 60,
      allowBlank: false,
      store: storeTipoZona,
      valueField: 'IdTipoZona',
      displayField: 'NombreTipoZona',
      queryMode: 'local',
      anchor: '99%',
      forceSelection: true,
      emptyText: 'Seleccione...',
      enableKeyEvents: true,
      editable: false
    });

    var storeVertices = [];
    propertieStore = Ext.create('Ext.data.ArrayStore', {
      fields: [
                   { name: 'Vertice' },
                   { name: 'Latitud', type: 'double' },
                   { name: 'Longitud', type: 'double' }
                ],
      data: storeVertices
    });

    var gridPanelVertices = Ext.create('Ext.grid.Panel', {
      id: 'gridPanelVertices',
      store: propertieStore,
      anchor: '100% -20',
      columnLines: true,
      scroll: false,
      viewConfig: {
        style: { overflow: 'auto', overflowX: 'hidden' }
      },
      columns: [
                    { text: 'Punto', width: 55, sortable: true, dataIndex: 'Vertice' },
                    { text: 'Latitud', flex: 1, sortable: true, dataIndex: 'Latitud', editor: { allowBlank: true, maxLength: 50, regex: /^[-''&.,\w\sáéíóúüñÑ]+$/i} },
                    { text: 'Longitud', flex: 1, sortable: true, dataIndex: 'Longitud'}],
      listeners: {
        select: function (sm, row, rec) {
          //Función para el evento select de la grilla
          for (var i = 0; i < markers.length; i++) {
            if (markers[i].labelText == row.data.Vertice) {
              markers[i].setAnimation(google.maps.Animation.BOUNCE);
              setTimeout('markers[' + i + '].setAnimation(null);', 800);
            }
          }
        }
      }
    });

    var rowEditing = Ext.create('Ext.grid.plugin.RowEditing', {
      clicksToMoveEditor: 1,
      autoCancel: true
    });

    var btnGuardar = {
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/save_black_20x20.png',
      text: 'Guardar',
      width: 90,
      height: 26,
      /*
      style: {
      marginRight: '5px'
      },
      */
      handler: function () {
        GuardarZona();
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
      /*
      style: {
      marginLeft: '5px'
      },
      */
      handler: function () {

        //Ext.getCmp("panelProperties").getForm().reset();
        Ext.getCmp("numberIdZona").reset();
        Ext.getCmp("textNombre").reset();
        Ext.getCmp("comboTipoZona").reset()
        propertieStore.removeAll();
        Ext.getCmp("numberIdZona").setDisabled(false);
        ClearMap();

        if (markerUbicacion.marker != null) {
          if (markerUbicacion.marker.map != null) {
            markerUbicacion.marker.setMap(null);
            markerUbicacion.label.setMap(null);
          }
        }

        viewIdZona = '';
        _editing = false;

        var _ckId = new Array();
        for (var i = 0; i < checkedZones.length; i++) {
          document.getElementById('viewCheck' + checkedZones[i].toString()).checked = false;
          _ckId.push(checkedZones[i].toString());
        }
        for (var i = 0; i < _ckId.length; i++) {
          var _check = new Object();
          _check.checked = false;
          CheckRow(_check, _ckId[i], true);
        }

      }
    };

    var panelProperties = new Ext.FormPanel({
      id: 'panelProperties',
      title: 'Configuración Zona',
      anchor: '100% 25%',
      collapsible: false,
      titleCollapsed: true,
      bodyStyle: 'padding: 5px;',
      hideCollapseTool: true,
      layout: 'anchor',
      buttons: [btnGuardar, btnCancelar],
      items: [{
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 0.2,
        items: [numberIdZona]
      }, {
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 0.2,
        items: [textNombre]
      }, {
        xtype: 'container',
        layout: 'anchor',
        columnWidth: 0.2,
        items: [comboTipoZona]
      }/*, {
        xtype: 'fieldset',
        anchor: '100% 65%',
        layout: 'anchor',
        title: 'Puntos',
        items: [gridPanelVertices]
      }*/]
    });


    /*
    var panelButtons = new Ext.FormPanel({
    layout: 'anchor',
    id: 'panelButtons',
    anchor: '100% 7%',
    hideCollapseTool: true,
    buttons: [btnGuardar, btnCancelar]
    });
    */
    var storeFiltroTipoZona = new Ext.data.JsonStore({
      fields: ['IdTipoZona', 'NombreTipoZona'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetTipoZonas&Todos=True',
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var comboFiltroTipoZona = new Ext.form.field.ComboBox({
      id: 'comboFiltroTipoZona',
      fieldLabel: 'Filtrar Tipo',
      labelWidth: 85,
      forceSelection: true,
      store: storeFiltroTipoZona,
      valueField: 'IdTipoZona',
      displayField: 'NombreTipoZona',
      queryMode: 'local',
      anchor: '99%',
      style: {
        marginTop: '5px'
      },
      emptyText: 'Seleccione...',
      enableKeyEvents: true,
      editable: false,
      listeners: {
        change: function (field, newVal) {
          if (newVal != null) {
            FiltrarZonas();
          }
        }
      }
    });



    storeFiltroTipoZona.load({
      callback: function (r, options, success) {
        if (success) {
          Ext.getCmp('comboFiltroTipoZona').select(0);
        }
      }
    })

    var textFiltroNombre = new Ext.form.TextField({
      fieldLabel: 'Filtrar Nombre',
      id: 'textFiltroNombre',
      allowBlank: true,
      labelWidth: 85,
      anchor: '99%',
      style: {
        marginTop: '5px'
      },
      maxLength: 20,
      enableKeyEvents: true,
      listeners: {
        'change': {
          fn: function (a, b, c) {
            FiltrarZonas();
          }
        }
      }
    });

    var toolbarZona = Ext.create('Ext.toolbar.Toolbar', {
      id: 'toolbarZona',
      height: 60,
      layout: 'anchor',
      items: [comboFiltroTipoZona, textFiltroNombre]
    });

    var storeZonas = new Ext.data.JsonStore({
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

    storeZonas.load();

    var btnExportarZonas = {
      id: 'btnExportarZonas',
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/export_black_20x20.png',
      text: 'Exportar Zonas',
      width: 105,
      height: 26,
      listeners: {
        click: {
          element: 'el',
          fn: function () {

            var tipoZona = Ext.getCmp('comboFiltroTipoZona').getValue();
            var nombreZona = Ext.getCmp('textFiltroNombre').getValue();

            var mapForm = document.createElement("form");
            mapForm.target = "ToExcel";
            mapForm.method = "POST"; // or "post" if appropriate
            mapForm.action = 'ConfigZonas.aspx?Metodo=ExportExcel';

            //
            var _tipoZona = document.createElement("input");
            _tipoZona.type = "text";
            _tipoZona.name = "tipoZona";
            _tipoZona.value = tipoZona;
            mapForm.appendChild(_tipoZona);

            var _nombreZona = document.createElement("input");
            _nombreZona.type = "text";
            _nombreZona.name = "nombreZona";
            _nombreZona.value = nombreZona;
            mapForm.appendChild(_nombreZona);

            document.body.appendChild(mapForm);
            mapForm.submit();

          }
        }
      }
    };

    var btnMostrarTodas = {
      id: 'btnMostrarTodas',
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/showall_black_20x20.png',
      width: 105,
      height: 26,
      text: 'Mostrar Todas',
      handler: function () {
        MostrarTodas();
      }
    };

    var gridPanelZonas = Ext.create('Ext.grid.Panel', {
      id: 'gridPanelZonas',
      title: 'Zonas',
      //hideCollapseTool: true,
      store: storeZonas,
      anchor: '100% 75%',
      columnLines: true,
      tbar: toolbarZona,
      buttons: [btnExportarZonas, btnMostrarTodas],
      scroll: false,
      viewConfig: {
        style: { overflow: 'auto', overflowX: 'hidden' }
      },
      columns: [
                  { text: 'Ver', width: 27, dataIndex: 'IdZona',
                    renderer: function (value, cell) {
                      ClearPoints();
                      var _ck = false;
                      for (var i = 0; i < checkedZones.length; i++) {
                        if (checkedZones[i] == value) {
                          _ck = true;
                        }
                      }
                      return '<input id="viewCheck' + value.toString() + '" type="checkbox" onclick="CheckRow(this, \'' + value.toString() + '\' );" ' + (_ck ? 'checked' : '') + '/>';
                    }
                  },
                    { text: 'Id Zona', sortable: true, width: 50, dataIndex: 'IdZona' },
                    { text: 'Nombre', sortable: true, flex: 1, dataIndex: 'NombreZona' },
                    { text: 'IdTipoZona', sortable: true, flex: 1, dataIndex: 'IdTipoZona', hidden: true },
                    { text: 'NombreTipoZona', sortable: true, flex: 1, dataIndex: 'NombreTipoZona', hidden: true },
                    {
                      xtype: 'actioncolumn',
                      width: 40,

                      items: [{
                        icon: 'Images/edit.png',
                        tooltip: 'Editar zona',
                        handler: function (grid, rowIndex, colIndex) {
                          var row = grid.getStore().getAt(rowIndex);
                          var idZona = row.data.IdZona;

                          //Ext.getCmp("panelProperties").getForm().reset();
                          Ext.getCmp("numberIdZona").reset();
                          Ext.getCmp("textNombre").reset();
                          Ext.getCmp("comboTipoZona").reset()
                          propertieStore.removeAll();

                          ClearMap();

                          Ext.getCmp("numberIdZona").setValue(idZona);
                          Ext.getCmp("textNombre").setValue(row.data.NombreZona);
                          Ext.getCmp("comboTipoZona").setValue(row.data.IdTipoZona);

                          Ext.getCmp("numberIdZona").setDisabled(true);

                          ShowProperties();

                          GetZona(idZona);
                          _editing = true;

                        }
                      },
                        {
                          icon: 'Images/delete.png',
                          tooltip: 'Eliminar zona',
                          handler: function (grid, rowIndex, colIndex) {
                            var row = grid.getStore().getAt(rowIndex);
                            DeleteZona(row.data.IdZona);

                            Ext.getCmp("numberIdZona").reset();
                            Ext.getCmp("textNombre").reset();
                            Ext.getCmp("comboTipoZona").reset()
                            propertieStore.removeAll();
                          }
                        }]
                    }

              ],
      listeners: {
        select: function (sm, row, rec) {
          viewIdZona = row.data.IdZona;
          viewIdTipoZona = row.data.IdTpoZona;

        }
      }
    });

    /*
    var panelBottomButtons = new Ext.FormPanel({
    layout: 'column',
    id: 'panelBottomButtons',
    hideCollapseTool: true,
    anchor: '100% 7%',
    bodyStyle: 'padding-top:2px;overflow:auto;',
    buttons: [btnExportarZonas, btnMostrarTodas]

    });
    */
    var viewWidth = Ext.getBody().getViewSize().width;

    var leftPanel = new Ext.FormPanel({
      id: 'leftPanel',
      region: 'west',
      margins: '0 0 3 3',
      border: true,
      width: 350,
      minWidth: 250,
      maxWidth: viewWidth / 2,
      layout: 'anchor',
      split: true,
      items: [panelProperties, gridPanelZonas]
    });

    leftPanel.on('collapse', function () {
      google.maps.event.trigger(map, "resize");
    });

    leftPanel.on('expand', function () {
      google.maps.event.trigger(map, "resize");
    });

    var textBuscarDireccion = new Ext.form.TextField({
      fieldLabel: 'Buscar Dirección',
      id: 'textBuscarDireccion',
      labelWidth: 100,
      maxLength: 255,
      enableKeyEvents: true,
      width: 350,
      style: {
        marginRight: '10px'
      }
    });

    var btnBuscarDireccion = {
      id: 'btnBuscarDireccion',
      xtype: 'button',
      iconAlign: 'left',
      icon: 'Images/search_black_16x16.png',
      width: 70,
      height: 23,
      text: 'Buscar',
      handler: function () {

        if (markerUbicacion.marker != null) {
          if (markerUbicacion.marker.map != null) {
            markerUbicacion.marker.setMap(null);
            markerUbicacion.label.setMap(null);
          }
        }

        var direccion = Ext.getCmp("textBuscarDireccion").getValue();
        if (direccion != "") {
          SearchAddress(direccion);
        }
      }
    };

    var toolbarMap = Ext.create('Ext.toolbar.Toolbar', {
      id: 'toolbarMap',
      height: 30,
      //layout: 'anchor'
      items: [textBuscarDireccion, btnBuscarDireccion]
    });

    var centerPanel = new Ext.FormPanel({
      id: 'centerPanel',
      region: 'center',
      border: true,
      margins: '0 3 3 0',
      anchor: '100% 100%',
      contentEl: 'dvMap',
      tbar: toolbarMap
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
  google.maps.event.addListener(map, 'click', CreateMarkerPolyLine);
});

function CheckRow(check, id, centrarMapa) {
    if (check.checked) {
        //var colorZone = "#7f7fff";

        var arrayColors = ['#0000ff', '#66cd00', '#ff4040', '#98f5ff', '#bf3eff', '#ff7f24', '#6495ed', '#ff1493', '#76ee00', '#caff70',
                            '#c1ffc1', '#97ffff', '#ffb90f', '#228b22', '#ffbbff', '#40e0d0', '#ffe7ba', '#ffff00', '#cd8c95', '#bdb76b']

        checkedZones.push(id);
        Ext.Ajax.request({
            url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetVerticesZona',
            params: {
                IdZona: id
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

                        Ext.Ajax.request({
                            url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonesInsideZona',
                            params: {
                                IdZona: id
                            },
                            success: function (data2, success) {
                                if (data2 != null) {
                                    data2 = Ext.decode(data2.responseText);

                                    var colorZone = "#7f7fff";

                                    if (data.idTipoZona == 3) {
                                        colorZone = "#FF0000";
                                    }

                                    if (data2 >= 1) {

                                        colorZone = arrayColors[stackedZones];

                                        stackedZones = stackedZones + 1;
                                        if (stackedZones >= 20)
                                        {
                                            stackedZones = 0;
                                        }
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
                                        //map: viewLabel ? map : null
                                        map: map
                                    });
                                    polygonGrid.label.bindTo('text', polygonGrid.layer, 'labelText');
                                    polygonGrid.layer.setMap(map);

                                    if (centrarMapa == true || centrarMapa == null) {
                                        map.setCenter(new google.maps.LatLng(data.Latitud, data.Longitud));
                                    }
                                    geoLayer.push(polygonGrid);
                                }
                            }
                        })

                    }//
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
                                //map: viewLabel ? map : null
                                map: map
                            });

                            Point.label.bindTo('text', Point.layer, 'labelText');
                            Point.layer.setMap(map);

                            if (centrarMapa == true) {
                                map.setCenter(new google.maps.LatLng(data.Latitud, data.Longitud));
                            }
                            geoLayer.push(Point);

                        }

                }
            },//
            failure: function (msg) {
                alert('Se ha producido un error.');
            }
        });

    }
    else {
        for (var i = 0; i < geoLayer.length; i++) {
            if (id == geoLayer[i].IdZona) {
                geoLayer[i].layer.setMap(null);
                geoLayer[i].label.setMap(null);
                geoLayer.splice(i, 1);
            }
        }
        for (var i = 0; i < checkedZones.length; i++) {
            if (id == checkedZones[i]) {
                checkedZones.splice(i, 1);
            }
        }

    }
}

function CreateMarkerPoint(point, overlay) {
  counter = counter == null ? 1 : counter + 1;
  var image = new google.maps.MarkerImage("Images/greymarker_32x32.png");
  var marker = new google.maps.Marker({
    position: point.latLng,
    icon: image,
    animation: google.maps.Animation.DROP,
    labelText: markers == undefined ? 'Punto 1' : 'Punto ' + (String(counter)),
    dragCrossMove: true,
    draggable: true,
    map: map
  });

  markers.push(marker);
  var label = new Label({
    map: map,
    labelText: markers == undefined ? 'Punto 1' : 'Punto ' + (String(counter)),
  });
  label.set('zIndex', 9999);
  label.bindTo('position', marker, 'position');
  label.bindTo('text', marker, 'labelText');
  labels.push(label);
}

function CreateMarkerPolyLine(point, overlay) {
  counter = counter == null ? 1 : counter + 1;
  var image = new google.maps.MarkerImage("Images/greymarker_32x32.png");
  var marker = new google.maps.Marker({
    position: point.latLng,
    icon: image,
    animation: google.maps.Animation.DROP,
    labelText: markers == undefined ? 'Punto 1' : 'Punto ' + (String(counter)),
    draggable: true,
    bouncy: false,
    dragCrossMove: true,

    map: map
  });
  markers.push(marker);
  var label = new Label({
    labelText: markers == undefined ? 'Punto 1' : 'Punto ' + (String(counter)),
    map: map
  });
  label.set('zIndex', 9999);
  label.bindTo('position', marker, 'position');
  label.bindTo('text', marker, 'labelText');
  labels.push(label);
  google.maps.event.addListener(marker, "drag", function () {
    DrawPolyLine();
  });
  google.maps.event.addListener(marker, "dragend", function () {
    ShowProperties();
  });
  google.maps.event.addListener(marker, "click", function () {
    for (var n = 0; n < markers.length; n++) {
      if (markers[n] == marker) {
        markers[n].setMap(null);
        for (var i = 0; i < labels.length; i++) {
          if (markers[n].labelText == labels[i].labelText) {
            labels[i].setMap(null);
          }
        }
        break;
      }
    }
    markers.splice(n, 1);
    if (markers.length == 0) {
      count = 0;
      counter = 0;
    }
    else {
      count = markers[markers.length - 1].content;
      DrawPolyLine();
    }
    ShowProperties();
  });
  DrawPolyLine();
  ShowProperties();
}

function DrawPolyLine() {
  var lineMode = false;
  var colorZone = "#0000FF";

  if (poly) { poly.setMap(null); }
  points.length = 0;
  for (i = 0; i < markers.length; i++) {
    points.push(markers[i].getPosition());
    lineMode = i < 2 ? true : false;
  }
  if (lineMode) {
    poly = new google.maps.Polyline({ path: points, strokeColor: "#000000", strokeWeight: 1, strokeOpacity: 0.9 });
  }
  else {
    points.push(markers[0].getPosition());
    poly = new google.maps.Polygon({ paths: points, strokeColor: "#000000", strokeWeight: 1, strokeOpacity: 0.9, fillColor: colorZone, fillOpacity: 0.3 });
  }
  poly.setMap(map);
}

//Función que muestra las propiedades de la zona que se está dibujando
function ShowProperties(show) {

  propertieStore.removeAll();

  for (var h = 0; h < markers.length; h++) {
    var fila;
    fila = {
      'Vertice': markers[h].labelText,
      'Latitud': markers[h].getPosition().lat().toString().substring(0, 10),
      'Longitud': markers[h].getPosition().lng().toString().substring(0, 10)
    };
    propertieStore.add(fila);
  }
}

function ValidarIdZona() {
  Ext.Ajax.request({
    url: 'AjaxPages/AjaxZonas.aspx?Metodo=ValidarIdZona',
    params: {
      IdZona: Ext.getCmp('numberIdZona').getValue()
    },
    success: function (data, success) {
      if (data != null) {
        data = (data.responseText.toLowerCase() == 'true');
        if (!data) {
          Ext.getCmp('numberIdZona').markInvalid("El Id de Zona se encuentra registrado.");
        }
        else {
          Ext.getCmp('numberIdZona').clearInvalid();
        } 
      }
    },
    failure: function (msg) {
      alert('Se ha producido un error.');
    }
  });
}

//Función que obtiene la Zona a Editar
function GetZona(IdZona) {

    Ext.Ajax.request({
      url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetVerticesZona',
      params: {
        IdZona: IdZona
      },
      success: function (data, success) {
        if (data != null) {
          data = Ext.decode(data.responseText);
          DrawZone(data);
        }
      },
      failure: function (msg) {
        alert('Se ha producido un error.');
      }
    });
  }

function FiltrarZonas() {
  var idTipoZona = Ext.getCmp('comboFiltroTipoZona').getValue();
  var nombreZona = Ext.getCmp('textFiltroNombre').getValue();
  
  var store = Ext.getCmp('gridPanelZonas').store;
  store.load({
    params: {
      idTipoZona: idTipoZona,
      nombreZona: nombreZona
    },
    callback: function (r, options, success) {
      if (!success) {
        Ext.MessageBox.show({
          title: 'Error',
          msg: 'Se ha producido un error.',
          buttons: Ext.MessageBox.OK
        });
      }
      else{
        Ext.getCmp("numberIdZona").reset();
        Ext.getCmp("textNombre").reset();
        Ext.getCmp("comboTipoZona").reset()
        propertieStore.removeAll();
      }
    }
  });
}

function DeleteZona(idZona) {
  if (confirm("La zona se eliminará permanentemente.¿Desea continuar?")) {

    var _storeZonas = Ext.getCmp('gridPanelZonas').getStore();

    var objCheck = document.getElementById("viewCheck" + idZona);
    objCheck.checked = false; 
    CheckRow(objCheck, idZona, false);

    Ext.Ajax.request({
      url: 'AjaxPages/AjaxZonas.aspx?Metodo=EliminaZona',
      params: {
        'IdZona': idZona
      },
      success: function (data, success) {
        if (data != null) {
          FiltrarZonas();
        }
      },
      failure: function (msg) {
        alert('Se ha producido un error.');
      }
    });
  }
}

function MostrarTodas() {

    Ext.Msg.wait('Espere por favor...', 'Generando zonas');

    var _storeZonas = Ext.getCmp('gridPanelZonas').getStore();

    var countZonas = Ext.getCmp('gridPanelZonas').getStore().count()
    
    for (i = 0; i < countZonas; i++) 
    {   
        var idZona = _storeZonas.data.items[i].data.IdZona
        var objCheck = document.getElementById("viewCheck" + idZona);
        objCheck.checked = true; // Ext.getCmp('chkVerMapa').getValue();
        if (checkedZones.indexOf(idZona) < 0) {
            CheckRow(objCheck, idZona, false);
        }
    }

    Ext.Ajax.request({
      url: 'AjaxPages/AjaxFunctions.aspx?Metodo=ProgressBarCall',
      success: function (response, opts) {

      var task = new Ext.util.DelayedTask(function(){
                Ext.Msg.hide();
      });

       task.delay(1100);

      },
      failure: function (response, opts) {
          Ext.Msg.hide();
      }
    });
    

}

function GuardarZona() {
  var flag = true;
  var message = '';
  var _vertices = new Array();

  if (Ext.getCmp('numberIdZona').hasActiveError()) {
    return;
  }

  if (!Ext.getCmp('panelProperties').getForm().isValid() || !Ext.getCmp("numberIdZona").getValue > 0) {
    return;
  }

  if (markers.length < 1) {
    alert('Debe seleccionar al menos 1 punto para crear la zona.');
    return;
  }

  if (markers.length == 2) {
    alert('Solo es posible crear zonas de tipo Punto o Polígono.');
    return;
  }

  for (var i = 0; i < markers.length; i++) {
    _vertices.push(markers[i].getPosition().lat() + ';' + markers[i].getPosition().lng());
  }

  if (!_editing) {
    //Nueva Zona
    Ext.Ajax.request({
      url: 'AjaxPages/AjaxZonas.aspx?Metodo=NuevaZona',
      params: {
        'IdZona': Ext.getCmp('numberIdZona').getValue(),
        'NombreZona': Ext.getCmp('textNombre').getValue(),
        'IdTipoZona': Ext.getCmp('comboTipoZona').getValue(),
        'Vertices': _vertices
      },
      success: function (msg, success) {
        alert(msg.responseText);
        FiltrarZonas();
        ClearPoints();
        ShowProperties();

        Ext.getCmp("numberIdZona").reset();
        Ext.getCmp("textNombre").reset();
        Ext.getCmp("comboTipoZona").reset()
        propertieStore.removeAll();
        Ext.getCmp('numberIdZona').setDisabled(false);
        _editing = false;

      },
      failure: function (msg) {
        alert('Se ha producido un error. ' + msg);
      }
    });
  }
  else {
    //EditarZona

    var idZona = Ext.getCmp('numberIdZona').getValue()

    Ext.Ajax.request({
      url: 'AjaxPages/AjaxZonas.aspx?Metodo=EditarZona',
      params: {
        'IdZona': idZona,
        'NombreZona': Ext.getCmp('textNombre').getValue(),
        'IdTipoZona': Ext.getCmp('comboTipoZona').getValue(),
        'Vertices': _vertices
      },
      success: function (msg, success) {

        alert(msg.responseText);
        FiltrarZonas();
        ClearPoints();
        ShowProperties();

        Ext.getCmp("numberIdZona").reset();
        Ext.getCmp("textNombre").reset();
        Ext.getCmp("comboTipoZona").reset()
        propertieStore.removeAll();
        Ext.getCmp('numberIdZona').setDisabled(false);
        _editing = false;

      },
      failure: function (msg) {
        alert('Se ha producido un error.');
      }

    });

    var _storeZonas = Ext.getCmp('gridPanelZonas').getStore();

    var objCheck = document.getElementById("viewCheck" + idZona);
    objCheck.checked = false; 
    CheckRow(objCheck, idZona, true);
    objCheck.checked = true; 
    CheckRow(objCheck, idZona, true);

  }

}
    function SearchAddress(address) {
        var geocoder = new google.maps.Geocoder();
        request = { 'address': address,
                    'region': 'CL' };
        geocoder.geocode(request, ShowAddress);
    }

    function ShowAddress(response) {
        if (arguments[1] != "OK") {
            alert("Dirección no encontrada.");
            return;
        } else {
            point = new google.maps.LatLng(response[0].geometry.location.lat(), response[0].geometry.location.lng());
            var resp = request.address + '*' + response[0].geometry.location.lat() + '*' + response[0].geometry.location.lng() + '*';
            var responseArray = resp.split('*');
            if (responseArray[1] != "?") {
                var latitude = responseArray[1];
                var longitude = responseArray[2];

                  var image = new google.maps.MarkerImage("Images/flag_black_32x32.png");
                  var marker = new google.maps.Marker({
                    position: point,
                    icon: image,
                    animation: google.maps.Animation.DROP,
                    labelText: request.address,
                    map: map
                  });
                  
                  markerUbicacion.marker = marker;
                  var label = new Label({
                    map: map,
                    labelText: 'Ubicación'
                  });
                  label.set('zIndex', 9999);
                  label.bindTo('position', marker, 'position');
                  label.bindTo('text', marker, 'labelText');
                  markerUbicacion.label = label;
                  
                google.maps.event.addListener(marker, "click", function () {
                    markerUbicacion.marker.setMap(null);
                    markerUbicacion.label.setMap(null);
                })

                map.setCenter(new google.maps.LatLng(parseFloat(latitude), parseFloat(longitude)));
                map.setZoom(16);
            }
        }
    }


</script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
  <div id="dvMap"></div>
</asp:Content>
