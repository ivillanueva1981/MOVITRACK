using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BusinessEntities;
using BusinessLayer;
using Newtonsoft.Json;
using UtilitiesLayer;

using System.IO;

namespace Track_Web.AjaxFunctions
{
  public partial class AjaxFunctions : System.Web.UI.Page
  {
    protected void Page_Load(object sender, EventArgs e)
    {
      switch (Request.QueryString["Metodo"])
      {
        case "ProgressBarCall":
          ProgressBarCall();
          break;
        case "MostrarPosicionesRutaCall":
          MostrarPosicionesRutaCall();
          break;
      }
    }

    public void ProgressBarCall()
    {
      try
      {
        string respuesta = "Ok";
    
        Response.Write(respuesta);

      }
      catch (Exception)
      {
        Response.Write("Se ha producido un error.");

      }
    }

    public void MostrarPosicionesRutaCall()
    {
      try
      {
        string respuesta = "Ok";
    
        Response.Write(respuesta);

      }
      catch (Exception)
      {
        Response.Write("Se ha producido un error.");

      }
    }

  }
}