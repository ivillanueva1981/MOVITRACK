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

namespace Track_Web
{
  public partial class Config_Zonas_Sitrans : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      UtilitiesLayer.Utilities.VerifyLoginStatus(Session, Response);

      switch (Request.QueryString["Metodo"])
      {
        case "ExportExcel":
          ExportExcel(Request.Form["tipoZona"].ToString(), Request.Form["nombreZona"].ToString());
          return;
        default:
          break;
      }
    }

    public void ExportExcel(string idTipoZona, string nombreZona)
    {
      string now = DateTime.Now.ToString();
      now = now.Replace(" ", "_");
      now = now.Replace("-", "");
      now = now.Replace(":", "");

      int _idTipoZona;
      int.TryParse(idTipoZona, out _idTipoZona);

      Methods_Zonas _obj = new Methods_Zonas();

      List<Track_GetZonasAsociadas_Result> _zonas = _obj.GetZonasAsociadas(_idTipoZona, nombreZona);

      StringBuilder reportBuilder = new StringBuilder();

      Response.Clear();
      Response.Buffer = true;
      Response.BufferOutput = true;
      Response.ContentType = "application/vnd.ms-excel";
      Response.AppendHeader("Content-Disposition", "attachment;filename=Zonas_" + now + ".xls");
      Response.Charset = "UTF-8";
      Response.ContentEncoding = Encoding.Default;
      Response.Write(Methods_Export.HTML_Zonas(_zonas.ToList()));
      Response.End();
    }
  }
}