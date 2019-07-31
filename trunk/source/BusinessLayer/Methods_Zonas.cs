using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using BusinessEntities;
using ContextLayer.Model;
using System.Data.Objects;

namespace BusinessLayer
{
  public class Methods_Zonas
  {
    private ModelEntities _context = new ModelEntities();

    public List<Track_TipoZonas> GetTipoZonas(bool _all = false)
    {
      try
      {
        List<Track_TipoZonas> _listTipoZonas = (from c in _context.Track_TipoZonas select c).ToList();
        if (_all)
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

    public List<Track_GetZonas_Result> GetZonas(int idTipoZona, string nombreZona)
    {
      try
      {
        List<Track_GetZonas_Result> _listZonas = _context.Track_GetZonas(idTipoZona, nombreZona).ToList();
        return _listZonas;

      }
      catch (Exception)
      {
        return new List<Track_GetZonas_Result>();
      }
    }

    public List<Track_GetZonasAsociadas_Result> GetZonasAsociadas(int idTipoZona, string nombreZona)
    {
      try
      {
        List<Track_GetZonasAsociadas_Result> _listZonas = _context.Track_GetZonasAsociadas(idTipoZona, nombreZona).ToList();
        return _listZonas;

      }
      catch (Exception)
      {
        return new List<Track_GetZonasAsociadas_Result>();
      }
    }

    public string EliminaZona(int IdZona, int idUsuario)
    {
      try
      {

        string _resp = _context.Track_EliminarZona(IdZona).FirstOrDefault().ToString();

        Methods_User _user = new Methods_User();

        //////_user.guardarlog(idUsuario, "Eliminación de zona: " + IdZona.ToString());

        return _resp;
      }
      catch (Exception)
      {
        return "Error al intentar eliminar la geocerca.";
      }
    }

    public Track_Zonas GetZonaById(int idZona)
    {
      try
      {
        Track_Zonas _zona = _context.Track_Zonas.Where(Z => Z.IdZona == idZona).FirstOrDefault();

        return _zona;
      }
      catch (Exception)
      {
        return null;
      }
    }

    public List<Track_Vertices> GetVerticesZona(int idZona)
    {
      try
      {
        List<Track_Vertices> _listVertices = new List<Track_Vertices>();

        //_listVertices = _context.Track_Vertices.Where(C => C.IdZona == idZona).OrderBy(C => C.IdPunto).ToList();

        List<Track_GetVerticesZona_Result> _vertices = _context.Track_GetVerticesZona(idZona).ToList();

        for (int i = 0; i < _vertices.Count; i++)
        {
          Track_Vertices vertice = new Track_Vertices();

          vertice.IdZona = _vertices[i].IdZona;
          vertice.IdPunto = _vertices[i].IdPunto;
          vertice.Latitud = _vertices[i].Latitud;
          vertice.Longitud = _vertices[i].Longitud;

          _listVertices.Add(vertice);
        }

        //_listVertices.RemoveAt(_listVertices.Count - 1);

        return _listVertices;
      }
      catch (Exception)
      {
        return new List<Track_Vertices>();
      }
    }

    public List<Track_Vertices> GetAllVerticesZona(int idZona)
    {
      try
      {
        List<Track_Vertices> _list = new List<Track_Vertices>();

        _list = _context.Track_Vertices.Where(C => C.IdZona == idZona).OrderBy(C => C.IdPunto).ToList();

        return _list;
      }
      catch (Exception)
      {
        return new List<Track_Vertices>();
      }
    }

    public bool ValidarIdZona(int IdZona)
    {
      try
      {
        Track_Zonas _existe = _context.Track_Zonas.Where(C => C.IdZona == IdZona).FirstOrDefault();

        if (_existe != null)
        {
          return false;
        }

        return true;
      }
      catch (Exception)
      {
        return false;
      }
    }

    public string NuevaZona(string nombreZona, int idTipoZona, string clientesAsociados, List<Tuple<decimal, decimal>> vertices, int radio, int idUsuario)
    {
      try
      {
        decimal promLat = 0;
        decimal promLon = 0;
        bool existeZona = false;

        //Track_Zonas _zona = _context.Track_Zonas.Where(C => C.IdZona == idZona).FirstOrDefault().IdZona;
        int newIdZona = (from c in _context.Track_Zonas orderby c.IdZona descending select c.IdZona).FirstOrDefault() + 1;
        if (newIdZona <= 100000000)
        {
          newIdZona = 100000001;
        }

        Track_Zonas _zona = new Track_Zonas();

        _zona.IdZona = newIdZona;
        _zona.NombreZona = nombreZona;
        _zona.IdTipoZona = idTipoZona;
        _zona.Radio = radio;

        for (int i = 0; i < vertices.Count; i++)
        {
          promLat += vertices[i].Item1;
          promLon += vertices[i].Item2;

          Track_Vertices _vertice = new Track_Vertices();
          _vertice.IdZona = _zona.IdZona;
          _vertice.IdPunto = (i + 1);
          _vertice.Latitud = vertices[i].Item1;
          _vertice.Longitud = vertices[i].Item2;

          _context.Track_Vertices.Add(_vertice);

          if (_context.Track_ExisteZonaEnPunto(vertices[i].Item1.ToString().Replace(",", "."), vertices[i].Item2.ToString().Replace(",", "."), idTipoZona).First().Value > 0)
            existeZona = true;
        }

        Track_Vertices _ultVertice = new Track_Vertices();
        _ultVertice.IdZona = _zona.IdZona;
        _ultVertice.IdPunto = vertices.Count + 1;
        _ultVertice.Latitud = vertices[0].Item1;
        _ultVertice.Longitud = vertices[0].Item2;

        _context.Track_Vertices.Add(_ultVertice);

        promLat = promLat / vertices.Count;
        promLon = promLon / vertices.Count;

        _zona.Latitud = promLat;
        _zona.Longitud = promLon;

        int existeName = 0;
        try { existeName = (from c in _context.Track_Zonas where c.NombreZona.ToLower() == nombreZona.ToLower() select c).Count(); } catch { existeName = 0; }

        if (_context.Track_ExisteZonaEnPunto(promLat.ToString().Replace(",", "."), promLon.ToString().Replace(",", "."), idTipoZona).First().Value > 0)
          existeZona = true;

        _context.Track_Zonas.Add(_zona);

        if (existeName > 0)
          return "Ya existe una zona con ese Nombre, favor utilice otro";
        else
        {
          _context.SaveChanges();

          string response = _context.Track_UpdateCodZonaIdZona(clientesAsociados, newIdZona).FirstOrDefault().Respuesta;

          if (existeZona)
          {
            return "Ya existe una zona en los puntos seleccionados, de todas formas la zona fue agregada satisfactoriamente. IdZona generado: " + newIdZona.ToString();
          }
          else
          {
            Methods_User _user = new Methods_User();
            /////_user.guardarlog(idUsuario, "Creación de zona: " + newIdZona.ToString());

            return "Zona agregada satisfactoriamente. IdZona generado: " + newIdZona.ToString();
          }
        }
      }
      catch (Exception e)
      {
        return "Se ha producido un error. Methods_Zonas.NuevaZona. " + e.InnerException;
      }
    }

    public string EditarZona(int idZona, string nombreZona, int idTipoZona, string clientesAsociados, List<Tuple<decimal, decimal>> vertices, int radio, int idUsuario)
    {
      try
      {
        decimal promLat = 0;
        decimal promLon = 0;

        Track_Zonas _zona = _context.Track_Zonas.Where(C => C.IdZona == idZona).FirstOrDefault();

        if (_zona == null)
        {
          return "El Id de Zona no existe.";
        }

        _zona.NombreZona = nombreZona;
        _zona.IdTipoZona = idTipoZona;
        _zona.Radio = radio;

        List<Track_Vertices> _vertices = _context.Track_Vertices.Where(C => C.IdZona == idZona).ToList();

        for (int i = 0; i < _vertices.Count; i++)
        {
          _context.Track_Vertices.Remove(_vertices[i]);
        }

        for (int i = 0; i < vertices.Count; i++)
        {
          promLat += vertices[i].Item1;
          promLon += vertices[i].Item2;

          Track_Vertices _vertice = new Track_Vertices();
          _vertice.IdZona = _zona.IdZona;
          _vertice.IdPunto = (i + 1);
          _vertice.Latitud = vertices[i].Item1;
          _vertice.Longitud = vertices[i].Item2;

          _context.Track_Vertices.Add(_vertice);
        }

        Track_Vertices _ultVertice = new Track_Vertices();
        _ultVertice.IdZona = _zona.IdZona;
        _ultVertice.IdPunto = vertices.Count + 1;
        _ultVertice.Latitud = vertices[0].Item1;
        _ultVertice.Longitud = vertices[0].Item2;

        _context.Track_Vertices.Add(_ultVertice);

        promLat = promLat / vertices.Count;
        promLon = promLon / vertices.Count;

        _zona.Latitud = promLat;
        _zona.Longitud = promLon;

        _context.SaveChanges();

        string response = _context.Track_UpdateCodZonaIdZona(clientesAsociados, idZona).FirstOrDefault().Respuesta;

        Methods_User _user = new Methods_User();
        //////_user.guardarlog(idUsuario, "Edición de zona: " + idZona.ToString());

        return response;
      }
      catch (Exception e)
      {
        return "Se ha producido un error. Methods_Zonas.EditarZona. " + e.InnerException;
      }
    }


    public List<Track_GetZonasToDraw_Result> GetZonasToDraw(DateTime fechaDesde, DateTime fechaHasta, string patente1, string patente2, int pNroTransporte)
    {
      try
      {
        List<Track_GetZonasToDraw_Result> _listaZonasToDraw = _context.Track_GetZonasToDraw(fechaDesde, fechaHasta, patente1, patente2, pNroTransporte).ToList();
        return _listaZonasToDraw;

      }
      catch (Exception)
      {
        return new List<Track_GetZonasToDraw_Result>();
      }
    }

    public List<Track_GetZonasToDrawModuloMapa_Result> GetZonasToDrawModuloMapa(int idAlerta)
    {
      try
      {
        List<Track_GetZonasToDrawModuloMapa_Result> _listaZonasToDraw = _context.Track_GetZonasToDrawModuloMapa(idAlerta).ToList();
        return _listaZonasToDraw;

      }
      catch (Exception)
      {
        return new List<Track_GetZonasToDrawModuloMapa_Result>();
      }
    }

    public int ZonesInsideZone(int IdZona)
    {
      try
      {
        int _zonesInsideZone = (int)_context.Track_GetZonesInsideZone(IdZona).FirstOrDefault().ZonesInsideZone;

        return _zonesInsideZone;
      }
      catch (Exception)
      {
        return -1;
      }
    }

    public List<Track_GetClientesAsociados_Result> GetClientesAsociados(int idZona, string codigoCliente, string nombreCliente)
    {
      try
      {
        List<Track_GetClientesAsociados_Result> _listClientes = _context.Track_GetClientesAsociados(idZona, codigoCliente, nombreCliente).ToList();

        return _listClientes;

      }
      catch (Exception)
      {
        return new List<Track_GetClientesAsociados_Result>();
      }
    }

    public bool ValidarCodCliente(string codCliente, int codTipoCliente)
    {
      try
      {
        Track_Clientes _existe = _context.Track_Clientes.Where(C => C.CodCliente == codCliente && C.CodTipoCliente == codTipoCliente).FirstOrDefault();

        if (_existe != null)
        {
          return false;
        }

        return true;
      }
      catch (Exception)
      {
        return false;
      }
    }

    public string EliminarCliente(string codCliente, int codtipoCliente, int idUsuario)
    {
      try
      {

        string _resp = _context.Track_EliminarCliente(codCliente, codtipoCliente).FirstOrDefault().Respuesta;

        Methods_User _user = new Methods_User();
        //////_user.guardarlog(idUsuario, "Eliminación de cliente: " + codCliente.ToString());

        return _resp;
      }
      catch (Exception)
      {
        return "Error al intentar eliminar el cliente.";
      }
    }

    public string GuardarCliente(string codCliente, int codtipoCliente, string nombreCliente, int idUsuario)
    {
      try
      {
        List<Track_CodZona_IdZona> _asociaciones = _context.Track_CodZona_IdZona.Where(C => C.CodZona == codCliente && C.CodTipoCliente == codtipoCliente).ToList();
        for (int i = 0; i < _asociaciones.Count; i++)
        {
          _context.Track_CodZona_IdZona.Remove(_asociaciones[i]);
        }

        List<Track_Clientes> _deleteClient = _context.Track_Clientes.Where(C => C.CodCliente == codCliente && C.CodTipoCliente == codtipoCliente).ToList();
        for (int i = 0; i < _deleteClient.Count; i++)
        {
          _context.Track_Clientes.Remove(_deleteClient[i]);
        }

        Track_Clientes _cliente = new Track_Clientes();

        _cliente.CodCliente = codCliente;
        _cliente.CodTipoCliente = codtipoCliente;
        _cliente.Descripcion = nombreCliente;

        _context.Track_Clientes.Add(_cliente);

        _context.SaveChanges();

        Methods_User _user = new Methods_User();
        /////_user.guardarlog(idUsuario, "Creación/modificación de cliente: " + codCliente.ToString());

        return "Cliente guardado satisfactoriamente.";
      }
      catch (Exception e)
      {
                Console.WriteLine(e.Message);
                return "Se ha producido un error al guardar el cliente.";
      }
    }

    /// <summary>
    /// Retorna listado de zonas y sus vertices, cercanos a la latitud y longitud central del mapa
    /// </summary>
    /// <param name="pLat">Latitud central del mapa</param>
    /// <param name="pLon">Longitud central del mapa</param>        
    public List<Track_GetZonasToDrawFromCenter_Result> getZonasCercanas(string pLat, string pLon)
    {
      try
      {
        List<Track_GetZonasToDrawFromCenter_Result> _result = _context.Track_GetZonasToDrawFromCenter(pLat, pLon).ToList();
        return _result;
      }
      catch (Exception ex)
      {
        string err = ex.Message.ToString();
        return new List<Track_GetZonasToDrawFromCenter_Result>();
      }
    }

    public List<Track_GetZonasClientesAsociados_Result> getZonasByclientes(string pListClientes)
    {
      try
      {
        return _context.Track_GetZonasClientesAsociados(pListClientes).ToList();
      }
      catch (Exception ex)
      {
        string err = ex.Message.ToString();
        return new List<Track_GetZonasClientesAsociados_Result>();
      }
    }

  }
}
