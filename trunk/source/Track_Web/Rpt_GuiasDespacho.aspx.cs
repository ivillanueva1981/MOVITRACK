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
  public partial class Rpt_GuiasDespacho : System.Web.UI.Page
  {
    IFormatProvider culture = new CultureInfo("en-US", true);
    protected void Page_Load(object sender, EventArgs e)
    {
      Utilities.VerifyLoginStatus(Session, Response);

      switch (Request.QueryString["Metodo"])
      {
        case "ExportExcel":
          ExportExcel(Request.Form["desde"].ToString(), Request.Form["hasta"].ToString(), Request.Form["nroTransporte"].ToString(), Request.Form["nroOS"].ToString());
          return;
        default:
          break;
      }
    }

    public void ExportExcel(string desde, string hasta, string nroTransporte, string nroOS)
    {
      Track_Usuarios _users = new Track_Usuarios();
      string userName = Utilities.GetUsuarioSession(Session);

      DateTime _desde;
      DateTime _hasta;

      int _nroTransporte;
      if (nroTransporte == "Todos" || nroTransporte == "")
      {
        _nroTransporte = 0;
      }
      else
      {
        int.TryParse(nroTransporte, out _nroTransporte);
      }

            int _nroOS;
            if (nroOS == "")
            {
                _nroOS = 0;
            }
            else
            {
                int.TryParse(nroOS, out _nroOS);
            }

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

      List<Track_GetGuiasDespacho_Result> _viajes = _objMethosReportes.GetGuiasDespacho(_desde, _hasta, _nroTransporte, _nroOS, userName);

      Response.Clear();
      Response.Buffer = true;
      Response.ContentType = "application/vnd.ms-excel";
      Response.AppendHeader("Content-Disposition", "attachment;filename=Reporte_GuiasDespacho_" + now + ".xls");
      Response.Charset = "UTF-8";
      Response.ContentEncoding = Encoding.Default;
      Response.Write(Methods_Export.HTML_RPT_GuiasDespacho(_viajes.ToList()));
      Response.End();
    }
  }
}