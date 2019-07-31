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

using System.Web.Mvc;

namespace Track_Web
{
  public partial class GeneracionRutas : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      Utilities.VerifyLoginStatus(Session, Response);

      switch (Request.QueryString["Metodo"])
      {
        case "ExportFormatoEjemplo":
          ExportFormatoEjemplo();
          return;
        default:
          break;
      }
    }

    public void ExportFormatoEjemplo()
    {
      string filePath = "Files//Formato_Generacion_Masiva.xls";

      Response.Clear();
      Response.Buffer = true;
      Response.ContentType = "application/vnd.ms-excel";
      Response.AppendHeader("Content-Disposition", "attachment;filename=Formato_Generacion_Masiva.xls");
      Response.WriteFile(filePath );
      Response.End();

    }

  }
}