
var imageMenu = {
  id: 'imageMenu',
  xtype: 'image',
  src: 'Images/logo_transparent_80x37.png',
  height: 37,
  width: 80

};

var btnPageHome = {
  id: 'btnPageHome',
  xtype: 'button',
  text: 'Inicio',
  iconAlign: 'left',
  icon: 'Images/home_white_24x24.png',
  height: 35,
  width: 80,
  handler: function () {
    window.location = "Dashboard.aspx";
  }
};

var btnVisualizador = {
  id: 'btnVisualizador',
  xtype: 'button',
  text: 'Vista General',
  iconAlign: 'left',
  icon: 'Images/earth_20x20.png',
  height: 35,
  width: 110,
  handler: function () {
    window.location = "Visualizador.aspx";
  }
};

var menuViajes = Ext.create('Ext.menu.Menu', {
  id: 'menuViajes'
});

menuViajes.add({  //xtype: 'button',
  text: 'Panel de Control',
  //iconAlign: 'left',  
  icon: 'Images/control_black_24x24.png',
  handler: function () {
    window.location = "ControlPanel.aspx";
  }
})

////menuViajes.add({  //xtype: 'button',
////  text: 'Control de Viajes',
////  //iconAlign: 'left',
////  icon: 'Images/historico_gray_24x24.png',
////  handler: function () {
////    window.location = "ViajesRuta.aspx";
////  }
////})

////menuViajes.add({  //xtype: 'button',
////  text: 'Indicadores diarios',
////  //iconAlign: 'left',
////  icon: 'Images/graph_24x24.png',
////  handler: function () {
////    window.location = "Dashboard.aspx";
////  }
////})

/* deshabilitado A Navarro
menuViajes.add({  //xtype: 'button',
  text: 'Creación de Viajes',
  //iconAlign: 'left',
  icon: 'Images/edittrip_black_26x26.png',
  handler: function () {
    window.location = "ConfigViajes.aspx";
  }
})
*/

////menuViajes.add({  //xtype: 'button',
////  text: 'Guías de Despacho',
////  //iconAlign: 'left',
////  icon: 'Images/rpt_monitoreo_24x24.png',
////  handler: function () {
////    window.location = "Rpt_GuiasDespacho.aspx";
////  }
////})

////menuViajes.add({
////  text: 'Ruta óptima',
////  //iconAlign: 'left',
////  icon: 'Images/route_black_24x24.png',
////  //height: 25,
////  //width: 80,
////  handler: function () {
////    window.location = "ConfigRutas.aspx";
////  }
////})

var btnMenuViajes = {
  id: 'btnMenuViajes',
  xtype: 'button',
  text: 'Viajes',
  iconAlign: 'left',
  icon: 'Images/truck_gray_24x24.png',
  height: 35,
  width: 100,
  menu: menuViajes
};

var menuGPS = Ext.create('Ext.menu.Menu', {
  id: 'menuGPS'
});

menuGPS.add({ //xtype: 'button',
  text: 'Flota Online',
  //iconAlign: 'left',
  icon: 'Images/fronttruck_black_24x24.png',
  handler: function () {
    window.location = "FlotaOnline.aspx";
  }
})

menuGPS.add({ //xtype: 'button',
  text: 'Monitoreo Online',
  //iconAlign: 'left',
  icon: 'Images/monitoreoOnline_black_24x24.png',
  handler: function () {
    window.location = "MonitoreoOnline.aspx";
  }
})

menuGPS.add({ //xtype: 'button',
  text: 'Posiciones GPS',
  //iconAlign: 'left',
  icon: 'Images/broadcast_black_24x24.png',
  handler: function () {
    window.location = "PosicionesGPS.aspx";
  }
})

menuGPS.add({ //xtype: 'button',
  text: 'Estado Patente',
  //iconAlign: 'left',
  icon: 'Images/checkmark_gray_24x24.png',
  handler: function () {
    window.location = "EstadoPatente.aspx";
  }
})

var btnMenuGPS = {
  id: 'btnMenuGPS',
  xtype: 'button',
  text: 'GPS',
  iconAlign: 'left',
  icon: 'Images/gps_gray_24x24.png',
  height: 35,
  width: 90,
  menu: menuGPS
};

var menuReportes = Ext.create('Ext.menu.Menu', {
  id: 'menuReportes'
});
/*
menuReportes.add({  //xtype: 'button',
                    text: 'Histórico de Viajes',
                    //iconAlign: 'left',
                    icon: 'Images/historico_gray_24x24.png',
                    handler: function () {
                      window.location = "ViajesHistoricos.aspx";
                    }
})
*/
menuReportes.add({  //xtype: 'button',
  text: 'Informe de Viajes',
  //iconAlign: 'left',
  icon: 'Images/informeViajes_white_24x24.png',
  handler: function () {
    window.location = "InformeViajes.aspx";
  }
})

menuReportes.add({  //xtype: 'button',
  text: 'Kms recorridos',
  //iconAlign: 'left',
  icon: 'Images/road_black_24x25.png',
  handler: function () {
    window.location = "Rpt_KmsRecorridos.aspx";
  }
})

menuReportes.add({  //xtype: 'button',
  text: 'Temático de alertas',
  //iconAlign: 'left',
  icon: 'Images/flag_black_24x24.png',
  handler: function () {
    window.location = "Rpt_Alertas.aspx";
  }
})
/*
menuReportes.add({  //xtype: 'button',
  text: 'Dashboard',
  //iconAlign: 'left',
  icon: 'Images/graph_24x24.png',
  handler: function () {
    window.location = "Dashboard.aspx";
  }
})
*/



var btnMenuReportes = new Ext.button.Button({
  id: 'btnMenuReportes',
  xtype: 'button',
  text: 'Reportes',
  iconAlign: 'left',
  icon: 'Images/reports_gray_24x24.png',
  height: 35,
  width: 100,
  menu: menuReportes
});

/*
var btnMenuReportes = {
  id: 'btnMenuReportes',
  xtype: 'button',
  text: 'Reportes',
  iconAlign: 'left',
  icon: 'Images/reports_gray_24x24.png',
  height: 35,
  width: 100,
  menu: menuReportes
};
*/
var menuConfiguracion = Ext.create('Ext.menu.Menu', {
  id: 'menuConfiguracion'
});

menuConfiguracion.add({
  text: 'Zonas',
  //iconAlign: 'left',
  icon: 'Images/zona_gray_22x22.png',
  //height: 25,
  //width: 80,
  handler: function () {
    window.location = "Config_Zonas_Sitrans.aspx";
  }
})
/*
menuConfiguracion.add({ text: 'Generación de Rutas',
                      //iconAlign: 'left',
                      icon: 'Images/route_black_24x24.png',
                      //height: 25,
                      //width: 80,
                      handler: function () {
                        window.location = "ConfigRutas.aspx";
                      }
})

menuConfiguracion.add({ text: 'Generación Masiva',
                      //iconAlign: 'left',
                      icon: 'Images/allroutes_24x24.png',
                      //height: 25,
                      //width: 80,
                      handler: function () {
                        window.location = "GeneracionRutas.aspx";
                      }
})

menuConfiguracion.add({ text: 'Alertas',
                        //iconAlign: 'left',
                        icon: 'Images/alert_black_24x24.png',
                        //height: 25,
                        //width: 80,
                        handler: function () {
                          window.location = "ConfigAlertas.aspx";
                        }
})
*/

var btnMenuConfig = new Ext.button.Button({
  id: 'btnMenuConfig',
  xtype: 'button',
  text: 'Configuración',
  iconAlign: 'left',
  icon: 'Images/gear_white_24x24.png',
  height: 35,
  width: 120,
  menu: menuConfiguracion
});


/********  Menú Soporte  *******/

var menuSoporte = Ext.create('Ext.menu.Menu', {
  id: 'menuSoporte'
});

menuSoporte.add({
  id: 'MnuEnviarTicket',
  text: 'Enviar Ticket',
  icon: 'Images/gear_white_24x24.png',
  handler: function () {
    window.location = "Soporte.NuevoTicket.aspx";
  }
})

menuSoporte.add({
  id: 'MnuMisTicket',
  text: 'Mis Tickets',
  icon: 'Images/mistickets_black_24x24.png',
  handler: function () {
    window.location = "Soporte.MisTicket.aspx";
  }
})

var btnMenuSoporte = new Ext.button.Button({
  id: 'btnMenuSoporte',
  xtype: 'button',
  text: 'Soporte',
  iconAlign: 'left',
  icon: 'Images/support_black_24x24.png',
  height: 35,
  width: 120,
  menu: menuSoporte
});

var btnLogout = {
  id: 'btnLogout',
  xtype: 'button',
  text: 'Cerrar Sesión',
  iconAlign: 'left',
  height: 35,
  width: 120,
  icon: 'Images/logout_grey_24x24.png',
  handler: function () {
    window.location = "Login.aspx";
  }
};

var toolbarMenu = Ext.create('Ext.toolbar.Toolbar', {
  id: 'toolbarMenu',
  height: 40,
  items: [btnPageHome, { xtype: 'tbseparator' }, btnVisualizador, { xtype: 'tbseparator' }, btnMenuViajes, { xtype: 'tbseparator' }, btnLogout]
  //items: [imageMenu, btnPageHome, { xtype: 'tbseparator' }, btnMenuViajes, { xtype: 'tbseparator' }, btnLogout]
  //items: [imageMenu, btnPageHome, { xtype: 'tbseparator' }, btnVisualizador, { xtype: 'tbseparator' }, btnMenuViajes, { xtype: 'tbseparator' }, btnMenuGPS, { xtype: 'tbseparator' }, btnMenuReportes, { xtype: 'tbseparator' }, btnMenuConfig, { xtype: 'tbseparator' }, btnMenuSoporte, { xtype: 'tbseparator' }, btnLogout]
});
/*
var toolbarMenu = Ext.create('Ext.toolbar.Toolbar', {
  id: 'toolbarMenu',
  height: 40,
  items: [imageMenu, btnMenuReportes, { xtype: 'tbseparator' }]
});
*/
var topMenu = new Ext.FormPanel({
  id: 'topMenu',
  region: 'north',
  border: true,
  height: 40,
  tbar: toolbarMenu
});