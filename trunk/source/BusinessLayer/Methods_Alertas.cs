using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BusinessEntities;
using ContextLayer.Model;
using System.Data.Objects;

namespace BusinessLayer
{
  public class Methods_Alertas
  {
    private ModelEntities _context = new ModelEntities();

    public List<Track_GetAlertasRuta_Result> GetAlertasRuta(int nroTransporte, int destino, string estadoViaje)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetAlertasRuta_Result> _listAlertas = _context.Track_GetAlertasRuta(nroTransporte, destino, estadoViaje).ToList();
        return _listAlertas;

      }
      catch (Exception e)
      {
                Console.WriteLine(e.Message);
                return new List<Track_GetAlertasRuta_Result>();
      }
    }

    public List<Track_TipoAlertas> GetTipoAlertas(bool _all = false)
    {
      try
      {
        List<Track_TipoAlertas> _listTipoAlertas = (from c in _context.Track_TipoAlertas select c).ToList();

        return _listTipoAlertas;

      }
      catch (Exception)
      {
        return new List<Track_TipoAlertas>();
      }
    }

    public string GuardarConfigAlerta(int idTipoAlerta, int control1, int control2, int control3, int control4, int velocidad, bool alertaActiva)
    {
      try
      {
        Track_TipoAlertas _tipoalertas = new Track_TipoAlertas();
        var res = (from a in _context.Track_TipoAlertas where a.IdTipoAlerta == idTipoAlerta select a).FirstOrDefault();
        res.Control1 = control1;
        res.Control2 = control2;
        res.Control3 = control3;
        res.Control4 = control4;
        res.Valor1 = velocidad;
        res.AlertaActiva = alertaActiva;

        _context.SaveChanges();

        return "Configuración guardada satisfactoriamente.";
      }
      catch (Exception)
      {
        return "Se ha producido un error.";
      }
    }

    public List<Track_GetAlertasInformeViaje_Result> GetAlertasInformeViaje(int nroTransporte)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetAlertasInformeViaje_Result> _listAlertas = _context.Track_GetAlertasInformeViaje(nroTransporte).ToList();

        return _listAlertas;

      }
      catch (Exception)
      {
        return new List<Track_GetAlertasInformeViaje_Result>();
      }
    }

    public string UpdateObservacionesInformeViaje(int idAlerta, int nroTransporte, string observaciones)
    {
      try
      {
        string result = _context.Track_UpdateObservacionesInformeViaje(idAlerta, nroTransporte, observaciones).FirstOrDefault().Respuesta;
        return result;

      }
      catch (Exception)
      {
        return "Se ha producido un error.";
      }
    }

    public List<Track_GetGestionCallCenter_Result> GetGestionCallCenter(int nroTransporte, int codLocal)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 180;

        List<Track_GetGestionCallCenter_Result> _listAlertas = _context.Track_GetGestionCallCenter(nroTransporte, codLocal).ToList();

        return _listAlertas;

      }
      catch (Exception)
      {
        return new List<Track_GetGestionCallCenter_Result>();
      }
    }

    public List<Track_GetAlertasPorGestionarCallCenter_Result> GetAlertasPorGestionarCallCenter(int nroTransporte, int codLocal)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetAlertasPorGestionarCallCenter_Result> _listAlertas = _context.Track_GetAlertasPorGestionarCallCenter(nroTransporte, codLocal).ToList();

        return _listAlertas;

      }
      catch (Exception)
      {
        return new List<Track_GetAlertasPorGestionarCallCenter_Result>();
      }
    }

    public List<Track_GetAlertasRutaModuloMapa_Result> GetAlertasRutaModuloMapa(int idAlerta)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetAlertasRutaModuloMapa_Result> _listAlertas = _context.Track_GetAlertasRutaModuloMapa(idAlerta).ToList();
        return _listAlertas;

      }
      catch (Exception)
      {
        return new List<Track_GetAlertasRutaModuloMapa_Result>();
      }
    }

  }
}
