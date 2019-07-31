<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Visualizador.aspx.cs" Inherits="Track_Web.Visualizador" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
    AltoTrack Platform 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8" type="text/javascript"></script>
    <script src="Scripts/MapFunctions.js" type="text/javascript"></script>
    <script src="Scripts/markerclusterer.js" type="text/javascript"></script>
    <script src="Scripts/TopMenu.js" type="text/javascript"></script>
    <script src="Scripts/LabelMarker.js" type="text/javascript"></script>

    <script type="text/javascript">

        var markersRoute = new Array();
        var markersMovil = new Array();
        var geoLayer = new Array();
        var movilLayer = new Array();
        var routeLayer = new Array();
        var trafficLayer = new google.maps.TrafficLayer();
        var infowindow = new google.maps.InfoWindow();
        var markerClusterer;
        var transportista = "";

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
                forceSelection: true,
                store: storeFiltroTransportista,
                valueField: 'Transportista',
                displayField: 'Transportista',
                queryMode: 'local'
            });

            storeFiltroTransportista.load({
                callback: function (r, options, success) {
                    if (success) {
                        transportista = Ext.getCmp("comboFiltroTransportista").store.getAt(0).get("Transportista");
                    }
                }
            })

            var storeFiltroComunaMapa = new Ext.data.JsonStore({
                fields: ['IdComuna', 'ComunaMapa'],
                data: [{ IdComuna: '0', ComunaMapa: 'Cerrillos', Latitud: '-33.49217', Longitud: '-70.70842' },
                         { IdComuna: '1', ComunaMapa: 'Cerro Navia', Latitud: '-33.429087', Longitud: '-70.730442' },
                         { IdComuna: '2', ComunaMapa: 'Conchalí', Latitud: '-33.39629', Longitud: '-70.67024' },
                         { IdComuna: '3', ComunaMapa: 'El Bosque', Latitud: '-33.553833', Longitud: '-70.673269' },
                         { IdComuna: '4', ComunaMapa: 'Estación Central', Latitud: '-33.462054', Longitud: '-70.701824' },
                         { IdComuna: '5', ComunaMapa: 'Huechuraba', Latitud: '-33.37472', Longitud: '-70.63464' },
                         { IdComuna: '6', ComunaMapa: 'Independencia', Latitud: '-33.420431', Longitud: '-70.66166' },
                         { IdComuna: '7', ComunaMapa: 'La Cisterna', Latitud: '-33.534594', Longitud: '-70.665977' },
                         { IdComuna: '8', ComunaMapa: 'La Florida', Latitud: '-33.533446', Longitud: '-70.582735' },
                         { IdComuna: '9', ComunaMapa: 'La Granja', Latitud: '-33.538966', Longitud: '-70.619992' },
                         { IdComuna: '10', ComunaMapa: 'La Pintana', Latitud: '-33.586674', Longitud: '-70.634802' },
                         { IdComuna: '11', ComunaMapa: 'La Reina', Latitud: '-33.440885', Longitud: '-70.557476' },
                         { IdComuna: '12', ComunaMapa: 'Las Condes', Latitud: '-33.40866', Longitud: '-70.568613' },
                         { IdComuna: '13', ComunaMapa: 'Lo Barnechea', Latitud: '-33.362547', Longitud: '-70.501523' },
                         { IdComuna: '14', ComunaMapa: 'Lo Espejo', Latitud: '-33.518828', Longitud: '-70.694159' },
                         { IdComuna: '15', ComunaMapa: 'Lo Prado', Latitud: '-33.44206', Longitud: '-70.71962' },
                         { IdComuna: '16', ComunaMapa: 'Macul', Latitud: '-33.49', Longitud: '-70.6' },
                         { IdComuna: '17', ComunaMapa: 'Maipú', Latitud: '-33.509344', Longitud: '-70.755464' },
                         { IdComuna: '18', ComunaMapa: 'Ñuñoa', Latitud: '-33.45099', Longitud: '-70.59298' },
                         { IdComuna: '19', ComunaMapa: 'Pedro Aguirre Cerda', Latitud: '-33.488703', Longitud: '-70.670953' },
                         { IdComuna: '20', ComunaMapa: 'Peñalolén', Latitud: '-33.473558', Longitud: '-70.55387' },
                         { IdComuna: '21', ComunaMapa: 'Providencia', Latitud: '-33.43198', Longitud: '-70.60951' },
                         { IdComuna: '22', ComunaMapa: 'Pudahuel', Latitud: '-33.440915', Longitud: '-70.755812' },
                         { IdComuna: '23', ComunaMapa: 'Puente Alto', Latitud: '-33.59476', Longitud: '-70.57933' },
                         { IdComuna: '24', ComunaMapa: 'Quilicura', Latitud: '-33.368822', Longitud: '-70.731123' },
                         { IdComuna: '25', ComunaMapa: 'Quinta Normal', Latitud: '-33.41895', Longitud: '-70.702854' },
                         { IdComuna: '26', ComunaMapa: 'Recoleta', Latitud: '-33.40678', Longitud: '-70.640804' },
                         { IdComuna: '27', ComunaMapa: 'Renca', Latitud: '-33.403697', Longitud: '-70.713522' },
                         { IdComuna: '28', ComunaMapa: 'San Bernardo', Latitud: '-33.591989', Longitud: '-70.705338' },
                         { IdComuna: '29', ComunaMapa: 'San Joaquín', Latitud: '-33.492765', Longitud: '-70.62899' },
                         { IdComuna: '30', ComunaMapa: 'San Miguel', Latitud: '-33.48598', Longitud: '-70.64976' },
                         { IdComuna: '31', ComunaMapa: 'San Ramón', Latitud: '-33.542156', Longitud: '-70.647184' },
                         { IdComuna: '32', ComunaMapa: 'Santiago', Latitud: '-33.437107', Longitud: '-70.650253' },
                         { IdComuna: '33', ComunaMapa: 'Vitacura', Latitud: '-33.38957', Longitud: '-70.571421' }
                ]
            });

            var comboFiltroComunaMapa = new Ext.form.field.ComboBox({
                id: 'comboFiltroComunaMapa',
                fieldLabel: 'Comuna',
                store: storeFiltroComunaMapa,
                valueField: 'IdComuna',
                displayField: 'ComunaMapa',
                emptyText: 'Seleccione...',
                queryMode: 'local',
                anchor: '99%',
                labelWidth: 100,
                editable: false,
                style: {
                    marginTop: '5px',
                    marginLeft: '5px'
                },
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                forceSelection: true,
                listeners: {
                    select: function () {
                        FiltrarComunaMapa();
                    }
                }
            });

            var storeTipoZonas = new Ext.data.JsonStore({
                id: 'storeTipoZonas',
                autoLoad: false,
                fields: ['IdTipoZona', 'NombreTipoZona'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetTipoZonas&Todos=False',
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var storeZonas = new Ext.data.JsonStore({
                id: 'storeZonas',
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

            var storeRutas = new Ext.data.JsonStore({
                id: 'storeRutas',
                autoLoad: false,
                fields: ['IdRuta', 'IdOrigen', 'NombreZonaOrigen', 'IdDestino', 'NombreZonaDestino', 'ResumenRuta'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxRutas.aspx?Metodo=GetRutas',
                    reader: { type: 'json', root: 'Rutas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var storeMoviles = new Ext.data.JsonStore({
                autoLoad: false,
                fields: [{ name: 'UltReporte' },
                          'TextUltReporte',
                          'Patente',
                          'Transportista',
                          'Latitud',
                          'Longitud',
                          'Ignicion',
                          'Velocidad',
                          'Direccion',
                          'EstadoGPS',
                          'Puerta1',
                          'Temperatura1',
                          'EstadoViaje',
                          'NroTransporte',
                          'CodigoDestino'],
                groupField: 'EstadoViaje',
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetFlotaOnline',
                    reader: { type: 'json', root: 'Zonas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var storeTreePanel = Ext.create('Ext.data.TreeStore', {
                id: 'storeTreePanel',
                root: {
                    expanded: false,
                    useArrows: true,
                    text: '',
                    user: '',
                    status: '',
                    children: [
                        {
                            text: 'Rutas',
                            leaf: false,
                            checked: true,
                            expanded: true,
                            iconCls: 'icon_route' //the icon CSS class
                        },
                        {
                            text: 'Zonas',
                            leaf: false,
                            checked: false,
                            expanded: false,
                            iconCls: 'icon_zona' //the icon CSS class
                        },
                        {
                            text: 'Móviles',
                            leaf: false,
                            checked: false,
                            expanded: true,
                            iconCls: 'icon_truck', //the icon CSS class
                            children: [
                                {
                                    text: 'En Viaje',
                                    leaf: false,
                                    checked: true,
                                    expanded: true,
                                    iconCls: 'icon_truck_loaded' //the icon CSS class
                                },
                                {
                                    text: 'Liberados',
                                    leaf: false,
                                    checked: false,
                                    expanded: false,
                                    iconCls: 'icon_truck_unloaded' //the icon CSS class
                                }
                            ]
                        }

                    ]
                }
            });

            storeRutas.load({
                callback: function (r, options, success) {
                    if (success) {

                        Ext.Msg.wait('Espere por favor...', 'Generando');

                        storeTreePanel.getRootNode().getChildAt(0).data.text = 'Rutas (' + storeRutas.count() + ')';

                        for (var i = 0; i < storeRutas.count() ; i++) {
                            var childRuta;
                            var idRuta = storeRutas.getAt(i).data.IdRuta;
                            var idOrigen = storeRutas.getAt(i).data.IdOrigen;
                            var idDestino = storeRutas.getAt(i).data.IdDestino;
                            var nombreRuta = storeRutas.data.getAt(i).data.NombreZonaOrigen + ' -> ' + storeRutas.data.getAt(i).data.NombreZonaDestino;

                            childRuta = {
                                tipo: 'Ruta',
                                idRuta: idRuta,
                                idOrigen: idOrigen,
                                idDestino: idDestino,
                                nombre: nombreRuta,
                                text: nombreRuta,
                                leaf: true,
                                checked: true,
                                iconCls: 'icon_route'
                            };

                            storeTreePanel.getRootNode().getChildAt(0).appendChild(childRuta);
                            GetRoute(idRuta, false);

                        }

                        storeZonas.load({
                            callback: function (r, options, success) {

                                storeTreePanel.getRootNode().getChildAt(1).data.text = 'Zonas (' + storeZonas.count() + ')';

                                storeTipoZonas.load({
                                    callback: function (r, options, success) {
                                        if (success) {

                                            for (var i = 0; i < storeTipoZonas.count() ; i++) {
                                                var childTipoZona;
                                                var IdTipoZona = storeTipoZonas.getAt(i).data.IdTipoZona;
                                                var NombreTipoZona = storeTipoZonas.data.getAt(i).data.NombreTipoZona;

                                                if (IdTipoZona == 1 || IdTipoZona == 3 || IdTipoZona == 11) {
                                                    childTipoZona = {
                                                        tipo: 'TipoZona',
                                                        idTipoZona: IdTipoZona,
                                                        nombre: NombreTipoZona,
                                                        text: NombreTipoZona,
                                                        leaf: false,
                                                        checked: true,
                                                        iconCls: 'icon_zona'
                                                    };
                                                }
                                                else {
                                                    childTipoZona = {
                                                        tipo: 'TipoZona',
                                                        idTipoZona: IdTipoZona,
                                                        nombre: NombreTipoZona,
                                                        text: NombreTipoZona,
                                                        leaf: false,
                                                        checked: false,
                                                        iconCls: 'icon_zona'
                                                    };
                                                }

                                                storeTreePanel.getRootNode().getChildAt(1).appendChild(childTipoZona);

                                                var countZonas = 0;

                                                for (var j = 0; j < storeZonas.count() ; j++) {

                                                    var Zona_IdTipoZona = storeZonas.data.getAt(j).data.IdTipoZona;

                                                    if (IdTipoZona == Zona_IdTipoZona) {
                                                        var childZona;
                                                        var IdZona = storeZonas.data.getAt(j).data.IdZona;
                                                        var NombreZona = storeZonas.data.getAt(j).data.NombreZona;
                                                        var Latitud = storeZonas.data.getAt(j).data.Latitud;
                                                        var Longitud = storeZonas.data.getAt(j).data.Longitud;

                                                        if (IdTipoZona == 1) {
                                                            childZona = {
                                                                tipo: 'Zona',
                                                                idZona: IdZona,
                                                                idTipoZona: IdTipoZona,
                                                                nombre: NombreZona,
                                                                latitud: Latitud,
                                                                longitud: Longitud,
                                                                text: NombreZona,
                                                                leaf: true,
                                                                checked: true,
                                                                iconCls: 'icon_zona'
                                                            };

                                                            DrawZone(IdZona, IdTipoZona);
                                                        }
                                                        else {
                                                            childZona = {
                                                                tipo: 'Zona',
                                                                idZona: IdZona,
                                                                idTipoZona: IdTipoZona,
                                                                nombre: NombreZona,
                                                                latitud: Latitud,
                                                                longitud: Longitud,
                                                                text: NombreZona,
                                                                leaf: true,
                                                                checked: false,
                                                                iconCls: 'icon_zona'
                                                            };
                                                        }

                                                        Ext.getCmp("treePanel").getStore().getRootNode().getChildAt(1).getChildAt(i).appendChild(childZona);

                                                        countZonas = countZonas + 1;
                                                    }

                                                    storeTreePanel.getRootNode().getChildAt(1).getChildAt(i).data.text = NombreTipoZona + ' (' + countZonas + ')';

                                                }

                                            }

                                            storeMoviles.load({
                                                params: {
                                                    patente: 'Todas',
                                                    transportista: transportista,
                                                    estadoViaje: 'Todos',
                                                    estadoGPS: 'Todos',
                                                    proveedorGPS: 'Todos'
                                                },
                                                callback: function (r, options, success) {
                                                    if (success) {

                                                        storeTreePanel.getRootNode().getChildAt(2).data.text = 'Móviles (' + storeMoviles.count() + ')';

                                                        var countEnViaje = 0;
                                                        var countLiberados = 0;

                                                        for (var i = 0; i < storeMoviles.count() ; i++) {
                                                            var childMovil;
                                                            var patente = storeMoviles.getAt(i).data.Patente;
                                                            var direccion = storeMoviles.getAt(i).data.Direccion;
                                                            var latitud = storeMoviles.getAt(i).data.Latitud;
                                                            var longitud = storeMoviles.getAt(i).data.Longitud;
                                                            var estadoViaje = storeMoviles.getAt(i).data.EstadoViaje;
                                                            var _fecha = storeMoviles.getAt(i).data.UltReporte;
                                                            var _estadoGps = storeMoviles.getAt(i).data.EstadoGPS;
                                                            var _velocidad = storeMoviles.getAt(i).data.Velocidad;
                                                            var _transportista = storeMoviles.getAt(i).data.Transportista;

                                                            if (estadoViaje != 'Liberado') {
                                                                childMovil = {
                                                                    tipo: 'Movil',
                                                                    patente: patente,
                                                                    direccion: direccion,
                                                                    latitud: latitud,
                                                                    longitud: longitud,
                                                                    estado: estadoViaje,
                                                                    fecha: _fecha,
                                                                    estadoGps: _estadoGps,
                                                                    velocidad: _velocidad,
                                                                    transportista:_transportista,
                                                                    text: patente,
                                                                    leaf: true,
                                                                    checked: true,
                                                                    iconCls: 'icon_truck_loaded'
                                                                };

                                                                storeTreePanel.getRootNode().getChildAt(2).getChildAt(0).appendChild(childMovil);
                                                                DrawMovil(patente, direccion, latitud, longitud, estadoViaje, _fecha, _estadoGps, _velocidad, _transportista);

                                                                countEnViaje = countEnViaje + 1;
                                                            }
                                                            else {
                                                                childMovil = {
                                                                    tipo: 'Movil',
                                                                    patente: patente,
                                                                    direccion: direccion,
                                                                    latitud: latitud,
                                                                    longitud: longitud,
                                                                    estado: estadoViaje,
                                                                    fecha: _fecha,
                                                                    estadoGps: _estadoGps,
                                                                    velocidad: _velocidad,
                                                                    transportista:_transportista,
                                                                    text: patente,
                                                                    leaf: true,
                                                                    checked: false,
                                                                    iconCls: 'icon_truck_unloaded'
                                                                };

                                                                storeTreePanel.getRootNode().getChildAt(2).getChildAt(1).appendChild(childMovil);
                                                                //DrawMovil(patente, direccion, latitud, longitud, estadoViaje);

                                                                countLiberados = countLiberados + 1;
                                                            }

                                                            storeTreePanel.getRootNode().getChildAt(2).getChildAt(0).data.text = 'En Viaje (' + countEnViaje + ')';
                                                            storeTreePanel.getRootNode().getChildAt(2).getChildAt(1).data.text = 'Liberados (' + countLiberados + ')';

                                                        }

                                                        Ext.Ajax.request({
                                                            url: 'AjaxPages/AjaxFunctions.aspx?Metodo=ProgressBarCall',
                                                            success: function (response, opts) {

                                                                var task = new Ext.util.DelayedTask(function () {
                                                                    Ext.Msg.hide();
                                                                });

                                                                task.delay(1300);

                                                            },
                                                            failure: function (response, opts) {
                                                                Ext.Msg.hide();
                                                            }
                                                        });

                                                    }
                                                }
                                            });

                                        }
                                    }
                                });

                            }
                        });

                    }
                }
            });

            var toolbarVisualizador = Ext.create('Ext.toolbar.Toolbar', {
                id: 'toolbarVisualizador',
                height: 40,
                layout: 'column',
                items: [{
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [comboFiltroComunaMapa]
                }]
            });

            var chkMostrarLabels = new Ext.form.Checkbox({
                id: 'chkMostrarLabels',
                fieldLabel: 'Mostrar Etiquetas',
                labelWidth: 110,
                listeners: {
                    change: function (cb, checked) {
                        if (checked == true) {
                            for (var i = 0; i < movilLabels.length; i++) {
                                movilLabels[i].setMap(map);
                            }
                            for (var i = 0; i < zoneLabels.length; i++) {
                                zoneLabels[i].setMap(map);
                            }
                        }
                        else {
                            for (var i = 0; i < movilLabels.length; i++) {
                                movilLabels[i].setMap(null);
                            }
                            for (var i = 0; i < zoneLabels.length; i++) {
                                zoneLabels[i].setMap(null);
                            }
                        }
                    }
                }
            });

            var treePanel = Ext.create('Ext.tree.Panel', {
                id: 'treePanel',
                title: 'Visualizador temático',
                anchor: '100% 100%',
                store: storeTreePanel,
                lines: true,
                rootVisible: false,
                tbar: toolbarVisualizador,
                buttons: [chkMostrarLabels],
                viewConfig: {
                    style: { overflow: 'auto' }
                },
                listeners: {
                    checkchange: function (node, checked) {
                        node.cascadeBy(function (child) {
                            child.set('checked', checked);
                        });

                        if (!node.isLeaf()) {

                            if (checked) {

                                Ext.Msg.wait('Espere por favor...', 'Generando');

                                for (var i = 0; i < node.childNodes.length; i++) {
                                    if (node.getChildAt(i).isLeaf()) {
                                        switch (node.getChildAt(i).data.tipo) {
                                            case 'Ruta':
                                                GetRoute(node.getChildAt(i).data.idRuta, false);
                                                break;
                                            case 'Zona':
                                                DrawZone(node.getChildAt(i).data.idZona, node.getChildAt(i).data.idTipoZona);
                                                break;
                                            case 'Movil':
                                                DrawMovil(node.getChildAt(i).data.patente, node.getChildAt(i).data.direccion, node.getChildAt(i).data.latitud, node.getChildAt(i).data.longitud, node.getChildAt(i).data.estado, node.getChildAt(i).data.fecha, node.getChildAt(i).data.estadoGps, node.getChildAt(i).data.velocidad, node.getChildAt(i).data.transportista);
                                                break;
                                        }
                                    }
                                    else {
                                        for (var j = 0; j < node.getChildAt(i).childNodes.length; j++) {
                                            if (node.getChildAt(i).getChildAt(j).isLeaf()) {
                                                switch (node.getChildAt(i).getChildAt(j).data.tipo) {
                                                    case 'Ruta':
                                                        GetRoute(node.getChildAt(i).getChildAt(j).data.idRuta, false);
                                                        break;
                                                    case 'Zona':
                                                        DrawZone(node.getChildAt(i).getChildAt(j).data.idZona, node.getChildAt(i).getChildAt(j).data.idTipoZona);
                                                        break;
                                                    case 'Movil':
                                                        DrawMovil(node.getChildAt(i).getChildAt(j).data.patente, node.getChildAt(i).getChildAt(j).data.direccion, node.getChildAt(i).getChildAt(j).data.latitud, node.getChildAt(i).getChildAt(j).data.longitud, node.getChildAt(i).getChildAt(j).data.estado, node.getChildAt(i).data.fecha, node.getChildAt(i).data.estadoGps, node.getChildAt(i).data.velocidad, node.getChildAt(i).data.transportista);
                                                        break;
                                                }
                                            }
                                        }
                                    }

                                }

                                //markerClusterer = new MarkerClusterer(map, markersMovil);

                                Ext.Ajax.request({
                                    url: 'AjaxPages/AjaxFunctions.aspx?Metodo=ProgressBarCall',
                                    success: function (response, opts) {

                                        var task = new Ext.util.DelayedTask(function () {
                                            Ext.Msg.hide();
                                        });

                                        task.delay(1100);

                                    },
                                    failure: function (response, opts) {
                                        Ext.Msg.hide();
                                    }
                                });

                            }
                            else {
                                for (var i = 0; i < node.childNodes.length; i++) {
                                    if (node.getChildAt(i).isLeaf()) {
                                        switch (node.getChildAt(i).data.tipo) {
                                            case 'Ruta':
                                                EraseRoute(node.getChildAt(i).data.idRuta, node.getChildAt(i).data.idOrigen, node.getChildAt(i).data.idDestino);
                                                break;
                                            case 'Zona':
                                                EraseZone(node.getChildAt(i).data.idZona);
                                                break;
                                            case 'Movil':
                                                EraseMovil(node.getChildAt(i).data.patente)
                                                break;
                                        }
                                    }
                                    else {
                                        for (var j = 0; j < node.getChildAt(i).childNodes.length; j++) {
                                            if (node.getChildAt(i).getChildAt(j).isLeaf()) {
                                                switch (node.getChildAt(i).getChildAt(j).data.tipo) {
                                                    case 'Ruta':
                                                        EraseRoute(node.getChildAt(i).getChildAt(j).data.idRuta, node.getChildAt(i).getChildAt(j).data.idOrigen, node.getChildAt(i).getChildAt(j).data.idDestino);
                                                        break;
                                                    case 'Zona':
                                                        EraseZone(node.getChildAt(i).getChildAt(j).data.idZona);
                                                        break;
                                                    case 'Movil':
                                                        EraseMovil(node.getChildAt(i).getChildAt(j).data.patente);
                                                        break;
                                                }
                                            }

                                        }
                                        //markerClusterer.removeMarkers(markersMovil);
                                    }

                                }
                            }
                        }

                        else {
                            if (checked) {
                                switch (node.data.tipo) {
                                    case 'Ruta':
                                        GetRoute(node.data.idRuta, true);
                                        break;
                                    case 'Zona':
                                        DrawZone(node.data.idZona, node.data.idTipoZona);
                                        map.setCenter(new google.maps.LatLng(node.data.latitud, node.data.longitud));
                                        break;
                                    case 'Movil':
                                        DrawMovil(node.data.patente, node.data.direccion, node.data.latitud, node.data.longitud, node.data.estado, node.data.fecha, node.data.estadoGps, node.data.velocidad, node.data.transportista);
                                        map.setCenter(new google.maps.LatLng(node.data.latitud, node.data.longitud));
                                        break;
                                }
                            }
                            else {
                                switch (node.data.tipo) {
                                    case 'Ruta':
                                        EraseRoute(node.data.idRuta, node.data.idOrigen, node.data.idDestino);
                                        break;
                                    case 'Zona':
                                        EraseZone(node.data.idZona);
                                        break;
                                    case 'Movil':
                                        EraseMovil(node.data.patente)
                                        break;
                                }
                            }
                        }

                    }
                }
            });

            var leftPanel = new Ext.FormPanel({
                id: 'leftPanel',
                region: 'west',
                margins: '0 0 3 3',
                border: true,
                width: 350,
                minWidth: 250,
                maxWidth: 500,
                layout: 'anchor',
                split: true,
                collapsible: true,
                collapsed: false,
                items: [treePanel]
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

        var movilLabels = new Array();
        var zoneLabels = new Array();

        Ext.onReady(function () {
            GeneraMapa("dvMap", true);
            map.setZoom(9);
        });

        function FiltrarComunaMapa() {
            var Id = Ext.getCmp('comboFiltroComunaMapa').getValue();

            var lat = Ext.getCmp('comboFiltroComunaMapa').store.getAt(Id).data.Latitud;
            var lon = Ext.getCmp('comboFiltroComunaMapa').store.getAt(Id).data.Longitud;

            map.setCenter(new google.maps.LatLng(lat, lon));
            map.setZoom(15);

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


                            zoneLabels.push(polygonGrid.label);

                        }

                    }
                },
                failure: function (msg) {
                    alert('Se ha producido un error.');
                }
            });
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

        function DrawMovil(patente, direccion, latitud, longitud, estadoViaje, fecha, estadoGps, velocidad, transportista) {

            if (containsMovil(movilLayer, patente) == true) {
                return;
            }

            var dir = parseInt(direccion);
            var Latlng = new google.maps.LatLng(latitud, longitud);

            var movilGrid = new Object();
            movilGrid.Patente = patente;

            var iconRoute;

            if (estadoViaje == 'Liberado') {
                iconRoute = 'Images/Truck_Empty/';
            }
            else {
                iconRoute = 'Images/Truck_Loaded/'
            }

            switch (true) {
                case ((dir >= 338) || (dir < 22)):
                    movilGrid.layer = new google.maps.Marker({
                        patente: patente,
                        position: Latlng,
                        icon: iconRoute + '1_N_21x29.png',
                        map: map,
                        labelText: patente
                    });
                    break;
                case ((dir >= 22) && (dir < 67)):
                    movilGrid.layer = new google.maps.Marker({
                        patente: patente,
                        position: Latlng,
                        icon: iconRoute + '2_NE_32x30.png',
                        map: map,
                        labelText: patente
                    });
                    break;
                case ((dir >= 67) && (dir < 112)):
                    movilGrid.layer = new google.maps.Marker({
                        patente: patente,
                        position: Latlng,
                        icon: iconRoute + '3_E_30x22.png',
                        map: map,
                        labelText: patente
                    });
                    break;
                case ((dir >= 112) && (dir < 157)):
                    movilGrid.layer = new google.maps.Marker({
                        patente: patente,
                        position: Latlng,
                        icon: iconRoute + '4_SE_30x32.png',
                        map: map,
                        labelText: patente
                    });
                    break;
                case ((dir >= 157) && (dir < 202)):
                    movilGrid.layer = new google.maps.Marker({
                        patente: patente,
                        position: Latlng,
                        icon: iconRoute + '5_S_21x29.png',
                        map: map,
                        labelText: patente
                    });
                    break;
                case ((dir >= 202) && (dir < 247)):
                    movilGrid.layer = new google.maps.Marker({
                        patente: patente,
                        position: Latlng,
                        icon: iconRoute + '6_SW_30x32.png',
                        map: map,
                        labelText: patente
                    });
                    break;
                case ((dir >= 247) && (dir < 292)):
                    movilGrid.layer = new google.maps.Marker({
                        patente: patente,
                        position: Latlng,
                        icon: iconRoute + '7_W_30x22.png',
                        map: map,
                        labelText: patente
                    });
                    break;
                case ((dir >= 292) && (dir < 338)):
                    movilGrid.layer = new google.maps.Marker({
                        patente: patente,
                        position: Latlng,
                        icon: iconRoute + '8_NW_32x30.png',
                        map: map,
                        labelText: patente
                    });
                    break;
            }



            var viewLabel = Ext.getCmp('chkMostrarLabels').getValue();
            movilGrid.label = new Label({
                text: patente,
                position: new google.maps.LatLng(latitud, longitud),
                map: viewLabel ? map : null
            });

            movilGrid.label.bindTo('text', movilGrid.layer, 'labelText');

            movilLabels.push(movilGrid.label);
            movilLayer.push(movilGrid);

            google.maps.event.addListener(movilLayer[movilLayer.length - 1].layer, 'click', function () {
 
                var contentString =
                      '<br>' +
                          '<table>' +                            
                            '<tr>' +
                                '       <td><b>Patente</b></td>' +
                                '       <td><pre>     </pre></td>' +
                                '       <td>' + patente + '</td>' +
                            '</tr>' +
                            '<tr>' +
                                '        <td><b>Fecha Ult. Reporte:</b></td>' +
                                '       <td><pre>     </pre></td>' +
                                '        <td>' + fecha.toString().replace("T", " ") + '</td>' +
                            '</tr>' +
                            '<tr>' +
                                '        <td><b>Estado GPS:</b></td>' +
                                '       <td><pre>     </pre></td>' +
                                '        <td>' + estadoGps + ' </td>' +
                            '</tr>' +
                            '<tr>' +
                                '        <td><b>Velocidad:</b></td>' +
                                '       <td><pre>     </pre></td>' +
                                '        <td>' + velocidad + ' Km/h </td>' +
                            '</tr>' +
                            '<tr>' +
                                '        <td><b>Transportista:</b></td>' +
                                '       <td><pre>     </pre></td>' +
                                '        <td>' + transportista + '</td>' +
                            '</tr>' +

                          '</table>' +
                        '<br>';

                infowindow.setContent(contentString);
                infowindow.open(map, this);
            });


        }

        function EraseMovil(patente) {
            for (var i = 0; i < movilLayer.length; i++) {
                if (patente == movilLayer[i].Patente) {
                    movilLayer[i].layer.setMap(null);
                    movilLayer[i].label.setMap(null);
                    movilLayer.splice(i, 1);
                    break;
                }
            }

            for (var i = 0; i < movilLabels.length; i++) {
                if (movilLabels[i].text == patente) {
                    movilLabels[i].setMap(null);
                    movilLabels.splice(i, 1);
                    break;
                }
            }
            /*
            for (var i = 0; i < markersMovil.length; i++) {
              if (markersMovil[i].patente == patente) {
                    markerClusterer.removeMarker(markersMovil[i]);
                    markersMovil.splice(i, 1);
                    break;
              }
            }
           */
        }

        function GetRoute(IdRuta, centerMap) {

            Ext.Ajax.request({
                url: 'AjaxPages/AjaxRutas.aspx?Metodo=GetPuntosRuta',
                params: {
                    IdRuta: IdRuta
                },
                success: function (data, success) {
                    if (data != null) {
                        data = Ext.decode(data.responseText);
                        DrawRoute(data, centerMap);
                    }
                },
                failure: function (msg) {
                    alert('Se ha producido un error.');
                }
            });
        }

        function DrawRoute(data, centerMap) {

            if (containsRoute(routeLayer, data.IdRuta) == true) {
                return;
            }

            //if (poly) { poly.setMap(null); }
            points.length = 0;

            var startPoint = new google.maps.LatLng(data.Puntos[0].Latitud, data.Puntos[0].Longitud);
            var endPoint = new google.maps.LatLng(data.Puntos[data.Puntos.length - 1].Latitud, data.Puntos[data.Puntos.length - 1].Longitud);

            for (i = 0; i < data.Puntos.length; i++) {
                lat = data.Puntos[i].Latitud;
                lon = data.Puntos[i].Longitud;
                point = new google.maps.LatLng(lat, lon);
                points.push(point);

            }

            var routeGrid = new Object();
            routeGrid.IdRuta = data.IdRuta;

            routeGrid.layer = new google.maps.Polyline({
                path: points,
                strokeColor: "#2492C9",
                strokeWeight: 7,
                strokeOpacity: 0.7,
                labelText: data.IdRuta
            });

            //routeGrid.label.bindTo('text', routeGrid.layer, 'labelText');
            routeGrid.layer.setMap(map);

            routeLayer.push(routeGrid);

            if (centerMap == true) {
                map.setCenter(startPoint);
            }
            DrawZone(data.IdDestino, 2);
            DrawZone(data.IdOrigen, 1);

            // Marcador Inicio Ruta
            var startMarker = new google.maps.Marker({
                idOrigen: data.IdOrigen,
                idDestino: data.IdDestino,
                position: startPoint,
                map: map,
                icon: new google.maps.MarkerImage("Images/marker_green_32x32.png"),
                //animation: google.maps.Animation.DROP
            });
            markersRoute.push(startMarker);

            // Marcador Fin Ruta
            var endMarker = new google.maps.Marker({
                idOrigen: data.IdOrigen,
                idDestino: data.IdDestino,
                position: endPoint,
                map: map,
                icon: new google.maps.MarkerImage("Images/marker_blue_32x32.png")
                //animation: google.maps.Animation.DROP
            });
            markersRoute.push(endMarker);

        }

        function EraseRoute(idRuta, idOrigen, idDestino) {
            for (var i = 0; i < routeLayer.length; i++) {
                if (idRuta == routeLayer[i].IdRuta) {
                    routeLayer[i].layer.setMap(null);
                    routeLayer.splice(i, 1);
                    break;
                }
            }

            //Necesario hacer el ciclo desde el final pues se elimina más de un marker
            for (var i = markersRoute.length - 1; i >= 0; i--) {
                if (idOrigen == markersRoute[i].idOrigen && idDestino == markersRoute[i].idDestino) {
                    markersRoute[i].setMap(null);
                    markersRoute.splice(i, 1);
                }
            }

        }

        (function () {
            google.maps.Map.prototype.clearLabels = function () {
                for (var i = 0; i < movilLabels.length; i++) {
                    if (movilLabels[i] != null) {
                        movilLabels[i].setMap(null);
                    }
                }

                for (var i = 0; i < zoneLabels.length; i++) {
                    if (zoneLabels[i] != null) {
                        zoneLabels[i].setMap(null);
                    }
                }
            };
        })();

        function ClearLabels() {
            map.clearLabels();
        }

        function containsMovil(a, obj) {
            var i = a.length;
            while (i--) {
                if (a[i].Patente === obj) {
                    return true;
                }
            }
            return false;
        }

        function containsRoute(a, obj) {
            var i = a.length;
            while (i--) {
                if (a[i].IdRuta === obj) {
                    return true;
                }
            }
            return false;
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

    </script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
    <div id="dvMap"></div>
</asp:Content>

