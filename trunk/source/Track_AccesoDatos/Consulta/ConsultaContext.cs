using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Entity;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Track_AccesoDatos.Models;

namespace Track_AccesoDatos.Consulta
{
    public class ConsultaContext : DbContext
    {
        #region ConfigurationManager
        //private string BASE_JBOSS;
        //private string Json_TokenAuthorization;
        //private bool bOnline;

        public ConsultaContext()
        {
            //bOnline = Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings["Online"].ToString());

        }
        #endregion

        #region Methods_User
        public usuarioViewModel _ValidarUsuario(string _usuario, string _pass)
        {
            var consultaComercial = new usuarioViewModel();

            SqlDataAdapter var_adaptador = new SqlDataAdapter();
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["BD_Produccion"].ConnectionString.ToString()))
            {

                using (SqlCommand cmd = new SqlCommand("spu_GpsTrack_ValidarUsuario", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Clear();
                        cmd.Parameters.AddWithValue("@Usuario", _usuario);
                        cmd.Parameters.AddWithValue("@Password", _pass);

                        conn.Open();
                        SqlDataReader reader = cmd.ExecuteReader();

                        foreach (var item in reader)
                        {
                            consultaComercial.respuesta = Convert.ToString(reader["Respuesta"]);
                            consultaComercial.IdUsuario = Convert.ToInt32(reader["IdUsuario"]);
                            consultaComercial.IdAltoTrack = Convert.ToInt32(reader["IdAltoTrack"]);
                            consultaComercial.Transportista = Convert.ToString(reader["Transportista"]);
                            consultaComercial.EMail = Convert.ToString(reader["EMail"]);
                            consultaComercial.Nombre = Convert.ToString(reader["Nombre"]);
                            consultaComercial.Apellidos = Convert.ToString(reader["Apellidos"]);
                        }

                        conn.Close();
                    }
                    catch (Exception ex)
                    {
                        //throw ex;
                        consultaComercial.respuesta = ex.Message;
                    }
                }

            }

            return consultaComercial;

        }

        public usuarioViewModel _getPerfilSession(string _usuario)
        {
            var consultaComercial = new usuarioViewModel();

            SqlDataAdapter var_adaptador = new SqlDataAdapter();
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["BD_Produccion"].ConnectionString.ToString()))
            {

                using (SqlCommand cmd = new SqlCommand("spu_GpsTrack_getPerfilUsuario", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Clear();
                        cmd.Parameters.AddWithValue("@Usuario", _usuario);

                        conn.Open();
                        SqlDataReader reader = cmd.ExecuteReader();

                        foreach (var item in reader)
                        {
                            consultaComercial.IdRol = Convert.ToInt32(reader["IdRol"]);
                        }

                        conn.Close();
                    }
                    catch (Exception ex)
                    {
                        //throw ex;
                        consultaComercial.respuesta = ex.Message;
                    }
                }

            }

            return consultaComercial;

        }



        public void _guardarlog(Nullable<int> idUsuario, string ipAddress, string action)
        {
            //var consultaComercial = new ConsultaComercialUsersData();
            SqlDataAdapter var_adaptador = new SqlDataAdapter();
            int var_resultado = 0;

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["BD_Produccion"].ConnectionString.ToString()))
            {
                using (SqlCommand cmd = new SqlCommand("spu_GpsTrack_GuardarLog", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Clear();
                        cmd.Parameters.AddWithValue("@idUsuario", idUsuario);
                        cmd.Parameters.AddWithValue("@ipAddress", ipAddress);
                        cmd.Parameters.AddWithValue("@action", action);

                        conn.Open();
                        var_adaptador.SelectCommand = cmd;
                        var_resultado = cmd.ExecuteNonQuery();

                        conn.Close();
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            //return consultaComercial;
        }


        public void _UpdateTrackId(string Usuario)
        {
            //var consultaComercial = new ConsultaComercialUsersData();
            SqlDataAdapter var_adaptador = new SqlDataAdapter();
            int var_resultado = 0;

            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["BD_Produccion"].ConnectionString.ToString()))
            {
                using (SqlCommand cmd = new SqlCommand("spu_GpsTrack_UserAltoTrack", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Clear();
                        cmd.Parameters.AddWithValue("@UserName", Usuario);

                        conn.Open();
                        var_adaptador.SelectCommand = cmd;
                        var_resultado = cmd.ExecuteNonQuery();

                        conn.Close();
                    }
                    catch (Exception ex)
                    {
                        throw ex;
                    }
                }
            }

            //return consultaComercial;
        }



        #endregion


        #region  VIAJES
        public List<Track_GetFlotaOnline_Fragil_Result> Track_GetFlotaOnline_Fragil(string patente, string transportista, int ignicion, string estadoViaje, string estadoGPS, string proveedorGPS, string viajeFragil)
        {

            var consultaComercial = new List<Track_GetFlotaOnline_Fragil_Result>();

            SqlDataAdapter var_adaptador = new SqlDataAdapter();
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["BD_Produccion"].ConnectionString.ToString()))
            {

                using (SqlCommand cmd = new SqlCommand("spu_GpsTrack_GetFlotaOnline_Fragil", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Clear();
                        cmd.Parameters.AddWithValue("@Patente", patente);
                        cmd.Parameters.AddWithValue("@Transportista", transportista);
                        cmd.Parameters.AddWithValue("@Ignicion", ignicion);
                        cmd.Parameters.AddWithValue("@estadoTrip", estadoViaje);
                        cmd.Parameters.AddWithValue("@estadoGPS", estadoGPS);
                        cmd.Parameters.AddWithValue("@proveedorGPS", proveedorGPS);
                        cmd.Parameters.AddWithValue("@viajeFragil", viajeFragil);

                        conn.Open();
                        SqlDataReader reader = cmd.ExecuteReader();

                        foreach (var item in reader)
                        {
                            Track_GetFlotaOnline_Fragil_Result rows = new Track_GetFlotaOnline_Fragil_Result
                            {
                                UltReporte = Convert.ToDateTime(reader["UltReporte"]),
                                TextUltReporte = Convert.ToString(reader["TextUltReporte"]),
                                Patente = Convert.ToString(reader["Patente"]),
                                IdTipoMovil = Convert.ToInt32(reader["IdTipoMovil"]),
                                Transportista = Convert.ToString(reader["Transportista"]),
                                Latitud = Convert.ToDecimal(reader["Latitud"]),
                                Longitud = Convert.ToDecimal(reader["Longitud"]),
                                Ignicion = Convert.ToString(reader["Ignicion"]),
                                Velocidad = Convert.ToInt32(reader["Velocidad"]),
                                Direccion = Convert.ToInt32(reader["Direccion"]),
                                EstadoGPS = Convert.ToString(reader["EstadoGPS"]),
                                Puerta1 = Convert.ToString(reader["Puerta1"]),
                                Temperatura1 = Convert.ToString(reader["Temperatura1"]),
                                EstadoViaje = Convert.ToString(reader["EstadoViaje"]),
                                NroTransporte = Convert.ToInt32(reader["NroTransporte"]),
                                CodigoDestino = Convert.ToInt32(reader["CodigoDestino"]),
                                ProveedorGPS = Convert.ToString(reader["ProveedorGPS"]),
                                RutConductor = Convert.ToString(reader["RutConductor"]),
                                NombreConductor = Convert.ToString(reader["NombreConductor"]),
                                TelefonoConductor = Convert.ToString(reader["TelefonoConductor"]),
                                FlagViajeFragil = Convert.ToInt32(reader["FlagViajeFragil"])
                            };

                            consultaComercial.Add(rows);
                        }
                        conn.Close();
                    }
                    catch (Exception ex)
                    {
                        //throw ex;
                        // consultaComercial.respuesta = ex.Message;
                    }
                }

            }

            return consultaComercial;


        }


        public List<Track_Movil> Track_GetAllTransportistas(string _all, string v_transportista)
        {

            var consultaComercial = new List<Track_Movil>();

            SqlDataAdapter var_adaptador = new SqlDataAdapter();
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["BD_Produccion"].ConnectionString.ToString()))
            {

                using (SqlCommand cmd = new SqlCommand("spu_GpsTrack_GetAllTransportistas", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Clear();
                        cmd.Parameters.AddWithValue("@Transportista", v_transportista);
                        cmd.Parameters.AddWithValue("@all", _all);

                        conn.Open();
                        SqlDataReader reader = cmd.ExecuteReader();

                        foreach (var item in reader)
                        {
                            Track_Movil rows = new Track_Movil
                            {
                                //Patente = Convert.ToString(reader["Patente"]),
                                //IdTipoMovil = Convert.ToInt32(reader["IdTipoMovil"]),
                                //ProveedorGPS = Convert.ToString(reader["ProveedorGPS"]),
                                Transportista = Convert.ToString(reader["Transportista"])
                                //RutTransportista = Convert.ToString(reader["RutTransportista"]),
                                //Opcional = Convert.ToString(reader["Opcional"]),
                            };

                            consultaComercial.Add(rows);
                        }
                        conn.Close();
                    }
                    catch (Exception ex)
                    {
                        //throw ex;
                        // consultaComercial.respuesta = ex.Message;
                    }
                }

            }

            return consultaComercial;


        }
        #endregion

        #region  ZONAS
        public List<Track_TipoZonas> Track_GetTipoZonas(string _all)
        {

            var consultaComercial = new List<Track_TipoZonas>();

            SqlDataAdapter var_adaptador = new SqlDataAdapter();
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["BD_Produccion"].ConnectionString.ToString()))
            {

                using (SqlCommand cmd = new SqlCommand("spu_GpsTrack_GetTipoZonas", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Clear();
                        cmd.Parameters.AddWithValue("@all", _all);

                        conn.Open();
                        SqlDataReader reader = cmd.ExecuteReader();

                        foreach (var item in reader)
                        {
                            Track_TipoZonas rows = new Track_TipoZonas
                            {
                                IdTipoZona = Convert.ToInt32(reader["IdTipoZona"]),
                                NombreTipoZona = Convert.ToString(reader["NombreTipoZona"])
                            };

                            consultaComercial.Add(rows);
                        }
                        conn.Close();
                    }
                    catch (Exception ex)
                    {
                        //throw ex;
                        // consultaComercial.respuesta = ex.Message;
                    }
                }

            }

            return consultaComercial;
        }
        public List<Track_GetZonasAsociadas> Track_GetZonasAsociadas(Nullable<int> idTipoZona, string nombreZona)
        {
            var consultaComercial = new List<Track_GetZonasAsociadas>();
            //////((IObjectContextAdapter)this).ObjectContext.MetadataWorkspace.LoadFromAssembly(typeof(Track_GetZonasAsociadas_Result).Assembly);
            //////var idTipoZonaParameter = idTipoZona.HasValue ?
            //////    new ObjectParameter("idTipoZona", idTipoZona) :
            //////    new ObjectParameter("idTipoZona", typeof(int));
            //////var nombreZonaParameter = nombreZona != null ?
            //////    new ObjectParameter("nombreZona", nombreZona) :
            //////    new ObjectParameter("nombreZona", typeof(string));

            //////return ((IObjectContextAdapter)this).ObjectContext.ExecuteFunction<Track_GetZonasAsociadas_Result>("Track_GetZonasAsociadas", idTipoZonaParameter, nombreZonaParameter);
            ///

            SqlDataAdapter var_adaptador = new SqlDataAdapter();
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["BD_Produccion"].ConnectionString.ToString()))
            {

                using (SqlCommand cmd = new SqlCommand("spu_GpsTrack_GetZonasAsociadas", conn))
                {
                    try
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.Clear();
                        cmd.Parameters.AddWithValue("@idTipoZona", idTipoZona);
                        cmd.Parameters.AddWithValue("@nombreZona", nombreZona);

                        conn.Open();
                        SqlDataReader reader = cmd.ExecuteReader();

                        foreach (var item in reader)
                        {
                            Track_GetZonasAsociadas rows = new Track_GetZonasAsociadas
                            {
                                IdZona = Convert.ToInt32(reader["IdTipoZona"]),
                                CodSitrans = Convert.ToString(reader["CodSitrans"]),
                                NombreZona = Convert.ToString(reader["NombreZona"]),
                                IdTipoZona = Convert.ToInt32(reader["IdTipoZona"]),
                                NombreTipoZona = Convert.ToString(reader["NombreTipoZona"]),
                                Latitud = Convert.ToDecimal(reader["Latitud"]),
                                Longitud = Convert.ToDecimal(reader["Longitud"]),
                                Radio = Convert.ToInt32(reader["Radio"]),
                                Direccion = Convert.ToString(reader["Direccion"]),
                                CantClientesAsociados = Convert.ToInt32(reader["CantClientesAsociados"])
                            };

                            consultaComercial.Add(rows);
                        }
                        conn.Close();
                    }
                    catch (Exception ex)
                    {
                        //throw ex;
                        // consultaComercial.respuesta = ex.Message;
                    }
                }

            }
            return consultaComercial;
        }
        #endregion
    }
}