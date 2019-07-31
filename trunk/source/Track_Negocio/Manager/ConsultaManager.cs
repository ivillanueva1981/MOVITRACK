using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Track_AccesoDatos.Consulta;
using Track_AccesoDatos.Models;

namespace Track_Negocio.Manager
{
    public class ConsultaManager
    {
        ConsultaContext _sC;         // SistemaContext

        public ConsultaManager()
        {
            _sC = new ConsultaContext();
        }


        #region Login
        public usuarioViewModel ValidarUsuario(string _usuario, string _pass)
        {
            return _sC._ValidarUsuario(_usuario, _pass);
        }

        public usuarioViewModel GetPerfilSession(string _usuario)
        {
            return _sC._getPerfilSession(_usuario);
        }
        #endregion





        #region Methods_User
        public void guardarlog(int _idUsuario, string _userIpAddress, string _action)
        {
            _sC._guardarlog(_idUsuario, _userIpAddress, _action);
        }

        public void UpdateTrackId(string _usuario)
        {
            _sC._UpdateTrackId(_usuario);
        }
        #endregion



        #region Viajes
        public List<Track_GetFlotaOnline_Fragil_Result> GetFlotaOnline_Fragil(string patente, string transportista, int ignicion, string estadoViaje, string estadoGPS, string proveedorGPS, string viajeFragil)
        {

            List<Track_GetFlotaOnline_Fragil_Result> _listaFlotaOnline = _sC.Track_GetFlotaOnline_Fragil(patente, transportista, ignicion, estadoViaje, estadoGPS, proveedorGPS, viajeFragil).ToList();
            return _listaFlotaOnline;

        }
        public List<Track_Movil> GetAllTransportistas(string _all, string v_transportista)
        {
             if (string.IsNullOrEmpty(v_transportista))
            {
                v_transportista = "-1";
            }
 
 
                List<Track_Movil> _listaTransportistas = _sC.Track_GetAllTransportistas(_all, v_transportista).ToList();
                return _listaTransportistas;
 
        }
        #endregion


        #region ZONAS
        //public List<Track_TipoZonas> GetTipoZonas(bool _all = false)
        public List<Track_TipoZonas> GetTipoZonas(string _all)
        {
            try
            {
                List<Track_TipoZonas> _listTipoZonas = _sC.Track_GetTipoZonas(_all).ToList();

                if (_all == "Todos")
                {
                    Track_TipoZonas newItem = new Track_TipoZonas { IdTipoZona = 0, NombreTipoZona = "Todas" };
                    _listTipoZonas.Insert(0, newItem);
                }

                return _listTipoZonas;

            }
            catch (Exception)
            {
                return new List<Track_TipoZonas>();
            }
        }

        public List<Track_GetZonasAsociadas> GetZonasAsociadas(int idTipoZona, string nombreZona)
        {
            try
            {
                List<Track_GetZonasAsociadas> _listZonas = _sC.Track_GetZonasAsociadas(idTipoZona, nombreZona);   // new List<Track_GetZonasAsociadas>();//  _context.Track_GetZonasAsociadas(idTipoZona, nombreZona).ToList();
                return _listZonas;

            }
            catch (Exception)
            {
                return new List<Track_GetZonasAsociadas>();
            }
        }
        #endregion

    }
}