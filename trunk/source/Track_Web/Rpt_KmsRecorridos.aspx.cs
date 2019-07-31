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
  public partial class Rpt_KmsRecorridos : System.Web.UI.Page
  {
    IFormatProvider culture = new CultureInfo("en-US", true);
    protected void Page_Load(object sender, EventArgs e)
    {
      Utilities.VerifyLoginStatus(Session, Response);

      switch (Request.QueryString["Metodo"])
      {
        case "ExportExcel":
          ExportExcel(Request.Form["desde"].ToString(), Request.Form["hasta"].ToString(), Request.Form["transportista"].ToString(), Request.Form["patente"].ToString());
          return;
        default:
          break;
      }
    }

    public void ExportExcel(string desde, string hasta, string transportista, string patente )
    {
      DateTime _desde;
      DateTime _hasta;

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

      string now = DateTime.Now.ToString();
      now = now.Replace(" ", "_");
      now = now.Replace("-", "");
      now = now.Replace(":", "");

      Methods_Reportes _objMethosReportes = new Methods_Reportes();

      List<Track_GetRpt_KmsRecorridos_Result> _viajes = _objMethosReportes.GetRpt_KmsRecorridos(_desde, _hasta, transportista, patente);

      Response.Clear();
      Response.Buffer = true;
      Response.ContentType = "application/vnd.ms-excel";
      Response.AppendHeader("Content-Disposition", "attachment;filename=Reporte_KmsRecorridos_" + now + ".xls");
      Response.Charset = "UTF-8";
      Response.ContentEncoding = Encoding.Default;
      Response.Write(Methods_Export.HTML_RPT_KmsRecorridos(_viajes.ToList()));
      Response.End();
    }
  }
}