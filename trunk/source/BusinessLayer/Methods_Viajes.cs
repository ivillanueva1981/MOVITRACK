using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BusinessEntities;
using ContextLayer.Model;
using System.Data.Objects;
using System.Web.SessionState;
using UtilitiesLayer;
using CrossCutting;
using System.Configuration;
using System.Globalization;

namespace BusinessLayer
{
  public class Methods_Viajes
  {
    private ModelEntities _context = new ModelEntities();

    public List<Track_GetViajesRuta_Result> GetViajesRuta(int nroTransporte, string patente, string estadoViaje, string transportista)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetViajesRuta_Result> _listViajes = _context.Track_GetViajesRuta(nroTransporte, patente, estadoViaje, transportista).ToList();
        return _listViajes;

      }
      catch (Exception)
      {
        return new List<Track_GetViajesRuta_Result>();
      }
    }

    public List<Track_GetNroTransportesRuta_Result> GetNroTransportesRuta()
    {
      try
      {
        List<Track_GetNroTransportesRuta_Result> _listNroTransportes = _context.Track_GetNroTransportesRuta().ToList();
        return _listNroTransportes;

      }
      catch (Exception)
      {
        return new List<Track_GetNroTransportesRuta_Result>();
      }
    }

    public List<Track_GetPatentesRuta_Result> GetPatentesRuta()
    {
      try
      {
        List<Track_GetPatentesRuta_Result> _listPatentesRuta = _context.Track_GetPatentesRuta().ToList();
        return _listPatentesRuta;

      }
      catch (Exception)
      {
        return new List<Track_GetPatentesRuta_Result>();
      }
    }

    public List<Track_GetTransportistasRuta_Result> GetTransportistasRuta()
    {
      try
      {
        List<Track_GetTransportistasRuta_Result> _listTransportistasRuta = _context.Track_GetTransportistasRuta().ToList();
        return _listTransportistasRuta;

      }
      catch (Exception)
      {
        return new List<Track_GetTransportistasRuta_Result>();
      }
    }

    public List<Track_GetPosicionesRuta_Result> GetPosicionesRuta(string patenteTracto, string patenteTrailer, DateTime? fechaHoraCreacion, DateTime? fechaHoraSalidaOrigen, DateTime? fechaHoraLlegadaDestino, int nroTransporte, int destino, string estadoViaje)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetPosicionesRuta_Result> _listaPosicionesRuta = _context.Track_GetPosicionesRuta(patenteTracto, patenteTrailer, fechaHoraCreacion, fechaHoraSalidaOrigen, fechaHoraLlegadaDestino, nroTransporte, destino, estadoViaje).ToList();
        return _listaPosicionesRuta;
      }
      catch (Exception e)
      {
        CommonUtilities.WriteInfo("Message: " + e.Message + " Inner Exception: " + e.InnerException + " StackTrace: " + e.StackTrace, CommonUtilities.EventType.Error, ConfigurationManager.AppSettings["LogPath"].ToString(), true);
        return new List<Track_GetPosicionesRuta_Result>();
      }
    }

    public List<Track_Movil> GetAllPatentes(string transportista, bool _all = false)
    {
      try
      {
        List<Track_Movil> _listaPatentes = (from c in _context.Track_Movil where (c.Transportista == transportista || transportista == "Todos" || transportista == "") select c).ToList();
        if (_all)
        {
          Track_Movil newItem = new Track_Movil { Patente = "Todas"};
          _listaPatentes.Insert(0, newItem);
        }

        return _listaPatentes;

      }
      catch (Exception)
      {
        return new List<Track_Movil>();
      }
    }

    //////////public List<Track_Movil> GetAllTransportistas(bool _all, HttpSessionState _session)
    //////////{
    //////////  try
    //////////  {
    //////////    List<Track_Movil> _listaTransportistas = new List<Track_Movil>();
    //////////    string transportista = Utilities.GetTransportistaSession(_session);

    //////////    if (transportista != "")
    //////////    {
    //////////      Track_Movil newItem = new Track_Movil { Transportista = transportista };
    //////////      _listaTransportistas.Insert(0, newItem);
    //////////    }
    //////////    else
    //////////    {
    //////////      _listaTransportistas = (from c in _context.Track_Movil select c).ToList();
    //////////      if (_all)
    //////////      {
    //////////        Track_Movil newItem = new Track_Movil { Transportista = "Todos" };
    //////////        _listaTransportistas.Insert(0, newItem);
    //////////      }
    //////////    }
    //////////    return _listaTransportistas;

    //////////  }
    //////////  catch (Exception)
    //////////  {
    //////////    return new List<Track_Movil>();
    //////////  }
    //////////}

    public List<Track_GetViajesHistoricos_Alerce_Result> GetViajesHistoricos(DateTime desde, DateTime hasta, int nroTransporte, int nroOS, string nroContenedor, string patente, string estadoViaje, string userName, string tipoEtis, string nombreConductor)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetViajesHistoricos_Alerce_Result> _listViajes = _context.Track_GetViajesHistoricos_Alerce(desde, hasta, nroTransporte, nroOS, nroContenedor, patente, estadoViaje, userName, tipoEtis, nombreConductor).ToList();
        return _listViajes;

      }
      catch (Exception)
      {
        return new List<Track_GetViajesHistoricos_Alerce_Result>();
      }
    }

    public List<Track_GetPosicionesGPS_Result> GetPosicionesGPS(DateTime fechaDesde, DateTime fechaHasta, string patente)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetPosicionesGPS_Result> _listaPosicionesGPS = _context.Track_GetPosicionesGPS(fechaDesde, fechaHasta, patente).ToList();
        return _listaPosicionesGPS;

      }
      catch (Exception)
      {
        return new List<Track_GetPosicionesGPS_Result>();
      }
    }

    public List<Track_GetPosicionesGPS_Ruta_Result> GetPosicionesGPS_Ruta(DateTime fechaDesde, DateTime fechaHasta, string patente)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetPosicionesGPS_Ruta_Result> _listaPosicionesGPS_Ruta = _context.Track_GetPosicionesGPS_Ruta(fechaDesde, fechaHasta, patente).ToList();
        return _listaPosicionesGPS_Ruta;

      }
      catch (Exception)
      {
        return new List<Track_GetPosicionesGPS_Ruta_Result>();
      }
    }

    public List<Track_GetInformeViajes_Result> GetInformeViajes(DateTime desde, DateTime hasta, int nroTransporte, int nroOS, string patente, string transportista, string userName, string tipoEtis)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetInformeViajes_Result> _listViajes = _context.Track_GetInformeViajes(desde, hasta, transportista, patente, nroTransporte, nroOS, userName, tipoEtis).ToList();
        return _listViajes;

      }
      catch (Exception)
      {
        return new List<Track_GetInformeViajes_Result>();
      }
    }

    public List<Track_GetDetalleTrayecto_Result> GetDetalleTrayecto(int nroTransporte)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetDetalleTrayecto_Result> _listaDetalleTrayecto = _context.Track_GetDetalleTrayecto(nroTransporte).ToList();
        return _listaDetalleTrayecto;

      }
      catch (Exception)
      {
        return new List<Track_GetDetalleTrayecto_Result>();
      }
    }

    public List<Track_GetNroTransportes_Result> GetNroTransportes(DateTime desde, DateTime hasta)
    {
      try
      {
        List<Track_GetNroTransportes_Result> _listNroTransportes = _context.Track_GetNroTransportes(desde, hasta).ToList();
        return _listNroTransportes;

      }
      catch (Exception)
      {
        return new List<Track_GetNroTransportes_Result>();
      }
    }

    public List<Track_GetFlotaOnline_Result> GetFlotaOnline(string patente, string transportista, int ignicion, string estadoViaje, string estadoGPS, string proveedorGPS)
    {
      try
      {
        List<Track_GetFlotaOnline_Result> _listaFlotaOnline = _context.Track_GetFlotaOnline(patente, transportista, ignicion, estadoViaje, estadoGPS, proveedorGPS).ToList();
        return _listaFlotaOnline;

      }
      catch (Exception)
      {
        return new List<Track_GetFlotaOnline_Result>();
      }
    }

        public List<Track_GetFlotaOnline_Fragil_Result> GetFlotaOnline_Fragil(string patente, string transportista, int ignicion, string estadoViaje, string estadoGPS, string proveedorGPS, string viajeFragil)
        {
            try
            {
                ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 1200;
                List<Track_GetFlotaOnline_Fragil_Result> _listaFlotaOnline =new List<Track_GetFlotaOnline_Fragil_Result>() ;

                //List<Track_GetFlotaOnline_Fragil_Result> _listaFlotaOnline = _context.Track_GetFlotaOnline_Fragil(patente, transportista, ignicion, estadoViaje, estadoGPS, proveedorGPS, viajeFragil).ToList();
                return _listaFlotaOnline;

            }
            catch (Exception)
            {
                return new List<Track_GetFlotaOnline_Fragil_Result>();
            }
        }

        public List<Track_GetViajesAsignados_Result> GetViajesAsignados()
    {
      try
      {
        List<Track_GetViajesAsignados_Result> _listViajes = _context.Track_GetViajesAsignados().ToList();
        return _listViajes;

      }
      catch (Exception)
      {
        return new List<Track_GetViajesAsignados_Result>();
      }
    }

    public List<Track_GetViajesControlPanel_Alerce_Result> GetViajesControlPanel(DateTime desde, DateTime hasta, int nroTransporte, int nroOrdenServicio, string nroContenedor, int idOrigen, int idDestino, string patente, string estadoViaje, string alertas, string userName, string tipoEtis, string cliente)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetViajesControlPanel_Alerce_Result> _listViajes = _context.Track_GetViajesControlPanel_Alerce(desde, hasta, nroTransporte, nroOrdenServicio, nroContenedor, idOrigen, idDestino, patente, estadoViaje, alertas, userName, tipoEtis, cliente).ToList();
        return _listViajes;

      }
      catch (Exception e)
      {
                Console.WriteLine(e.Message);
                return new List<Track_GetViajesControlPanel_Alerce_Result>();
      }
    }

    public string EliminarViaje(int nroTransporte, int codLocal)
    {
      try
      {

        string _resp = _context.Track_EliminarViaje(nroTransporte, codLocal).FirstOrDefault().Respuesta;

        return _resp;
      }
      catch (Exception)
      {
        return "Error al intentar eliminar el viaje.";
      }
    }

    public int ValidarMovilCD(string patente)
    {
      try
      {
        int _resp = _context.Track_ValidarMovilCD(patente).FirstOrDefault().Respuesta.Value;

        return _resp;
      }
      catch (Exception)
      {
        return -1;
      }
    }

    public bool ValidarNroTransporte(int nroTransporte)
    {
      try
      {
        TrazaViaje _existe = _context.TrazaViaje.Where(C => C.NroTransporte == nroTransporte).FirstOrDefault();

        if (_existe != null)
        {
          return false;
        }

        return true;
      }
      catch (Exception)
      {
        return false;
      }
    }

    public string NuevoViaje(int nroTransporte, string transportista, string trailer, string tracto, int codOrigen, int codRuta, string rutConductor, string nombreConductor)
    {
      try
      {

        string _resp = _context.Track_NuevoViaje(nroTransporte, transportista, trailer, tracto, codOrigen, codRuta, rutConductor, nombreConductor).FirstOrDefault().Respuesta;

        return _resp;
      }
      catch (Exception e)
      {
                Console.WriteLine(e.Message);
                return "Se ha producido un error.";
      }
    }

    public string EditarViaje(int nroTransporte, string transportista, string trailer, string tracto, int codOrigen, int codDestino, string rutConductor, string nombreConductor)
    {
      try
      {

        string _resp = _context.Track_EditarViaje(nroTransporte, transportista, trailer, tracto, codOrigen, codDestino, rutConductor, nombreConductor).FirstOrDefault().Respuesta;

        return _resp;
      }
      catch (Exception)
      {
        return "Se ha producido un error.";
      }
    }

    public List<Track_GetPosicionesRutaModuloMapa_Result> GetPosicionesRutaModuloMapa(int idAlerta)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetPosicionesRutaModuloMapa_Result> _listaPosicionesRuta = _context.Track_GetPosicionesRutaModuloMapa(idAlerta).ToList();
        return _listaPosicionesRuta;

      }
      catch (Exception)
      {
        return new List<Track_GetPosicionesRutaModuloMapa_Result>();
      }
    }

    public List<Track_GetProveedoresGPS_Result> GetProveedoresGPS(bool _all, string rutTransportista)
    {
      try
      {
        List<Track_GetProveedoresGPS_Result> _listProveedores = _context.Track_GetProveedoresGPS(rutTransportista).ToList();

        if (_all)
        {
          Track_GetProveedoresGPS_Result item = new Track_GetProveedoresGPS_Result { ProveedorGPS = "Todos" };
          _listProveedores.Insert(0, item);
        }

        return _listProveedores;

      }
      catch (Exception)
      {
        return new List<Track_GetProveedoresGPS_Result>();
      }
    }

    public List<Track_GetRutasGeneradas_Result> GetRutasGeneradas(int idRuta)
    {
      try
      {
        List<Track_GetRutasGeneradas_Result> _listRutas = _context.Track_GetRutasGeneradas(idRuta).ToList();
        return _listRutas;

      }
      catch (Exception)
      {
        return new List<Track_GetRutasGeneradas_Result>();
      }
    }

    public List<Track_GetDetalleRuta_Result> GetDetalleRuta(int idRuta)
    {
      try
      {
        List<Track_GetDetalleRuta_Result> _listDetalleRuta = _context.Track_GetDetalleRuta(idRuta).ToList();
        return _listDetalleRuta;

      }
      catch (Exception)
      {
        return new List<Track_GetDetalleRuta_Result>();
      }
    }

    public string EliminarRutaGenerada(int IdRuta)
    {
      try
      {
        string _resp = _context.Track_EliminarRutaGenerada(IdRuta).FirstOrDefault().ToString();

        return _resp;
      }
      catch (Exception)
      {
        return "Se ha producido un error.";
      }
    }

    public string EliminarDestinoRuta(int IdZona)
    {
      try
      {
        string _resp = _context.Track_EliminarDestinoRuta(IdZona).FirstOrDefault().ToString();

        return _resp;
      }
      catch (Exception)
      {
        return "Se ha producido un error.";
      }
    }

    public string AgrgarRutaGenerada(string nombreRuta)
    {
      try
      {
        string _resp = _context.Track_AgregarRutaGenerada(nombreRuta).FirstOrDefault().ToString();

        return _resp;
      }
      catch (Exception)
      {
        return "Se ha producido un error.";
      }
    }

    public string AgregarDestinoRuta(int idRuta, int idZona)
    {
      try
      {
        string _resp = _context.Track_AgregarDestinoRuta(idRuta, idZona).FirstOrDefault().ToString();

        return _resp;
      }
      catch (Exception)
      {
        return "Se ha producido un error.";
      }
    }

    public string NuevoViajeDestinoUnico(int nroTransporte, string transportista, int codOrigen, int codDestino, string patenteTrailer, string patenteTracto, string rutConductor, string nombreConductor)
    {
      try
      {
        string _resp = _context.Track_NuevoViajeDestinoUnico(nroTransporte, transportista, patenteTrailer, patenteTracto, codOrigen, codDestino, rutConductor, nombreConductor).FirstOrDefault().Respuesta;

        return _resp;
      }
      catch (Exception)
      {
        return "Se ha producido un error.";
      }
    }


    public string CierreManual(int nroTransporte, int codLocal, string patenteTracto, string patenteTrailer, string estadolat, string estadoLon, string userName)
    {
      try
      {
        string _resp = _context.Track_CierreManual(nroTransporte, codLocal, patenteTracto, patenteTrailer, estadolat, estadoLon, userName).FirstOrDefault().Respuesta;

        return _resp;
      }
      catch (Exception)
      {
        return "Se ha producido un error.";
      }
    }

    public List<Track_GetTipoEtis_Result> GetTipoEtis(bool _all)
    {
      try
      {
        List<Track_GetTipoEtis_Result> _listEtis = _context.Track_GetTipoEtis().ToList();

        if (_all)
        {
          Track_GetTipoEtis_Result item = new Track_GetTipoEtis_Result { ETIS = "Todas" };
          _listEtis.Insert(0, item);
        }

        return _listEtis;

      }
      catch (Exception)
      {
        return new List<Track_GetTipoEtis_Result>();
      }
    }

    public List<Track_GetClientes_Result> GetClientes(bool _all)
    {
      try
      {
        List<Track_GetClientes_Result> _listClientes = _context.Track_GetClientes().ToList();

        if (_all)
        {
          Track_GetClientes_Result item = new Track_GetClientes_Result { RutCliente = "Todos", NombreCliente = "Todos" };
          _listClientes.Insert(0, item);
        }

        return _listClientes;

      }
      catch (Exception)
      {
        return new List<Track_GetClientes_Result>();
      }
    }
        // se actualiza por getMonitoreoOnlineFragil si hubiera cualquier problema volver a este, si ya ES MAS DE 12-04-2018 Quitar GetMoniteroOnline como limpieza
        public List<Track_GetMonitoreoOnline_Result> GetMonitoreoOnline(string patente, string transportista, int ignicion, string estadoViaje, string estadoGPS, string proveedorGPS, int nroTransporte, string tipoEtis, string rutCliente)
    {
      try
      {
        List<Track_GetMonitoreoOnline_Result> _listaMonitoreoOnline = _context.Track_GetMonitoreoOnline(patente, transportista, ignicion, estadoViaje, estadoGPS, proveedorGPS, nroTransporte, tipoEtis, rutCliente).ToList();
        return _listaMonitoreoOnline;

      }
      catch (Exception)
      {
        return new List<Track_GetMonitoreoOnline_Result>();
      }
    }
        public List<Track_GetMonitoreoOnline_Fragil_Result> GetMonitoreoOnlineFragil(string patente, string transportista, int ignicion, string estadoViaje, string estadoGPS, string proveedorGPS, int nroTransporte, int nroOS, string tipoEtis, string rutCliente,string viajeFragil)
        {
            try
            {
                ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 1200;

                List<Track_GetMonitoreoOnline_Fragil_Result> _listaMonitoreoOnline = _context.Track_GetMonitoreoOnline_Fragil(patente, transportista, ignicion, estadoViaje, estadoGPS, proveedorGPS, nroTransporte, /*nroOS,*/ tipoEtis, viajeFragil, rutCliente).ToList();
                return _listaMonitoreoOnline;

            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                return new List<Track_GetMonitoreoOnline_Fragil_Result>();
            }
        }

        public List<Track_GetViajesMineria_Result> GetViajesMineria(string  nroTransporte, string userName)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetViajesMineria_Result> _listViajes = _context.Track_GetViajesMineria(nroTransporte, userName).ToList();
        return _listViajes;

      }
      catch (Exception)
      {
        return new List<Track_GetViajesMineria_Result>();
      }
    }

        public List<Track_GetClientesUsuario_Result> GetClientesUsuario(bool _all, string userName)
        {
            try
            {
                List<Track_GetClientesUsuario_Result> _listClientes = _context.Track_GetClientesUsuario(userName).ToList();

                if (_all)
                {
                    Track_GetClientesUsuario_Result item = new Track_GetClientesUsuario_Result { RutCliente = "Todos", NombreCliente = "Todos" };
                    _listClientes.Insert(0, item);
                }

                return _listClientes;

            }
            catch (Exception)
            {
                return new List<Track_GetClientesUsuario_Result>();
            }
        }

    }
}
