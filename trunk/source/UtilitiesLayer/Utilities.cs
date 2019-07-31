using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.SessionState;
using System.Web;
using BusinessEntities;
using Newtonsoft.Json;

namespace UtilitiesLayer
{
  public class Utilities
  {
    public static void VerifyLoginStatus(HttpSessionState _session, HttpResponse _response)
    {
      if (_session["userName"] == null)
      {
        _response.Redirect("Login.aspx");
      }
    }

    public static void ResetSession(HttpSessionState _session)
    {
        //_session["userName"] = null;
      _session.Clear();
      //_session.Timeout = 60;
    }

    public static string GetTransportistaSession(HttpSessionState _session)
    {
      try
      {
        return _session["transportista"].ToString();
      }
      catch {
        return "";  
      }

    }

    public static string GetExePath()
    {
      return (System.AppDomain.CurrentDomain.BaseDirectory);
    }

    public static string GetUsuarioSession(HttpSessionState _session)
    {
      try
      {
        return _session["userName"].ToString();
      }
      catch
      {
        return "";
      }

    }

    public static string GetIdUsuarioSession(HttpSessionState _session)
    {
      try
      {
        return _session["idusuario"].ToString();
      }
      catch
      {
        return "";
      }

    }

    public string getETA(string estadoLat, string estadoLon, string destinoLat, string destinoLon)
    {
      ServiceTrack_GoogleAPI.Track_GoogleAPIClient _service = new ServiceTrack_GoogleAPI.Track_GoogleAPIClient();

      Positions pObject = new Positions()
      {
        latOrigen = estadoLat.Replace(",","."),
        lonOrigen = estadoLon.Replace(",", "."),
        latDestino = destinoLat.Replace(",", "."),
        lonDestino = destinoLon.Replace(",", ".")
      };

      string request = JsonConvert.SerializeObject(pObject);

      string ETA = string.Empty;
      ETA = _service.GetGoogleETA(request);

      return ETA;
    }
    
  }
}
