using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BusinessEntities;
using ContextLayer.Model;
using System.Data.Objects;

namespace BusinessLayer
{
    public class Methods_Rutas
    {
        private ModelEntities _context = new ModelEntities();

        public List<Track_GetRutas_Result> GetRutas()
        {
            try
            {
                List<Track_GetRutas_Result> _listZonas = _context.Track_GetRutas().ToList();
                return _listZonas;

            }
            catch (Exception)
            {
                return new List<Track_GetRutas_Result>();
            }
        }

        public string EliminaRuta(int IdRuta)
        {
            try
            {

                string _resp = _context.Track_EliminarRuta(IdRuta).FirstOrDefault().ToString();

                return _resp;
            }
            catch (Exception)
            {
                return "Se ha producido un error.";
            }
        }

        public Track_Rutas GetRutaById(int idRuta)
        {
            try
            {
                Track_Rutas _ruta = _context.Track_Rutas.Where(Z => Z.IdRuta == idRuta).FirstOrDefault();

                return _ruta;
            }
            catch (Exception)
            {
                return null;
            }
        }

        public List<Track_PuntosRuta> GetPuntosRuta(int idRuta)
        {
            try
            {
                List<Track_PuntosRuta> _list = new List<Track_PuntosRuta>();

                _list = _context.Track_PuntosRuta.Where(C => C.IdRuta == idRuta).OrderBy(C => C.IdPunto).ToList();

                _list.RemoveAt(_list.Count - 1);

                return _list;
            }
            catch (Exception)
            {
                return new List<Track_PuntosRuta>();
            }
        }

        public Track_RutaSegura getRutaSegura(int pNroTransporte)
        {
            try
            {
                Track_RutaSegura _trsg = _context.Track_RutaSegura.Where(Z => Z.NroTransporte == pNroTransporte).FirstOrDefault();
                return _trsg;
            }
            catch (Exception ex)
            {
                string err = ex.Message.ToString();
                return new Track_RutaSegura();
            }
        }

        
        public List<Track_GetPuntoSafeRoute_Result> getPuntosRutaSegura(int IdRutaS)
        {
            try
            {
                List<Track_GetPuntoSafeRoute_Result> _lst = new List<Track_GetPuntoSafeRoute_Result>();               

                _lst = _context.Track_GetPuntoSafeRoute(IdRutaS).ToList();

                _lst.RemoveAt(_lst.Count - 1);

                return _lst;
            }
            catch (Exception ex)
            {
                string err = ex.Message.ToString();
                return new List<Track_GetPuntoSafeRoute_Result>();
            }
        }

        public List<Track_PuntosRuta> GetAllPuntosRuta(int idRuta)
        {
            try
            {
                List<Track_PuntosRuta> _list = new List<Track_PuntosRuta>();

                _list = _context.Track_PuntosRuta.Where(C => C.IdRuta == idRuta).OrderBy(C => C.IdPunto).ToList();

                return _list;
            }
            catch (Exception)
            {
                return new List<Track_PuntosRuta>();
            }
        }

        public bool ValidarRuta(int idOrigen, int idDestino)
        {
            try
            {
                Track_Rutas _existe = _context.Track_Rutas.Where(C => C.IdZonaOrigen == idOrigen && C.IdZonaDestino == idDestino).FirstOrDefault();

                if (_existe != null)
                {
                    return true;
                }

                return false;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public string NuevaRuta(int idOrigen, int idDestino, string resumenRuta, List<Tuple<decimal, decimal>> verticesRuta)
        {
            try
            {
                int id;

                Track_Rutas _ruta = _context.Track_Rutas.Where(C => C.IdZonaOrigen == idOrigen && C.IdZonaDestino == idDestino).FirstOrDefault();

                if (_ruta == null)
                {
                    var _object = new Track_Rutas();

                    _object.IdZonaOrigen = idOrigen;
                    _object.IdZonaDestino = idDestino;
                    _object.ResumenRuta = resumenRuta;

                    _context.Track_Rutas.Add(_object);
                    _context.SaveChanges();
                    id = _object.IdRuta;
                }
                else
                {
                    id = _ruta.IdRuta;
                    List<Track_PuntosRuta> _puntosexistentes = _context.Track_PuntosRuta.Where(C => C.IdRuta == id).ToList();
                    for (int i = 0; i < _puntosexistentes.Count; i++)
                    {
                        _context.Track_PuntosRuta.Remove(_puntosexistentes[i]);
                    }

                    _ruta.ResumenRuta = resumenRuta;
                }

                for (int i = 0; i < verticesRuta.Count; i++)
                {
                    Track_PuntosRuta _vertice = new Track_PuntosRuta();
                    _vertice.IdRuta = id;
                    _vertice.IdPunto = (i + 1);
                    _vertice.Latitud = verticesRuta[i].Item1;
                    _vertice.Longitud = verticesRuta[i].Item2;

                    _context.Track_PuntosRuta.Add(_vertice);
                }

                Track_PuntosRuta _ultVertice = new Track_PuntosRuta();
                _ultVertice.IdRuta = id;
                _ultVertice.IdPunto = verticesRuta.Count + 1;
                _ultVertice.Latitud = verticesRuta[0].Item1;
                _ultVertice.Longitud = verticesRuta[0].Item2;

                _context.Track_PuntosRuta.Add(_ultVertice);

                _context.SaveChanges();

                if (_ruta != null)
                {
                    return "Ruta actualizada satisfactoriamente.";
                }
                else
                {
                    return "Ruta guardada satisfactoriamente.";
                }
            }
            catch (Exception)
            {
                return "Se ha producido un error.";
            }
        }

        public List<Track_RutaOptima_Result> GetRutaOptima(int criterioOptimizacion, string stringRuta1, string stringRuta2, string stringRuta3, string stringRuta4, string stringRuta5)
        {
            try
            {

                //List<Track_RutaOptima_Result> _listaRutas = _context.Track_RutaOptima(null, null, null, null, null, null).ToList();
                List<Track_RutaOptima_Result> _listaRutas = _context.Track_RutaOptima(criterioOptimizacion, stringRuta1, stringRuta2, stringRuta3, stringRuta4, stringRuta5).ToList();

                return _listaRutas;

            }
            catch (Exception)
            {
                return new List<Track_RutaOptima_Result>();
            }
        }

        public int GuardaRutaTmp(int idRuta, string stringRuta)
        {
            try
            {
                int id;

                var _object = new Track_RutaOptimaTmp();

                _object.Id = idRuta;
                _object.StringRuta = stringRuta;

                _context.Track_RutaOptimaTmp.Add(_object);
                _context.SaveChanges();

                id = _object.Id;

                return id;
            }

            catch (Exception)
            {
                return -1;
            }

        }

        public string GeneraRutaOptima(int criterioOptimizacion, string latOrigen, string lonOrigen, string latDestino, string lonDestino, string stringRuta1, string stringRuta2, string stringRuta3, string stringRuta4, string stringRuta5)
        {
            try
            {
                string result = _context.Track_GeneraRutaOptima(criterioOptimizacion, latOrigen, lonOrigen, latDestino, lonDestino, stringRuta1, stringRuta2, stringRuta3, stringRuta4, stringRuta5).FirstOrDefault().Respuesta;
                return result;

            }
            catch (Exception)
            {
                return "Se ha producido un error.";
            }

        }

    }
}
