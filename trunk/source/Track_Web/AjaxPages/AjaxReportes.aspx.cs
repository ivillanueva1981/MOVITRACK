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
using System.Globalization;

namespace Track_Web.AjaxPages
{
  public partial class AjaxReportes : System.Web.UI.Page
  {
    IFormatProvider culture = new CultureInfo("en-US", true);
    protected void Page_Load(object sender, EventArgs e)
    {
      switch (Request.QueryString["Metodo"])
      {
        case "GetRpt_KmsRecorridos":
          GetRpt_KmsRecorridos();
          break;
        case "GetRpt_Alertas":
          GetRpt_Alertas();
          break;
        case "GetDashboard":
          GetDashboard();
          break;
        case "GetConductores":
          GetConductores();
          break;
        case "GetFormatos":
          GetFormatos();
          break;
        case "GetLocales":
          GetLocales();
          break;
        case "GetRpt_Alertas_DetalleArea":
          GetRpt_Alertas_DetalleArea();
          break;
        case "GetRpt_GuiasDespacho":
          GetRpt_GuiasDespacho();
          break;
        case "GetIntegracionDashboard":
          GetIntegracionDashboard();
          break;
        case "GetAlertasDashboard":
          GetAlertasDashboard();
          break;
        case "GetMotivosDashboard":
          GetMotivosDashboard();
          break;
        case "GetTendenciaIntegracionDashboard":
          GetTendenciaIntegracionDashboard();
          break;
        case "GetTendenciaAlertasDashboard":
          GetTendenciaAlertasDashboard();
          break;
        case "GetEstadoPatente":
          GetEstadoPatente(Request.Form["patente"].ToString());
          break;
        case "GetEstadoPod":
          GetEstadoPod(Request.Form["rut"].ToString());
          break;
        case "GetEstadoPodDetalle":
          GetEstadoPodDetalle();
          break;
      }
    }

    public void GetRpt_KmsRecorridos()
    {
      string fecDesde = "" + Request.QueryString["desde"];
      string fecHasta = "" + Request.QueryString["hasta"];
      string transportista = "" + Request.QueryString["transportista"];
      string patente = "" + Request.QueryString["patente"];

      DateTime _fecDesde;
      DateTime _fecHasta;

      if (DateTime.TryParseExact(fecDesde.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fecDesde))
      {
      }
      else
      {
        DateTime.TryParseExact(fecDesde.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fecDesde);
      }

      if (DateTime.TryParseExact(fecHasta.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fecHasta))
      {
      }
      else
      {
        DateTime.TryParseExact(fecHasta.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fecHasta);
      }

      Methods_Reportes _objMethodsReportes = new Methods_Reportes();

      string _response = JsonConvert.SerializeObject(_objMethodsReportes.GetRpt_KmsRecorridos(_fecDesde, _fecHasta, transportista, patente));

      Response.Write(_response);
    }

    public void GetRpt_Alertas()
    {
      string fecDesde = "" + Request.QueryString["desde"];
      string fecHasta = "" + Request.QueryString["hasta"];
      string transportista = "" + Request.QueryString["transportista"];
      string proveedorGPS = "" + Request.QueryString["proveedorGPS"];
      string patente = "" + Request.QueryString["patente"];
      string scoreConductor = "" + Request.QueryString["scoreConductor"];
      string rutConductor = "" + Request.QueryString["rutConductor"];
      string tipoAlerta = "" + Request.QueryString["tipoAlerta"];
      string idFormato = "" + Request.QueryString["idFormato"];
      string codigoLocal = "" + Request.QueryString["codigoLocal"];
      string permiso = "" + Request.QueryString["permiso"];
      string estadoViaje = "" + Request.QueryString["estadoViaje"];

      int _idFormato;
      int _codigoLocal;
      int.TryParse(idFormato, out _idFormato);
      int.TryParse(codigoLocal, out _codigoLocal);

      DateTime _fecDesde;
      DateTime _fecHasta;

      if (DateTime.TryParseExact(fecDesde.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fecDesde))
      {
      }
      else
      {
        DateTime.TryParseExact(fecDesde.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fecDesde);
      }

      if (DateTime.TryParseExact(fecHasta.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fecHasta))
      {
      }
      else
      {
        DateTime.TryParseExact(fecHasta.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fecHasta);
      }

      Methods_Reportes _objMethodsReportes = new Methods_Reportes();

      string _response = JsonConvert.SerializeObject(_objMethodsReportes.GetRpt_Alertas(_fecDesde, _fecHasta, transportista, patente, scoreConductor, rutConductor, tipoAlerta, _idFormato, _codigoLocal, permiso, estadoViaje, proveedorGPS));

      Response.Write(_response);
    }

    public void GetDashboard()
    {
      string year = "" + Request.QueryString["year"];
      string month = "" + Request.QueryString["month"];
      string transportista = "" + Request.QueryString["transportista"];

      int _year;
      int _month;

      int.TryParse(year, out _year);
      int.TryParse(month, out _month);

      Methods_Reportes _objMethodsReportes = new Methods_Reportes();

      string _response = JsonConvert.SerializeObject(_objMethodsReportes.GetDashboard(_year, _month, transportista));

      Response.Write(_response);
    }

    public void GetConductores()
    {
      string _todos = "" + Request.QueryString["Todos"];
      string _result = "";
      Methods_Reportes _obj = new Methods_Reportes();

      if (_todos == "True")
      {
        var _list = (from i in _obj.GetConductores(true)
                     select new
                     {
                       RutConductor = (i.Rut == "Todos") ? "Todos" : i.Rut + '-' + i.DV,
                       NombreConductor = i.Nombre + ' ' + i.Paterno
                     }).ToList();
        _result = JsonConvert.SerializeObject(_list);
      }
      else
      {
        var _list = (from i in _obj.GetConductores()
                     select new
                     {
                       RutConductor = (i.Rut == "Todos") ? "Todos" : i.Rut + '-' + i.DV,
                       NombreConductor = i.Nombre + ' ' + i.Paterno
                     }).ToList();
        _result = JsonConvert.SerializeObject(_list);
      }

      Response.Write(_result);
    }

    public void GetFormatos()
    {
      string _todos = "" + Request.QueryString["Todos"];
      string _result = "";
      Methods_Reportes _obj = new Methods_Reportes();

      if (_todos == "True")
      {
        var _list = (from i in _obj.GetFormatos(true)
                     select new
                     {
                       Id = i.Id,
                       Nombre = i.Nombre
                     }).ToList();
        _result = JsonConvert.SerializeObject(_list);
      }
      else
      {
        var _list = (from i in _obj.GetConductores()
                     select new
                     {
                       Id = i.Id,
                       Nombre = i.Nombre
                     }).ToList();
        _result = JsonConvert.SerializeObject(_list);
      }

      Response.Write(_result);
    }

    public void GetLocales()
    {
      string  idFormato  = "" +  Request.QueryString["IdFormato"];

      if (idFormato == null || idFormato == "")
        {
        idFormato = "0";
      }

      string _result = "";

      int _idFormato;
      int.TryParse(idFormato, out _idFormato);

      Methods_Reportes _obj = new Methods_Reportes();

      if (_idFormato == 0)
      {
        var _list = (from i in _obj.GetLocales()
                     orderby (i.CodigoInterno)
                     select new
                     {
                       CodigoInterno = i.CodigoInterno,
                       IdFormato = i.Id,
                       NumeroLocal = i.NumeroLocal
                     }).ToList();
        _result = JsonConvert.SerializeObject(_list);
      }
      else
      {
        var _list = (from i in _obj.GetLocales()
                     where i.CodigoInterno == 0 || i.IdFormato == _idFormato
                     orderby (i.CodigoInterno)
                     select new
                     {
                       CodigoInterno = i.CodigoInterno,
                       IdFormato = i.Id,
                       NumeroLocal = i.NumeroLocal
                     }).ToList();
        _result = JsonConvert.SerializeObject(_list);
      }

      Response.Write(_result);
    }

    public void GetRpt_Alertas_DetalleArea()
    {
      string fecDesde = "" + Request.QueryString["desde"];
      string fecHasta = "" + Request.QueryString["hasta"];
      string transportista = "" + Request.QueryString["transportista"];
      string proveedorGPS = "" + Request.QueryString["proveedorGPS"];
      string patente = "" + Request.QueryString["patente"];
      string scoreConductor = "" + Request.QueryString["scoreConductor"];
      string rutConductor = "" + Request.QueryString["rutConductor"];
      string tipoAlerta = "" + Request.QueryString["tipoAlerta"];
      string idFormato = "" + Request.QueryString["idFormato"];
      string codigoLocal = "" + Request.QueryString["codigoLocal"];
      string permiso = "" + Request.QueryString["permiso"];
      string estadoViaje = "" + Request.QueryString["estadoViaje"];
      string puntosPolygon = "" + Request.QueryString["vertices"];

      int _idFormato;
      int _codigoLocal;
      int.TryParse(idFormato, out _idFormato);
      int.TryParse(codigoLocal, out _codigoLocal);

      DateTime _fecDesde;
      DateTime _fecHasta;

      if (DateTime.TryParseExact(fecDesde.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fecDesde))
      {
      }
      else
      {
        DateTime.TryParseExact(fecDesde.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fecDesde);
      }

      if (DateTime.TryParseExact(fecHasta.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fecHasta))
      {
      }
      else
      {
        DateTime.TryParseExact(fecHasta.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fecHasta);
      }

      Methods_Reportes _objMethodsReportes = new Methods_Reportes();

      string _response = JsonConvert.SerializeObject(_objMethodsReportes.GetRpt_AlertasDetalleArea(_fecDesde, _fecHasta, transportista, patente, scoreConductor, rutConductor, tipoAlerta, _idFormato, _codigoLocal, permiso, estadoViaje, proveedorGPS, puntosPolygon));

      Response.Write(_response);
    }

        public void GetRpt_GuiasDespacho()
        {
            Track_Usuarios _users = new Track_Usuarios();
            string userName = Utilities.GetUsuarioSession(Session);

            string fecDesde = "" + Request.QueryString["desde"];
            string fecHasta = "" + Request.QueryString["hasta"];
            string nroTransporte = "" + Request.QueryString["nroTransporte"];
            string nroOS = "" + Request.QueryString["nroOS"];

            DateTime _fecDesde;
            DateTime _fecHasta;

            if (DateTime.TryParseExact(fecDesde.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fecDesde))
            {
            }
            else
            {
                DateTime.TryParseExact(fecDesde.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fecDesde);
            }

            if (DateTime.TryParseExact(fecHasta.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fecHasta))
            {
            }
            else
            {
                DateTime.TryParseExact(fecHasta.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fecHasta);
            }

            int _nroTransporte;
            int _nroOS;

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

            Methods_Reportes _objMethodsReportes = new Methods_Reportes();

      string _response = JsonConvert.SerializeObject(_objMethodsReportes.GetGuiasDespacho(_fecDesde, _fecHasta, _nroTransporte, _nroOS, userName));

      Response.Write(_response);
    }

    public void GetIntegracionDashboard()
    {
      Methods_Reportes _objMethodsReportes = new Methods_Reportes();

      string _response = JsonConvert.SerializeObject(_objMethodsReportes.GetDashboardIntegracion());

      Response.Write(_response);
    }

    public void GetAlertasDashboard()
    {
      Methods_Reportes _objMethodsReportes = new Methods_Reportes();

      string _response = JsonConvert.SerializeObject(_objMethodsReportes.GetDashboardAlertas());

      Response.Write(_response);
    }

    public void GetMotivosDashboard()
    {
      Methods_Reportes _objMethodsReportes = new Methods_Reportes();

      string _response = JsonConvert.SerializeObject(_objMethodsReportes.GetDashboardMotivos());

      Response.Write(_response);
    }

    public void GetTendenciaIntegracionDashboard()
    {
      Methods_Reportes _objMethodsReportes = new Methods_Reportes();

      string _response = JsonConvert.SerializeObject(_objMethodsReportes.GetDashboardTendenciaIntegracion());

      Response.Write(_response);
    }

    public void GetTendenciaAlertasDashboard()
    {
      Methods_Reportes _objMethodsReportes = new Methods_Reportes();

      string _response = JsonConvert.SerializeObject(_objMethodsReportes.GetDashboardTendenciaAlertas());

      Response.Write(_response);
    }

    public void GetEstadoPatente(string patente)
    {
      Methods_Reportes _objMethodsReportes = new Methods_Reportes();

      string _response = JsonConvert.SerializeObject(_objMethodsReportes.GetEstadoPatente(patente));

      Response.Write(_response);
    }
    public void GetEstadoPod(string rut)
    {

      try
      {
        Methods_Reportes blReportes = new Methods_Reportes();
        string estado = blReportes.GetEstadoPod(rut);
        Response.Write(estado);
      }
      catch (Exception ex)
      {
        Response.Write(ex.Message);
      }
    }

    public void GetEstadoPodDetalle()
    {

      try
      {
        string rut = "" + Request.QueryString["rut"];

        Methods_Reportes blReportes = new Methods_Reportes();
        string estado = JsonConvert.SerializeObject(blReportes.GetEstadoPodDetalle(rut));
        Response.Write(estado);
      }
      catch (Exception ex)
      {
        Response.Write(ex.Message);
      }
    }
  }
}