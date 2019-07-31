using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BusinessEntities;
using BusinessLayer;
using Newtonsoft.Json;
using UtilitiesLayer;

using System.IO;
using System.Data;

using System.Collections;
using System.Data.OleDb;
using System.Text.RegularExpressions;
using LinqToExcel;
using System.Globalization;
using Track_Negocio.Manager;

namespace Track_Web.AjaxPages
{
    public partial class AjaxViajes : System.Web.UI.Page
    {
        IFormatProvider culture = new CultureInfo("en-US", true);
        ConsultaManager _db = new ConsultaManager();

        protected void Page_Load(object sender, EventArgs e)
        {
            switch (Request.QueryString["Metodo"])
            {
                case "GetTransportesRuta":
                    GetTransportesRuta();
                    break;
                case "GetPatentesRuta":
                    GetPatentesRuta();
                    break;
                case "GetViajesRuta":
                    GetViajesRuta();
                    break;
                case "GetTransportistasRuta":
                    GetTransportistasRuta();
                    break;
                case "GetPosicionesRuta":
                    GetPosicionesRuta();
                    break;
                case "GetAllPatentes":
                    GetAllPatentes();
                    break;
                case "GetAllTransportistas":
                    // Modificado 30/07/2019
                    GetAllTransportistas();
                    break;
                case "GetViajesHistoricos":
                    GetViajesHistoricos();
                    break;
                case "GetPosicionesGPS":
                    GetPosicionesGPS();
                    break;
                case "GetPosicionesGPS_Ruta":
                    GetPosicionesGPS_Ruta();
                    break;
                case "GetInformeViajes":
                    GetInformeViajes();
                    break;
                case "GetDetalleTrayecto":
                    GetDetalleTrayecto();
                    break;
                case "GetNroTransportes":
                    GetNroTransportes();
                    break;
                case "GetFlotaOnline":
                    GetFlotaOnline();
                    break;
                case "GetViajesAsignados":
                    GetViajesAsignados();
                    break;
                case "GetViajesControlPanel":
                    GetViajesControlPanel();
                    break;
                case "EliminarViaje":
                    EliminarViaje(Request.Form["nroTransporte"].ToString(), Request.Form["codLocal"].ToString());
                    break;
                case "ValidarMovilCD":
                    ValidarMovilCD(Request.Form["patente"].ToString());
                    break;
                case "ValidarNroTransporte":
                    ValidarNroTransporte(Request.Form["nroTransporte"].ToString());
                    break;
                case "NuevoViaje":
                    NuevoViaje(Request.Form["nroTransporte"].ToString(), Request.Form["transportista"].ToString(), Request.Form["trailer"].ToString(), Request.Form["tracto"].ToString(), Request.Form["codOrigen"].ToString(), Request.Form["codRuta"].ToString(), Request.Form["rutConductor"].ToString(), Request.Form["nombreConductor"].ToString());
                    break;
                case "EditarViaje":
                    EditarViaje(Request.Form["nroTransporte"].ToString(), Request.Form["transportista"].ToString(), Request.Form["trailer"].ToString(), Request.Form["tracto"].ToString(), Request.Form["codOrigen"].ToString(), Request.Form["codDestino"].ToString(), Request.Form["rutConductor"].ToString(), Request.Form["nombreConductor"].ToString());
                    break;
                case "GetPosicionesRutaModuloMapa":
                    GetPosicionesRutaModuloMapa();
                    break;
                case "GetProveedoresGPS":
                    GetProveedoresGPS();
                    break;
                case "GetRutasGeneradas":
                    GetRutasGeneradas();
                    break;
                case "GetDetalleRuta":
                    GetDetalleRuta();
                    break;
                case "EliminarRutaGenerada":
                    EliminarRutaGenerada(Request.Form["idRuta"].ToString());
                    break;
                case "EliminarDestinoRuta":
                    EliminarDestinoRuta(Request.Form["idZona"].ToString());
                    break;
                case "AgregarRutaGenerada":
                    AgregarRutaGenerada(Request.Form["nombreRuta"].ToString());
                    break;
                case "AgregarDestinoRuta":
                    AgregarDestinoRuta(Request.Form["idRuta"].ToString(), Request.Form["idZona"].ToString());
                    break;
                case "CargaViajesExcel":
                    CargaViajesExcel();
                    break;
                case "CierreManual":
                    CierreManual(Request.Form["NroTransporte"].ToString(), Request.Form["CodLocal"].ToString(), Request.Form["PatenteTracto"].ToString(), Request.Form["PatenteTrailer"].ToString(), Request.Form["EstadoLat"].ToString(), Request.Form["EstadoLon"].ToString());
                    break;
                case "GetTipoEtis":
                    GetTipoEtis();
                    break;
                case "GetClientes":
                    GetClientes();
                    break;
                case "GetMonitoreoOnline":
                    GetMonitoreoOnline();
                    break;
                case "GetViajesMineria":
                    GetViajesMineria();
                    break;
                case "GetETA":
                    GetETA(Request.Form["estadoLat"].ToString(), Request.Form["estadoLon"].ToString(), Request.Form["destinolat"].ToString(), Request.Form["destinoLon"].ToString());
                    break;
                case "GetClientesUsuario":
                    GetClientesUsuario();
                    break;
            }
        }

        public void GetTransportesRuta()
        {
            string _todos = "" + Request.QueryString["Todos"];

            Methods_Viajes _objMethodsViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethodsViajes.GetNroTransportesRuta());

            Response.Write(_response);

        }

        public void GetPatentesRuta()
        {
            string _todos = "" + Request.QueryString["Todos"];

            Methods_Viajes _objMethodsViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethodsViajes.GetPatentesRuta());

            Response.Write(_response);

        }

        public void GetTransportistasRuta()
        {
            string _todos = "" + Request.QueryString["Todos"];

            Methods_Viajes _objMethodsViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethodsViajes.GetTransportistasRuta());

            Response.Write(_response);

        }

        public void GetViajesRuta()
        {
            string nroTransporte = "" + Request.QueryString["nroTransporte"];
            string patente = "" + Request.QueryString["patente"];
            string estadoViaje = "" + Request.QueryString["estadoViaje"];
            string transportista = "" + Request.QueryString["transportista"];

            int _nroTransporte;
            if (nroTransporte == "Todos" || nroTransporte == "")
            {
                _nroTransporte = 0;
            }
            else
            {
                int.TryParse(nroTransporte, out _nroTransporte);
            }

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetViajesRuta(_nroTransporte, patente, estadoViaje, transportista));

            Response.Write(_response);
        }

        public void GetPosicionesRuta()
        {
            Methods_User _objUser = new Methods_User();

            int webDiferenciaHoraria = _objUser.webDiferenciaHoraria();

            string patenteTracto = "" + Request.QueryString["patenteTracto"];
            string patenteTrailer = "" + Request.QueryString["patenteTrailer"];
            string fechaCreacion = "" + Request.QueryString["fechaHoraCreacion"];
            string fechaSalidaOrigen = "" + Request.QueryString["fechaHoraSalidaOrigen"];
            string fechaLlegadaDestino = "" + Request.QueryString["fechaHoraLlegadaDestino"];
            string nroTransporte = "" + Request.QueryString["nroTransporte"];
            string destino = "" + Request.QueryString["destino"];
            string estadoViaje = "" + Request.QueryString["estadoViaje"];

            int _nroTransporte;
            int _destino;

            int.TryParse(nroTransporte, out _nroTransporte);
            int.TryParse(destino, out _destino);

            DateTime _fechaCreacion;
            DateTime _fechaSalidaOrigen;
            DateTime _fechaLlegadaDestino;

            if (fechaCreacion == "")
            {
                fechaCreacion = DateTime.UtcNow.AddHours(webDiferenciaHoraria).ToString("yyyy-MM-ddTHH\\:mm");
            }

            if (fechaSalidaOrigen == "")
            {
                fechaSalidaOrigen = DateTime.UtcNow.AddHours(webDiferenciaHoraria).ToString("yyyy-MM-ddTHH\\:mm");
            }

            if (fechaLlegadaDestino == "")
            {
                fechaLlegadaDestino = DateTime.UtcNow.AddHours(webDiferenciaHoraria).ToString("yyyy-MM-ddTHH\\:mm");
            }

            if (DateTime.TryParseExact(fechaCreacion.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fechaCreacion))
            {
            }
            else
            {
                DateTime.TryParseExact(fechaCreacion.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fechaCreacion);
            }

            if (DateTime.TryParseExact(fechaSalidaOrigen.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fechaSalidaOrigen))
            {
            }
            else
            {
                DateTime.TryParseExact(fechaSalidaOrigen.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fechaSalidaOrigen);
            }

            if (DateTime.TryParseExact(fechaLlegadaDestino.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fechaLlegadaDestino))
            {
            }
            else
            {
                DateTime.TryParseExact(fechaLlegadaDestino.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fechaLlegadaDestino);
            }

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetPosicionesRuta(patenteTracto, patenteTrailer, _fechaCreacion, _fechaSalidaOrigen, _fechaLlegadaDestino, _nroTransporte, _destino, estadoViaje));

            Response.Write(_response);
        }

        public void GetAllPatentes()
        {
            string _transportista = "" + Request.QueryString["transportista"];
            string _todas = "" + Request.QueryString["Todas"];
            string _result = "";
            Methods_Viajes _obj = new Methods_Viajes();

            if (_todas == "True")
            {
                var _list = (from i in _obj.GetAllPatentes(_transportista, true)
                             select new
                             {
                                 i.Patente,
                             }).Distinct().ToList();
                _result = JsonConvert.SerializeObject(_list);
            }
            else
            {
                var _list = (from i in _obj.GetAllPatentes(_transportista)
                             select new
                             {
                                 i.Patente
                             }).Distinct().ToList();
                _result = JsonConvert.SerializeObject(_list);
            }

            Response.Write(_result);
        }

        public void GetAllTransportistas()
        {
            string _todos = "" + Request.QueryString["Todos"];
            string _result = "";
            Methods_Viajes _obj = new Methods_Viajes();

            var v_session = Utilities.GetTransportistaSession(Session);

            if (_todos == "True") {
                _todos = "Todos";
            }

             _result = JsonConvert.SerializeObject(_db.GetAllTransportistas(_todos, v_session.ToString()));

            #region Web MWthod
            //if (_todos == "True")
            //{
            //    var _list = (from i in _obj.GetAllTransportistas(true, Session)
            //                 where i.Transportista != null
            //                 select new
            //                 {
            //                     i.Transportista,
            //                 }).Distinct().ToList();
            //    _result = JsonConvert.SerializeObject(_list);
            //}
            //else
            //{
            //    var _list = (from i in _obj.GetAllTransportistas(false, Session)
            //                 select new
            //                 {
            //                     i.Transportista
            //                 }).Distinct().ToList();
            //    _result = JsonConvert.SerializeObject(_list);
            //}
            #endregion

            Response.Write(_result);
        }

        public void GetViajesHistoricos()
        {
            string userName = Utilities.GetUsuarioSession(Session);

            string desde = "" + Request.QueryString["desde"];
            string hasta = "" + Request.QueryString["hasta"];
            string nroTransporte = "" + Request.QueryString["nroTransporte"];
            string nroOS = "" + Request.QueryString["nroOS"];
            string nroContenedor = "" + Request.QueryString["nroContenedor"];
            string tipoEtis = "" + Request.QueryString["tipoEtis"];
            string patente = "" + Request.QueryString["patente"];
            string estadoViaje = "" + Request.QueryString["estadoViaje"];
            string nombreConductor = "" + Request.QueryString["nombreConductor"];

            DateTime _desde;
            DateTime _hasta;
            int _nroTransporte;
            int _nroOS;

            //DateTime.TryParse(desde, out _desde);
            //DateTime.TryParse(hasta, out _hasta);

            if (DateTime.TryParseExact(desde.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _desde))
            {
            }
            else
            {
                DateTime.TryParseExact(desde.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _desde);
            }

            if (DateTime.TryParseExact(hasta.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _hasta))
            {
            }
            else
            {
                DateTime.TryParseExact(hasta.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _hasta);
            }
            if (nroTransporte == "Todos" || nroTransporte == "")
            {
                _nroTransporte = 0;
            }
            else
            {
                int.TryParse(nroTransporte, out _nroTransporte);
            }

            if (nroOS == "")
            {
                _nroOS = 0;
            }
            else
            {
                int.TryParse(nroOS, out _nroOS);
            }

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetViajesHistoricos(_desde, _hasta, _nroTransporte, _nroOS, nroContenedor, patente, estadoViaje, userName, tipoEtis, nombreConductor));

            Response.Write(_response);
        }

        public void GetPosicionesGPS()
        {
            string fechaDesde = "" + Request.QueryString["fechaDesde"];
            string fechaHasta = "" + Request.QueryString["fechaHasta"];
            string patente = "" + Request.QueryString["patente"];

            DateTime _fechaDesde;
            DateTime _fechaHasta;

            //_fechaDesde = Convert.ToDateTime(fechaDesde);
            //_fechaHasta = Convert.ToDateTime(fechaHasta);
            if (DateTime.TryParseExact(fechaDesde.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fechaDesde))
            {
            }
            else
            {
                DateTime.TryParseExact(fechaDesde.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fechaDesde);
            }

            if (DateTime.TryParseExact(fechaHasta.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fechaHasta))
            {
            }
            else
            {
                DateTime.TryParseExact(fechaHasta.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fechaHasta);
            }

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetPosicionesGPS(_fechaDesde, _fechaHasta, patente));

            Response.Write(_response);
        }

        public void GetPosicionesGPS_Ruta()
        {
            string fechaDesde = "" + Request.QueryString["fechaDesde"];
            string fechaHasta = "" + Request.QueryString["fechaHasta"];
            string patente = "" + Request.QueryString["patente"];

            DateTime _fechaDesde;
            DateTime _fechaHasta;

            //_fechaDesde = Convert.ToDateTime(fechaDesde);
            //_fechaHasta = Convert.ToDateTime(fechaHasta);
            if (DateTime.TryParseExact(fechaDesde.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fechaDesde))
            {
            }
            else
            {
                DateTime.TryParseExact(fechaDesde.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fechaDesde);
            }

            if (DateTime.TryParseExact(fechaHasta.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fechaHasta))
            {
            }
            else
            {
                DateTime.TryParseExact(fechaHasta.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fechaHasta);
            }

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetPosicionesGPS_Ruta(_fechaDesde, _fechaHasta, patente));

            Response.Write(_response);
        }

        public void GetInformeViajes()
        {
            string userName = Utilities.GetUsuarioSession(Session);

            string desde = "" + Request.QueryString["desde"];
            string hasta = "" + Request.QueryString["hasta"];
            string nroTransporte = "" + Request.QueryString["nroTransporte"];
            string nroOS = "" + Request.QueryString["nroOS"];
            string patente = "" + Request.QueryString["patente"];
            string transportista = "" + Request.QueryString["transportista"];
            string tipoEtis = "" + Request.QueryString["tipoEtis"];

            DateTime _desde;
            DateTime _hasta;
            int _nroTransporte;
            int _nroOS;

            //DateTime.TryParse(desde, out _desde);
            //DateTime.TryParse(hasta, out _hasta);
            if (DateTime.TryParseExact(desde.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _desde))
            {
            }
            else
            {
                DateTime.TryParseExact(desde.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _desde);
            }

            if (DateTime.TryParseExact(hasta.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _hasta))
            {
            }
            else
            {
                DateTime.TryParseExact(hasta.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _hasta);
            }

            if (nroTransporte == "Todos" || nroTransporte == "")
            {
                _nroTransporte = 0;
            }
            else
            {
                int.TryParse(nroTransporte, out _nroTransporte);
            }


            if (nroOS == "")
            {
                _nroOS = 0;
            }
            else
            {
                int.TryParse(nroOS, out _nroOS);
            }

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetInformeViajes(_desde, _hasta, _nroTransporte, _nroOS, patente, transportista, userName, tipoEtis));

            Response.Write(_response);
        }

        public void GetDetalleTrayecto()
        {
            string nroTransporte = "" + Request.QueryString["nroTransporte"];

            int _nroTransporte;

            int.TryParse(nroTransporte, out _nroTransporte);


            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetDetalleTrayecto(_nroTransporte));

            Response.Write(_response);
        }

        public void GetNroTransportes()
        {
            string _todos = "" + Request.QueryString["Todos"];

            string fechaDesde = "" + Request.QueryString["desde"];
            string fechaHasta = "" + Request.QueryString["hasta"];

            DateTime _fechaDesde;
            DateTime _fechaHasta;

            //DateTime.TryParse(fechaDesde, out _fechaDesde);
            //DateTime.TryParse(fechaHasta, out _fechaHasta);
            if (DateTime.TryParseExact(fechaDesde.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fechaDesde))
            {
            }
            else
            {
                DateTime.TryParseExact(fechaDesde.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fechaDesde);
            }

            if (DateTime.TryParseExact(fechaHasta.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fechaHasta))
            {
            }
            else
            {
                DateTime.TryParseExact(fechaHasta.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fechaHasta);
            }

            Methods_Viajes _objMethodsViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethodsViajes.GetNroTransportes(_fechaDesde, _fechaHasta));

            Response.Write(_response);

        }

        public void GetFlotaOnline()
        {
            string patente = "" + Request.QueryString["patente"];
            string transportista = "" + Request.QueryString["transportista"];
            //string ignicion = "" + Request.QueryString["ignicion"];
            string estadoViaje = "" + Request.QueryString["estadoViaje"];
            string estadoGPS = "" + Request.QueryString["estadoGPS"];
            string proveedorGPS = "" + Request.QueryString["proveedorGPS"];
            string viajeFragil = "" + Request.QueryString["viajeFragil"];

            int _ignicion = -1;

            //int.TryParse(ignicion, out _ignicion);

            Methods_Viajes _objMethosViajes = new Methods_Viajes();


            string _response = JsonConvert.SerializeObject(_db.GetFlotaOnline_Fragil(patente, transportista, _ignicion, estadoViaje, estadoGPS, proveedorGPS, viajeFragil));

            //string _response = JsonConvert.SerializeObject(_objMethosViajes.GetFlotaOnline_Fragil(patente, transportista, _ignicion, estadoViaje, estadoGPS, proveedorGPS, viajeFragil));

            Response.Write(_response);
        }

        public void GetViajesAsignados()
        {

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetViajesAsignados());

            Response.Write(_response);
        }

        public void GetViajesControlPanel()
        {
            Methods_User _obj = new Methods_User();
            Track_Usuarios _users = new Track_Usuarios();
            string userName = Utilities.GetUsuarioSession(Session);

            string desde = "" + Request.QueryString["desde"];
            string hasta = "" + Request.QueryString["hasta"];
            string nroTransporte = "" + Request.QueryString["nroTransporte"];
            string nroOS = "" + Request.QueryString["nroOS"];
            string nroContenedor = "" + Request.QueryString["nroContenedor"];
            string tipoEtis = "" + Request.QueryString["tipoEtis"];
            string idOrigen = "" + Request.QueryString["idOrigen"];
            string idDestino = "" + Request.QueryString["idDestino"];
            string patente = "" + Request.QueryString["patente"];
            string estadoViaje = "" + Request.QueryString["estadoViaje"];
            string alertas = "" + Request.QueryString["alertas"];
            string cliente = "" + Request.QueryString["cliente"];

            DateTime _desde;
            DateTime _hasta;
            int _nroTransporte;
            int _nroOS;
            int _idOrigen;
            int _idDestino;

            //DateTime.TryParse(desde, out _desde);
            //DateTime.TryParse(hasta, out _hasta);
            if (DateTime.TryParseExact(desde.Replace("-", "/").Substring(0, 10), "dd/MM/yyyy", culture, DateTimeStyles.None, out _desde))
            {
            }
            else
            {
                DateTime.TryParseExact(desde.Replace("T", " ").Substring(0, 10), "yyyy-MM-dd", culture, DateTimeStyles.None, out _desde);
            }

            if (DateTime.TryParseExact(hasta.Replace("-", "/").Substring(0, 10), "dd/MM/yyyy", culture, DateTimeStyles.None, out _hasta))
            {
            }
            else
            {
                DateTime.TryParseExact(hasta.Replace("T", " ").Substring(0, 10), "yyyy-MM-dd", culture, DateTimeStyles.None, out _hasta);
            }

            if (nroTransporte == "Todos" || nroTransporte == "")
            {
                _nroTransporte = 0;
            }
            else
            {
                int.TryParse(nroTransporte, out _nroTransporte);
            }

            if (nroOS == "")
            {
                _nroOS = 0;
            }
            else
            {
                int.TryParse(nroOS, out _nroOS);
            }

            if (idOrigen == "Todos" || idOrigen == "")
            {
                _idOrigen = 0;
            }
            else
            {
                int.TryParse(idOrigen, out _idOrigen);
            }

            if (idDestino == "Todos" || idDestino == "")
            {
                _idDestino = 0;
            }
            else
            {
                int.TryParse(idDestino, out _idDestino);
            }

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetViajesControlPanel(_desde, _hasta, _nroTransporte, _nroOS, nroContenedor, _idOrigen, _idDestino, patente, estadoViaje, alertas, userName, tipoEtis, cliente));

            Response.Write(_response);
        }

        public void EliminarViaje(string nroTransporte, string codLocal)
        {
            int _nroTransporte;
            int _codLoca;

            int.TryParse(nroTransporte, out _nroTransporte);
            int.TryParse(codLocal, out _codLoca);

            Methods_Viajes _obj = new Methods_Viajes();

            string _resp = _obj.EliminarViaje(_nroTransporte, _codLoca);

            Response.Write(_resp);
        }

        public void ValidarMovilCD(string patente)
        {
            Methods_Viajes _obj = new Methods_Viajes();

            int _resp = _obj.ValidarMovilCD(patente);

            Response.Write(_resp);
        }

        public void ValidarNroTransporte(string nroTransporte)
        {
            int _nroTransporte;
            int.TryParse(nroTransporte, out _nroTransporte);

            Methods_Viajes _obj = new Methods_Viajes();

            Response.Write(_obj.ValidarNroTransporte(_nroTransporte).ToString());
        }

        public void NuevoViaje(string nroTransporte, string transportista, string trailer, string tracto, string codOrigen, string codRuta, string rutConductor, string nombreConductor)
        {
            int _nroTransporte;
            int _codOrigen;
            int _codRuta;

            int.TryParse(nroTransporte, out _nroTransporte);
            int.TryParse(codOrigen, out _codOrigen);
            int.TryParse(codRuta, out _codRuta);

            Methods_Viajes _obj = new Methods_Viajes();
            try
            {
                string _resp = _obj.NuevoViaje(_nroTransporte, transportista, trailer, tracto, _codOrigen, _codRuta, rutConductor, nombreConductor);

                Response.Write(_resp);
            }
            catch (Exception)
            {
                Response.Write("Se ha producido un error.");

            }
        }

        public void EditarViaje(string nroTransporte, string transportista, string trailer, string tracto, string codOrigen, string codDestino, string rutConductor, string nombreConductor)
        {
            int _nroTransporte;
            int _codOrigen;
            int _codDestino;

            int.TryParse(nroTransporte, out _nroTransporte);
            int.TryParse(codOrigen, out _codOrigen);
            int.TryParse(codDestino, out _codDestino);

            Methods_Viajes _obj = new Methods_Viajes();
            try
            {
                string _resp = _obj.EditarViaje(_nroTransporte, transportista, trailer, tracto, _codOrigen, _codDestino, rutConductor, nombreConductor);

                Response.Write(_resp);
            }
            catch (Exception)
            {
                Response.Write("Se ha producido un error.");

            }
        }

        public void GetPosicionesRutaModuloMapa()
        {
            string idAlerta = "" + Request.QueryString["IdAlerta"];

            int _idAlerta;

            int.TryParse(idAlerta, out _idAlerta);

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetPosicionesRutaModuloMapa(_idAlerta));

            Response.Write(_response);
        }

        public void GetProveedoresGPS()
        {
            string _todos = "" + Request.QueryString["Todos"];
            string _rutTransportista = "" + Request.QueryString["Transportista"];

            Methods_Viajes _objMethodsViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethodsViajes.GetProveedoresGPS(true, _rutTransportista));

            Response.Write(_response);

        }

        public void GetRutasGeneradas()
        {
            string idRuta = "" + Request.QueryString["IdRuta"];

            int _idRuta;

            int.TryParse(idRuta, out _idRuta);

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetRutasGeneradas(_idRuta));

            Response.Write(_response);
        }

        public void GetDetalleRuta()
        {
            string idRuta = "" + Request.QueryString["IdRuta"];

            int _idRuta;

            int.TryParse(idRuta, out _idRuta);

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetDetalleRuta(_idRuta));

            Response.Write(_response);
        }

        public void EliminarRutaGenerada(string idRuta)
        {
            int _idRuta;
            int.TryParse(idRuta, out _idRuta);

            Methods_Viajes _obj = new Methods_Viajes();

            string _resp = _obj.EliminarRutaGenerada(_idRuta);

            Response.Write(_resp);
        }

        public void EliminarDestinoRuta(string idZona)
        {
            int _idZona;
            int.TryParse(idZona, out _idZona);

            Methods_Viajes _obj = new Methods_Viajes();

            string _resp = _obj.EliminarDestinoRuta(_idZona);

            Response.Write(_resp);
        }

        public void AgregarRutaGenerada(string nombreRuta)
        {
            Methods_Viajes _obj = new Methods_Viajes();

            string _resp = _obj.AgrgarRutaGenerada(nombreRuta);

            Response.Write(_resp);
        }

        public void AgregarDestinoRuta(string idRuta, string idZona)
        {
            int _idRuta;
            int _idZona;

            int.TryParse(idRuta, out _idRuta);
            int.TryParse(idZona, out _idZona);

            Methods_Viajes _obj = new Methods_Viajes();

            string _resp = _obj.AgregarDestinoRuta(_idRuta, _idZona);

            Response.Write(_resp);
        }

        public void CargaViajesExcel()
        {
            Methods_Viajes _obj = new Methods_Viajes();

            HttpContext context = HttpContext.Current;
            if (context.Request.Files.Count > 0)
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("NroTransporte", typeof(string));
                dt.Columns.Add("Transportista", typeof(string));
                dt.Columns.Add("CodOrigen", typeof(string));
                dt.Columns.Add("CodDestino", typeof(string));
                dt.Columns.Add("PatenteTrailer", typeof(string));
                dt.Columns.Add("PatenteTracto", typeof(string));
                dt.Columns.Add("RutConductor", typeof(string));
                dt.Columns.Add("NombreConductor", typeof(string));

                HttpPostedFile archivoSubido = context.Request.Files[0];
                StreamReader file = new StreamReader(context.Request.Files[0].InputStream);

                string[] fileName = archivoSubido.FileName.Split('.');
                string fileExtension = fileName[fileName.Length - 1].ToUpper();
                string rutaSitio = Utilities.GetExePath();

                if (!(Directory.Exists(rutaSitio + "FileTemp")))
                {
                    Directory.CreateDirectory(rutaSitio + "FileTemp");
                }
                string Fechafile = DateTime.Now.ToString("ddMMyyyyHHmmss");
                var fileNameCopy = @"" + rutaSitio + "FileTemp\\ExcelTemp" + Fechafile + "." + fileExtension;
                string result = "";
                try
                {
                    if (fileExtension == "XLS" || fileExtension == "XLSX" || fileExtension == "XLSB")
                    {
                        archivoSubido.SaveAs(fileNameCopy);
                        ExcelQueryFactory xcl = new ExcelQueryFactory(fileNameCopy);
                        var lst = from d in xcl.Worksheet(0) select d;

                        int nroTransporte;
                        string transportista;
                        int codOrigen;
                        int codDestino;
                        string patenteTrailer;
                        string patenteTracto;
                        string rutConductor;
                        string nombreConductor;

                        //if (lst.ToList()[0][0].ToString() != "NroTransporte" || lst.ToList()[0][1].ToString() != "Transportista" || lst.ToList()[0][2].ToString() != "CodOrigen" || lst.ToList()[0][3].ToString() != "CodDestino" || lst.ToList()[0][4].ToString() != "PatenteTrailer" || lst.ToList()[0][5].ToString() != "PatenteTracto" || lst.ToList()[0][6].ToString() != "RutConductor" || lst.ToList()[0][7].ToString() != "NombreConductor")
                        if (lst.ToList()[0][0].ToString() != "NroTransporte" || lst.ToList()[0][1].ToString() != "Transportista" || lst.ToList()[0][2].ToString() != "CodOrigen" || lst.ToList()[0][3].ToString() != "CodDestino" || lst.ToList()[0][4].ToString() != "PatenteTrailer" || lst.ToList()[0][5].ToString() != "PatenteTracto" || lst.ToList()[0][6].ToString() != "RutConductor" || lst.ToList()[0][7].ToString() != "NombreConductor")
                        {
                            result = @"{'success':true,'Data':[], 'result':false}";
                        }
                        else
                        {
                            {
                                for (int i = 1; i < lst.ToList().Count; i++)
                                {
                                    nroTransporte = Convert.ToInt32(lst.ToList()[i][0].ToString());
                                    transportista = lst.ToList()[i][1].ToString();
                                    codOrigen = Convert.ToInt32(lst.ToList()[i][2].ToString());
                                    codDestino = Convert.ToInt32(lst.ToList()[i][3].ToString());
                                    patenteTrailer = lst.ToList()[i][4].ToString();
                                    patenteTracto = lst.ToList()[i][5].ToString();
                                    rutConductor = lst.ToList()[i][6].ToString();
                                    nombreConductor = lst.ToList()[i][7].ToString();

                                    string _resp = _obj.NuevoViajeDestinoUnico(nroTransporte, transportista, codOrigen, codDestino, patenteTrailer, patenteTracto, rutConductor, nombreConductor);

                                }
                                result = @"{'success':true,'Data':[], 'result':false}";
                            }
                        }

                    }

                    Response.Write(result);
                }
                catch (Exception)
                {
                    result = @"{'success':true,'Data':[" + JsonConvert.SerializeObject(dt) + "], 'result':false}";
                    Response.Write(result);
                }
            }
        }

        public void CierreManual(string nroTransporte, string codLocal, string patenteTracto, string patenteTrailer, string estadoLat, string estadoLon)
        {
            Track_Usuarios _users = new Track_Usuarios();
            string userName = Utilities.GetUsuarioSession(Session);

            int _nroTransporte;
            int _codLocal;

            int.TryParse(nroTransporte, out _nroTransporte);
            int.TryParse(codLocal, out _codLocal);

            Methods_Viajes _obj = new Methods_Viajes();

            string _resp = _obj.CierreManual(_nroTransporte, _codLocal, patenteTracto, patenteTrailer, estadoLat, estadoLon, userName);

            Response.Write(_resp);
        }

        public void GetTipoEtis()
        {
            string _todos = "" + Request.QueryString["Todos"];

            Methods_Viajes _objMethodsViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethodsViajes.GetTipoEtis(true));

            Response.Write(_response);

        }

        public void GetClientes()
        {
            string _todos = "" + Request.QueryString["Todos"];

            Methods_Viajes _objMethodsViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethodsViajes.GetClientes(true));

            Response.Write(_response);

        }

        public void GetMonitoreoOnline()
        {
            string nroTransporte = "" + Request.QueryString["nroTransporte"];
            string nroOS = "" + Request.QueryString["nroOS"];
            string tipoEtis = "" + Request.QueryString["tipoEtis"];
            string estadoViaje = "" + Request.QueryString["estadoViaje"];
            string estadoGPS = "" + Request.QueryString["estadoGPS"];
            string transportista = "" + Request.QueryString["transportista"];
            string proveedorGPS = "" + Request.QueryString["proveedorGPS"];
            string patente = "" + Request.QueryString["patente"];
            string rutCliente = "" + Request.QueryString["cliente"];

            string viajeFragil = "" + Request.QueryString["viajeFragil"];

            int _nroTransporte;
            int _nroOS;

            int.TryParse(nroTransporte, out _nroTransporte);
            int.TryParse(nroOS, out _nroOS);
            int _ignicion = -1;

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetMonitoreoOnlineFragil(patente, transportista, _ignicion, estadoViaje, estadoGPS, proveedorGPS, _nroTransporte, _nroOS, tipoEtis, rutCliente, viajeFragil));

            Response.Write(_response);
        }

        public void GetViajesMineria()
        {
            string nroTransporte = "" + Request.QueryString["nroTransporte"];
            string userName = "" + Request.QueryString["userName"];

            //int _nroTransporte;
            //int.TryParse(nroTransporte, out _nroTransporte);

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethosViajes.GetViajesMineria(nroTransporte, userName));

            Response.Write(_response);
        }

        public void GetETA(string estadoLat, string estadoLon, string destinoLat, string destinoLon)
        {
            Utilities _obj = new Utilities();

            string _response = JsonConvert.SerializeObject(_obj.getETA(estadoLat, estadoLon, destinoLat, destinoLon));
            Response.Write(_response);
        }

        public void GetClientesUsuario()
        {
            string username = Session["userName"].ToString();
            string _todos = "" + Request.QueryString["Todos"];
            bool todos = true;

            if (_todos == "False")
            {
                todos = false;
            }

            Methods_Viajes _objMethodsViajes = new Methods_Viajes();

            string _response = JsonConvert.SerializeObject(_objMethodsViajes.GetClientesUsuario(todos, username));

            Response.Write(_response);

        }

    }
}