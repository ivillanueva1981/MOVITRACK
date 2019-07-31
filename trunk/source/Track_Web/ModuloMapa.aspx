<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ModuloMapa.aspx.cs" Inherits="Track_Web.ModuloMapa" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
AltoTrack Platform 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyDFhE-5S6P5dI1Q1mFjpgGKKmcbTiM0GbY" type="text/javascript"></script>
  <script src="Scripts/MapFunctions.js" type="text/javascript"></script>
  <script src="Scripts/LabelMarker.js" type="text/javascript"></script>
  <script src="Scripts/RowExpander.js" type="text/javascript"></script>
  
<script type="text/javascript">

  var geoLayer = new Array();
  var arrayPositions = new Array();
  var arrayAlerts = new Array();
  var trafficLayer = new google.maps.TrafficLayer();
  var infowindow = new google.maps.InfoWindow();
  var idAlerta;

  Ext.onReady(function () {

    Ext.QuickTips.init();
    Ext.Ajax.timeout = 600000;
    Ext.override(Ext.form.Basic, { timeout: Ext.Ajax.timeout / 1000 });
    Ext.override(Ext.data.proxy.Server, { timeout: Ext.Ajax.timeout });
    Ext.override(Ext.data.Connection, { timeout: Ext.Ajax.timeout });
    //Ext.form.Field.prototype.msgTarget = 'side';
    //if (Ext.isIE) { Ext.enableGarbageCollector = false; }

    var storeZonasToDraw = new Ext.data.JsonStore({
      id: 'storeZonasToDraw',
      autoLoad: false,
      fields: ['IdZona'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonasToDrawModuloMapa',
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

    var storePosicionesRuta = new Ext.data.JsonStore({
      autoLoad: false,
      fields: ['NroTransporte',
                'LocalDestino',
                'Patente',
                'IdTipoMovil',
                'NombreTipoMovil',
                { name: 'Fecha', type: 'date', dateFormat: 'c' },
                'Latitud',
                'Longitud',
                'Velocidad',
                'Direccion',
                'Ignicion',
                'Puerta1',
                'Temperatura1'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetPosicionesRutaModuloMapa',
        reader: { type: 'json', root: 'Zonas' },
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var gridPosicionesRuta = Ext.create('Ext.grid.Panel', {
      id: 'gridPosicionesRuta',
      store: storePosicionesRuta,
      columns: [
                    { text: 'Patente', dataIndex: 'Patente', hidden: true },
                    { text: 'IdTipoMovil', dataIndex: 'IdTipoMovil', hidden: true },
                    { text: 'NombreTipoMovil', dataIndex: 'NombreTipoMovil', hidden: true },
                    { text: 'Fecha', dataIndex: 'Fecha', hidden: true, renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                    { text: 'Latitud', dataIndex: 'Latitud', hidden: true },
                    { text: 'Longitud', dataIndex: 'Longitud', hidden: true },
                    { text: 'Velocidad', dataIndex: 'Velocidad', hidden: true },
                    { text: 'Direccion', dataIndex: 'Direccion', hidden: true },
                    { text: 'Ignicion', dataIndex: 'Ignicion', hidden: true },
                    { text: 'Puerta', dataIndex: 'Puerta1', hidden: true },
                    { text: 'Temperatura', dataIndex: 'Temperatura1', hidden: true }
             ]
    });

    var storeAlertasRuta = new Ext.data.JsonStore({
      autoLoad: false,
      fields: [ 'NroTransporte',
                'LocalDestino',
                { name: 'FechaInicioAlerta', type: 'date', dateFormat: 'c' },
                { name: 'FechaHoraCreacion', type: 'date', dateFormat: 'c' },
                'PatenteTracto',
                'TextFechaCreacion',
                'PatenteTrailer',
                'Velocidad',
                'Latitud',
                'Longitud',
                'TipoAlerta',
                'DescripcionAlerta',
                'Ocurrencia',
                'Puerta1',
                'Temp1'],
      proxy: new Ext.data.HttpProxy({
        url: 'AjaxPages/AjaxAlertas.aspx?Metodo=GetAlertasRutaModuloMapa',
        reader: { type: 'json', root: 'Zonas' },
        headers: {
          'Content-type': 'application/json'
        }
      })
    });

    var gridPanelAlertasRuta = Ext.create('Ext.grid.Panel', {
      id: 'gridPanelAlertasRuta',
      title: 'Alertas',
      //hideCollapseTool: true,
      store: storeAlertasRuta,
      anchor: '100% 100%',
      columnLines: true,
      scroll: false,
      viewConfig: {
        style: { overflow: 'auto', overflowX: 'hidden' }
      },
      columns: [
                    { text: 'Fecha Inicio', sortable: true, width: 110, dataIndex: 'FechaInicioAlerta', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                    { text: 'Fecha Envío', sortable: true, width: 110, dataIndex: 'FechaHoraCreacion', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                    {text: 'Descripción', sortable: true, flex: 1, dataIndex: 'DescripcionAlerta' }
              ],
      listeners: {
        select: function (sm, row, rec) {

          var date = Ext.getCmp('gridPanelAlertasRuta').getStore().data.items[rec].raw.FechaHoraCreacion.toString();

          for (var i = 0; i < markers.length; i++) {
            if (markers[i].labelText == date) {
              markers[i].setAnimation(google.maps.Animation.BOUNCE);
              setTimeout('markers[' + i + '].setAnimation(null);', 800);

              var contentString =

                  '<br>' +
                      '<table>' +
                        '<tr>' +
                            '       <td><b>Nro. Transporte:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '       <td>' + row.data.NroTransporte + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '       <td><b>Local destino:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '       <td>' + row.data.LocalDestino + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '       <td><b>Fecha:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '       <td>' + row.data.TextFechaCreacion + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Velocidad:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + row.data.Velocidad + ' Km/h </td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Latitud:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + row.data.Latitud + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Longitud:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + row.data.Longitud + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Puerta:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + row.data.Puerta1 + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Temperatura:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + row.data.Temp1 + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Descripción:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + row.data.DescripcionAlerta + '</td>' +
                        '</tr>' +

                      '</table>' +
                    '<br>';
                
              infowindow.setContent(contentString);
              infowindow.open(map, markers[i]);

              break;
            }
          }

          map.setCenter(new google.maps.LatLng(row.data.Latitud, row.data.Longitud));
          //map.setZoom(16);

        }
      }
    });

    idAlerta = location.search.split('ID=')[1]
    if (idAlerta == undefined) {
        idAlerta = 0;
    }

    GetPosiciones(idAlerta)
    GetAlertasRuta(idAlerta)

    var viewWidth = Ext.getBody().getViewSize().width;
    var viewHeight = Ext.getBody().getViewSize().height;

    var textDistancia = new Ext.form.TextField({
      id: 'textDistancia',
      fieldLabel: 'Distancia',
      labelWidth: 60,
      anchor: '99%',
      readOnly: true
    });

    var textTiempo = new Ext.form.TextField({
      id: 'textTiempo',
      fieldLabel: 'Tiempo',
      labelWidth: 60,
      anchor: '99%',
      readOnly: true
    });

    var winDistanciaTiempo = new Ext.Window({
      id: 'winDistanciaTiempo',
      title: 'Distancia / Tiempo hasta Local',
      width: 210,
      height: 30,
      closable: true,
      closeAction: 'hide',
      modal: false,
      initCenter: false,
      x: viewWidth - 220,
      y: 335,
      items: [{
        xtype: 'container',
        layout: 'anchor',
        style: 'padding-top:3px;padding-left:5px;',
        items: [textDistancia]
      }, {
        xtype: 'container',
        layout: 'anchor',
        style: 'padding-left:5px;',
        items: [textTiempo]
      }
      ],
      resizable: false,
      border: true,
      draggable: false
    });

    var leftPanel = new Ext.FormPanel({
      id: 'leftPanel',
      region: 'west',
      margins: '0 0 3 3',
      border: true,
      width: 450,
      minWidth: 300,
      maxWidth: viewWidth / 1.5,
      layout: 'anchor',
      split: true,
      collapsible: true,
      hideCollapseTool: true,
      items: [gridPanelAlertasRuta]
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
      items: [leftPanel, centerPanel]
    });

    viewport.on('resize', function () {
      google.maps.event.trigger(map, "resize");
      Ext.getCmp('winDistanciaTiempo').setPosition(Ext.getBody().getViewSize().width - 220, 50, true)

    });

  }); 

</script>

<script type="text/javascript">

  Ext.onReady(function () {
    GeneraMapa("dvMap", true);
  });

  function GetAlertasRuta(nroTransporte, destino, estadoViaje) {

    var store = Ext.getCmp('gridPanelAlertasRuta').store;
    store.load({
      params: {
        idAlerta: idAlerta
      },
      callback: function (r, options, success) {
        if (!success) {
          Ext.MessageBox.show({
            title: 'Error',
            msg: 'Se ha producido un error. 2',
            buttons: Ext.MessageBox.OK
          });
        }
        else {
          MuestraAlertasViaje();
        }
      }
    });
  }

  function GetPosiciones(idAlerta) {

    Ext.getCmp('gridPosicionesRuta').store.removeAll();

    var store = Ext.getCmp('gridPosicionesRuta').store;
    var storeZone = Ext.getCmp('gridZonasToDraw').store;
      /*
    var fec;

    if (estadoViaje == 'Finalizado') {
      fec = fechaHoraLlegadaDestino;
    }
    if (estadoViaje == 'Cerrado por Sistema') {
      fec = fechaHoraCierreSistema;
    }
    else {
      fec = new Date();
    }
    */
    store.load({
      params: {
        idAlerta: idAlerta
      },
      callback: function (r, options, success) {
        if (success) {

          storeZone.load({
            params: {
              idAlerta: idAlerta
            },
            callback: function (r, options, success) {
              if (success) {

                MuestraRutaViaje();

                var store = Ext.getCmp('gridZonasToDraw').getStore();
                for (var i = 0; i < store.count(); i++) {
                  DrawZone(store.getAt(i).data.IdZona);
                }

               // DrawZone(origen);
               // var storeViajes = Ext.getCmp('gridPanelViajesRuta').store;

               // for (var i = 0; i < storeViajes.count(); i++) {
                //  if (storeViajes.getAt(i).data.NroTransporte == nroTransporte) {
                //    DrawZone(storeViajes.getAt(i).data.CodigoDestino);
                //  }
                //}

              }
            }

          });

        }
      }
    });

  }

  function MuestraRutaViaje() {

    var store = Ext.getCmp('gridPosicionesRuta').getStore();
    var rowCount = store.count();
    var iterRow = 0;

    while (iterRow < rowCount) {

      var dir = parseInt(store.data.items[iterRow].raw.Direccion);

      var lat = store.data.items[iterRow].raw.Latitud;
      var lon = store.data.items[iterRow].raw.Longitud;

      var Latlng = new google.maps.LatLng(lat, lon);

      arrayPositions.push(
        {
        NroTransporte: store.data.items[iterRow].raw.NroTransporte.toString(),
        LocalDestino: store.data.items[iterRow].raw.LocalDestino.toString(),
        Fecha: store.data.items[iterRow].raw.Fecha.toString(),
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

            var Lat = arrayPositions[i].Latitud;
            var Lon = arrayPositions[i].Longitud;

            var contentString =

                  '<br>' +
                      '<table>' +
                        '<tr>' +
                            '        <td><b>Nro. Transporte:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayPositions[i].NroTransporte + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Local destino:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayPositions[i].LocalDestino + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '       <td><b>Fecha</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '       <td>' + (arrayPositions[i].Fecha.toString()).replace("T", " ") + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Velocidad:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayPositions[i].Velocidad + ' Km/h </td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Latitud:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayPositions[i].Latitud + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Longitud:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayPositions[i].Longitud + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Puerta:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayPositions[i].Puerta + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Temperatura:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayPositions[i].Temperatura + '</td>' +
                        '</tr>' +

                      '</table>' +
                    '<br>';

            infowindow.setContent(contentString);
            infowindow.open(map, this);

            break;
          }
        }

      });

      markers.push(marker);
      labels.push(label);

      iterRow++;
    }

    if (rowCount > 0) {
      var len = markers.length - 1
      map.setCenter(markers[len].position);
      markers[len].setAnimation(google.maps.Animation.BOUNCE);
      setTimeout('markers[' + len + '].setAnimation(null);', 800);
    }

  }

  function MuestraAlertasViaje() {

    var store = Ext.getCmp('gridPanelAlertasRuta').getStore();
    var rowCount = store.count();
    var iterRow = 0;

    while (iterRow < rowCount) {
      var descrip = store.data.items[iterRow].raw.DescripcionAlerta;

      var lat = store.data.items[iterRow].raw.Latitud;
      var lon = store.data.items[iterRow].raw.Longitud;

      var Latlng = new google.maps.LatLng(lat, lon);

      arrayAlerts.push({
        NroTransporte: store.data.items[iterRow].raw.NroTransporte.toString(),
        LocalDestino: store.data.items[iterRow].raw.LocalDestino.toString(),
        Fecha: store.data.items[iterRow].raw.FechaHoraCreacion.toString(),
        TextFechaCreacion: store.data.items[iterRow].raw.TextFechaCreacion,
        Velocidad: store.data.items[iterRow].raw.Velocidad,
        Latitud: lat,
        Longitud: lon,
        LatLng: Latlng,
        Puerta: store.data.items[iterRow].raw.Puerta1,
        Temperatura: store.data.items[iterRow].raw.Temp1,
        Descripcion: store.data.items[iterRow].raw.DescripcionAlerta
      });

      switch (true) {
        case (descrip == 'CRUCE GEOCERCA PARA INGRESAR A LOCAL'):
          marker = new google.maps.Marker({
            //idBusqueda: busquedaAud,
            position: Latlng,
            icon: 'Images/finishflag_24x24.png',
            map: map,
            labelText: store.data.items[iterRow].raw.FechaHoraCreacion.toString()
            //labelText: htmlString2,
            //infoWinMark: htmlNew
          });
          break;
        default:
          marker = new google.maps.Marker({
            //idBusqueda: busquedaAud,
            position: Latlng,
            icon: 'Images/alert_orange_22x22.png',
            map: map,
            labelText: store.data.items[iterRow].raw.FechaHoraCreacion.toString()
            //labelText: htmlString2,
            //infoWinMark: htmlNew
          });
          break;
      }



      var label = new Label({
        //idBusqueda: busquedaAud,
        map: null
      });
      label.bindTo('position', marker, 'position');
      label.bindTo('text', marker, 'labelText');

      google.maps.event.addListener(marker, 'click', function () {

        var latLng = this.position;
        var fec = this.labelText;

        for (i = 0; i < arrayAlerts.length; i++) {
          if (arrayAlerts[i].Fecha.toString() == fec.toString() & arrayAlerts[i].LatLng.toString() == latLng.toString()) {

            var contentString =

                  '<br>' +
                      '<table>' +
                        '<tr>' +
                            '       <td><b>Nro. Transporte:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '       <td>' + arrayAlerts[i].NroTransporte + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '       <td><b>Local destino:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '       <td>' + arrayAlerts[i].LocalDestino + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '       <td><b>Fecha:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '       <td>' + arrayAlerts[i].TextFechaCreacion + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Velocidad:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayAlerts[i].Velocidad + ' Km/h </td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Latitud:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayAlerts[i].Latitud + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Longitud:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayAlerts[i].Longitud + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Puerta:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayAlerts[i].Puerta + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Temperatura:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayAlerts[i].Temperatura + '</td>' +
                        '</tr>' +
                        '<tr>' +
                            '        <td><b>Descripción:</b></td>' +
                            '       <td><pre>     </pre></td>' +
                            '        <td>' + arrayAlerts[i].Descripcion + '</td>' +
                        '</tr>' +

                      '</table>' +
                    '<br>';

            infowindow.setContent(contentString);
            infowindow.open(map, this);

            break;

          }
        }

      });


      markers.push(marker);
      labels.push(label);

      iterRow++;
    }

  }

  function DrawZone(idZona) {

    for (var i = 0; i < geoLayer.length; i++) {
      geoLayer[i].layer.setMap(null);
      geoLayer[i].label.setMap(null);
      geoLayer.splice(i, 1);
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
        alert('Se ha producido un error. 3');
      }
    });
  }

  function CalculateDistanceTime(estadoLat, estadoLon, destinoLat, destinoLon) {

    var service = new google.maps.DistanceMatrixService();
    var origen = new google.maps.LatLng(estadoLat, estadoLon);
    var destino = new google.maps.LatLng(destinoLat, destinoLon);

    service.getDistanceMatrix(
    {
      origins: [origen],
      destinations: [destino],
      travelMode: google.maps.TravelMode.DRIVING,
      unitSystem: google.maps.UnitSystem.METRIC,
      avoidHighways: false,
      avoidTolls: false
    }, callback);
  }

  function callback(response, status) {
    if (status == google.maps.DistanceMatrixStatus.OK) {

      var distance = response.rows[0].elements[0].distance.text;
      var time = response.rows[0].elements[0].duration.text;

      Ext.getCmp('winDistanciaTiempo').show();

      Ext.getCmp('textDistancia').setValue(distance);
      Ext.getCmp('textTiempo').setValue(time);

      Ext.getCmp('winDistanciaTiempo').setPosition(Ext.getBody().getViewSize().width - 220, 50, true)
    }
  }

</script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
  <div id="dvMap"></div>
</asp:Content>

