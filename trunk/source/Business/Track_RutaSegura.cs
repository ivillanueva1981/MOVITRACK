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
    
    public partial class Track_RutaSegura
    {
        public Track_RutaSegura()
        {
            this.Track_PuntosRutaSegura = new HashSet<Track_PuntosRutaSegura>();
        }
    
        public int Id { get; set; }
        public Nullable<int> NroTransporte { get; set; }
        public Nullable<int> CodOrigen { get; set; }
        public Nullable<int> CodDestino { get; set; }
        public string DescripcionRuta { get; set; }
        public Nullable<int> ETA { get; set; }
    
        public virtual ICollection<Track_PuntosRutaSegura> Track_PuntosRutaSegura { get; set; }
    }
}
