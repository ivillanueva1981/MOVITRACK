Ext.Loader.setConfig({ enabled: true, paths: { GenForm: './Scripts'} })
Ext.require([
        'widget.panel',
        'Ext.GMapPanel.*'
    ]);

var map;
var map2;
var markers = new Array();
var labels = new Array();

var markersWinMaxi = new Array();
var labelsWinMaxi = new Array();
var pointsWinMaxi = new Array();

var dir = new Array();
var poly;
var circle;
var counter;
var points = new Array();

var xWinMap = 140;
var yWinMap = 160;

(function () {
    google.maps.Map.prototype.clearMarkers = function () {
        for (var i = 0; i < markers.length; i++) {
            if (markers[i] != null) {
                markers[i].setMap(null);
            }
        }
        markers.length = 0;
    };
})();
(function () {
    google.maps.Map.prototype.clearLabels = function () {
        for (var i = 0; i < labels.length; i++) {
            if (labels[i] != null) {
                labels[i].setMap(null);
            }
        }
        labels.length = 0;
    };
})();

function GeneraMapa(idDiv, parent) {
    if (arguments.length < 2) {
        parent = false;
    }
    var myLatlng = new google.maps.LatLng(-33.443915, -70.653986);
    var myOptions = {
        zoom: 12,
        center: myLatlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };

    if (parent == true) {
      map = new google.maps.Map(document.getElementById(idDiv).parentNode, myOptions);
    }
    else {
        map = new google.maps.Map(document.getElementById(idDiv), myOptions);
    }
}


function ClearMap() {
    map.clearMarkers();
    if (labels.length > 0) {
        map.clearLabels();
    }
    if (dir != undefined) {
        for (var i = 0; i < dir.length; i++) {
            dir[i].setMap(null);
        }
        dir.length = 0;
    }
    if (poly != null) {
        poly.setMap(null);
    }
    if (circle != null) {
        circle.setMap(null);
    }
    markers.length = 0;
    counter = 0;
}

function addNuevoMarker(movilRefreshMap, newMarker) {
    var winMapa = Ext.getCmp(movilRefreshMap);
    var latlngMark = new google.maps.LatLng(newMarker.lat, newMarker.lng);
    winMapa.addMarker(latlngMark, newMarker.marker, true, true, newMarker.listeners);
    winMapa.setCenter = latlngMark;
}

//Funcion que genera una ventana con el mapa donde esta ubicado el movil y su direccion
function UbicaMovilMapa(latitud, longitud, html, direccion, colorMovil) {
    if (Ext.getCmp('winUbicacionMovil') != null) {
        Ext.getCmp('winUbicacionMovil').close();
    }

    var latlng = new google.maps.LatLng(latitud, longitud);
    var myOptions = {
        zoom: 12,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };

    var win = new Ext.window.Window({
        id: 'winUbicacionMovil',
        title: 'Ubicación',
        height: 500,
        width: 500,
        hidden: false,
        modal: false,
        maximizable: true,
        resizable: true,
        minimizable: false,
        layout: 'anchor',
        closeAction: 'destroy',
        html: '<div id="divMApMovil" style="width:100%; height:100%;"></div>',
        buttons: [{
            xtype: 'button',
            text: 'Salir',
            handler: function (a, b, c, d, e) {
                win.close();
            }
        }],
        listeners: {
            'resize': function (win, width, height, eOpts) {
                if (typeof map != "undefined") {
                    google.maps.event.trigger(map, "resize");
                }
            },
            'maximize': function (win, width, height, eOpts) {
                if (typeof map != "undefined") {
                    google.maps.event.trigger(map, "resize");
                }
            }
        }
    });

    win.show();
    map = new google.maps.Map(document.getElementById("divMApMovil").parentNode, myOptions);
     
    var iconState;
    iconState = 'Images/Camiones/';

    if (colorMovil.indexOf("rojo.png") >= 0) {
        iconState += 'Rojo/autoNN';
    }
    else if (colorMovil.indexOf("verde.png") >= 0) {
        iconState += 'Verde/autoNN';
    }
    else if (colorMovil.indexOf("amarillo.png") >= 0) {
        iconState += 'Amarillo/autoNN';
    }
    else if (colorMovil.indexOf("azul.png") >= 0) {
        iconState += 'Azul/autoNN';
    }
    else if (colorMovil.indexOf("celeste.png") >= 0) {
        iconState += 'Celeste/autoNN';
    }

    else {
        iconState += 'Verde/autoNN';
    }

    if (direccion != '') {
        if (direccion >= 339 || direccion <= 22) {
            iconState += '0.png';
        }
        if (direccion >= 23 && direccion <= 68) {
            iconState += '1.png';
        }
        if (direccion >= 69 && direccion <= 112) {
            iconState += '2.png';
        }
        if (direccion >= 113 && direccion <= 158) {
            iconState += '3.png';
        }
        if (direccion >= 159 && direccion <= 202) {
            iconState += '4.png';
        }
        if (direccion >= 203 && direccion <= 246) {
            iconState += '5.png';
        }
        if (direccion >= 247 && direccion <= 291) {
            iconState += '6.png';
        }
        if (direccion >= 292 && direccion <= 338) {
            iconState += '7.png';
        }
    } else {
        iconState += '.png';
    }

    marker = new google.maps.Marker({
        position: latlng,
        icon: new google.maps.MarkerImage(
                                            iconState,
                                            new google.maps.Size(27, 27),
                                            new google.maps.Point(0, 0),
                                            new google.maps.Point(0, 32),
                                            new google.maps.Size(27, 27)),
        map: map
    });

    markers.push(marker);

    var htmlString = '';
    htmlString = '<div style="max-width:300px;">' +
                '<font color="#6387A5" size="2"face="Verdana, Arial, Helvetica, sans-serif">' +
                html +
                '</font></div>';
    infowindow.setContent(htmlString);
    infowindow.open(map, marker);

    google.maps.event.addListener(marker, 'click', function () {
        infowindow.setContent(htmlString);
        infowindow.open(map, marker);
    });
}

function UbicaMovilMapaV2(latitud, longitud, direccion, html, movil, colorMovil, tipoVehiculo) {
    if (winArray.length >= 8) {
        alert('No se pueden posicionar más de 8 móviles');
        return;
    }
    if (Ext.getCmp('Win_' + movil) != null) {
        alert('Ya mantiene una vista personalizada de este Movil.');
        return;
    }

    var latlng = new google.maps.LatLng(latitud, longitud);

    if (tipoVehiculo == 'Camion' || tipoVehiculo == '') {
        tipoVehiculo = 'Camiones';
    }
    var iconState;
    iconState = 'Images/' + tipoVehiculo + '/';

    if (colorMovil.indexOf("rojo.png") >= 0) {
        iconState += 'Rojo/autoNN';
    }
    else if (colorMovil.indexOf("verde.png") >= 0) {
        iconState += 'Verde/autoNN';
    }
    else if (colorMovil.indexOf("amarillo.png") >= 0) {
        iconState += 'Amarillo/autoNN';
    }
    else if (colorMovil.indexOf("azul.png") >= 0) {
        iconState += 'Azul/autoNN';
    }
    else if (colorMovil.indexOf("celeste.png") >= 0) {
        iconState += 'Celeste/autoNN';
    }

    if (direccion != '') {
        if (direccion >= 339 || direccion <= 22) {
            iconState += '0.png';
        }
        if (direccion >= 23 && direccion <= 68) {
            iconState += '1.png';
        }
        if (direccion >= 69 && direccion <= 112) {
            iconState += '2.png';
        }
        if (direccion >= 113 && direccion <= 158) {
            iconState += '3.png';
        }
        if (direccion >= 159 && direccion <= 202) {
            iconState += '4.png';
        }
        if (direccion >= 203 && direccion <= 246) {
            iconState += '5.png';
        }
        if (direccion >= 247 && direccion <= 291) {
            iconState += '6.png';
        }
        if (direccion >= 292 && direccion <= 338) {
            iconState += '7.png';
        }
    } else {
        iconState += '.png';
    }

    var win = new Ext.window.Window({
        title: 'Mapa Móvil: ' + movil,
        id: 'Win_' + movil,
        width: 240,
        height: 240,
        x: xWinMap,
        y: yWinMap,
        floating: true,
        closable: true,
        closeAction: 'destroy',
        maximizable: true,
        resizable: true,
        minimizable: false,
        constrain: true,
        autoDestroy: true,
        handleResize: function () {
            var Ventana = Ext.getCmp(this.id);
            Ventana.setWidth(240);
            Ventana.setHeight(240);
        },
        Position: function (ax, ay) {
            var el = this.getPositionEl();
            if (ax !== undefined || ay !== undefined) {
                if (ax !== undefined && ay !== undefined) {
                    el.setLeftTop(ax, ay);
                } else if (ax !== undefined) {
                    el.setLeft(ax);
                } else if (ay !== undefined) {
                    el.setTop(ay);
                }
                this.fireEvent('move', this, ax, ay);
            }
        },

        items: {
            xtype: 'gmappanel',
            zoomLevel: 15,
            width: '100%',
            height: '100%',
            layout: 'fit',
            id: "thisMap" + movil,
            gmapType: 'map',
            region: 'center',
            autoDestroy: true,
            setCenter: {
                lat: latitud,
                lng: longitud
            },
            markers: [
                {
                    lat: latitud,
                    lng: longitud,
                    marker: {
                        title: html,
                        icon: new google.maps.MarkerImage(
                        iconState,
                        new google.maps.Size(40, 40),
                        new google.maps.Point(0, 0),
                        new google.maps.Point(0, 32),
                        new google.maps.Size(40, 40))
                    }
                }
            ]
        },

        hidden: false,
        modal: false,
        layout: 'anchor',
        closeAction: 'destroy',
        buttons: [{
            xtype: 'button',
            text: 'Salir',
            handler: function (a, b, c, d, e) {
                win.close();
            }
        }],
        listeners: {
            'resize': function (win, width, height, eOpts) {
                var mapMovil = Ext.getCmp('thisMap' + movil);
                if (typeof mapMovil != "undefined" && typeof mapMovil.getMap() != "undefined") {
                    google.maps.event.trigger(mapMovil.getMap(), "resize");

                }
            },
            'maximize': function (win, width, height, eOpts) {
                var mapMovil = Ext.getCmp('thisMap' + movil);
                if (typeof mapMovil != "undefined" && typeof mapMovil.getMap() != "undefined") {
                    google.maps.event.trigger(mapMovil.getMap(), "resize");
                }
            }
        }

    });

    win.on("beforeclose", function () {
        var arregloTemp = new Array();
        var IdMovil = null;
        var IdMapa = null;

        for (x = 0; x < winArray.length; x++) {
            if (winArray[x].id == this.id) {
                arregloTemp = borra_arr(winArray, x);
                break;
            }
        }

        winArray = new Array();
        winArray = arregloTemp;

        arregloTemp = new Array();
        movil = this.id.substring(4);
        IdMapa = "thisMap" + movil;

        for (x = 0; x < mapArray.length; x++) {
            if (mapArray[x].id == IdMapa) {
                arregloTemp = borra_arr(mapArray, x);
                break;
            }
        }

        mapArray = new Array();
        mapArray = arregloTemp;

    });

    var mapMovil = Ext.getCmp('thisMap' + movil);
    win.show();

    winArray.push(win)
    mapArray.push(mapMovil);

    xWinMap = xWinMap + 30;
    yWinMap = yWinMap + 30;

    if (xWinMap > 450) {
        xWinMap = 340;
        yWinMap = 160;
    }
}

function borra_arr(arreglo, pos) {
    var arreglo2 = new Array();
    y = 0;
    for (x = 0; x < arreglo.length; x++) {
        if (x != pos) {
            arreglo2[y] = arreglo[x];
            y++;
        }
    }
    return arreglo2;
}

function MosaicoWinMap() {
    var cont = 4;
    var x = 0;
    var y = 0;

    for (var m = 0; m < winArray.length; m++) {

        switch (cont) {
            case 4:
                x = 10;
                y = 165;
                break;
            case 8:
                x = 10;
                y = 406;
                break;
        }

        winArray[m].handleResize();
        winArray[m].Position(x, y);

        x += 241;
        cont += 1;
    }
}

//Función que muestra la dirección buscada en el mapa
function addAddressToMap(response) {
    if (arguments[1] != "OK") {
        alert("Reintente, no se ha encontrado su dirección");
        return;
    } else {
        point = new google.maps.LatLng(response[0].geometry.location.lat(), response[0].geometry.location.lng());
        var resp = request.address + '*' + response[0].geometry.location.lat() + '*' + response[0].geometry.location.lng() + '*';
        var arreglo = resp.split('*');
        if (arreglo[1] != "?") {
            var lamo = arreglo[1];
            var lomo = arreglo[2];
            var cadena = arreglo[0];

            var image = new google.maps.MarkerImage("Images/house.png");

            var marker = new google.maps.Marker({
                position: new google.maps.LatLng(parseFloat(lamo), parseFloat(lomo)),
                clickable: false,
                icon: image,
                draggable: false,
                labelText: cadena.split(',')[0],
                labelOffset: new google.maps.Size(15, -6),
                map: map
            });

            var label = new Label({
                map: map
            });
            label.bindTo('position', marker, 'position');
            label.bindTo('text', marker, 'labelText');

            dir.push(label);
            dir.push(marker);
            map.setCenter(new google.maps.LatLng(lamo, lomo));
        }
    }
}

//Función que elimina todos los puntos del mapa
function ClearPoints() {
    map.clearMarkers();
    markers.length = 0;
    counter = 0;
    if (poly != null) {
        poly.setMap(null); points.length = 0;
    }
    if (circle != null) {
        circle.setMap(null);
    }
    if (labels.length > 0) {
        map.clearLabels();
    }
}

//Función que dibuja la Zona en el Mapa
function DrawZone(data, radio) {

    var colorZone = "#0000FF";

    //Polígono
    if (data.Vertices.length > 1) {
        //ClearPoints();
        //ShowProperties();
        for (var i = 0; i < data.Vertices.length; i++) {
            var Point = new Object;
            Point.latLng = new google.maps.LatLng(data.Vertices[i].Latitud, data.Vertices[i].Longitud);
            CreateMarkerPolyLine(Point);
        }
        map.setCenter(new google.maps.LatLng(data.Latitud, data.Longitud));
    }
        //Punto
        /*else {
          if (data.Vertices.length == 1) {
            //ClearPoints();
            //ShowProperties();
            var Point = new Object;
            Point.latLng = new google.maps.LatLng(data.Latitud, data.Longitud);
            CreateMarkerPoint(Point);
      
            map.setCenter(new google.maps.LatLng(data.Latitud, data.Longitud));
          }
        }*/
    else {
        if (circle) { circle.setMap(null); }

        var center = new google.maps.LatLng(data.Latitud, data.Longitud)

        circle = new google.maps.Circle({ strokeColor: "#000000", strokeWeight: 1, strokeOpacity: 0.9, fillColor: colorZone, fillOpacity: 0.3, center: center, editable: true, draggable: true, radius: radio });
        circle.setMap(map);

        map.setCenter(center);

        var Point = new Object;
        Point.latLng = center;
        CreateMarkerPolyLine(Point);

        circle.bindTo('center', markers[0], 'position');

        google.maps.event.addListener(circle, 'radius_changed', function () {
            radius = circle.getRadius();
        });
    }

}
