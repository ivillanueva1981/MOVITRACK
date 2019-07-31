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
  public partial class ControlPanel : System.Web.UI.Page
  {
    IFormatProvider culture = new CultureInfo("en-US", true);
    protected void Page_Load(object sender, EventArgs e)
    {
      Utilities.VerifyLoginStatus(Session, Response);

      switch (Request.QueryString["Metodo"])
      {
        case "ExportExcel":
          ExportExcel(Request.Form["desde"].ToString(), Request.Form["hasta"].ToString(), Request.Form["nroTransporte"].ToString(), Request.Form["nroOS"].ToString(), Request.Form["nroContenedor"].ToString(), Request.Form["tipoEtis"].ToString(), Request.Form["idOrigen"].ToString(), Request.Form["patente"].ToString(), Request.Form["estadoViaje"].ToString(), Request.Form["alertas"].ToString(), Request.Form["cliente"].ToString());
          return;
        default:
          break;
      }
    }

        public void ExportExcel(string desde, string hasta, string nroTransporte, string nroOS, string nroContenedor, string tipoEtis, string idOrigen, string patente, string estadoViaje, string alertas, string cliente)
    {
      Methods_User _obj = new Methods_User();
      Track_Usuarios _users = new Track_Usuarios();
      string userName = Utilities.GetUsuarioSession(Session);

      string now = DateTime.Now.ToString();
      now = now.Replace(" ", "_");
      now = now.Replace("-", "");
      now = now.Replace(":", "");

      DateTime _desde;
      DateTime _hasta;
      int _nroTransporte;
            int _nroOS;
      int _idOrigen;
      int _idDestino;

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

            if (idOrigen == "Todos" || idOrigen == "")
      {
        _idOrigen = 0;
      }
      else
      {
        int.TryParse(idOrigen, out _idOrigen);
      }

      _idDestino = 0;

      Methods_Viajes _objMethosViajes = new Methods_Viajes();

      List<Track_GetViajesControlPanel_Alerce_Result> _viajes = _objMethosViajes.GetViajesControlPanel(_desde, _hasta, _nroTransporte, _nroOS, nroContenedor, _idOrigen, _idDestino, patente, estadoViaje, alertas, userName, tipoEtis, cliente);

      Response.Clear();
      Response.Buffer = true;
      Response.ContentType = "application/vnd.ms-excel";
      Response.AppendHeader("Content-Disposition", "attachment;filename=ViajesControlPanel_" + now + ".xls");
      Response.Charset = "UTF-8";
      Response.ContentEncoding = Encoding.Default;
      Response.Write(Methods_Export.HTML_ViajesControlPanel(_viajes.ToList()));
      Response.End();
    }
  }

}