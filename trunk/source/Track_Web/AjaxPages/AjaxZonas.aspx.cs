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
using System.Configuration;

using System.IO;
using System.Globalization;
using Track_Negocio.Manager;

namespace Track_Web.AjaxPages
{
    public partial class AjaxZonas : System.Web.UI.Page
    {
        IFormatProvider culture = new CultureInfo("en-US", true);
        ConsultaManager _db = new ConsultaManager();
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (Request.QueryString["Metodo"])
            {
                case "GetTipoZonas":
                    // Revisado 22-08-2018
                    GetTipoZonas();
                    break;
                case "GetZonas":
                    // Revisado 22-08-2018
                    GetZonas();
                    break;
                case "EliminaZona":
                    EliminaZona(Request.Form["idZona"].ToString());
                    break;
                case "GetVerticesZona":
                    GetVerticesZona(Request.Form["IdZona"].ToString());
                    break;
                case "GetAllVerticesZona":
                    GetAllVerticesZona(Request.Form["IdZona"].ToString());
                    break;
                case "ValidarIdZona":
                    ValidarIdZona(Request.Form["IdZona"].ToString());
                    break;
                case "NuevaZona":
                    NuevaZona(Request.Form["NombreZona"].ToString(), Request.Form["IdTipoZona"].ToString(), Request.Form["ClientesAsociados"].ToString(), Request.Form["Vertices"].Split(','), Request.Form["Radio"].ToString());
                    break;
                case "EditarZona":
                    EditarZona(Request.Form["IdZona"].ToString(), Request.Form["NombreZona"].ToString(), Request.Form["IdTipoZona"].ToString(), Request.Form["ClientesAsociados"].ToString(), Request.Form["Vertices"].Split(','), Request.Form["Radio"].ToString());
                    break;
                case "GetZonasToDraw":
                    GetZonasToDraw();
                    break;
                case "GetZonasToDrawModuloMapa":
                    GetZonasToDrawModuloMapa();
                    break;
                case "GetZonesInsideZona":
                    GetZonesInsideZona(Request.Form["IdZona"].ToString());
                    break;
                case "GetClientesAsociados":
                    GetClientesAsociados();
                    break;
                case "ValidarCodCliente":
                    ValidarCodCliente(Request.Form["CodCliente"].ToString(), Request.Form["CodTipoCliente"].ToString());
                    break;
                case "EliminarCliente":
                    EliminarCliente(Request.Form["CodCliente"].ToString(), Request.Form["CodTipoCliente"].ToString());
                    break;
                case "GuardarCliente":
                    GuardarCliente(Request.Form["CodCliente"].ToString(), Request.Form["CodTipoCliente"].ToString(), Request.Form["NombreCliente"].ToString());
                    break;
                case "GetZonasCercanas":
                    GetZonasCercanas();
                    break;
                case "GetZonasByClientes":
                    GetZonasByClientes();
                    break;
            }
        }

        public void GetTipoZonas()
        {
            string _todos = "" + Request.QueryString["Todos"];
            string _result = "";
            Methods_Zonas _obj = new Methods_Zonas();
             
            if (_todos == "True")
            {
                _todos = "Todos";
            }

            var _list = (from i in _db.GetTipoZonas(_todos)
                         select new
                         {
                             i.IdTipoZona,
                             i.NombreTipoZona
                         }).ToList();
            _result = JsonConvert.SerializeObject(_list);

            #region Web MWthod
            //////////if (_todos == "True")
            //////////{
            //////////    var _list = (from i in _obj.GetTipoZonas(true)
            //////////                 select new
            //////////                 {
            //////////                     i.IdTipoZona,
            //////////                     i.NombreTipoZona
            //////////                 }).ToList();
            //////////    _result = JsonConvert.SerializeObject(_list);
            //////////}
            //////////else
            //////////{
            //////////    var _list = (from i in _obj.GetTipoZonas()
            //////////                 select new
            //////////                 {
            //////////                     i.IdTipoZona,
            //////////                     i.NombreTipoZona
            //////////                 }).ToList();
            //////////    _result = JsonConvert.SerializeObject(_list);
            //////////}
            #endregion

            Response.Write(_result);
        }

        public void GetZonas()
        {
            string idTipoZona = "" + Request.QueryString["idTipoZona"];
            string nombreZona = "" + Request.QueryString["nombreZona"];
            int _idTipoZona;

            int.TryParse(idTipoZona, out _idTipoZona);

            string _response = JsonConvert.SerializeObject(_db.GetZonasAsociadas(_idTipoZona, nombreZona));

            #region Web MWthod
            //Methods_Zonas _obj = new Methods_Zonas();
            // string _response = JsonConvert.SerializeObject(_obj.GetZonasAsociadas(_idTipoZona, nombreZona));
            #endregion
            Response.Write(_response);
        }

        public void EliminaZona(string idZona)
        {
            string idusuario = Utilities.GetIdUsuarioSession(Session);
            int _idUsuario = 0;

            int.TryParse(idusuario, out _idUsuario);

            int _idZona;
            int.TryParse(idZona, out _idZona);

            Methods_Zonas _obj = new Methods_Zonas();

            string _resp = _obj.EliminaZona(_idZona, _idUsuario);

            Response.Write(_resp);
        }

        public void GetVerticesZona(string idZona)
        {
            int _idZona;
            int.TryParse(idZona, out _idZona);

            Methods_Zonas _obj = new Methods_Zonas();

            Track_Zonas _zona = _obj.GetZonaById(_idZona);

            string _response = string.Empty;
            if (_zona != null)
            {
                var json = new
                {
                    IdZona = _zona.IdZona,
                    NombreZona = _zona.NombreZona,
                    Latitud = _zona.Latitud,
                    Longitud = _zona.Longitud,
                    idTipoZona = _zona.IdTipoZona,
                    Vertices = _obj.GetVerticesZona(_idZona)
                };
                _response = JsonConvert.SerializeObject(json);
            }


            Response.Write(_response);
        }

        public void GetAllVerticesZona(string idZona)
        {
            int _idZona;
            int.TryParse(idZona, out _idZona);

            Methods_Zonas _obj = new Methods_Zonas();

            Track_Zonas _zona = _obj.GetZonaById(_idZona);

            var json = new
            {
                IdZona = _zona.IdZona,
                NombreZona = _zona.NombreZona,
                Latitud = _zona.Latitud,
                Longitud = _zona.Longitud,
                idTipoZona = _zona.IdTipoZona,
                Vertices = _obj.GetAllVerticesZona(_idZona)
            };

            string _response = JsonConvert.SerializeObject(json);

            Response.Write(_response);
        }

        public void ValidarIdZona(string idZona)
        {
            int _idZona;
            int.TryParse(idZona, out _idZona);

            Methods_Zonas _obj = new Methods_Zonas();

            Response.Write(_obj.ValidarIdZona(_idZona).ToString());
        }
        /*
        public void NuevaZona(string idZona, string nombreZona, string idTipoZona, string[] vertices)
        {
          int _idZona;
          int _idTipoZona;
          int.TryParse(idZona, out _idZona);
          int.TryParse(idTipoZona, out _idTipoZona);

          Methods_Zonas _obj = new Methods_Zonas();
          try
          {
            List<Tuple<decimal, decimal>> _vertices = new List<Tuple<decimal, decimal>>();
            for (int i = 0; i < vertices.Length; i++)
            {
              string[] temp = vertices[i].Split(';');
              Tuple<decimal, decimal> _ver = new Tuple<decimal, decimal>(decimal.Parse(temp[0].Replace('.', ',')), decimal.Parse(temp[1].Replace('.', ',')));
              _vertices.Add(_ver);
            }
            string _resp = _obj.NuevaZona(_idZona, nombreZona, _idTipoZona, _vertices);

            Response.Write(_resp);
          }
          catch (Exception)
          {
            Response.Write("Se ha producido un error.");

          }
        }

        public void EditarZona(string idZona, string nombreZona, string idTipoZona, string[] vertices)
        {
          int _idZona;
          int _idTipoZona;
          int.TryParse(idZona, out _idZona);
          int.TryParse(idTipoZona, out _idTipoZona);

          Methods_Zonas _obj = new Methods_Zonas();
          try
          {
            List<Tuple<decimal, decimal>> _vertices = new List<Tuple<decimal, decimal>>();
            for (int i = 0; i < vertices.Length; i++)
            {
              string[] temp = vertices[i].Split(';');
              Tuple<decimal, decimal> _ver = new Tuple<decimal, decimal>(decimal.Parse(temp[0].Replace('.', ',')), decimal.Parse(temp[1].Replace('.', ',')));
              _vertices.Add(_ver);
            }
            string _resp = _obj.EditarZona(_idZona, nombreZona, _idTipoZona, _vertices);

            Response.Write(_resp);
          }
          catch (Exception)
          {
            Response.Write("Se ha producido un error.");
          }
        }

        public void NuevaZona(string idZona, string codSitrans, string nombreZona, string idTipoZona, string[] vertices)
        {
          int _idZona;
          int _idTipoZona;
          int.TryParse(idZona, out _idZona);
          int.TryParse(idTipoZona, out _idTipoZona);

          Methods_Zonas _obj = new Methods_Zonas();
          try
          {
            List<Tuple<decimal, decimal>> _vertices = new List<Tuple<decimal, decimal>>();
            for (int i = 0; i < vertices.Length; i++)
            {
              string[] temp = vertices[i].Split(';');
              Tuple<decimal, decimal> _ver = new Tuple<decimal, decimal>(decimal.Parse(temp[0].Replace('.', ',')), decimal.Parse(temp[1].Replace('.', ',')));
              _vertices.Add(_ver);
            }
            string _resp = _obj.NuevaZona(_idZona, codSitrans, nombreZona, _idTipoZona, _vertices);

            Response.Write(_resp);
          }
          catch (Exception)
          {
            Response.Write("Se ha producido un error.");

          }
        }
        */
        public void NuevaZona(string nombreZona, string idTipoZona, string clientesAsociados, string[] vertices, string radio)
        {
            string idusuario = Utilities.GetIdUsuarioSession(Session);
            int _idUsuario = 0;

            int.TryParse(idusuario, out _idUsuario);

            int _idTipoZona;
            int _radio;

            int.TryParse(idTipoZona, out _idTipoZona);

            _radio = int.Parse(radio.Split('.')[0]);

            Methods_Zonas _obj = new Methods_Zonas();
            try
            {
                List<Tuple<decimal, decimal>> _vertices = new List<Tuple<decimal, decimal>>();
                for (int i = 0; i < vertices.Length; i++)
                {
                    string[] temp = vertices[i].Split(';');
                    Tuple<decimal, decimal> _ver;

                    string deployDestination = ConfigurationManager.AppSettings["DeployDestination"].ToString();

                    switch (deployDestination)
                    {
                        case "CL":
                            _ver = new Tuple<decimal, decimal>(decimal.Parse(temp[0].Replace('.', ',')), decimal.Parse(temp[1].Replace('.', ',')));
                            break;
                        case "US":
                            _ver = new Tuple<decimal, decimal>(Convert.ToDecimal(temp[0]), Convert.ToDecimal(temp[1]));
                            break;

                        //Valor por defecto CL      
                        default:
                            _ver = new Tuple<decimal, decimal>(decimal.Parse(temp[0].Replace('.', ',')), decimal.Parse(temp[1].Replace('.', ',')));
                            break;
                    }

                    _vertices.Add(_ver);
                }
                string _resp = _obj.NuevaZona(nombreZona, _idTipoZona, clientesAsociados, _vertices, _radio, _idUsuario);

                Response.Write(_resp);
            }
            catch (Exception e)
            {
                Response.Write("Se ha producido un error. AjaxZonas.NuevaZona. " + Convert.ToChar(CultureInfo.CurrentUICulture.NumberFormat.NumberDecimalSeparator) + e.InnerException);

            }
        }

        public void EditarZona(string idZona, string nombreZona, string idTipoZona, string clientesAsociados, string[] vertices, string radio)
        {
            string idusuario = Utilities.GetIdUsuarioSession(Session);
            int _idUsuario = 0;

            int.TryParse(idusuario, out _idUsuario);

            int _idZona;
            int _idTipoZona;
            int _radio;

            int.TryParse(idZona, out _idZona);
            int.TryParse(idTipoZona, out _idTipoZona);

            _radio = int.Parse(radio.Split('.')[0]);

            Methods_Zonas _obj = new Methods_Zonas();
            try
            {
                List<Tuple<decimal, decimal>> _vertices = new List<Tuple<decimal, decimal>>();
                for (int i = 0; i < vertices.Length; i++)
                {
                    string[] temp = vertices[i].Split(';');
                    Tuple<decimal, decimal> _ver;

                    string deployDestination = ConfigurationManager.AppSettings["DeployDestination"].ToString();

                    switch (deployDestination)
                    {
                        case "CL":
                            _ver = new Tuple<decimal, decimal>(decimal.Parse(temp[0].Replace('.', ',')), decimal.Parse(temp[1].Replace('.', ',')));
                            break;
                        case "US":
                            _ver = new Tuple<decimal, decimal>(Convert.ToDecimal(temp[0]), Convert.ToDecimal(temp[1]));
                            break;

                        //Valor por defecto CL      
                        default:
                            _ver = new Tuple<decimal, decimal>(decimal.Parse(temp[0].Replace('.', ',')), decimal.Parse(temp[1].Replace('.', ',')));
                            break;
                    }

                    _vertices.Add(_ver);
                }
                string _resp = _obj.EditarZona(_idZona, nombreZona, _idTipoZona, clientesAsociados, _vertices, _radio, _idUsuario);

                Response.Write(_resp);
            }
            catch (Exception e)
            {
                Response.Write("Se ha producido un error. AjaxZonas.EditarZona. " + e.InnerException);
            }
        }

        public void GetZonasToDraw()
        {
            string fechaDesde = "" + Request.QueryString["fechaDesde"];
            string fechaHasta = "" + Request.QueryString["fechaHasta"];
            string patente1 = "" + Request.QueryString["patente1"];
            string patente2 = "" + Request.QueryString["patente2"];
            string _nroTransporte = "" + Request.QueryString["_nroTransporte"];

            int pNroTrans = -1;

            if (!string.IsNullOrEmpty(_nroTransporte))
                pNroTrans = int.Parse(_nroTransporte);

            DateTime _fechaDesde;
            DateTime _fechaHasta;

            //_fechaDesde = Convert.ToDateTime(fechaDesde);
            //_fechaHasta = Convert.ToDateTime(fechaHasta);
            if (DateTime.TryParseExact(fechaDesde.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fechaDesde))
            {
            }
            else
            {
                DateTime.TryParseExact(fechaDesde.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fechaDesde);
            }

            if (DateTime.TryParseExact(fechaHasta.Replace("-", "/").Substring(0, 16), "dd/MM/yyyy HH:mm", culture, DateTimeStyles.None, out _fechaHasta))
            {
            }
            else
            {
                DateTime.TryParseExact(fechaHasta.Replace("T", " ").Substring(0, 16), "yyyy-MM-dd HH:mm", culture, DateTimeStyles.None, out _fechaHasta);
            }

            Methods_Zonas _objMethosZonas = new Methods_Zonas();

            string _response = JsonConvert.SerializeObject(_objMethosZonas.GetZonasToDraw(_fechaDesde, _fechaHasta, patente1, patente2, pNroTrans));

            Response.Write(_response);
        }

        public void GetZonasToDrawModuloMapa()
        {
            string idAlerta = "" + Request.QueryString["IdAlerta"];

            int _idAlerta;

            int.TryParse(idAlerta, out _idAlerta);

            Methods_Zonas _objMethosZonas = new Methods_Zonas();

            string _response = JsonConvert.SerializeObject(_objMethosZonas.GetZonasToDrawModuloMapa(_idAlerta));

            Response.Write(_response);
        }
        public void GetZonesInsideZona(string idZona)
        {
            int _idZona;
            int.TryParse(idZona, out _idZona);

            Methods_Zonas _obj = new Methods_Zonas();

            Response.Write(_obj.ZonesInsideZone(_idZona).ToString());
        }

        public void GetClientesAsociados()
        {
            string idZona = "" + Request.QueryString["IdZona"];
            string CodigoCliente = "" + Request.QueryString["CodigoCliente"];
            string nombreCliente = "" + Request.QueryString["NombreCliente"];

            int _idZona;
            int.TryParse(idZona, out _idZona);

            Methods_Zonas _objMethodsZonas = new Methods_Zonas();

            string _response = JsonConvert.SerializeObject(_objMethodsZonas.GetClientesAsociados(_idZona, CodigoCliente, nombreCliente));

            Response.Write(_response);

        }

        public void ValidarCodCliente(string codCliente, string codTipoCliente)
        {
            int _codTipoCliente;
            int.TryParse(codTipoCliente, out _codTipoCliente);

            Methods_Zonas _obj = new Methods_Zonas();

            Response.Write(_obj.ValidarCodCliente(codCliente, _codTipoCliente).ToString());
        }

        public void EliminarCliente(string codCliente, string codTipoCliente)
        {
            string idusuario = Utilities.GetIdUsuarioSession(Session);
            int _idUsuario = 0;

            int.TryParse(idusuario, out _idUsuario);

            int _codTipoCliente;
            int.TryParse(codTipoCliente, out _codTipoCliente);

            Methods_Zonas _obj = new Methods_Zonas();

            string _resp = _obj.EliminarCliente(codCliente, _codTipoCliente, _idUsuario);

            Response.Write(_resp);
        }

        public void GuardarCliente(string codCliente, string codTipoCliente, string nombreCliente)
        {
            string idusuario = Utilities.GetIdUsuarioSession(Session);
            int _idUsuario = 0;

            int.TryParse(idusuario, out _idUsuario);

            int _codTipoCliente;
            int.TryParse(codTipoCliente, out _codTipoCliente);

            Methods_Zonas _obj = new Methods_Zonas();

            string _resp = _obj.GuardarCliente(codCliente, _codTipoCliente, nombreCliente, _idUsuario);

            Response.Write(_resp);
        }

        public void GetZonasCercanas()
        {
            try
            {
                string _lat = Request.QueryString["lat"].Replace(",", ".");
                string _lon = Request.QueryString["lon"].Replace(",", ".");

                Methods_Zonas _obj = new Methods_Zonas();

                string _resp = JsonConvert.SerializeObject(_obj.getZonasCercanas(_lat, _lon));

                Response.Write(_resp);

            }
            catch (Exception ex)
            {
                string err = ex.Message.ToString();
            }
        }

        public void GetZonasByClientes()
        {
            try
            {
                string _lstCodClientes = Request.QueryString["listCodClientes"];

                Methods_Zonas _obj = new Methods_Zonas();

                string _resp = JsonConvert.SerializeObject(_obj.getZonasByclientes(_lstCodClientes));

                Response.Write(_resp);

            }
            catch (Exception ex)
            {
                string err = ex.Message.ToString();
            }
        }

    }
}