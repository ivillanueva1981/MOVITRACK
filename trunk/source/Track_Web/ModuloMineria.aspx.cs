using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BusinessEntities;
using BusinessLayer;
using UtilitiesLayer;
using System.Text;

namespace Track_Web
{
  public partial class ModuloMineria : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      switch (Request.QueryString["Metodo"])
      {
        case "ExportExcel":
          ExportExcel(Request.Form["nroTransporte"].ToString(), Request.Form["userName"].ToString());
          return;
        default:
          break;
      }
    }

    public void ExportExcel(string nroTransporte, string userName)
    {
     // int _nroTransporte;

      string now = DateTime.Now.ToString();
      now = now.Replace(" ", "_");
      now = now.Replace("-", "");
      now = now.Replace(":", "");

      //int.TryParse(nroTransporte, out _nroTransporte);

      Methods_Viajes _objMethosViajes = new Methods_Viajes();

      List<Track_GetViajesMineria_Result> _viajes = _objMethosViajes.GetViajesMineria(nroTransporte, userName);

      Response.Clear();
      Response.Buffer = true;
      Response.ContentType = "application/vnd.ms-excel";
      Response.AppendHeader("Content-Disposition", "attachment;filename=ViajesMineria" + now + ".xls");
      Response.Charset = "UTF-8";
      Response.ContentEncoding = Encoding.Default;
      Response.Write(Methods_Export.HTML_ViajesMineria(_viajes.ToList()));
      Response.End();
    }
  }
}