using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Track_Negocio.Manager;

namespace Track_Web.Utils
{
    public class Utilidades
    {
        ConsultaManager _db = new ConsultaManager();


        public string GetUserIP()
        {

            string ipList = System.Web.HttpContext.Current.Request.ServerVariables["HTTP_X_FORWARDED_FOR"];

            if (!string.IsNullOrEmpty(ipList))
            {
                return ipList.Split(',')[0];
            }

            return System.Web.HttpContext.Current.Request.ServerVariables["REMOTE_ADDR"];
        }

        public void uGuardarlog(int idUsuario, string action)
        {
            try
            {
                string userIpAddress = GetUserIP();

                if (userIpAddress == "::1")
                {
                    userIpAddress = "127.0.0.1";
                }

                 _db.guardarlog(idUsuario, userIpAddress, action);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
        }

    }
}