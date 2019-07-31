using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BusinessEntities;
using ContextLayer.Model;
using System.Data.Objects;

namespace BusinessLayer
{
  public class Methods_User
  {
    private ModelEntities _context = new ModelEntities();

    ////////////public string ValidarUsuario(string usuario, string password)
    ////////////{
    ////////////  try
    ////////////  {
    ////////////    ObjectResult<Track_ValidarUsuario_Result> _result = _context.Track_ValidarUsuario(usuario, password);
    ////////////    return _result.FirstOrDefault().Respuesta;
        
    ////////////  }
    ////////////  catch(Exception ex)
    ////////////  {
    ////////////    return "Se ha producido un error. Erro:" + ex.Message;
    ////////////  }
    ////////////}

    //public string getTransportista(string usuario)
    //{
    //  try
    //  {
    //    string transportista = "";

    //    int rolUsuario = (from a in _context.Track_Usuarios where a.Usuario == usuario select a).FirstOrDefault().IdRol;

    //    if (rolUsuario == 5) //Rol Transportista
    //    {
    //      transportista = (from a in _context.Track_Usuarios where a.Usuario == usuario select a).FirstOrDefault().Transportista;
    //    }
 
    //    return transportista;

    //  }
    //  catch (Exception e)
    //  {
    //            Console.WriteLine(e.Message);
    //            return "";
    //  }
    //}

    //////public int getPerfilUsuario(string usuario)
    //////{
    //////  try
    //////  {
    //////    int rolUsuario = (from a in _context.Track_Usuarios where a.Usuario == usuario select a).FirstOrDefault().IdRol;

    //////    return rolUsuario;

    //////  }
    //////  catch (Exception)
    //////  {
    //////    return 0;
    //////  }
    //////}

    public DateTime getDate()
    {
      try
      {
        ObjectResult<Track_GetDate_Result> _result = _context.Track_GetDate();
        return (DateTime)_result.FirstOrDefault().Fecha;
      }
      catch (Exception)
      {
        return new DateTime();
      }
    }

    //public void UpdateTrackId(string Usuario)
    //{
    //  try
    //  {
    //    _context.Track_UserAltoTrack(Usuario);
    //  }
    //  catch (Exception ex)
    //  {
    //    string err = ex.Message.ToString();
    //  }
    //}

    public int webDiferenciaHoraria()
    {
      try
      {
        int webDiferenciaHoraria = Convert.ToInt32((from a in _context.Configuracion where a.Clave == "webDiferenciaHoraria" select a).FirstOrDefault().Valor);
        return webDiferenciaHoraria;
      }
      catch (Exception)
      {
        return 0;
      }
    }

    //public Track_Usuarios getUsuarioConectado(string pUsuario)
    //{
    //  try
    //  {
    //    return (from a in _context.Track_Usuarios where a.Usuario == pUsuario select a).FirstOrDefault();
    //  }
    //  catch (Exception ex)
    //  {
    //    string err = ex.Message.ToString();
    //    return new Track_Usuarios();
    //  }
    //}

    //public void guardarlog(int idUsuario, string action)
    //{
    //  try
    //  {
    //    string userIpAddress = GetUserIP();

    //    if (userIpAddress == "::1")
    //    {
    //      userIpAddress = "127.0.0.1";
    //    }

    //    _context.Track_GuardarLog(idUsuario, userIpAddress, action);
    //  }
    //  catch (Exception ex)
    //  {
    //            Console.WriteLine(ex.Message);
    //        }
    //}

    //public string GetUserIP()
    //{

    //  string ipList = System.Web.HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];

    //  if (!string.IsNullOrEmpty(ipList))
    //  {
    //    return ipList.Split(',')[0];
    //  }

    //  return System.Web.HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
    //}

  }
}
