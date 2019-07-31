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

//using iTextSharp.text.html.simpleparser;
//using iTextSharp.text.pdf;
//using iTextSharp.text;
using System.IO;

using System.Security.Cryptography.X509Certificates;
using System.Net.Security;

namespace Track_Web
{
  public partial class InformeViajes : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      UtilitiesLayer.Utilities.VerifyLoginStatus(Session, Response);

      switch (Request.QueryString["Metodo"])
      {
        case "ExportPDF":
          ExportPDF(Request.Form["nroTRansporte"].ToString(), Request.Form["transportista"].ToString(), Request.Form["nombreOrigen"].ToString(), Request.Form["destinos"].ToString(),
                    Request.Form["tracto"].ToString(), Request.Form["trailer"].ToString(), Request.Form["nroContenedor"].ToString(), Request.Form["conductor"].ToString(), Request.Form["rutConductor"].ToString(), Request.Form["score"].ToString(), Request.Form["nombreCliente"].ToString());
          return;
        default:
          break;
      }
    }

    public void ExportPDF(string nroTransporte, string transportista, string nombreOrigen, string destinos, string tracto, string trailer, string nroContenedor, string conductor, string rutConductor, string score, string nombreCliente)
    {

      int _nroTransporte;
            //int _nroOS;
            int.TryParse(nroTransporte, out _nroTransporte);

            Methods_Alertas _objAlertas = new Methods_Alertas();
      Methods_Viajes _objViajes = new Methods_Viajes();

      List<Track_GetAlertasInformeViaje_Result> _alertasInformeViaje = _objAlertas.GetAlertasInformeViaje(_nroTransporte);
      List<Track_GetDetalleTrayecto_Result> _detalleTrayecto = _objViajes.GetDetalleTrayecto(_nroTransporte);

      MemoryStream ms = new MemoryStream();
      ms = Methods_Export.MS_InformeViajes(nroTransporte, transportista, nombreOrigen, destinos, tracto, trailer, nroContenedor, conductor, rutConductor, score, nombreCliente, _detalleTrayecto, _alertasInformeViaje);

      Response.Clear();
      Response.Buffer = true;
      Response.AppendHeader("content-disposition", "attachment; filename=InformeViaje_" + nroTransporte + ".pdf");
      Response.ContentType = "application/pdf";

      Response.OutputStream.Write(ms.GetBuffer(), 0, ms.GetBuffer().Length);
      Response.End();

    }

  }
}