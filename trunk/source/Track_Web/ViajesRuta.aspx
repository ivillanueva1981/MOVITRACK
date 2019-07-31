<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ViajesRuta.aspx.cs" Inherits="Track_Web.ViajesRuta" %>

<asp:Content ID="Content1" ContentPlaceHolderID="Title" runat="server">
    AltoTrack Platform 
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
        var trafficLayer = new google.maps.TrafficLayer();
        var infowindow = new google.maps.InfoWindow();
        var arrayHouses = new Array();
        var stackedZones = 0;

        Ext.onReady(function () {

            Ext.QuickTips.init();
            Ext.Ajax.timeout = 600000;
            Ext.override(Ext.form.Basic, { timeout: Ext.Ajax.timeout / 1000 });
            Ext.override(Ext.data.proxy.Server, { timeout: Ext.Ajax.timeout });
            Ext.override(Ext.data.Connection, { timeout: Ext.Ajax.timeout });

            Ext.Ajax.request({
                url: 'AjaxPages/AjaxLogin.aspx?Metodo=GetPerfilSession',
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
                            Ext.getCmp("textFiltroOrdenServicio").setDisabled(true);
                            
                            Ext.getCmp("textFiltroNroContenedor").setDisabled(true);
                            Ext.getCmp("textFiltroNombreConductor").setDisabled(true);
                            
                            Ext.getCmp("dateDesde").setDisabled(true);
                            Ext.getCmp("dateHasta").setDisabled(true);
                            Ext.getCmp("comboFiltroPatente").setDisabled(true);
                            Ext.getCmp("comboFiltroEstadoViaje").setDisabled(true);
                            Ext.getCmp("comboFiltroTipoEtis").setDisabled(true);
                        }
                        else {
                            Ext.getCmp("textFiltroNroTransporte").setDisabled(true);
                            Ext.getCmp("textFiltroOrdenServicio").setDisabled(false);
                            Ext.getCmp("textFiltroNroContenedor").setDisabled(false);
                            Ext.getCmp("textFiltroNombreConductor").setDisabled(false);
                            Ext.getCmp("dateDesde").setDisabled(false);
                            Ext.getCmp("dateHasta").setDisabled(false);
                            Ext.getCmp("comboFiltroPatente").setDisabled(false);
                            Ext.getCmp("comboFiltroEstadoViaje").setDisabled(false);
                            Ext.getCmp('textFiltroNroTransporte').reset();
                            Ext.getCmp("comboFiltroTipoEtis").setDisabled(false);
                        }
                    }
                }
            });

            var dateDesde = new Ext.form.DateField({
                id: 'dateDesde',
                fieldLabel: 'Desde',
                labelWidth: 110,
                allowBlank: false,
                anchor: '99%',
                format: 'd-m-Y',
                editable: false,
                value: new Date(),
                maxValue: new Date(),
                style: {
                    marginLeft: '5px'
                },
                disabled: false
            });

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
                disabled: false
            });

            dateDesde.on('change', function () {
                var _desde = Ext.getCmp('dateDesde');
                var _hasta = Ext.getCmp('dateHasta');

                _hasta.setMinValue(_desde.getValue());
                _hasta.setMaxValue(Ext.Date.add(_desde.getValue(), Ext.Date.DAY, 60));
                _hasta.validate();
                //FiltrarViajes();
            });

            dateHasta.on('change', function () {
                var _desde = Ext.getCmp('dateDesde');
                var _hasta = Ext.getCmp('dateHasta');

                _desde.setMinValue(Ext.Date.add(_hasta.getValue(), Ext.Date.DAY, -60));
                //_desde.setMaxValue(_hasta.getValue());
                _desde.validate();
                //FiltrarViajes();
            });

            Ext.getCmp('dateDesde').setMinValue(Ext.Date.add(Ext.getCmp('dateHasta').getValue(), Ext.Date.DAY, -60));
            Ext.getCmp('dateHasta').setMaxValue(Ext.Date.add(Ext.getCmp('dateDesde').getValue(), Ext.Date.DAY, 60));

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

            var textFiltroOrdenServicio = new Ext.form.TextField({
                id: 'textFiltroOrdenServicio',
                fieldLabel: 'OS',
                labelWidth: 80,
                allowBlank: true,
                anchor: '99%',
                maxLength: 20,
                style: {
                    marginTop: '5px',
                    marginLeft: '5px'
                },
                disabled: false

            });

            var textFiltroNroContenedor = new Ext.form.TextField({
                id: 'textFiltroNroContenedor',
                fieldLabel: 'Contenedor',
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

            var textFiltroNombreConductor = new Ext.form.TextField({
                id: 'textFiltroNombreConductor',
                fieldLabel: 'Conductor',
                labelWidth: 80,
                allowBlank: true,
                anchor: '99%',
                maxLength: 20,
                style: {
                    marginTop: '5px',
                    marginLeft: '5px'
                },
                disabled: false
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
                    marginLeft: '5px'
                },
                disabled: false
            });

            storeFiltroTipoEtis.load({
                callback: function (r, options, success) {
                    if (success) {
                        comboFiltroTipoEtis.setValue('Todas');
                    }
                }
            })

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
                forceSelection: true,
                store: storeFiltroPatente,
                valueField: 'Patente',
                displayField: 'Patente',
                queryMode: 'local',
                anchor: '99%',
                labelWidth: 80,
                style: {
                    marginTop: '5px',
                    marginLeft: '5px'
                },
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                editable: true,
                forceSelection: true,
                disabled: false
            });

            var storeFiltroEstadoViaje = new Ext.data.JsonStore({
                fields: ['EstadoViaje'],
                data: [{ "EstadoViaje": "Todos" },
                        { "EstadoViaje": "Asignado" },
                        { "EstadoViaje": "En Ruta" },
                        { "EstadoViaje": "En Destino" },
                        { "EstadoViaje": "Finalizado" },
                        { "EstadoViaje": "Cerrado por Sistema" }
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
                labelWidth: 110,
                editable: false,
                style: {
                    marginTop: '5px',
                    marginLeft: '5px'
                },
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                forceSelection: true,
                disabled: false
            });

            Ext.getCmp('comboFiltroEstadoViaje').setValue('Todos');

            var storeFiltroProveedorGPS = new Ext.data.JsonStore({
                fields: ['ProveedorGPS'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetProveedoresGPS&Todos=True',
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var chkMostrarZonas = new Ext.form.Checkbox({
                id: 'chkMostrarZonas',
                fieldLabel: 'Mostrar Zonas',
                labelWidth: 80,
                minWidth: 105,
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
                minWidth: 130,
                checked: true,
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

            var chkMostrarTrafico = new Ext.form.Checkbox({
                id: 'chkMostrarTrafico',
                fieldLabel: 'Mostrar tráfico',
                minWidth: 115,
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
                    FiltrarViajes();
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

                            var desde = Ext.getCmp('dateDesde').getRawValue();
                            var hasta = Ext.getCmp('dateHasta').getRawValue();
                            var nroTransporte = Ext.getCmp('textFiltroNroTransporte').getRawValue();
                            var nroOS = Ext.getCmp('textFiltroOrdenServicio').getRawValue();
                            
                            var nroContenedor = Ext.getCmp('textFiltroNroContenedor').getRawValue();
                            
                            var tipoEtis = Ext.getCmp('comboFiltroTipoEtis').getValue();
                            var patente = Ext.getCmp('comboFiltroPatente').getValue();
                            var estadoViaje = Ext.getCmp('comboFiltroEstadoViaje').getValue();
                            var nombreConductor = Ext.getCmp('textFiltroNombreConductor').getValue();
                            

                            var mapForm = document.createElement("form");
                            mapForm.target = "ToExcel";
                            mapForm.method = "POST"; // or "post" if appropriate
                            mapForm.action = 'ViajesRuta.aspx?Metodo=ExportExcel';

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

                            var _nombreConductor = document.createElement("input");
                            _nombreConductor.type = "text";
                            _nombreConductor.name = "nombreConductor";
                            _nombreConductor.value = nombreConductor;
                            mapForm.appendChild(_nombreConductor);

                            document.body.appendChild(mapForm);
                            mapForm.submit();

                        }
                    }
                }
            };

            var toolbarViajesRuta = Ext.create('Ext.toolbar.Toolbar', {
                id: 'toolbarViajesRuta',
                height: 150,
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
                    items: [dateDesde, comboFiltroEstadoViaje, comboFiltroTipoEtis, textFiltroNroContenedor]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.5,
                    items: [dateHasta, comboFiltroPatente, textFiltroNombreConductor]
                }]
            });

            var storeViajesRuta = new Ext.data.JsonStore({
                autoLoad: false,
                fields: ['NroTransporte',
                          'NumeroOrdenServicio',
                          'NombreCliente',
                          'NumeroContenedor',
                          'FechaHoraPresentacion',
                          'NombreChofer',
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
                          'NombreConductor',
                          'TelefonoConductor',
                          'NombreTerminalGestionServicio'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxViajes.aspx?Metodo=GetViajesHistoricos',
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
                                    Ext.getCmp("comboFiltroPatente").setValue("Todas");
                                    FiltrarPatentes();

                                }
                            }
                        })

                    }
                }
            })

            var gridPanelViajesRuta = Ext.create('Ext.grid.Panel', {
                id: 'gridPanelViajesRuta',
                title: 'Viajes',
                store: storeViajesRuta,
                anchor: '100% 70%',
                columnLines: true,
                tbar: toolbarViajesRuta,
                buttons: [chkMostrarZonas, chkMostrarLabels, chkMostrarTrafico, btnExportar, btnActualizar],
                scroll: false,
                viewConfig: {
                    style: { overflow: 'auto', overflowX: 'hidden' }
                },
                columns: [
                              { text: 'Guía', sortable: true, width: 65, dataIndex: 'NroTransporte' },
                              { text: 'Fecha', sortable: true, width: 70, dataIndex: 'FechaHoraPresentacion', renderer: Ext.util.Format.dateRenderer('d-m-Y') },
                              { text: 'Patente', sortable: true, width: 56, dataIndex: 'PatenteTracto' },
                              { text: 'Transportista', sortable: true, width: 90, dataIndex: 'Transportista' },
                              { text: 'Conductor', sortable: true, width: 90, dataIndex: 'NombreConductor' },
                              { text: 'Cliente', sortable: true, flex: 1, dataIndex: 'NombreCliente' },
                              { text: 'Alertas', sortable: true, width: 50, dataIndex: 'CantidadAlertas', renderer: renderCantidadAlertas },
                              { text: 'Estado', sortable: true, flex: 1, dataIndex: 'EstadoViaje', renderer: renderEstadoViaje }

                ],
                plugins: [{
                    ptype: 'rowexpander',
                    rowBodyTpl: [
                                '<br>',
                                  '<table>',
                                    '<tr>',
                                        '       <td align><b>&nbsp;&nbsp;Alerta</b></td>',
                                        '       <td><pre>     </pre></td>',
                                        '       <td align = center><b>Cantidad</b></td>',
                                        '       <td><pre>     </pre></td>',
                                        '       <td><pre>     </pre></td>',
                                        '       <td align><b>Fecha Asignación:</b></td>',
                                        '       <td><pre>     </pre></td>',
                                        '       <td align = center>{FHAsignacion}</td>',
                                    '</tr>',
                                    '<tr>',
                                        '       <td><pre>     </pre></td>',
                                        '       <td><pre>     </pre></td>',
                                        '       <td><pre>     </pre></td>',
                                        '       <td><pre>     </pre></td>',
                                        '       <td><pre>     </pre></td>',
                                        '       <td align><b>Salida Origen:</b></td>',
                                        '       <td><pre>     </pre></td>',
                                        '       <td align = center>{FHSalidaOrigen}</td>',
                                    '</tr>',
                                    '<tr>',
                                        '        <td>&nbsp;&nbsp;Detención:</td>',
                                        '       <td><pre>     </pre></td>',
                                        '        <td align = center> {CantidadDetencion} </td>',
                                        '        <td><pre>     </pre></td>',
                                        '       <td><pre>     </pre></td>',
                                        '        <td><b>Llegada Destino:<b></td>',
                                        '       <td><pre>     </pre></td>',
                                        '        <td align = center> {FHLlegadaDestino} </td>',
                                    '</tr>',
                                    '<tr>',
                                        '        <td>&nbsp;&nbsp;Pérdida Señal:</td>',
                                        '       <td><pre>     </pre></td>',
                                        '        <td align = center> {CantidadPerdidaSenal} </td>',
                                        '        <td><pre>     </pre></td>',
                                        '       <td><pre>     </pre></td>',
                                        '        <td><b>Salida Destino:<b></td>',
                                        '       <td><pre>     </pre></td>',
                                        '        <td align = center> {FHSalidaDestino} </td>',
                                    '</tr>',
                                  '</table>',
                                '<br>'
                    ]
                }],
                listeners: {
                    select: function (sm, row, rec) {

                        Ext.Msg.wait('Espere por favor...', 'Generando ruta');

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

                        var estadoLat = row.data.EstadoLat;
                        var estadoLon = row.data.EstadoLon;
                        var destinoLat = row.data.DestinoLat;
                        var destinoLon = row.data.DestinoLon;

                        var nombreConductor = row.data.NombreConductor;
                        var telefonoConductor = row.data.TelefonoConductor;

                        ClearMap();
                        arrayPositions.splice(0, arrayPositions.length);
                        arrayAlerts.splice(0, arrayAlerts.length);
                        eraseHouses();

                        GetPosiciones(origen, destino, patenteTracto, patenteTrailer, FechaHoraCreacion, FHSalidaOrigen, FHLlegadaDestino, FHCierreSistema, nroTransporte, destino, estadoViaje, nombreConductor, telefonoConductor)
                        GetAlertasRuta(nroTransporte, destino, estadoViaje, nombreConductor, telefonoConductor);

                        if (nroTransporte > 0) {
                            FindPoints(nroTransporte);
                        }

                        if (estadoViaje == 'En Ruta' || estadoViaje == 'RUTA') {
                            CalculateDistanceTime(estadoLat, estadoLon, destinoLat, destinoLon);
                        }
                        else {
                            Ext.getCmp('winDistanciaTiempo').hide();
                        }

                        Ext.Ajax.request({
                            url: 'AjaxPages/AjaxFunctions.aspx?Metodo=ProgressBarCall',
                            success: function (response, opts) {

                                var task = new Ext.util.DelayedTask(function () {
                                    Ext.Msg.hide();
                                });

                                task.delay(100);

                            },
                            failure: function (response, opts) {
                                Ext.Msg.hide();
                            }
                        });

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

                   // map.setCenter(startPoint);

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
                          'Temp1',
                          'TiempoDetenido'],
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
                title: 'Alertas',
                //hideCollapseTool: true,
                store: storeAlertasRuta,
                anchor: '100% 30%',
                columnLines: true,
                scroll: false,
                viewConfig: {
                    style: { overflow: 'auto', overflowX: 'hidden' }
                },
                columns: [
                              { text: 'Fecha Inicio', sortable: true, width: 110, dataIndex: 'FechaInicioAlerta', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                              { text: 'Fecha Fin', sortable: true, width: 110, dataIndex: 'FechaHoraCreacion', renderer: Ext.util.Format.dateRenderer('d-m-Y H:i') },
                              { text: 'Descripción', sortable: true, flex: 1, dataIndex: 'DescripcionAlerta' }
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
                                            '<tr>' +
                                              '        <td><b>Tiempo detenido:</b></td>' +
                                              '       <td><pre>     </pre></td>' +
                                              '        <td>' + row.data.TiempoDetenido + ' minuto(s)' + '</td>' +
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
                width: 650,
                minWidth: 400,
                maxWidth: viewWidth / 1.5,
                layout: 'anchor',
                split: true,
                collapsible: true,
                hideCollapseTool: true,
                items: [gridPanelViajesRuta, gridPanelAlertasRuta]
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
                Ext.getCmp('winDistanciaTiempo').setPosition(Ext.getBody().getViewSize().width - 220, 50, true)

            });

        });

    </script>

    <script type="text/javascript">

        var zoneLabels = new Array();

        Ext.onReady(function () {
            GeneraMapa("dvMap", true);
            /*
            var trafficLayer = new google.maps.TrafficLayer();
            trafficLayer.setMap(map);
            */
        });

        function FiltrarViajes() {

            var nroTransporte = Ext.getCmp('textFiltroNroTransporte').getValue();
            var nroOS = Ext.getCmp('textFiltroOrdenServicio').getValue();
            
            if (Ext.getCmp("chkNroTransporte").getValue() == true && nroTransporte == "") {
                return;
            }

            ClearMap();
            arrayPositions.splice(0, arrayPositions.length);
            arrayAlerts.splice(0, arrayAlerts.length);
            eraseHouses();

            for (var i = 0; i < geoLayer.length; i++) {
                geoLayer[i].layer.setMap(null);
                geoLayer[i].label.setMap(null);
                geoLayer.splice(i, 1);
            }

            Ext.getCmp('winDistanciaTiempo').hide();

            Ext.getCmp("gridPanelViajesRuta").getStore().removeAll();
            Ext.getCmp("gridPanelAlertasRuta").getStore().removeAll()

            var desde = Ext.getCmp('dateDesde').getValue();
            var hasta = Ext.getCmp('dateHasta').getValue();
            var nroTransporte = Ext.getCmp('textFiltroNroTransporte').getValue();
            var nroContenedor = Ext.getCmp('textFiltroNroContenedor').getValue();
            var nombreConductor = Ext.getCmp('textFiltroNombreConductor').getValue();
            
            var tipoEtis = Ext.getCmp('comboFiltroTipoEtis').getValue();
            var patente = Ext.getCmp('comboFiltroPatente').getValue();
            var estadoViaje = Ext.getCmp('comboFiltroEstadoViaje').getValue();

            switch (estadoViaje) {
                case "Finalizado":
                    estadoViaje = "EnLocal-P";
                    break;
                case "En Destino":
                    estadoViaje = "EnLocal-R";
                    break;
                case "En Ruta":
                    estadoViaje = "RUTA";
                    break;
                case "Asignado":
                    estadoViaje = "ASIGNADO";
                    break;
                case "Cerrado por Sistema":
                    estadoViaje = "Cerrado por Sistema";
                    break;
                case "Todos":
                    estadoViaje = "Todos";
                    break;
                default:
                    estadoViaje = "Todos";
            }

            var store = Ext.getCmp('gridPanelViajesRuta').store;
            store.load({
                params: {
                    desde: desde,
                    hasta: hasta,
                    nroTransporte: nroTransporte,
                    nroOS: nroOS,
                    nroContenedor: nroContenedor,
                    tipoEtis: tipoEtis,
                    patente: patente,
                    estadoViaje: estadoViaje,
                    nombreConductor: nombreConductor
                },
                callback: function (r, options, success) {
                    if (!success) {

                    }
                }
            });
        }

        function GetAlertasRuta(nroTransporte, destino, estadoViaje, nombreConductor, telefonoConductor) {

            var store = Ext.getCmp('gridPanelAlertasRuta').store;
            store.load({
                params: {
                    nroTransporte: nroTransporte,
                    destino: destino,
                    estadoViaje: estadoViaje
                },
                callback: function (r, options, success) {
                    if (!success) {
                        /*Ext.MessageBox.show({
                          title: 'Error',
                          msg: 'Se ha producido un error. 2',
                          buttons: Ext.MessageBox.OK
                        });*/
                    }
                    else {
                        MuestraAlertasViaje();
                    }
                }
            });
        }

        function GetPosiciones(origen, destino, patenteTracto, patenteTrailer, fechaHoraCreacion, fechaHoraSalidaOrigen, fechaHoraLlegadaDestino, fechaHoraCierreSistema, nroTransporte, destino, estadoViaje, nombreConductor, telefonoConductor) {

            Ext.getCmp('gridPosicionesRuta').store.removeAll();

            var store = Ext.getCmp('gridPosicionesRuta').store;
            var storeZone = Ext.getCmp('gridZonasToDraw').store;

            var fec;

            if (estadoViaje == 'Finalizado') {
                fec = fechaHoraLlegadaDestino;
            }
            if (estadoViaje == 'Cerrado por Sistema') {
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

                                    MuestraRutaViaje(nombreConductor, telefonoConductor);

                                    var store = Ext.getCmp('gridZonasToDraw').getStore();
                                    for (var i = 0; i < store.count() ; i++) {
                                        DrawZone(store.getAt(i).data.IdZona);
                                    }

                                    DrawZone(origen);
                                    var storeViajes = Ext.getCmp('gridPanelViajesRuta').store;

                                    for (var i = 0; i < storeViajes.count() ; i++) {
                                        if (storeViajes.getAt(i).data.NroTransporte == nroTransporte) {
                                            DrawZone(storeViajes.getAt(i).data.CodigoDestino);
                                            DrawHouse(storeViajes.getAt(i).data.CodigoDestino, storeViajes.getAt(i).data.DestinoLat, storeViajes.getAt(i).data.DestinoLon, storeViajes.getAt(i).data.EstadoViaje);
                                        }
                                    }

                                }
                            }

                        });

                    }
                }
            });

        }

        function MuestraRutaViaje(nombreConductor, telefonoConductor) {

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
                    NombreConductor: nombreConductor,
                    TelefonoConductor: telefonoConductor,
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
                                            '        <td><b>Nombre conductor:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + arrayPositions[i].NombreConductor + '</td>' +
                                        '</tr>' +
                                        '<tr>' +
                                            '        <td><b>Teléfono conductor:</b></td>' +
                                            '       <td><pre>     </pre></td>' +
                                            '        <td>' + arrayPositions[i].TelefonoConductor + '</td>' +
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
                    Fecha: store.data.items[iterRow].raw.FechaHoraCreacion.toString(),
                    Patente: store.data.items[iterRow].raw.PatenteTracto,
                    TextFechaCreacion: store.data.items[iterRow].raw.TextFechaCreacion,
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
                                          '<tr>' +
                                              '        <td><b>Tiempo detenido:</b></td>' +
                                              '       <td><pre>     </pre></td>' +
                                              '        <td>' + arrayAlerts[i].TiempoDetenido + ' minuto(s)' + '</td>' +
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
                    alert('Se ha producido un error. 3');
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
            while (i--) {
                //GetDetalleAreaSeleccionada
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

        function FiltrarPatentes() {
            var transportista = Ext.getCmp('comboFiltroTransportista').getValue();

            var store = Ext.getCmp('comboFiltroPatente').store;
            store.load({
                params: {
                    transportista: transportista
                }
            });
        }

        var renderEstadoViaje = function (value, meta) {
            {
                if (value == 'Cerrado por Sistema' || value == 'Cerrado manual' || value == 'Cerrado por segundo viaje') {
                    meta.tdCls = 'red-cell';
                    return value;
                }
                if (value == 'Finalizado') {
                    meta.tdCls = 'blue-cell';
                    return value;
                }
                else {
                    meta.tdCls = 'black-cell';
                    return value;
                }
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

        function DrawHouse(idZona, latitud, longitud, estadoViaje) {

            var image = new google.maps.MarkerImage("Images/house_blue_24x24.png");

            if (estadoViaje == "Finalizado") {
                image = new google.maps.MarkerImage("Images/house_green_24x24.png");
            }
            if (estadoViaje == "Cerrado por Sistema" || estadoViaje == "Cerrado manual" || estadoViaje == "Cerrado por segundo destino") {
                image = new google.maps.MarkerImage("Images/house_red_24x24.png");
            }

            var point = new google.maps.LatLng(latitud, longitud);

            var markerHouse = new google.maps.Marker({
                position: point,
                icon: image,
                map: map
            });

            arrayHouses.push(markerHouse);
        }

        function eraseHouses() {

            for (i = 0; i < arrayHouses.length; i++) {
                arrayHouses[i].setMap(null);
            }
            arrayHouses = [];
        }

    </script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="Body" runat="server">
    <div id="dvMap"></div>
</asp:Content>

