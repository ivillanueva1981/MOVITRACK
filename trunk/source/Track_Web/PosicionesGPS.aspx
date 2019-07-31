<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PosicionesGPS.aspx.cs" Inherits="Track_Web.PosicionesGPS" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
AltoTrack Platform 
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8" type="text/javascript"></script>
  <script src="Scripts/MapFunctions.js" type="text/javascript"></script>
  <script src="Scripts/TopMenu.js" type="text/javascript"></script>
  <script src="Scripts/LabelMarker.js" type="text/javascript"></script>
  
<script type="text/javascript">

  var geoLayer = new Array();
  var arrayPositions = new Array();
  var trafficLayer = new google.maps.TrafficLayer();

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

    var dateDesde = new Ext.form.DateField({
      id: 'dateDesde',
      fieldLabel: 'Desde',
      labelWidth: 80,
      allowBlank: false,
      anchor: '99%',
      format: 'd-m-Y',
      editable: false,
      value: new Date(),
      maxValue: new Date(),
      style: {
        marginTop: '5px',
        marginLeft: '5px'
      },
    });

    dateDesde.on('change', function () {
      var _desde = Ext.getCmp('dateDesde');
      var _hasta = Ext.getCmp('dateHasta');

      _hasta.setValue(_desde.getValue());
      _hasta.setMinValue(_desde.getValue());
      _hasta.setMaxValue(Ext.Date.add(_desde.getValue(), Ext.Date.DAY, 1));
      _hasta.validate();
    });

    var hourDesde = {
      xtype: 'timefield',
      id: 'hourDesde',
      allowBlank: false,
      format: 'H:i',
      minValue: '00:00',
      maxValue: '23:59',
      increment: 10,
      anchor: '99%',
      editable: true,
      value: '00:00',
      style: {
        marginTop: '5px'
      }
    };

    var dateHasta = new Ext.form.DateField({
      id: 'dateHasta',
      fieldLabel: 'Hasta',
      labelWidth: 80,
      allowBlank: false,
      anchor: '99%',
      format: 'd-m-Y',
      editable: false,
      value: new Date(),
      minValue: Ext.getCmp('dateDesde').getValue(),
      maxValue: new Date(),
      style: {
        marginLeft: '5px'
      },
    });

    var hourHasta = {
      xtype: 'timefield',
      id: 'hourHasta',
      allowBlank: false,
      format: 'H:i',
      minValue: '00:00',
      maxValue: '23:59',
      increment: 10,
      anchor: '99%',
      editable: true,
      value: new Date(),
      style: {
        marginTop: '5px'
      },
    };

    var storeFiltroTransportista = new Ext.data.JsonStore({
      autoLoad: true,
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
      labelWidth: 80,
      forceSelection: true,
      store: storeFiltroTransportista,
      valueField: 'Transportista',
      displayField: 'Transportista',
      queryMode: 'local',
      anchor: '99%',
      emptyText: 'Seleccione...',
      enableKeyEvents: true,
      editable: true,
      forceSelection: true,
      style: {
        marginLeft: '5px'
      },
      listeners: {
        change: function (field, newVal) {
          if (newVal != null) {
            FiltrarPatentes();
          }
          Ext.getCmp('comboFiltroPatente').reset();
        }
      }
    });

    var storeFiltroPatente = new Ext.data.JsonStore({
      autoLoad: true,
      fields: ['Patente'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetAllPatentes&Todas=False',
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var comboFiltroPatente = new Ext.form.field.ComboBox({
      id: 'comboFiltroPatente',
      fieldLabel: 'Patente',
      labelWidth: 80,
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

    var toolbarPosiciones = Ext.create('Ext.toolbar.Toolbar', {
      id: 'toolbarPosiciones',
      height: 120,
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
        items: [comboFiltroPatente]
      }]
    });

    var chkMostrarTrafico = new Ext.form.Checkbox({
      id: 'chkMostrarTrafico',
      fieldLabel: 'Mostrar tráfico',
      listeners: {
        change: function (cb, checked) {
          if (checked == true) {
            trafficLayer.setMap(map);
          }
          else {
            trafficLayer.setMap(null);
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
        style: {
        marginLeft: '20px'
      },
      handler: function () {
        Buscar();
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

    var storeZonasToDraw = new Ext.data.JsonStore({
      id: 'storeZonasToDraw',
      autoLoad: false,
      fields: ['IdZona'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonasToDraw',
        reader: { type: 'json', root: 'Zonas' },
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var gridZonasToDraw = Ext.create('Ext.grid.Panel', {
      id: 'gridZonasToDraw',
      store: storeZonasToDraw,
      columns: [
                { text: 'IdZona', flex: 1, dataIndex: 'IdZona' }
             ]

    });

    var storePosiciones = new Ext.data.JsonStore({
      autoLoad: false,
      fields: ['Patente',
                'IdTipoMovil',
                'NombreTipoMovil',
                'Transportista',
                { name: 'Fecha', type: 'date', dateFormat: 'c' },
                'Latitud',
                'Longitud',
                'Velocidad',
                'Direccion',
                'Ignicion',
                'Puerta1',
                'Temperatura1'],
      proxy: new Ext.data.HttpProxy({
        //url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetPosicionesGPS_Ruta',
        url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetPosicionesGPS',
        reader: { type: 'json', root: 'Zonas' },
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var gridPosiciones = Ext.create('Ext.grid.Panel', {
      id: 'gridPosiciones',
      store: storePosiciones,
      tbar: toolbarPosiciones,
      columnLines: true,
      anchor: '100% 100%',
      scroll: false,
      buttons: [chkMostrarTrafico, btnBuscar, btnCancelar],
      viewConfig: {
        style: { overflow: 'auto', overflowX: 'hidden' }
      },
      columns: [
                    { text: 'Fecha', width: 110, dataIndex: 'Fecha', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                    { text: 'Patente', width: 60, dataIndex: 'Patente'},
                    { text: 'IdTipoMovil', dataIndex: 'IdTipoMovil', hidden: true },
                    { text: 'NombreTipoMovil', dataIndex: 'NombreTipoMovil', hidden: true },
                    { text: 'Transp.', flex: 1, dataIndex: 'Transportista'},
                    { text: 'Latitud', dataIndex: 'Latitud', hidden: true },
                    { text: 'Longitud', dataIndex: 'Longitud', hidden: true },
                    { text: 'Vel.', width: 35, dataIndex: 'Velocidad' },
                    { text: 'Direccion', dataIndex: 'Direccion', hidden: true },
                    { text: 'Ignición', width: 55, dataIndex: 'Ignicion'}
             ],
      listeners: {
        select: function (sm, row, rec) {

          var date = Ext.getCmp('gridPosiciones').getStore().data.items[rec].raw.Fecha.toString();

          for (var i = 0; i < markers.length; i++) {
            if (markers[i].labelText == date) {
              markers[i].setAnimation(google.maps.Animation.BOUNCE);
              setTimeout('markers[' + i + '].setAnimation(null);', 800);
            }
          }

          Ext.getCmp('textFecha').setValue(date.replace("T", " "));
          Ext.getCmp('textVelocidad').setValue(row.data.Velocidad);
          Ext.getCmp('textLatitud').setValue(row.data.Latitud);
          Ext.getCmp('textLongitud').setValue(row.data.Longitud);
          Ext.getCmp('textPuerta').setValue(row.data.Puerta1);
          Ext.getCmp('textTemperatura').setValue(row.data.Temperatura1);

          map.setCenter(new google.maps.LatLng(row.data.Latitud, row.data.Longitud));
          //map.setZoom(16);

          Ext.getCmp("gridPosiciones").getSelectionModel().deselectAll(); 

        }
      }
    });

    var textFecha = new Ext.form.TextField({
      id: 'textFecha',
      fieldLabel: 'Fecha',
      labelWidth: 60,
      anchor: '99%',
      readOnly: true
    });

    var textVelocidad = new Ext.form.TextField({
      id: 'textVelocidad',
      fieldLabel: 'Velocidad',
      labelWidth: 60,
      anchor: '99%',
      readOnly: true
    });

    var textLatitud = new Ext.form.TextField({
      id: 'textLatitud',
      fieldLabel: 'Latitud',
      labelWidth: 60,
      anchor: '99%',
      readOnly: true
    });

    var textLongitud = new Ext.form.TextField({
      id: 'textLongitud',
      fieldLabel: 'Longitud',
      labelWidth: 60,
      anchor: '99%',
      readOnly: true
    });

    var textPuerta = new Ext.form.TextField({
      id: 'textPuerta',
      fieldLabel: 'Puerta',
      labelWidth: 60,
      anchor: '99%',
      readOnly: true
    });

    var textTemperatura = new Ext.form.TextField({
      id: 'textTemperatura',
      fieldLabel: 'Temp.',
      labelWidth: 60,
      anchor: '99%',
      readOnly: true
    });

    var viewWidth = Ext.getBody().getViewSize().width;
    var viewHeight = Ext.getBody().getViewSize().height;

    var winDetallesPunto = new Ext.Window({
      id: 'winDetallesPunto',
      title: 'Detalles',
      width: 210,
      height: 200,
      closable: false,
      collapsible: true,
      modal: false,
      initCenter: false,
      x: viewWidth - 220,
      y: 50,
      items: [{
        xtype: 'container',
        layout: 'anchor',
        style: 'padding-top:3px;padding-left:5px;',
        items: [textFecha]
      }, {
        xtype: 'container',
        layout: 'anchor',
        style: 'padding-left:5px;',
        items: [textVelocidad]
      }, {
        xtype: 'container',
        layout: 'anchor',
        style: 'padding-left:5px;',
        items: [textLatitud]
      }, {
        xtype: 'container',
        layout: 'anchor',
        style: 'padding-left:5px;',
        items: [textLongitud]
      }, {
        xtype: 'container',
        layout: 'anchor',
        style: 'padding-left:5px;',
        items: [textPuerta]
      }, {
        xtype: 'container',
        layout: 'anchor',
        style: 'padding-left:5px;',
        items: [textTemperatura]
      }],
      resizable: false,
      border: true,
      draggable: false
    }).show();

    var leftPanel = new Ext.FormPanel({
      id: 'leftPanel',
      region: 'west',
      margins: '0 0 3 3',
      border: true,
      width: 480,
      minWidth: 300,
      maxWidth: viewWidth / 2,
      layout: 'anchor',
      split: true,
      collapsible: true,
      items: [gridPosiciones]
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
      Ext.getCmp('winDetallesPunto').setPosition(Ext.getBody().getViewSize().width - 220, 50, true)
    });

  }); 

</script>

<script type="text/javascript">

  Ext.onReady(function () {
    GeneraMapa("dvMap", true);
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

  function Buscar() {

    if (!Ext.getCmp('leftPanel').getForm().isValid()) {
      return;
    }

    Ext.getCmp('gridPosiciones').store.removeAll();
    ClearMap();
    Ext.getCmp('textFecha').reset();
    Ext.getCmp('textVelocidad').reset();
    Ext.getCmp('textLatitud').reset();
    Ext.getCmp('textLongitud').reset();
    Ext.getCmp('textPuerta').reset();
    Ext.getCmp('textTemperatura').reset();

    var desde = Ext.getCmp('dateDesde').getRawValue() + " " + Ext.getCmp('hourDesde').getRawValue();
    var hasta = Ext.getCmp('dateHasta').getRawValue() + " " + Ext.getCmp('hourHasta').getRawValue();
    var patente = Ext.getCmp('comboFiltroPatente').getValue();

    var storePos = Ext.getCmp('gridPosiciones').store;
    var storeZone = Ext.getCmp('gridZonasToDraw').store;

    storePos.load({
      params: {
        fechaDesde: desde,
        fechaHasta: hasta,
        patente: patente
      },
      callback: function (r, options, success) {
        if (success) {

          storeZone.load({
            params: {
              fechaDesde: desde,
              fechaHasta: hasta,
              patente1: patente,
              patente2: ''
            },
            callback: function (r, options, success) {
              if (success) {

                MuestraRutaViaje();

                var store = Ext.getCmp('gridZonasToDraw').getStore();
                for (var i = 0; i < store.count(); i++) {
                  DrawZone(store.getAt(i).data.IdZona);
                }

              }
            }

          });

        }

      }
    });

  }

  function Cancelar() {

    arrayPositions.splice(0, arrayPositions.length);

    Ext.getCmp('dateDesde').reset();
    Ext.getCmp('hourDesde').reset();
    Ext.getCmp('dateHasta').reset();
    Ext.getCmp('hourHasta').reset();
    Ext.getCmp('comboFiltroTransportista').reset();
    Ext.getCmp('comboFiltroPatente').reset();
    Ext.getCmp('comboFiltroPatente').store.load();

    Ext.getCmp('gridPosiciones').store.removeAll();
    ClearMap();

    for (var i = 0; i < geoLayer.length; i++) {
      geoLayer[i].layer.setMap(null);
      geoLayer[i].label.setMap(null);
    }
    geoLayer.splice(0, geoLayer.length);

    Ext.getCmp('textFecha').reset();
    Ext.getCmp('textVelocidad').reset();
    Ext.getCmp('textLatitud').reset();
    Ext.getCmp('textLongitud').reset();
    Ext.getCmp('textPuerta').reset();
    Ext.getCmp('textTemperatura').reset();
  }

  function MuestraRutaViaje() {

    var store = Ext.getCmp('gridPosiciones').getStore();
    var rowCount = store.count();
    var iterRow = 0;

    while (iterRow < rowCount) {

      var dir = parseInt(store.data.items[iterRow].raw.Direccion);

      var lat = store.data.items[iterRow].raw.Latitud;
      var lon = store.data.items[iterRow].raw.Longitud;

      var Latlng = new google.maps.LatLng(lat, lon);

      arrayPositions.push({ Fecha: store.data.items[iterRow].raw.Fecha.toString(),
        Velocidad: store.data.items[iterRow].raw.Velocidad,
        Latitud: lat,
        Longitud: lon,
        LatLng: Latlng,
        Puerta: store.data.items[iterRow].raw.Puerta1,
        Temperatura: store.data.items[iterRow].raw.Temperatura1
      });

      if (store.data.items[iterRow].raw.Velocidad > 0) {

        switch (true) {
          case ((dir >= 338) || (dir < 22)):
            marker = new google.maps.Marker({
              position: Latlng,
              icon: 'Images/Circle_Arrow/1_arrowcircle_blue_N_20x20.png',
              map: map,
              labelText: store.data.items[iterRow].raw.Fecha.toString()
              //labelText: htmlString2,
              //infoWinMark: htmlNew
            });
            break;
          case ((dir >= 22) && (dir < 67)):
            marker = new google.maps.Marker({
              position: Latlng,
              icon: 'Images/Circle_Arrow/2_arrowcircle_blue_NE_20x20.png',
              map: map,
              labelText: store.data.items[iterRow].raw.Fecha.toString()
              //labelText: htmlString2,
              //infoWinMark: htmlNew
            });
            break;
          case ((dir >= 67) && (dir < 112)):
            marker = new google.maps.Marker({
              position: Latlng,
              icon: 'Images/Circle_Arrow/3_arrowcircle_blue_E_20x20.png',
              map: map,
              labelText: store.data.items[iterRow].raw.Fecha.toString()
              //labelText: htmlString2,
              //infoWinMark: htmlNew
            });
            break;
          case ((dir >= 112) && (dir < 157)):
            marker = new google.maps.Marker({
              position: Latlng,
              icon: 'Images/Circle_Arrow/4_arrowcircle_blue_SE_20x20.png',
              map: map,
              labelText: store.data.items[iterRow].raw.Fecha.toString()
              //labelText: htmlString2,
              //infoWinMark: htmlNew
            });
            break;
          case ((dir >= 157) && (dir < 202)):
            marker = new google.maps.Marker({
              position: Latlng,
              icon: 'Images/Circle_Arrow/5_arrowcircle_blue_S_20x20.png',
              map: map,
              labelText: store.data.items[iterRow].raw.Fecha.toString()
              //labelText: htmlString2,
              //infoWinMark: htmlNew
            });
            break;
          case ((dir >= 202) && (dir < 247)):
            marker = new google.maps.Marker({
              position: Latlng,
              icon: 'Images/Circle_Arrow/6_arrowcircle_blue_SW_20x20.png',
              map: map,
              labelText: store.data.items[iterRow].raw.Fecha.toString()
              //labelText: htmlString2,
              //infoWinMark: htmlNew
            });
            break;
          case ((dir >= 247) && (dir < 292)):
            marker = new google.maps.Marker({
              position: Latlng,
              icon: 'Images/Circle_Arrow/7_arrowcircle_blue_W_20x20.png',
              map: map,
              labelText: store.data.items[iterRow].raw.Fecha.toString()
              //labelText: htmlString2,
              //infoWinMark: htmlNew
            });
            break;
          case ((dir >= 292) && (dir < 338)):
            marker = new google.maps.Marker({
              position: Latlng,
              icon: 'Images/Circle_Arrow/8_arrowcircle_blue_NW_20x20.png',
              map: map,
              labelText: store.data.items[iterRow].raw.Fecha.toString()
              //labelText: htmlString2,
              //infoWinMark: htmlNew
            });
            break;
        }
      }
      else {
        marker = new google.maps.Marker({
          position: Latlng,
          icon: 'Images/dot_red_16x16.png',
          map: map,
          labelText: store.data.items[iterRow].raw.Fecha.toString()

          //labelText: htmlString2,
          //infoWinMark: htmlNew
        });
      }

      var label = new Label({
        map: null
      });
      label.bindTo('position', marker, 'position');
      label.bindTo('text', marker, 'labelText');

      google.maps.event.addListener(marker, 'click', function () {
        var latLng = this.position;
        var fec = this.labelText;

        for (i = 0; i < arrayPositions.length; i++) {
          if (arrayPositions[i].Fecha.toString() == fec.toString() & arrayPositions[i].LatLng.toString() == latLng.toString()) {
            Ext.getCmp('textFecha').setValue((arrayPositions[i].Fecha.toString()).replace("T", " "));
            Ext.getCmp('textVelocidad').setValue(arrayPositions[i].Velocidad);
            Ext.getCmp('textLatitud').setValue(arrayPositions[i].Latitud);
            Ext.getCmp('textLongitud').setValue(arrayPositions[i].Longitud);
            Ext.getCmp('textPuerta').setValue(arrayPositions[i].Puerta);
            Ext.getCmp('textTemperatura').setValue(arrayPositions[i].Temperatura);
            break;
          }
        }

      });

      markers.push(marker);
      labels.push(label);


      iterRow++;
    }

    if (rowCount > 0) {
      map.setCenter(markers[markers.length - 1].position);
    }

  }



  function DrawZone(idZona) {

    for (var i = 0; i < geoLayer.length; i++) {
      geoLayer[i].layer.setMap(null);
      geoLayer[i].label.setMap(null);
      geoLayer.splice(i, 1);
    }

    //var colorZone = "#7f7fff";

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

            if (data.idTipoZona == 3) {
              var colorZone = "#FF0000";
            }
            else {
              var colorZone = "#7f7fff";
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

</script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
  <div id="dvMap"></div>
</asp:Content>
