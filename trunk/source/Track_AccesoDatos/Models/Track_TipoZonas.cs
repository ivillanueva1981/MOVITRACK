using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Track_AccesoDatos.Models
{
    public class Track_TipoZonas
    {
 
        public Track_TipoZonas()
        {
            this.Track_Zonas = new HashSet<Track_Zonas>();
        }

        public int IdTipoZona { get; set; }
        public string NombreTipoZona { get; set; }
        public Nullable<int> Orden { get; set; }

        public virtual ICollection<Track_Zonas> Track_Zonas { get; set; }
    }
}
 
