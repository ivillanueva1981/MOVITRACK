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
  public partial class FlotaOnline : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      Utilities.VerifyLoginStatus(Session, Response);

      switch (Request.QueryString["Metodo"])
      {
        case "ExportExcel":
          ExportExcel(Request.Form["patente"].ToString(), Request.Form["transportista"].ToString(), Request.Form["estadoViaje"].ToString(), Request.Form["estadoGPS"].ToString(), Request.Form["proveedorGPS"].ToString());
          return;
        default:
          break;
      }
    }

    public void ExportExcel(string patente, string transportista, string estadoViaje, string estadoGPS, string proveedorGPS)
    {
      string now = DateTime.Now.ToString();
      now = now.Replace(" ", "_");
      now = now.Replace("-", "");
      now = now.Replace(":", "");

      int _ignicion = -1;

      Methods_Viajes _objMethosViajes = new Methods_Viajes();

      List<Track_GetFlotaOnline_Result> _viajes = _objMethosViajes.GetFlotaOnline(patente, transportista, _ignicion, estadoViaje, estadoGPS, proveedorGPS);

      Response.Clear();
      Response.Buffer = true;
      Response.ContentType = "application/vnd.ms-excel";
      Response.AppendHeader("Content-Disposition", "attachment;filename=FlotaOnline_" + now + ".xls");
      Response.Charset = "UTF-8";
      Response.ContentEncoding = Encoding.Default;
      Response.Write(Methods_Export.HTML_FlotaOnline(_viajes.ToList()));
      Response.End();
    }
  }
}