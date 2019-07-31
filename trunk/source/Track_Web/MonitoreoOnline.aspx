<%@  Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MonitoreoOnline.aspx.cs" Inherits="Track_Web.MonitoreoOnline" %>
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
        var infowindow = new google.maps.InfoWindow();
        //var markerCluster;
        var directionsService = new google.maps.DirectionsService;
        var directionsDisplay = new google.maps.DirectionsRenderer;

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

            var storeZonasCD = new Ext.data.JsonStore({
                id: 'storeZonasCD',
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

            var gridZonasCD = Ext.create('Ext.grid.Panel', {
                id: 'gridZonasCD',
                store: storeZonasCD,
                columns: [
                          { text: 'IdZona', flex: 1, dataIndex: 'IdZona' }
                ]

            });

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

            var gridZonasRiesgo = Ext.create('Ext.grid.Panel', {
                id: 'gridZonasRiesgo',
                store: storeZonasRiesgo,
                columns: [
                          { text: 'IdZona', flex: 1, dataIndex: 'IdZona' }
                ]

            });

            var storeZonasPredio = new Ext.data.JsonStore({
                id: 'storeZonasPredio',
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

            var gridZonasPredio = Ext.create('Ext.grid.Panel', {
                id: 'gridZonasPredio',
                store: storeZonasPredio,
                columns: [
                          { text: 'IdZona', flex: 1, dataIndex: 'IdZona' }
                ]

            });

            storeZonasCD.load({
                params: {
                    idTipoZona: 1,
                    nombreZona: ''
                }, callback: function (r, options, success) {
                    if (success) {
                        var storeZonasC = Ext.getCmp('gridZonasCD').getStore();
                        for (var i = 0; i < storeZonasC.count() ; i++) {
                            DrawZone(storeZonasC.getAt(i).data.IdZona);
                        }
                    }
                }

            });

            storeZonasRiesgo.load({
                params: {
                    idTipoZona: 3,
                    nombreZona: ''
                }, callback: function (r, options, success) {
                    if (success) {
                        var storeZonasR = Ext.getCmp('gridZonasRiesgo').getStore();
                        for (var i = 0; i < storeZonasR.count() ; i++) {
                            DrawZone(storeZonasR.getAt(i).data.IdZona);
                        }
                    }
                }
            });

            storeZonasPredio.load({
                params: {
                    idTipoZona: 5,
                    nombreZona: ''
                }, callback: function (r, options, success) {
                    if (success) {
                        var storeZonasP = Ext.getCmp('gridZonasPredio').getStore();
                        for (var i = 0; i < storeZonasP.count() ; i++) {
                            DrawZone(storeZonasP.getAt(i).data.IdZona);
                        }
                    }
                }
            });

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

            //Ext.getCmp('comboFiltroComunaMapa').setValue('0');

            var chkNroTransporte = new Ext.form.Checkbox({
                id: 'chkNroTransporte',
                labelSeparator: '',
                hideLabel: true,
                checked: false,
                style: {
                    marginTop: '7px',
                    marginLeft: '5px'
                },
                listeners: {
                    change: function (cb, checked) {
                        if (checked == true) {
                            Ext.getCmp("textFiltroNroTransporte").setDisabled(false);
                            Ext.getCmp("textFiltroOrdenServicio").setDisabled(false);
                            
                            Ext.getCmp("comboFiltroTipoEtis").setDisabled(true);
                            Ext.getCmp("comboFiltroEstadoViaje").setDisabled(true);
                            Ext.getCmp("comboFiltroEstadoGPS").setDisabled(true);
                            Ext.getCmp("comboFiltroTransportista").setDisabled(true);
                            Ext.getCmp("comboFiltroProveedorGPS").setDisabled(true);
                            Ext.getCmp("comboFiltroPatente").setDisabled(true);
                            Ext.getCmp("comboFiltroClientes").setDisabled(true);

                            Ext.getCmp("comboFiltroViajeFragil").setDisabled(true);
                        }
                        else {
                            Ext.getCmp("textFiltroNroTransporte").setDisabled(true);
                            Ext.getCmp("textFiltroOrdenServicio").setDisabled(true);
                            Ext.getCmp("comboFiltroTipoEtis").setDisabled(false);
                            Ext.getCmp("comboFiltroEstadoViaje").setDisabled(false);
                            Ext.getCmp("comboFiltroEstadoGPS").setDisabled(false);
                            Ext.getCmp("comboFiltroTransportista").setDisabled(false);
                            Ext.getCmp("comboFiltroProveedorGPS").setDisabled(false);
                            Ext.getCmp("comboFiltroPatente").setDisabled(false);
                            Ext.getCmp("comboFiltroClientes").setDisabled(false);

                            Ext.getCmp("comboFiltroViajeFragil").setDisabled(false);

                            Ext.getCmp('textFiltroNroTransporte').reset();

                        }
                    }
                }
            });

            var textFiltroOrdenServicio = new Ext.form.TextField({
                id: 'textFiltroOrdenServicio',
                fieldLabel: 'OS',
                labelWidth: 110,
                allowBlank: true,
                anchor: '99%',
                maxLength: 20,
                style: {
                    marginTop: '5px',
                    marginLeft: '5px'
                },
                disabled: false 

            });

            var textFiltroNroTransporte = new Ext.form.TextField({
                id: 'textFiltroNroTransporte',
                fieldLabel: 'Guía Despacho',
                labelWidth: 80,
                allowBlank: true,
                anchor: '99%',
                maxLength: 20,
                style: {
                    marginTop: '5px',
                    marginLeft: '5px'
                },
                disabled: true

            });

            var storeFiltroTipoEtis = new Ext.data.JsonStore({
                autoLoad: true,
                fields: ['ETIS'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetTipoEtis&Todos=True',
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var comboFiltroTipoEtis = new Ext.form.field.ComboBox({
                id: 'comboFiltroTipoEtis',
                fieldLabel: 'ETIS',
                labelWidth: 110,
                forceSelection: true,
                store: storeFiltroTipoEtis,
                valueField: 'ETIS',
                displayField: 'ETIS',
                queryMode: 'local',
                anchor: '99%',
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                editable: false,
                forceSelection: true,
                style: {
                    marginTop: '5px',
                    marginLeft: '5px'
                },
                disabled: false
            });

            var storeFiltroClientes = new Ext.data.JsonStore({
                fields: ['RutCliente', 'NombreCliente'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetClientes&Todos=True',
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var comboFiltroClientes = new Ext.form.field.ComboBox({
                id: 'comboFiltroClientes',
                fieldLabel: 'Cliente',
                forceSelection: true,
                store: storeFiltroClientes,
                valueField: 'RutCliente',
                displayField: 'NombreCliente',
                queryMode: 'local',
                anchor: '99%',
                labelWidth: 110,
                style: {
                    marginLeft: '5px'
                },
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                editable: true,
                forceSelection: true
            });



            var storeFiltroEstadoViaje = new Ext.data.JsonStore({
                fields: ['EstadoViaje'],
                data: [{ "EstadoViaje": "Todos" },
                        { "EstadoViaje": "En Viaje" },
                        { "EstadoViaje": "Liberado" }
                ]
            });

            var comboFiltroEstadoViaje = new Ext.form.field.ComboBox({
                id: 'comboFiltroEstadoViaje',
                fieldLabel: 'Estado Viaje',
                store: storeFiltroEstadoViaje,
                valueField: 'EstadoViaje',
                displayField: 'EstadoViaje',
                queryMode: 'local',
                anchor: '99%',
                labelWidth: 110,
                editable: false,
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

            Ext.getCmp('comboFiltroEstadoViaje').setValue('En Viaje');

            var storeFiltroViajeFragil = new Ext.data.JsonStore({
                fields: ['ViajeFragil'],
                data: [{ "ViajeFragil": "Todos" },
                        { "ViajeFragil": "Viajes frágiles" },
                   //     { "ViajeFragil": "Sin Viajes Fragiles" }
                ]
            });

            var comboFiltroViajeFragil = new Ext.form.field.ComboBox({
                id: 'comboFiltroViajeFragil',
                fieldLabel: 'Viaje Fragil',
                store: storeFiltroViajeFragil,
                valueField: 'ViajeFragil',
                displayField: 'ViajeFragil',
                queryMode: 'local',
                anchor: '99%',
                labelWidth: 110,
                editable: false,
                style: {
                    marginLeft: '5px'
                },
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                forceSelection: true,
                listeners: {
                    select: function () {
                        
                    }
                }
            });

            Ext.getCmp('comboFiltroViajeFragil').setValue('Todos');

            var storeFiltroTransportista = new Ext.data.JsonStore({
                fields: ['Transportista'],
                proxy: new Ext.data.HttpProxy({
                    //url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetTransportistasRuta&Todos=True',
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
                queryMode: 'local',
                anchor: '99%',
                labelWidth: 110,
                style: {
                    marginLeft: '5px'
                },
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                editable: true,
                forceSelection: true,
                listeners: {
                    select: function () {
                        FiltrarPatentes();
                        FiltrarProveedoresGPS();
                        //FiltrarFlota();
                    }
                }
            });

            var storeFiltroPatente = new Ext.data.JsonStore({
                fields: ['Patente'],
                proxy: new Ext.data.HttpProxy({
                    //url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetPatentesRuta&Todos=True',
                    url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetAllPatentes&Todas=True',
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var comboFiltroPatente = new Ext.form.field.ComboBox({
                id: 'comboFiltroPatente',
                fieldLabel: 'Patente',
                labelWidth: 110,
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
                },
                listeners: {
                    select: function () {
                        //FiltrarFlota();
                    }
                }
            });

            var storeFiltroEstadoGPS = new Ext.data.JsonStore({
                fields: ['EstadoGPS'],
                data: [{ "EstadoGPS": "Todos" },
                        { "EstadoGPS": "Online" },
                        { "EstadoGPS": "Offline" }
                ]
            });

            var comboFiltroEstadoGPS = new Ext.form.field.ComboBox({
                id: 'comboFiltroEstadoGPS',
                fieldLabel: 'Estado GPS',
                store: storeFiltroEstadoGPS,
                valueField: 'EstadoGPS',
                displayField: 'EstadoGPS',
                queryMode: 'local',
                anchor: '99%',
                labelWidth: 110,
                editable: false,
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

            Ext.getCmp('comboFiltroEstadoGPS').setValue('Todos');

            var storeFiltroProveedorGPS = new Ext.data.JsonStore({
                fields: ['ProveedorGPS'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetProveedoresGPS&Todos=True',
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
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
                labelWidth: 110,
                style: {
                    marginLeft: '5px'
                },
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                editable: true,
                forceSelection: true,
                listeners: {
                    select: function () {
                        //FiltrarFlota();
                    }
                }
            });

            storeFiltroProveedorGPS.load({
                callback: function (r, options, success) {
                    if (success) {
                        FiltrarProveedoresGPS();
                        Ext.getCmp("comboFiltroProveedorGPS").setValue("Todos");
                    }
                }
            })

            storeFiltroTransportista.load({
                callback: function (r, options, success) {
                    if (success) {
                        //Ext.getCmp("comboFiltroTransportista").store.insert(0, { Transportista: "Todos" });
                        var firstTransportista = Ext.getCmp("comboFiltroTransportista").store.getAt(0).get("Transportista");
                        Ext.getCmp("comboFiltroTransportista").setValue(firstTransportista);

                        //Ext.getCmp("comboFiltroTransportista").setValue("Todos");

                        storeFiltroTipoEtis.load({
                            callback: function (r, options, success) {
                                if (success) {
                                    Ext.getCmp("comboFiltroTipoEtis").setValue("Todas");

                                }
                            }
                        })

                        storeFiltroClientes.load({
                            callback: function (r, options, success) {
                                if (success) {
                                    Ext.getCmp("comboFiltroClientes").setValue("Todos");

                                }
                            }
                        })

                        storeFiltroProveedorGPS.load({
                            params: {
                                Transportista: firstTransportista
                            },
                            callback: function (r, options, success) {
                                if (success) {
                                    Ext.getCmp("comboFiltroProveedorGPS").setValue("Todos");
                                }
                            }
                        })

                        storeFiltroPatente.load({
                            callback: function (r, options, success) {
                                if (success) {
                                    //Ext.getCmp("comboFiltroPatente").store.insert(0, { Patente: "Todas" });
                                    Ext.getCmp("comboFiltroPatente").setValue("Todas");
                                    FiltrarPatentes();
                                    FiltrarFlota();
                                }
                            }
                        })

                    }
                }
            })

            var chkMostrarTrafico = new Ext.form.Checkbox({
                id: 'chkMostrarTrafico',
                fieldLabel: 'Mostrar tráfico',
                labelWidth: 90,
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

            var btnActualizar = {
                id: 'btnActualizar',
                xtype: 'button',
                iconAlign: 'left',
                icon: 'Images/refresh_gray_20x20.png',
                text: 'Actualizar',
                width: 80,
                height: 26,
                handler: function () {
                    FiltrarFlota();
                }
            };

            var btnExportar = {
                id: 'btnExportar',
                xtype: 'button',
                iconAlign: 'left',
                icon: 'Images/export_black_20x20.png',
                text: 'Exportar',
                width: 80,
                height: 26,
                style: {
                    marginLeft: '20px'
                },
                listeners: {
                    click: {
                        element: 'el',
                        fn: function () {

                            var nroTransporte = Ext.getCmp('textFiltroNroTransporte').getValue();
                            var nroOS = Ext.getCmp('textFiltroOrdenServicio').getValue();
                            
                            var tipoEtis = Ext.getCmp('comboFiltroTipoEtis').getValue();
                            var estadoViaje = Ext.getCmp('comboFiltroEstadoViaje').getValue();
                            var estadoGPS = Ext.getCmp('comboFiltroEstadoGPS').getValue();
                            var transportista = Ext.getCmp('comboFiltroTransportista').getValue();
                            var proveedorGPS = Ext.getCmp('comboFiltroProveedorGPS').getValue();
                            var patente = Ext.getCmp('comboFiltroPatente').getValue();
                            var cliente = Ext.getCmp('comboFiltroClientes').getValue();

                        //    var ViajeFragil = Ext.getCmp('comboFiltroViajeFragil').getValue();

                            var mapForm = document.createElement("form");
                            mapForm.target = "ToExcel";
                            mapForm.method = "POST"; // or "post" if appropriate
                            mapForm.action = 'MonitoreoOnline.aspx?Metodo=ExportExcel';

                            //

                            var _nroTransporte = document.createElement("input");
                            _nroTransporte.type = "text";
                            _nroTransporte.name = "nroTransporte";
                            _nroTransporte.value = nroTransporte;
                            mapForm.appendChild(_nroTransporte);

                            var _nroOS = document.createElement("input");
                            _nroOS.type = "text";
                            _nroOS.name = "nroOS";
                            _nroOS.value = nroOS;
                            mapForm.appendChild(_nroOS);

                            var _tipoEtis = document.createElement("input");
                            _tipoEtis.type = "text";
                            _tipoEtis.name = "tipoEtis";
                            _tipoEtis.value = tipoEtis;
                            mapForm.appendChild(_tipoEtis);

                            var _estadoViaje = document.createElement("input");
                            _estadoViaje.type = "text";
                            _estadoViaje.name = "estadoViaje";
                            _estadoViaje.value = estadoViaje;
                            mapForm.appendChild(_estadoViaje);

                            var _estadoGPS = document.createElement("input");
                            _estadoGPS.type = "text";
                            _estadoGPS.name = "estadoGPS";
                            _estadoGPS.value = estadoGPS;
                            mapForm.appendChild(_estadoGPS);

                            var _transportista = document.createElement("input");
                            _transportista.type = "text";
                            _transportista.name = "transportista";
                            _transportista.value = transportista;
                            mapForm.appendChild(_transportista);

                            var _proveedorGPS = document.createElement("input");
                            _proveedorGPS.type = "text";
                            _proveedorGPS.name = "proveedorGPS";
                            _proveedorGPS.value = proveedorGPS;
                            mapForm.appendChild(_proveedorGPS);

                            var _patente = document.createElement("input");
                            _patente.type = "text";
                            _patente.name = "patente";
                            _patente.value = patente;
                            mapForm.appendChild(_patente);

                            var _cliente = document.createElement("input");
                            _cliente.type = "text";
                            _cliente.name = "cliente";
                            _cliente.value = cliente;
                            mapForm.appendChild(_cliente);

                            document.body.appendChild(mapForm);
                            mapForm.submit();

                        }
                    }
                }
            };

            var toolbarPosiciones = Ext.create('Ext.toolbar.Toolbar', {
                id: 'toolbarPosiciones',
                height: 143,
                layout: 'column',
                items: [{
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.05,
                    items: [chkNroTransporte]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.45,
                    items: [textFiltroNroTransporte]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.5,
                    items: [textFiltroOrdenServicio]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.5,
                    items: [comboFiltroEstadoViaje, comboFiltroTransportista, comboFiltroPatente, comboFiltroViajeFragil]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.5,
                    items: [comboFiltroEstadoGPS, comboFiltroProveedorGPS, comboFiltroClientes, comboFiltroTipoEtis]
                }



                /*, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.5,
                    items: [comboFiltroEstadoViaje, comboFiltroTransportista, comboFiltroPatente]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.5,
                    items: [comboFiltroEstadoGPS, comboFiltroProveedorGPS, comboFiltroClientes]
                }*/]
            });



            var storePosiciones = new Ext.data.JsonStore({
                autoLoad: false,
                fields: [{ name: 'UltReporte', type: 'date', dateFormat: 'c' },
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
                          'CodigoOrigen',
                          'LatitudOrigen',
                          'LongitudOrigen',
                          'CodigoDestino',
                          'LatitudDestino',
                          'LongitudDestino',
                          'ProveedorGPS',
                          'RutConductor',
                          'NombreConductor',
                          'TelefonoConductor',
                          'ETIS',
                          'RutCliente',
                          'FlagViajeFragil',
                          'NombreCliente'],
                groupField: 'EstadoViaje',
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetMonitoreoOnline',
                    reader: { type: 'json', root: 'Zonas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var groupingFeature = Ext.create('Ext.grid.feature.Grouping', {
                groupHeaderTpl: '{name} ({rows.length})'
            });

            var gridPosiciones = Ext.create('Ext.grid.Panel', {
                id: 'gridPosiciones',
                store: storePosiciones,
                tbar: toolbarPosiciones,
                columnLines: true,
                anchor: '100% 100%',
                scroll: false,
                features: [groupingFeature],
                buttons: [chkMostrarTrafico, btnExportar, btnActualizar],
                viewConfig: {
                    style: { overflow: 'auto', overflowX: 'hidden' }
                },
                columns: [
                              { text: 'Fecha', width: 105, dataIndex: 'UltReporte', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                              { text: 'Patente', width: 57, dataIndex: 'Patente' },
                              { text: 'Transportista', flex: 1, dataIndex: 'Transportista' },
                              { text: 'Proveedor', width: 70, dataIndex: 'ProveedorGPS' },
                              { text: 'Ignición', width: 55, dataIndex: 'Ignicion' },
                              { text: 'Vel.', width: 35, dataIndex: 'Velocidad' },
                              { text: 'Estado', flex: 1, dataIndex: 'EstadoViaje' },
                              { text: 'Guía', width: 60, dataIndex: 'NroTransporte' },
                              { text: 'GPS', width: 50, dataIndex: 'EstadoGPS', renderer: renderEstadoGPS },

                ],
                listeners: {
                    select: function (sm, row, rec) {

                        var latOrigen = Ext.getCmp('gridPosiciones').getStore().data.items[rec].raw.LatitudOrigen;
                        var lonOrigen = Ext.getCmp('gridPosiciones').getStore().data.items[rec].raw.LongitudOrigen;
                        var latDestino = Ext.getCmp('gridPosiciones').getStore().data.items[rec].raw.LatitudDestino;
                        var lonDestino = Ext.getCmp('gridPosiciones').getStore().data.items[rec].raw.LongitudDestino;

                        //var latlonOrigen = new google.maps.LatLng(latOrigen, lonOrigen);
                        //var latlonDestino = new google.maps.LatLng(latDestino, lonDestino);

                        //if (directionsDisplay) {
                        //    directionsDisplay.setMap(null);
                        //}

                        //directionsDisplay.setMap(map);

                        //var request = {
                        //    origin: latlonOrigen,
                        //    destination: latlonDestino,
                        //    travelMode: google.maps.TravelMode.DRIVING,
                        //    unitSystem: google.maps.UnitSystem.METRIC,
                        //    provideRouteAlternatives: false,
                        //    region: 'CL'
                        //};

                        //directionsService.route(request, function (response, status) {
                        //    if (status === google.maps.DirectionsStatus.OK) {
                        //        directionsDisplay.setOptions({ preserveViewport: true });
                        //        directionsDisplay.setDirections(response);
                        //    }
                        //});

                        var patFec = Ext.getCmp('gridPosiciones').getStore().data.items[rec].raw.Patente + Ext.getCmp('gridPosiciones').getStore().data.items[rec].raw.UltReporte.toString();

                        for (var i = 0; i < markers.length; i++) {
                            if (markers[i].labelText == patFec) {
                                markers[i].setAnimation(google.maps.Animation.BOUNCE);
                                setTimeout('markers[' + i + '].setAnimation(null);', 800);

                                var contentString =

                                    '<br>' +
                                        '<table>' +
                                          '<tr>' +
                                              '       <td><b>Fecha</b></td>' +
                                              '       <td><pre>     </pre></td>' +
                                              '       <td>' + row.data.TextUltReporte + '</td>' +
                                          '</tr>' +
                                          '<tr>' +
                                              '        <td><b>Patente:</b></td>' +
                                              '       <td><pre>     </pre></td>' +
                                              '        <td>' + row.data.Patente + '</td>' +
                                          '</tr>' +
                                          '<tr>' +
                                              '        <td><b>Velocidad:</b></td>' +
                                              '       <td><pre>     </pre></td>' +
                                              '        <td>' + row.data.Velocidad + ' Km/h </td>' +
                                          '</tr>' +
                                          '<tr>' +
                                              '        <td><b>Conductor:</b></td>' +
                                              '       <td><pre>     </pre></td>' +
                                              '        <td>' + row.data.NombreConductor + '</td>' +
                                          '</tr>' +
                                          '<tr>' +
                                              '        <td><b>Teléfono:</b></td>' +
                                              '       <td><pre>     </pre></td>' +
                                              '        <td>' + row.data.TelefonoConductor + '</td>' +
                                          '</tr>' +

                                        '</table>' +
                                      '<br>';

                                infowindow.setContent(contentString);
                                infowindow.open(map, markers[i]);

                                break;

                            }
                        }

                        if (row.data.NroTransporte > 0) {
                            FindPoints(row.data.NroTransporte);
                        }

                        map.setCenter(new google.maps.LatLng(row.data.Latitud, row.data.Longitud));
                        //map.setZoom(16);

                        Ext.getCmp("gridPosiciones").getSelectionModel().deselectAll();

                    }
                }
            });

            function FindPoints(pTransporte) {
                Ext.Ajax.request({
                    url: 'AjaxPages/AjaxRutas.aspx?Metodo=GetPointSafeRoute',
                    params: {
                        NroTranporte: pTransporte
                    },
                    success: function (data, success) {
                        if (data != null) {
                            data = Ext.decode(data.responseText);
                            DrawSafeRoute(data);
                        }
                    },
                    failure: function (msg) {
                        alert('Se ha producido un error.');
                    }
                });

            }

            function DrawSafeRoute(data) {

                //ClearMap();
                var storeRouteToDraw;

                var lineMode = false;

                if (poly) { poly.setMap(null); }
                points.length = 0;

                if (data.Puntos.length > 0) {

                    var startPoint = new google.maps.LatLng(data.Puntos[0].Latitud, data.Puntos[0].Longitud);
                    var endPoint = new google.maps.LatLng(data.Puntos[data.Puntos.length - 1].Latitud, data.Puntos[data.Puntos.length - 1].Longitud);

                    for (i = 0; i < data.Puntos.length; i++) {
                        lat = data.Puntos[i].Latitud;
                        lon = data.Puntos[i].Longitud;
                        point = new google.maps.LatLng(lat, lon);
                        points.push(point);

                    }

                    poly = new google.maps.Polyline({ path: points, strokeColor: "#6600FF", strokeWeight: 4, strokeOpacity: 0.7 });
                    poly.setMap(map);

                 //   map.setCenter(startPoint);

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


            var viewWidth = Ext.getBody().getViewSize().width;
            var viewHeight = Ext.getBody().getViewSize().height;

            var leftPanel = new Ext.FormPanel({
                id: 'leftPanel',
                region: 'west',
                margins: '0 0 3 3',
                border: true,
                width: 600,
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
            });

            var refreshPanel = function () {
                FiltrarFlota();
            };
            setInterval(refreshPanel, 120000); //120 seg


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

        function FiltrarComunaMapa() {
            var Id = Ext.getCmp('comboFiltroComunaMapa').getValue();

            var lat = Ext.getCmp('comboFiltroComunaMapa').store.getAt(Id).data.Latitud;
            var lon = Ext.getCmp('comboFiltroComunaMapa').store.getAt(Id).data.Longitud;

            map.setCenter(new google.maps.LatLng(lat, lon));
            map.setZoom(15);

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

        function FiltrarFlota() {
            //ClearMap();

            var nroTransporte = Ext.getCmp('textFiltroNroTransporte').getValue();
            var nroOS = Ext.getCmp('textFiltroOrdenServicio').getValue();
            
            var tipoEtis = Ext.getCmp('comboFiltroTipoEtis').getValue();
            var estadoViaje = Ext.getCmp('comboFiltroEstadoViaje').getValue();
            var estadoGPS = Ext.getCmp('comboFiltroEstadoGPS').getValue();
            var transportista = Ext.getCmp('comboFiltroTransportista').getValue();
            var proveedorGPS = Ext.getCmp('comboFiltroProveedorGPS').getValue();
            var patente = Ext.getCmp('comboFiltroPatente').getValue();
            var cliente = Ext.getCmp('comboFiltroClientes').getValue();

            var viajeFragil = Ext.getCmp('comboFiltroViajeFragil').getValue();

            var store = Ext.getCmp('gridPosiciones').store;
            store.load({
                params: {
                    nroTransporte: nroTransporte,
                    nroOS: nroOS,
                    tipoEtis: tipoEtis,
                    estadoViaje: estadoViaje,
                    estadoGPS: estadoGPS,
                    transportista: transportista,
                    proveedorGPS: proveedorGPS,
                    patente: patente,
                    viajeFragil :viajeFragil,
                    cliente: cliente
                },
                callback: function (r, options, success) {
                    if (!success) {

                    }
                    else {
                        MostrarFlota();

                    }
                }
            });
        }

        var renderEstadoGPS = function (value, meta) {
            {
                if (value == 'Online') {
                    meta.tdCls = 'blue-cell';
                    return value;
                }
                if (value == 'Offline') {
                    meta.tdCls = 'red-cell';
                    return value;
                }
                else {
                    meta.tdCls = 'black-cell';
                    return value;
                }
            }
        };

        function MostrarFlota() {

            ClearMap();
            /*if (markerCluster != null) {
              markerCluster.clearMarkers();
            }*/

            arrayPositions.splice(0, arrayPositions.length);

            var store = Ext.getCmp('gridPosiciones').getStore();
            var rowCount = store.count();
            var iterRow = 0;

            while (iterRow < rowCount) {

                var dir = parseInt(store.data.items[iterRow].raw.Direccion);

                var lat = store.data.items[iterRow].raw.Latitud;
                var lon = store.data.items[iterRow].raw.Longitud;

                var Latlng = new google.maps.LatLng(lat, lon);

                arrayPositions.push({
                    Patente: store.data.items[iterRow].raw.Patente,
                    Fecha: store.data.items[iterRow].raw.UltReporte.toString(),
                    Velocidad: store.data.items[iterRow].raw.Velocidad,
                    Latitud: lat,
                    Longitud: lon,
                    LatLng: Latlng,
                    Puerta: store.data.items[iterRow].raw.Puerta1,
                    Temperatura: store.data.items[iterRow].raw.Temperatura1,
                    NroTransporte: store.data.items[iterRow].raw.NroTransporte,
                    NombreConductor: store.data.items[iterRow].raw.NombreConductor,
                    TelefonoConductor: store.data.items[iterRow].raw.TelefonoConductor,

                });

                var iconRoute;

                if (store.data.items[iterRow].raw.EstadoViaje == 'Liberado') {
                    iconRoute = 'Images/Truck_Empty/';
                }
                else if (store.data.items[iterRow].raw.FlagViajeFragil == 1) {
                    iconRoute = 'Images/Truck_Fragile/';
                   }
                    // uno de los elses va que si tiene viaje fragil lo muestre amarillo
                else {
                    iconRoute = 'Images/Truck_Loaded/'
                }

                switch (true) {
                    case ((dir >= 338) || (dir < 22)):
                        marker = new google.maps.Marker({
                            position: Latlng,
                            icon: iconRoute + '1_N_21x29.png',
                            map: map,
                            labelText: store.data.items[iterRow].raw.Patente + store.data.items[iterRow].raw.UltReporte.toString()
                            //labelText: htmlString2, 
                            //infoWinMark: htmlNew
                        });
                        break;
                    case ((dir >= 22) && (dir < 67)):
                        marker = new google.maps.Marker({
                            position: Latlng,
                            icon: iconRoute + '2_NE_32x30.png',
                            map: map,
                            labelText: store.data.items[iterRow].raw.Patente + store.data.items[iterRow].raw.UltReporte.toString()
                            //labelText: htmlString2,
                            //infoWinMark: htmlNew
                        });
                        break;
                    case ((dir >= 67) && (dir < 112)):
                        marker = new google.maps.Marker({
                            position: Latlng,
                            icon: iconRoute + '3_E_30x22.png',
                            map: map,
                            labelText: store.data.items[iterRow].raw.Patente + store.data.items[iterRow].raw.UltReporte.toString()
                            //labelText: htmlString2,
                            //infoWinMark: htmlNew
                        });
                        break;
                    case ((dir >= 112) && (dir < 157)):
                        marker = new google.maps.Marker({
                            position: Latlng,
                            icon: iconRoute + '4_SE_30x32.png',
                            map: map,
                            labelText: store.data.items[iterRow].raw.Patente + store.data.items[iterRow].raw.UltReporte.toString()
                            //labelText: htmlString2,
                            //infoWinMark: htmlNew
                        });
                        break;
                    case ((dir >= 157) && (dir < 202)):
                        marker = new google.maps.Marker({
                            position: Latlng,
                            icon: iconRoute + '5_S_21x29.png',
                            map: map,
                            labelText: store.data.items[iterRow].raw.Patente + store.data.items[iterRow].raw.UltReporte.toString()
                            //labelText: htmlString2,
                            //infoWinMark: htmlNew
                        });
                        break;
                    case ((dir >= 202) && (dir < 247)):
                        marker = new google.maps.Marker({
                            position: Latlng,
                            icon: iconRoute + '6_SW_30x32.png',
                            map: map,
                            labelText: store.data.items[iterRow].raw.Patente + store.data.items[iterRow].raw.UltReporte.toString()
                            //labelText: htmlString2,
                            //infoWinMark: htmlNew
                        });
                        break;
                    case ((dir >= 247) && (dir < 292)):
                        marker = new google.maps.Marker({
                            position: Latlng,
                            icon: iconRoute + '7_W_30x22.png',
                            map: map,
                            labelText: store.data.items[iterRow].raw.Patente + store.data.items[iterRow].raw.UltReporte.toString()
                            //labelText: htmlString2,
                            //infoWinMark: htmlNew
                        });
                        break;
                    case ((dir >= 292) && (dir < 338)):
                        marker = new google.maps.Marker({
                            position: Latlng,
                            icon: iconRoute + '8_NW_32x30.png',
                            map: map,
                            labelText: store.data.items[iterRow].raw.Patente + store.data.items[iterRow].raw.UltReporte.toString()
                            //labelText: htmlString2,
                            //infoWinMark: htmlNew
                        });
                        break;
                }

                var label = new Label({
                    map: null
                });
                label.bindTo('position', marker, 'position');
                label.bindTo('text', marker, 'labelText');

                google.maps.event.addListener(marker, 'click', function () {
                    var latLng = this.position;
                    var patFec = this.labelText;

                    for (i = 0; i < arrayPositions.length; i++) {
                        if ((arrayPositions[i].Patente + arrayPositions[i].Fecha.toString()) == patFec.toString() & arrayPositions[i].LatLng.toString() == latLng.toString()) {

                            var contentString =

                                  '<br>' +
                                      '<table>' +
                                        '<tr>' +
                                            '       <td><b>Fecha</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '       <td>' + (arrayPositions[i].Fecha.toString()).replace("T", " ") + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Patente:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + arrayPositions[i].Patente + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Velocidad:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + arrayPositions[i].Velocidad + ' Km/h </td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Conductor:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + arrayPositions[i].NombreConductor + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Teléfono:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + arrayPositions[i].TelefonoConductor + '</td>' +
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

            //markerCluster = new MarkerClusterer(map, markers);


        }

        function DrawZone(idZona) {
            /*
          for (var i = 0; i < geoLayer.length; i++) {
            geoLayer[i].layer.setMap(null);
            geoLayer[i].label.setMap(null);
            geoLayer.splice(i, 1);
          }
          */
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
