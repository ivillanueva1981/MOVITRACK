<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ControlPanel.aspx.cs" Inherits="Track_Web.ControlPanel" %>
<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
    Track Platform 
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://maps.googleapis.com/maps/api/js?v=3.exp&key=AIzaSyDKLevfrbLESV7ebpmVxb9P7XRRKE1ypq8" type="text/javascript"></script>
    <script src="Scripts/MapFunctions.js" type="text/javascript"></script>
    <script src="Scripts/TopMenu.js" type="text/javascript"></script>
    <script src="Scripts/LabelMarker.js" type="text/javascript"></script>
    <script src="Scripts/RowExpander.js" type="text/javascript"></script>

    <script type="text/javascript">

        var geoLayer = new Array();
        var arrayPositions = new Array();
        var arrayAlerts = new Array();
        var infowindow = new google.maps.InfoWindow();
        var lastSelected = -1;
        var stackedZones = 0;

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
                            btnMenuReportes.disable();
                            btnMenuConfig.disable();
                        }

                    }
                }
            });

            //new Date(),
            var dateDesde = new Ext.form.DateField({
                id: 'dateDesde',
                fieldLabel: 'Desde',
                labelWidth: 100,
                allowBlank: false,
                anchor: '99%',
                format: 'd-m-Y',
                editable: false,
                value: '24-07-2018',
                maxValue: new Date()
            });

            var dateHasta = new Ext.form.DateField({
                id: 'dateHasta',
                fieldLabel: 'Hasta',
                labelWidth: 100,
                allowBlank: false,
                anchor: '99%',
                format: 'd-m-Y',
                editable: false,
                value: '25-07-2018',
                minValue: Ext.getCmp('dateDesde').getValue(),
                maxValue: new Date()
            });

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
                labelWidth: 100,
                forceSelection: true,
                store: storeFiltroTransportista,
                valueField: 'Transportista',
                displayField: 'Transportista',
                queryMode: 'local',
                anchor: '99%',
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                editable: false,
                forceSelection: true,
                listeners: {
                    change: function (field, newVal) {
                        if (newVal != null) {
                            FiltrarPatentes();
                        }
                    }
                }
            });

            var storeFiltroPatente = new Ext.data.JsonStore({
                autoLoad: true,
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
                forceSelection: true,
                store: storeFiltroPatente,
                valueField: 'Patente',
                displayField: 'Patente',
                queryMode: 'local',
                anchor: '99%',
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                editable: true,
                forceSelection: true
            });

            var storeFiltroEstadoViaje = new Ext.data.JsonStore({
                fields: ['EstadoViaje'],
                data: [{ "EstadoViaje": "Todos" },
                      { "EstadoViaje": "Asignado" },
                      { "EstadoViaje": "En Ruta" },
                      { "EstadoViaje": "En Destino" },
                      { "EstadoViaje": "Finalizado" },
                      { "EstadoViaje": "Cerrado por Sistema" },
                      { "EstadoViaje": "Cerrado manual" },
                      { "EstadoViaje": "Cerrado por segundo viaje" }
                ]
            });

            var comboFiltroEstadoViaje = new Ext.form.field.ComboBox({
                id: 'comboFiltroEstadoViaje',
                fieldLabel: 'Estado',
                store: storeFiltroEstadoViaje,
                valueField: 'EstadoViaje',
                displayField: 'EstadoViaje',
                queryMode: 'local',
                anchor: '99%',
                labelWidth: 100,
                editable: false,
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                forceSelection: true
            });

            Ext.getCmp('comboFiltroEstadoViaje').setValue('Todos');

            var textFiltroNroTransporte = new Ext.form.TextField({
                id: 'textFiltroNroTransporte',
                fieldLabel: 'Guía Despacho',
                labelWidth: 100,
                allowBlank: true,
                anchor: '99%',
                maxLength: 20
            });

            var textFiltroOrdenServicio = new Ext.form.TextField({
                id: 'textFiltroOrdenServicio',
                fieldLabel: 'OS',
                labelWidth: 100,
                allowBlank: true,
                anchor: '99%',
                maxLength: 20
            });

            var textFiltroNroContenedor = new Ext.form.TextField({
                id: 'textFiltroNroContenedor',
                fieldLabel: 'Nro. Contenedor',
                labelWidth: 100,
                allowBlank: true,
                anchor: '99%',
                maxLength: 20
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
                fieldLabel: 'Origen del Servicio',
                labelWidth: 100,
                forceSelection: true,
                store: storeFiltroTipoEtis,
                valueField: 'ETIS',
                displayField: 'ETIS',
                queryMode: 'local',
                anchor: '99%',
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                editable: false,
                forceSelection: true
            });

            storeFiltroTipoEtis.load({
                callback: function (r, options, success) {
                    if (success) {
                        comboFiltroTipoEtis.setValue('Todas');
                    }
                }
            })

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
                }
            });

            storeZonasOrigen.load({
                params: {
                    idTipoZona: 1,
                    nombreZona: ''
                },
                callback: function (r, options, success) {
                    Ext.getCmp("comboZonaOrigen").store.insert(0, { IdZona: 0, NombreZona: "Todos" });
                    Ext.getCmp("comboZonaOrigen").setValue(0);
                }
            });


            var storeFiltroAlertas = new Ext.data.JsonStore({
                fields: ['Alertas'],
                data: [{ "Alertas": "Todos" },
                      { "Alertas": "Con Alertas" },
                      { "Alertas": "Sin Alertas" }
                ]
            });

            var comboFiltroAlertas = new Ext.form.field.ComboBox({
                id: 'comboFiltroAlertas',
                fieldLabel: 'Alertas',
                store: storeFiltroAlertas,
                valueField: 'Alertas',
                displayField: 'Alertas',
                queryMode: 'local',
                anchor: '99%',
                labelWidth: 100,
                editable: false,
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                forceSelection: true
            });

            Ext.getCmp('comboFiltroAlertas').setValue('Todos');

            var storeFiltroClientes = new Ext.data.JsonStore({
                fields: ['RutCliente', 'NombreCliente'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetClientesUsuario&Todos=True',
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
                labelWidth: 100,
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                editable: true,
                forceSelection: true
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

            var btnExportar = {
                id: 'btnExportar',
                xtype: 'button',
                iconAlign: 'left',
                icon: 'Images/export_black_20x20.png',
                text: 'Exportar',
                width: 90,
                height: 26,
                listeners: {
                    click: {
                        element: 'el',
                        fn: function () {

                            var desde = Ext.getCmp('dateDesde').getRawValue();
                            var hasta = Ext.getCmp('dateHasta').getRawValue();
                            var nroTransporte = Ext.getCmp('textFiltroNroTransporte').getValue();
                            var nroOS = Ext.getCmp('textFiltroOrdenServicio').getValue();
                      
                            var nroContenedor = Ext.getCmp('textFiltroNroContenedor').getValue();
                            var tipoEtis = Ext.getCmp('comboFiltroTipoEtis').getValue();
                            var idOrigen = Ext.getCmp('comboZonaOrigen').getValue();
                            var idDestino = 0;
                            var patente = Ext.getCmp('comboFiltroPatente').getValue();
                            var estadoViaje = Ext.getCmp('comboFiltroEstadoViaje').getValue();
                            var alertas = Ext.getCmp('comboFiltroAlertas').getValue();
                            var cliente = Ext.getCmp('comboFiltroClientes').getValue();

                            switch (estadoViaje) {
                                case "Finalizado":
                                    estadoViaje = "EnLocal-P";
                                    break;
                                case "En Ruta":
                                    estadoViaje = "RUTA";
                                    break;
                                case "Cerrado por Sistema":
                                    estadoViaje = "Cerrado por Sistema";
                                    break;
                                case "Cerrado manual":
                                    estadoViaje = "Cerrado manual";
                                    break;
                                case "Cerrado por segundo viaje":
                                    estadoViaje = "Cerrado por segundo viaje";
                                    break;
                                case "En Destino":
                                    estadoViaje = "EnLocal-R";
                                    break;
                                case "Asignado":
                                    estadoViaje = "ASIGNADO";
                                    break;
                                case "Todos":
                                    estadoViaje = "Todos";
                                    break;
                                default:
                                    estadoViaje = "Todos";
                            }

                            var mapForm = document.createElement("form");
                            mapForm.target = "ToExcel";
                            mapForm.method = "POST"; // or "post" if appropriate
                            mapForm.action = 'ControlPanel.aspx?Metodo=ExportExcel';

                            //
                            var _desde = document.createElement("input");
                            _desde.type = "text";
                            _desde.name = "desde";
                            _desde.value = desde;
                            mapForm.appendChild(_desde);

                            var _hasta = document.createElement("input");
                            _hasta.type = "text";
                            _hasta.name = "hasta";
                            _hasta.value = hasta;
                            mapForm.appendChild(_hasta);

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

                            var _nroContenedor = document.createElement("input");
                            _nroContenedor.type = "text";
                            _nroContenedor.name = "nroContenedor";
                            _nroContenedor.value = nroContenedor;
                            mapForm.appendChild(_nroContenedor);

                            var _tipoEtis = document.createElement("input");
                            _tipoEtis.type = "text";
                            _tipoEtis.name = "tipoEtis";
                            _tipoEtis.value = tipoEtis;
                            mapForm.appendChild(_tipoEtis);

                            var _idOrigen = document.createElement("input");
                            _idOrigen.type = "text";
                            _idOrigen.name = "idOrigen";
                            _idOrigen.value = idOrigen;
                            mapForm.appendChild(_idOrigen);

                            var _patente = document.createElement("input");
                            _patente.type = "text";
                            _patente.name = "patente";
                            _patente.value = patente;
                            mapForm.appendChild(_patente);

                            var _estadoViaje = document.createElement("input");
                            _estadoViaje.type = "text";
                            _estadoViaje.name = "estadoViaje";
                            _estadoViaje.value = estadoViaje;
                            mapForm.appendChild(_estadoViaje);

                            var _alertas = document.createElement("input");
                            _alertas.type = "text";
                            _alertas.name = "alertas";
                            _alertas.value = alertas;
                            mapForm.appendChild(_alertas);

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

            var storeViajesControlPanel = new Ext.data.JsonStore({
                autoLoad: false,
                fields: ['NroTransporte',
                        'Fecha',
                        'SecuenciaDestino',
                        'PatenteTracto',
                        'PatenteTrailer',
                        'Transportista',
                        { name: 'FechaHoraCreacion', type: 'date', dateFormat: 'c' },
                        'CodigoOrigen',
                        'NombreOrigen',
                        'FHAsignacion',
                        'FHSalidaOrigen',
                        'CodigoDestino',
                        'NombreDestino',
                        'FHLlegadaDestino',
                        { name: 'FHCierreSistema', type: 'date', dateFormat: 'c' },
                        'TiempoViaje',
                        'FHSalidaDestino',
                        'EstadoViaje',
                        'EstadoLat',
                        'EstadoLon',
                        'DestinoLat',
                        'DestinoLon',
                        'CantidadAlertas',
                        'CantidadAperturaPuerta',
                        'CantidadDetencion',
                        'CantidadPerdidaSenal',
                        'CantidadTemperatura',
                        'AlertasGestionadas',
                        'AlertasPorGestionar',
                        { name: 'UltReporte', type: 'date', dateFormat: 'c' },
                        'Velocidad',
                        'Coordenadas',
                        'NumeroOrdenServicio',
                        'NombreCliente',
                        'NumeroContenedor',
                        { name: 'FechaHoraPresentacion', type: 'date', dateFormat: 'c' },
                        'NombreChofer',
                        'LlegadaCliente',
                        'SalidaCliente',
                        'Etis',
                        'ETA'
                ],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetViajesControlPanel',
                    reader: { type: 'json', root: 'Zonas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            storeFiltroTransportista.load({
                callback: function (r, options, success) {
                    if (success) {

                        var firstTransportista = Ext.getCmp("comboFiltroTransportista").store.getAt(0).get("Transportista");
                        Ext.getCmp("comboFiltroTransportista").setValue(firstTransportista);

                        storeFiltroPatente.load({
                            callback: function (r, options, success) {
                                if (success) {
                                    //Ext.getCmp("comboFiltroPatente").store.insert(0, { Patente: "Todas" });
                                    Ext.getCmp("comboFiltroPatente").setValue("Todas");

                                    var estadoViaje = Ext.getCmp('comboFiltroEstadoViaje').getValue();
                                    var alertas = Ext.getCmp('comboFiltroAlertas').getValue();

                                    switch (estadoViaje) {
                                        case "Finalizado":
                                            estadoViaje = "EnLocal-P";
                                            break;
                                        case "Cerrado por Sistema":
                                            estadoViaje = "Cerrado por Sistema";
                                            break;
                                        case "Cerrado manual":
                                            estadoViaje = "Cerrado manual";
                                            break;
                                        case "Cerrado por segundo viaje":
                                            estadoViaje = "Cerrado por segundo viaje";
                                            break;
                                        case "En Ruta":
                                            estadoViaje = "RUTA";
                                            break;
                                        case "En Destino":
                                            estadoViaje = "EnLocal-R";
                                            break;
                                        case "Asignado":
                                            estadoViaje = "ASIGNADO";
                                            break;
                                        case "Todos":
                                            estadoViaje = "Todos";
                                            break;
                                        default:
                                            estadoViaje = "Todos";
                                    }

                                    storeFiltroClientes.load({
                                        callback: function (r, options, success) {
                                            if (success) {
                                                comboFiltroClientes.setValue("Todos");

                                                storeViajesControlPanel.load({
                                                    params: {
                                                        desde: Ext.getCmp('dateDesde').getValue(),
                                                        hasta: Ext.getCmp('dateHasta').getValue(),
                                                        nroTransporte: Ext.getCmp('textFiltroNroTransporte').getValue(),
                                                        nroOS: Ext.getCmp('textFiltroOrdenServicio').getValue(),
                                                        
                                                        nroContenedor: Ext.getCmp('textFiltroNroContenedor').getValue(),
                                                        tipoEtis: Ext.getCmp('comboFiltroTipoEtis').getValue(),
                                                        patente: "Todas",
                                                        estadoViaje: estadoViaje,
                                                        transportista: Ext.getCmp('comboFiltroTransportista').getValue(),
                                                        alertas: alertas,
                                                        cliente: Ext.getCmp('comboFiltroClientes').getValue()
                                                    },
                                                    callback: function (r, options, success) {
                                                        if (success) {
                                                            Ext.getCmp("gridPanelViajesControlPanel").setTitle("Panel de Control. " + storeViajesControlPanel.data.length + " viajes.")
                                                        }
                                                    }
                                                })
                                            }
                                        }
                                    });

                                }
                            }
                        })

                    }
                }
            })

            var gridPanelViajesControlPanel = Ext.create('Ext.grid.Panel', {
                id: 'gridPanelViajesControlPanel',
                title: 'Panel de Control.',
                store: storeViajesControlPanel,
                anchor: '100% 100%',
                columnLines: true,
                scroll: false,
                viewConfig: {
                    style: { overflow: 'auto', overflowX: 'hidden' },
                    enableTextSelection: true
                },
                columns: [{ text: "Viaje", dataIndex: 'CantidadAlertas', sortable: true, width: 40, align: 'center', renderer: renderIconAlertas },
                            { text: 'Guía', sortable: true, width: 55, dataIndex: 'NroTransporte' },
                            { text: 'OS', sortable: true, width: 60, dataIndex: 'NumeroOrdenServicio' },
                            { text: 'Cliente', sortable: true, flex: 1, dataIndex: 'NombreCliente' },
                            { text: 'Contenedor', sortable: true, width: 80, dataIndex: 'NumeroContenedor' },
                            { text: 'Fecha ejecución', sortable: true, width: 100, dataIndex: 'FechaHoraPresentacion', renderer: Ext.util.Format.dateRenderer('d-m-Y') },
                            { text: 'Hora presentación', sortable: true, width: 105, dataIndex: 'FechaHoraPresentacion', renderer: Ext.util.Format.dateRenderer('H:i') },
                            { text: 'Llegada cliente', sortable: true, width: 110, dataIndex: 'LlegadaCliente' },
                            { text: 'Salida cliente', sortable: true, width: 105, dataIndex: 'SalidaCliente' },
                            { text: 'Patente', sortable: true, width: 60, dataIndex: 'PatenteTracto' },
                            { text: 'Conductor', sortable: true, width: 120, dataIndex: 'NombreChofer' },
                            { text: 'Ult. Reporte', sortable: true, width: 110, dataIndex: 'UltReporte', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                            { text: 'Vel. (Km/h)', sortable: true, width: 70, align: 'center', dataIndex: 'Velocidad' },
                            { text: 'ETIS', hidden: true, sortable: true, flex: 1, dataIndex: 'Etis' },
                            { text: 'T. Viaje', sortable: true, width: 60, dataIndex: 'TiempoViaje', renderer: renderHorasMinutos },
                            { text: 'T. Est. Lleg.', sortable: true, width: 100, dataIndex: 'ETA' },
                            { text: 'Alertas', sortable: true, width: 50, dataIndex: 'CantidadAlertas', align: 'center', renderer: renderCantidadAlertas },
                            { text: 'Estado', sortable: true, flex: 1, dataIndex: 'EstadoViaje', renderer: renderEstadoViaje },

                            {
                                xtype: 'actioncolumn',
                                width: 24,
                                items: [{
                                    icon: 'Images/showmap_gray_18x18.png',
                                    tooltip: 'Ver viaje en mapa.',
                                    handler: function (grid, rowIndex, colIndex) {
                                        var row = grid.getStore().getAt(rowIndex);

                                        ShowMapViaje(row);

                                    }
                                }]
                            }
                ],
                listeners: {
                    itemdblclick: function (sm, row, rec) {

                        ShowDetalleViaje(row);

                        lastSelected = Ext.getCmp("gridPanelViajesControlPanel").getSelectionModel().getLastSelected().index;
                        Ext.getCmp("gridPanelViajesControlPanel").getSelectionModel().deselectAll();

                    }
                }
            });

            var panelFilters = new Ext.FormPanel({
                id: 'panelFilters',
                title: 'Filtros Reporte',
                anchor: '100% 100%',
                bodyStyle: 'padding: 5px;',
                layout: 'anchor',
                items: [{
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [dateDesde]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [dateHasta]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [textFiltroNroTransporte]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [textFiltroOrdenServicio]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [textFiltroNroContenedor]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [comboZonaOrigen]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [comboFiltroTipoEtis]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [comboFiltroPatente]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [comboFiltroEstadoViaje]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [comboFiltroAlertas]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [comboFiltroClientes]
                }
                ],
                buttons: [btnExportar, btnBuscar]
            });

            var numberNroTransporte = new Ext.form.NumberField({
                fieldLabel: 'Guía Despacho',
                id: 'numberNroTransporte',
                anchor: '99%',
                labelWidth: 140,
                hideTrigger: true
            });

            var textLocalDestino = new Ext.form.TextField({
                fieldLabel: 'Nombre Cliente',
                id: 'textLocalDestino',
                anchor: '99%',
                labelWidth: 140,
                style: {
                    marginLeft: '20px'
                },
            });

            var textFechaAsignacion = new Ext.form.TextField({
                fieldLabel: 'Fecha asignación',
                id: 'textFechaAsignacion',
                anchor: '99%',
                labelWidth: 140
            });

            var textFechaSalidaOrigen = new Ext.form.TextField({
                fieldLabel: 'Fecha salida origen',
                id: 'textFechaSalidaOrigen',
                anchor: '99%',
                labelWidth: 140,
                style: {
                    marginLeft: '20px'
                },
            });

            var textFechaLlegadaDestino = new Ext.form.TextField({
                fieldLabel: 'Fecha llegada cliente',
                id: 'textFechaLlegadaDestino',
                anchor: '99%',
                labelWidth: 140
            });

            var textFechaSalidaDestino = new Ext.form.TextField({
                fieldLabel: 'Fecha salida cliente',
                id: 'textFechaSalidaDestino',
                anchor: '99%',
                labelWidth: 140,
                style: {
                    marginLeft: '20px'
                },
            });

            var storeGestionCallCenter = new Ext.data.JsonStore({
                autoLoad: false,
                fields: [{ name: 'FechaCreacion', type: 'date', dateFormat: 'c' },
                        'NombreAlerta',
                        'AtendidoPor',
                        'NombreContacto',
                        'Explicacion',
                        'Observacion'
                ],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxAlertas.aspx?Metodo=GetGestionCallCenter',
                    reader: { type: 'json', root: 'Zonas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var gridPanelGestionCallCenter = Ext.create('Ext.grid.Panel', {
                id: 'gridPanelGestionCallCenter',
                //title: 'Gestión Call Center',
                store: storeGestionCallCenter,
                //width: 960,
                //height: 160,
                anchor: '100% 100%',
                columnLines: true,
                scroll: false,
                viewConfig: {
                    style: { overflow: 'auto', overflowX: 'hidden' }
                },
                columns: [
                            { text: 'Fecha Creación', sortable: true, width: 105, dataIndex: 'FechaCreacion', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                            { text: 'Nombre alerta', sortable: true, flex: 1, dataIndex: 'NombreAlerta' },
                            { text: 'Atendido por', sortable: true, flex: 1, dataIndex: 'AtendidoPor' },
                            { text: 'Contacto', sortable: true, flex: 1, dataIndex: 'NombreContacto' },
                            { text: 'Explicación', sortable: true, flex: 1, dataIndex: 'Explicacion' },
                            { text: 'Observación', sortable: true, width: 300, dataIndex: 'Observacion' }
                ]
            });

            var storeAlertasPorGestionarCallCenter = new Ext.data.JsonStore({
                autoLoad: false,
                fields: [{ name: 'FechaCreacion', type: 'date', dateFormat: 'c' },
                          'IdAlerta',
                          'NombreAlerta',
                          'NroTransporte',
                          'LocalDestinoCodigo',
                          'NombreTransportista',
                          'Clasificacion',
                          'Prioridad'
                ],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxAlertas.aspx?Metodo=GetAlertasPorGestionarCallCenter',
                    reader: { type: 'json', root: 'Zonas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var gridPanelAlertasPorGestionarCallCenter = Ext.create('Ext.grid.Panel', {
                id: 'gridPanelAlertasPorGestionarCallCenter',
                //title: 'Alertas por gestionar',
                store: storeAlertasPorGestionarCallCenter,
                //width: 973,
                //height: 190,
                anchor: '100% 100%',
                columnLines: true,
                scroll: false,
                viewConfig: {
                    style: { overflow: 'auto', overflowX: 'hidden' }
                },
                columns: [
                            { text: 'Fecha Creación', sortable: true, width: 105, dataIndex: 'FechaCreacion', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                            { text: 'Nombre alerta', sortable: true, flex: 1, dataIndex: 'NombreAlerta' },
                            { text: 'Transportista', sortable: true, flex: 1, dataIndex: 'NombreTransportista' },
                            { text: 'Estado', sortable: true, flex: 1, dataIndex: 'Clasificacion' },
                            { text: 'Prioridad', sortable: true, width: 60, dataIndex: 'Prioridad' }
                ]
            });

            var tabPanelGestionCallCenter = Ext.create('Ext.tab.Panel', {
                id: 'tabPanelAlertasCallCenter',
                activeTab: 0,
                width: 980,
                height: 210,
                //anchor: '100% -20',
                plain: true,

                items: [
                {
                    title: 'Alertas gestionadas',
                    layout: 'anchor',
                    items: [gridPanelGestionCallCenter]
                }]
            });

            var formDetalleViaje = new Ext.FormPanel({
                id: 'formDetalleViaje',
                border: false,
                frame: true,
                height: 300,
                //anchor: '100% 100%',
                layout: 'column',
                items: [{
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.5,
                    items: [numberNroTransporte, textFechaAsignacion, textFechaLlegadaDestino]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.5,
                    items: [textLocalDestino, textFechaSalidaOrigen, textFechaSalidaDestino]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [tabPanelGestionCallCenter]
                }]
            });

            var btnMostarEnMapa = {
                xtype: 'button',
                iconAlign: 'left',
                icon: 'Images/showmap_gray_16x16.png',
                text: 'Ver en Mapa',
                width: 90,
                height: 24,
                handler: function () {
                    //winDetalleViaje.close();
                    ShowMapViaje(Ext.getCmp("gridPanelViajesControlPanel").getStore().getAt(lastSelected));

                }
            };

            var btnSalirDetalleViaje = {
                xtype: 'button',
                iconAlign: 'left',
                icon: 'Images/back_black_16x16.png',
                text: 'Salir',
                width: 70,
                height: 24,
                handler: function () {
                    winDetalleViaje.close();

                    Ext.getCmp('textFechaAsignacion').reset();
                    Ext.getCmp('textFechaSalidaOrigen').reset();
                    Ext.getCmp('textFechaLlegadaDestino').reset();
                    Ext.getCmp('textFechaSalidaDestino').reset();
                    Ext.getCmp('gridPanelGestionCallCenter').store.removeAll();

                }
            };

            var winDetalleViaje = new Ext.Window({
                id: 'winDetalleViaje',
                title: 'Detalle Viaje',
                width: 1000,
                closeAction: 'hide',
                modal: true,
                items: formDetalleViaje,
                resizable: false,
                border: false,
                constrain: true,
                buttons: [btnMostarEnMapa, btnSalirDetalleViaje]
            });

            var leftPanel = new Ext.FormPanel({
                id: 'leftPanel',
                region: 'west',
                border: true,
                margins: '0 0 3 3',
                width: 270,
                minWidth: 200,
                maxWidth: 330,
                layout: 'anchor',
                collapsible: true,
                titleCollapsed: false,
                collapsed: true,
                split: true,
                items: [panelFilters]
            });

            var centerPanel = new Ext.FormPanel({
                id: 'centerPanel',
                region: 'center',
                border: true,
                margins: '0 3 3 0',
                anchor: '100% 100%',
                items: [gridPanelViajesControlPanel]
            });

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

            var storePosicionesRuta = new Ext.data.JsonStore({
                autoLoad: false,
                fields: ['Patente',
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
                    url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetPosicionesRuta',
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
                            { text: 'Ignicion', dataIndex: 'Ignicion', hidden: true }
                ]
            });

            var storeAlertasRuta = new Ext.data.JsonStore({
                autoLoad: false,
                fields: [{ name: 'FechaInicioAlerta', type: 'date', dateFormat: 'c' },
                       { name: 'FechaHoraCreacion', type: 'date', dateFormat: 'c' },
                        'PatenteTracto',
                        'TextFechaCreacion',
                        'PatenteTrailer',
                        'Velocidad',
                        'Latitud',
                        'Longitud',
                        'DescripcionAlerta',
                        'Ocurrencia',
                        'Puerta1',
                        'Temp1'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxAlertas.aspx?Metodo=GetAlertasRuta',
                    reader: { type: 'json', root: 'Zonas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var gridPanelAlertasRuta = Ext.create('Ext.grid.Panel', {
                id: 'gridPanelAlertasRuta',
                title: 'Alertas y eventos',
                store: storeAlertasRuta,
                anchor: '100% 100%',
                columnLines: true,
                scroll: false,
                viewConfig: {
                    style: { overflow: 'auto', overflowX: 'hidden' }
                },
                columns: [
                            { text: 'Fecha Inicio', sortable: true, width: 105, dataIndex: 'FechaInicioAlerta', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                            { text: 'Fecha Envío', sortable: true, width: 105, dataIndex: 'FechaHoraCreacion', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                            { text: 'TextFechaCreacion', sortable: true, dataIndex: 'TextFechaCreacion', hidden: true },
                            { text: 'Tracto', sortable: true, dataIndex: 'PatenteTracto', hidden: true },
                            { text: 'Trailer', sortable: true, dataIndex: 'PatenteTrailer', hidden: true },
                            { text: 'Velocidad', sortable: true, dataIndex: 'Velocidad', hidden: true },
                            { text: 'Latitud', sortable: true, width: 60, dataIndex: 'Latitud', hidden: true },
                            { text: 'Longitud', sortable: true, flex: 1, dataIndex: 'Longitud', hidden: true },
                            { text: 'Descripción', sortable: true, flex: 1, dataIndex: 'DescripcionAlerta' },
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
                                            '       <td><b>Fecha</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '       <td>' + row.data.TextFechaCreacion + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Patente:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + row.data.PatenteTracto + '</td>' +
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

            var textAreaAlerta = new Ext.form.field.TextArea({
                fieldLabel: 'Descrip.',
                id: 'textAreaAlerta',
                anchor: '99%',
                labelWidth: 60,
                height: 55
            });

            var viewWidth = Ext.getBody().getViewSize().width;
            var viewHeight = Ext.getBody().getViewSize().height;

            var panelAlertas = new Ext.FormPanel({
                id: 'panelAlertas',
                border: false,
                region: 'west',
                layout: 'anchor',
                width: 420,
                minWidth: 250,
                maxWidth: 500,
                split: true,
                collapsible: true,
                items: [gridPanelAlertasRuta]
            });

            panelAlertas.on('collapse', function () {
                google.maps.event.trigger(map, "resize");
            });

            panelAlertas.on('expand', function () {
                google.maps.event.trigger(map, "resize");
            });

            var panelMap = new Ext.FormPanel({
                id: 'panelMap',
                region: 'center',
                html: '<div id="divMapViaje" style="width:100%; height:100%;"></div>'
            });

            var btnSalirMapa = {
                xtype: 'button',
                iconAlign: 'left',
                icon: 'Images/back_black_16x16.png',
                text: 'Salir',
                width: 70,
                height: 24,
                handler: function (a, b, c, d, e) {
                    winMap.close();
                }
            };

            var winMap = new Ext.window.Window({
                id: 'winMap',
                title: 'Detalle Viaje',
                constrain: true,
                height: viewHeight / 1.2,
                width: viewWidth / 1.25,
                hidden: true,
                modal: true,
                resizable: true,
                border: true,
                draggable: true,
                closeAction: 'hide',
                maximizable: true,
                layout: 'border',
                items: [panelAlertas, panelMap],
                buttons: [btnSalirMapa],
                listeners: {
                    'resize': function (win, width, height, eOpts) {
                        google.maps.event.trigger(map, "resize");
                    }
                }
            });

            var viewport = Ext.create('Ext.container.Viewport', {
                layout: 'border',
                items: [topMenu, leftPanel, centerPanel]
            });

            var refreshPanel = function () {
                Buscar();
            };
            setInterval(refreshPanel, 1200000); //1200 seg

        });

    </script>

    <script type="text/javascript">

        Ext.onReady(function () {
            GeneraMapa("dvMap", true);
        });

        function Buscar() {

            if (!Ext.getCmp('leftPanel').getForm().isValid()) {
                return;
            }

            //Ext.getCmp('winDistanciaTiempo').hide();

            var desde = Ext.getCmp('dateDesde').getRawValue();
            var hasta = Ext.getCmp('dateHasta').getRawValue();
            var nroTransporte = Ext.getCmp('textFiltroNroTransporte').getValue();
            var nroOS = Ext.getCmp('textFiltroOrdenServicio').getValue();
            var nroContenedor = Ext.getCmp('textFiltroNroContenedor').getValue();
            var tipoEtis = Ext.getCmp('comboFiltroTipoEtis').getValue();
            var idOrigen = Ext.getCmp('comboZonaOrigen').getValue();
            var idDestino = 0;
            var patente = Ext.getCmp('comboFiltroPatente').getValue();
            var estadoViaje = Ext.getCmp('comboFiltroEstadoViaje').getValue();
            var alertas = Ext.getCmp('comboFiltroAlertas').getValue();
            var cliente = Ext.getCmp('comboFiltroClientes').getValue();
            
            switch (estadoViaje) {
                case "Finalizado":
                    estadoViaje = "EnLocal-P";
                    break;
                case "En Ruta":
                    estadoViaje = "RUTA";
                    break;
                case "Cerrado por Sistema":
                    estadoViaje = "Cerrado por Sistema";
                    break;
                case "Cerrado manual":
                    estadoViaje = "Cerrado manual";
                    break;
                case "Cerrado por segundo viaje":
                    estadoViaje = "Cerrado por segundo viaje";
                    break;
                case "En Destino":
                    estadoViaje = "EnLocal-R";
                    break;
                case "Asignado":
                    estadoViaje = "ASIGNADO";
                    break;
                case "Todos":
                    estadoViaje = "Todos";
                    break;
                default:
                    estadoViaje = "Todos";
            }

            var store = Ext.getCmp('gridPanelViajesControlPanel').store;
            store.load({
                params: {
                    desde: desde,
                    hasta: hasta,
                    nroTransporte: nroTransporte,
                    nroOS: nroOS,
                    nroContenedor: nroContenedor,
                    tipoEtis: tipoEtis,
                    idOrigen: idOrigen,
                    idDestino: idDestino,
                    patente: patente,
                    estadoViaje: estadoViaje,
                    alertas: alertas,
                    cliente: cliente
                },
                callback: function (r, options, success) {
                    if (success) {
                        Ext.getCmp("gridPanelViajesControlPanel").setTitle("Panel de Control. " + store.data.length + " viajes.")
                    }
                }
            });
        }

        function ShowMapViaje(row) {

            if (Ext.getCmp('winMap') != null) {
                Ext.getCmp('winMap').close();
            }

            var nroTransporte = row.data.NroTransporte;
            var origen = row.data.CodigoOrigen;
            var destino = row.data.CodigoDestino;
            var estadoViaje = row.data.EstadoViaje;
            var patenteTracto = row.data.PatenteTracto;
            var patenteTrailer = row.data.PatenteTrailer;
            var FechaHoraCreacion = row.data.FechaHoraCreacion;
            var FHSalidaOrigen = row.data.FHSalidaOrigen;
            var FHLlegadaDestino = row.data.FHLlegadaDestino;
            var FHCierreSistema = row.data.FHCierreSistema;
            //var destino = row.data.NombreCliente;

            var estadoLat = row.data.EstadoLat;
            var estadoLon = row.data.EstadoLon;
            var destinoLat = row.data.DestinoLat;
            var destinoLon = row.data.DestinoLon;

            var title = "Detalle Guia Despacho: " + nroTransporte;
            Ext.getCmp('winMap').setTitle(title);

            ClearMap();
            arrayPositions.splice(0, arrayPositions.length);
            arrayAlerts.splice(0, arrayAlerts.length);

            GetPosiciones(origen, destino, patenteTracto, patenteTrailer, FechaHoraCreacion, FHSalidaOrigen, FHLlegadaDestino, FHCierreSistema, nroTransporte, destino, estadoViaje)
            GetAlertasRuta(nroTransporte, destino, estadoViaje);

            if (nroTransporte > 0) {
                FindPoints(nroTransporte);
            }

            Ext.getCmp("winMap").show();

            Ext.Msg.wait('Espere por favor...', 'Generando posiciones');

            var myLatlng = new google.maps.LatLng(-33.453172, -70.858681);
            var myOptions = {
                zoom: 12,
                center: myLatlng,
                mapTypeId: google.maps.MapTypeId.ROADMAP
            };

            map = new google.maps.Map(document.getElementById("divMapViaje"), myOptions);
        }

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

              //  map.setCenter(startPoint);

                //DrawZone(data.IdOrigen, 1);
                //DrawZone(data.IdDestino, 2);

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

        function GetAlertasRuta(nroTransporte, destino, estadoViaje) {

            var store = Ext.getCmp('gridPanelAlertasRuta').store;
            store.load({
                params: {
                    nroTransporte: nroTransporte,
                    destino: destino,
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
                        MuestraAlertasViaje();
                    }
                }
            });
        }

        function GetPosiciones(origen, destino, patenteTracto, patenteTrailer, fechaHoraCreacion, fechaHoraSalidaOrigen, fechaHoraLlegadaDestino, fechaHoraCierreSistema, nroTransporte, destino, estadoViaje) {

            Ext.getCmp('gridPosicionesRuta').store.removeAll();

            var store = Ext.getCmp('gridPosicionesRuta').store;
            var storeZone = Ext.getCmp('gridZonasToDraw').store;

            var fec;

            if (estadoViaje == 'Finalizado') {
                fec = fechaHoraLlegadaDestino;
            }
            if (estadoViaje == 'Cerrado por Sistema' || estadoViaje == 'Cerrado manual' || estadoViaje == 'Cerrado por segundo viaje') {
                fec = fechaHoraCierreSistema;
            }
            if (fec == null) {
                fec = new Date();
            }

            store.load({
                params: {
                    patenteTracto: patenteTracto,
                    patenteTrailer: patenteTrailer,
                    fechaHoraCreacion: fechaHoraCreacion,
                    fechaHoraSalidaOrigen: fechaHoraSalidaOrigen,
                    fechaHoraLlegadaDestino: fechaHoraLlegadaDestino,
                    nroTRansporte: nroTransporte,
                    destino: destino,
                    estadoViaje: estadoViaje
                },
                callback: function (r, options, success) {
                    if (success) {

                        storeZone.load({
                            params: {
                                fechaDesde: fechaHoraCreacion,
                                fechaHasta: fec,
                                patente1: patenteTrailer,
                                patente2: patenteTracto,
                                _nroTransporte: nroTransporte
                            },
                            callback: function (r, options, success) {
                                if (success) {

                                    MuestraRutaViaje();

                                    var store = Ext.getCmp('gridZonasToDraw').getStore();
                                    for (var i = 0; i < store.count() ; i++) {
                                        DrawZone(store.getAt(i).data.IdZona);
                                    }

                                    DrawZone(origen);
                                    var storeViajes = Ext.getCmp('gridPanelViajesControlPanel').store;

                                    for (var i = 0; i < storeViajes.count() ; i++) {
                                        if (storeViajes.getAt(i).data.NroTransporte == nroTransporte) {
                                            DrawZone(storeViajes.getAt(i).data.CodigoDestino);
                                        }
                                    }

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

                arrayPositions.push({
                    Fecha: store.data.items[iterRow].raw.Fecha.toString(),
                    Patente: store.data.items[iterRow].raw.Patente,
                    Velocidad: store.data.items[iterRow].raw.Velocidad,
                    Latitud: lat,
                    Longitud: lon,
                    LatLng: Latlng
                });

                if (store.data.items[iterRow].raw.Velocidad > 0) {

                    switch (true) {
                        case ((dir >= 338) || (dir < 22)):
                            marker = new google.maps.Marker({
                                position: Latlng,
                                icon: 'Images/Circle_Arrow/1_arrowcircle_blue_N_20x20.png',
                                map: map,
                                labelText: store.data.items[iterRow].raw.Fecha.toString()
                            });
                            break;
                        case ((dir >= 22) && (dir < 67)):
                            marker = new google.maps.Marker({
                                position: Latlng,
                                icon: 'Images/Circle_Arrow/2_arrowcircle_blue_NE_20x20.png',
                                map: map,
                                labelText: store.data.items[iterRow].raw.Fecha.toString()
                            });
                            break;
                        case ((dir >= 67) && (dir < 112)):
                            marker = new google.maps.Marker({
                                position: Latlng,
                                icon: 'Images/Circle_Arrow/3_arrowcircle_blue_E_20x20.png',
                                map: map,
                                labelText: store.data.items[iterRow].raw.Fecha.toString()
                            });
                            break;
                        case ((dir >= 112) && (dir < 157)):
                            marker = new google.maps.Marker({
                                position: Latlng,
                                icon: 'Images/Circle_Arrow/4_arrowcircle_blue_SE_20x20.png',
                                map: map,
                                labelText: store.data.items[iterRow].raw.Fecha.toString()
                            });
                            break;
                        case ((dir >= 157) && (dir < 202)):
                            marker = new google.maps.Marker({
                                position: Latlng,
                                icon: 'Images/Circle_Arrow/5_arrowcircle_blue_S_20x20.png',
                                map: map,
                                labelText: store.data.items[iterRow].raw.Fecha.toString()
                            });
                            break;
                        case ((dir >= 202) && (dir < 247)):
                            marker = new google.maps.Marker({
                                position: Latlng,
                                icon: 'Images/Circle_Arrow/6_arrowcircle_blue_SW_20x20.png',
                                map: map,
                                labelText: store.data.items[iterRow].raw.Fecha.toString()
                            });
                            break;
                        case ((dir >= 247) && (dir < 292)):
                            marker = new google.maps.Marker({
                                position: Latlng,
                                icon: 'Images/Circle_Arrow/7_arrowcircle_blue_W_20x20.png',
                                map: map,
                                labelText: store.data.items[iterRow].raw.Fecha.toString()
                            });
                            break;
                        case ((dir >= 292) && (dir < 338)):
                            marker = new google.maps.Marker({
                                position: Latlng,
                                icon: 'Images/Circle_Arrow/8_arrowcircle_blue_NW_20x20.png',
                                map: map,
                                labelText: store.data.items[iterRow].raw.Fecha.toString()
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
                                          '        <td><b>Latitud:</b></td>' +
                                          '       <td><pre>     </pre></td>' +
                                          '        <td>' + arrayPositions[i].Latitud + '</td>' +
                                      '</tr>' +
                                      '<tr>' +
                                          '        <td><b>Longitud:</b></td>' +
                                          '       <td><pre>     </pre></td>' +
                                          '        <td>' + arrayPositions[i].Longitud + '</td>' +
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

            Ext.Ajax.request({
                url: 'AjaxPages/AjaxFunctions.aspx?Metodo=ProgressBarCall',
                success: function (response, opts) {

                    var task = new Ext.util.DelayedTask(function () {
                        Ext.Msg.hide();
                    });

                    task.delay(500);

                },
                failure: function (response, opts) {
                    Ext.Msg.hide();
                }
            });

            if (rowCount > 0) {
                map.setCenter(markers[markers.length - 1].position);
            }
            else {
                alert('No se registran posiciones.');
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
                    Fecha: store.data.items[iterRow].raw.FechaHoraCreacion.toString(),
                    TextFechaCreacion: store.data.items[iterRow].raw.TextFechaCreacion,
                    Patente: store.data.items[iterRow].raw.PatenteTracto,
                    Velocidad: store.data.items[iterRow].raw.Velocidad,
                    Latitud: lat,
                    Longitud: lon,
                    LatLng: Latlng,
                    Descripcion: store.data.items[iterRow].raw.DescripcionAlerta
                });

                switch (true) {
                    case (descrip == 'CRUCE GEOCERCA PARA INGRESAR A LOCAL' || descrip == 'LLEGADA A DESTINO'):
                        marker = new google.maps.Marker({
                            position: Latlng,
                            icon: 'Images/finishflag_24x24.png',
                            map: map,
                            labelText: store.data.items[iterRow].raw.FechaHoraCreacion.toString()
                        });
                        break;
                    default:
                        marker = new google.maps.Marker({
                            position: Latlng,
                            icon: 'Images/alert_orange_22x22.png',
                            map: map,
                            labelText: store.data.items[iterRow].raw.FechaHoraCreacion.toString()
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
                    var fec = this.labelText;

                    for (i = 0; i < arrayAlerts.length; i++) {
                        if (arrayAlerts[i].Fecha.toString() == fec.toString() & arrayAlerts[i].LatLng.toString() == latLng.toString()) {

                            var contentString =

                                '<br>' +
                                    '<table>' +
                                      '<tr>' +
                                          '       <td><b>Fecha</b></td>' +
                                          '       <td><pre>     </pre></td>' +
                                          '       <td>' + arrayAlerts[i].TextFechaCreacion + '</td>' +
                                      '</tr>' +
                                      '<tr>' +
                                          '        <td><b>Patente:</b></td>' +
                                          '       <td><pre>     </pre></td>' +
                                          '        <td>' + arrayAlerts[i].Patente + '</td>' +
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

            //var colorZone = "#7f7fff";
            var arrayColors = ['#0000ff', '#66cd00', '#ff4040', '#98f5ff', '#bf3eff', '#ff7f24', '#6495ed', '#ff1493', '#76ee00', '#caff70',
                               '#c1ffc1', '#97ffff', '#ffb90f', '#228b22', '#ffbbff', '#40e0d0', '#ffe7ba', '#ffff00', '#cd8c95', '#bdb76b']

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

                            Ext.Ajax.request({
                                url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonesInsideZona',
                                params: {
                                    IdZona: idZona
                                },
                                success: function (data2, success) {
                                    if (data2 != null) {
                                        data2 = Ext.decode(data2.responseText);

                                        var colorZone = "#7f7fff";

                                        if (data.idTipoZona == 3) {
                                            colorZone = "#FF0000";
                                        }
                                        else {
                                            if (data2 >= 1) {

                                                colorZone = arrayColors[stackedZones];

                                                stackedZones = stackedZones + 1;
                                                if (stackedZones >= 20) {
                                                    stackedZones = 0;
                                                }
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
                                            map: map
                                        });
                                        polygonGrid.label.bindTo('text', polygonGrid.layer, 'labelText');
                                        polygonGrid.layer.setMap(map);
                                        geoLayer.push(polygonGrid);

                                    }
                                }
                            })

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

        function FiltrarPatentes() {
            var transportista = Ext.getCmp('comboFiltroTransportista').getValue();

            var store = Ext.getCmp('comboFiltroPatente').store;
            store.load({
                params: {
                    transportista: transportista
                },
                callback: function (r, options, success) {
                    if (success) {
                        Ext.getCmp("comboFiltroPatente").setValue("Todas");
                    }
                }

            });
        }

        var renderEstadoViaje = function (value, meta) {
            /*{
              if (value == 'Cerrado por Sistema' || value == 'Cerrado manual') {
              meta.tdCls = 'red-cell';
              return value;
            }
            else {
              meta.tdCls = 'blue-cell';
              return value;
            }
            }
            */

            switch (value) {
                case "Cerrado por Sistema":
                    meta.tdCls = 'red-cell';
                    return value;
                    break;
                case "Cerrado manual":
                    meta.tdCls = 'red-cell';
                    return value;
                    break;
                case "Cerrado por segundo viaje":
                    meta.tdCls = 'red-cell';
                    return value;
                    break;
                case "Finalizado":
                    meta.tdCls = 'green-cell';
                    return value;
                    break;
                case "Programado":
                    return value;
                    break;
                default:
                    meta.tdCls = 'blue-cell';
                    return value;
                    break;
            }

        };

        var renderCantidadAlertas = function (value, meta) {
            {
                if (value >= 1) {
                    meta.tdCls = 'red-cell';
                    return value;
                }
                else {
                    return value;
                }
            }
        };

        var renderIconAlertas = function (val) {
            if (val == 0) {
                return '<img data-qtip="Viaje sin alertas." src="Images/dot_green_18x18.gif">';

            }
            if (val > 0) {
                return '<img data-qtip="Viaje con alertas." src="Images/dot_red_18x18.gif">';

            }

        };

        var renderIconCallCenter = function (val) {
            if (val == 0) {
                return '<img data-qtip="No existen alertas sin gestionar." src="Images/flag_white_18x18.png">';

            }
            if (val > 0) {
                return '<img data-qtip="Existen alertas sin gestionar." src="Images/flag_red_18x18.png">';

            }

        };

        var renderHorasMinutos = function (value, meta) {
            if (value != '' || value != null || value != '0') {
                if (value > 0 && value <= 360) {
                    meta.tdCls = 'green-cell';
                }
                if (value > 360 && value <= 480) {
                    meta.tdCls = 'orange-cell';
                }
                if (value > 480) {
                    meta.tdCls = 'red-cell';
                }

                var hrs = Math.floor(value / 60);
                value = value % 60;
                if (value < 10) value = "0" + value;
                return hrs + ":" + value + ' hrs';
            }
            else {
                return '0';
            }
        };

        function ShowDetalleViaje(row) {

            var nroTransporte = row.data.NroTransporte;
            var destino = row.data.CodigoDestino;

            var fecAsignacion = row.data.FHAsignacion;
            var fecSalidaOrigen = row.data.FHSalidaOrigen;
            var fecLlegadaDestino = row.data.FHLlegadaDestino;
            var fecSalidaDestino = row.data.FHSalidaDestino;

            var nombreCliente = row.data.NombreCliente;

            Ext.getCmp('numberNroTransporte').setValue(nroTransporte);
            Ext.getCmp('textLocalDestino').setValue(nombreCliente);
            Ext.getCmp('textFechaAsignacion').setValue(fecAsignacion);
            Ext.getCmp('textFechaAsignacion').setValue(fecAsignacion);
            Ext.getCmp('textFechaSalidaOrigen').setValue(fecSalidaOrigen);
            Ext.getCmp('textFechaLlegadaDestino').setValue(fecLlegadaDestino);
            Ext.getCmp('textFechaSalidaDestino').setValue(fecSalidaDestino);

            var storeGestionCallCenter = Ext.getCmp('gridPanelGestionCallCenter').store;
            var storeAlertasPorGestionarCallCenter = Ext.getCmp('gridPanelAlertasPorGestionarCallCenter').store;

            storeGestionCallCenter.load({
                params: {
                    nroTransporte: nroTransporte,
                    codLocal: destino
                },
                callback: function (r, options, success) {
                    if (success) {
                        storeAlertasPorGestionarCallCenter.load({
                            params: {
                                nroTransporte: nroTransporte
                            }
                        });
                    }
                }
            });

            Ext.getCmp("winDetalleViaje").show();

        }

        /*
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
        */

        function CerrarViaje(row) {

            var estadoViaje = row.data.EstadoViaje;

            if (estadoViaje.indexOf("En Ruta") == -1) {
                alert('El viaje debe estar en ruta para poder ser cerrado.');
                return;
            }
            /*
            if (estadoViaje != "En Ruta")
            {
                alert('El viaje debe estar en ruta para poder ser cerrado.');
                return;
            }
            */
            if (!confirm("El viaje seleccionado será cerrado. ¿Desea continuar?")) {
                return;
            }

            var nroTransporte = row.data.NroTransporte;
            var origen = row.data.CodigoOrigen;
            var destino = row.data.CodigoDestino;
            var estadoViaje = row.data.EstadoViaje;
            var patenteTracto = row.data.PatenteTracto;
            var patenteTrailer = row.data.PatenteTrailer;
            var FechaHoraCreacion = row.data.FechaHoraCreacion;
            var FHSalidaOrigen = row.data.FHSalidaOrigen;
            var FHLlegadaDestino = row.data.FHLlegadaDestino;
            var FHCierreSistema = row.data.FHCierreSistema;
            //var destino = row.data.NombreCliente;

            var estadoLat = row.data.EstadoLat;
            var estadoLon = row.data.EstadoLon;
            var destinoLat = row.data.DestinoLat;
            var destinoLon = row.data.DestinoLon;

            Ext.Ajax.request({
                url: 'AjaxPages/AjaxViajes.aspx?Metodo=CierreManual',
                params: {
                    'NroTransporte': nroTransporte,
                    'CodLocal': destino,
                    'PatenteTracto': patenteTracto,
                    'PatenteTrailer': patenteTrailer,
                    'EstadoLat': estadoLat,
                    'EstadoLon': estadoLon
                },
                success: function (msg, success) {

                    //alert(msg.responseText);
                    Buscar();
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
