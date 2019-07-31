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

namespace Track_Web
{
  public partial class MonitoreoOnline : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      Utilities.VerifyLoginStatus(Session, Response);

      switch (Request.QueryString["Metodo"])
      {
        case "ExportExcel":
          ExportExcel(Request.Form["nroTransporte"].ToString(), Request.Form["nroOS"].ToString(), Request.Form["tipoEtis"].ToString(), Request.Form["estadoViaje"].ToString(), Request.Form["estadoGPS"].ToString(), Request.Form["transportista"].ToString(), Request.Form["proveedorGPS"].ToString(), Request.Form["patente"].ToString(), Request.Form["cliente"].ToString());
          return;
        default:
          break;
      }
    }

    public void ExportExcel(string nroTransporte, string nroOS, string tipoEtis,  string estadoViaje, string estadoGPS, string transportista, string proveedorGPS, string patente, string cliente)
    {
      string now = DateTime.Now.ToString();
      now = now.Replace(" ", "_");
      now = now.Replace("-", "");
      now = now.Replace(":", "");

      int _nroTransporte;

      int.TryParse(nroTransporte, out _nroTransporte);

            int _nroOS;

            int.TryParse(nroOS, out _nroOS);

            int _ignicion = -1;

      Methods_Viajes _objMethosViajes = new Methods_Viajes();

      List<Track_GetMonitoreoOnline_Fragil_Result> _viajes = _objMethosViajes.GetMonitoreoOnlineFragil(patente, transportista, _ignicion, estadoViaje, estadoGPS, proveedorGPS, _nroTransporte, _nroOS, tipoEtis, cliente, "0");

      Response.Clear();
      Response.Buffer = true;
      Response.ContentType = "application/vnd.ms-excel";
      Response.AppendHeader("Content-Disposition", "attachment;filename=MonitoreoOnline_" + now + ".xls");
      Response.Charset = "UTF-8";
      Response.ContentEncoding = Encoding.Default;
      Response.Write(Methods_Export.HTML_MonitoreoOnline(_viajes.ToList()));
      Response.End();
    }
  }
}