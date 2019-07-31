<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Config_Zonas_Sitrans.aspx.cs" Inherits="Track_Web.Config_Zonas_Sitrans" %>

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
        var _editingCliente = false;
        var geoLayer = new Array();
        var geoLayerCercana = new Array();
        var geoLayerZonaCliente = new Array();
        var viewIdZona = '';
        var viewIdTipoZona = '';
        var radius = 300;
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

            var numberIdZona = new Ext.form.TextField({
                fieldLabel: 'Id Zona',
                id: 'numberIdZona',
                labelWidth: 50,
                anchor: '99%',
                disabled: true
            });

            var textNombre = new Ext.form.TextField({
                fieldLabel: 'Nombre',
                id: 'textNombre',
                allowBlank: false,
                labelWidth: 50,
                anchor: '99%',
                style: {
                    marginLeft: '5px'
                },
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
                labelWidth: 50,
                allowBlank: false,
                store: storeTipoZona,
                valueField: 'IdTipoZona',
                displayField: 'NombreTipoZona',
                queryMode: 'local',
                anchor: '99%',
                forceSelection: true,
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                editable: false,
                style: {
                    marginLeft: '5px'
                },
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
                              { text: 'Latitud', flex: 1, sortable: true, dataIndex: 'Latitud', editor: { allowBlank: true, maxLength: 50, regex: /^[-''&.,\w\sáéíóúüñÑ]+$/i } },
                              { text: 'Longitud', flex: 1, sortable: true, dataIndex: 'Longitud' }],
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

            var storeClientesAsociados = new Ext.data.JsonStore({
                autoLoad: false,
                fields: ['Id',
                          'CodCliente',
                          'CodTipoCliente',
                          'NombreCliente',
                          'NombreTipoCliente'
                ],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetClientesAsociados',
                    reader: { type: 'json', root: 'Zonas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var storeClientes = new Ext.data.JsonStore({
                autoLoad: false,
                fields: ['Id', 'CodCliente', 'CodTipoCliente', 'NombreTipoCliente', 'NombreCliente'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetClientesAsociados',
                    reader: { type: 'json', root: 'Zonas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var comboClientes = new Ext.form.field.ComboBox({
                id: 'comboClientes',
                fieldLabel: 'Cliente',
                store: storeClientes,
                valueField: 'Id',
                displayField: 'CodCliente',
                queryMode: 'local',
                anchor: '100% 100%',
                enableKeyEvents: true,
                editable: true,
                labelWidth: 50,
                width: 225,
                emptyText: 'Seleccione...',
                listConfig: {
                    loadingText: 'Buscando...',
                    getInnerTpl: function () {
                        return '<a class="search-item">' +
                                          '<span>Cod. Cliente: {CodCliente}</span><br />' +
                                          '<span>Nombre: {NombreCliente}</span><br />' +
                                          '<span>Tipo: {NombreTipoCliente}</span>' +
                                      '</a>';
                    }
                }

            });

            storeClientes.load({
                params: {
                    IdZona: -1,
                    NombreCliente: ''
                }
            });

            var btnAgregarClienteAsociado = {
                id: 'btnAgregarClienteAsociado',
                xtype: 'button',
                height: 25,
                icon: 'Images/add_blue_20x19.png',
                text: 'Agregar',
                handler: function () {
                    AgregarClienteAsociado();
                }
            };

            var btnMantenedorClientes = {
                id: 'btnMantenedorClientes',
                xtype: 'button',
                height: 25,
                text: 'Clientes',
                icon: 'Images/client_black_18x18.png',
                handler: function () {
                    Ext.getCmp("winMantenedorClientes").show();
                }
            };

            var gridPanelClientesAsociados = Ext.create('Ext.grid.Panel', {
                id: 'gridPanelClientesAsociados',
                store: storeClientesAsociados,
                anchor: '100% 90%',
                columnLines: true,
                buttons: [comboClientes, btnAgregarClienteAsociado],
                scroll: false,
                style: {
                    marginTop: '5px'
                },
                viewConfig: {
                    style: { overflow: 'auto', overflowX: 'hidden' }
                },
                columns: [{ text: 'Cod. Cliente', sortable: true, width: 70, dataIndex: 'CodCliente' },
                            { text: 'Nombre', sortable: true, flex: 1, dataIndex: 'NombreCliente' },
                            { text: 'Tipo', sortable: true, width: 70, dataIndex: 'NombreTipoCliente' },
                            {
                                xtype: 'actioncolumn',
                                width: 23,
                                editor: false,
                                items: [
                                  {
                                      icon: 'Images/delete.png',
                                      tooltip: 'Desasociar cliente',
                                      handler: function (grid, rowIndex, colIndex) {
                                          grid.getStore().removeAt(rowIndex);
                                          //var row = grid.getStore().getAt(rowIndex);

                                      }
                                  }]
                            }
                ]
            });

            var btnGuardar = {
                xtype: 'button',
                iconAlign: 'left',
                icon: 'Images/save_black_18x18.png',
                text: 'Guardar',
                height: 25,
                handler: function () {
                    GuardarZona();
                }
            };

            var btnCancelar = {
                id: 'btnCancelar',
                xtype: 'button',
                height: 25,
                iconAlign: 'left',
                icon: 'Images/back_black_18x18.png',
                text: 'Cancelar',
                handler: function () {

                    Ext.getCmp("numberIdZona").reset();
                    Ext.getCmp("textNombre").reset();
                    Ext.getCmp("comboTipoZona").reset();
                    Ext.getCmp("comboClientes").reset();
                    propertieStore.removeAll();
                    storeClientesAsociados.removeAll();
                    ClearMap();
                    EliminarZonaCercana();
                    EliminarZonaClientes();
                    radius = 300;

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
                anchor: '100% 45%',
                //height: 250,
                collapsible: false,
                titleCollapsed: true,
                bodyStyle: 'padding: 5px;',
                hideCollapseTool: true,
                layout: 'column',
                buttons: [btnMantenedorClientes, btnGuardar, btnCancelar],
                layout: 'column',
                items: [{
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [comboTipoZona]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [textNombre]
                }, {
                    xtype: 'fieldset',
                    height: 150,
                    layout: 'anchor',
                    columnWidth: 1,
                    title: 'Clientes asociados',
                    items: [gridPanelClientesAsociados]
                }]

            });

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
                fieldLabel: 'Tipo',
                labelWidth: 40,
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
                fieldLabel: 'Nombre',
                id: 'textFiltroNombre',
                allowBlank: true,
                labelWidth: 50,
                anchor: '99%',
                style: {
                    marginTop: '5px',
                    marginLeft: '5px',
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
                height: 40,
                layout: 'column',
                items: [{
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.5,
                    items: [comboFiltroTipoZona]
                }, {
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 0.5,
                    items: [textFiltroNombre]
                }]
            });

            var storeZonas = new Ext.data.JsonStore({
                autoLoad: false,
                fields: ['IdZona', 'CodSitrans', 'NombreZona', 'IdTipoZona', 'NombreTipoZona', 'Latitud', 'Longitud', 'Radio', 'CantClientesAsociados'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonas',
                    reader: { type: 'json', root: 'Zonas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var storeZonasCercanas = Ext.data.JsonStore({
                autoLoad: false,
                fields: ['IdZona', 'IdPunto', 'Latitud', 'Longitud', 'NombreZona', 'LatZona', 'LonZona'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonasCercanas',
                    reader: { type: 'json', root: 'Zonas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var gridZonasCercana = Ext.create('Ext.grid.Panel', {
                id: 'gridZonasCercana',
                store: storeZonasCercanas,
                columns: [{ text: 'Id Zona', sortable: true, width: 70, hidden: true, dataIndex: 'IdZona' }]
            });

            var storeZonasbyClientes = Ext.data.JsonStore({
                autoLoad: false,
                fields: ['IdZona', 'IdPunto', 'Latitud', 'Longitud', 'NombreZona', 'LatZona', 'LonZona'],
                proxy: new Ext.data.HttpProxy({
                    url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonasByClientes',
                    reader: { type: 'json', root: 'Zonas' },
                    headers: {
                        'Content-type': 'application/json'
                    }
                })
            });

            var gridZonasByClientes = Ext.create('Ext.grid.Panel', {
                id: 'gridZonasByClientes',
                store: storeZonasbyClientes,
                columns: [{ text: 'Id Zona', sortable: true, width: 70, hidden: true, dataIndex: 'IdZona' }]
            });

            var btnExportarZonas = {
                id: 'btnExportarZonas',
                xtype: 'button',
                iconAlign: 'left',
                icon: 'Images/export_black_20x20.png',
                text: 'Exportar Zonas',
                width: 105,
                minWidth: 105,
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
                minWidth: 105,
                height: 26,
                text: 'Mostrar Todas',
                handler: function () {
                    MostrarTodas();
                }
            };

            var btnMostrarZonaZoom = {
                id: 'btnMostrarZonaZoom',
                xtype: 'button',
                disabled: true,
                iconAlign: 'left',
                icon: 'Images/search_black_16x16.png',
                width: 105,
                minWidth: 105,
                height: 26,
                text: 'Zonas Cercanas',
                handler: function () {
                    MostrarZonasCercanas();
                }

            };

            var gridPanelZonas = Ext.create('Ext.grid.Panel', {
                id: 'gridPanelZonas',
                title: 'Zonas',
                //hideCollapseTool: true,
                store: storeZonas,
                anchor: '100% 55%',
                columnLines: true,
                tbar: toolbarZona,
                buttons: [btnExportarZonas, btnMostrarTodas, btnMostrarZonaZoom],
                scroll: false,
                viewConfig: {
                    style: { overflow: 'auto', overflowX: 'hidden' }
                },
                columns: [
                            {
                                text: 'Ver', width: 27, dataIndex: 'IdZona',
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
                              { text: 'Id Zona', sortable: true, width: 70, hidden: true, dataIndex: 'IdZona' },
                              { text: 'Nombre', sortable: true, flex: 1, dataIndex: 'NombreZona' },
                              { text: 'Clientes', sortable: true, width: 50, dataIndex: 'CantClientesAsociados' },
                              { text: 'NombreTipoZona', sortable: true, flex: 1, dataIndex: 'NombreTipoZona', },
                              {
                                  xtype: 'actioncolumn',
                                  width: 40,

                                  items: [{
                                      icon: 'Images/edit.png',
                                      tooltip: 'Editar zona',
                                      handler: function (grid, rowIndex, colIndex) {
                                          var row = grid.getStore().getAt(rowIndex);
                                          var idZona = row.data.IdZona;
                                          var radio = row.data.Radio;

                                          Ext.getCmp("numberIdZona").reset();
                                          Ext.getCmp("textNombre").reset();
                                          Ext.getCmp("comboTipoZona").reset()
                                          propertieStore.removeAll();
                                          storeClientesAsociados.removeAll();

                                          ClearMap();

                                          Ext.getCmp("numberIdZona").setValue(idZona);
                                          Ext.getCmp("textNombre").setValue(row.data.NombreZona);
                                          Ext.getCmp("comboTipoZona").setValue(row.data.IdTipoZona);

                                          storeClientesAsociados.load({
                                              params: {
                                                  IdZona: idZona
                                              }
                                          });

                                          ShowProperties();

                                          GetZona(idZona, radio);
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
                                            Ext.getCmp("comboClientes").reset();
                                            propertieStore.removeAll();
                                            storeClientesAsociados.removeAll();

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

            var textFiltroNombreCliente = new Ext.form.TextField({
                fieldLabel: 'Filtrar Nombre',
                id: 'textFiltroNombreCliente',
                allowBlank: true,
                labelWidth: 85,
                anchor: '99%',
                style: {
                    marginTop: '5px',
                    marginLeft: '5px'
                },
                maxLength: 20,
                enableKeyEvents: true,
                listeners: {
                    'change': {
                        fn: function (a, b, c) {

                            var nombreCliente = Ext.getCmp('textFiltroNombreCliente').getValue();
                            var codigoCliente = Ext.getCmp('textFiltroCodigoCliente').getValue();
                            
                            if (codigoCliente == '' && nombreCliente == '') 
                                Ext.getCmp('btnMostrarZonas').setDisabled(true);
                            else
                                Ext.getCmp('btnMostrarZonas').setDisabled(false);


                            var store = Ext.getCmp('gridPanelClientes').store;
                            store.load({
                                params: {
                                    IdZona: -1,
                                    NombreCliente: nombreCliente,
                                    CodigoCliente: codigoCliente
                                }
                            });

                            
                        }
                    }
                }
            });

            var textFiltroCodigoCliente = new Ext.form.TextField({
                fieldLabel: 'Filtrar Codigo',
                id: 'textFiltroCodigoCliente',
                allowBlank: true,
                labelWidth: 85,
                anchor: '99%',
                style: {
                    marginTop: '5px',
                    marginLeft: '5px'
                },
                maxLength: 100,
                enableKeyEvents: true,
                listeners: {
                    'change': {
                        fn: function (a, b, c) {

                            var nombreCliente = Ext.getCmp('textFiltroNombreCliente').getValue();
                            var codigoCliente = Ext.getCmp('textFiltroCodigoCliente').getValue();

                            var store = Ext.getCmp('gridPanelClientes').store;
                            store.load({
                                params: {
                                    IdZona: -1,
                                    NombreCliente: nombreCliente,
                                    CodigoCliente: codigoCliente
                                }
                            });

                               if (codigoCliente == '' && nombreCliente == '') 
                                Ext.getCmp('btnMostrarZonas').setDisabled(true);
                            else
                                Ext.getCmp('btnMostrarZonas').setDisabled(false);
                        }
                    }
                }
            });

            var toolbarClientes = Ext.create('Ext.toolbar.Toolbar', {
                id: 'toolbarClientes',
                height: 65,
                layout: 'column',
                items: [{
                    xtype: 'container',
                    layout: 'anchor',
                    columnWidth: 1,
                    items: [textFiltroCodigoCliente, textFiltroNombreCliente]
                }]
            });

            var gridPanelClientes = Ext.create('Ext.grid.Panel', {
                id: 'gridPanelClientes',
                store: storeClientes,
                anchor: '100% 90%',
                columnLines: true,
                tbar: toolbarClientes,
                //buttons: [comboClientes, btnAgregarClienteAsociado],
                scroll: false,
                style: {
                    marginTop: '5px'
                },
                viewConfig: {
                    style: { overflow: 'auto', overflowX: 'hidden' }
                },
                columns: [{ text: 'Cod. Cliente', sortable: true, width: 70, dataIndex: 'CodCliente' },
                            { text: 'Nombre', sortable: true, flex: 1, dataIndex: 'NombreCliente' },
                            { text: 'Tipo', sortable: true, width: 70, dataIndex: 'NombreTipoCliente' },
                            {
                                xtype: 'actioncolumn',
                                width: 55,
                                editor: false,
                                items: [
                                    {
                                        icon: 'Images/link_black_16x16.png',
                                        tooltip: 'Asociar cliente',
                                        handler: function (grid, rowIndex, colIndex) {
                                            var row = grid.getStore().getAt(rowIndex);
                                            AgregarClienteAsociadoFromGrid(row);
                                        }
                                    },
                                    {
                                        icon: 'Images/edit.png',
                                        tooltip: 'Editar cliente',
                                        handler: function (grid, rowIndex, colIndex) {
                                            var row = grid.getStore().getAt(rowIndex);

                                            var codCliente = row.data.CodCliente;

                                            Ext.getCmp("codCliente").reset();
                                            Ext.getCmp("comboTipoCliente").reset();
                                            Ext.getCmp("textNombreCliente").reset();

                                            Ext.getCmp("codCliente").setValue(codCliente);
                                            Ext.getCmp("comboTipoCliente").setValue(row.data.CodTipoCliente);
                                            Ext.getCmp("textNombreCliente").setValue(row.data.NombreCliente);

                                            Ext.getCmp("codCliente").setDisabled(true);
                                            Ext.getCmp("comboTipoCliente").setDisabled(true);
                                        }
                                    },
                                    {
                                        icon: 'Images/delete.png',
                                        tooltip: 'Eliminar cliente',
                                        handler: function (grid, rowIndex, colIndex) {
                                            var row = grid.getStore().getAt(rowIndex);
                                            EliminarCliente(row.data.CodCliente, row.data.CodTipoCliente, grid, rowIndex);
                                        }
                                    }]
                            },

                ]
            });

            var codCliente = new Ext.form.TextField({
                id: 'codCliente',
                fieldLabel: 'Cod. Cliente',
                labelWidth: 80,
                maxLength: 10,
                anchor: '99%',
                scroll: false,
                allowBlank: false,
                style: {
                    marginLeft: '5px',
                    marginTop: '5px'
                },
                disabled: false

            });

            var storeTipoClientes = new Ext.data.JsonStore({
                fields: ['CodTipoCliente', 'NombreTipoCliente'],
                data: [{ CodTipoCliente: 1, NombreTipoCliente: 'Puerto' },
                        { CodTipoCliente: 2, NombreTipoCliente: 'Cliente' },
                        { CodTipoCliente: 3, NombreTipoCliente: 'Deposito' },
                        { CodTipoCliente: 4, NombreTipoCliente: 'Terminal' }, ]
            });


            var comboTipoCliente = new Ext.form.field.ComboBox({
                id: 'comboTipoCliente',
                fieldLabel: 'Tipo',
                labelWidth: 50,
                allowBlank: false,
                store: storeTipoClientes,
                valueField: 'CodTipoCliente',
                displayField: 'NombreTipoCliente',
                queryMode: 'local',
                anchor: '99%',
                style: {
                    marginTop: '5px',
                    marginLeft: '5px'
                },
                forceSelection: true,
                emptyText: 'Seleccione...',
                enableKeyEvents: true,
                editable: false

            });

            var textNombreCliente = new Ext.form.TextField({
                id: 'textNombreCliente',
                fieldLabel: 'Nombre',
                allowBlank: false,
                labelWidth: 80,
                anchor: '99%',
                regex: /^[-''&.,_\w\sáéíóúüñÑ\(\)]+$/i,
                regexText: 'Caracteres no válidos.',
                maxLength: 255,
                style: {
                    marginLeft: '5px'
                },
                enableKeyEvents: true
            });

            var btnGuardarCliente = {
                id: 'btnGuardarCliente',
                xtype: 'button',
                iconAlign: 'left',
                icon: 'Images/save_black_18x18.png',
                text: 'Guardar',
                height: 25,
                handler: function () {
                    GuardarCliente();
                }
            };

            var formMantenedorClientes = new Ext.FormPanel({
                id: 'formMantenedorClientes',
                border: false,
                frame: true,
                layout: 'column',
                items: [
                            {
                                xtype: 'container',
                                layout: 'anchor',
                                columnWidth: 0.5,
                                items: [codCliente]
                            }, {
                                xtype: 'container',
                                layout: 'anchor',
                                columnWidth: 0.5,
                                items: [comboTipoCliente]
                            }, {
                                xtype: 'container',
                                layout: 'anchor',
                                columnWidth: 1,
                                items: [textNombreCliente]
                            },
                            {
                                xtype: 'fieldset',
                                height: 255,
                                layout: 'anchor',
                                columnWidth: 1,
                                title: 'Clientes',
                                items: [gridPanelClientes]
                            }
                ]
            });

            var btnSalir = {
                id: 'btnSalir',
                xtype: 'button',
                height: 25,
                iconAlign: 'left',
                icon: 'Images/back_black_20x20.png',
                text: 'Salir',
                handler: function () {
                    //Cancelar();
                    Ext.getCmp("winMantenedorClientes").hide();

                    Ext.getCmp("codCliente").reset();
                    Ext.getCmp("comboTipoCliente").reset();
                    Ext.getCmp("textNombreCliente").reset();

                    Ext.getCmp("textFiltroNombreCliente").reset();

                    Ext.getCmp("codCliente").setDisabled(false);
                    Ext.getCmp("comboTipoCliente").setDisabled(false);
                }
            };


            var btnMostrarZonas = {
                id: 'btnMostrarZonas',
                xtype: 'button',
                disabled: true,
                height: 25,
                iconAlign: 'left',
                icon: 'Images/showmap_gray_16x16.png',
                text: 'Mostrar Zonas',
                handler: function () {

                    var _storeZonasbycli = Ext.getCmp('gridPanelClientes').store;
                    var _listCodClientes;
                    for (i = 0; i < _storeZonasbycli.data.length; i++) {
                        if (_listCodClientes == undefined)
                            _listCodClientes = _storeZonasbycli.data.items[i].data.CodCliente + ';';
                        else if (i == _storeZonasbycli.data.length - 1)
                            _listCodClientes = _listCodClientes + _storeZonasbycli.data.items[i].data.CodCliente;
                        else
                            _listCodClientes +=  _storeZonasbycli.data.items[i].data.CodCliente + ';';
                    }
                    MostrarZonasByCodigosClientes(_listCodClientes);

                    Ext.getCmp("winMantenedorClientes").hide();

                    Ext.getCmp("codCliente").reset();
                    Ext.getCmp("comboTipoCliente").reset();
                    Ext.getCmp("textNombreCliente").reset();

                    Ext.getCmp("textFiltroNombreCliente").reset();

                    Ext.getCmp("codCliente").setDisabled(false);
                    Ext.getCmp("comboTipoCliente").setDisabled(false);
                }
            };


            var winMantenedorClientes = new Ext.Window({
                id: 'winMantenedorClientes',
                title: 'Configuración de clientes',
                width: 400,
                height: 400,
                closeAction: 'hide',
                modal: true,
                items: formMantenedorClientes,
                resizable: false,
                border: false,
                constrain: true,
                buttons: [btnMostrarZonas,btnGuardarCliente, btnSalir]
            });

            var progBar = Ext.create('Ext.MessageBox', {
                id: 'progBar',
                title: 'Espere por favor'
            });

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
            /*
          var viewport = Ext.create('Ext.container.Viewport', {
            layout: 'border',
            items: [topMenu, leftPanel, centerPanel]
          });
          */
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
            google.maps.event.addListener(map, 'zoom_changed', CambiaZoom);
        });

        function CambiaZoom() {
            var _zoom = map.getZoom();
            var btn;
            if (_zoom > 13) {
                Ext.getCmp('btnMostrarZonaZoom').setDisabled(false);
            }
            else {
                Ext.getCmp('btnMostrarZonaZoom').setDisabled(true);
            }
        }

        function MostrarZonasCercanas() {

            var NewMapCenter = map.getCenter();

            var LatitudCentral = NewMapCenter.lat();
            var LongitudCentral = NewMapCenter.lng();

            var _storeZonasCercanas = Ext.getCmp('gridZonasCercana').store;

            _storeZonasCercanas.load({
                params: {
                    lat: LatitudCentral,
                    lon: LongitudCentral
                },
                callback: function (r, options, success) {
                    if (success) {
                        EliminarZonaCercana();
                        var _zonaId = 0;
                        if (_storeZonasCercanas.data.length > 0) {
                            var arr = new Array();

                            for (i = 0; i < _storeZonasCercanas.data.length; i++) {
                                var polygonGridCercana = new Object();

                                if (_zonaId == 0) {
                                    _zonaId = _storeZonasCercanas.data.items[i].data.IdZona;
                                    arr.push(new google.maps.LatLng(_storeZonasCercanas.data.items[i].data.Latitud, _storeZonasCercanas.data.items[i].data.Longitud));
                                }
                                else if (_zonaId == _storeZonasCercanas.data.items[i].data.IdZona) {
                                    arr.push(new google.maps.LatLng(_storeZonasCercanas.data.items[i].data.Latitud, _storeZonasCercanas.data.items[i].data.Longitud));
                                }
                                else if (_zonaId != _storeZonasCercanas.data.items[i].data.IdZona) {
                                    _zonaId = _storeZonasCercanas.data.items[i].data.IdZona;

                                    var colorZone = "#7f7fff";

                                    polygonGridCercana.layer = new google.maps.Polygon({
                                        paths: arr,
                                        strokeColor: "#000000",
                                        strokeWeight: 1,
                                        strokeOpacity: 0.9,
                                        fillColor: colorZone,
                                        fillOpacity: 0.3,
                                        labelText: _storeZonasCercanas.data.items[i - 1].data.NombreZona
                                    });

                                    polygonGridCercana.label = new Label({
                                        position: new google.maps.LatLng(_storeZonasCercanas.data.items[i - 1].data.LatZona, _storeZonasCercanas.data.items[i - 1].data.LonZona),
                                        map: map
                                    });

                                    polygonGridCercana.label.bindTo('text', polygonGridCercana.layer, 'labelText');
                                    polygonGridCercana.layer.setMap(map);

                                    geoLayerCercana.push(polygonGridCercana);

                                    arr = new Array();

                                    arr.push(new google.maps.LatLng(_storeZonasCercanas.data.items[i].data.Latitud, _storeZonasCercanas.data.items[i].data.Longitud));
                                }
                                if (i == _storeZonasCercanas.data.length - 1) {
                                    var colorZone = "#7f7fff";

                                    polygonGridCercana.layer = new google.maps.Polygon({
                                        paths: arr,
                                        strokeColor: "#000000",
                                        strokeWeight: 1,
                                        strokeOpacity: 0.9,
                                        fillColor: colorZone,
                                        fillOpacity: 0.3,
                                        labelText: _storeZonasCercanas.data.items[i].data.NombreZona
                                    });

                                    polygonGridCercana.label = new Label({
                                        position: new google.maps.LatLng(_storeZonasCercanas.data.items[i].data.LatZona, _storeZonasCercanas.data.items[i].data.LonZona),
                                        map: map
                                    });

                                    polygonGridCercana.label.bindTo('text', polygonGridCercana.layer, 'labelText');
                                    polygonGridCercana.layer.setMap(map);

                                    geoLayerCercana.push(polygonGridCercana);
                                }


                            }
                        }
                    }
                }

            });


        }

        function MostrarZonasByCodigosClientes(plistCodigoClientes) {

            var NewMapCenter = map.getCenter();

            var LatitudCentral = NewMapCenter.lat();
            var LongitudCentral = NewMapCenter.lng();

            var _storeZonasCercanas = Ext.getCmp('gridZonasByClientes').store;

            _storeZonasCercanas.load({
                params: {
                    listCodClientes: plistCodigoClientes                    
                },
                callback: function (r, options, success) {
                    if (success) {
                         EliminarZonaClientes();
                        var _zonaId = 0;
                        if (_storeZonasCercanas.data.length > 0) {
                            var arr = new Array();

                            for (i = 0; i < _storeZonasCercanas.data.length; i++) {
                                var polygonGridCercana = new Object();

                                if (_zonaId == 0) {
                                    _zonaId = _storeZonasCercanas.data.items[i].data.IdZona;
                                    arr.push(new google.maps.LatLng(_storeZonasCercanas.data.items[i].data.Latitud, _storeZonasCercanas.data.items[i].data.Longitud));
                                }
                                else if (_zonaId == _storeZonasCercanas.data.items[i].data.IdZona) {
                                    arr.push(new google.maps.LatLng(_storeZonasCercanas.data.items[i].data.Latitud, _storeZonasCercanas.data.items[i].data.Longitud));
                                }
                                else if (_zonaId != _storeZonasCercanas.data.items[i].data.IdZona) {
                                    _zonaId = _storeZonasCercanas.data.items[i].data.IdZona;

                                    var colorZone = "#7f7fff";

                                    polygonGridCercana.layer = new google.maps.Polygon({
                                        paths: arr,
                                        strokeColor: "#000000",
                                        strokeWeight: 1,
                                        strokeOpacity: 0.9,
                                        fillColor: colorZone,
                                        fillOpacity: 0.3,
                                        labelText: _storeZonasCercanas.data.items[i - 1].data.NombreZona
                                    });

                                    polygonGridCercana.label = new Label({
                                        position: new google.maps.LatLng(_storeZonasCercanas.data.items[i - 1].data.LatZona, _storeZonasCercanas.data.items[i - 1].data.LonZona),
                                        map: map
                                    });

                                    polygonGridCercana.label.bindTo('text', polygonGridCercana.layer, 'labelText');
                                    polygonGridCercana.layer.setMap(map);

                                    geoLayerZonaCliente.push(polygonGridCercana);

                                    arr = new Array();

                                    arr.push(new google.maps.LatLng(_storeZonasCercanas.data.items[i].data.Latitud, _storeZonasCercanas.data.items[i].data.Longitud));
                                }

                                if (i == _storeZonasCercanas.data.length - 1) {
                                    var colorZone = "#7f7fff";

                                    polygonGridCercana.layer = new google.maps.Polygon({
                                        paths: arr,
                                        strokeColor: "#000000",
                                        strokeWeight: 1,
                                        strokeOpacity: 0.9,
                                        fillColor: colorZone,
                                        fillOpacity: 0.3,
                                        labelText: _storeZonasCercanas.data.items[i].data.NombreZona
                                    });

                                    polygonGridCercana.label = new Label({
                                        position: new google.maps.LatLng(_storeZonasCercanas.data.items[i].data.LatZona, _storeZonasCercanas.data.items[i].data.LonZona),
                                        map: map
                                    });

                                    polygonGridCercana.label.bindTo('text', polygonGridCercana.layer, 'labelText');
                                    polygonGridCercana.layer.setMap(map);

                                    geoLayerZonaCliente.push(polygonGridCercana);
                                }


                            }
                        }
                    }
                }

            });


        }

        function EliminarZonaCercana() {
            for (var i = geoLayerCercana.length - 1 ; i >= 0; i--) {
                geoLayerCercana[i].layer.setMap(null);
                geoLayerCercana[i].label.setMap(null);
                geoLayerCercana.splice(i, 1);
            }
        }

           function EliminarZonaClientes() {
            for (var i = geoLayerZonaCliente.length - 1 ; i >= 0; i--) {
                geoLayerZonaCliente[i].layer.setMap(null);
                geoLayerZonaCliente[i].label.setMap(null);
                geoLayerZonaCliente.splice(i, 1);
            }
        }
        

        function CheckRow(check, id, centrarMapa) {
            if (check.checked) {

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
                                var colorZone = "#7f7fff";
                                Ext.Ajax.request({
                                    url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetZonesInsideZona',
                                    params: {
                                        IdZona: id
                                    },
                                    success: function (data2, success) {
                                        if (data2 != null) {
                                            data2 = Ext.decode(data2.responseText);

                                            var colorZone = "#7f7fff";

                                            if (data2 >= 1) {

                                                colorZone = arrayColors[stackedZones];

                                                stackedZones = stackedZones + 1;
                                                if (stackedZones >= 20) {
                                                    stackedZones = 0;
                                                }
                                            }

                                            if (data.idTipoZona == 3) {
                                                colorZone = "#FF0000";
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
                                            geoLayer.push(polygonGrid);
                                        }
                                    }
                                })
                            }
                            else
                                if (data.Vertices.length = 1) { //Point

                                    if (data.idTipoZona == 3) {
                                        var colorZone = "#FF0000";
                                    }
                                    else {
                                        var colorZone = "#7f7fff";
                                    }

                                    var Point = new Object();
                                    Point.IdZona = data.IdZona;

                                    var radio;

                                    var _storeZonas = Ext.getCmp('gridPanelZonas').getStore();
                                    for (var i = 0; i < _storeZonas.count() ; i++) {
                                        if (_storeZonas.data.items[i].data.IdZona == id) {
                                            radio = _storeZonas.data.items[i].data.Radio;
                                            break;
                                        }
                                    }

                                    var image = new google.maps.MarkerImage("Images/greymarker_32x32.png");

                                    var center = new google.maps.LatLng(data.Latitud, data.Longitud)

                                    Point.layer = new google.maps.Circle({
                                        position: new google.maps.LatLng(data.Latitud, data.Longitud),
                                        strokeColor: "#000000",
                                        strokeWeight: 1,
                                        strokeOpacity: 0.9,
                                        fillOpacity: 0.3,
                                        center: center,
                                        fillColor: colorZone,
                                        radius: radio,
                                        //icon: image,
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
                    },
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

        function CheckRowMostrarTodas(check, id, centrarMapa) {
            if (check.checked) {

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

                                var colorZone = "#7f7fff";

                                if (data.idTipoZona == 3) {
                                    colorZone = "#FF0000";
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

                                if (centrarMapa == true || centrarMapa == null) {
                                    map.setCenter(new google.maps.LatLng(data.Latitud, data.Longitud));
                                }
                                geoLayer.push(polygonGrid);
                                geoLayer.push(polygonGrid);
                            }
                            else
                                if (data.Vertices.length = 1) { //Point

                                    var colorZone = "#7f7fff";

                                    if (data.idTipoZona == 3) {
                                        colorZone = "#FF0000";
                                    }

                                    var Point = new Object();
                                    Point.IdZona = data.IdZona;

                                    var radio;

                                    var _storeZonas = Ext.getCmp('gridPanelZonas').getStore();
                                    for (var i = 0; i < _storeZonas.count() ; i++) {
                                        if (_storeZonas.data.items[i].data.IdZona == id) {
                                            radio = _storeZonas.data.items[i].data.Radio;
                                            break;
                                        }
                                    }

                                    var image = new google.maps.MarkerImage("Images/greymarker_32x32.png");

                                    var center = new google.maps.LatLng(data.Latitud, data.Longitud)

                                    Point.layer = new google.maps.Circle({
                                        position: new google.maps.LatLng(data.Latitud, data.Longitud),
                                        strokeColor: "#000000",
                                        strokeWeight: 1,
                                        strokeOpacity: 0.9,
                                        fillOpacity: 0.3,
                                        center: center,
                                        fillColor: colorZone,
                                        radius: radio,
                                        //icon: image,
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
                    },
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

                    circle.setMap(null);
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

            if (circle) { circle.setMap(null); }

            if (markers.length == 1) {
                circle = new google.maps.Circle({ strokeColor: "#000000", strokeWeight: 1, strokeOpacity: 0.9, fillColor: colorZone, fillOpacity: 0.3, center: markers[0].getPosition(), editable: true, draggable: true, radius: radius });
                circle.setMap(map);

                circle.bindTo('center', markers[0], 'position');

                google.maps.event.addListener(circle, 'radius_changed', function () {
                    radius = circle.getRadius();
                });
            }

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
        /*
      function ValidarCodCliente() {
        Ext.Ajax.request({
          url: 'AjaxPages/AjaxZonas.aspx?Metodo=ValidarCodCliente',
          params: {
              CodCliente: Ext.getCmp('codCliente').getValue(),
              CodTipoCliente: Ext.getCmp('codTipoCliente').getValue()
          },
          success: function (data, success) {
            if (data != null) {
              data = (data.responseText.toLowerCase() == 'true');
              if (!data) {
                Ext.getCmp('codCliente').markInvalid("El Cod. Cliente del tipo seleccionado ya se encuentra registrado.");
              }
              else {
                Ext.getCmp('codCliente').clearInvalid();
              } 
            }
          },
          failure: function (msg) {
            alert('Se ha producido un error.');
          }
        });
      }
      */
        //Función que obtiene la Zona a Editar
        function GetZona(IdZona, Radio) {

            var colorZone = "#0000FF";

            Ext.Ajax.request({
                url: 'AjaxPages/AjaxZonas.aspx?Metodo=GetVerticesZona',
                params: {
                    IdZona: IdZona
                },
                success: function (data, success) {
                    if (data != null) {
                        data = Ext.decode(data.responseText);
                        DrawZone(data, Radio);

                        if (data.Vertices.length == 1) {
                            map.setZoom(15);
                        }

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
                    else {
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

            for (i = 0; i < countZonas; i++) {
                var idZona = _storeZonas.data.items[i].data.IdZona;

                var objCheck = document.getElementById("viewCheck" + idZona);
                objCheck.checked = true; // Ext.getCmp('chkVerMapa').getValue();
                if (checkedZones.indexOf(idZona) < 0) {
                    CheckRowMostrarTodas(objCheck, idZona, false);
                }
            }

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

        function GuardarZona() {
            var flag = true;
            var message = '';
            var _vertices = new Array();
            var _radio = 0;
            /*
          if (Ext.getCmp('numberIdZona').hasActiveError()) {
            return;
          }
          */
            if (!Ext.getCmp('panelProperties').getForm().isValid()) {
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

            if (markers.length == 1) {
                _radio = radius;
            }

            for (var i = 0; i < markers.length; i++) {
                _vertices.push(markers[i].getPosition().lat() + ';' + markers[i].getPosition().lng());
            }

            var storeClientesAsociados = Ext.getCmp("gridPanelClientesAsociados").store;
            var clientesAsociados = "";

            for (var i = 0; i < storeClientesAsociados.count() ; i++) {
                clientesAsociados = clientesAsociados + storeClientesAsociados.data.items[i].data.Id;

                if (i < storeClientesAsociados.count() - 1) {
                    clientesAsociados = clientesAsociados + ",";
                }
            }

            if (!_editing) {
                //Nueva Zona
                Ext.Ajax.request({
                    url: 'AjaxPages/AjaxZonas.aspx?Metodo=NuevaZona',
                    params: {
                        'NombreZona': Ext.getCmp('textNombre').getValue(),
                        'IdTipoZona': Ext.getCmp('comboTipoZona').getValue(),
                        'ClientesAsociados': clientesAsociados,
                        'Vertices': _vertices,
                        'Radio': _radio
                    },
                    success: function (msg, success) {
                        alert(msg.responseText);

                        if (msg.responseText != 'Ya existe una zona en los puntos seleccionados' && msg.responseText != 'Ya existe una zona con ese Nombre, favor utilice otro') {
                            FiltrarZonas();
                            ClearPoints();
                            ShowProperties();

                            Ext.getCmp("numberIdZona").reset();
                            Ext.getCmp("textNombre").reset();
                            Ext.getCmp("comboTipoZona").reset();
                            Ext.getCmp("comboClientes").reset();
                            propertieStore.removeAll();
                            storeClientesAsociados.removeAll();

                            _editing = false;
                        }
                    },
                    failure: function (msg) {
                        alert('Se ha producido un error.');
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
                        'ClientesAsociados': clientesAsociados,
                        'Vertices': _vertices,
                        'Radio': _radio
                    },
                    success: function (msg, success) {

                        alert(msg.responseText);
                        FiltrarZonas();
                        ClearPoints();
                        ShowProperties();

                        Ext.getCmp("numberIdZona").reset();
                        Ext.getCmp("textNombre").reset();
                        Ext.getCmp("comboTipoZona").reset();
                        Ext.getCmp("comboClientes").reset();
                        propertieStore.removeAll();
                        storeClientesAsociados.removeAll();

                        _editing = false;

                    },
                    failure: function (msg) {
                        alert('Se ha producido un error.');
                    }

                });

            }

        }

        function SearchAddress(address) {
            var geocoder = new google.maps.Geocoder();
            request = {
                'address': address,
                'region': 'CL'
            };
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

        function AgregarClienteAsociado() {
            var storeClientesAsociados = Ext.getCmp("gridPanelClientesAsociados").store;

            var id = Ext.getCmp("comboClientes").getValue();
            if (!id > 0) {
                return;
            }

            var codCliente = Ext.getCmp("comboClientes").findRecordByValue(Ext.getCmp("comboClientes").getValue()).data.CodCliente;
            var nombreCliente = Ext.getCmp("comboClientes").findRecordByValue(Ext.getCmp("comboClientes").getValue()).data.NombreCliente;
            var nombreTipoCliente = Ext.getCmp("comboClientes").findRecordByValue(Ext.getCmp("comboClientes").getValue()).data.NombreTipoCliente;
            var codTipoCliente = Ext.getCmp("comboClientes").findRecordByValue(Ext.getCmp("comboClientes").getValue()).data.CodTipoCliente;

            var fila;
            fila = {
                'Id': id,
                'CodCliente': codCliente,
                'CodTipoCliente': codTipoCliente,
                'NombreCliente': nombreCliente,
                'NombreTipoCliente': nombreTipoCliente
            };

            var exists = 0;

            for (var i = 0; i < storeClientesAsociados.count() ; i++) {
                if (storeClientesAsociados.data.items[i].data.Id == id) {
                    exists = 1
                    break;
                }
            }

            if (exists == 0) {
                storeClientesAsociados.add(fila);
            }

        }

        function AgregarClienteAsociadoFromGrid(row) {
            var storeClientesAsociados = Ext.getCmp("gridPanelClientesAsociados").store;

            var id = row.data.Id;
            if (!id > 0) {
                return;
            }

            var codCliente = row.data.CodCliente;
            var nombreCliente = row.data.NombreCliente;
            var nombreTipoCliente = row.data.NombreTipoCliente;
            var codTipoCliente = row.data.CodTipoCliente;

            var fila;
            fila = {
                'Id': id,
                'CodCliente': codCliente,
                'CodTipoCliente': codTipoCliente,
                'NombreCliente': nombreCliente,
                'NombreTipoCliente': nombreTipoCliente
            };

            var exists = 0;

            for (var i = 0; i < storeClientesAsociados.count() ; i++) {
                if (storeClientesAsociados.data.items[i].data.Id == id) {
                    exists = 1
                    break;
                }
            }

            if (exists == 0) {
                storeClientesAsociados.add(fila);
            }

        }

        function EliminarCliente(codCliente, codTipoCliente, grid, rowIndex) {
            if (confirm("El Cliente se eliminará permanentemente, así como todas sus asociaciones. ¿Desea continuar?")) {

                Ext.Ajax.request({
                    url: 'AjaxPages/AjaxZonas.aspx?Metodo=EliminarCliente',
                    params: {
                        'CodCliente': codCliente,
                        'CodTipoCliente': codTipoCliente
                    },
                    success: function (data, success) {
                        if (data != null) {
                            grid.getStore().removeAt(rowIndex);
                            alert(data.responseText);
                        }
                    },
                    failure: function (msg) {
                        alert('Se ha producido un error.');
                    }
                });
            }
        }

        function GuardarCliente() {
            if (Ext.getCmp('codCliente').hasActiveError()) {
                return;
            }

            if (!Ext.getCmp('formMantenedorClientes').getForm().isValid()) {
                return;
            }

            var codCliente = Ext.getCmp('codCliente').getValue();
            var codTipoCliente = Ext.getCmp('comboTipoCliente').getValue();
            var nombreCliente = Ext.getCmp('textNombreCliente').getValue();

            Ext.Ajax.request({
                url: 'AjaxPages/AjaxZonas.aspx?Metodo=GuardarCliente',
                params: {
                    'CodCliente': codCliente,
                    'CodTipoCliente': codTipoCliente,
                    'NombreCLiente': nombreCliente
                },
                success: function (msg, success) {
                    alert(msg.responseText);

                    Ext.getCmp("codCliente").reset();
                    Ext.getCmp("comboTipoCliente").reset();
                    Ext.getCmp("textNombreCliente").reset();

                    Ext.getCmp("codCliente").setDisabled(false);
                    Ext.getCmp("comboTipoCliente").setDisabled(false);

                    Ext.getCmp("gridPanelClientes").store.load({
                        params: {
                            IdZona: -1
                        }
                    });

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
