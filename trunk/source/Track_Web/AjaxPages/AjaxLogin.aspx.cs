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
using System.Reflection;
using System.IO;
using System.Configuration;
using Track_Negocio.Manager;
using Track_Web.Utils;

namespace Track_Web.AjaxPages
{
  public partial class AjaxLogin : System.Web.UI.Page
  {
    ConsultaManager _db = new ConsultaManager();
    Utilidades _util = new Utilidades();

    protected void Page_Load(object sender, EventArgs e)
    {
      switch (Request.QueryString["Metodo"])
      {
        case "ValidarUsuario":
          // Modificado 16-08-2018 
          ValidarUsuario(Request.Form["Usuario"].ToString(), Request.Form["Password"].ToString());
          break;
        case "GetPerfilSession":
            // Modificado 16-08-2018 
            GetPerfilSession();
          break;
        case "GetVersion":
            // Modificado 16-08-2018 
            GetVersion();
          break;
        case "getInfoUsuario":
            // Modificado 16-08-2018 
            getInfoUsuario();
          break;
      }
    }

    public void ValidarUsuario(string usuario, string password)
    {

            try
            {
                var result = _db.ValidarUsuario(usuario, password);

                if (result.respuesta == "Ok")
                {
                    _db.UpdateTrackId(usuario);

                    Session["idusuario"] = result.IdUsuario;
                    Session["idaltotrack"] = result.IdAltoTrack;
                    Session["userName"] = usuario;
                    Session["transportista"] = result.Transportista;
                    Session["correo"] = result.EMail;
                    Session["Nombre"] = result.Nombre.ToString() + " " + result.Apellidos.ToString();

                    _util.uGuardarlog(result.IdUsuario, "GPSTrack. Login");
                }

                Response.Write(result.respuesta);

              }
              catch (Exception ex )
              {
                Response.Write("ValidarUsuario\nSe ha producido un error\n" + ex.Message);
              }
    }

    public void GetPerfilSession()
    {
    string userName = Utilities.GetUsuarioSession(Session);
    int rol = _db.GetPerfilSession(userName).IdRol;

      string _response = JsonConvert.SerializeObject(rol);

      Response.Write(_response);
    }

    public void GetVersion()
    {
      string assemblyVersion = Assembly.GetExecutingAssembly().GetName().Version.Major.ToString() + '.' + Assembly.GetExecutingAssembly().GetName().Version.Minor.ToString() + '.' + Assembly.GetExecutingAssembly().GetName().Version.Build.ToString();

      Response.Write(assemblyVersion);
    }

    public void getInfoUsuario()
    {
      try
      {
        string _UrlTicket = ConfigurationManager.AppSettings["UrlTicket"].ToString();
        string _LlavePerfil = ConfigurationManager.AppSettings["LlavePerfil"].ToString();
        string _LlaveFormato = ConfigurationManager.AppSettings["LlaveFormato"].ToString();
        string _EnviadoDesde = ConfigurationManager.AppSettings["ENVIADO_DESDE"].ToString();
        string _OrigenTicket = ConfigurationManager.AppSettings["ORIGEN_TICKET"].ToString();
        string _ComodinOtro = ConfigurationManager.AppSettings["COMODIN_OTRO"].ToString();

        var json = new
        {
          UserName = Session["userName"].ToString(),
          Nombre = Session["Nombre"].ToString(),
          IdUsuario = Session["idusuario"].ToString(),
          Tranportista = Session["transportista"].ToString(),
          IdAltoTrack = Session["IdAltoTrack"].ToString(),
          Correo = Session["correo"].ToString(),
          Fono = "",
          UrlTicket = _UrlTicket,
          LlavePerfil = _LlavePerfil,
          LlaveFormato = _LlaveFormato,
          EnviadoDesde = _EnviadoDesde,
          OrigenTicket = _OrigenTicket,
          ComodinOtro = _ComodinOtro
        };

        string _response = JsonConvert.SerializeObject(json);

        Response.Write(_response);
      }
      catch (Exception ex)
      {
        string err = ex.Message.ToString();
      }
    }

  }
}