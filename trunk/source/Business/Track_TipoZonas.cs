//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace BusinessEntities
{
    using System;
    using System.Collections.Generic;
    
    public partial class Track_TipoZonas
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
