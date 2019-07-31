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
using System.Data;

using System.Collections;
using System.Data.OleDb;
using System.Text.RegularExpressions;
using LinqToExcel;

namespace Track_Web.AjaxPages
{
    public partial class AjaxRutas : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            switch (Request.QueryString["Metodo"])
            {
                case "GetRutas":
                    GetRutas();
                    break;
                case "EliminaRuta":
                    EliminaRuta(Request.Form["idRuta"].ToString());
                    break;
                case "GetPuntosRuta":
                    GetPuntosRuta(Request.Form["IdRuta"].ToString());
                    break;
                case "NuevaRuta":
                    NuevaRuta(Request.Form["idOrigen"].ToString(), Request.Form["idDestino"].ToString(), Request.Form["resumenRuta"].ToString(), Request.Form["verticesRuta"].Split(','));
                    break;
                case "ValidarRuta":
                    ValidarRuta(Request.Form["IdOrigen"].ToString(), Request.Form["IdDestino"].ToString());
                    break;
                case "RutaOptima":
                    RutaOptima();
                    break;
                case "GeneraRutaOptima":
                    GeneraRutaOptima(Request.Form["criterioOptimizacion"].ToString(), Request.Form["latOrigen"].ToString(), Request.Form["lonOrigen"].ToString(), Request.Form["latDestino"].ToString(), Request.Form["lonDestino"].ToString(),
                                      Request.Form["stringRuta1"].ToString(), Request.Form["stringRuta2"].ToString(), Request.Form["stringRuta3"].ToString(), Request.Form["stringRuta4"].ToString(), Request.Form["stringRuta5"].ToString());
                    break;
                case "CargaExcelPuntosOrigenDestino":
                    CargaExcelPuntosOrigenDestino();
                    break;
                case "GuardaRutaTmp":
                    GuardaRutaTmp(Request.Form["idRuta"].ToString(), Request.Form["stringRuta"].ToString());
                    break;
                case "GetPointSafeRoute":
                    GetPointSafeRoute(int.Parse(Request.Form["NroTranporte"].ToString()));
                    break;

            }
        }

        public void GetRutas()
        {
            Methods_Rutas _obj = new Methods_Rutas();

            string _response = JsonConvert.SerializeObject(_obj.GetRutas());

            Response.Write(_response);
        }

        public void EliminaRuta(string idRuta)
        {
            int _idRuta;
            int.TryParse(idRuta, out _idRuta);

            Methods_Rutas _obj = new Methods_Rutas();

            string _resp = _obj.EliminaRuta(_idRuta);

            Response.Write(_resp);
        }

        public void GetPuntosRuta(string idRuta)
        {
            int _idRuta;
            int.TryParse(idRuta, out _idRuta);

            Methods_Rutas _obj = new Methods_Rutas();

            Track_Rutas _ruta = _obj.GetRutaById(_idRuta);

            var json = new
            {
                IdRuta = _ruta.IdRuta,
                IdOrigen = _ruta.IdZonaOrigen,
                IdDestino = _ruta.IdZonaDestino,
                ResumenRuta = _ruta.ResumenRuta,
                Puntos = _obj.GetPuntosRuta(_idRuta)
            };

            string _response = JsonConvert.SerializeObject(json);

            Response.Write(_response);
        }

        public void GetAllPuntosRuta(string idRuta)
        {
            int _idRuta;
            int.TryParse(idRuta, out _idRuta);

            Methods_Rutas _obj = new Methods_Rutas();

            Track_Rutas _ruta = _obj.GetRutaById(_idRuta);

            var json = new
            {
                IdRuta = _ruta.IdRuta,
                IdOrigen = _ruta.IdZonaOrigen,
                IdDestino = _ruta.IdZonaDestino,
                ResumenRuta = _ruta.ResumenRuta,
                Puntos = _obj.GetPuntosRuta(_idRuta)
            };

            string _response = JsonConvert.SerializeObject(json);

            Response.Write(_response);
        }

        public void ValidarRuta(string idOrigen, string idDestino)
        {
            int _idOrigen;
            int _idDestino;
            int.TryParse(idOrigen, out _idOrigen);
            int.TryParse(idDestino, out _idDestino);

            Methods_Rutas _obj = new Methods_Rutas();

            Response.Write(_obj.ValidarRuta(_idOrigen, _idDestino).ToString());
        }

        public void NuevaRuta(string idOrigen, string idDestino, string resumenRuta, string[] verticesRuta)
        {
            int _idOrigen;
            int _idDestino;
            int.TryParse(idOrigen, out _idOrigen);
            int.TryParse(idDestino, out _idDestino);

            Methods_Rutas _obj = new Methods_Rutas();
            try
            {
                List<Tuple<decimal, decimal>> _verticesRuta = new List<Tuple<decimal, decimal>>();
                for (int i = 0; i < verticesRuta.Length; i++)
                {
                    string[] temp = verticesRuta[i].Split(';');
                    Tuple<decimal, decimal> _ver = new Tuple<decimal, decimal>(decimal.Parse(temp[0].Replace('.', ',')), decimal.Parse(temp[1].Replace('.', ',')));
                    _verticesRuta.Add(_ver);
                }
                string _resp = _obj.NuevaRuta(_idOrigen, _idDestino, resumenRuta, _verticesRuta);

                Response.Write(_resp);
            }
            catch (Exception)
            {
                Response.Write("Se ha producido un error.");

            }
        }

        public void RutaOptima()
        {
            string criterioOptimizacion = "" + Request.QueryString["criterioOptimizacion"];
            string stringRuta1 = "" + Request.QueryString["stringRuta1"];
            string stringRuta2 = "" + Request.QueryString["stringRuta2"];
            string stringRuta3 = "" + Request.QueryString["stringRuta3"];
            string stringRuta4 = "" + Request.QueryString["stringRuta4"];
            string stringRuta5 = "" + Request.QueryString["stringRuta5"];

            int _criterioOptimizacion;
            int.TryParse(criterioOptimizacion, out _criterioOptimizacion);

            Methods_Rutas _obj = new Methods_Rutas();

            string _response = JsonConvert.SerializeObject(_obj.GetRutaOptima(_criterioOptimizacion, stringRuta1, stringRuta2, stringRuta3, stringRuta4, stringRuta5));
            Response.Write(_response);

        }

        public void GuardaRutaTmp(string idRuta, string stringRuta)
        {
            int _idRuta;
            int.TryParse(idRuta, out _idRuta);

            Methods_Rutas _obj = new Methods_Rutas();

            Response.Write(_obj.GuardaRutaTmp(_idRuta, stringRuta).ToString());
        }

        public void GeneraRutaOptima(string criterioOptimizacion, string latOrigen, string lonOrigen, string latDestino, string lonDestino,
                                      string stringRuta1, string stringRuta2, string stringRuta3, string stringRuta4, string stringRuta5)
        {


            int _criterioOptimizacion;
            int.TryParse(criterioOptimizacion, out _criterioOptimizacion);

            Methods_Rutas _obj = new Methods_Rutas();

            string _response = JsonConvert.SerializeObject(_obj.GeneraRutaOptima(_criterioOptimizacion, latOrigen, lonOrigen, latDestino, lonDestino, stringRuta1, stringRuta2, stringRuta3, stringRuta4, stringRuta5));
            Response.Write(_response);

        }

        public void CargaExcelPuntosOrigenDestino()
        {
            HttpContext context = HttpContext.Current;
            if (context.Request.Files.Count > 0)
            {
                DataTable dt = new DataTable();
                dt.Columns.Add("LatOrigen", typeof(string));
                dt.Columns.Add("LonOrigen", typeof(string));
                dt.Columns.Add("LatDestino", typeof(string));
                dt.Columns.Add("LonDestino", typeof(string));

                HttpPostedFile archivoSubido = context.Request.Files[0];
                StreamReader file = new StreamReader(context.Request.Files[0].InputStream);

                string[] fileName = archivoSubido.FileName.Split('.');
                string fileExtension = fileName[fileName.Length - 1].ToUpper();
                string rutaSitio = Utilities.GetExePath();

                if (!(Directory.Exists(rutaSitio + "FileTemp")))
                {
                    Directory.CreateDirectory(rutaSitio + "FileTemp");
                }
                string Fechafile = DateTime.Now.ToString("ddMMyyyyHHmmss");
                var fileNameCopy = @"" + rutaSitio + "FileTemp\\ExcelTemp" + Fechafile + "." + fileExtension;
                string result = "";
                try
                {
                    if (fileExtension == "XLS" || fileExtension == "XLSX" || fileExtension == "XLSB")
                    {
                        archivoSubido.SaveAs(fileNameCopy);
                        ExcelQueryFactory xcl = new ExcelQueryFactory(fileNameCopy);
                        var lst = from d in xcl.Worksheet(0) select d;

                        if (lst.ToList()[0][0].ToString() != "Latitud Origen" || lst.ToList()[0][1].ToString() != "Longitud Origen" || lst.ToList()[0][2].ToString() != "Latitud Destino" || lst.ToList()[0][3].ToString() != "Longitud Destino")
                        {
                            result = @"{'success':true,'Data':[], 'result':false}";
                        }
                        else
                        {
                            {
                                DataRow rowNew;

                                for (int i = 1; i < lst.ToList().Count; i++)
                                {
                                    rowNew = dt.NewRow();

                                    rowNew[0] = lst.ToList()[i][0].ToString();
                                    rowNew[1] = lst.ToList()[i][1].ToString();
                                    rowNew[2] = lst.ToList()[i][2].ToString();
                                    rowNew[3] = lst.ToList()[i][3].ToString();

                                    dt.Rows.Add(rowNew);

                                }
                                result = @"{'success':true,'Data':[" + JsonConvert.SerializeObject(dt) + "], 'result':true}";
                            }
                        }

                    }

                    Response.Write(result);
                }
                catch (Exception)
                {
                    result = @"{'success':true,'Data':[" + JsonConvert.SerializeObject(dt) + "], 'result':false}";
                    Response.Write(result);
                }
            }
        }

        private string[] ValidaCoordenada(string coordenada)
        {
            return ("OK;" + Convert.ToDouble(coordenada)).Split(';');
        }

        public void GetPointSafeRoute(int nroTransporte)
        {
            Methods_Rutas _obj = new Methods_Rutas();
            Track_RutaSegura _trck = _obj.getRutaSegura(nroTransporte);

            if (_trck != null)
            {
                var json = new
                {
                    IdRuta = _trck.Id,
                    IdOrigen = _trck.CodOrigen,
                    IdDestino = _trck.CodDestino,
                    ResumenRuta = _trck.DescripcionRuta,
                    Puntos = _obj.getPuntosRutaSegura(_trck.Id)
                };

                string _response = JsonConvert.SerializeObject(json);
                Response.Write(_response);
            }
            else
            {
                var json = new
                {
                    IdRuta = "",
                    IdOrigen = "",
                    IdDestino = "",
                    ResumenRuta = "",
                    Puntos =""
                };

                string _response = JsonConvert.SerializeObject(json);
                Response.Write(_response);
            }
        }

    }
}