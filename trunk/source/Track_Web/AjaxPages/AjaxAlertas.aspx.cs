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

namespace Track_Web.AjaxPages
{
  public partial class AjaxAlertas : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      switch (Request.QueryString["Metodo"])
      {
        case "GetAlertasRuta":
          GetAlertasRuta();
          break;
        case "GetTipoAlertas":
          GetTipoAlertas();
          break;
        case "GuardarCongifAlerta":
          GuardarCongifAlerta(Request.Form["IdTipoAlerta"].ToString(), Request.Form["Control1"].ToString(), Request.Form["Control2"].ToString(), Request.Form["Control3"].ToString(), Request.Form["Control4"].ToString(), Request.Form["Velocidad"].ToString(), Request.Form["alertaActiva"].ToString());
          break;
        case "GetAlertasInformeViaje":
          GetAlertasInformeViaje();
          break;
        case "UpdateObservacionesInformeViaje":
          UpdateObservacionesInformeViaje(Request.Form["idAlerta"].ToString(), Request.Form["nroTransporte"].ToString(), Request.Form["observaciones"].ToString());
          break;
        case "GetGestionCallCenter":
          GetGestionCallCenter();
          break;
        case "GetAlertasPorGestionarCallCenter":
          GetAlertasPorGestionarCallCenter();
          break;
        case "GetNombreTipoAlertas":
          GetNombreTipoAlertas();
          break;
        case "GetAlertasRutaModuloMapa":
          GetAlertasRutaModuloMapa();
          break;
      }
    }

    public void GetAlertasRuta()
    {
      string nroTransporte = "" + Request.QueryString["nroTransporte"];
      string destino = "" + Request.QueryString["destino"];
      string estadoViaje = "" + Request.QueryString["estadoViaje"];

      int _nroTransporte;
      int _destino;

      int.TryParse(nroTransporte, out _nroTransporte);
      int.TryParse(destino, out _destino);

      Methods_Alertas _objMethodsAlertas = new Methods_Alertas();

      string _response = JsonConvert.SerializeObject(_objMethodsAlertas.GetAlertasRuta(_nroTransporte, _destino, estadoViaje));

      Response.Write(_response);
    }

    public void GetTipoAlertas()
    {

      string _result = "";
      Methods_Alertas _obj = new Methods_Alertas();

        var _list = (from i in _obj.GetTipoAlertas()
                     select new
                     {
                       i.IdTipoAlerta,
                       i.NombreTipoAlerta,
                       i.AlertaActiva,
                       i.DescripcionAlerta,
                       i.Control1,
                       i.Control2,
                       i.Control3,
                       i.Control4,
                       i.Valor1,
                       i.InfoAlerta
                     }).ToList();
        _result = JsonConvert.SerializeObject(_list);

      Response.Write(_result);
    }

    public void GuardarCongifAlerta(string idTipoAlerta, string control1, string control2, string control3, string control4, string velocidad, string alertaActiva)
    {
      int _idTipoAlerta;
      int _control1;
      int _control2;
      int _control3;
      int _control4;
      int _velocidad;
      bool _alertaActiva;

      int.TryParse(idTipoAlerta, out _idTipoAlerta);
      int.TryParse(control1, out _control1);
      int.TryParse(control2, out _control2);
      int.TryParse(control3, out _control3);
      int.TryParse(control4, out _control4);
      int.TryParse(velocidad, out _velocidad);
      bool.TryParse(alertaActiva, out _alertaActiva);

      Methods_Alertas _obj = new Methods_Alertas();

      string _result = _obj.GuardarConfigAlerta(_idTipoAlerta, _control1, _control2, _control3, _control4, _velocidad, _alertaActiva);

      Response.Write(_result);
    }

    public void GetAlertasInformeViaje()
    {
      string nroTransporte = "" + Request.QueryString["nroTransporte"];

      int _nroTransporte;

      int.TryParse(nroTransporte, out _nroTransporte);

      Methods_Alertas _objMethodsAlertas = new Methods_Alertas();

      string _response = JsonConvert.SerializeObject(_objMethodsAlertas.GetAlertasInformeViaje(_nroTransporte));

      Response.Write(_response);
    }

    public void UpdateObservacionesInformeViaje(string idAlerta, string nroTransporte, string observaciones)
    {
      int _idAlerta;
      int _nroTransporte;

      int.TryParse(idAlerta, out _idAlerta);
      int.TryParse(nroTransporte, out _nroTransporte);

      Methods_Alertas _objMethodsAlertas = new Methods_Alertas();

      string _response = JsonConvert.SerializeObject(_objMethodsAlertas.UpdateObservacionesInformeViaje(_idAlerta, _nroTransporte, observaciones));

      Response.Write(_response);

    }

    public void GetGestionCallCenter()
    {
      string nroTransporte = "" + Request.QueryString["nroTransporte"];
      string codLocal = "" + Request.QueryString["codLocal"];

      int _nroTransporte;
      int _codLocal;

      int.TryParse(nroTransporte, out _nroTransporte);
      int.TryParse(codLocal, out _codLocal);

      Methods_Alertas _objMethodsAlertas = new Methods_Alertas();

      string _response = JsonConvert.SerializeObject(_objMethodsAlertas.GetGestionCallCenter(_nroTransporte, _codLocal));

      Response.Write(_response);
    }

    public void GetNombreTipoAlertas()
    {

      string _result = "";
      Methods_Alertas _obj = new Methods_Alertas();

      var _list = (from i in _obj.GetTipoAlertas()
                   group i by new { i.NombreTipoAlerta } into groupedTipoAlerta
                   select new
                   {
                     groupedTipoAlerta.FirstOrDefault().NombreTipoAlerta
                   }).ToList();

      //_list.Insert(0, new { NombreTipoAlerta = "Todas" });

      _result = JsonConvert.SerializeObject(_list);

      Response.Write(_result);
    }

    public void GetAlertasPorGestionarCallCenter()
    {
      string nroTransporte = "" + Request.QueryString["nroTransporte"];
      string codLocal = "" + Request.QueryString["codLocal"];

      int _nroTransporte;
      int _codLocal;

      int.TryParse(nroTransporte, out _nroTransporte);
      int.TryParse(codLocal, out _codLocal);

      Methods_Alertas _objMethodsAlertas = new Methods_Alertas();

      string _response = JsonConvert.SerializeObject(_objMethodsAlertas.GetAlertasPorGestionarCallCenter(_nroTransporte, _codLocal));

      Response.Write(_response);
    }

    public void GetAlertasRutaModuloMapa()
    {
      string idAlerta = "" + Request.QueryString["IdAlerta"];

      int _idAlerta;

      int.TryParse(idAlerta, out _idAlerta);

      Methods_Alertas _objMethodsAlertas = new Methods_Alertas();

      string _response = JsonConvert.SerializeObject(_objMethodsAlertas.GetAlertasRutaModuloMapa(_idAlerta));

      Response.Write(_response);
    }

  }
}