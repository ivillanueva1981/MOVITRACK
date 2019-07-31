using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Track_AccesoDatos.Models
{
    public class Track_Zonas
    {
        public Track_Zonas()
        {
            this.Track_CodZona_IdZona = new HashSet<Track_CodZona_IdZona>();
        }

        public int IdZona { get; set; }
        public string NombreZona { get; set; }
        public int IdTipoZona { get; set; }
        public Nullable<decimal> Latitud { get; set; }
        public Nullable<decimal> Longitud { get; set; }
        public Nullable<int> Radio { get; set; }
        public string Direccion { get; set; }
        public string Permiso { get; set; }

        public virtual Track_TipoZonas Track_TipoZonas { get; set; }
        public virtual ICollection<Track_CodZona_IdZona> Track_CodZona_IdZona { get; set; }
    }
}
