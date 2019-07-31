using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using UtilitiesLayer;
using System.Text;

using BusinessEntities;
using BusinessLayer;
using Newtonsoft.Json;
using System.Globalization;

namespace Track_Web
{
  public partial class ViajesRuta : System.Web.UI.Page
  {
    IFormatProvider culture = new CultureInfo("en-US", true);
    protected void Page_Load(object sender, EventArgs e)
    {
      Utilities.VerifyLoginStatus(Session, Response);

      switch (Request.QueryString["Metodo"])
      {
        case "ExportExcel":
          ExportExcel(Request.Form["desde"].ToString(), Request.Form["hasta"].ToString(), Request.Form["nroTransporte"].ToString(), Request.Form["nroOS"].ToString(), Request.Form["nroContenedor"].ToString(), Request.Form["tipoEtis"].ToString(), Request.Form["patente"].ToString(), Request.Form["estadoViaje"].ToString(), Request.Form["nombreConductor"].ToString());
          return;
        default:
          break;
      }
    }

    public void ExportExcel(string desde, string hasta, string nroTransporte, string nroOS, string nroContenedor, string tipoEtis, string patente, string estadoViaje, string nombreConductor)
    {
      string userName = Utilities.GetUsuarioSession(Session);

      DateTime _desde;
      DateTime _hasta;
      int _nroTransporte;
            int _nroOS;

      string now = DateTime.Now.ToString();
      now = now.Replace(" ", "_");
      now = now.Replace("-", "");
      now = now.Replace(":", "");

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

            Methods_Viajes _objMethosViajes = new Methods_Viajes();

      List<Track_GetViajesHistoricos_Alerce_Result> _viajes = _objMethosViajes.GetViajesHistoricos(_desde, _hasta, _nroTransporte, _nroOS, nroContenedor, patente, estadoViaje, userName, tipoEtis, nombreConductor);

      Response.Clear();
      Response.Buffer = true;
      Response.ContentType = "application/vnd.ms-excel";
      Response.AppendHeader("Content-Disposition", "attachment;filename=ViajesHistoricos_" + now + ".xls");
      Response.Charset = "UTF-8";
      Response.ContentEncoding = Encoding.Default;
      Response.Write(Methods_Export.HTML_ViajesHistoricos(_viajes.ToList()));
      Response.End();
    }
  }
}