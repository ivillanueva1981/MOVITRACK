using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BusinessEntities;
using ContextLayer.Model;
using System.Data.Objects;

namespace BusinessLayer
{
  public class Methods_Reportes
  {
    private ModelEntities _context = new ModelEntities();

    public List<Track_GetRpt_KmsRecorridos_Result> GetRpt_KmsRecorridos(DateTime? fecDesde, DateTime? fecHasta, string transportista, string patente)
    {
      try
      {
        List<Track_GetRpt_KmsRecorridos_Result> _listReporte = _context.Track_GetRpt_KmsRecorridos(fecDesde, fecHasta, transportista, patente).ToList();
        return _listReporte;

      }
      catch (Exception)
      {
        return new List<Track_GetRpt_KmsRecorridos_Result>();
      }
    }

    public List<Track_GetRpt_Alertas_Result> GetRpt_Alertas(DateTime? fecDesde, DateTime? fecHasta, string transportista, string patente, string scoreConductor, string rutConductor, string tipoAlerta, int idFormato, int codigoLocal, string permiso, string estadoViaje, string proveedorGPS)
    {
      try
      {
        List<Track_GetRpt_Alertas_Result> _listReporte = _context.Track_GetRpt_Alertas(fecDesde, fecHasta, transportista, patente, scoreConductor, rutConductor, tipoAlerta, idFormato, codigoLocal, permiso, estadoViaje, proveedorGPS).ToList();
        return _listReporte;

      }
      catch (Exception)
      {
        return new List<Track_GetRpt_Alertas_Result>();
      }
    }

    public List<Track_GetDashboard_Result> GetDashboard(int year, int month, string transportista)
    {
      try
      {
        List<Track_GetDashboard_Result> _listReporte = _context.Track_GetDashboard(year, month, transportista).ToList();
        return _listReporte;

      }
      catch (Exception)
      {
        return new List<Track_GetDashboard_Result>();
      }
    }

    public List<FichaConductor> GetConductores(bool _all = false)
    {
      try
      {
        List<FichaConductor> _listConductores = (from c in _context.FichaConductor select c).ToList();
        if (_all)
        {
          FichaConductor newItem = new FichaConductor { Rut = "Todos", DV = "", Nombre = "Todos", Paterno = "" };
          _listConductores.Insert(0, newItem);
        }

        return _listConductores;

      }
      catch (Exception)
      {
        return new List<FichaConductor>();
      }
    }

    public List<Formato> GetFormatos(bool _all = false)
    {
      try
      {
        List<Formato> _listFormatos = (from c in _context.Formato select c).ToList();
        if (_all)
        {
          Formato newItem = new Formato {Id = 0, Nombre = "Todos" };
          _listFormatos.Insert(0, newItem);
        }

        return _listFormatos;

      }
      catch (Exception)
      {
        return new List<Formato>();
      }
    }

    public List<Local> GetLocales()
    {
      try
      {
        List<Local> _listLocales = (from c in _context.Local select c).ToList();
          Local newItem = new Local { CodigoInterno = 0, IdFormato = 0, NumeroLocal = "Todos" };
          _listLocales.Insert(0, newItem);

        return _listLocales;

      }
      catch (Exception)
      {
        return new List<Local>();
      }
    }

    public List<Track_GetRpt_Alertas_DetalleArea_Result> GetRpt_AlertasDetalleArea(DateTime? fecDesde, DateTime? fecHasta, string transportista, string patente, string scoreConductor, string rutConductor, string tipoAlerta, int idFormato, int codigoLocal, string permiso, string estadoViaje, string proveedorGPS, string puntosPolygon)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetRpt_Alertas_DetalleArea_Result> _listReporte = _context.Track_GetRpt_Alertas_DetalleArea(fecDesde, fecHasta, transportista, patente, scoreConductor, rutConductor, tipoAlerta, idFormato, codigoLocal, permiso, estadoViaje, proveedorGPS, puntosPolygon).ToList();
        return _listReporte;

      }
      catch (Exception e)
      {
                Console.WriteLine(e.Message);
                return new List<Track_GetRpt_Alertas_DetalleArea_Result>();
      }
    }

    public List<Track_GetGuiasDespacho_Result> GetGuiasDespacho(DateTime? fecDesde, DateTime? fecHasta, int nroTransporte, int nroOS, string userName)
    {
      try
      {
        ((System.Data.Entity.Infrastructure.IObjectContextAdapter)_context).ObjectContext.CommandTimeout = 120;

        List<Track_GetGuiasDespacho_Result> _listReporte = _context.Track_GetGuiasDespacho(fecDesde, fecHasta, nroTransporte, nroOS, userName).ToList();
        return _listReporte;

      }
      catch (Exception e)
      {
                Console.WriteLine(e.Message);
                return new List<Track_GetGuiasDespacho_Result>();
      }
    }
    
    public List<Track_GetDashboardIntegracion_Result> GetDashboardIntegracion()
    {
      try
      {
        List<Track_GetDashboardIntegracion_Result> _listReporte = _context.Track_GetDashboardIntegracion().ToList();
        return _listReporte;

      }
      catch (Exception)
      {
        return new List<Track_GetDashboardIntegracion_Result>();
      }
    }

    public List<Track_GetDashboardAlertas_Result> GetDashboardAlertas()
    {
      try
      {
        List<Track_GetDashboardAlertas_Result> _listReporte = _context.Track_GetDashboardAlertas().ToList();
        return _listReporte;

      }
      catch (Exception)
      {
        return new List<Track_GetDashboardAlertas_Result>();
      }
    }

    public List<Track_GetDashboardMotivos_Result> GetDashboardMotivos()
    {
      try
      {
        List<Track_GetDashboardMotivos_Result> _listReporte = _context.Track_GetDashboardMotivos().ToList();
        return _listReporte;

      }
      catch (Exception)
      {
        return new List<Track_GetDashboardMotivos_Result>();
      }
    }

    public List<Track_GetDashboardTendenciaIntegracion_Result> GetDashboardTendenciaIntegracion()
    {
      try
      {
        List<Track_GetDashboardTendenciaIntegracion_Result> _listReporte = _context.Track_GetDashboardTendenciaIntegracion().ToList();
        return _listReporte;

      }
      catch (Exception)
      {
        return new List<Track_GetDashboardTendenciaIntegracion_Result>();
      }
    }

    public List<Track_GetDashboardTendenciaAlertas_Result> GetDashboardTendenciaAlertas()
    {
      try
      {
        List<Track_GetDashboardTendenciaAlertas_Result> _listReporte = _context.Track_GetDashboardTendenciaAlertas().ToList();
        return _listReporte;

      }
      catch (Exception)
      {
        return new List<Track_GetDashboardTendenciaAlertas_Result>();
      }
    }

    public List<Track_GetEstadoPatente_Result> GetEstadoPatente(string patente)
    {
      try
      {
        List<Track_GetEstadoPatente_Result> _listReporte = _context.Track_GetEstadoPatente(patente).ToList();
        return _listReporte;

      }
      catch (Exception)
      {
        return new List<Track_GetEstadoPatente_Result>();
      }
    }

    public string GetEstadoPod(string rut)
    {
      try
      {
        var obj = _context.Track_GetEstadoPod(rut).First();
        return obj.Estado;
      }
      catch (Exception ex)
      {
        return ex.Message;
      }
    }

    public List<Track_GetEstadoPodDetalle_Result> GetEstadoPodDetalle(string rut)
    {
      try
      {
        List<Track_GetEstadoPodDetalle_Result> _listPODDetalle = _context.Track_GetEstadoPodDetalle(rut).ToList();
        return _listPODDetalle;

      }
      catch (Exception ex)
      {
                Console.WriteLine(ex.Message);
                return new List<Track_GetEstadoPodDetalle_Result>();
      }
    }

  }
}
